import 'package:client/pb/collaboration.pb.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

enum SessionState { connecting, syncing, connected, disconnected }

typedef SyncModelFunction = Future<List<int>?> Function(List<int>, List<int>);
typedef ProcessDataFunction = void Function(List<int>);
typedef StateChangedFunction = void Function(SessionState);
typedef OnErrorFunction = void Function(String);

class CollaborationSession {
  static const _host = 'localhost';
  static const _port = '3000';

  final ProcessDataFunction onUpdateReceived;
  final SyncModelFunction? onSyncModel;
  final ProcessDataFunction? onModelReceived;
  final StateChangedFunction? onStateChanged;
  final OnErrorFunction? onError;

  final _channel = WebSocketChannel.connect(Uri.parse('ws://$_host:$_port'));
  final bool _hasModel;

  SessionState _state = SessionState.connecting;

  CollaborationSession(String uuid, List<int>? stateVector,
      {required this.onUpdateReceived,
      this.onSyncModel,
      this.onModelReceived,
      this.onStateChanged,
      this.onError})
      : _hasModel = stateVector != null {
    _channel.stream.listen(
      _processMessage,
      onError: (error) {
        print('Received error: $error');
        _setState(SessionState.disconnected);
        if (onError != null) {
          onError!('$error');
        }
      },
      onDone: () {
        print(
            'Channel closed (${_channel.closeCode}: ${_channel.closeReason})');
        _setState(SessionState.disconnected);
      },
      cancelOnError: true,
    );
    _send(CollaborationRequest(
      connectRequest: ConnectRequest(
        uuid: uuid,
        stateVector: stateVector,
      ),
    ));
  }

  SessionState get status => _state;

  void _setState(SessionState state) {
    _state = state;
    if (onStateChanged != null) {
      onStateChanged!(state);
    }
  }

  void _processMessage(message) {
    final response = CollaborationResponse.fromBuffer(message);
    print('[ws] Received response: ${response.whichMessage()}');
    switch (_state) {
      case SessionState.connecting:
        if (!response.hasConnectResponse()) {
          print('Received invalid response: $response for state $_state');
          _disconnect();
          break;
        }
        _processConnectResponse(response.connectResponse);
        break;
      case SessionState.syncing:
        if (!response.hasSyncResponse()) {
          print('Received invalid response: $response for state $_state');
          _disconnect();
          break;
        }
        _setState(SessionState.connected);
        break;
      case SessionState.connected:
        if (!response.hasUpdate()) {
          print('Received invalid response: $response for state $_state');
          _disconnect();
          break;
        }
        onUpdateReceived(response.update);
        break;
      case SessionState.disconnected:
        print('Received message while being disconnected.');
        break;
    }
  }

  void _processConnectResponse(ConnectResponse response) {
    if (_hasModel) {
      onSyncModel!(response.stateVector, response.update).then((update) =>
          _send(
              CollaborationRequest(syncRequest: SyncRequest(update: update))));
      _setState(SessionState.syncing);
    } else if (response.hasUpdate()) {
      onModelReceived!(response.update);
      _setState(SessionState.connected);
    } else {
      print('Model not found on server');
      _disconnect();
    }
  }

  void _send(CollaborationRequest request) =>
      _channel.sink.add(request.writeToBuffer());

  void _disconnect() {
    _channel.sink.close();
    _setState(SessionState.disconnected);
  }

  void sendUpdate(List<int> update) {
    if (_state != SessionState.connected) {
      print('Cannot send document data when being disconnected.');
      return;
    }
    _send(CollaborationRequest(update: update));
  }

  Future<void> close() async => await _channel.sink.close();
}

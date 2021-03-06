import 'dart:io';

import 'package:client/logic/collaboration/collaboration_channel.dart';
import 'package:client/logic/collaboration/mock_collaboration_channel.dart';
import 'package:client/logic/collaboration/ws_collaboration_channel.dart';
import 'package:client/pb/collaboration.pb.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

enum SessionState { connecting, syncing, connected, disconnected }

typedef SyncModelFunction = Future<List<int>?> Function(List<int>, List<int>);
typedef ProcessDataFunction = void Function(List<int>);
typedef StateChangedFunction = void Function(SessionState);
typedef OnErrorFunction = void Function(String);

class CollaborationSession {
  static final _host = Platform.isIOS ? 'localhost' : '10.0.2.2';
  static const _port = '3000';

  final SyncModelFunction? onSyncModel;
  final ProcessDataFunction? onModelReceived;
  final OnErrorFunction? onError;

  ProcessDataFunction? onUpdateReceived;
  StateChangedFunction? onStateChanged;

  final CollaborationChannel _channel;
  final bool _hasModel;

  SessionState _state = SessionState.connecting;

  CollaborationSession._(String uuid, List<int>? stateVector,
      {this.onSyncModel,
      this.onModelReceived,
      this.onUpdateReceived,
      this.onStateChanged,
      this.onError,
      MockCollaborationChannel? mockChannel})
      : _channel = mockChannel ??
            WsCollaborationChannel(
                WebSocketChannel.connect(Uri.parse('ws://$_host:$_port'))),
        _hasModel = stateVector != null {
    _channel.listen(_onResponse, onError: _onError, onDone: _onDone);
    _channel.send(CollaborationRequest(
        connectRequest: ConnectRequest(uuid: uuid, stateVector: stateVector)));
  }

  CollaborationSession.joinWithModel(String uuid, List<int>? stateVector,
      {required SyncModelFunction onSyncModel,
      required ProcessDataFunction onUpdateReceived,
      StateChangedFunction? onStateChanged,
      OnErrorFunction? onError,
      MockCollaborationChannel? mockChannel})
      : this._(uuid, stateVector,
            onSyncModel: onSyncModel,
            onUpdateReceived: onUpdateReceived,
            onStateChanged: onStateChanged,
            onError: onError,
            mockChannel: mockChannel);

  CollaborationSession.joinWithoutModel(String uuid,
      {required ProcessDataFunction onModelReceived,
      StateChangedFunction? onStateChanged,
      OnErrorFunction? onError,
      MockCollaborationChannel? mockChannel})
      : this._(uuid, null,
            onModelReceived: onModelReceived,
            onStateChanged: onStateChanged,
            onError: onError,
            mockChannel: mockChannel);

  SessionState get state => _state;

  void _setState(SessionState state) {
    _state = state;
    if (onStateChanged != null) {
      onStateChanged!(state);
    }
    if (_state == SessionState.connected && cachedUpdates != null) {
      cachedUpdates!.forEach(sendUpdate);
      cachedUpdates = null;
    }
  }

  void _onResponse(CollaborationResponse response) {
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
        onUpdateReceived!(response.update);
        break;
      case SessionState.disconnected:
        print('Received message while being disconnected.');
        break;
    }
  }

  void _processConnectResponse(ConnectResponse response) {
    if (_hasModel) {
      onSyncModel!(response.stateVector, response.update).then((update) =>
          _channel.send(
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

  void _onDone() {
    print('Channel closed (${_channel.closeCode}: ${_channel.closeReason})');
    _setState(SessionState.disconnected);
  }

  void _onError(dynamic error) {
    print('Received error: $error');
    _setState(SessionState.disconnected);
    if (onError != null) {
      onError!('$error');
    }
  }

  void _disconnect() {
    _channel.close();
    _setState(SessionState.disconnected);
  }

  List<List<int>>? cachedUpdates;

  void sendUpdate(List<int> update) {
    assert(_state != SessionState.disconnected);
    if (_state == SessionState.connected) {
      _channel.send(CollaborationRequest(update: update));
    } else if (cachedUpdates != null) {
      cachedUpdates!.add(update);
    } else {
      cachedUpdates = [update];
    }
  }

  Future<void> close() async => await _channel.close();
}

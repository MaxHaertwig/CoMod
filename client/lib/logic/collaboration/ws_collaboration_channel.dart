import 'package:client/logic/collaboration/collaboration_channel.dart';
import 'package:client/pb/collaboration.pb.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WsCollaborationChannel extends CollaborationChannel {
  final WebSocketChannel _wsChannel;

  WsCollaborationChannel(this._wsChannel);

  @override
  listen(void Function(CollaborationResponse) onResponse,
          {void Function(dynamic)? onError, void Function()? onDone}) =>
      _wsChannel.stream.listen(
        (message) => onResponse(CollaborationResponse.fromBuffer(message)),
        onError: onError,
        onDone: onDone,
        cancelOnError: true,
      );

  @override
  void send(CollaborationRequest request) =>
      _wsChannel.sink.add(request.writeToBuffer());

  @override
  Future<void> close() async => await _wsChannel.sink.close();

  @override
  int? get closeCode => _wsChannel.closeCode;

  @override
  String? get closeReason => _wsChannel.closeReason;
}

import 'package:client/pb/collaboration.pb.dart';

abstract class CollaborationChannel {
  listen(void Function(CollaborationResponse) onResponse,
      {void Function(dynamic)? onError, void Function()? onDone});

  void send(CollaborationRequest request);

  Future<void> close();

  int? get closeCode;
  String? get closeReason;
}

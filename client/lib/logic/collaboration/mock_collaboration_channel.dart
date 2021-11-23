import 'dart:collection';

import 'package:client/logic/collaboration/collaboration_channel.dart';
import 'package:client/pb/collaboration.pb.dart';
import 'package:flutter/services.dart' show rootBundle;

typedef OnResponseFunction = void Function(CollaborationResponse);

class MockCollaborationChannel extends CollaborationChannel {
  final List<int>? _serverModel;

  List<CollaborationRequest> _requests = [];
  var _isClosed = false;
  OnResponseFunction? _onResponse;

  MockCollaborationChannel({List<int>? serverModel})
      : _serverModel = serverModel;

  @override
  listen(OnResponseFunction onResponse,
      {void Function(dynamic)? onError, void Function()? onDone}) {
    _onResponse = onResponse;
  }

  @override
  void send(CollaborationRequest request) {
    assert(!_isClosed);
    _requests.add(request);
    if (_onResponse != null) {
      if (request.hasConnectRequest()) {
        if (!request.connectRequest.hasStateVector() && _serverModel != null) {
          _onResponse!(CollaborationResponse(
              connectResponse: ConnectResponse(update: _serverModel)));
        } else {
          _onResponse!(
              CollaborationResponse(connectResponse: ConnectResponse()));
        }
      } else if (request.hasSyncRequest()) {
        _onResponse!(CollaborationResponse(syncResponse: SyncResponse()));
      }
    }
  }

  void receive(CollaborationResponse response) {
    assert(!_isClosed);
    if (_onResponse != null) {
      _onResponse!(response);
    }
  }

  @override
  Future<void> close() async {
    assert(!_isClosed);
    _isClosed = true;
  }

  @override
  int? closeCode;

  @override
  String? closeReason;

  UnmodifiableListView<CollaborationRequest> get requests =>
      UnmodifiableListView(_requests);

  Future<String> get clientJsCode async =>
      await rootBundle.loadString('assets/client.js');
}

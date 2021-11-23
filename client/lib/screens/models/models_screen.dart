import 'dart:async';

import 'package:client/extensions.dart';
import 'package:client/logic/collaboration/collaboration_session.dart';
import 'package:client/logic/collaboration/mock_collaboration_channel.dart';
import 'package:client/logic/js_bridge.dart';
import 'package:client/logic/models_manager.dart';
import 'package:client/model/model.dart';
import 'package:client/screens/main_screen/main_screen.dart';
import 'package:client/screens/main_screen/widgets/collaboration_dialog.dart';
import 'package:client/screens/models/widgets/join_collaboration_session_dialog.dart';
import 'package:client/screens/models/widgets/model_row.dart';
import 'package:client/screens/edit_model_screen.dart';
import 'package:client/widgets/menu_item.dart';
import 'package:client/widgets/no_data_view.dart';
import 'package:flutter/material.dart';

class ModelsScreen extends StatefulWidget {
  final MockCollaborationChannel? mockChannel;

  ModelsScreen({this.mockChannel});

  @override
  State<StatefulWidget> createState() => _ModelsScreenState();
}

class _ModelsScreenState extends State<ModelsScreen> {
  List<Model>? _models;

  @override
  void initState() {
    super.initState();
    ModelsManager.allModels()
        .then((models) => setState(() => _models = models));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Models'),
          actions: [
            PopupMenuButton(
              icon: const Icon(Icons.group_add),
              tooltip: 'Collaborate',
              itemBuilder: (_) => [
                MenuItem(Icons.group_add, 'Collaborate', 0),
              ],
              onSelected: (_) => _collaborate(context),
            )
          ],
        ),
        body: _models == null
            ? Container()
            : _models!.isEmpty
                ? NoDataView(
                    'No Models',
                    'It looks pretty empty here. Create a model to get started.',
                    ['Create Model', 'Load Example'],
                    (index) => _noDataAction(context, index))
                : ListView(
                    children: _models!
                        .map((model) => ModelRow(
                              model,
                              onTap: () async {
                                await model.load();
                                _openModel(context, model);
                              },
                              onAction: (action) =>
                                  _modelAction(context, model, action),
                            ))
                        .toList(),
                  ),
        floatingActionButton: _models?.isEmpty == true
            ? null
            : FloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () => _models == null ? null : _newModel(context),
              ),
      );

  void _noDataAction(BuildContext context, int index) async {
    switch (index) {
      case 0:
        _newModel(context);
        break;
      case 1:
        _loadExample();
        break;
    }
  }

  void _newModel(BuildContext context) async {
    final model = await _editModelMetadata(context, null);
    if (model != null) {
      setState(() {
        _models?.add(model);
        _models?.sort();
      });
    }
  }

  void _loadExample() async {
    final model = await ModelsManager.newModel('Example');
    await model.loadExample();
    setState(() => _models?.add(model));
  }

  void _openModel(BuildContext context, Model model) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) =>
                MainScreen(model, mockChannel: widget.mockChannel)));
    model.stopCollaboratingIfNecessary();
  }

  void _modelAction(
      BuildContext context, Model model, ModelRowAction action) async {
    switch (action) {
      case ModelRowAction.rename:
        await _editModelMetadata(context, model);
        setState(() => _models?.sort());
        break;
      case ModelRowAction.delete:
        model.delete();
        setState(() => _models?.remove(model));
        break;
    }
  }

  Future<Model?> _editModelMetadata(BuildContext context, Model? model) async =>
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EditModelScreen(model,
              existingNames: _models!.map((model) => model.name).toSet()),
        ),
      );

  void _collaborate(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => JoinCollaborationSessionDialog(
          onJoinSession: _joinCollaborationSession),
    );
  }

  void _joinCollaborationSession(String uuid) async {
    showDialog(
      context: context,
      builder: (_) =>
          CollaborationDialog(onCancel: () => Navigator.pop(context)),
      barrierDismissible: false,
    );

    final localModel = _models?.firstWhereOrNull((model) => model.uuid == uuid);
    final onError = (String error) => ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(error)));
    if (localModel != null) {
      Navigator.pop(context);
      await localModel.collaborate(onError, mockChannel: widget.mockChannel);
      _openModel(context, localModel);
    } else {
      final completer = Completer();
      final session = CollaborationSession.joinWithoutModel(
        uuid,
        onModelReceived: (data) async {
          print('Model received');
          // TODO: don't save model right away; support collaboration-only models
          final name = 'Shared';
          final model = Model(await ModelsManager.path(uuid), name);
          await model.load(await JSBridge().loadModel(uuid, data, true));
          await ModelsManager.addModel(uuid, name);
          setState(() {
            _models?.add(model);
            _models?.sort();
          });
          completer.complete(model);
        },
        onStateChanged: (state) {
          if (state == SessionState.disconnected && !completer.isCompleted) {
            completer.complete(null);
          }
        },
        onError: onError,
        mockChannel: widget.mockChannel,
      );
      final model = await completer.future;
      Navigator.pop(context);
      if (model != null) {
        model.continueSession(session);
        _openModel(context, model);
      }
    }
  }
}

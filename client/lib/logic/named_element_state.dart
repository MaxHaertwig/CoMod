import 'package:client/model/uml/uml_element.dart';
import 'package:flutter/material.dart';

abstract class NamedElementState<T extends StatefulWidget> extends State<T> {
  final nameTextEditingController = TextEditingController();
  final VoidCallback _dispose;

  NamedElementState(NamedUMLElement element)
      : _dispose = (() => element.onNameChanged = null) {
    nameTextEditingController.text = element.name;
    element.onNameChanged = (name) {
      // TODO: improve with insert and delete
      final selection = nameTextEditingController.selection;
      nameTextEditingController.text = name;
      nameTextEditingController.selection = selection;
    };
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }
}

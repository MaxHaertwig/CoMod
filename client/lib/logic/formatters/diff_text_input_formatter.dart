import 'package:client/model/uml/uml_element.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef UpdateCallback = void Function(void Function(NamedUMLElement));

class DiffTextInputFormatter extends TextInputFormatter {
  final UpdateCallback _callback;

  DiffTextInputFormatter(UpdateCallback callback) : _callback = callback;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final selectionLength = oldValue.selection.end - oldValue.selection.start;
    final backspace =
        selectionLength == 0 && newValue.text.length < oldValue.text.length;
    _callback((element) => element.updateName(
        newValue.text,
        backspace ? oldValue.selection.start - 1 : oldValue.selection.start,
        backspace ? 1 : selectionLength,
        newValue.selection.end < oldValue.selection.start
            ? ''
            : newValue.text
                .substring(oldValue.selection.start, newValue.selection.end)));
    return newValue;
  }
}

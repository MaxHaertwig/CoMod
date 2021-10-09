import 'package:flutter/services.dart';

class UpperMultiplicityTextInputFormatter extends TextInputFormatter {
  static const _digits = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'};

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length < oldValue.text.length) {
      return newValue;
    }
    if (newValue.text.length - oldValue.text.length > 1) {
      return oldValue; // TODO: don't ignore multiple characters
    }
    final newCharacter = newValue.text[newValue.text.length - 1];
    if (oldValue.text.isEmpty) {
      return newCharacter == '*' || _digits.contains(newCharacter)
          ? newValue
          : oldValue;
    } else if (oldValue.text == '*') {
      return oldValue; // Don't allow new characters
    } else if (_digits.contains(newCharacter)) {
      return newValue;
    }
    return oldValue;
  }
}

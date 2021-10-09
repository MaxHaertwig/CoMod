import 'package:client/logic/upper_multiplicity_text_input_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('UpperMultiplicityTextInputFormatter', () {
    void _test(String oldText, String newText, String expectedText) => expect(
        UpperMultiplicityTextInputFormatter().formatEditUpdate(
            TextEditingValue(text: oldText), TextEditingValue(text: newText)),
        TextEditingValue(text: expectedText));

    // Allow number(s)
    _test('', '1', '1');
    _test('1', '12', '12');
    // Allow *
    _test('', '*', '*');
    // Allow backspace
    _test('1', '', '');
    _test('*', '', '');
    // Don't allow number(s) after *
    _test('*', '*1', '*');
    // Don't allow * after number(s)
    _test('1', '1*', '1');
  });
}

import 'package:client/model/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

typedef OnChangedFunction = void Function(String);

class NamedTextField extends StatefulWidget {
  final String name, initialValue;
  final bool autofocus;
  final OnChangedFunction? onChanged;

  NamedTextField(this.name,
      {this.initialValue = '', this.autofocus = false, this.onChanged});

  @override
  _NamedTextFieldState createState() => _NamedTextFieldState(initialValue);
}

class _NamedTextFieldState extends State<NamedTextField> {
  final _textEditingController = TextEditingController();

  _NamedTextFieldState(String initialValue) {
    _textEditingController.text = initialValue;
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextField(
            autofocus: widget.autofocus,
            decoration:
                InputDecoration(hintText: 'Enter ${widget.name.toLowerCase()}'),
            controller: _textEditingController,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                  RegExp(identifierCharactersRegex))
            ],
            onChanged: widget.onChanged,
          ),
        ],
      );
}

import 'package:client/model/document.dart';
import 'package:flutter/material.dart';

class EditModelScreen extends StatefulWidget {
  final Document? document;
  final Set<String>? existingNames;

  EditModelScreen(this.document, {this.existingNames});

  @override
  State<StatefulWidget> createState() => _EditModelScreenState(document);
}

class _EditModelScreenState extends State<EditModelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textEditingController = TextEditingController();

  var _isValid = false;

  _EditModelScreenState(Document? document) {
    _textEditingController.text = document?.name ?? '';
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.document == null ? 'New Model' : 'Edit Model'),
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _isValid ? _done : null,
            )
          ],
        ),
        body: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Name',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  autofocus: true,
                  decoration: const InputDecoration(hintText: 'Enter name'),
                  controller: _textEditingController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: _validateName,
                  onChanged: (value) {
                    setState(() =>
                        _isValid = _formKey.currentState?.validate() == true);
                  },
                ),
              ],
            ),
          ),
        ),
      );

  String? _validateName(String? name) {
    // TODO: limit allowed characters
    final trimmedName = name?.trim();
    return !(trimmedName?.isEmpty == false)
        ? 'Please enter a name.'
        : widget.existingNames?.contains(trimmedName) == true
            ? 'A model with this name already exists.'
            : null;
  }

  void _done() async {
    final name = _textEditingController.text.trim();
    if (widget.document == null) {
      final document = await Document.newDocument(name);
      Navigator.pop(context, document);
    } else if (widget.document!.name != name) {
      await widget.document!.rename(name);
      Navigator.pop(context, widget.document!);
    }
  }
}

import 'package:client/model/document.dart';
import 'package:flutter/material.dart';

class NewModelScreen extends StatefulWidget {
  final Set<String> existingNames;

  NewModelScreen(this.existingNames);

  @override
  State<StatefulWidget> createState() => _NewModelScreenState();
}

class _NewModelScreenState extends State<NewModelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  var _isValid = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Model'),
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
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Enter name'),
                controller: _nameController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  final name = value?.trim();
                  if (name?.isEmpty == false) {
                    return widget.existingNames.contains(name)
                        ? 'A model with this name already exists.'
                        : null;
                  }
                  return 'Please enter a name.';
                },
                onChanged: (value) {
                  setState(() {
                    _isValid = _formKey.currentState?.validate() == true;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _done() async {
    final document = await Document.newDocument(_nameController.text.trim());
    Navigator.pop(context, document);
  }
}

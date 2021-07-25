import 'package:client/components/no_data_view.dart';
import 'package:client/components/outline_class.dart';
import 'package:client/model/model.dart';
import 'package:client/screens/edit_class_screen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  final Model model;

  MainScreen(this.model);

  @override
  State<StatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.model.name)),
      body: widget.model.model.classes.isEmpty
          ? NoDataView(
              'No classes',
              'Your model doesn\'t have any classes yet. Press the button to create one.',
              'Create Class', () {
              _newClass(context);
            })
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: widget.model.model.classes
                  .map((cls) => OutlineClass(cls))
                  .toList(),
            ),
      floatingActionButton: widget.model.model.classes.isEmpty
          ? null
          : FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                _newClass(context);
              },
            ),
    );
  }

  void _newClass(BuildContext context) {}
}

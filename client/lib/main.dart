import 'package:client/screens/models/models_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Client',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: ModelsScreen(),
      );
}

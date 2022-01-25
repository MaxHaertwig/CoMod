import 'package:client/logic/collaboration/mock_collaboration_channel.dart';
import 'package:client/model/constants.dart';
import 'package:client/screens/models/models_screen.dart';
import 'package:flutter/material.dart';

void main({MockCollaborationChannel? mockChannel}) {
  runApp(MyApp(mockChannel: mockChannel));
}

class MyApp extends StatelessWidget {
  final MockCollaborationChannel? mockChannel;

  MyApp({this.mockChannel});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Client',
        theme: ThemeData(primarySwatch: appColor),
        home: ModelsScreen(mockChannel: mockChannel),
        debugShowCheckedModeBanner: false,
      );
}

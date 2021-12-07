import 'dart:async';
import 'dart:convert';

import 'package:client/logic/collaboration/mock_collaboration_channel.dart';
import 'package:client/pb/collaboration.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:client/main.dart' as app;

import 'integration_test_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('collaboration', () {
    testWidgets('join with model', (tester) async {
      final mockChannel = MockCollaborationChannel();

      await launchApp(() => app.main(mockChannel: mockChannel), tester);
      await _loadExampleAndCollaborate(tester);

      await tester.tap(find.text('Copy link'));

      expect(mockChannel.requests.length, 2); // Connect, Sync
      expect(mockChannel.requests[0].hasConnectRequest(), true);
      expect(mockChannel.requests[1].hasSyncRequest(), true);
    });

    testWidgets('join without model', (tester) async {
      final mockChannel = MockCollaborationChannel();

      await launchApp(() => app.main(mockChannel: mockChannel), tester);
      await _joinCollaborationSession(tester);

      expect(mockChannel.requests.length, 1); // Connect
      expect(mockChannel.requests.first.hasConnectRequest(), true);
    });

    testWidgets('emit changes', (tester) async {
      final mockChannel = MockCollaborationChannel();

      await launchApp(() => app.main(mockChannel: mockChannel), tester);
      await _loadExampleAndCollaborate(tester);

      await tester.tap(find.text('Student').first);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Pupil');
      await tester.pumpAndSettle();

      expect(mockChannel.requests.length, 3); // Connect, Sync, Update
      expect(mockChannel.requests.last.hasUpdate(), true);
    });

    testWidgets('process changes', (tester) async {
      const model =
          'AQqhp7qVBQAHAQADBW1vZGVsKAChp7qVBQAEdXVpZAF3JDY4YmJkM2E3LTNiYzktNGMwOS04ODVlLWIyNzg0NDZmYmQyNQcAoae6lQUAAwR0eXBlBwChp7qVBQIGBAChp7qVBQMFVHlwZUGHoae6lQUDAwpzdXBlcnR5cGVzh6GnupUFCQMKYXR0cmlidXRlc4ehp7qVBQoDCm9wZXJhdGlvbnMoAKGnupUFAgJpZAF3JDA5YTBlMGZhLTA1YjYtNGQ3NS1hZDY1LTRmYWU0Yjc5MGRlOCgAoae6lQUCBHR5cGUBdwVjbGFzcwA='; // TypeA
      const update = 'AQGhp7qVBQ6Eoae6lQUIAUIA'; // TypeA -> TypeAB

      final mockChannel =
          MockCollaborationChannel(serverModel: base64Decode(model));

      await launchApp(() => app.main(mockChannel: mockChannel), tester);
      await _joinCollaborationSession(tester);

      mockChannel.receive(CollaborationResponse(update: base64Decode(update)));
      await tester.pumpAndSettle();

      expect(find.text('TypeAB'), findsOneWidget);
    });
  });
}

Future<void> _loadExampleAndCollaborate(WidgetTester tester) async {
  await loadExample(tester, true);

  await tester.tap(find.byTooltip('Collaboration'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Collaborate'));
  await tester.pumpAndSettle();
}

Future<void> _joinCollaborationSession(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Collaborate'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Collaborate'));
  await tester.pumpAndSettle();

  await tester.enterText(find.byType(TextField),
      'collaborate://maxhaertwig.com/thesis/68bbd3a7-3bc9-4c09-885e-b278446fbd25'); // random UUID
  await tester.pumpAndSettle();

  await tester.tap(find.text('Join'));
  await tester.pumpAndSettle();
}

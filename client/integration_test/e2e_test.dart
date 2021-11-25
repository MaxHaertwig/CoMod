import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:client/main.dart' as app;

import 'integration_test_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('e2e', () {
    testWidgets('client1', (tester) async {
      await launchApp(() => app.main(), tester);

      await loadExample(tester, true);

      await tester.tap(find.byTooltip('Collaboration'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Collaborate'));
      await tester.pumpAndSettle();
    });

    testWidgets('client2', (tester) async {
      await launchApp(() => app.main(), tester);

      await tester.tap(find.byTooltip('Collaborate'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Collaborate'));
      await tester.pumpAndSettle();

      const collaborationUUID = String.fromEnvironment('collaboration_uuid');
      await tester.enterText(find.byType(TextField), collaborationUUID);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Join'));
      await tester.pumpAndSettle();

      expect(find.text('Being'), findsWidgets);
    });
  });
}

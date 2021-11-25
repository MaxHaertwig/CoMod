import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:client/main.dart' as app;

import 'integration_test_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('local', () {
    testWidgets('create model', (tester) async {
      await launchApp(() => app.main(), tester);

      const modelName = 'University';
      await _createModel(tester, modelName);

      expect(find.text(modelName), findsOneWidget);
    });

    testWidgets('load example', (tester) async {
      await launchApp(() => app.main(), tester);
      await loadExample(tester, true);

      expect(find.text('Example'), findsOneWidget);
    });

    testWidgets('create type', (tester) async {
      await launchApp(() => app.main(), tester);

      const modelName = 'University';
      await _createModel(tester, modelName);

      await tester.tap(find.text(modelName));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create Type'));
      await tester.pumpAndSettle();

      const typeName = 'Person';
      await tester.enterText(find.byType(TextField), typeName);
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Type'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Abstract Class'));
      await tester.pumpAndSettle();

      // Attribute
      await tester.tap(find.text('Add attribute'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(1), 'age');
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Visibility'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('- private'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Data type'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('integer'));
      await tester.pumpAndSettle();

      // Operation
      await tester.tap(find.text('Add operation'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(2), 'study');
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Return type'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('boolean'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      expect(find.text(typeName), findsOneWidget);
      expect(find.text('- age: integer'), findsOneWidget);
      expect(find.text('+ study(): boolean'), findsOneWidget);
    });

    testWidgets('delete type', (tester) async {
      await launchApp(() => app.main(), tester);

      const modelName = 'University';
      await _createModel(tester, modelName);

      await tester.tap(find.text(modelName));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create Type'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Delete type'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete type'));
      await tester.pumpAndSettle();

      expect(find.text('No types'), findsOneWidget);
    });
  });
}

Future<void> _createModel(WidgetTester tester, String name) async {
  await tester.tap(find.text('Create Model'));
  await tester.pumpAndSettle();

  await tester.enterText(find.byType(TextField), name);
  await tester.pumpAndSettle();

  await tester.tap(find.byTooltip('Done'));
  await tester.pumpAndSettle();
}

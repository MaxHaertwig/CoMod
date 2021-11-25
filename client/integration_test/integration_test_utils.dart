import 'package:flutter_test/flutter_test.dart';

Future<void> launchApp(void Function() main, WidgetTester tester) async {
  main();
  await tester.pumpAndSettle();

  // Delete existing models
  while (find.text('No Models').evaluate().isEmpty) {
    await tester.tap(find.byTooltip('Model actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
  }
}

Future<void> loadExample(WidgetTester tester, bool openModel) async {
  await tester.tap(find.text('Load Example'));
  await tester.pumpAndSettle();

  if (openModel) {
    await tester.tap(find.text('Example'));
    await tester.pumpAndSettle();
  }
}

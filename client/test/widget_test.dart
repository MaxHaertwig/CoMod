import 'package:flutter_test/flutter_test.dart';

import 'package:client/main.dart';

void main() {
  testWidgets('Initializer', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
  });
}

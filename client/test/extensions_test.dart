import 'dart:collection';

import 'package:client/extensions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuple/tuple.dart';

void main() {
  test('Iterable firstWhereOrNull', () {
    final list = [0, 1, 2];
    expect(list.firstWhereOrNull((val) => val == 1), 1);
    expect(list.firstWhereOrNull((val) => val == 3), null);
  });

  test('LinkedHashMap move', () {
    final tests = [
      Tuple3(0, MoveType.moveToTop, [0, 1, 2, 3, 4, 5]),
      Tuple3(3, MoveType.moveToTop, [3, 0, 1, 2, 4, 5]),
      Tuple3(0, MoveType.moveUp, [0, 1, 2, 3, 4, 5]),
      Tuple3(3, MoveType.moveUp, [0, 1, 3, 2, 4, 5]),
      Tuple3(3, MoveType.moveDown, [0, 1, 2, 4, 3, 5]),
      Tuple3(5, MoveType.moveDown, [0, 1, 2, 3, 4, 5]),
      Tuple3(5, MoveType.moveToBottom, [0, 1, 2, 3, 4, 5]),
    ];
    for (final test in tests) {
      final list = LinkedHashMap.fromIterable([0, 1, 2, 3, 4, 5]);
      list.move(test.item1, test.item2);
      expect(list.values, test.item3);
    }
  });

  test('Map moveTypes', () {
    final tests = [
      Tuple3([], 0, Set<MoveType>()),
      Tuple3([0], 0, Set<MoveType>()),
      Tuple3([0, 1], 0, {MoveType.moveDown}),
      Tuple3([0, 1], 1, {MoveType.moveUp}),
      Tuple3([0, 1, 2, 3], 1,
          {MoveType.moveUp, MoveType.moveDown, MoveType.moveToBottom}),
    ];
    for (final test in tests) {
      expect(LinkedHashMap.fromIterable(test.item1).moveTypes(test.item2),
          test.item3);
    }
  });
}

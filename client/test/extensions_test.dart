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

  test('Iterable compactMap', () {
    final list = [1, 2, 3, 4];
    expect(list.compactMap((x) => null), []);
    expect(list.compactMap((x) => x), list);
    expect(list.compactMap((x) => x % 2 == 0 ? x : null), [2, 4]);
  });

  test('LinkedHashMap insertAt', () {
    final tests = [
      Tuple2(0, [9, 0, 1, 2]),
      Tuple2(1, [0, 9, 1, 2]),
      Tuple2(2, [0, 1, 9, 2]),
      Tuple2(3, [0, 1, 2, 9]),
      Tuple2(4, [0, 1, 2, 9]),
    ];
    for (final test in tests) {
      final list = LinkedHashMap.fromIterable([0, 1, 2]);
      list.insertAt(9, 9, test.item1);
      expect(list.values, test.item2);
    }
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

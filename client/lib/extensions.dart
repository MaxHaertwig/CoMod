import 'dart:collection';

extension IterableExtensions<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    final list = where(test);
    return list.isEmpty ? null : list.first;
  }
}

enum MoveType { moveToTop, moveUp, moveDown, moveToBottom }

extension LinkedHashMapExtensions<K, V> on LinkedHashMap<K, V> {
  void move(K key, MoveType moveType) {
    if (length <= 1 || !containsKey(key)) {
      return;
    }
    switch (moveType) {
      case MoveType.moveToTop:
        if (key != keys.first) {
          final value = remove(key)!;
          final entriesList = entries.toList();
          clear();
          this[key] = value;
          addEntries(entriesList);
        }
        break;
      case MoveType.moveUp:
        if (key != keys.first) {
          final entriesList = entries.toList();
          final index = keys.toList().indexOf(key);
          keys.skip(index - 1).toList().forEach((k) => remove(k));
          this[key] = entriesList[index].value;
          final previousEntry = entriesList[index - 1];
          this[previousEntry.key] = previousEntry.value;
          entriesList.skip(index + 1).forEach((e) => this[e.key] = e.value);
        }
        break;
      case MoveType.moveDown:
        if (key != keys.last) {
          final entriesList = entries.toList();
          final index = keys.toList().indexOf(key);
          keys.skip(index).toList().forEach((k) => remove(k));
          final nextEntry = entriesList[index + 1];
          this[nextEntry.key] = nextEntry.value;
          this[key] = entriesList[index].value;
          entriesList.skip(index + 2).forEach((e) => this[e.key] = e.value);
        }
        break;
      case MoveType.moveToBottom:
        if (key != keys.last) {
          this[key] = remove(key)!;
        }
        break;
    }
  }
}

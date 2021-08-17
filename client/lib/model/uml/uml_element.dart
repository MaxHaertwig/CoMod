import 'package:tuple/tuple.dart';

abstract class UMLElement {
  String get id => '';

  String get name => '';
  set name(String newName) {}

  List<UMLElement>? update(List<Tuple2<String, String>> attributes,
      List<String> addedElements, List<String> deletedElements) {}
}

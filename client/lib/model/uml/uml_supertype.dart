import 'package:client/model/model.dart';
import 'package:client/model/uml/uml_type.dart';
import 'package:client/model/uml/uml_element.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';

class UMLSupertype implements UMLElement {
  static const xmlTag = 'supertype';
  static const _idAttribute = 'id';
  static const _superIDAttribute = 'superID';

  UMLType? _umlType;
  final String id, superID;

  UMLSupertype({String? id, this.superID = ''}) : id = id ?? Uuid().v4();

  static UMLSupertype fromXml(String xml) =>
      fromXmlElement(XmlDocument.parse(xml).rootElement);

  static UMLSupertype fromXmlElement(XmlElement element) {
    assert(element.name.toString() == xmlTag);
    return UMLSupertype(
      id: element.getAttribute(_idAttribute)!,
      superID: element.getAttribute(_superIDAttribute)!,
    );
  }

  set umlType(UMLType umlType) => _umlType = umlType;

  Model? get model => _umlType?.model;

  void addToModel() => model?.insertElement(
      this, _umlType!.id, 1, xmlTag, '', [Tuple2(_superIDAttribute, superID)]);

  String get xmlRepresentation =>
      '<$xmlTag $_idAttribute="$id" $_superIDAttribute="$superID" />';

  @override
  int get hashCode => superID.hashCode;

  @override
  bool operator ==(other) => other is UMLSupertype && other.superID == superID;

  @override
  List<UMLElement>? update(
      List<Tuple2<String, String>> attributes,
      List<Tuple2<String, int>> addedElements,
      List<Tuple2<String, String>> deletedElements) {} // Class can't be updated
}

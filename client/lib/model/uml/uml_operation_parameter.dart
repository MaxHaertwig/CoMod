import 'package:client/model/model.dart';
import 'package:client/model/uml/uml_data_type.dart';
import 'package:client/model/uml/uml_element.dart';
import 'package:client/model/uml/uml_model.dart';
import 'package:client/model/uml/uml_operation.dart';
import 'package:either_dart/either.dart';
import 'package:tuple/tuple.dart';
import 'package:xml/xml.dart';

class UMLOperationParameter extends NamedUMLElement {
  static const xmlTag = 'param';
  static const _idAttribute = 'id';
  static const _typeAttribute = 'type';

  UMLOperation? _operation;
  UMLDataType _type;

  UMLOperationParameter({String? id, name = '', UMLDataType? type})
      : _type = type ?? UMLDataType(Left(UMLPrimitiveType.string)),
        super(id: id, name: name);

  static UMLOperationParameter fromXml(String xml) =>
      fromXmlElement(XmlDocument.parse(xml).rootElement);

  static UMLOperationParameter fromXmlElement(XmlElement element) {
    assert(element.name.toString() == xmlTag);
    return UMLOperationParameter(
      id: element.getAttribute(_idAttribute)!,
      name: element.text.trim(),
      type: UMLDataType.fromString(element.getAttribute(_typeAttribute)!),
    );
  }

  set operation(UMLOperation operation) => _operation = operation;

  Model? get model => _operation?.model;

  UMLDataType get type => _type;

  set type(UMLDataType type) {
    if (type != _type) {
      _type = type;
      model?.updateAttribute(id, _typeAttribute, type.xmlRepresentation);
    }
  }

  void addToModel() => model?.insertElement(this, _operation!.id, -1, xmlTag,
      name, [Tuple2(_typeAttribute, type.xmlRepresentation)]);

  String get xmlRepresentation =>
      '<$xmlTag $_idAttribute="$id" $_typeAttribute="${_type.xmlRepresentation}">' +
      name +
      '</$xmlTag>';

  String stringRepresentation(UMLModel umlModel) =>
      '$name: ${_type.stringRepresentation(umlModel)}';

  @override
  String toString() => '$name: $_type';

  @override
  List<UMLElement>? update(
      List<Tuple2<String, String>> attributes,
      List<Tuple2<String, int>> addedElements,
      List<Tuple2<String, String>> deletedElements) {
    for (final tuple in attributes) {
      if (tuple.item1 == _typeAttribute) {
        _type = UMLDataType.fromString(tuple.item2);
      }
    }
  }
}

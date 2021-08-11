import 'package:client/model/model.dart';
import 'package:client/model/uml/uml_data_type.dart';
import 'package:client/model/uml/uml_operation.dart';
import 'package:either_dart/either.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';

class UMLOperationParameter {
  static const xmlTag = 'param';
  static const _typeAttribute = 'type';

  UMLOperation? _operation;
  final String id;
  String _name;
  UMLDataType _type;

  UMLOperationParameter({String? id, name = '', UMLDataType? type})
      : id = id ?? Uuid().v4(),
        _name = name,
        _type = type ?? UMLDataType(Left(UMLPrimitiveType.string));

  static UMLOperationParameter fromXml(XmlElement element) {
    assert(element.name.toString() == 'param');
    return UMLOperationParameter(
      name: element.innerText.trim(),
      type: UMLDataType.fromString(element.getAttribute('type')!),
    );
  }

  set operation(UMLOperation operation) => _operation = operation;

  Model? get model => _operation?.model;

  String get name => _name;

  UMLDataType get type => _type;

  String get stringRepresentation => '$_name: ${_type.stringRepresentation}';

  String get xmlRepresentation =>
      '<$xmlTag id="$id" $_typeAttribute="${_type.xmlRepresentation}">' +
      _name +
      '</$xmlTag>';
}

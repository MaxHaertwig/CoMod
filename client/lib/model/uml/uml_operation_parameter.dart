import 'package:client/model/model.dart';
import 'package:client/model/uml/uml_data_type.dart';
import 'package:client/model/uml/uml_element.dart';
import 'package:client/model/uml/uml_operation.dart';
import 'package:either_dart/either.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';

class UMLOperationParameter implements UMLElement {
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

  set name(String newName) {
    if (newName != _name) {
      final oldName = _name;
      _name = newName;
      model?.updateText(id, oldName, newName);
    }
  }

  UMLDataType get type => _type;

  String get stringRepresentation => '$_name: ${_type.stringRepresentation}';

  String get xmlRepresentation =>
      '<$xmlTag id="$id" $_typeAttribute="${_type.xmlRepresentation}">' +
      _name +
      '</$xmlTag>';

  List<UMLElement>? update(List<Tuple2<String, String>> attributes,
      List<String> addedElements, List<String> deletedElements) {
    // TODO: implement update
  }
}

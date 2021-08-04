import 'dart:io';

import 'package:client/model/uml/uml_data_type.dart';
import 'package:client/model/uml/uml_visibility.dart';
import 'package:either_dart/either.dart';
import 'package:test/test.dart';
import 'package:client/model/uml/uml_model.dart';
import 'package:xml/xml.dart';

void main() {
  test('UMLModel should load model from XML file.', () async {
    final xmlString = await File('test_resources/valid.xml').readAsString();
    final root = XmlDocument.parse(xmlString).rootElement;
    final model = UMLModel.fromXml(root);
    expect(model.version, '1.0');
    expect(model.classes.values.map((c) => c.name).toSet(),
        {'Person', 'Student', 'Book'});

    final person = model.classes.values.firstWhere((c) => c.name == 'Person');
    expect(person.attributes.map((a) => a.name).toList(), ['Name', 'Age']);

    final personName = person.attributes.firstWhere((a) => a.name == 'Name');
    expect(personName.visibility, UMLVisibility.public);
    expect(personName.dataType, UMLDataType.string());

    final personAge = person.attributes.firstWhere((a) => a.name == 'Age');
    expect(personAge.visibility, UMLVisibility.private);
    expect(personAge.dataType, UMLDataType.integer());

    final student = model.classes.values.firstWhere((c) => c.name == 'Student');
    expect(student.attributes.map((a) => a.name).toList(), ['Major']);

    final studentMajor =
        student.attributes.firstWhere((a) => a.name == 'Major');
    expect(studentMajor.visibility, UMLVisibility.public);
    expect(studentMajor.dataType, UMLDataType.string());

    final studentStudy =
        student.operations.firstWhere((op) => op.name == 'study');
    expect(studentStudy.visibility, UMLVisibility.protected);
    expect(studentStudy.returnType, UMLDataType.voidType());
    expect(studentStudy.parameters.map((p) => p.name).toList(),
        ['subject', 'hours']);
    expect(studentStudy.parameters[0].type,
        UMLDataType(Left(UMLPrimitiveType.string)));
    expect(studentStudy.parameters[1].type,
        UMLDataType(Left(UMLPrimitiveType.integer)));
  });
}

import 'dart:io';

import 'package:client/model/uml/uml_attribute.dart';
import 'package:client/model/uml/uml_class.dart';
import 'package:client/model/uml/uml_data_type.dart';
import 'package:client/model/uml/uml_operation.dart';
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
    expect(
        person.attributes.values.map((a) => a.name).toList(), ['Name', 'Age']);

    final personName =
        person.attributes.values.firstWhere((a) => a.name == 'Name');
    expect(personName.visibility, UMLVisibility.public);
    expect(personName.dataType, UMLDataType.string());

    final personAge =
        person.attributes.values.firstWhere((a) => a.name == 'Age');
    expect(personAge.visibility, UMLVisibility.private);
    expect(personAge.dataType, UMLDataType.integer());

    final student = model.classes.values.firstWhere((c) => c.name == 'Student');
    expect(student.attributes.values.map((a) => a.name).toList(), ['Major']);

    final studentMajor =
        student.attributes.values.firstWhere((a) => a.name == 'Major');
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

  test('UMLModel xmlRepresentation', () {
    final umlModel = UMLModel(
      uuid: 'M',
      classes: [
        UMLClass(
          id: 'P',
          name: 'Person',
          attributes: [
            UMLAttribute(
              name: 'name',
              visibility: UMLVisibility.public,
              dataType: UMLDataType.string(),
            ),
            UMLAttribute(
              name: 'age',
              visibility: UMLVisibility.private,
              dataType: UMLDataType.integer(),
            ),
          ],
        ),
        UMLClass(
          id: 'S',
          name: 'Student',
          y: 100,
          attributes: [
            UMLAttribute(
              name: 'major',
              visibility: UMLVisibility.public,
              dataType: UMLDataType.string(),
            ),
          ],
          operations: [
            UMLOperation(
              name: 'study',
              visibility: UMLVisibility.protected,
              parameters: [
                UMLOperationParameter(
                  name: 'subject',
                  type: UMLDataType.string(),
                ),
                UMLOperationParameter(
                  name: 'hours',
                  type: UMLDataType.integer(),
                )
              ],
            )
          ],
        ),
      ],
    );
    final xml = '''<?xml version="1.0" encoding="UTF-8"?>
    <model version="1.0" uuid="M">
      <class id="P" x="0" y="0">
        <name>Person</name>
        <attribute visibility="public" type="string">name</attribute>
        <attribute visibility="private" type="integer">age</attribute>
      </class>
      <class id="S" x="0" y="100">
        <name>Student</name>
        <attribute visibility="public" type="string">major</attribute>
        <operation visibility="protected" returnType="void">
          <name>study</name>
          <param type="string">subject</param>
          <param type="integer">hours</param>
        </operation>
      </class>
    </model>
    '''
        .split('\n')
        .map((line) => line.trim())
        .join();
    expect(umlModel.xmlRepresentation, xml);
  });
}

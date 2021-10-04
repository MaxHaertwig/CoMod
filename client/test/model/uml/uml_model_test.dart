import 'dart:io';

import 'package:client/model/uml/uml_attribute.dart';
import 'package:client/model/uml/uml_type.dart';
import 'package:client/model/uml/uml_data_type.dart';
import 'package:client/model/uml/uml_operation.dart';
import 'package:client/model/uml/uml_operation_parameter.dart';
import 'package:client/model/uml/uml_type_type.dart';
import 'package:client/model/uml/uml_visibility.dart';
import 'package:either_dart/either.dart';
import 'package:test/test.dart';
import 'package:client/model/uml/uml_model.dart';

void main() {
  test('UMLModel should load model from XML file.', () async {
    final xmlString = await File('test_resources/valid.xml').readAsString();
    final model = UMLModel.fromXml(xmlString);
    expect(model.types.values.map((c) => c.name).toSet(),
        {'Person', 'Student', 'Book'});

    final person = model.types.values.firstWhere((c) => c.name == 'Person');
    expect(person.type, UMLTypeType.abstractClass);
    expect(person.extendsClass, '');
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

    final student = model.types.values.firstWhere((c) => c.name == 'Student');
    expect(student.type, UMLTypeType.classType);
    expect(student.extendsClass, person.id);
    expect(student.attributes.values.map((a) => a.name).toList(), ['Major']);

    final studentMajor =
        student.attributes.values.firstWhere((a) => a.name == 'Major');
    expect(studentMajor.visibility, UMLVisibility.public);
    expect(studentMajor.dataType, UMLDataType.string());

    final studentStudy =
        student.operations.values.firstWhere((op) => op.name == 'study');
    expect(studentStudy.visibility, UMLVisibility.protected);
    expect(studentStudy.returnType, UMLDataType.voidType());
    expect(studentStudy.parameters.values.map((p) => p.name).toList(),
        ['subject', 'hours']);
    expect(studentStudy.parameters.values.first.type,
        UMLDataType(Left(UMLPrimitiveType.string)));
    expect(studentStudy.parameters.values.skip(1).first.type,
        UMLDataType(Left(UMLPrimitiveType.integer)));
  });

  test('UMLModel xmlRepresentation', () {
    final person = UMLType(
      id: 'P',
      name: 'Person',
      attributes: [
        UMLAttribute(
          id: 'PA1',
          name: 'name',
          visibility: UMLVisibility.public,
          dataType: UMLDataType.string(),
        ),
        UMLAttribute(
          id: 'PA2',
          name: 'age',
          visibility: UMLVisibility.private,
          dataType: UMLDataType.integer(),
        ),
      ],
    );
    final umlModel = UMLModel(
      uuid: 'M',
      types: [
        person,
        UMLType(
          id: 'S',
          name: 'Student',
          y: 100,
          extendsClass: person.id,
          attributes: [
            UMLAttribute(
              id: 'SA1',
              name: 'major',
              visibility: UMLVisibility.public,
              dataType: UMLDataType.string(),
            ),
          ],
          operations: [
            UMLOperation(
              id: 'SO1',
              name: 'study',
              visibility: UMLVisibility.protected,
              parameters: [
                UMLOperationParameter(
                  id: 'SOP1',
                  name: 'subject',
                  type: UMLDataType.string(),
                ),
                UMLOperationParameter(
                  id: 'SOP2',
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
    <model uuid="M">
      <type id="P" x="0" y="0" type="class" extends="">
        Person
        <attributes>
          <attribute id="PA1" visibility="public" type="string">name</attribute>
          <attribute id="PA2" visibility="private" type="integer">age</attribute>
        </attributes>
        <operations></operations>
      </type>
      <type id="S" x="0" y="100" type="class" extends="P">
        Student
        <attributes>
          <attribute id="SA1" visibility="public" type="string">major</attribute>
        </attributes>
        <operations>
          <operation id="SO1" visibility="protected" returnType="void">
            study
            <param id="SOP1" type="string">subject</param>
            <param id="SOP2" type="integer">hours</param>
          </operation>
        </operations>
      </type>
    </model>
    '''
        .split('\n')
        .map((line) => line.trim())
        .join();
    expect(umlModel.xmlRepresentation, xml);
  });

  test('UMLModel should load partially empty model', () {
    final xml = '''<model uuid="M">
      <type id="Empty" x="0" y="0" type="class" extends="">
        <attributes />
        <operations />
      </type>
      <type id="EmptyAttributeAndOperation" x="0" y="0" type="class" extends="">
        <attributes>
          <attribute id="AA" visibility="public" type="string"></attribute>
        </attributes>
        <operations>
          <operation id="BO" visibility="protected" returnType="void"></operation>
        </operations>
      </type>
      <type id="EmptyOperationParameter" x="0" y="0" type="class" extends="">
        <attributes />
        <operations>
          <operation id="BO" visibility="protected" returnType="void">
            <param id="BOP" type="string"></param>
          </operation>
        </operations>
      </type>
    </model>''';
    UMLModel.fromXml(xml);
  });
}

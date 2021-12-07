import { v4 as uuidv4 } from 'uuid';
import * as yjs from 'yjs';

export function createModel(uuid?: string): yjs.XmlElement {
  const model = new yjs.XmlElement('model');
  model.setAttribute('uuid', uuid ?? uuidv4());
  model.push([createType()]);
  return model;
}

export function createType(): yjs.XmlElement {
  const type = new yjs.XmlElement('type');
  type.setAttribute('id', uuidv4());
  type.setAttribute('type', randomTypeType());
  type.push([
    new yjs.XmlText('abcde'),
    new yjs.XmlElement('supertypes'),
    new yjs.XmlElement('attributes'),
    new yjs.XmlElement('operations')
  ]);
  return type;
}

export function randomTypeType(): string {
  const values = ['class', 'abstractClass', 'interface'];
  return values[Math.floor(Math.random() * values.length)];
}

export function createAttribute(): yjs.XmlElement {
  const attribute = new yjs.XmlElement('attribute');
  attribute.setAttribute('id', uuidv4());
  attribute.setAttribute('visibility', randomVisibility());
  attribute.setAttribute('type', randomDataType());
  attribute.push([new yjs.XmlText('abcde')]);
  return attribute;
}

export function randomVisibility(): string {
  const values = ['public', 'package', 'protected', 'private'];
  return values[Math.floor(Math.random() * values.length)];
}

export function randomDataType(): string {
  const values = ['boolean', 'integer', 'real', 'string'];
  return values[Math.floor(Math.random() * values.length)];
}

export function createOperation(): yjs.XmlElement {
  const operation = new yjs.XmlElement('operation');
  operation.setAttribute('id', uuidv4());
  operation.setAttribute('visibility', randomVisibility());
  operation.setAttribute('returnType', randomDataType());
  operation.push([new yjs.XmlText('abcde')]);
  return operation;
}

export function createOperationParameter(): yjs.XmlElement {
  const param = new yjs.XmlElement('param');
  param.setAttribute('id', uuidv4());
  param.setAttribute('type', randomDataType());
  param.push([new yjs.XmlText('abcde')]);
  return param;
}

export function createRelationship(model: yjs.XmlElement): yjs.XmlElement {
  const ids = (model.toArray() as yjs.XmlElement[])
    .filter(child => child.nodeName === 'type')
    .map(type => type.getAttribute('id'));
  if (ids.includes('undefined')) {
    console.log('!!!!!!!!!!!!!!!');
    console.log(model.toArray());
  }
  const relationship = new yjs.XmlElement('relationship');
  relationship.setAttribute('id', uuidv4());
  relationship.setAttribute('from', ids[Math.floor(Math.random() * ids.length)]);
  relationship.setAttribute('to', ids[Math.floor(Math.random() * ids.length)]);
  relationship.setAttribute('fromMulti', '');
  relationship.setAttribute('toMulti', '');
  relationship.setAttribute('type', randomRelationshipType());
  relationship.push([new yjs.XmlText('')]);
  return relationship;
}

export function randomRelationshipType(): string {
  const values = ['association', 'aggregation', 'composition', 'associationWithClass', 'qualifiedAssociation'];
  return values[Math.floor(Math.random() * values.length)];
}

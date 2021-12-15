import * as fs from 'fs';
import { Base64 } from 'js-base64';
import * as yjs from 'yjs';
import { createAttribute, createModel, createOperation, createOperationParameter, createRelationship, createType, randomDataType, randomTypeType, randomVisibility } from './model_components';

const fileName = process.argv[2];
const iterations = parseInt(process.argv[3]);
const clients = parseInt(process.argv[4]);

async function main() {
  const path = 'test-data/' + fileName;
  try {
    fs.unlinkSync(path);
  } catch (error) {}

  const yDoc = new yjs.Doc();
  yDoc.getXmlFragment().push([createModel()]);
  fs.appendFileSync(path, Base64.fromUint8Array(yjs.encodeStateAsUpdate(yDoc)) + '\n')

  for (let i = 0; i < iterations; i++) {
    if (i % 10 === 0) {
      console.log('Iteration ' + i);
    }
    const data = yjs.encodeStateAsUpdate(yDoc);
    try {
      const updates = await Promise.all([...Array(clients).keys()].map(() => generateUpdate(data).catch(console.error)));
      updates.forEach(update => fs.appendFileSync(path, Base64.fromUint8Array(update!) + '\n'));
      updates.forEach(update => yjs.applyUpdate(yDoc, update!));
    } catch (error) {
      console.log(error);
    }
  }
}

function elementList(element: yjs.XmlElement): yjs.XmlElement[] {
  const children = element.toArray()
    .filter(x => x instanceof yjs.XmlElement)
    .map(x => elementList(x as yjs.XmlElement))
    .flat();
  return [element, ...children];
}

function generateUpdate(data: Uint8Array): Promise<Uint8Array> {
  const copy = new yjs.Doc();
  yjs.applyUpdate(copy, data);
  return new Promise(resolve => {
    copy.on('update', resolve);
    performRandomChange(copy.getXmlFragment().get(0) as yjs.XmlElement);
  });
}

enum ChangeType {
  Insert, Delete, Attribute, Text
}

const changeTypes = [
  ...Array(3).fill(ChangeType.Insert),
  ...Array(1).fill(ChangeType.Delete),
  ...Array(6).fill(ChangeType.Attribute),
  ...Array(40).fill(ChangeType.Text)
];

function performRandomChange(model: yjs.XmlElement): void {
  const elements = elementList(model);
  let changeType = changeTypes[Math.floor(Math.random() * changeTypes.length)];
  while ((changeType === ChangeType.Delete && elements.every(el => !deletableNodes.has(el.nodeName))) ||
    (changeType === ChangeType.Attribute && elements.every(el => !attributeNodes.has(el.nodeName))) ||
    (changeType === ChangeType.Text && elements.every(el => !nodesWithText.has(el.nodeName)))) {
    changeType = changeTypes[Math.floor(Math.random() * changeTypes.length)];
  }

  switch (changeType) {
    case ChangeType.Insert:
      performInsert(model, elements);
      break;
    case ChangeType.Delete:
      performDeletion(elements);
      break;
    case ChangeType.Attribute:
      performAttributeChange(elements);
      break;
    case ChangeType.Text:
      performTextChange(elements);
      break;
  }
}

const parentNodes = new Set(['model', 'type', 'operation']);
function performInsert(model: yjs.XmlElement, elements: yjs.XmlElement[]): void {
  let parent = elements[Math.floor(Math.random() * elements.length)];
  while (!parentNodes.has(parent.nodeName)) {
    parent = elements[Math.floor(Math.random() * elements.length)];
  }
  switch (parent.nodeName) {
    case 'model':
      if (Math.random() < 0.5) {
        parent.push([createType()]);
      } else {
        parent.push([createRelationship(model)]);
      }
      break;
    case 'type':
      if (Math.random() < 0.5) {
        (parent.get(2) as yjs.XmlElement).push([createAttribute()]);
      } else {
        (parent.get(3) as yjs.XmlElement).push([createOperation()]);
      }
      break;
    case 'operation':
      parent.push([createOperationParameter()]);
      break;
  }
  const element = new yjs.XmlElement('element');
  element.setAttribute('attribute1', 'abcde');
  element.setAttribute('attribute2', 'abcde');
  element.push([new yjs.XmlText('abcde')]);
  parent.push([element]);
}

const deletableNodes = new Set(['type', 'attribute', 'operation', 'param']);
function performDeletion(elements: yjs.XmlElement[]): void {
  let element = elements[Math.floor(Math.random() * elements.length)];
  while (!deletableNodes.has(element.nodeName)) {
    element = elements[Math.floor(Math.random() * elements.length)];
  }
  const parent = element.parent as yjs.XmlElement;
  const index = parent.toArray().indexOf(element);
  parent.delete(index);
}

const attributeNodes = new Set(['type', 'attribute', 'operation', 'param']);
function performAttributeChange(elements: yjs.XmlElement[]): void {
  let element = elements[Math.floor(Math.random() * elements.length)];
  while (!attributeNodes.has(element.nodeName)) {
    element = elements[Math.floor(Math.random() * elements.length)];
  }
  switch (element.nodeName) {
    case 'type':
      let newValue = randomTypeType();
      while (newValue === element.getAttribute('type')) {
        newValue = randomTypeType();
      }
      element.setAttribute('type', newValue);
      break;
    case 'attribute':
      if (Math.random() < 0.5) {
        let newValue = randomVisibility();
        while (newValue === element.getAttribute('visibility')) {
          newValue = randomVisibility();
        }
        element.setAttribute('visibility', newValue);
      } else {
        let newValue = randomDataType();
        while (newValue === element.getAttribute('type')) {
          newValue = randomDataType();
        }
        element.setAttribute('type', newValue);
      }
      break;
    case 'operation':
      if (Math.random() < 0.5) {
        let newValue = randomVisibility();
        while (newValue === element.getAttribute('visibility')) {
          newValue = randomVisibility();
        }
        element.setAttribute('visibility', newValue);
      } else {
        let newValue = randomDataType();
        while (newValue === element.getAttribute('returnType')) {
          newValue = randomDataType();
        }
        element.setAttribute('returnType', newValue);
      }
      break;
    case 'param':
      let newValue2 = randomDataType();
      while (newValue2 === element.getAttribute('type')) {
        newValue2 = randomDataType();
      }
      element.setAttribute('type', newValue2);
      break;
  }
}

const nodesWithText = new Set(['type', 'attribute', 'operation', 'param']);
function performTextChange(elements: yjs.XmlElement[]): void {
  let element = elements[Math.floor(Math.random() * elements.length)];
  while (!nodesWithText.has(element.nodeName)) {
    element = elements[Math.floor(Math.random() * elements.length)];
  }
  const yText = element.get(0) as yjs.XmlText;
  if (Math.random() < 0.67 || !yText.toString().length) {
    yText.insert(Math.floor(Math.random() * (yText.toString().length + 1)), randomLetter());
  } else {
    yText.delete(Math.floor(Math.random() * yText.toString().length), 1);
  }
}

const letters = 'abcdefghijklmnopqrstuvwxyz';
function randomLetter(): string {
  return letters[Math.floor(Math.random() * letters.length)];
}

main()
  .then(() => console.log('Done'))
  .catch(err => console.error(err));

const { bytesToBase64 } = require('./base64');
const parser = require('fast-xml-parser');
const yjs = require('yjs');

function xmlElementToYjsElement(tagName, tagObject) {
  const element = new yjs.XmlElement(tagName);
  for (const [key, value] of Object.entries(tagObject)) {
    if (key.startsWith('_')) {
      element.setAttribute(key.substring(1), value);
    } else if (key === '#text' || typeof value === 'string') {
      element.push([new yjs.XmlText(value)]);
    } else {
      element.push(value.map(v => xmlElementToYjsElement(key, v)));
    }
  }
  return element;
}

function xmlToYjs(xml) {
  const options = {
    arrayMode: true,
    attributeNamePrefix: '_',
    ignoreAttributes: false
  };
  const jsonObject = parser.parse(xml, options);
  const doc = new yjs.Doc();
  const model = jsonObject['model'][0];
  const yjsModel = doc.getXmlFragment('uml');
  if (model.class) {
    yjsModel.push(model.class.map(cls => xmlElementToYjsElement('class', cls)));
  }
  return doc;
}

function addToMapping(element) {
  const id = element.getAttribute('id');
  if (!id || id === '') {
    throw `Element without id: ${element}`;
  }
  mapping.set(id, element);
  element.toArray()
    .filter(element => element instanceof yjs.XmlElement)
    .forEach(element => addToMapping(element));
}

var activeDoc, activeModel, mapping, onUpdateHandler;

// Functions for client

function loadModel(xml) {
  if (activeDoc) {
    activeDoc.off('update', onUpdateHandler);
  }

  activeDoc = xmlToYjs(xml);
  onUpdateHandler = data => {
    sendMessage('DocUpdate', `"${bytesToBase64(data)}"`);
  };
  activeDoc.on('update', onUpdateHandler);
  activeModel = activeDoc.getXmlFragment('uml');
  mapping = new Map();
  activeModel.toArray().forEach(element => addToMapping(element));
}

function insertElement(parentID, id, nodeName, hasNameElement) {
  const element = new yjs.XmlElement(nodeName);
  element.setAttribute('id', id);
  if (hasNameElement) {
    const nameElement = new yjs.XmlElement('name');
    nameElement.push([new yjs.Text()]);
    element.push([nameElement]);
  } else {
    element.push([new yjs.Text()]);
  }
  mapping.set(id, element);
  (parentID ? mapping.get(parentID) : activeModel).push([element]);
}

function deleteElement(id) {
  const element = mapping.get(id);
  element.parent.delete(element.parent.toArray().indexOf(element));
  mapping.delete(id);
}

// TODO: apply delta
function updateText(id, name) {
  const element = mapping.get(id);
  let text = element.get(0);
  if (text instanceof yjs.XmlElement) {
    text = text.get(0);
  }
  activeDoc.transact(() => {
    text.delete(0, text.length);
    text.insert(0, name);
  });
}

function updateAttribute(id, attribute, value) {
  mapping.get(id).setAttribute(attribute, value);
}

module.exports = { xmlToYjs, loadModel, insertElement, deleteElement, updateAttribute, updateText };

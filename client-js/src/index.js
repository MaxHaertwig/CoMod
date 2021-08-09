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
  const model = doc.getXmlFragment('uml');
  model.push(jsonObject['model'][0].class.map(cls => xmlElementToYjsElement('class', cls)));
  return doc;
}

function addToMapping(element) {
  mapping[element.id] = element;
  element.toArray()
    .filter(element => element instanceof yjs.XmlElement)
    .forEach(element => addToMapping(element));
}

var activeModel, mapping;

// Functions for client

function loadModel(xml) {
  const activeDoc = xmlToYjs(xml);
  activeModel = activeDoc.getXmlFragment('uml');
  mapping = new Map();
  activeModel.toArray().forEach(element => addToMapping(element));
}

function updateAttribute(id, attribute, value) {
  mapping[id].setAttribute(attribute, value);
}

function updateTextInsert(id, index, text) {
  mapping[id].get(0).insert(index, text);
}

function updateTextDelete(id, index, length) {
  mapping[id].get(0).delete(index, length);
}

module.exports = { xmlToYjs, loadModel, updateAttribute, updateTextInsert, updateTextDelete };

const { Base64 } = require('js-base64');
const yjs = require('yjs');

function addToMapping(element) {
  const id = element.getAttribute('id');
  if (id) {
    mapping.set(id, element);
    element.toArray()
      .filter(element => element instanceof yjs.XmlElement)
      .forEach(element => addToMapping(element));
  }
}

function serializeModel(yDoc) {
  const doc = yDoc || activeDoc;
  sendMessage('ModelSerialized', JSON.stringify({
    uuid: doc.guid,
    data: Base64.fromUint8Array(yjs.encodeStateAsUpdate(doc))
  }));
}

var activeDoc, activeModel, mapping;

// Functions for client

function newModel(uuid) {
  const yDoc = new yjs.Doc({ guid: uuid });
  const model = new yjs.XmlElement('model');
  model.setAttribute('uuid', uuid);
  yDoc.getXmlFragment().push([model]);
  serializeModel(yDoc);
}

function loadModel(uuid, base64Data) {
  if (activeDoc) {
    activeDoc.destroy();
  }
  activeDoc = new yjs.Doc({ guid: uuid });
  yjs.applyUpdate(activeDoc, Base64.toUint8Array(base64Data));
  activeDoc.on('update', data => {
    sendMessage('DocUpdate', `"${Base64.fromUint8Array(data)}"`);
  });
  activeModel = activeDoc.getXmlFragment().get(0);
  mapping = new Map();
  mapping.set(uuid, activeModel);
  activeModel.toArray().forEach(element => addToMapping(element));
  sendMessage('ModelLoaded', JSON.stringify(activeModel.toJSON()));
}

function insertElement(parentID, id, nodeName, hasNameElement) {
  const element = new yjs.XmlElement(nodeName);
  element.setAttribute('id', id);
  if (hasNameElement) {
    const nameElement = new yjs.XmlElement('name');
    nameElement.push([new yjs.XmlText()]);
    element.push([nameElement]);
  } else {
    element.push([new yjs.XmlText()]);
  }
  mapping.set(id, element);
  mapping.get(parentID).push([element]);
  serializeModel();
}

function deleteElement(id) {
  const element = mapping.get(id);
  element.parent.delete(element.parent.toArray().indexOf(element));
  mapping.delete(id);
  serializeModel();
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
  serializeModel();
}

function updateAttribute(id, attribute, value) {
  mapping.get(id).setAttribute(attribute, value);
  serializeModel();
}

module.exports = { newModel, loadModel, insertElement, deleteElement, updateAttribute, updateText };

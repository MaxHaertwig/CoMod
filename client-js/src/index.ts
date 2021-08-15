import { Base64 } from 'js-base64';
import * as yjs from 'yjs';

declare function sendMessage(channel: string, message: string): void;

function addToMapping(element: yjs.XmlElement) {
  const id = element.getAttribute('id');
  if (id) {
    mapping.set(id, element);
    element.toArray()
      .filter(element => element instanceof yjs.XmlElement)
      .forEach(element => addToMapping(element as yjs.XmlElement));
  }
}

function serializeModel(yDoc?: yjs.Doc) {
  const doc = yDoc || activeDoc;
  sendMessage('ModelSerialized', JSON.stringify({
    uuid: doc.guid,
    data: Base64.fromUint8Array(yjs.encodeStateAsUpdate(doc))
  }));
}

var activeDoc: yjs.Doc;
var activeModel: yjs.XmlElement;
var mapping: Map<string, yjs.XmlElement>;

// Functions for client

function newModel(uuid: string) {
  const yDoc = new yjs.Doc({ guid: uuid });
  const model = new yjs.XmlElement('model');
  model.setAttribute('uuid', uuid);
  yDoc.getXmlFragment().push([model]);
  serializeModel(yDoc);
}

function loadModel(uuid: string, base64Data: string, shouldSerialize: boolean) {
  if (activeDoc) {
    activeDoc.destroy();
  }
  activeDoc = new yjs.Doc({ guid: uuid });
  yjs.applyUpdate(activeDoc, Base64.toUint8Array(base64Data));
  activeDoc.on('update', (data: Uint8Array) => {
    sendMessage('DocUpdate', `"${Base64.fromUint8Array(data)}"`);
  });
  activeModel = activeDoc.getXmlFragment().get(0) as yjs.XmlElement;
  mapping = new Map();
  mapping.set(uuid, activeModel);
  activeModel.toArray().forEach(element => addToMapping(element as yjs.XmlElement));
  if (shouldSerialize) {
    serializeModel();
  }
  sendMessage('ModelLoaded', JSON.stringify(activeModel.toJSON()));
}

function stateVector() {
  return Base64.fromUint8Array(yjs.encodeStateVector(activeDoc));
}

function sync(serverStateVector: string, serverUpdate: string) {
  if (serverUpdate) {
    yjs.applyUpdate(activeDoc, Base64.toUint8Array(serverUpdate));
  }
  const update = yjs.encodeStateAsUpdate(activeDoc, serverStateVector ? Base64.toUint8Array(serverStateVector) : undefined);
  serializeModel();
  return update ? Base64.fromUint8Array(update) : undefined;
}

function processUpdate(data: string) {
  // TODO: report diff to Flutter; yjs observe
  yjs.applyUpdate(activeDoc, Base64.toUint8Array(data));
  serializeModel();
}

function insertElement(parentID: string, id: string, nodeName: string, hasNameElement: boolean, name: string, attributes: Array<Array<string>>) {
  const element = new yjs.XmlElement(nodeName);
  element.setAttribute('id', id);
  if (attributes) {
    for (const [key, value] of attributes) {
      element.setAttribute(key, value);
    }
  }
  if (hasNameElement) {
    const nameElement = new yjs.XmlElement('name');
    nameElement.push([new yjs.XmlText(name)]);
    element.push([nameElement]);
  } else {
    element.push([new yjs.XmlText(name)]);
  }
  mapping.set(id, element);
  mapping.get(parentID)!.push([element]);
  serializeModel();
}

function deleteElement(id: string) {
  const element = mapping.get(id)!;
  const parent = element.parent! as yjs.XmlFragment;
  parent.delete(parent.toArray().indexOf(element));
  mapping.delete(id);
  serializeModel();
}

// TODO: apply delta
function updateText(id: string, name: string) {
  const element = mapping.get(id)!;
  let text = element.get(0);
  if (text instanceof yjs.XmlElement) {
    text = text.get(0);
  }
  activeDoc.transact(() => {
    (text as yjs.XmlText).delete(0, text.length);
    (text as yjs.XmlText).insert(0, name);
  });
  serializeModel();
}

function updateAttribute(id: string, attribute: string, value: string) {
  mapping.get(id)!.setAttribute(attribute, value);
  serializeModel();
}

function startObservation() {
  
}

module.exports = { newModel, loadModel, stateVector, sync, processUpdate, insertElement, deleteElement, updateAttribute, updateText, startObservation };

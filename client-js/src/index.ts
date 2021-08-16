import { Base64 } from 'js-base64';
import * as yjs from 'yjs';

declare function sendMessage(channel: string, message: string): void;

export let activeDoc: yjs.Doc; // exported for testing purposes
let activeModel: yjs.XmlElement;
let mapping: Map<string, yjs.XmlElement>;

export function newModel(uuid: string): void {
  const yDoc = new yjs.Doc({ guid: uuid });
  const model = new yjs.XmlElement('model');
  model.setAttribute('uuid', uuid);
  yDoc.getXmlFragment().push([model]);
  serializeModel(yDoc);
}

export function loadModel(uuid: string, base64Data: string, shouldSerialize: boolean): string {
  if (activeDoc) {
    activeDoc.destroy();
  }

  activeDoc = new yjs.Doc({ guid: uuid });
  yjs.applyUpdate(activeDoc, Base64.toUint8Array(base64Data));
  activeDoc.on('update', (data: Uint8Array, origin: any) => {
    if (origin !== activeDoc) {
      sendMessage('DocUpdate', `"${Base64.fromUint8Array(data)}"`);
    }
  });
  activeModel = activeDoc.getXmlFragment().get(0) as yjs.XmlElement;

  mapping = new Map();
  mapping.set(uuid, activeModel);
  activeModel.toArray().forEach(element => addToMapping(element as yjs.XmlElement));

  if (shouldSerialize) {
    serializeModel();
  }

  return JSON.stringify(activeModel.toJSON());
}

function addToMapping(element: yjs.XmlElement) {
  const id = element.getAttribute('id');
  if (id) {
    mapping.set(id, element);
    element.toArray()
      .filter(element => element instanceof yjs.XmlElement)
      .forEach(element => addToMapping(element as yjs.XmlElement));
  }
}

export function stateVector(): string {
  return Base64.fromUint8Array(yjs.encodeStateVector(activeDoc));
}

export function sync(serverStateVector?: string, serverUpdate?: string): string | undefined {
  if (serverUpdate) {
    yjs.applyUpdate(activeDoc, Base64.toUint8Array(serverUpdate), activeDoc);
    serializeModel();
  }
  const update = yjs.encodeStateAsUpdate(activeDoc, serverStateVector ? Base64.toUint8Array(serverStateVector) : undefined);
  return update ? Base64.fromUint8Array(update) : undefined;
}

export function processUpdate(data: string): void {
  // TODO: report diff to Flutter; yjs observe
  yjs.applyUpdate(activeDoc, Base64.toUint8Array(data), activeDoc);
  serializeModel();
}

export function insertElement(parentID: string, id: string, nodeName: string, hasNameElement: boolean, name: string, attributes: Array<Array<string>>): void {
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

export function deleteElement(id: string): void {
  const element = mapping.get(id)!;
  const parent = element.parent! as yjs.XmlFragment;
  parent.delete(parent.toArray().indexOf(element));
  mapping.delete(id);
  serializeModel();
}

// TODO: apply delta
export function updateText(id: string, name: string): void {
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

export function updateAttribute(id: string, attribute: string, value: string): void {
  mapping.get(id)!.setAttribute(attribute, value);
  serializeModel();
}

function serializeModel(yDoc?: yjs.Doc) {
  const doc = yDoc || activeDoc;
  sendMessage('ModelSerialized', JSON.stringify({
    uuid: doc.guid,
    data: Base64.fromUint8Array(yjs.encodeStateAsUpdate(doc))
  }));
}

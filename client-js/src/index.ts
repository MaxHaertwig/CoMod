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
  activeDoc?.destroy();

  activeDoc = new yjs.Doc({ guid: uuid });
  yjs.applyUpdate(activeDoc, Base64.toUint8Array(base64Data));
  // TODO: don't listen to updates before a collaboration session has been started
  activeDoc.on('update', (data: Uint8Array, origin: any) => {
    if (origin !== activeDoc) {
      sendMessage('LocalUpdate', `"${Base64.fromUint8Array(data)}"`);
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

export function insertElement(parentID: string, id: string, nodeName: string, name: string, attributes?: [string, string][]): void {
  const element = new yjs.XmlElement(nodeName);
  element.setAttribute('id', id);
  if (attributes) {
    for (const [key, value] of attributes) {
      element.setAttribute(key, value);
    }
  }
  element.push([new yjs.XmlText(name)]);

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

let observationFunction: (arg0: yjs.YEvent[], arg1: yjs.Transaction) => void;

export function startObservingRemoteChanges(): void {
  observationFunction = (events, transaction) => {
    if (transaction.local) {
      return;
    }
    // [
    //   [
    //     'id',                                   // ID
    //     [['attr1', 'val1'], ['attr2', 'val2']], // attributes
    //     ['<param>...</param>'],                 // added elements
    //     ['id1']                                 // deleted element IDs  
    //   ]
    // ]
    const elementChanges: [string, [string, string][], string[], string[]][] = [];
    const textChanges: [string, string][] = [];
    for (const event of events) {
      if (event instanceof yjs.YTextEvent) {
        textChanges.push([
          (event.target.parent as yjs.XmlElement).getAttribute('id'),
          (event.target as yjs.XmlText).toString()
        ]);
      } else if (event instanceof yjs.YXmlEvent) {
        const element = event.target as yjs.XmlElement;
        elementChanges.push([
          element.getAttribute(element.nodeName === 'model' ? 'uuid' : 'id'),
          Array.from(event.attributesChanged.values()).map(key => [key, element.getAttribute(key)]),
          Array.from(event.changes.added.values()).map(item => item.content.getContent()[0].toJSON()),
          Array.from(event.changes.deleted.values()).map(item => item.content.getContent()[0]._map.get('id').content.getContent()[0]) // workaround, getAttribute('id') returns undefined, because the type is deleted
        ]);
      }
    }
    sendMessage('RemoteUpdate', JSON.stringify({ text: textChanges, elements: elementChanges }));
  };
  activeModel.observeDeep(observationFunction);
}

export function stopObservingRemoteChanges(): void {
  activeModel.unobserveDeep(observationFunction);
}

function serializeModel(yDoc?: yjs.Doc) {
  const doc = yDoc || activeDoc;
  sendMessage('ModelSerialized', JSON.stringify({
    uuid: doc.guid,
    data: Base64.fromUint8Array(yjs.encodeStateAsUpdate(doc))
  }));
}

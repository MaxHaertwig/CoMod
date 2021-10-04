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
  }
  element.toArray()
    .filter(element => element instanceof yjs.XmlElement)
    .forEach(element => addToMapping(element as yjs.XmlElement));
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

export function insertElement(parentID: string, parentTagIndex: number, id: string, nodeName: string, name: string, attributes?: [string, string][], tags?: string[]): void {
  const element = new yjs.XmlElement(nodeName);
  element.setAttribute('id', id);
  if (attributes) {
    for (const [key, value] of attributes) {
      element.setAttribute(key, value);
    }
  }
  element.push([new yjs.XmlText(name)]);
  if (tags) {
    element.push(tags.map(tag => new yjs.XmlElement(tag)));
  }

  mapping.set(id, element);
  if (parentTagIndex < 0) {
    mapping.get(parentID)!.push([element]);
  } else {
    (mapping.get(parentID)!.get(parentTagIndex) as yjs.XmlElement).push([element]);
  }

  serializeModel();
}

export function deleteElements(ids: string[]): void {
  if (ids.length === 1) {
    deleteElement(ids[0]);
  } else {
    activeDoc.transact(() => ids.forEach(id => deleteElement(id)));
  }
  serializeModel();
}

function deleteElement(id: string) {
  const element = mapping.get(id)!;
  const parent = element.parent! as yjs.XmlFragment;
  parent.delete(parent.toArray().indexOf(element));
  mapping.delete(id);
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

export enum MoveType {
  ToTop = 0, Up, Down, ToBottom
}


export function moveElement(id: string, moveType: MoveType): void {
  const element = mapping.get(id)!;
  const clone = element.clone() as yjs.XmlElement;
  mapping.set(id, clone);
  const parent = element.parent! as yjs.XmlFragment;
  const index = parent.toArray().indexOf(element);
  activeDoc.transact(() => {
    parent.delete(index);
    switch (moveType) {
    case MoveType.ToTop:
      parent.insert(parent.get(0) instanceof yjs.XmlText ? 1 : 0, [clone]);
      break;
    case MoveType.Up:
      parent.insert(Math.max(index - 1, parent.get(0) instanceof yjs.XmlText ? 1 : 0), [clone]);
      break;
    case MoveType.Down:
      parent.insert(index + 1, [clone]);
      break;
    case MoveType.ToBottom:
      parent.push([clone]);
      break;
    }
  });
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
    //     [['<param>...</param>', 2]],            // added elements (xml, index)
    //     ['id1']                                 // deleted element IDs  
    //   ]
    // ]
    const textChanges: [string, string][] = [];
    const elementChanges = new Map<string, [[string, string][], [string, number][], string[]]>();
    for (const event of events) {
      if (event instanceof yjs.YTextEvent) {
        textChanges.push([
          (event.target.parent as yjs.XmlElement).getAttribute('id'),
          (event.target as yjs.XmlText).toString()
        ]);
      } else if (event instanceof yjs.YXmlEvent) {
        const element = event.target as yjs.XmlElement;

        // Remove duplicate elements (as a result of concurrent moves)
        if (event.changes.added.size) {
          const seen = new Set();
          const indicesToDelete: number[] = [];
          for (let i = element.length - 1; i >= 0; i--) {
            const item = element.get(i) as yjs.XmlElement;
            if (item instanceof yjs.XmlElement) {
              const id = item.getAttribute('id');
              if (seen.has(id)) {
                indicesToDelete.push(i);
              } else {
                seen.add(id);
              }
            }
          }
          if (indicesToDelete.length) {
            activeDoc.transact(() => {
              indicesToDelete.forEach(i => element.delete(i));
            });
            serializeModel();
          }
        }

        const addedElements = Array.from(event.changes.added.values()).map(item => item.content.getContent()[0]);
        const deletedElements = Array.from(event.changes.deleted.values()).map(item => item.content.getContent()[0]);

        deletedElements.forEach(e => mapping.delete(e.getAttribute('id')));
        addedElements.forEach(e => mapping.set(e.getAttribute('id'), e));

        const elementArray = element.toArray();
        const firstChildIsText = element.get(0) instanceof yjs.XmlText;
        const id = element.getAttribute(element.nodeName === 'model' ? 'uuid' : 'id') ?? (element.parent as yjs.XmlElement).getAttribute('id');
        if (!elementChanges.has(id)) {
          elementChanges.set(id, [[], [], []]);
        }
        const array = elementChanges.get(id)!;
        array[0].push(...Array.from(event.attributesChanged.values()).map(key => [key, element.getAttribute(key)]) as [string, string][]);
        array[1].push(...addedElements.map(item => {
          const index = elementArray.indexOf(item);
          return [item.toJSON(), firstChildIsText ? index - 1 : index];
        }) as [string, number][]);
        array[2].push(...deletedElements.map(item => item._map.get('id').content.getContent()[0])); // workaround, getAttribute('id') returns undefined, because the type is deleted
      }
    }
    sendMessage('RemoteUpdate', JSON.stringify({
      text: textChanges,
      elements: Array.from(elementChanges.entries()).map(([id, array]) => [id, ...array])
    }));
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

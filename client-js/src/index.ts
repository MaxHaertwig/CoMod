import { Base64 } from 'js-base64';
import * as yjs from 'yjs';

declare function sendMessage(channel: string, message: string): void;

export let activeDoc: yjs.Doc;
let inTransaction = false;
let activeModel: yjs.XmlElement;
let mapping: Map<string, yjs.XmlElement>;

/** Creates a new model. */
export function newModel(uuid: string): void {
  const yDoc = new yjs.Doc({ guid: uuid });
  const model = new yjs.XmlElement('model');
  model.setAttribute('uuid', uuid);
  yDoc.getXmlFragment().push([model]);
  serializeModel(yDoc);
}

/**
 * Loads a model.
 * 
 * @param uuid The model's UUID.
 * @param base64Data The model's serialized data.
 * @param shouldSerialize Whether the model should be serialized after loading.
 * @returns The loaded model as an XML string.
 */
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

/** Returns the current model's state vector. */
export function stateVector(): string {
  return Base64.fromUint8Array(yjs.encodeStateVector(activeDoc));
}

/**
 * Performs the sync procedure.
 * 
 * @param serverStateVector The state vector received from the server.
 * @param serverUpdate The update received from the server.
 * @returns An optional update to be sent to the server.
 */
export function sync(serverStateVector?: string, serverUpdate?: string): string | undefined {
  if (serverUpdate) {
    yjs.applyUpdate(activeDoc, Base64.toUint8Array(serverUpdate), activeDoc);
    serializeModel();
  }
  const update = yjs.encodeStateAsUpdate(activeDoc, serverStateVector ? Base64.toUint8Array(serverStateVector) : undefined);
  return update ? Base64.fromUint8Array(update) : undefined;
}

/** Processes a remote update. */
export function processUpdate(data: string): void {
  yjs.applyUpdate(activeDoc, Base64.toUint8Array(data), activeDoc);
  serializeModel();
}

/** Begins a transaction. */
export function beginTransaction(): void {
  inTransaction = true;
}

/** Ends a transaction. */
export function endTransaction(): void {
  inTransaction = false;
  serializeModel();
}

/**
 * Inserts an element into the model.
 * 
 * @param parentID ID of the parent to insert the element into.
 * @param parentTagIndex If positive, the new element is inserted into the element at that parent's index.
 * @param id ID of the new element.
 * @param nodeName Node name (XML tag name) of the new element.
 * @param name Name (contained text) of the new element.
 * @param attributes Attributes of the new element (optional).
 * @param tags (Empty) XML tags to add to the new element (optional).
 */
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

  if (!inTransaction) {
    serializeModel();
  }
}

/** Deletes the elements with the given IDs from the model. */
export function deleteElements(ids: string[]): void {
  if (ids.length === 1) {
    deleteElement(ids[0]);
  } else if (!inTransaction) {
    activeDoc.transact(() => ids.forEach(id => deleteElement(id)));
  } else {
    ids.forEach(id => deleteElement(id));
  }
  if (!inTransaction) {
    serializeModel();
  }
}

function deleteElement(id: string) {
  const element = mapping.get(id)!;
  const parent = element.parent! as yjs.XmlFragment;
  parent.delete(parent.toArray().indexOf(element));
  mapping.delete(id);
}

/**
 * Updates some text in the model.
 * 
 * @param id ID of the text's parent element.
 * @param position The index within the text.
 * @param deleteLength The number of characters to delete at `position` (to the right).
 * @param insertString The string to insert at `position`.
 */
export function updateText(id: string, position: number, deleteLength: number, insertString: string): void {
  const element = mapping.get(id)!;
  let text = element.get(0);
  if (text instanceof yjs.XmlElement) {
    text = text.get(0);
  }
  if (insertString.length && deleteLength === 0) {
    (text as yjs.XmlText).insert(position, insertString);
  } else if (insertString.length === 0 && deleteLength > 0) {
    (text as yjs.XmlText).delete(position, deleteLength);
  } else if (inTransaction) {
    (text as yjs.XmlText).delete(position, deleteLength);
    (text as yjs.XmlText).insert(position, insertString);
  } else {
    activeDoc.transact(() => {
      (text as yjs.XmlText).delete(position, deleteLength);
      (text as yjs.XmlText).insert(position, insertString);
    });
  }
  if (!inTransaction) {
    serializeModel();
  }
}

/** Updates an attribute in the model. */
export function updateAttribute(id: string, attribute: string, value: string): void {
  mapping.get(id)!.setAttribute(attribute, value);
  if (!inTransaction) {
    serializeModel();
  }
}

/** The type of a move of an element within its parent. */
export enum MoveType {
  ToTop = 0, Up, Down, ToBottom
}

/** Moves an element within its parent. */
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

/** Starts observing remote changes. */
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
    //     [['id1', 'type']]                       // deleted elements (id, tag)
    //   ]
    // ]
    const textChanges: [string, string][] = [];
    const elementChanges = new Map<string, [[string, string][], [string, number][], [string, string][]]>();
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
        const deletedElements = Array.from(event.changes.deleted.values()).map(item => item.content.getContent()[0]); // workaround, getAttribute('id') returns undefined, because the type is deleted

        deletedElements.forEach(el => mapping.delete(el._map.get('id').content.getContent()[0]));
        addedElements.forEach(el => mapping.set(el.getAttribute('id'), el));

        const elementArray = element.toArray();
        const firstChildIsText = element.get(0) instanceof yjs.XmlText;
        const id = element.getAttribute(element.nodeName === 'model' ? 'uuid' : 'id') ?? (element.parent as yjs.XmlElement).getAttribute('id');
        if (!elementChanges.has(id)) {
          elementChanges.set(id, [[], [], []]);
        }
        const array = elementChanges.get(id)!;
        array[0].push(...Array.from(event.attributesChanged.values()).map(key => [key, element.getAttribute(key)] as [string, string]));
        array[1].push(...addedElements.map(el => {
          const index = elementArray.indexOf(el);
          return [el.toJSON(), firstChildIsText ? index - 1 : index];
        }) as [string, number][]);
        array[2].push(...deletedElements.map(el => [el._map.get('id').content.getContent()[0], el.nodeName] as [string, string])); // workaround, getAttribute('id') returns undefined, because the type is deleted
      }
    }
    sendMessage('RemoteUpdate', JSON.stringify({
      text: textChanges,
      elements: Array.from(elementChanges.entries()).map(([id, array]) => [id, ...array])
    }));
  };
  activeModel.observeDeep(observationFunction);
}

/** Stops observing remote changes. */
export function stopObservingRemoteChanges(): void {
  activeModel.unobserveDeep(observationFunction);
}

function serializeModel(yDoc?: yjs.Doc): void {
  const doc = yDoc || activeDoc;
  sendMessage('ModelSerialized', JSON.stringify({
    uuid: doc.guid,
    data: Base64.fromUint8Array(yjs.encodeStateAsUpdate(doc))
  }));
}

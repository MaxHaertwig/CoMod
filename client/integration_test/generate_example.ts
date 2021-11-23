import * as yjs from 'yjs';
import { Base64 } from 'js-base64';

const yDoc = new yjs.Doc();
const model = new yjs.XmlElement('model');
model.setAttribute('uuid', '68bbd3a7-3bc9-4c09-885e-b278446fbd25');
yDoc.getXmlFragment().push([model]);
const typeA = new yjs.XmlElement('type');
typeA.setAttribute('id', '09a0e0fa-05b6-4d75-ad65-4fae4b790de8');
typeA.setAttribute('type', 'class');
const typeName = new yjs.XmlText('TypeA');
typeA.push([typeName, new yjs.XmlElement('supertypes'), new yjs.XmlElement('attributes'), new yjs.XmlElement('operations')]);
model.push([typeA]);

console.log('state');
console.log(Base64.fromUint8Array(yjs.encodeStateAsUpdate(yDoc)));

yDoc.on('update', (update: Uint8Array) => {
  console.log('update');
  console.log(Base64.fromUint8Array(update));
});

typeName.insert('TypeA'.length, 'B');

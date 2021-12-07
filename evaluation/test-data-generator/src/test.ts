import * as fs from 'fs';
import { Base64 } from 'js-base64';
import * as yjs from 'yjs';

const lines = fs
  .readFileSync('../test-data/1w_5000/1w_5000_1.txt', {encoding: 'utf-8'})
  .toString()
  .split('\n');

const yDoc = new yjs.Doc();
yjs.applyUpdate(yDoc, Base64.toUint8Array(lines[0]));

let i = 1;
setInterval(() => {
  yjs.applyUpdate(yDoc, Base64.toUint8Array(lines[i++]));
  console.log(yDoc.getXmlFragment().toString());
}, 1000);

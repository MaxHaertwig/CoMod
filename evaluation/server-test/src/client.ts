import * as fs from 'fs';
import { Base64 } from 'js-base64';
import { exit } from 'process';
import { v4 as uuidv4 } from 'uuid';
import { parentPort, workerData } from 'worker_threads';
import * as yjs from 'yjs';
import { CollaborationRequest } from './pb/collaboration_pb';
import { TestClient } from './test_client';

const {dir, index, clientsPerSession, sessionLength, updateRate, senders} = workerData;
const path = `../../test-data-generator/test-data/${dir}/${dir}_${1 + index}.txt`;
const lines = fs
  .readFileSync(path, {encoding: 'utf-8'})
  .toString()
  .split('\n');
const docData = Base64.toUint8Array(lines[0]);
const messages = lines.slice(1, sessionLength * senders + 1).map(line => {
    const request = new CollaborationRequest();
    request.setUpdate(Base64.toUint8Array(line));
    return request;
  });

async function main() {
  const address = 'ws://34.159.60.232:3000';
  const yDoc = new yjs.Doc();
  yjs.applyUpdate(yDoc, docData);
  const client = new TestClient(address, yDoc);
  let clients = [...Array(clientsPerSession - 1).keys()].map(() => new TestClient(address));

  await Promise.all([client, ...clients].map(client => client.open()));

  const uuid = uuidv4();
  await client.connect(uuid);
  await Promise.all(clients.map(client => client.connect(uuid)));

  clients = [client, ...clients];

  setInterval(() => sendMessage(clients), 1000 / updateRate);
}

let i = 0;
let s = 0;
async function sendMessage(clients: TestClient[]) {
  if (i >= messages.length) {
    return;
  }

  if (senders === 1) {
    clients[0].send(messages[i]);
    i++;
  } else {
    clients.forEach((client, idx) => client.send(messages[i + idx]));
    i += clients.length;
  }
  
  const time = process.hrtime();
  const times: number[] = [];
  if (senders === 1) {
    await Promise.all(clients.slice(1).map(c => c.waitForUpdate(1).then(() => times.push(process.hrtime(time)[1]))));
  } else {
    // TODO: what if senders > 1 and senders < clients?
    await Promise.all(clients.map(c => c.waitForUpdate(clients.length - 1).then(() => times.push(process.hrtime(time)[1]))));
  }
  s += times.reduce((a, b) => a + b, 0) / times.length / 1000000;
  if (i + clients.length >= messages.length) {
    parentPort?.postMessage(s / (i / (senders === 1 ? 1 : clients.length)));
    clients.forEach(c => c.disconnect());
    exit(0);
  }
}

try {
  main();
} catch (error) {
  parentPort?.postMessage(error);
}

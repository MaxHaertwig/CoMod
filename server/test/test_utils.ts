import { v4 as uuidv4 } from 'uuid';
import * as WebSocket from 'ws';
import * as yjs from 'yjs';
import { CollaborationRequest, CollaborationResponse, ConnectRequest, SyncRequest } from '../src/pb/collaboration_pb';
import { TestClient } from './test_client';
import { WSCloseCode } from '../src/ws_close_code';

export const PORT = 3000;
export const TEXT_ID = 'text';

export async function openTestClient(yDoc: yjs.Doc|undefined = undefined): Promise<TestClient> {
  const client = new TestClient(`ws://localhost:${PORT}`, yDoc);
  await client.open();
  return client;
}

export async function testWebSocket(onOpen: (ws: WebSocket) => void, onResponse?: (ws: WebSocket, response: CollaborationResponse) => void): Promise<WSCloseCode> {
  return new Promise(resolve => {
    const ws = new WebSocket(`ws://localhost:${PORT}`);
    ws.on('open', () => onOpen(ws));
    if (onResponse) {
      ws.on('message', (data: Uint8Array) => onResponse(ws, CollaborationResponse.deserializeBinary(data)));
    }
    ws.on('close', resolve);
  });
}

export function createConnectRequest(uuid?: string, yDoc: boolean|yjs.Doc = true): CollaborationRequest {
  const connectRequest = new ConnectRequest();
  connectRequest.setUuid(uuid ?? uuidv4());
  if (yDoc === true || yDoc instanceof yjs.Doc) {
    connectRequest.setStateVector(yjs.encodeStateVector(yDoc === true ? createYDocWithText() : yDoc));
  }
  const request = new CollaborationRequest();
  request.setConnectRequest(connectRequest);
  return request;
}

export function createSyncRequest(): CollaborationRequest {
  const syncRequest = new SyncRequest();
  syncRequest.setUpdate(yjs.encodeStateAsUpdate(createYDocWithText()));
  const request = new CollaborationRequest();
  request.setSyncRequest(syncRequest);
  return request;
}

export function createYDocWithText(text = 'hello'): yjs.Doc {
  const yDoc = new yjs.Doc();
  yDoc.getText(TEXT_ID).insert(0, text);
  return yDoc;
}

export async function yDocUpdate(yDoc: yjs.Doc, transaction: (yDoc: yjs.Doc) => void): Promise<Uint8Array> {
  return new Promise(resolve => {
    yDoc.on('update', (data: Uint8Array) => resolve(data));
    yDoc.transact(() => {
      transaction(yDoc);
    });
  });
}

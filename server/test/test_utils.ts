import { v4 as uuidv4 } from 'uuid';
import * as WebSocket from 'ws';
import * as yjs from 'yjs';
import { CollaborationRequest, ConnectRequest, SyncDocumentRequest } from '../src/pb/collaboration_pb';
import { WSCloseCode } from '../src/ws_close_code';

export const PORT = 3000;

export async function testWebSocket(onOpen: (ws: WebSocket) => void, onMessage?: (ws: WebSocket, data: Uint8Array) => void): Promise<WSCloseCode> {
  return new Promise(resolve => {
    const ws = new WebSocket(`ws://localhost:${PORT}`);
    ws.on('open', () => onOpen(ws));
    if (onMessage) {
      ws.on('message', data => onMessage(ws, data as Uint8Array));
    }
    ws.on('close', resolve);
  });
}

export function createConnectRequest(uuid?: string): CollaborationRequest {
  const connectRequest = new ConnectRequest();
  connectRequest.setUuid(uuid ?? uuidv4())
  connectRequest.setStateVector(yjs.encodeStateVector(createYDocWithText()));
  const request = new CollaborationRequest();
  request.setConnectRequest(connectRequest);
  return request;
}

export function createSyncDocumentRequest(): CollaborationRequest {
  const syncDocumentRequest = new SyncDocumentRequest();
  syncDocumentRequest.setDocumentUpdate(yjs.encodeStateAsUpdate(createYDocWithText()));
  const request = new CollaborationRequest();
  request.setSyncDocumentRequest(syncDocumentRequest);
  return request;
}

export function createYDocWithText(): yjs.Doc {
  const yDoc = new yjs.Doc();
  yDoc.getText('text').insert(0, 'hello');
  return yDoc;
}

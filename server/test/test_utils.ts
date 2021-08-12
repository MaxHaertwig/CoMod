import { CollaborationRequest, ConnectRequest, SyncDocumentRequest } from '../src/pb/collaboration_pb';
import { v4 as uuidv4 } from 'uuid';
import * as yjs from 'yjs';

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

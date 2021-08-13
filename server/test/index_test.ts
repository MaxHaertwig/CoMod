import * as assert from 'assert';
import { describe, it } from 'mocha';
import { v4 as uuidv4 } from 'uuid';
import * as yjs from 'yjs';
import { CollaborationRequest, ConnectRequest, SyncDocumentRequest } from '../src/pb/collaboration_pb';
import { Server } from '../src/server';
import { Session } from '../src/session';
import { WSCloseCode } from '../src/ws_close_code';
import { createConnectRequest, createSyncDocumentRequest, createYDocWithText, openTestClient, PORT, testWebSocket, TEXT_ID, yDocUpdate } from './test_utils';

describe('Server', () => {
  let server: Server;

  beforeEach(done => server = new Server(PORT, done));

  afterEach(done => server.close(done));

  it('closes when receiving a string message', async () => {
    const code = await testWebSocket(ws => {
      ws.send('string message');
    });
    assert.strictEqual(code, WSCloseCode.UnsuportedData);
  });

  describe('protocol', () => {
    describe('handling connecting client', () => {
      it('closes when receiving an invalid ConnectRequest', async () => {
        const code = await testWebSocket(ws => {
          const request = new CollaborationRequest();
          request.setConnectRequest(new ConnectRequest());
          ws.send(request.serializeBinary());
        });
        assert.strictEqual(code, WSCloseCode.UnsuportedData);
      });

      it('closes when receiving SyncDocumentRequest', async () => {
        const code = await testWebSocket(ws => {
          const request = new CollaborationRequest();
          request.setSyncDocumentRequest(new SyncDocumentRequest());
          ws.send(request.serializeBinary());
        });
        assert.strictEqual(code, WSCloseCode.ProtocolError);
      });

      it('closes when receiving document data', async () => {
        const code = await testWebSocket(ws => {
          const request = new CollaborationRequest();
          request.setDocumentUpdate(new Uint8Array());
          ws.send(request.serializeBinary());
        });
        assert.strictEqual(code, WSCloseCode.ProtocolError);
      });
    });

    describe('handling syncing client', () => {
      it('closes when receiving ConnectRequest', async () => {
        const code = await testWebSocket(ws => {
          ws.send(createConnectRequest().serializeBinary());
          const request = new CollaborationRequest();
          request.setConnectRequest(new ConnectRequest());
          ws.send(request.serializeBinary());
        });
        assert.strictEqual(code, WSCloseCode.ProtocolError);
      });

      it('closes when receiving document data', async () => {
        const code = await testWebSocket(ws => {
          ws.send(createConnectRequest().serializeBinary());
          const request = new CollaborationRequest();
          request.setDocumentUpdate(new Uint8Array());
          ws.send(request.serializeBinary());
        });
        assert.strictEqual(code, WSCloseCode.ProtocolError);
      });
    });

    describe('handling connected client', () => {
      it('closes when receiving ConnectRequest', async () => {
        const code = await testWebSocket(ws => {
          ws.send(createConnectRequest().serializeBinary());
          ws.send(createSyncDocumentRequest().serializeBinary());
          const request = new CollaborationRequest();
          request.setConnectRequest(new ConnectRequest());
          ws.send(request.serializeBinary());
        });
        assert.strictEqual(code, WSCloseCode.ProtocolError);
      });

      it('closes when receiving SyncDocumentRequest', async () => {
        const code = await testWebSocket(ws => {
          ws.send(createConnectRequest().serializeBinary());
          ws.send(createSyncDocumentRequest().serializeBinary());
          const request = new CollaborationRequest();
          request.setSyncDocumentRequest(new SyncDocumentRequest());
          ws.send(request.serializeBinary());
        });
        assert.strictEqual(code, WSCloseCode.ProtocolError);
      });
    });
  });

  it('provides data of known documents', async () => {
    const uuid = uuidv4();
    const serverDoc = createYDocWithText();
    server.addSession(uuid, new Session(serverDoc));
    
    await testWebSocket(ws => {
      ws.send(createConnectRequest(uuid, false).serializeBinary());
    }, (ws, response) => {
      assert(response.hasConnectResponse());
      const clientDoc = new yjs.Doc();
      yjs.applyUpdate(clientDoc, response.getConnectResponse()!.getDocumentUpdate_asU8());
      assert.strictEqual(clientDoc.getText(TEXT_ID).toString(), serverDoc.getText(TEXT_ID).toString());
      ws.close();
    });
  });

  it('processes and broadcasts document data', async () => {
    const uuid = uuidv4();
    const suffix = 'world';
    server.addSession(uuid, new Session(createYDocWithText(suffix)));

    const ws1 = await openTestClient();
    await ws1.connect(uuid);

    const ws2 = await openTestClient();
    await ws2.connect(uuid);

    const changedDocPromise = new Promise<yjs.Doc>(resolve => ws2.onYDocChanged(resolve));
    
    const prefix = 'Hello ';
    const update = await yDocUpdate(ws1.yDoc!, yDoc => yDoc.getText(TEXT_ID).insert(0, prefix));

    const request = new CollaborationRequest();
    request.setDocumentUpdate(update);
    ws1.send(request);
    
    const changedDoc = await changedDocPromise;

    assert.strictEqual(changedDoc.getText(TEXT_ID).toString(), prefix + suffix);
    assert.strictEqual(server.session(uuid)!.yDoc.getText(TEXT_ID).toString(), prefix + suffix);
  });
});

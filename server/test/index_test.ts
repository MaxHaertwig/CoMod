import * as assert from 'assert';
import { describe, it } from 'mocha';
import * as WebSocket from 'ws';
import { CollaborationRequest, CollaborationResponse, ConnectRequest, ConnectResponse, SyncDocumentRequest } from '../src/pb/collaboration_pb';
import { Server } from '../src/server';
import { WSCloseCode } from '../src/ws_close_code';
import { createConnectRequest, createSyncDocumentRequest, PORT, testWebSocket } from './test_utils';

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

      it('returns status NOT_FOUND when receiving no state vector for an unknown document', async () => {
        await testWebSocket(ws => {
          const request = new CollaborationRequest();
          request.setConnectRequest(new ConnectRequest());
          ws.send(request.serializeBinary());
        }, (ws, data) => {
          const response = CollaborationResponse.deserializeBinary(data);
          assert(response.hasConnectResponse());
          assert.strictEqual(response.getConnectResponse()!.getStatus(), ConnectResponse.Status.NOT_FOUND);
          ws.close();
        });
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
});

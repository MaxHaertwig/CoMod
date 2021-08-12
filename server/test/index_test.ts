import * as assert from 'assert';
import { describe, it } from 'mocha';
import * as WebSocket from 'ws';
import { CollaborationRequest, ConnectRequest, SyncDocumentRequest } from '../src/pb/collaboration_pb';
import { Server } from '../src/server';
import { WSCloseCode } from '../src/ws_close_code';
import { createConnectRequest, createSyncDocumentRequest } from './test_utils';

const PORT = 3000;

describe('Server', () => {
  let server: Server;

  beforeEach(done => server = new Server(PORT, done));

  afterEach(done => server.close(done));

  it('closes when receiving a string message', done => {
    const ws = new WebSocket(`ws://localhost:${PORT}`);
    ws.on('open', () => {
      ws.send('string message');
    });
    ws.on('close', code => {
      assert.strictEqual(code, WSCloseCode.UnsuportedData);
      done();
    });
  });

  describe('protocol', () => {
    describe('handling connecting client', () => {
      it('closes when receiving SyncDocumentRequest', done => {
        const ws = new WebSocket(`ws://localhost:${PORT}`);
        ws.on('open', () => {
          const request = new CollaborationRequest();
          request.setSyncDocumentRequest(new SyncDocumentRequest());
          ws.send(request.serializeBinary());
        });
        ws.on('close', code => {
          assert.strictEqual(code, WSCloseCode.ProtocolError);
          done();
        });
      });

      it('closes when receiving document data', done => {
        const ws = new WebSocket(`ws://localhost:${PORT}`);
        ws.on('open', () => {
          const request = new CollaborationRequest();
          request.setDocumentUpdate(new Uint8Array());
          ws.send(request.serializeBinary());
        });
        ws.on('close', code => {
          assert.strictEqual(code, WSCloseCode.ProtocolError);
          done();
        });
      });
    });

    describe('handling syncing client', () => {
      it('closes when receiving ConnectRequest', done => {
        const ws = new WebSocket(`ws://localhost:${PORT}`);
        ws.on('open', () => {
          ws.send(createConnectRequest().serializeBinary());
          const request = new CollaborationRequest();
          request.setConnectRequest(new ConnectRequest());
          ws.send(request.serializeBinary());
        });
        ws.on('close', code => {
          assert.strictEqual(code, WSCloseCode.ProtocolError);
          done();
        });
      });

      it('closes when receiving document data', done => {
        const ws = new WebSocket(`ws://localhost:${PORT}`);
        ws.on('open', () => {
          ws.send(createConnectRequest().serializeBinary());
          const request = new CollaborationRequest();
          request.setDocumentUpdate(new Uint8Array());
          ws.send(request.serializeBinary());
        });
        ws.on('close', code => {
          assert.strictEqual(code, WSCloseCode.ProtocolError);
          done();
        });
      });
    });

    describe('handling connected client', () => {
      it('closes when receiving ConnectRequest', done => {
        const ws = new WebSocket(`ws://localhost:${PORT}`);
        ws.on('open', () => {
          ws.send(createConnectRequest().serializeBinary());
          ws.send(createSyncDocumentRequest().serializeBinary());
          const request = new CollaborationRequest();
          request.setConnectRequest(new ConnectRequest());
          ws.send(request.serializeBinary());
        });
        ws.on('close', code => {
          assert.strictEqual(code, WSCloseCode.ProtocolError);
          done();
        });
      });

      it('closes when receiving SyncDocumentRequest', done => {
        const ws = new WebSocket(`ws://localhost:${PORT}`);
        ws.on('open', () => {
          ws.send(createConnectRequest().serializeBinary());
          ws.send(createSyncDocumentRequest().serializeBinary());
          const request = new CollaborationRequest();
          request.setSyncDocumentRequest(new SyncDocumentRequest());
          ws.send(request.serializeBinary());
        });
        ws.on('close', code => {
          assert.strictEqual(code, WSCloseCode.ProtocolError);
          done();
        });
      });
    });
  });
});

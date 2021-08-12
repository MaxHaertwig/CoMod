import * as WebSocket from 'ws';
import { Client } from './client';
import { CollaborationRequest } from './pb/collaboration_pb';
import { SessionManager } from './session_manager';

const server = new WebSocket.Server({ port: process.env.PORT ? +process.env.PORT : 3000 });
const sessionManager = new SessionManager();

server.on('connection', ws => {
  const client = new Client(ws, sessionManager);

  ws.on('message', data => {
    if (!(data instanceof Uint8Array)) {
      ws.close();
      return;
    }

    try {
      client.handleRequest(CollaborationRequest.deserializeBinary(data));
    } catch (error) {
      console.log(`Error handling message: ${error}`);
      ws.close();
    }
  });

  ws.on('close', (code, reason) => {
    console.log(`Closed with code ${code} and reason ${reason}.`);
    client.remove();
  });

  ws.on('error', err => {
    console.log(`WebSocket error: ${err}`);
    client.remove();
  });
});

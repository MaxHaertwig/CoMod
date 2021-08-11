import * as WebSocket from 'ws';
import { CollaborationRequest } from './pb/collaboration_pb';

const server = new WebSocket.Server({ port: +process.env.PORT || 3000 });

server.on('connection', ws => {
  ws.on('message', (data: Uint8Array) => {
    const message = CollaborationRequest.deserializeBinary(data);
    console.log(`Received message: ${message}`);
  });
});

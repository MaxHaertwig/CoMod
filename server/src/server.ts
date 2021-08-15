import * as WebSocket from 'ws';
import { Client } from './client';
import { CollaborationRequest } from './pb/collaboration_pb';
import { Session } from './session';
import { WSCloseCode } from './ws_close_code';

export class Server {
  private sessions = new Map<string, Session>();
  private wss: WebSocket.Server;

  constructor(port?: number, callback: (() => void) | undefined = undefined) {
    this.wss = new WebSocket.Server({ port: port || 3000 }, callback);
    this.wss.on('connection', ws => {
      const client = new Client(ws, this);
      console.log(`New client connected: ${client.shortID}`);

      ws.on('message', data => {
        if (!(data instanceof Uint8Array)) {
          ws.close(WSCloseCode.UnsuportedData);
          return;
        }

        try {
          client.handleRequest(CollaborationRequest.deserializeBinary(data));
        } catch (error) {
          console.log(`Error handling message: ${error}`);
          ws.close();
        }
      });

      ws.on('close', () => {
        client.remove();
        console.log(`Client disconnected: ${client.shortID}`);
      });
      ws.on('error', error => {
        console.log(`WebSocket error: ${error}`);
        client.remove();
        console.log(`Client disconnected: ${client.shortID}`);
      });
    });
  }

  close(callback?: (err?: Error) => void): void {
    this.wss.close(callback);
  }

  session(uuid: string): Session | undefined {
    return this.sessions.get(uuid);
  }

  addSession(session: Session): void {
    this.sessions.set(session.uuid, session);
  }
}

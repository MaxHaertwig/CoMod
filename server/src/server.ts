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

      ws.on('close', () => client.remove());
      ws.on('error', () => client.remove());
    });
  }

  close(callback?: (err?: Error) => void): void {
    this.wss.close(callback);
  }

  session(uuid: string): Session | undefined {
    return this.sessions.get(uuid);
  }

  addSession(uuid: string, session: Session): void {
    this.sessions.set(uuid, session);
  }
}

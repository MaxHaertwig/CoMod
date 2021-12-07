import * as fs from 'fs';
import { Base64 } from 'js-base64';
import * as WebSocket from 'ws';
import { Client } from './client';
import { CollaborationRequest } from './pb/collaboration_pb';
import { Session } from './session';
import { WSCloseCode } from './ws_close_code';

export class MockServer {
  private sessions = new Map<string, Session>();
  private wss: WebSocket.Server;

  constructor(dir: string, updatesPerSecond: number, port?: number, callback: (() => void) | undefined = undefined) {
    const lines = fs
      .readFileSync(`../../test-data-generator/test-data/${dir}/${dir}_1.txt`, {encoding: 'utf-8'})
      .toString()
      .split('\n');
    this.addSession(new Session('9b0fc032-c3d5-4937-8719-9e6bf774255c', Base64.toUint8Array(lines[0])));

    this.wss = new WebSocket.Server({ port: port || 3000 }, callback);
    this.wss.on('connection', ws => {
      const client = new Client(ws, this);
      console.info(`New client connected: ${client.shortID}`);

      ws.on('message', data => {
        if (!(data instanceof Uint8Array)) {
          ws.close(WSCloseCode.UnsuportedData);
          return;
        }

        try {
          if (client.handleRequest(CollaborationRequest.deserializeBinary(data))) {
            setTimeout(() => {
              const messages = lines.slice(1).map(line => {
                const request = new CollaborationRequest();
                request.setUpdate(Base64.toUint8Array(line));
                return request.serializeBinary();
              });
              let i = 0;
              setInterval(() => ws.send(messages[i++]), 1000 / updatesPerSecond);
            }, 5000);
          }
        } catch (error) {
          console.error(`Error handling message: ${error}`);
          ws.close();
        }
      });

      ws.on('close', () => {
        client.remove();
        console.info(`Client disconnected: ${client.shortID}`);
      });
      ws.on('error', error => {
        console.error(`WebSocket error: ${error}`);
        client.remove();
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

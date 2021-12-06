import { v4 as uuidv4 } from 'uuid';
import * as WebSocket from 'ws';
import * as yjs from 'yjs';
import { CollaborationRequest, CollaborationResponse, ConnectRequest, ConnectResponse, SyncRequest, SyncResponse } from './pb/collaboration_pb';
import { Session } from './session';
import { WSCloseCode } from './ws_close_code';

export enum ClientState {
  Connecting = 1,
  Syncing,
  Connected
}

interface SessionManager {
  session(uuid: string): Session | undefined;
  addSession(session: Session): void;
}

/** A client connected to the server. */
export class Client {
  readonly id = uuidv4();

  private state = ClientState.Connecting;
  private ws: WebSocket;
  private sessionManager: SessionManager;
  private sessionUUID?: string;
  private session?: Session;

  constructor(ws: WebSocket, sessionManager: SessionManager) {
    this.ws = ws;
    this.sessionManager = sessionManager;
  }

  get shortID(): string {
    return this.id.split('-')[0];
  }

  /** Sends a response to the client. */
  send(response: CollaborationResponse): void {
    this.ws.send(response.serializeBinary(), error => {
      if (error) {
        console.error(`Sending response ${response} failed with error: ${error}`);
      }
    });
  }

  /** Closes the connection to the client. */
  close(code: WSCloseCode, reason: string): void {
    console.warn(`Client ${this.shortID} closing channel (${code}: ${reason})`);
    this.remove();
    this.ws.close(code, reason);
  }

  /** Removes the client from its session. */
  remove(): void {
    this.session?.removeParticipant(this.id);
  }

  /** Handles an incoming request. */
  handleRequest(request: CollaborationRequest): void {
    switch (this.state) {
    case ClientState.Connecting:
      if (!request.hasConnectRequest()) {
        this.close(WSCloseCode.ProtocolError, 'Connecting client did not receive ConnectRequest.');
        return;
      }
      this.handleConnectRequest(request.getConnectRequest()!);
      break;
    case ClientState.Syncing:
      if (!request.hasSyncRequest()) {
        this.close(WSCloseCode.ProtocolError, 'Syncing client did not receive SyncRequest.');
        return;
      }
      this.handleSyncRequest(request.getSyncRequest()!);
      break;
    case ClientState.Connected:
      if (!request.hasUpdate()) {
        this.close(WSCloseCode.ProtocolError, 'Connected client did not receive model update.');
        return;
      }
      console.info(`Client ${this.shortID} handling update`);
      this.session!.processUpdate(request.getUpdate_asU8(), this.id);
      break;
    }
  }

  private handleConnectRequest(request: ConnectRequest): void {
    console.info(`Client ${this.shortID} handling ConnectRequest`);

    if (!request.getUuid()) {
      this.close(WSCloseCode.UnsuportedData, 'Invalid ConnectRequest: missing uuid.');
      return;
    }

    this.sessionUUID = request.getUuid();
    
    const connectResponse = new ConnectResponse();
    this.session = this.sessionManager.session(request.getUuid());

    if (request.getStateVector_asU8().length) {
      // Client has a version of the model -> syncing
      if (this.session) {
        connectResponse.setStateVector(yjs.encodeStateVector(this.session.yDoc));
        connectResponse.setUpdate(yjs.encodeStateAsUpdate(this.session.yDoc, request.getStateVector_asU8()));
        this.session.addParticipant(this);
      }
      this.state = ClientState.Syncing;
    } else if (this.session) {
      // Client doesn't yet have the model -> connected
      connectResponse.setStateVector(yjs.encodeStateVector(this.session.yDoc));
      connectResponse.setUpdate(yjs.encodeStateAsUpdate(this.session.yDoc));
      this.session.addParticipant(this);
      this.state = ClientState.Connected;
    }

    const response = new CollaborationResponse();
    response.setConnectResponse(connectResponse);
    this.send(response);
  }

  private handleSyncRequest(request: SyncRequest): void {
    console.info(`Client ${this.shortID} handling SyncRequest`);

    if (!this.session && !request.getUpdate_asU8().length) {
      this.close(WSCloseCode.UnsuportedData, 'Received invalid SyncRequest: missing update.');
      return;
    }

    const update = request.getUpdate_asU8();
    if (!this.session) {
      this.session = new Session(this.sessionUUID!, update);
      this.session.addParticipant(this);
      this.sessionManager.addSession(this.session);
    } else if (update.length) {
      this.session.processUpdate(update, this.id);
    }

    const response = new CollaborationResponse();
    response.setSyncResponse(new SyncResponse());
    this.send(response);

    this.state = ClientState.Connected;
  }
}

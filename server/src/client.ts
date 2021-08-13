import { v4 as uuidv4 } from 'uuid';
import * as WebSocket from 'ws';
import * as yjs from 'yjs';
import { CollaborationRequest, CollaborationResponse, ConnectRequest, ConnectResponse, SyncDocumentRequest, SyncDocumentResponse } from './pb/collaboration_pb';
import { Session } from './session';
import { WSCloseCode } from './ws_close_code';

export enum ClientState {
  Connecting = 1,
  Syncing,
  Connected
}

interface SessionManager {
  session(uuid: string): Session | undefined;
  addSession(uuid: string, session: Session): void;
}

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

  send(response: CollaborationResponse): void {
    this.ws.send(response.serializeBinary(), error => {
      if (error) {
        console.log(`Sending response ${response} failed with error: ${error}`);
      }
    });
  }

  close(code: WSCloseCode, reason: string): void {
    this.remove();
    this.ws.close(code, reason);
  }

  remove(): void {
    this.session?.removeParticipant(this.id);
  }

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
      if (!request.hasSyncDocumentRequest()) {
        this.close(WSCloseCode.ProtocolError, 'Syncing client did not receive SyncDocumentRequest.');
        return;
      }
      this.handleSyncDocumentRequest(request.getSyncDocumentRequest()!);
      break;
    case ClientState.Connected:
      if (!request.hasDocumentUpdate()) {
        this.close(WSCloseCode.ProtocolError, 'Connected client did not receive document update.');
        return;
      }
      this.session!.processDocumentUpdate(request.getDocumentUpdate_asU8(), this.id);
      break;
    }
  }

  handleConnectRequest(request: ConnectRequest): void {
    if (!request.getUuid()) {
      this.close(WSCloseCode.UnsuportedData, 'Invalid ConnectRequest: missing uuid.');
      return;
    }

    this.sessionUUID = request.getUuid();
    
    const connectResponse = new ConnectResponse();
    this.session = this.sessionManager.session(request.getUuid());

    if (request.getStateVector_asU8().length) {
      // Client has a version of the document -> syncing
      if (this.session) {
        connectResponse.setStateVector(yjs.encodeStateVector(this.session.yDoc));
        connectResponse.setDocumentUpdate(yjs.encodeStateAsUpdate(this.session.yDoc, request.getStateVector_asU8()));
        this.session.addParticipant(this);
      }
      this.state = ClientState.Syncing;
    } else if (this.session) {
      // Client doesn't yet have the document -> connected
      connectResponse.setStateVector(yjs.encodeStateVector(this.session.yDoc));
      connectResponse.setDocumentUpdate(yjs.encodeStateAsUpdate(this.session.yDoc));
      this.session.addParticipant(this);
      this.state = ClientState.Connected;
    }

    const response = new CollaborationResponse();
    response.setConnectResponse(connectResponse);
    this.send(response);
  }

  handleSyncDocumentRequest(request: SyncDocumentRequest): void {
    if (!this.session && !request.getDocumentUpdate_asU8().length) {
      this.close(WSCloseCode.UnsuportedData, `Received invalid SyncDocumentRequest: ${request}`);
      return;
    }

    if (!this.session) {
      this.session = new Session(request.getDocumentUpdate_asU8());
      this.session.addParticipant(this);
      this.sessionManager.addSession(this.sessionUUID!, this.session);
    } else if (request.getDocumentUpdate_asU8().length) {
      yjs.applyUpdate(this.session.yDoc, request.getDocumentUpdate_asU8());
    }

    const response = new CollaborationResponse();
    response.setSyncDocumentResponse(new SyncDocumentResponse());
    this.send(response);

    this.state = ClientState.Connected;
  }
}

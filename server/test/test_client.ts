import { URL } from 'url';
import * as WebSocket from 'ws';
import * as yjs from 'yjs';
import { CollaborationRequest, CollaborationResponse, ConnectRequest, ConnectResponse, SyncDocumentRequest } from '../src/pb/collaboration_pb';

enum ClientState {
  Connecting = 1,
  Syncing,
  Connected
}

type OnStateChangedListener = (newState: ClientState) => void;
type OnYDocChangedListener = (yDoc: yjs.Doc) => void;

export class TestClient {
  private ws: WebSocket;

  private _state = ClientState.Connecting;
  private set state(newState: ClientState) {
    this._state = newState;
    this.onStateChangedListeners.forEach(l => l(newState));
  }
  private onStateChangedListeners = new Array<OnStateChangedListener>();

  private onYDocChangedListeners = new Array<OnYDocChangedListener>();

  private _yDoc?: yjs.Doc;
  get yDoc(): yjs.Doc|undefined {
    return this._yDoc;
  }

  constructor(address: string | URL, yDoc?: yjs.Doc) {
    this.ws = new WebSocket(address);
    this._yDoc = yDoc;
    this.onResponse(response => {
      switch (this._state) {
      case ClientState.Connecting:
        if (!response.hasConnectResponse()) {
          throw `Invalid response ${response} for state ${this._state}.`;
        }
        this.handleConnectResponse(response.getConnectResponse()!);
        break;
      case ClientState.Syncing:
        if (!response.hasSyncDocumentResponse()) {
          throw `Invalid response ${response} for state ${this._state}.`;
        }
        this.state = ClientState.Connected;
        break;
      case ClientState.Connected:
        if (!response.hasDocumentUpdate()) {
          throw `Invalid response ${response} for state ${this._state}.`;
        }
        yjs.applyUpdate(this._yDoc!, response.getDocumentUpdate_asU8());
        this.onYDocChangedListeners.forEach(l => l(this._yDoc!));
        break;
      }
    });
  }

  private handleConnectResponse(response: ConnectResponse): void {
    if (this._yDoc) {
      yjs.applyUpdate(this._yDoc, response.getDocumentUpdate_asU8());
      this.state = ClientState.Syncing;

      const syncDocumentRequest = new SyncDocumentRequest();
      syncDocumentRequest.setDocumentUpdate(yjs.encodeStateAsUpdate(this._yDoc, response.getStateVector_asU8()));
      const request = new CollaborationRequest();
      request.setSyncDocumentRequest(syncDocumentRequest);
      this.send(request);
    } else if (response.getDocumentUpdate_asU8().length) {
      this._yDoc = new yjs.Doc();
      yjs.applyUpdate(this._yDoc!, response.getDocumentUpdate_asU8());
      this.state = ClientState.Connected;
    }
  }

  async open(): Promise<void> {
    return new Promise(resolve => {
      this.ws.on('open', () => resolve());
    });
  }

  close(): void {
    this.ws.close();
  }

  onResponse(callback: (response: CollaborationResponse) => void): void {
    this.ws.on('message', data => {
      callback(CollaborationResponse.deserializeBinary(data as Uint8Array));
    });
  }

  async send(request: CollaborationRequest): Promise<void> {
    return new Promise((resolve, reject) => {
      this.ws.send(request.serializeBinary(), error => {
        if (error) {
          reject(error);
        } else {
          resolve();
        }
      });
    });
  }

  async connect(uuid: string): Promise<void> {
    const connectRequest = new ConnectRequest();
    connectRequest.setUuid(uuid);
    if (this.yDoc) {
      connectRequest.setStateVector(yjs.encodeStateVector(this.yDoc));
    }
    const request = new CollaborationRequest();
    request.setConnectRequest(connectRequest);
    await this.send(request);
    return new Promise(resolve => {
      this.onStateChanged(newState => {
        if (newState === ClientState.Connected) {
          resolve();
        }
      });
    });
  }

  onStateChanged(listener: OnStateChangedListener): void {
    this.onStateChangedListeners.push(listener);
  }

  onYDocChanged(listener: OnYDocChangedListener): void {
    this.onYDocChangedListeners.push(listener);
  }
}

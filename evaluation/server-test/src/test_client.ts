import { URL } from 'url';
import * as WebSocket from 'ws';
import * as yjs from 'yjs';
import { CollaborationRequest, CollaborationResponse, ConnectRequest, ConnectResponse, SyncRequest } from './pb/collaboration_pb';

enum ClientState {
  Connecting = 1,
  Syncing,
  Connected
}

type OnStateChangedListener = (newState: ClientState) => void;
type OnYDocChangedListener = (yDoc: yjs.Doc) => void;

/** Testing client that understands the communication protocol. */
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
    this.ws.setMaxListeners(0);
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
        if (!response.hasSyncResponse()) {
          throw `Invalid response ${response} for state ${this._state}.`;
        }
        this.state = ClientState.Connected;
        break;
      case ClientState.Connected:
        if (!response.hasUpdate()) {
          throw `Invalid response ${response} for state ${this._state}.`;
        }
        yjs.applyUpdate(this._yDoc!, response.getUpdate_asU8());
        this.onYDocChangedListeners.forEach(l => l(this._yDoc!));
        break;
      }
    });
    this.ws.on('error', (err: Error) => {
      console.log('ws error');
      console.log(err);
    });
  }

  private handleConnectResponse(response: ConnectResponse): void {
    const update = response.getUpdate_asU8();
    if (this._yDoc) {
      if (update.length) {
        yjs.applyUpdate(this._yDoc, update);
      }
      this.state = ClientState.Syncing;

      const syncRequest = new SyncRequest();
      const stateVector = response.getStateVector_asU8();
      const data = yjs.encodeStateAsUpdate(this._yDoc, stateVector.length ? stateVector : undefined);
      syncRequest.setUpdate(data);
      const request = new CollaborationRequest();
      request.setSyncRequest(syncRequest);
      this.send(request);
    } else if (update.length) {
      this._yDoc = new yjs.Doc();
      yjs.applyUpdate(this._yDoc!, update);
      this.state = ClientState.Connected;
    }
  }

  /** Opens a WebSocket connection. Returns a promise that resolves when the channel has been opened. */
  async open(): Promise<void> {
    return new Promise(resolve => {
      this.ws.on('open', () => resolve());
    });
  }

  /** Closes the WebSocket connection. */
  close(): void {
    this.ws.close();
  }

  /** Calls `callback` when receiving a message. */
  onResponse(callback: (response: CollaborationResponse) => void): void {
    this.ws.on('message', data => {
      callback(CollaborationResponse.deserializeBinary(data as Uint8Array));
    });
  }

  /** Sends the given request. */
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

  /** Connects to the session with the given UUID. */
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

  /** Calls `listener` whenever the client's state changes. */
  onStateChanged(listener: OnStateChangedListener): void {
    this.onStateChangedListeners.push(listener);
  }

  /** Calls `listener` whenever the client's yjs document changes. */
  onYDocChanged(listener: OnYDocChangedListener): void {
    this.onYDocChangedListeners.push(listener);
  }

  async waitForUpdate(count: number): Promise<void> {
    return new Promise(resolve => {
      let i = 0;
      const listener = (data: WebSocket.RawData) => {
        if (CollaborationResponse.deserializeBinary(data as Uint8Array).hasUpdate()) {
          i++;
          if (i === count) {
            this.ws.removeAllListeners();
            resolve();
          }
        }
      };
      this.ws.on('message', listener);
    });
  }

  disconnect(): void {
    this.ws.close();
  }
}

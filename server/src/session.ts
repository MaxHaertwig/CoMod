import * as yjs from 'yjs';
import { Client } from './client';
import { CollaborationResponse } from './pb/collaboration_pb';

/** An in-progress collaboration session. */
export class Session {
  /** Unique identifier. Equal to `yDoc`'s guid. */
  readonly uuid: string;
  /** Yjs document holding the data model. */
  readonly yDoc: yjs.Doc;

  private participants = new Map<string, Client>();

  /**
   * Initializes a new `Session`.
   * 
   * @param uuid The session's UUID. Will be used as the `document`'s guid.
   * @param document Yjs document or the data to initialize one.
   */
  constructor(uuid: string, document: yjs.Doc|Uint8Array) {
    this.uuid = uuid;
    console.log(`New session ${this.shortUUID}`);

    if (document instanceof yjs.Doc) {
      this.yDoc = document;
    } else {
      this.yDoc = new yjs.Doc({ guid: uuid });
      yjs.applyUpdate(this.yDoc, document);
    }
  }

  get shortUUID(): string {
    return this.uuid.split('-')[0];
  }

  /** Adds a participant to the session. */
  addParticipant(client: Client): void {
    console.log(`Adding client ${client.shortID} to session ${this.shortUUID}`);
    this.participants.set(client.id, client);
  }

  /** Removes a participant from the session. */
  removeParticipant(id: string): void {
    console.log(`Removing client ${id.split('-')[0]} from session ${this.shortUUID}`);
    this.participants.delete(id);
  }

  /** Processes an update and forwards it to all other participants of the session. */
  processUpdate(update: Uint8Array, fromParticipantID: string): void {
    console.log(`Processing update for session ${this.shortUUID}`);
    yjs.applyUpdate(this.yDoc, update);
    const response = new CollaborationResponse();
    response.setUpdate(update);
    this.broadcast(response, fromParticipantID);
  }

  private broadcast(response: CollaborationResponse, excludeID: string): void {
    this.participants.forEach((participant, id) => {
      if (id !== excludeID) {
        participant.send(response);
      }
    });
  }
}

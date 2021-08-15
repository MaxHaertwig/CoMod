import * as yjs from 'yjs';
import { Client } from './client';
import { CollaborationResponse } from './pb/collaboration_pb';

export class Session {
  readonly uuid: string;
  readonly yDoc: yjs.Doc;

  private participants = new Map<string, Client>();

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

  addParticipant(client: Client): void {
    console.log(`Adding client ${client.shortID} to session ${this.shortUUID}`);
    this.participants.set(client.id, client);
  }

  removeParticipant(id: string): void {
    console.log(`Removing client ${id.split('-')[0]} from session ${this.shortUUID}`);
    this.participants.delete(id);
  }

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

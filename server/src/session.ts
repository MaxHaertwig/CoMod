import * as yjs from 'yjs';
import { Client } from './client';
import { CollaborationResponse } from './pb/collaboration_pb';

export class Session {
  readonly yDoc: yjs.Doc;

  private participants = new Map<string, Client>();

  constructor(document: yjs.Doc|Uint8Array) {
    if (document instanceof yjs.Doc) {
      this.yDoc = document;
    } else {
      this.yDoc = new yjs.Doc();
      yjs.applyUpdate(this.yDoc, document);
    }
  }

  addParticipant(client: Client): void {
    this.participants.set(client.id, client);
  }

  removeParticipant(id: string): void {
    this.participants.delete(id);
  }

  processUpdate(update: Uint8Array, fromParticipantID: string): void {
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

import * as yjs from 'yjs';
import { Client } from './client';
import { CollaborationResponse } from './pb/collaboration_pb';

export class Session {
  readonly doc: yjs.Doc;

  private participants = new Map<string, Client>();

  constructor(documentData: Uint8Array) {
    this.doc = new yjs.Doc();
    yjs.applyUpdate(this.doc, documentData);
  }

  addParticipant(client: Client): void {
    this.participants.set(client.id, client);
  }

  removeParticipant(id: string): void {
    this.participants.delete(id);
  }

  broadcast(response: CollaborationResponse, excludeID: string): void {
    this.participants.forEach((participant, id) => {
      if (id !== excludeID) {
        participant.send(response);
      }
    });
  }
}

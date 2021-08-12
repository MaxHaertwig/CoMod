import { Session } from './session';

export class SessionManager {
  private sessions = new Map<string, Session>();

  session(uuid: string): Session | undefined {
    return this.sessions.get(uuid);
  }

  addSession(uuid: string, session: Session): void {
    this.sessions.set(uuid, session);
  }
}

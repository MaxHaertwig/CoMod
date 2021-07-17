import * as Koa from 'koa';
import * as websockify from 'koa-websocket';
import {CollaborationMessage} from './pb/collaboration_pb';

const wsOptions = {};
const app = websockify(new Koa(), wsOptions);

app.ws.use(ctx => {
  ctx.websocket.binaryType = 'arraybuffer';
  ctx.websocket.on('message', (buffer: Buffer) => {
    const message = CollaborationMessage.deserializeBinary(buffer);
    console.log(`Received message: ${message.getMessage()}`);
  });
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`Running on port ${port}.`);
});

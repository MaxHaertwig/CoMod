import * as Koa from 'koa';
import * as websockify from 'koa-websocket';
import { CollaborationRequest } from './pb/collaboration_pb';

const wsOptions = {};
const app = websockify(new Koa(), wsOptions);

app.ws.use(ctx => {
  ctx.websocket.binaryType = 'arraybuffer';
  ctx.websocket.on('message', (buffer: Buffer) => {
    const message = CollaborationRequest.deserializeBinary(buffer);
    console.log(`Received message: ${message}`);
  });
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`Running on port ${port}.`);
});

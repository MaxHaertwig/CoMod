import * as Koa from 'koa';
import * as websockify from 'koa-websocket';

const app = websockify(new Koa());

app.ws.use(ctx => {
  ctx.websocket.on('message', msg => {
    console.log(`Received message: ${msg}`);
  });
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`Running on port ${port}.`);
});

import { Server } from './server';

const port = process.env.PORT ? +process.env.PORT : 3000;
console.log(`Starting server on port ${port}...`);
new Server(port, () => console.log('Server is up'));

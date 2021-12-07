import { MockServer } from './server';

if (process.argv.length < 4) {
    console.log('Invalid args')
    process.exit(0);
}

const port = process.env.PORT ? +process.env.PORT : 3000;
console.log(`Starting server on port ${port}...`);
new MockServer(process.argv[2], parseInt(process.argv[3]), port, () => console.log('Server is up'));

import { exit } from 'process';
import { Worker } from 'worker_threads';

const dir = process.argv[2];
const sessions = parseInt(process.argv[3]);
const clientsPerSession = parseInt(process.argv[4]);
const sessionLength = parseInt(process.argv[5]);
const updateRate = parseInt(process.argv[6]);

let measure = false;

async function main(): Promise<void> {
  console.log('Setting up...')
  for (let i = 0; i < sessions; i++) {
    simulateSession(i % 5, i);
    await sleep(1000 * sessionLength / sessions / updateRate);
    if ((i + 1) % 10 === 0) {
      console.log(i + 1 + ' sessions');
    }
  }
  measure = true;
  console.log('Measuring...')
}

let time = 0;
let completedSessions = 0;

async function simulateSession(index: number, first: number): Promise<void> {
  await sleep(Math.random() * 1000);
  return new Promise((resolve, reject) => {
    const worker = new Worker('./client.js', {workerData: {first, dir, index, clientsPerSession, sessionLength, updateRate, senders: dir.startsWith('1w') ? 1 : clientsPerSession}});
    worker.on('message', ms => {
      if (!measure) {
        return;
      }
      time += ms;
      completedSessions++;
      if (completedSessions % 10 === 0) {
        console.log(completedSessions + ' sessions');
      }
      if (completedSessions % sessions === 0) {
        console.log(Math.round(time / sessions * 100) / 100 + 'ms');
        exit(0);
      }
    });
    worker.on('error', reject);
    worker.on('exit', code => {
      if (code === 0) {
        resolve(1);
      } else {
        reject(new Error(`Worker stopped with exit code ${code}`));
      }
    });
  }).then(() => simulateSession(index, first));
}

function sleep(ms: number): Promise<void> {
  return new Promise(resolve => {
    setTimeout(resolve, ms);
  });
}

try {
  main();
} catch (error) {
  console.log('error');
  console.error(error);
}

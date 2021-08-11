# Server

This is the app's server backend. It is based on the [ws](https://github.com/websockets/ws) package, written in [TypeScript](https://www.typescriptlang.org), and uses the _WebSocket_ protocol to communicate.

## Setup

```bash
npm install
```

## Run locally

Requires [Node.js](https://nodejs.dev) to be installed.

```bash
npm start
```

## Run with Docker

```bash
docker build -t server .
docker run -d -p 3000:3000 server
```

## Lint

This project makes use of [ESLint](https://eslint.org).

```bash
npm run lint
```

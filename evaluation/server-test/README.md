# Server Test

This directory contains the means to test the server's latency, i.e. the average time it takes for all clients of a session to receive updates.

Set up with `npm install`.

Compile using the `tsc` command.

Run as `node dist/index.js d s c l u` where

- `d` is the name of the directory containing the test files
- `s` is the number of concurrent sessions to simulate
- `c` is the number of clients per session
- `l` is the number of iterations to simulate per session
- `u` is the rate of updates to send per second (per client)

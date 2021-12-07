# Test Data Generator

This directory contains the means to generate test files containing updates to send to the server.

Set up with `npm install`.

Run as `ts-node src/index.ts x y z` where

- `x` is the name of the file to generate
- `y` is the number of iterations to simulate (i.e. concurrent edits from clients)
- `z` is the number of clients to simulate

E.g. `1000 5` will simulate 1000 steps with 5 clients resulting in 5000 updates.

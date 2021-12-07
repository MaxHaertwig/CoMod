# Client Test

Contains a mock server implementation that can be used to test the client application (how many requests per second it is able to process).

Set up with `npm install`.

Compile using the `tsc` command.

Run as `node dist/index.js x y` where

- `x` is the name of the directory containing the test file(s)
- `y` is the number of updates sent per second (spread evenly)

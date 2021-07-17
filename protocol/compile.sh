#!/bin/bash

protoc \
  --plugin="protoc-gen-ts=./node_modules/.bin/protoc-gen-ts" \
  --dart_out="../client/lib/pb" \
  --js_out=import_style=commonjs,binary:"../server/src/pb" \
  --ts_out="../server/src/pb" \
  collaboration.proto

#!/bin/bash

# Client

if ! command -v flutter &> /dev/null
then
  echo "Please install Flutter: https://flutter.dev/docs/get-started/install"
  exit
fi

echo "Setting up client..."

# Client-JS

if ! command -v node &> /dev/null
then
  echo "Please install Node.js: https://nodejs.dev"
  exit
fi

echo "Setting up client-js..."
cd client-js
npm install 1> /dev/null
cd ..

# Protocol

if ! command -v protoc &> /dev/null
then
  echo "Please install protoc: https://github.com/protocolbuffers/protobuf"
  exit
fi

echo "Setting up protocol..."
cd protocol
npm install 1> /dev/null
source compile.sh
cd ..

# Server

echo "Setting up server..."
cd server
npm install 1> /dev/null
cd ..

echo "Done"

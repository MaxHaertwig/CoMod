#!/bin/bash

cd ../server
npm start &
NODE_PID=$!
cd -

COLLABORATION_UUID="2c8932f2-7ac2-4e6d-abee-2b09b407fc46"

cd ../client
flutter test integration_test/e2e_test.dart \
    --name client1 \
    --dart-define="collaboration_uuid=$COLLABORATION_UUID" \
    -d iphone
flutter test integration_test/e2e_test.dart \
    --name client2 \
    --dart-define="collaboration_uuid=$COLLABORATION_UUID" \
    -d iphone \
    --no-pub

kill "$NODE_PID"

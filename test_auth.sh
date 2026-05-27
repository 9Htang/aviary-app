#!/bin/bash
echo '{"pin":"1234","deviceId":"test"}' | curl -s -X POST http://localhost:8080/auth/connect -H 'Content-Type: application/json' -d @-

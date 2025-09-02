#!/bin/bash
set -euo pipefail

ENDPOINT="${ENDPOINT:-https://localhost:22200/pun/sys/loop}"
OOD_USERNAME="${OOD_USERNAME:-ood}"
OOD_PASSWORD="${OOD_PASSWORD:-ood}"
MAX_RETRIES="${MAX_RETRIES:-20}"
SLEEP_SECS="${SLEEP_SECS:-25}"

echo "Trying: ${ENDPOINT} with username: ${OOD_USERNAME}"

docker ps

for i in {1..10}; do
  if curl -sk -u "ood:ood" https://localhost:22200/pun/sys/loop > /dev/null; then
    echo "✅ Service is up"
    break
  fi
  echo "⏳ Waiting for service (attempt $i)..."
  sleep 5
done

docker exec test_loop_ood cat /var/log/ondemand-nginx/ood/error.log

for ((i=1; i<=MAX_RETRIES; i++)); do
  STATUS_RECEIVED=$(curl -k -s -o /dev/null -L -w '%{http_code}' \
    -u "${OOD_USERNAME}:${OOD_PASSWORD}" "${ENDPOINT}")

  if [ "${STATUS_RECEIVED}" = "200" ]; then
    echo "OnDemand Loop up and running..."
    exit 0
  fi

  printf '[%s] Attempt %d/%d - Response: %s\n' \
    "$(date '+%H:%M:%S')" "$i" "$MAX_RETRIES" "$STATUS_RECEIVED"

  sleep "${SLEEP_SECS}"
done

echo "OnDemand Loop not running after ${MAX_RETRIES} attempts..."
exit 1

#!/usr/bin/env bash
set -euo pipefail

CONNECT_URL="${CONNECT_URL:-http://localhost:8083}"

require() { command -v "$1" >/dev/null 2>&1 || { echo "Missing dependency: $1"; exit 1; }; }
require curl
require jq

wait_for_connect() {
  local tries=60
  while (( tries-- > 0 )); do
    if curl -fsS "${CONNECT_URL}/" >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done
  echo "Kafka Connect not ready at ${CONNECT_URL}"
  exit 1
}

curl_json() {
  local method="$1"
  local url="$2"
  local data="${3:-}"
  if [[ -n "${data}" ]]; then
    curl -sS -w "\nHTTP_STATUS:%{http_code}\n" -X "${method}" \
      -H "Content-Type: application/json" \
      --data "${data}" \
      "${url}"
  else
    curl -sS -w "\nHTTP_STATUS:%{http_code}\n" -X "${method}" \
      "${url}"
  fi
}

http_status() { sed -n 's/^HTTP_STATUS://p' <<<"$1" | tail -n 1; }
http_body() { sed '/^HTTP_STATUS:/d' <<<"$1"; }

upsert_connector() {
  local file="$1"
  local name config
  name="$(jq -r '.name' "$file")"
  config="$(jq -c '.config' "$file")"

  # Check existence reliably
  local resp status
  resp="$(curl_json GET "${CONNECT_URL}/connectors/${name}")"
  status="$(http_status "$resp")"

  if [[ "$status" == "200" ]]; then
    echo "Updating: ${name}"
    resp="$(curl_json PUT "${CONNECT_URL}/connectors/${name}/config" "${config}")"
    status="$(http_status "$resp")"
    if [[ "$status" != "200" ]]; then
      echo "Update failed (${status}):"
      http_body "$resp"
      exit 1
    fi
  elif [[ "$status" == "404" ]]; then
    echo "Creating: ${name}"
    resp="$(curl_json POST "${CONNECT_URL}/connectors" "$(jq -c '.' "$file")")"
    status="$(http_status "$resp")"
    if [[ "$status" != "201" ]]; then
      echo "Create failed (${status}):"
      http_body "$resp"
      exit 1
    fi
  else
    echo "Unexpected status checking ${name} (${status}):"
    http_body "$resp"
    exit 1
  fi
}

wait_for_connect

upsert_connector "connectors/mysql-source.json"
upsert_connector "connectors/postgres-sink.json"

echo
echo "Connectors:"
curl -fsS "${CONNECT_URL}/connectors" | jq -r '.[]'

echo
echo "Statuses:"
for c in $(curl -fsS "${CONNECT_URL}/connectors" | jq -r '.[]'); do
  echo "- ${c}"
  curl -fsS "${CONNECT_URL}/connectors/${c}/status" | jq '{name, connector: .connector.state, tasks: [.tasks[].state]}'
done

echo
echo "Kafka UI: http://localhost:8080"
echo "Connect REST: ${CONNECT_URL}"

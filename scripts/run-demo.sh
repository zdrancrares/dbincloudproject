#!/usr/bin/env bash
set -euo pipefail

docker exec -i mysql mysql -uroot -prootpw tennis < scripts/demo-mysql.sql
echo "Done. Check Kafka UI topics/messages and Postgres."

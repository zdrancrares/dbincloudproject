#!/usr/bin/env bash
set -euo pipefail

docker exec -i mysql mysql -uroot -prootpw tennis < scripts/demo-mysql.sql
echo "Done. You can check Kafka UI topics/messages and postgres."

#!/usr/bin/env bash
set -euo pipefail

docker exec -it postgres psql -U postgres -d postgres -c "SELECT * FROM tennis.players ORDER BY player_id;"

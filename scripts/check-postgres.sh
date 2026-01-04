#!/usr/bin/env bash
set -euo pipefail

psql_cmd() {
  docker exec -i postgres psql -U postgres -d postgres -v ON_ERROR_STOP=1 -t -A -c "$1"
}

echo "--- tables in schema tennis ---"
docker exec -i postgres psql -U postgres -d postgres -c "\dt tennis.*"

echo "--- row counts ---"
psql_cmd "SELECT 'players' AS table, COUNT(*) FROM tennis.players;"               | awk -F'|' '{print $1 ": " $2}'
psql_cmd "SELECT 'tournaments' AS table, COUNT(*) FROM tennis.tournaments;"       | awk -F'|' '{print $1 ": " $2}'
psql_cmd "SELECT 'matches' AS table, COUNT(*) FROM tennis.matches;"               | awk -F'|' '{print $1 ": " $2}'
psql_cmd "SELECT 'match_results' AS table, COUNT(*) FROM tennis.match_results;"   | awk -F'|' '{print $1 ": " $2}'
psql_cmd "SELECT 'player_rankings' AS table, COUNT(*) FROM tennis.player_rankings;" | awk -F'|' '{print $1 ": " $2}'

echo "--- players ---"
docker exec -i postgres psql -U postgres -d postgres -c "SELECT * FROM tennis.players ORDER BY player_id;"

echo "--- tournaments ---"
docker exec -i postgres psql -U postgres -d postgres -c "SELECT * FROM tennis.tournaments ORDER BY tournament_id;"

echo "--- matches ---"
docker exec -i postgres psql -U postgres -d postgres -c "SELECT * FROM tennis.matches ORDER BY match_id;"

echo "--- match_results ---"
docker exec -i postgres psql -U postgres -d postgres -c "SELECT * FROM tennis.match_results ORDER BY result_id;"

echo "--- player_rankings ---"
docker exec -i postgres psql -U postgres -d postgres -c "SELECT * FROM tennis.player_rankings ORDER BY ranking_id;"

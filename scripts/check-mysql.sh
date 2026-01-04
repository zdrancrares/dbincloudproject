#!/usr/bin/env bash
set -euo pipefail

mysql_cmd() {
  docker exec -i mysql mysql -uroot -prootpw -D tennis -N -s -e "$1"
}

echo "--- tables in database tennis ---"
docker exec -i mysql mysql -uroot -prootpw -D tennis -e "SHOW TABLES;"

echo "--- row counts ---"
mysql_cmd "SELECT 'players' AS table_name, COUNT(*) FROM players;"          | awk '{print $1 ": " $2}'
mysql_cmd "SELECT 'tournaments' AS table_name, COUNT(*) FROM tournaments;"  | awk '{print $1 ": " $2}'
mysql_cmd "SELECT 'matches' AS table_name, COUNT(*) FROM matches;"          | awk '{print $1 ": " $2}'
mysql_cmd "SELECT 'match_results' AS table_name, COUNT(*) FROM match_results;" | awk '{print $1 ": " $2}'
mysql_cmd "SELECT 'player_rankings' AS table_name, COUNT(*) FROM player_rankings;" | awk '{print $1 ": " $2}'

echo "--- players ---"
docker exec -i mysql mysql -uroot -prootpw -D tennis -e "SELECT * FROM players ORDER BY player_id;"

echo "--- tournaments ---"
docker exec -i mysql mysql -uroot -prootpw -D tennis -e "SELECT * FROM tournaments ORDER BY tournament_id;"

echo "--- matches ---"
docker exec -i mysql mysql -uroot -prootpw -D tennis -e "SELECT * FROM matches ORDER BY match_id;"

echo "--- match_results ---"
docker exec -i mysql mysql -uroot -prootpw -D tennis -e "SELECT * FROM match_results ORDER BY result_id;"

echo "--- player_rankings ---"
docker exec -i mysql mysql -uroot -prootpw -D tennis -e "SELECT * FROM player_rankings ORDER BY ranking_id;"

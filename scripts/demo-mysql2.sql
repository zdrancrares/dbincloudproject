-- insert
INSERT INTO players (player_id, name, country, birth_date, turned_pro_date) VALUES
(6, 'Jannik Sinner', 'ITA', '2001-08-16', '2018-01-01');

-- updates
UPDATE tournaments SET location = 'Melbourne, AUS' WHERE tournament_id = 10;
UPDATE matches SET match_duration_minutes = COALESCE(match_duration_minutes, 0) + 15 WHERE match_id = 100;

-- deletes
DELETE FROM match_results WHERE player1_id = 3 OR player2_id = 3 OR winner_id = 3;
DELETE FROM player_rankings WHERE player_id = 3;
DELETE FROM players WHERE player_id = 3;

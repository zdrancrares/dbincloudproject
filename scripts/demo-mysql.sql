-- insert
INSERT INTO players (player_id, name, country, birth_date, turned_pro_date)
VALUES (5, 'Carlos Alcaraz', 'ESP', '2003-05-05', '2018-01-01');

-- update
UPDATE players SET name='Carlos Alcaraz Garfia' WHERE player_id=5;
UPDATE tournaments SET prize_money = 80000000.0 WHERE tournament_id = 10;

-- delete
DELETE FROM match_results WHERE player2_id=2 OR player1_id=2 OR winner_id=2;
DELETE FROM player_rankings WHERE player_id=2;
DELETE FROM players WHERE player_id=2;

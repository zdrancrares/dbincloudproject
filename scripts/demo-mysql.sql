-- scripts/demo-mysql.sql

-- insert
INSERT INTO players (player_id, name, country, birth_date, turned_pro_date)
VALUES (3, 'Carlos Alcaraz', 'ESP', '2003-05-05', '2018-01-01')
    ON DUPLICATE KEY UPDATE name=VALUES(name);

-- update
UPDATE players SET name='Carlos Alcaraz Garfia' WHERE player_id=3;

-- delete
DELETE FROM match_results WHERE player2_id=2 OR player1_id=2 OR winner_id=2;
DELETE FROM player_rankings WHERE player_id=2;

DELETE FROM players WHERE player_id=2;

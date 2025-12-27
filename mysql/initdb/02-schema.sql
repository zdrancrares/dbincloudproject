CREATE DATABASE IF NOT EXISTS tennis
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE tennis;

SET FOREIGN_KEY_CHECKS=0;

DROP TABLE IF EXISTS player_rankings;
DROP TABLE IF EXISTS match_results;
DROP TABLE IF EXISTS matches;
DROP TABLE IF EXISTS tournaments;
DROP TABLE IF EXISTS players;

CREATE TABLE players (
                         player_id INT NOT NULL,
                         name VARCHAR(100) NOT NULL,
                         country CHAR(3) NOT NULL,
                         birth_date DATE NOT NULL,
                         turned_pro_date DATE NULL,
                         PRIMARY KEY (player_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE tournaments (
                             tournament_id INT NOT NULL,
                             tournament_name VARCHAR(100) NOT NULL,
                             location VARCHAR(100) NOT NULL,
                             surface VARCHAR(20) NOT NULL,
                             tournament_level VARCHAR(20) NOT NULL,
                             prize_money DECIMAL(12,2) NULL,
                             PRIMARY KEY (tournament_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE matches (
                         match_id INT NOT NULL,
                         tournament_id INT NOT NULL,
                         match_date DATE NOT NULL,
                         round VARCHAR(20) NOT NULL,
                         court_name VARCHAR(50) NULL,
                         match_duration_minutes INT NULL,
                         PRIMARY KEY (match_id),
                         CONSTRAINT fk_matches_tournament
                             FOREIGN KEY (tournament_id) REFERENCES tournaments(tournament_id)
                                 ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE match_results (
                               result_id INT NOT NULL AUTO_INCREMENT,
                               match_id INT NOT NULL,
                               player1_id INT NOT NULL,
                               player2_id INT NOT NULL,
                               winner_id INT NOT NULL,
                               score VARCHAR(50) NULL,
                               player1_aces INT NULL,
                               player2_aces INT NULL,
                               player1_double_faults INT NULL,
                               player2_double_faults INT NULL,
                               PRIMARY KEY (result_id),
                               CONSTRAINT fk_results_match
                                   FOREIGN KEY (match_id) REFERENCES matches(match_id)
                                       ON DELETE RESTRICT ON UPDATE RESTRICT,
                               CONSTRAINT fk_results_player1
                                   FOREIGN KEY (player1_id) REFERENCES players(player_id)
                                       ON DELETE RESTRICT ON UPDATE RESTRICT,
                               CONSTRAINT fk_results_player2
                                   FOREIGN KEY (player2_id) REFERENCES players(player_id)
                                       ON DELETE RESTRICT ON UPDATE RESTRICT,
                               CONSTRAINT fk_results_winner
                                   FOREIGN KEY (winner_id) REFERENCES players(player_id)
                                       ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE player_rankings (
                                 ranking_id INT NOT NULL AUTO_INCREMENT,
                                 player_id INT NOT NULL,
                                 ranking_position INT NOT NULL,
                                 ranking_points INT NOT NULL,
                                 tournaments_played INT NULL,
                                 PRIMARY KEY (ranking_id),
                                 CONSTRAINT fk_rankings_player
                                     FOREIGN KEY (player_id) REFERENCES players(player_id)
                                         ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS=1;

INSERT INTO players (player_id, name, country, birth_date, turned_pro_date)
VALUES
    (1, 'Novak Djokovic', 'SRB', '1987-05-22', '2003-01-01'),
    (2, 'Rafael Nadal', 'ESP', '1986-06-03', '2001-01-01'),
    (3, 'Roger Federer', 'SUI', '1981-08-08', '1998-01-01'),
    (4, 'Andy Murray', 'GBR', '1987-05-15', '2005-01-01')
    ON DUPLICATE KEY UPDATE
                         name=VALUES(name),
                         country=VALUES(country),
                         birth_date=VALUES(birth_date),
                         turned_pro_date=VALUES(turned_pro_date);

INSERT INTO tournaments (tournament_id, tournament_name, location, surface, tournament_level, prize_money)
VALUES
    (10, 'Australian Open', 'Melbourne', 'Hard', 'Grand Slam', 75000000.00),
    (11, 'Roland Garros', 'Paris', 'Clay', 'Grand Slam', 53000000.00),
    (12, 'Wimbledon', 'London', 'Grass', 'Grand Slam', 50000000.00)
    ON DUPLICATE KEY UPDATE
                         tournament_name=VALUES(tournament_name),
                         location=VALUES(location),
                         surface=VALUES(surface),
                         tournament_level=VALUES(tournament_level),
                         prize_money=VALUES(prize_money);

INSERT INTO matches (match_id, tournament_id, match_date, round, court_name, match_duration_minutes)
VALUES
    (100, 10, CURDATE(), 'Final', 'Rod Laver Arena', 180),
    (101, 11, DATE_SUB(CURDATE(), INTERVAL 7 DAY), 'Semifinal', 'Court Philippe-Chatrier', 210),
    (102, 12, DATE_SUB(CURDATE(), INTERVAL 14 DAY), 'Quarterfinal', 'Centre Court', 165)
    ON DUPLICATE KEY UPDATE
                         tournament_id=VALUES(tournament_id),
                         match_date=VALUES(match_date),
                         round=VALUES(round),
                         court_name=VALUES(court_name),
                         match_duration_minutes=VALUES(match_duration_minutes);

INSERT INTO match_results (
    match_id, player1_id, player2_id, winner_id, score,
    player1_aces, player2_aces, player1_double_faults, player2_double_faults
)
VALUES
    (100, 1, 2, 1, '6-3 6-4', 10, 4, 2, 3),
    (101, 3, 4, 3, '6-7 6-2 6-4', 14, 9, 1, 4),
    (102, 1, 3, 1, '7-5 6-7 6-3', 11, 12, 3, 2);

INSERT INTO player_rankings (player_id, ranking_position, ranking_points, tournaments_played)
VALUES
    (1, 1, 12000, 18),
    (2, 2, 10500, 16),
    (3, 3, 9800, 15),
    (4, 4, 9200, 17);

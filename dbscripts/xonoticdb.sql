DROP DATABASE IF EXISTS xonoticdb;
CREATE DATABASE xonoticdb;
USE xonoticdb;


CREATE TABLE `player` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(120) DEFAULT NULL,
  `email` varchar(60) DEFAULT NULL,
  `inventory` json DEFAULT NULL,
  `level` smallint(6) DEFAULT NULL,
  `registration_date` timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=387 DEFAULT CHARSET=utf8;

CREATE TABLE `game` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `game_name` varchar(120) NOT NULL,
  `total_players` int(11) NOT NULL,
  `start_time` timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `end_time` timestamp(6) NULL DEFAULT NULL,
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

CREATE TABLE `gameplayer` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `game_id` int(10) unsigned NOT NULL,
  `player_id` bigint(20) NOT NULL,
  `start_time` timestamp(6) NULL DEFAULT NULL,
  UNIQUE KEY `id` (`id`),
  KEY `idx_1` (`player_id`)
) ENGINE=InnoDB AUTO_INCREMENT=235 DEFAULT CHARSET=utf8;

CREATE TABLE `leaderboard` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `game_id` int(10) unsigned NOT NULL,
  `player_id` bigint(20) NOT NULL,
  `killed_by` bigint(20) DEFAULT NULL,
  `killed_time` timestamp(6) NULL DEFAULT NULL,
  UNIQUE KEY `id` (`id`),
  KEY `idx_1` (`killed_by`,`game_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4335 DEFAULT CHARSET=utf8;

CREATE OR REPLACE VIEW v_full_leaderboard AS (
SELECT A.id, A.game_name as GameName, A.start_time as StartTime, P.id as PlayerID, P.name as PlayerName, coalesce(D.kills, 0)  as Kills, coalesce(C.deaths,0) as Deaths
FROM game A 
INNER JOIN gameplayer B on A.id = B.game_id
INNER JOIN player P on B.player_id = P.id
LEFT JOIN (select game_id, player_id, count(*) as deaths from leaderboard group by game_id, player_id) C on A.id = C.game_id AND B.player_id = C.player_id
LEFT JOIN (select game_id, killed_by, count(*) as kills from leaderboard group by game_id, killed_by) D on A.id = D.game_id AND B.player_id = D.killed_by);

CREATE OR REPLACE VIEW v_game_players AS (
SELECT A.id, A.game_name as GameName, A.start_time as StartTime, P.id as PlayerID, P.name as PlayerName, P.level as PlayerLevel
FROM game A 
INNER JOIN gameplayer B on A.id = B.game_id
INNER JOIN player P on B.player_id = P.id
ORDER BY A.start_time DESC, A.game_name, P.name);

CREATE OR REPLACE VIEW v_top_leaderboard AS (
SELECT ID as GameID, GameName, StartTime, PlayerID, PlayerName, Kills, Deaths, A.RN 
FROM (SELECT id, GameName, StartTime, PlayerID, PlayerName, Kills, Deaths, ROW_NUMBER() OVER (PARTITION BY ID ORDER BY Kills DESC) AS RN from v_full_leaderboard) A
);
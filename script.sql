USE master
GO

if exists(select * from sysdatabases where name='PD2')
	drop database PD2
GO

CREATE DATABASE PD2
GO

USE PD2

CREATE TABLE Users
(
	UserID		INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	Nick		VARCHAR(50) NOT NULL,
	Email		VARCHAR(50) NOT NULL
)

CREATE UNIQUE INDEX ix_U_Nick ON Users(Nick);

CREATE TABLE Channels
(
	ChannelID	INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	Name		VARCHAR(50) NOT NULL,
	OwnerID		INT NOT NULL FOREIGN KEY REFERENCES Users(UserID)
)

CREATE UNIQUE INDEX ix_C_Name ON Channels(Name);
CREATE INDEX ix_C_OwnerID ON Channels(OwnerID);

CREATE TABLE Videos
(
	VideoID		INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	ChannelID	INT NOT NULL FOREIGN KEY REFERENCES Channels(ChannelID),
	Title		VARCHAR(70) NOT NULL,
	Duration	TIME NOT NULL
)

CREATE INDEX ix_Vids_ChannelID ON Videos(ChannelID);
CREATE INDEX ix_Vids_Title ON Videos(Title);

CREATE TABLE Genres
(
	GenreID		INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	Name		VARCHAR(50) NOT NULL
)

CREATE TABLE Videos_Genres
(
	VideoID		INT NOT NULL FOREIGN KEY REFERENCES Videos(VideoID),
	GenreID		INT NOT NULL FOREIGN KEY REFERENCES Genres(GenreID),
	PRIMARY KEY (VideoID, GenreID),
)

CREATE INDEX ix_VG_VideoID ON Videos_Genres(VideoID);
CREATE INDEX ix_VG_GenreID ON Videos_Genres(GenreID);

CREATE TABLE Watch_History
(
	WatchID		INT NOT NULL PRIMARY KEY NONCLUSTERED IDENTITY(1, 1),
	UserID		INT NOT NULL FOREIGN KEY REFERENCES Users(UserID),
	VideoID		INT NOT NULL FOREIGN KEY REFERENCES Videos(VideoID),
	Watch_Time	DATETIME NOT NULL,
)

CREATE CLUSTERED INDEX ix_WH_UserID ON Watch_History(UserID);
CREATE INDEX ix_WH_VideoID ON Watch_History(VideoID);

CREATE TABLE Subscriptions
(
	UserID		INT NOT NULL FOREIGN KEY REFERENCES Users(UserID),
	ChannelID	INT NOT NULL FOREIGN KEY REFERENCES Channels(ChannelID),
	PRIMARY KEY NONCLUSTERED (UserID, ChannelID)
)

CREATE CLUSTERED INDEX ix_Sub_UserID ON Subscriptions(UserID);
CREATE INDEX ix_Sub_ChannelID ON Subscriptions(ChannelID);

INSERT INTO Users VALUES
(
	'MusicFan', 'music.fan@gmail.com'
),
(
	'CatGaming', 'catgaming@gmail.com'
),
(
	'GamingMaster', 'gaming.master@gmail.com'
),
(
	'MusicFactory', 'music.factory@gmail.com'
),
(
	'GameReviewer', 'game.reviewer@gmail.com'
),
(
	'LetsPlayer', 'letsplayer@gmail.com'
),
(
	'CatLover', 'cat.lover@gmail.com'
)

INSERT INTO Channels VALUES
(
	'Music Channel', 4
),
(
	'Lets Play Channel', 5
),
(
	'Review Channel', 6
),
(
	'Cats', 7
)

INSERT INTO Videos VALUES
(
	(SELECT ChannelID FROM Channels WHERE Name = 'Music Channel'), 'My first song!', '00:03:00'
),
(
	(SELECT ChannelID FROM Channels WHERE Name = 'Music Channel'), 'My second song!', '00:04:15'
),
(
	(SELECT ChannelID FROM Channels WHERE Name = 'Music Channel'), 'A cat song!', '00:02:49'
),
(
	(SELECT ChannelID FROM Channels WHERE Name = 'Review Channel'), 'New Game review. Is it as good as people claim?', '00:21:36'
),
(
	(SELECT ChannelID FROM Channels WHERE Name = 'Lets Play Channel'), 'Lets play New Game S01E01', '00:15:42'
),
(
	(SELECT ChannelID FROM Channels WHERE Name = 'Lets Play Channel'), 'Lets play New Game S01E02', '00:20:04'
),
(
	(SELECT ChannelID FROM Channels WHERE Name = 'Cats'), 'Everything you need to know about cats', '10:56:59'
),
(
	(SELECT ChannelID FROM Channels WHERE Name = 'Cats'), 'Why are cats superior animals?', '20:08:01'
)

INSERT INTO Genres VALUES
(
	'Music'
),
(
	'Gaming'
),
(
	'Animals'
)

INSERT INTO Videos_Genres VALUES
(1, 1), (2, 1), (3, 1), (3, 3), (4, 2), (5, 2), (6, 2), (7, 3), (8, 3)

INSERT INTO Subscriptions VALUES
(1, 1), (2, 2), (2, 3), (3, 2)

INSERT INTO Watch_History VALUES
(1, 1, '2020-01-02 12:32:01'), (1, 1, '2020-01-02 12:35:01'), (1, 1, '2020-01-02 12:38:01'), (1, 1, '2020-01-02 12:41:01'), (1, 1, '2020-01-02 12:44:01'), (1, 1, '2020-01-02 12:32:01'),
(1, 2, '2020-01-02 12:50:01'), (1, 3, '2020-01-02 12:55:01'), (2, 4, '2020-01-02 12:32:01'), (2, 5, '2020-01-02 13:30:01'), (2, 6, '2020-01-02 15:32:01'), (2, 7, '2020-01-02 20:00:01'),
(2, 8, '2020-01-03 12:30:01'), (3, 4, '2020-01-02 12:32:01'), (3, 5, '2020-01-02 13:42:01'), (3, 6, '2020-01-02 15:12:01'), (1, 1, '2020-01-03 09:03:01'), (1, 1, '2020-01-03 09:10:01'),
(1, 1, '2020-01-03 09:15:01'), (1, 1, '2020-01-03 09:20:01'), (2, 5, '2020-01-04 11:51:32'), (2, 8, '2020-01-05 12:00:02'), (1, 1, '2021-05-29 12:32:01'), (1, 1, '2021-05-29 12:40:01')

UPDATE Users
SET Email = 'music.fan@yahoo.com'
WHERE UserID = 1

UPDATE Users
SET Email = 'cat.gaming@yahoo.com'
WHERE UserID = 2

UPDATE Users
SET Email = 'gaming.master@yahoo.com'
WHERE UserID = 3

SELECT u.Nick as 'User', v.Title as 'Video Title', v.Duration as 'Video Duration', c.Name as 'Channel Name', g.Name as 'Genre'
FROM Watch_History wh
JOIN Videos v on v.VideoID = wh.VideoID
JOIN Users u on u.UserID = wh.UserID
JOIN Channels c on c.ChannelID = v.ChannelID
JOIN Videos_Genres vg on vg.VideoID = v.VideoID
JOIN Genres g on g.GenreID = vg.GenreID
ORDER BY Watch_Time
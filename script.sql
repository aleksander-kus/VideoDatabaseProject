USE master
GO

if exists(select * from sysdatabases where name='PD2')
	drop database PD2
GO

CREATE DATABASE PD2
GO

USE PD2

CREATE TABLE Channels
(
	ChannelID	INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	Name		VARCHAR(50) NOT NULL		
)

CREATE TABLE Videos
(
	VideoID		INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	ChannelID	INT NOT NULL FOREIGN KEY REFERENCES Channels(ChannelID),
	Title		VARCHAR(70) NOT NULL,
	Duration	TIME NOT NULL
)

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

CREATE TABLE Users
(
	UserID		INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	Nick		VARCHAR(50) NOT NULL,
	Email		VARCHAR(50) NOT NULL
)

CREATE TABLE Watch_History
(
	UserID		INT NOT NULL FOREIGN KEY REFERENCES Users(UserID),
	VideoID		INT NOT NULL FOREIGN KEY REFERENCES Videos(VideoID),
	Watch_Time	DATETIME NOT NULL,
	PRIMARY KEY (UserID, VideoID)
)

CREATE TABLE Subscriptions
(
	UserID		INT NOT NULL FOREIGN KEY REFERENCES Users(UserID),
	ChannelID	INT NOT NULL FOREIGN KEY REFERENCES Channels(ChannelID),
	PRIMARY KEY (UserID, ChannelID)
)

INSERT INTO Channels VALUES
(
	'Music Channel'
),
(
	'Lets Play Channel'
),
(
	'Review Channel'
),
(
	'Cats'
)

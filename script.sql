USE master
GO

if exists(select * from sysdatabases where name='PD2')
	drop database PD2
GO

CREATE DATABASE PD2
GO

USE PD2

CREATE TABLE Videos
(
	VideoID		INT NOT NULL PRIMARY KEY,
	Title		VARCHAR(50) NOT NULL,
	Duration	INT NOT NULL
)

CREATE TABLE Genres
(
	GenreID		INT NOT NULL PRIMARY KEY,
	Name		VARCHAR(50) NOT NULL
)

CREATE TABLE Videos_Genres
(
	VideoID		INT NOT NULL FOREIGN KEY REFERENCES Videos(VideoID),
	GenreID		INT NOT NULL FOREIGN KEY REFERENCES Genres(GenreID),
	PRIMARY KEY (VideoID, GenreID),
)
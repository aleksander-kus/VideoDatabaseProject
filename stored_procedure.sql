USE PD2
GO

-- Prepare archive table
IF OBJECT_ID('HistoryArchive') IS NOT NULL DROP TABLE HistoryArchive;
SELECT * INTO HistoryArchive FROM Watch_History WHERE 0=1;

ALTER TABLE HistoryArchive
ADD CONSTRAINT [PK_WatchID] Primary Key (WatchID),
	CONSTRAINT [FK_Users] FOREIGN KEY (UserID) REFERENCES Users(UserID),
	CONSTRAINT FK_Videos FOREIGN KEY (VideoID) REFERENCES Videos(VideoID);

set Identity_insert dbo.HistoryArchive ON;


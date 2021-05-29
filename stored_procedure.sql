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

-- Add ViewsCnt column to Videos table
ALTER TABLE Videos
ADD ViewsCnt INT NOT NULL DEFAULT(0);
GO

-- Create procedure
IF OBJECT_ID('arch') IS NOT NULL
	DROP PROC arch;
GO
CREATE PROCEDURE arch
	@DaysCount int
AS
BEGIN
	SET IDENTITY_INSERT dbo.HistoryArchive ON;

	DECLARE @archiveDate datetime;
	DECLARE @currentDate datetime;
	DECLARE @archivedVideoIDs TABLE(WatchID int, VideoID int);
	DECLARE @archivedViewCount TABLE(VideoID int, ViewCount int);


	SET @currentDate = getdate();
	SET @archiveDate = dateadd(dd, -@DaysCount, @currentDate);
	
	IF (SELECT COUNT(*) FROM Watch_History WHERE Watch_Time <= @archiveDate) = 0
	BEGIN
		print 'There are no records to archive... ';
		RETURN;
	END;

	PRINT 'Archiving records older than ' + CONVERT(VARCHAR(4),@DaysCount) + ' days' ;

	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
	
	BEGIN TRANSACTION
	BEGIN TRY

		-- Move records from Watch_History to HistoryArchive
		INSERT INTO HistoryArchive(WatchID, UserID, VideoID, Watch_Time)
		OUTPUT INSERTED.WatchID, inserted.VideoID INTO @archivedVideoIDs
		SELECT * FROM Watch_History WHERE Watch_Time <= @archiveDate;
		
		DELETE FROM Watch_History
		FROM Watch_History wh JOIN @archivedVideoIDs AO ON wh.WatchID = AO.WatchID;

		-- Update ViewsCnt column in Videos
		DECLARE @vID INT, @vctn INT;

		DECLARE c CURSOR LOCAL FOR SELECT VideoID, COUNT(*) FROM @archivedVideoIDs GROUP BY VideoID;
		OPEN c
		FETCH NEXT FROM c INTO @vID, @vctn

		WHILE @@FETCH_STATUS=0
		BEGIN
			UPDATE Videos SET ViewsCnt = ViewsCnt + @vctn WHERE VideoID = @vID;
			FETCH NEXT FROM c INTO @vID, @vctn
		END
		CLOSE c
		DEALLOCATE c
		COMMIT TRANSACTION

	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		print ERROR_MESSAGE()
	END CATCH;
END

-- execute procedure
EXECUTE arch 30;

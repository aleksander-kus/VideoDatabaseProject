USE PD2

-- 1. Time watched by each user on each channel
SELECT Name as 'Channel Name', Nick, SUM(DATEDIFF(ms, '00:00:00', Duration)) / 1000 as 'Seconds Watched'
FROM Users u
Join Watch_History wh on wh.UserID = u.UserID
Join Videos v on v.VideoID = wh.VideoID
Join Channels c on c.ChannelID = v.ChannelID
GROUP BY Nick, c.Name, c.ChannelID
ORDER BY c.ChannelID;

-- 2. Subscribed users who watches < 3 videos on each channel
SELECT u.Nick, c.Name, b.[Videos watched]
FROM
(
	SELECT s.UserID, s.ChannelID, CASE WHEN a.ChannelID IS NULL THEN 0 ELSE COUNT(*) END as 'Videos watched'
	FROM Subscriptions s
	LEFT JOIN
	(
		SELECT v.VideoID, v.ChannelID, wh.UserID FROM Watch_History wh
		Join Videos v on v.VideoID = wh.VideoID
	) a on a.ChannelID = s.ChannelID AND a.UserID = s.UserID
	GROUP BY s.UserID, s.ChannelID, a.UserID, a.ChannelID
	HAVING COUNT(*) < 3 OR a.ChannelID IS NULL
) b
JOIN Users u on u.UserID = b.UserID
JOIN Channels c on c.ChannelID = b.ChannelID

-- 3. Most popular video in each genre
WITH ViewTable (VideoID, Title, ViewCount) AS
(
	SELECT v.VideoID, v.Title, COUNT(*) as ViewCount
	FROM Videos v
	Join Watch_History wh on wh.VideoID = v.VideoID
	GROUP BY v.VideoID, v.Title
)
SELECT g.Name as 'Genre', vt1.Title as 'Most popular video', vt1.ViewCount as 'View Count'
FROM Genres g
JOIN Videos_Genres vg1 on vg1.GenreID = g.GenreID
JOIN  ViewTable vt1 on vt1.VideoID = vg1.VideoID
JOIN
(
	SELECT g.GenreID, MAX(vt.ViewCount) as ViewCount
	FROM Genres g
	JOIN Videos_Genres vg on vg.GenreID = g.GenreID
	JOIN  ViewTable vt on vt.VideoID = vg.VideoID
	GROUP BY g.GenreID
) as tmp on tmp.GenreID = vg1.GenreID AND tmp.ViewCount = vt1.ViewCount
ORDER BY g.GenreID;

-- 4. For each channel display the ratio of views to amount of posted videos
SELECT c.Name, CAST(a.[Videos watched] as float) / COUNT(*) as 'Views to posted ratio'
FROM Videos v
JOIN Channels c on c.ChannelID = v.ChannelID
JOIN
(
	SELECT c.Name, COUNT(*) as 'Videos watched'
	FROM Watch_History wh
	Join Videos v on v.VideoID = wh.VideoID
	Join Channels c on c.ChannelID = v.ChannelID
	GROUP BY c.Name
) a on a.Name = c.Name
GROUP BY c.Name, a.[Videos watched]
ORDER BY [Views to posted ratio] DESC

-- 5. Videos by most subscribed channel
SELECT v.Title, v.Duration
FROM
	(
	SELECT s.ChannelID, COUNT(*) as c
	FROM Subscriptions s
	GROUP BY s.ChannelID
	HAVING COUNT(*) =
	(
		SELECT MAX(a.Subscribers)
		FROM
		(
			SELECT COUNT(*) as 'Subscribers'
			FROM Subscriptions
			GROUP BY ChannelID
		) as a
	)
) as f
JOIN Videos v on v.ChannelID = f.ChannelID
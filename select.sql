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
SELECT u.Nick, c.Name, COUNT(wh.VideoID) as 'Videos watched'
FROM Users u
Join Watch_History wh on wh.UserID = u.UserID
Join Videos v on v.VideoID = wh.VideoID
Join Channels c on c.ChannelID = v.ChannelID
WHERE c.ChannelID IN (SELECT ChannelID FROM Subscriptions s WHERE s.UserID = u.UserID)
GROUP BY u.Nick, c.Name
HAVING COUNT(wh.VideoID) < 3;

-- 3. Most popular video in each genre
WITH ViewTable (VideoID, Title, ViewCount) AS
(
	SELECT v.VideoID, v.Title, COUNT(v.VideoID) as ViewCount
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

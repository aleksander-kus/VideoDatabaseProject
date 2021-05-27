USE PD2

-- 1. Time watched by each user on each channel
SELECT Nick, Name as 'Channel Name', SUM(DATEDIFF(ms, '00:00:00', Duration)) / 1000 as 'Seconds Watched'
FROM Users u
Join Watch_History wh on wh.UserID = u.UserID
Join Videos v on v.VideoID = wh.VideoID
Join Channels c on c.ChannelID = v.ChannelID
GROUP BY Nick, c.Name, c.ChannelID
ORDER BY c.ChannelID;


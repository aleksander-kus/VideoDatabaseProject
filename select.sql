USE PD2
--SUM(DATEDIFF(ms, '00:00:00', Duration))
SELECT Nick, Email, Watch_Time, Title, Duration, Name
FROM Users u
Join Watch_History wh on wh.UserID = u.UserID
Join Videos v on v.VideoID = wh.VideoID
Join Channels c on c.ChannelID = v.ChannelID
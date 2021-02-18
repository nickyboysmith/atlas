


SELECT DISTINCT SCET.ScheduledEmailId
INTO #tempEmail
FROM ScheduledEmail SCE
INNER JOIN ScheduledEmailTo SCET ON SCE.Id = SCET.ScheduledEmailId
LEFT JOIN OrganisationScheduledEmail OSCE ON SCE.Id = OSCE.ScheduledEmailId
WHERE SCET.Email IN (SELECT DISTINCT Email
						FROM EmailsBlockedOutgoing EBO);

DELETE A
FROM #tempEmail T
INNER JOIN OrganisationScheduledEmail A ON A.ScheduledEmailId = T.ScheduledEmailId
						
DELETE A
FROM #tempEmail T
INNER JOIN ScheduledEmailTo A ON A.ScheduledEmailId = T.ScheduledEmailId
						
DELETE A
FROM #tempEmail T
INNER JOIN ScheduledEmailNote A ON A.ScheduledEmailId = T.ScheduledEmailId
						
DELETE A
FROM #tempEmail T
INNER JOIN ScheduledEmailAttachment A ON A.ScheduledEmailId = T.ScheduledEmailId

DELETE A
FROM #tempEmail T
INNER JOIN SystemScheduledEmail A ON A.ScheduledEmailId = T.ScheduledEmailId
						
DELETE A
FROM #tempEmail T
INNER JOIN CourseVenueEmail A ON A.ScheduledEmailId = T.ScheduledEmailId
						
DELETE A
FROM #tempEmail T
INNER JOIN ScheduledEmail A ON A.Id = T.ScheduledEmailId


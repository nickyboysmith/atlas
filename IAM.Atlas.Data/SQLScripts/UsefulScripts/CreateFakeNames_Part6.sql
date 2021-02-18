


INSERT INTO FakePeople (FirstName, Surname, Email, Sex)
SELECT DISTINCT FP2.FirstName, FP2.Surname, LOWER(FP2.FirstName + '.' + FP2.Surname + '2@iam_fake_email2.com') AS Email, FP2.Sex
FROM dbo.FakePeople FP1
INNER JOIN dbo.FakePeople FP2 ON FP2.Id = FP1.Id + 3 AND FP2.Sex = FP1.Sex
WHERE NOT EXISTS (SELECT * FROM dbo.FakePeople FP3 WHERE FP3.Email = LOWER(FP2.FirstName + '.' + FP2.Surname + '2@iam_fake_email2.com'))
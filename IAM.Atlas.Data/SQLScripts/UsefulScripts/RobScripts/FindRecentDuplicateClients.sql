


SELECT CL.DisplayName, CLL.LicenceNumber, E.[Address], COUNT(*) CNT, MIN(CL.Id) EarliestId, MAX(CL.Id) LatestId
FROM dbo.Client CL
INNER JOIN dbo.ClientLicence CLL ON CLL.ClientId = CL.Id
INNER JOIN dbo.ClientEmail CE ON CE.ClientId = CL.Id
INNER JOIN dbo.Email E ON E.Id = CE.EmailId
LEFT JOIN dbo.ClientMarkedForDelete CMFD ON CMFD.ClientId = CL.Id
WHERE CL.DateCreated > DATEADD(HOUR, -4, GETDATE())
--AND CMFD.Id IS NULL
GROUP BY CL.DisplayName, CLL.LicenceNumber, E.[Address]
HAVING COUNT(*) > 1

DECLARE @ClientId INT = NULL;

			SELECT CL2.Id												AS ClientId
				, dbo.udfGetSystemUserId()								AS RequestedByUserId
				, GETDATE()												AS DateRequested
				, DATEADD(DAY, 7, GETDATE())							AS DeleteAfterDate
				, 'Atlas System Noted Newer Duplicate Details Entered'	AS Note
			FROM (
				SELECT CL.DisplayName, CLL.LicenceNumber, E.[Address], COUNT(*) CNT, MIN(CL.Id) EarliestId, MAX(CL.Id) LatestId
				FROM dbo.Client CL
				INNER JOIN dbo.ClientLicence CLL			ON CLL.ClientId = CL.Id
				INNER JOIN dbo.ClientEmail CE				ON CE.ClientId = CL.Id
				INNER JOIN dbo.Email E						ON E.Id = CE.EmailId
				LEFT JOIN dbo.ClientMarkedForDelete CMFD	ON CMFD.ClientId = CL.Id
				WHERE CL.DateCreated > DATEADD(HOUR, -4, GETDATE())
				--AND CMFD.Id IS NULL--Not Already Marked For Deletion
				GROUP BY CL.DisplayName, CLL.LicenceNumber, E.[Address]
				HAVING COUNT(*) > 1
				) T
			INNER JOIN dbo.Client CL2						ON CL2.DisplayName = T.DisplayName
			INNER JOIN dbo.ClientLicence CLL2				ON CLL2.LicenceNumber = T.LicenceNumber
															AND CLL2.ClientId = CL2.Id
			INNER JOIN dbo.Email E2							ON E2.[Address] = T.[Address]
			INNER JOIN dbo.ClientEmail CE2					ON CE2.EmailId = E2.Id
															AND CE2.ClientId = CL2.Id
			LEFT JOIN dbo.ClientMarkedForDelete CMFD2		ON CMFD2.ClientId = CL2.Id
			LEFT JOIN dbo.CourseClient CC					ON CC.ClientId = CL2.Id
			LEFT JOIN dbo.ClientPayment CLP					ON CLP.ClientId = CL2.Id
			WHERE T.LatestId = ISNULL(@ClientId, T.LatestId) --If Null Look for All Duplicates Else Duplicates of the Specific
			AND CL2.DateCreated > DATEADD(HOUR, -4, GETDATE())
			AND CL2.Id = T.EarliestId
			--AND CMFD2.Id IS NULL --Not Already Marked For Deletion
			AND CC.Id IS NULL --Not Booked onto any Courses
			AND CLP.Id IS NULL --Not Made any Payments
			;
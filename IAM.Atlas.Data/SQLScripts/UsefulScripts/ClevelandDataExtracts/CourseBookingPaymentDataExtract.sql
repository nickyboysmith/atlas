

SELECT DISTINCT
	P.Id							AS AtlasPaymentId
	, P.TransactionDate				AS TransactionDate
	, ISNULL(P.Reference,'')		AS PaymentReference
	, ISNULL(P.ReceiptNumber,'')	AS PaymentReceiptNumber
	, P.Amount						AS PaymentAmount
	, PM.[Name]						AS PaymentMethod
	, ISNULL(PCT.[Name],'')			AS PaymentCardType
	, ISNULL(N.Note,'')				AS PaymentNote
	, (CASE WHEN C.Id IS NOT NULL
			THEN C.Id ELSE NULL END)			AS ForCourseAtlasCourseId
	, (CASE WHEN C.Id IS NOT NULL
			THEN C.Reference ELSE NULL END)		AS ForCourseAtlasCourseReference
	, (CASE WHEN CLO.Id IS NOT NULL
			THEN CLO.ClientId ELSE NULL END)	AS ForClientAtlasClientId
	, (CASE WHEN CLO.Id IS NOT NULL
			THEN ISNULL(CLL.LicenceNumber,'') ELSE NULL END)	AS ForClientAtlasClientLicenceNumber
FROM dbo.Payment P
LEFT JOIN dbo.PaymentMethod PM				ON PM.Id = P.PaymentMethodId
LEFT JOIN dbo.PaymentCard PC				ON PC.PaymentId = P.Id
LEFT JOIN dbo.PaymentCardType PCT			ON PCT.Id = PC.PaymentCardTypeId
LEFT JOIN dbo.OrganisationPayment OP		ON OP.PaymentId = P.Id
											AND OP.OrganisationId = 318
LEFT JOIN dbo.ClientPayment CP				ON CP.PaymentId = P.Id
LEFT JOIN dbo.ClientOrganisation CLO		ON CLO.ClientId = CP.ClientId
											AND CLO.OrganisationId = 318
LEFT JOIN dbo.ClientLicence CLL				ON CLL.ClientId = CLO.ClientId
LEFT JOIN dbo.CourseClientPayment CCP		ON CCP.PaymentId = P.Id
LEFT JOIN dbo.Course C						ON C.Id = CCP.CourseId
											AND C.OrganisationId = 318
LEFT JOIN dbo.PaymentNote PN				ON PN.PaymentId = P.Id
LEFT JOIN dbo.Note N						ON N.Id = PN.NoteId
WHERE P.TransactionDate > DATEADD(YEAR, -3.5, GETDATE())
AND (C.Id IS NOT NULL OR CLO.Id IS NOT NULL OR OP.Id IS NOT NULL)
ORDER BY P.TransactionDate DESC


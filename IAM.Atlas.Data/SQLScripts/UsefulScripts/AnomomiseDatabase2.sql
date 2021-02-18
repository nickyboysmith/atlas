
	PRINT 'Trainers';
	PRINT 'Reset Fake People';
	UPDATE dbo._Temp_FakePeople 
	SET AlternateId = NULL;
	
	/*********************************************************************************/
	IF OBJECT_ID('tempdb..#FakePeople1', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #FakePeople1;
	END	
	IF OBJECT_ID('tempdb..#Trainer1', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #Trainer1;
	END			

	--First the Girlies
	PRINT 'First the Girlies';
	SELECT Id
	, Firstname
	, Surname
	, Sex
	, ROW_NUMBER() OVER (ORDER BY (SELECT 100)) AS RowNumber 
	INTO #FakePeople1
	FROM dbo._Temp_FakePeople 
	WHERE AlternateId IS NULL AND Sex = 'F';

	SELECT Id
	, Title
	, FirstName
	, Surname
	, GenderId
	, ROW_NUMBER() OVER (ORDER BY (SELECT 100)) AS RowNumber 
	INTO #Trainer1
	FROM dbo.Trainer
	WHERE GenderId = 0;

	UPDATE FP
	SET AlternateId = TrainerTable.Id
	FROM dbo._Temp_FakePeople FP
	INNER JOIN #FakePeople1 FP2 ON FP2.Id = FP.Id
	INNER JOIN #Trainer1 TrainerTable ON TrainerTable.RowNumber = FP2.RowNumber;
	
	UPDATE C
	SET FirstName = FP.Firstname
	, Surname = FP.Surname
	, DisplayName = LTRIM(RTRIM(ISNULL(Title, '') + ' ' + FP.Firstname + ' ' + FP.Surname))
	FROM dbo.Trainer C
	INNER JOIN dbo._Temp_FakePeople FP ON FP.AlternateId = C.Id
	WHERE C.GenderId = 0;
	
	/*********************************************************************************/
	--Now the Boysies
	IF OBJECT_ID('tempdb..#FakePeople2', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #FakePeople2;
	END	
	IF OBJECT_ID('tempdb..#Trainer2', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #Trainer2;
	END			

	--Now the Boysies
	PRINT 'Now the Boysies';
	SELECT Id
	, Firstname
	, Surname
	, Sex
	, ROW_NUMBER() OVER (ORDER BY (SELECT 100)) AS RowNumber 
	INTO #FakePeople2
	FROM dbo._Temp_FakePeople 
	WHERE AlternateId IS NULL AND Sex = 'M';

	SELECT Id
	, Title
	, FirstName
	, Surname
	, GenderId
	, ROW_NUMBER() OVER (ORDER BY (SELECT 100)) AS RowNumber 
	INTO #Trainer2
	FROM dbo.Trainer
	WHERE GenderId = 1;

	UPDATE FP
	SET AlternateId = TrainerTable.Id
	FROM dbo._Temp_FakePeople FP
	INNER JOIN #FakePeople2 FP2 ON FP2.Id = FP.Id
	INNER JOIN #Trainer2 TrainerTable ON TrainerTable.RowNumber = FP2.RowNumber
	
	UPDATE C
	SET FirstName = FP.Firstname
	, Surname = FP.Surname
	, DisplayName = LTRIM(RTRIM(ISNULL(Title, '') + ' ' + FP.Firstname + ' ' + FP.Surname))
	FROM dbo.Trainer C
	INNER JOIN dbo._Temp_FakePeople FP ON FP.AlternateId = C.Id
	WHERE C.GenderId = 1;
	
	
	/*********************************************************************************/
	--Now the Anom Data
	PRINT 'Now the Anom Data';
	IF OBJECT_ID('tempdb..#FakePeople3', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #FakePeople3;
	END	
	IF OBJECT_ID('tempdb..#Trainer3', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #Trainer3;
	END			

	--Now the Anom Data with now Title
	PRINT 'Now the Anom Data with now Title';
	SELECT Id
	, Firstname
	, Surname
	, Sex
	, ROW_NUMBER() OVER (ORDER BY (SELECT 100)) AS RowNumber 
	INTO #FakePeople3
	FROM dbo._Temp_FakePeople 
	WHERE AlternateId IS NULL;

	SELECT Id
	, Title
	, FirstName
	, Surname
	, GenderId
	, ROW_NUMBER() OVER (ORDER BY (SELECT 100)) AS RowNumber 
	INTO #Trainer3
	FROM dbo.Trainer
	WHERE GenderId = 9 AND FirstName = '(anonymised)' AND LTRIM(RTRIM(Title)) = '';

	UPDATE FP
	SET AlternateId = TrainerTable.Id
	FROM dbo._Temp_FakePeople FP
	INNER JOIN #FakePeople3 FP2 ON FP2.Id = FP.Id
	INNER JOIN #Trainer3 TrainerTable ON TrainerTable.RowNumber = FP2.RowNumber
	
	UPDATE C
	SET FirstName = FP.Firstname
	, Surname = FP.Surname
	, DisplayName = LTRIM(RTRIM(ISNULL(Title, '') + ' ' + FP.Firstname + ' ' + FP.Surname))
	, GenderId = (CASE WHEN FP.SEX = 'M' THEN 1 ELSE 0 END)
	FROM dbo.Trainer C
	INNER JOIN dbo._Temp_FakePeople FP ON FP.AlternateId = C.Id
	WHERE C.GenderId = 9 AND C.FirstName = '(anonymised)' AND LTRIM(RTRIM(C.Title)) = '';
		
	/*********************************************************************************/
	--Now the Anom Data ('Reverend', 'Captain', 'Dr')
	PRINT 'Now the Anom Data (''Reverend'', ''Captain'', ''Dr'')';
	IF OBJECT_ID('tempdb..#FakePeople4', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #FakePeople4;
	END	
	IF OBJECT_ID('tempdb..#Trainer4', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #Trainer4;
	END			

	--Now the Anom Data with now Title
	PRINT 'Now the Anom Data with now Title';
	SELECT Id
	, Firstname
	, Surname
	, Sex
	, ROW_NUMBER() OVER (ORDER BY (SELECT 100)) AS RowNumber 
	INTO #FakePeople4
	FROM dbo._Temp_FakePeople 
	WHERE AlternateId IS NULL AND Sex = 'M';

	SELECT Id
	, Title
	, FirstName
	, Surname
	, GenderId
	, ROW_NUMBER() OVER (ORDER BY (SELECT 100)) AS RowNumber 
	INTO #Trainer4
	FROM dbo.Trainer
	WHERE GenderId = 9 AND LTRIM(RTRIM(ISNULL(Title, ''))) IN('Reverend', 'Captain', 'Dr');

	UPDATE FP
	SET AlternateId = TrainerTable.Id
	FROM dbo._Temp_FakePeople FP
	INNER JOIN #FakePeople4 FP2 ON FP2.Id = FP.Id
	INNER JOIN #Trainer4 TrainerTable ON TrainerTable.RowNumber = FP2.RowNumber
	
	UPDATE C
	SET FirstName = FP.Firstname
	, Surname = FP.Surname
	, DisplayName = LTRIM(RTRIM(Title + ' ' + FP.Firstname + ' ' + FP.Surname))
	, GenderId = (CASE WHEN FP.SEX = 'M' THEN 1 ELSE 0 END)
	FROM dbo.Trainer C
	INNER JOIN dbo._Temp_FakePeople FP ON FP.AlternateId = C.Id
	WHERE C.GenderId = 9 AND LTRIM(RTRIM(ISNULL(Title, ''))) IN('Reverend', 'Captain', 'Dr');
	
	/*********************************************************************************/
	--Now the Anom Data ('Prof', 'Major', 'Doctor', 'Rev')
	PRINT 'Now the Anom Data (''Prof'', ''Major'', ''Doctor'', ''Rev'')';
	IF OBJECT_ID('tempdb..#FakePeople5', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #FakePeople5;
	END	
	IF OBJECT_ID('tempdb..#Trainer5', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #Trainer5;
	END			

	--Now the Anom Data with now Title
	PRINT 'Now the Anom Data with now Title';
	SELECT Id
	, Firstname
	, Surname
	, Sex
	, ROW_NUMBER() OVER (ORDER BY (SELECT 100)) AS RowNumber 
	INTO #FakePeople5
	FROM dbo._Temp_FakePeople 
	WHERE AlternateId IS NULL AND Sex = 'F';

	SELECT Id
	, Title
	, FirstName
	, Surname
	, GenderId
	, ROW_NUMBER() OVER (ORDER BY (SELECT 100)) AS RowNumber 
	INTO #Trainer5
	FROM dbo.Trainer
	WHERE GenderId = 9 AND LTRIM(RTRIM(ISNULL(Title, ''))) IN('Prof', 'Major', 'Doctor', 'Rev');

	UPDATE FP
	SET AlternateId = TrainerTable.Id
	FROM dbo._Temp_FakePeople FP
	INNER JOIN #FakePeople5 FP2 ON FP2.Id = FP.Id
	INNER JOIN #Trainer5 TrainerTable ON TrainerTable.RowNumber = FP2.RowNumber
	
	UPDATE C
	SET FirstName = FP.Firstname
	, Surname = FP.Surname
	, DisplayName = LTRIM(RTRIM(ISNULL(Title, '') + ' ' + FP.Firstname + ' ' + FP.Surname))
	, GenderId = (CASE WHEN FP.SEX = 'M' THEN 1 ELSE 0 END)
	FROM dbo.Trainer C
	INNER JOIN dbo._Temp_FakePeople FP ON FP.AlternateId = C.Id
	WHERE C.GenderId = 9 AND LTRIM(RTRIM(Title)) IN('Prof', 'Major', 'Doctor', 'Rev');
	
	/*********************************************************************************/
	
	--Now the Anom Data (All the rest)
	PRINT 'Now the Anom Data (All the rest)';
	IF OBJECT_ID('tempdb..#FakePeople6', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #FakePeople6;
	END	
	IF OBJECT_ID('tempdb..#Trainer6', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #Trainer6;
	END			

	--Now the Anom Data with no Title
	PRINT 'Now the Anom Data with no Title';
	SELECT Id
	, Firstname
	, Surname
	, Sex
	, ROW_NUMBER() OVER (ORDER BY (SELECT 100)) AS RowNumber 
	INTO #FakePeople6
	FROM dbo._Temp_FakePeople 
	WHERE AlternateId IS NULL;

	SELECT Id
	, Title
	, FirstName
	, Surname
	, GenderId
	, ROW_NUMBER() OVER (ORDER BY (SELECT 100)) AS RowNumber 
	INTO #Trainer6
	FROM dbo.Trainer
	WHERE GenderId = 9;

	UPDATE FP
	SET AlternateId = TrainerTable.Id
	FROM dbo._Temp_FakePeople FP
	INNER JOIN #FakePeople6 FP2 ON FP2.Id = FP.Id
	INNER JOIN #Trainer6 TrainerTable ON TrainerTable.RowNumber = FP2.RowNumber
	
	UPDATE C
	SET FirstName = FP.Firstname
	, Surname = FP.Surname
	, DisplayName = LTRIM(RTRIM(ISNULL(Title, '') + ' ' + FP.Firstname + ' ' + FP.Surname))
	, GenderId = (CASE WHEN FP.SEX = 'M' THEN 1 ELSE 0 END)
	FROM dbo.Trainer C
	INNER JOIN dbo._Temp_FakePeople FP ON FP.AlternateId = C.Id
	WHERE C.GenderId = 9;
	
	--Now the Trainer Email Addresses
	PRINT 'Now the Trainer Email Addresses';
	
	UPDATE E
	SET Address = FP.Email
	FROM dbo._Temp_FakePeople FP
	INNER JOIN dbo.TrainerEmail CE ON CE.TrainerId = FP.AlternateId
	INNER JOIN dbo.Email E ON E.Id = CE.EmailId
	WHERE AlternateId IS NOT NULL;

	/*********************************************************************************/
	PRINT 'For Any that were missed';
	-- For Any that were missed
	UPDATE dbo.Trainer
	SET DisplayName = LTRIM(RTRIM(ISNULL(Title, '') + ' ' + ISNULL(FirstName, '') + ' ' + ISNULL(Surname, '')))
	WHERE DisplayName IS NULL
		
	/*********************************************************************************/
	
	PRINT 'Update Client User Account';
	--Update Client User Account
	UPDATE U
	SET U.[Name] = CL.DisplayName 
	FROM Trainer CL
	INNER JOIN [User] U ON U.Id = CL.UserId
	WHERE CL.UserId IS NOT NULL
	AND U.[Name] != CL.DisplayName;

	
	/*********************************************************************************/
	
	PRINT 'Fake Trainer Licence Numbers';
	UPDATE CL
	SET CL.LicenceNumber = UPPER(CASE WHEN LEN(C.Surname) > 4 AND LEN(ISNULL(CL.LicenceNumber,'')) > 5
									THEN SUBSTRING(C.Surname,1,5) + SUBSTRING(CL.LicenceNumber,6, LEN(CL.LicenceNumber) - 5)
									WHEN LEN(C.Surname) = 4 AND LEN(ISNULL(CL.LicenceNumber,'')) > 5
									THEN SUBSTRING(C.Surname,1,4) + '9' + SUBSTRING(CL.LicenceNumber,6, LEN(CL.LicenceNumber) - 5)
									WHEN LEN(C.Surname) = 3 AND LEN(ISNULL(CL.LicenceNumber,'')) > 5
									THEN SUBSTRING(C.Surname,1,3) + '99' + SUBSTRING(CL.LicenceNumber,6, LEN(CL.LicenceNumber) - 5)
									WHEN LEN(C.Surname) = 2 AND LEN(ISNULL(CL.LicenceNumber,'')) > 5
									THEN SUBSTRING(C.Surname,1,2) + '999' + SUBSTRING(CL.LicenceNumber,6, LEN(CL.LicenceNumber) - 5)
									ELSE CL.LicenceNumber
									END
									)
	FROM dbo.Trainer C
	INNER JOIN dbo.TrainerLicence CL ON CL.TrainerId = C.Id
	WHERE LEN(C.Surname) > 1
	AND LEN(ISNULL(CL.LicenceNumber,'')) > 1
	
	/*********************************************************************************/
	PRINT 'Fake Trainer Phone Numbers';
	--Fake Numbers
	UPDATE CP
	SET CP.Number = 'FAKE' + CAST(CP.Id AS VARCHAR)
	FROM dbo.Trainer C
	INNER JOIN TrainerPhone CP ON CP.TrainerId = C.Id
	
	/*********************************************************************************/

	PRINT 'SETUP TEST ACCOUNT DETAILS FRO SECURE TRADING';
	DECLARE @SecTra_SiteRef VARCHAR(320) = 'test_pdse70272';
	DECLARE @SecTra_Password VARCHAR(320) = 'Atlas2016Payment';
	DECLARE @SecTra_UserName VARCHAR(320) = 'Atlas2016@iam.org.uk';

	UPDATE OPPC
	SET OPPC.[Value] = (CASE WHEN OPPC.[Key] = 'sitereference' THEN @SecTra_SiteRef
						WHEN OPPC.[Key] = 'password' THEN @SecTra_Password
						WHEN OPPC.[Key] = 'username' THEN @SecTra_UserName
						ELSE OPPC.[Value] END)
	FROM dbo.PaymentProvider PP
	INNER JOIN [dbo].[OrganisationPaymentProvider] OPP ON OPP.PaymentProviderId = PP.Id
	INNER JOIN dbo.OrganisationPaymentProviderCredential OPPC ON OPPC.OrganisationId = OPP.OrganisationId
																AND OPPC.PaymentProviderId = OPP.PaymentProviderId 
	WHERE PP.[Name] = 'Secure Trading';
	
	
	/*********************************************************************************/





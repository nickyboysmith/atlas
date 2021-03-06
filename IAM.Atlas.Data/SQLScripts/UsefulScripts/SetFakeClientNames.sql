
--SELECT * 
--INTO dbo._Temp_FakePeople
--FROM dbo._Temp_FakePeople

--SELECT [Id]
--      ,[Title]
--      ,[FirstName]
--      ,[Surname]
--      ,[OtherNames]
--      ,[DisplayName]
--      ,[DateOfBirth]
--      ,[Locked]
--      ,[UserId]
--      ,[GenderId]
--  FROM [Atlas_Dev].[dbo].[Client]
--  WHERE [FirstName] = '(anonymised)'

	--	BEGIN TRY
	--		--Drop if Exists
	--		DROP EXTERNAL DATA SOURCE IAM_Elastic_Test;
	--	END TRY
	--	BEGIN CATCH
	--	END CATCH
	--	BEGIN TRY
	--		--Drop if Exists
	--		DROP DATABASE SCOPED CREDENTIAL ElasticDBQueryCred;
	--	END TRY
	--	BEGIN CATCH
	--	END CATCH
	--	BEGIN TRY
	--		--Drop if Exists
	--		DROP MASTER KEY;
	--	END TRY
	--	BEGIN CATCH
	--	END CATCH
	
	--	BEGIN TRY
	--		CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'IAM1961!TestAndDev';

	--		CREATE DATABASE SCOPED CREDENTIAL ElasticDBQueryCred  
	--		WITH IDENTITY = 'Atlas!Test1961',
	--		SECRET = 'IAM1961!TestAndDev';

	--		CREATE EXTERNAL DATA SOURCE IAM_Elastic_Test WITH
	--		  (TYPE = RDBMS,
	--		  LOCATION = 'tcp:atlastest.database.windows.net,1433',
	--		  DATABASE_NAME = 'Developers',
	--		  CREDENTIAL = ElasticDBQueryCred
	--		) ;
	--	END TRY
	--	BEGIN CATCH
	--	END CATCH
		
	--CREATE EXTERNAL TABLE [dbo].[FakePeople](
	--	[Id] [int] NOT NULL,
	--	[FirstName] [varchar](200) NULL,
	--	[Surname] [varchar](200) NULL,
	--	[Email] [varchar](300) NULL,
	--	[Sex] [char](1) NULL,
	--	[AlternateId] [int] NULL
	--)
	-- WITH ( DATA_SOURCE = IAM_Elastic_Test ) ;
	--/************/

	
		--CREATE NONCLUSTERED INDEX [IX__Temp_FakePeople1] ON [dbo].[_Temp_FakePeople]
		--(
		--	[Id] ASC
		--) WITH (ONLINE = ON) ;
		--CREATE NONCLUSTERED INDEX [IX__Temp_FakePeople2] ON [dbo].[_Temp_FakePeople]
		--(
		--	[AlternateId] ASC
		--) WITH (ONLINE = ON) ;

	/*********************************************************************************/
	IF OBJECT_ID('tempdb..#FakePeople1', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #FakePeople1;
	END	
	IF OBJECT_ID('tempdb..#Client1', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #Client1;
	END			

	--UPDATE dbo._Temp_FakePeople 
	--SET AlternateId = NULL;
	
	--First the Girlies
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
	INTO #Client1
	FROM dbo.Client
	WHERE GenderId = 0;

	UPDATE FP
	SET AlternateId = ClientTable.Id
	FROM dbo._Temp_FakePeople FP
	INNER JOIN #FakePeople1 FP2 ON FP2.Id = FP.Id
	INNER JOIN #Client1 ClientTable ON ClientTable.RowNumber = FP2.RowNumber;
	
	UPDATE C
	SET FirstName = FP.Firstname
	, Surname = FP.Surname
	, DisplayName = LTRIM(RTRIM(ISNULL(Title, '') + ' ' + FP.Firstname + ' ' + FP.Surname))
	FROM dbo.Client C
	INNER JOIN dbo._Temp_FakePeople FP ON FP.AlternateId = C.Id
	WHERE C.GenderId = 0;
	
	/*********************************************************************************/
	--Now the Boysies
	IF OBJECT_ID('tempdb..#FakePeople2', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #FakePeople2;
	END	
	IF OBJECT_ID('tempdb..#Client2', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #Client2;
	END			

	--Now the Boysies
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
	INTO #Client2
	FROM dbo.Client
	WHERE GenderId = 1;

	UPDATE FP
	SET AlternateId = ClientTable.Id
	FROM dbo._Temp_FakePeople FP
	INNER JOIN #FakePeople2 FP2 ON FP2.Id = FP.Id
	INNER JOIN #Client2 ClientTable ON ClientTable.RowNumber = FP2.RowNumber
	
	UPDATE C
	SET FirstName = FP.Firstname
	, Surname = FP.Surname
	, DisplayName = LTRIM(RTRIM(ISNULL(Title, '') + ' ' + FP.Firstname + ' ' + FP.Surname))
	FROM dbo.Client C
	INNER JOIN dbo._Temp_FakePeople FP ON FP.AlternateId = C.Id
	WHERE C.GenderId = 1;
	
	
	/*********************************************************************************/
	--Now the Anom Data
	IF OBJECT_ID('tempdb..#FakePeople3', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #FakePeople3;
	END	
	IF OBJECT_ID('tempdb..#Client3', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #Client3;
	END			

	--Now the Anom Data with now Title
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
	INTO #Client3
	FROM dbo.Client
	WHERE GenderId = 9 AND FirstName = '(anonymised)' AND LTRIM(RTRIM(Title)) = '';

	UPDATE FP
	SET AlternateId = ClientTable.Id
	FROM dbo._Temp_FakePeople FP
	INNER JOIN #FakePeople3 FP2 ON FP2.Id = FP.Id
	INNER JOIN #Client3 ClientTable ON ClientTable.RowNumber = FP2.RowNumber
	
	UPDATE C
	SET FirstName = FP.Firstname
	, Surname = FP.Surname
	, DisplayName = LTRIM(RTRIM(ISNULL(Title, '') + ' ' + FP.Firstname + ' ' + FP.Surname))
	, GenderId = (CASE WHEN FP.SEX = 'M' THEN 1 ELSE 0 END)
	FROM dbo.Client C
	INNER JOIN dbo._Temp_FakePeople FP ON FP.AlternateId = C.Id
	WHERE C.GenderId = 9 AND C.FirstName = '(anonymised)' AND LTRIM(RTRIM(C.Title)) = '';
		
	/*********************************************************************************/
	--Now the Anom Data ('Reverend', 'Captain', 'Dr')
	IF OBJECT_ID('tempdb..#FakePeople4', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #FakePeople4;
	END	
	IF OBJECT_ID('tempdb..#Client4', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #Client4;
	END			

	--Now the Anom Data with now Title
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
	INTO #Client4
	FROM dbo.Client
	WHERE GenderId = 9 AND LTRIM(RTRIM(ISNULL(Title, ''))) IN('Reverend', 'Captain', 'Dr');

	UPDATE FP
	SET AlternateId = ClientTable.Id
	FROM dbo._Temp_FakePeople FP
	INNER JOIN #FakePeople4 FP2 ON FP2.Id = FP.Id
	INNER JOIN #Client4 ClientTable ON ClientTable.RowNumber = FP2.RowNumber
	
	UPDATE C
	SET FirstName = FP.Firstname
	, Surname = FP.Surname
	, DisplayName = LTRIM(RTRIM(Title + ' ' + FP.Firstname + ' ' + FP.Surname))
	, GenderId = (CASE WHEN FP.SEX = 'M' THEN 1 ELSE 0 END)
	FROM dbo.Client C
	INNER JOIN dbo._Temp_FakePeople FP ON FP.AlternateId = C.Id
	WHERE C.GenderId = 9 AND LTRIM(RTRIM(ISNULL(Title, ''))) IN('Reverend', 'Captain', 'Dr');
	
	/*********************************************************************************/
	--Now the Anom Data ('Prof', 'Major', 'Doctor', 'Rev')
	IF OBJECT_ID('tempdb..#FakePeople5', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #FakePeople5;
	END	
	IF OBJECT_ID('tempdb..#Client5', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #Client5;
	END			

	--Now the Anom Data with now Title
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
	INTO #Client5
	FROM dbo.Client
	WHERE GenderId = 9 AND LTRIM(RTRIM(ISNULL(Title, ''))) IN('Prof', 'Major', 'Doctor', 'Rev');

	UPDATE FP
	SET AlternateId = ClientTable.Id
	FROM dbo._Temp_FakePeople FP
	INNER JOIN #FakePeople5 FP2 ON FP2.Id = FP.Id
	INNER JOIN #Client5 ClientTable ON ClientTable.RowNumber = FP2.RowNumber
	
	UPDATE C
	SET FirstName = FP.Firstname
	, Surname = FP.Surname
	, DisplayName = LTRIM(RTRIM(ISNULL(Title, '') + ' ' + FP.Firstname + ' ' + FP.Surname))
	, GenderId = (CASE WHEN FP.SEX = 'M' THEN 1 ELSE 0 END)
	FROM dbo.Client C
	INNER JOIN dbo._Temp_FakePeople FP ON FP.AlternateId = C.Id
	WHERE C.GenderId = 9 AND LTRIM(RTRIM(Title)) IN('Prof', 'Major', 'Doctor', 'Rev');
	
	/*********************************************************************************/
	
	--Now the Anom Data (All the rest)
	IF OBJECT_ID('tempdb..#FakePeople6', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #FakePeople6;
	END	
	IF OBJECT_ID('tempdb..#Client6', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #Client6;
	END			

	--Now the Anom Data with no Title
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
	INTO #Client6
	FROM dbo.Client
	WHERE GenderId = 9;

	UPDATE FP
	SET AlternateId = ClientTable.Id
	FROM dbo._Temp_FakePeople FP
	INNER JOIN #FakePeople6 FP2 ON FP2.Id = FP.Id
	INNER JOIN #Client6 ClientTable ON ClientTable.RowNumber = FP2.RowNumber
	
	UPDATE C
	SET FirstName = FP.Firstname
	, Surname = FP.Surname
	, DisplayName = LTRIM(RTRIM(ISNULL(Title, '') + ' ' + FP.Firstname + ' ' + FP.Surname))
	, GenderId = (CASE WHEN FP.SEX = 'M' THEN 1 ELSE 0 END)
	FROM dbo.Client C
	INNER JOIN dbo._Temp_FakePeople FP ON FP.AlternateId = C.Id
	WHERE C.GenderId = 9;
	
	/*********************************************************************************/
	
	
	
	--Now the Client Email Addresses
	
	UPDATE E
	SET Address = FP.Email
	FROM dbo._Temp_FakePeople FP
	INNER JOIN dbo.ClientEmail CE ON CE.ClientId = FP.AlternateId
	INNER JOIN dbo.Email E ON E.Id = CE.EmailId
	WHERE AlternateId IS NOT NULL;
	
	
	/*********************************************************************************/
	
	--Update Client User Account
	UPDATE U
	SET U.[Name] = CL.DisplayName 
	FROM Client CL
	INNER JOIN [User] U ON U.Id = CL.UserId
	WHERE CL.UserId IS NOT NULL
	AND U.[Name] != CL.DisplayName;

	
	/*********************************************************************************/
	-- For Any that were missed
	UPDATE dbo.Client
	SET DisplayName = LTRIM(RTRIM(ISNULL(Title, '') + ' ' + ISNULL(FirstName, '') + ' ' + ISNULL(Surname, '')))
	WHERE DisplayName IS NULL
	
	/*********************************************************************************/
	
	--Now Licence Numbers

	--SELECT TOP 100  C.DisplayName
	--	, CL.LicenceNumber
	--	, SUBSTRING(ISNULL(CL.LicenceNumber,''),5,1)
	--	, ISNUMERIC(SUBSTRING(ISNULL(CL.LicenceNumber,''),5,1))
	--	, SUBSTRING(C.Surname,1,5)
	--	, SUBSTRING(C.Surname,1,4)
	--	, LEN(C.Surname)
	--	, LEN(CL.LicenceNumber)
	--	, UPPER(CASE WHEN LEN(C.Surname) > 4 AND LEN(ISNULL(CL.LicenceNumber,'')) > 5
	--		THEN SUBSTRING(C.Surname,1,5) + SUBSTRING(CL.LicenceNumber,6, LEN(CL.LicenceNumber) - 5)
	--		WHEN LEN(C.Surname) = 4 AND LEN(ISNULL(CL.LicenceNumber,'')) > 5
	--		THEN SUBSTRING(C.Surname,1,4) + '9' + SUBSTRING(CL.LicenceNumber,6, LEN(CL.LicenceNumber) - 5)
	--		WHEN LEN(C.Surname) = 3 AND LEN(ISNULL(CL.LicenceNumber,'')) > 5
	--		THEN SUBSTRING(C.Surname,1,3) + '99' + SUBSTRING(CL.LicenceNumber,6, LEN(CL.LicenceNumber) - 5)
	--		WHEN LEN(C.Surname) = 2 AND LEN(ISNULL(CL.LicenceNumber,'')) > 5
	--		THEN SUBSTRING(C.Surname,1,2) + '999' + SUBSTRING(CL.LicenceNumber,6, LEN(CL.LicenceNumber) - 5)
	--		ELSE CL.LicenceNumber
	--		END
	--		) NewLic
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
	FROM dbo.Client C
	INNER JOIN dbo.ClientLicence CL ON CL.ClientId = C.Id
	WHERE LEN(C.Surname) > 1
	AND LEN(ISNULL(CL.LicenceNumber,'')) > 1
	
	/*********************************************************************************/
	--Fake Numbers
	UPDATE CP
	SET CP.PhoneNumber = 'FAKE' + CAST(CP.Id AS VARCHAR)
	FROM dbo.Client C
	INNER JOIN ClientPhone CP ON CP.ClientId = C.Id
	WHERE CP.PhoneNumber != '(anonymised)'

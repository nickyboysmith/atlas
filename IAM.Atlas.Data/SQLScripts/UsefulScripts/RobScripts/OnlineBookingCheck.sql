--/****** Script for SelectTopNRows command from SSMS  ******/
--SELECT TOP (1000) [Id]
--      ,[LicenceNumber]
--      ,[DateTimeEntered]
--      ,[Browser]
--      ,[OperatingSystem]
--      ,[IPAddress]
--  FROM [dbo].[OnlineBookingLog]

--DECLARE @DateFrom AS DATETIME = CAST('2017-10-04 18:06:23.833' AS DATETIME);
DECLARE @DateFrom AS DATETIME = CAST('2017-10-06 06:25:37.310' AS DATETIME);
SELECT 
	NumberAccessedWebSite
	, NumberRegistered
	, NumberBooked
	, NumberBookedOnline
	, NumberPaid
	, NumberPaidOnline
	, NumberPaidOnlineAndIpadUsers
	, NumberPaidOnlineAndIphoneUsers
	, NumberPaidOnlineAndMacUsers
	, NumberPaidOnlineAndWindowsUsers
	, NumberPaidOnlineAndAndroidUsers
	, NumberPaidOnlineAndUnixUsers
	, FirstAttempt
	, LastAttempt
	, SafariUsers
	, ChromeUsers
	, InternetExplorerUsers
	, FirefoxUsers
	, MacUsers
	, WindowsUsers
	, iPadUsers
	, iPhoneUsers
	, AndroidUsers
	, UnixUsers
	, OtherComputerUsers
	, Total
	, NumberSafariUsersNotPaidOnline
	, CAST(SafariUsers AS FLOAT) / CAST(Total AS FLOAT) * 100 AS SafariUsersPercentage
	, CAST(ChromeUsers AS FLOAT) / CAST(Total AS FLOAT) * 100 AS ChromeUsersPercentage
	, CAST(InternetExplorerUsers AS FLOAT) / CAST(Total AS FLOAT) * 100 AS InternetExplorerUsersPercentage
	, CAST(FirefoxUsers AS FLOAT) / CAST(Total AS FLOAT) * 100 AS FirefoxUsersPercentage
	, CAST(OtherBrowserUsers AS FLOAT) / CAST(Total AS FLOAT) * 100 AS OtherBrowserUsersPercentage
	, CAST(MacUsers AS FLOAT) / CAST(YTotal AS FLOAT) * 100 AS MacUsersPercentage
	, CAST(WindowsUsers AS FLOAT) / CAST(YTotal AS FLOAT) * 100 AS WindowsUsersPercentage
	, CAST(iPadUsers AS FLOAT) / CAST(YTotal AS FLOAT) * 100 AS iPadUsersPercentage
	, CAST(iPhoneUsers AS FLOAT) / CAST(YTotal AS FLOAT) * 100 AS iPhoneUsersPercentage
	, CAST(AndroidUsers AS FLOAT) / CAST(YTotal AS FLOAT) * 100 AS AndroidUsersPercentage
	, CAST(UnixUsers AS FLOAT) / CAST(YTotal AS FLOAT) * 100 AS UnixUsersPercentage
	, CAST(OtherComputerUsers AS FLOAT) / CAST(YTotal AS FLOAT) * 100 AS OtherComputerUsersPercentage
FROM (
  SELECT 
		COUNT(*) AS NumberAccessedWebSite
		, SUM(CASE WHEN CLL.Id IS NULL THEN 0 ELSE 1 END) AS NumberRegistered
		, SUM(CASE WHEN COCL.Id IS NULL THEN 0 ELSE 1 END) AS NumberBooked
		, SUM(CASE WHEN COCL.Id IS NOT NULL   
					AND CL.Id IS NOT NULL
					AND COCL.AddedByUserId = CL.UserId
					THEN 1 ELSE 0 END) AS NumberBookedOnline
		, SUM(CASE WHEN CLP.Id IS NULL THEN 0 ELSE 1 END) AS NumberPaid
		, SUM(CASE WHEN CLP.Id IS NOT NULL 
					AND CL.Id IS NOT NULL
					AND P.CreatedByUserId = CL.UserId
					THEN 1 ELSE 0 END) AS NumberPaidOnline
		, SUM(CASE WHEN CLP.Id IS NOT NULL 
					AND CL.Id IS NOT NULL
					AND P.CreatedByUserId = CL.UserId
					AND Y.OperatingSystem IN ('iPad')
					THEN 1 ELSE 0 END) AS NumberPaidOnlineAndIpadUsers
		, SUM(CASE WHEN CLP.Id IS NOT NULL 
					AND CL.Id IS NOT NULL
					AND P.CreatedByUserId = CL.UserId
					AND Y.OperatingSystem IN ('iPhone')
					THEN 1 ELSE 0 END) AS NumberPaidOnlineAndIphoneUsers
		, SUM(CASE WHEN CLP.Id IS NOT NULL 
					AND CL.Id IS NOT NULL
					AND P.CreatedByUserId = CL.UserId
					AND Y.OperatingSystem IN ('Mac')
					THEN 1 ELSE 0 END) AS NumberPaidOnlineAndMacUsers
		, SUM(CASE WHEN CLP.Id IS NOT NULL 
					AND CL.Id IS NOT NULL
					AND P.CreatedByUserId = CL.UserId
					AND Y.OperatingSystem IN ('Windows')
					THEN 1 ELSE 0 END) AS NumberPaidOnlineAndWindowsUsers
		, SUM(CASE WHEN CLP.Id IS NOT NULL 
					AND CL.Id IS NOT NULL
					AND P.CreatedByUserId = CL.UserId
					AND Y.OperatingSystem IN ('Android')
					THEN 1 ELSE 0 END) AS NumberPaidOnlineAndAndroidUsers
		, SUM(CASE WHEN CLP.Id IS NOT NULL 
					AND CL.Id IS NOT NULL
					AND P.CreatedByUserId = CL.UserId
					AND Y.OperatingSystem IN ('UNIX')
					THEN 1 ELSE 0 END) AS NumberPaidOnlineAndUnixUsers
		, SUM(CASE WHEN CLP.Id IS NOT NULL 
					AND CL.Id IS NOT NULL
					AND P.CreatedByUserId != CL.UserId
					AND Z.Browser = 'Safari'
					THEN 1 ELSE 0 END) AS NumberSafariUsersNotPaidOnline
		, MIN(T.First) AS FirstAttempt
		, MAX(T.Last) AS LastAttempt
		, SUM(CASE WHEN Z.Browser = 'Safari' THEN 1 ELSE 0 END) AS SafariUsers
		, SUM(CASE WHEN Z.Browser = 'Chrome' THEN 1 ELSE 0 END) AS ChromeUsers
		, SUM(CASE WHEN Z.Browser = 'InternetExplorer' THEN 1 ELSE 0 END) AS InternetExplorerUsers
		, SUM(CASE WHEN Z.Browser = 'Firefox' THEN 1 ELSE 0 END) AS FirefoxUsers
		, SUM(CASE WHEN Z.Browser IN ('Safari','Chrome','InternetExplorer','Firefox') THEN 0 ELSE 1 END) AS OtherBrowserUsers
		, SUM(CASE WHEN Y.OperatingSystem = 'Mac' THEN 1 ELSE 0 END) AS MacUsers
		, SUM(CASE WHEN Y.OperatingSystem = 'Windows' THEN 1 ELSE 0 END) AS WindowsUsers
		, SUM(CASE WHEN Y.OperatingSystem = 'iPad' THEN 1 ELSE 0 END) AS iPadUsers
		, SUM(CASE WHEN Y.OperatingSystem = 'iPhone' THEN 1 ELSE 0 END) AS iPhoneUsers
		, SUM(CASE WHEN Y.OperatingSystem = 'Android' THEN 1 ELSE 0 END) AS AndroidUsers
		, SUM(CASE WHEN Y.OperatingSystem = 'UNIX' THEN 1 ELSE 0 END) AS UnixUsers
		, SUM(CASE WHEN Y.OperatingSystem IN ('Mac','Windows','iPad','iPhone','Android', 'UNIX') THEN 0 ELSE 1 END) AS OtherComputerUsers
		, COUNT(Z.LicenceNumber) Total
		, COUNT(Y.LicenceNumber) YTotal

  FROM (
	  SELECT [LicenceNumber], COUNT(*) CNT, MIN([DateTimeEntered]) AS First, MAX([DateTimeEntered]) AS Last
	  FROM [dbo].[OnlineBookingLog]
	  WHERE DateTimeEntered > @DateFrom
	  GROUP BY [LicenceNumber]
	  --ORDER BY [LicenceNumber]
	  ) T
  LEFT JOIN (
		SELECT [LicenceNumber]
				, Browser AS BrowserAndVersion
				, SUBSTRING(Browser, 1, CHARINDEX(' ', Browser, 1) - 1) AS Browser
				, REVERSE( LEFT( REVERSE(Browser), CHARINDEX(' ', REVERSE(Browser))-1 ) ) AS BrowserVersion
				, COUNT(*) AccessAttempts
		FROM [dbo].[OnlineBookingLog] OBL
		WHERE OBL.DateTimeEntered > @DateFrom
		GROUP BY [LicenceNumber], Browser
		--ORDER BY [LicenceNumber]
		) Z ON Z.LicenceNumber = T.LicenceNumber
  LEFT JOIN (
		SELECT [LicenceNumber]
				, OperatingSystem AS OperatingSystemAndVersion
				, (CASE WHEN CHARINDEX(' ', [OperatingSystem], 1) <= 0 THEN OperatingSystem
					ELSE SUBSTRING([OperatingSystem], 1, CHARINDEX(' ', [OperatingSystem], 1) - 1)
					END) AS OperatingSystem
				, (CASE WHEN CHARINDEX(' ',REVERSE(OperatingSystem)) > 0
					THEN REVERSE( LEFT( REVERSE(OperatingSystem), CHARINDEX(' ', REVERSE(OperatingSystem)) -1 ) ) 
					ELSE '' END)
					AS OperatingSystemVersion
				, COUNT(*) AccessAttempts
		FROM [dbo].[OnlineBookingLog] OBL
		WHERE OBL.DateTimeEntered > @DateFrom
		--AND OperatingSystem != 'Unknown'
		GROUP BY [LicenceNumber], [OperatingSystem]
		--ORDER BY [LicenceNumber]
		) Y ON Y.LicenceNumber = T.LicenceNumber
  LEFT JOIN dbo.ClientLicence CLL ON CLL.LicenceNumber = T.LicenceNumber
  LEFT JOIN dbo.CourseClient COCL ON COCL.ClientId = CLL.ClientId
  LEFT JOIN dbo.ClientPayment CLP ON CLP.ClientId = CLL.ClientId
  LEFT JOIN dbo.Client CL ON CL.Id = CLP.ClientId
  LEFT JOIN dbo.Payment P ON P.Id = CLP.PaymentId
  ) A
  
		--SELECT [LicenceNumber]
		--		, OperatingSystem AS OperatingSystemAndVersion
		--		, CHARINDEX(' ',OperatingSystem)
		--		, CHARINDEX(' ', REVERSE(OperatingSystem))
		--FROM [dbo].[OnlineBookingLog] OBL
		--WHERE OBL.DateTimeEntered > @DateFrom
		--GROUP BY [LicenceNumber], [OperatingSystem]
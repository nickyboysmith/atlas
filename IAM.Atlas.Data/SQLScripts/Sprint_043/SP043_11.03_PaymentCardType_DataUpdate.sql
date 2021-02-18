/*
	SCRIPT: PaymentCardType and PaymentCardValidationType Data Update
	Author: Robert Newnham
	Created: 09/09/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP043_11.03_PaymentCardType_DataUpdate.sql';
DECLARE @ScriptComments VARCHAR(800) = 'PaymentCardType Data Update';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		INSERT INTO [dbo].[PaymentCardValidationType] ([Name])
		SELECT DISTINCT T.[Name]
		FROM (
			SELECT 'VISA' AS [Name]
			UNION SELECT 'AMEX' AS [Name]
			UNION SELECT 'DINERS' AS [Name]
			UNION SELECT 'DISCOVER' AS [Name]
			UNION SELECT 'ENROUTE' AS [Name]
			UNION SELECT 'JCB' AS [Name]
			UNION SELECT 'MASTERCARD' AS [Name]
			UNION SELECT 'MAESTRO' AS [Name]
			UNION SELECT 'OTHER' AS [Name]
			) AS T
		LEFT JOIN [dbo].[PaymentCardValidationType] PCVT ON PCVT.[Name] = T.[Name]
		WHERE PCVT.Id IS NULL;
		
		/**************************************************************/
		INSERT INTO [dbo].[PaymentCardValidationTypeVariation] (
			PaymentCardValidationTypeId
			, IssuerIdentificationCharacters
			, CreatedByUserId
			, DateTimeCreated
			, [Disabled]
			)
		SELECT DISTINCT
			PCVT.Id											AS PaymentCardValidationTypeId
			, T.IssuerIdentificationCharacters				AS IssuerIdentificationCharacters
			, dbo.udfGetSystemUserId()						AS CreatedByUserId
			, GETDATE()										AS DateTimeCreated
			, 'False'										AS [Disabled]
		FROM (
			SELECT 'VISA' AS PaymentCardValidationType, '4' AS IssuerIdentificationCharacters
			UNION SELECT 'AMEX' AS PaymentCardValidationType, '34' AS IssuerIdentificationCharacters
			UNION SELECT 'AMEX' AS PaymentCardValidationType, '37' AS IssuerIdentificationCharacters
			UNION SELECT 'DINERS' AS PaymentCardValidationType, '30' AS IssuerIdentificationCharacters
			UNION SELECT 'DINERS' AS PaymentCardValidationType, '36' AS IssuerIdentificationCharacters
			UNION SELECT 'DINERS' AS PaymentCardValidationType, '38' AS IssuerIdentificationCharacters
			UNION SELECT 'DISCOVER' AS PaymentCardValidationType, '60110' AS IssuerIdentificationCharacters
			UNION SELECT 'DISCOVER' AS PaymentCardValidationType, '60112' AS IssuerIdentificationCharacters
			UNION SELECT 'DISCOVER' AS PaymentCardValidationType, '60113' AS IssuerIdentificationCharacters
			UNION SELECT 'DISCOVER' AS PaymentCardValidationType, '60114' AS IssuerIdentificationCharacters
			UNION SELECT 'DISCOVER' AS PaymentCardValidationType, '601174' AS IssuerIdentificationCharacters
			UNION SELECT 'DISCOVER' AS PaymentCardValidationType, '601177' AS IssuerIdentificationCharacters
			UNION SELECT 'DISCOVER' AS PaymentCardValidationType, '601178' AS IssuerIdentificationCharacters
			UNION SELECT 'DISCOVER' AS PaymentCardValidationType, '601179' AS IssuerIdentificationCharacters
			UNION SELECT 'DISCOVER' AS PaymentCardValidationType, '601186' AS IssuerIdentificationCharacters
			UNION SELECT 'DISCOVER' AS PaymentCardValidationType, '601187' AS IssuerIdentificationCharacters
			UNION SELECT 'DISCOVER' AS PaymentCardValidationType, '601188' AS IssuerIdentificationCharacters
			UNION SELECT 'DISCOVER' AS PaymentCardValidationType, '60119' AS IssuerIdentificationCharacters
			UNION SELECT 'DISCOVER' AS PaymentCardValidationType, '644' AS IssuerIdentificationCharacters
			UNION SELECT 'DISCOVER' AS PaymentCardValidationType, '65' AS IssuerIdentificationCharacters
			UNION SELECT 'ENROUTE' AS PaymentCardValidationType, '2014' AS IssuerIdentificationCharacters
			UNION SELECT 'ENROUTE' AS PaymentCardValidationType, '2149' AS IssuerIdentificationCharacters
			UNION SELECT 'JCB' AS PaymentCardValidationType, '3528' AS IssuerIdentificationCharacters
			UNION SELECT 'JCB' AS PaymentCardValidationType, '3589' AS IssuerIdentificationCharacters
			UNION SELECT 'MASTERCARD' AS PaymentCardValidationType, '51' AS IssuerIdentificationCharacters
			UNION SELECT 'MASTERCARD' AS PaymentCardValidationType, '52' AS IssuerIdentificationCharacters
			UNION SELECT 'MASTERCARD' AS PaymentCardValidationType, '53' AS IssuerIdentificationCharacters
			UNION SELECT 'MASTERCARD' AS PaymentCardValidationType, '54' AS IssuerIdentificationCharacters
			UNION SELECT 'MASTERCARD' AS PaymentCardValidationType, '55' AS IssuerIdentificationCharacters
			UNION SELECT 'MASTERCARD' AS PaymentCardValidationType, '22' AS IssuerIdentificationCharacters
			UNION SELECT 'MASTERCARD' AS PaymentCardValidationType, '23' AS IssuerIdentificationCharacters
			UNION SELECT 'MASTERCARD' AS PaymentCardValidationType, '24' AS IssuerIdentificationCharacters
			UNION SELECT 'MASTERCARD' AS PaymentCardValidationType, '25' AS IssuerIdentificationCharacters
			UNION SELECT 'MASTERCARD' AS PaymentCardValidationType, '26' AS IssuerIdentificationCharacters
			UNION SELECT 'MASTERCARD' AS PaymentCardValidationType, '27' AS IssuerIdentificationCharacters
			UNION SELECT 'MAESTRO' AS PaymentCardValidationType, '50' AS IssuerIdentificationCharacters
			UNION SELECT 'MAESTRO' AS PaymentCardValidationType, '56' AS IssuerIdentificationCharacters
			UNION SELECT 'MAESTRO' AS PaymentCardValidationType, '57' AS IssuerIdentificationCharacters
			UNION SELECT 'MAESTRO' AS PaymentCardValidationType, '58' AS IssuerIdentificationCharacters
			UNION SELECT 'MAESTRO' AS PaymentCardValidationType, '59' AS IssuerIdentificationCharacters
			UNION SELECT 'MAESTRO' AS PaymentCardValidationType, '60' AS IssuerIdentificationCharacters
			UNION SELECT 'MAESTRO' AS PaymentCardValidationType, '61' AS IssuerIdentificationCharacters
			UNION SELECT 'MAESTRO' AS PaymentCardValidationType, '62' AS IssuerIdentificationCharacters
			UNION SELECT 'MAESTRO' AS PaymentCardValidationType, '63' AS IssuerIdentificationCharacters
			UNION SELECT 'MAESTRO' AS PaymentCardValidationType, '64' AS IssuerIdentificationCharacters
			UNION SELECT 'MAESTRO' AS PaymentCardValidationType, '66' AS IssuerIdentificationCharacters
			UNION SELECT 'MAESTRO' AS PaymentCardValidationType, '67' AS IssuerIdentificationCharacters
			UNION SELECT 'MAESTRO' AS PaymentCardValidationType, '68' AS IssuerIdentificationCharacters
			UNION SELECT 'MAESTRO' AS PaymentCardValidationType, '69' AS IssuerIdentificationCharacters
			) T
		INNER JOIN [dbo].[PaymentCardValidationType] PCVT ON PCVT.[Name] = T.PaymentCardValidationType
		LEFT JOIN [dbo].[PaymentCardValidationTypeVariation] PCVTV ON PCVTV.PaymentCardValidationTypeId = PCVT.Id	
																	AND PCVTV.IssuerIdentificationCharacters = T.IssuerIdentificationCharacters
		WHERE PCVTV.Id IS NULL
		;
		/**************************************************************/
		INSERT INTO [dbo].[PaymentCardValidationTypeLength] (
			PaymentCardValidationTypeId
			, ValidLength
			, CreatedByUserId
			, DateTimeCreated
			, [Disabled]
			)
		SELECT DISTINCT
			PCVT.Id											AS PaymentCardValidationTypeId
			, T.ValidLength									AS ValidLength
			, dbo.udfGetSystemUserId()						AS CreatedByUserId
			, GETDATE()										AS DateTimeCreated
			, 'False'										AS [Disabled]
		FROM (
			SELECT 'VISA' AS PaymentCardValidationType, 13 AS ValidLength
			UNION SELECT 'VISA' AS PaymentCardValidationType, 16 AS ValidLength
			UNION SELECT 'VISA' AS PaymentCardValidationType, 19 AS ValidLength
			UNION SELECT 'AMEX' AS PaymentCardValidationType, 15 AS ValidLength
			UNION SELECT 'DINERS' AS PaymentCardValidationType, 14 AS ValidLength
			UNION SELECT 'DINERS' AS PaymentCardValidationType, 15 AS ValidLength
			UNION SELECT 'DINERS' AS PaymentCardValidationType, 16 AS ValidLength
			UNION SELECT 'DINERS' AS PaymentCardValidationType, 17 AS ValidLength
			UNION SELECT 'DINERS' AS PaymentCardValidationType, 18 AS ValidLength
			UNION SELECT 'DINERS' AS PaymentCardValidationType, 19 AS ValidLength
			UNION SELECT 'DISCOVER' AS PaymentCardValidationType, 16 AS ValidLength
			UNION SELECT 'DISCOVER' AS PaymentCardValidationType, 17 AS ValidLength
			UNION SELECT 'DISCOVER' AS PaymentCardValidationType, 18 AS ValidLength
			UNION SELECT 'DISCOVER' AS PaymentCardValidationType, 19 AS ValidLength
			UNION SELECT 'ENROUTE' AS PaymentCardValidationType, 15 AS ValidLength
			UNION SELECT 'JCB' AS PaymentCardValidationType, 16 AS ValidLength
			UNION SELECT 'JCB' AS PaymentCardValidationType, 17 AS ValidLength
			UNION SELECT 'JCB' AS PaymentCardValidationType, 18 AS ValidLength
			UNION SELECT 'JCB' AS PaymentCardValidationType, 19 AS ValidLength
			UNION SELECT 'MASTERCARD' AS PaymentCardValidationType, 16 AS ValidLength
			UNION SELECT 'MAESTRO' AS PaymentCardValidationType, 12 AS ValidLength
			UNION SELECT 'MAESTRO' AS PaymentCardValidationType, 13 AS ValidLength
			UNION SELECT 'MAESTRO' AS PaymentCardValidationType, 14 AS ValidLength
			UNION SELECT 'MAESTRO' AS PaymentCardValidationType, 15 AS ValidLength
			UNION SELECT 'MAESTRO' AS PaymentCardValidationType, 16 AS ValidLength
			UNION SELECT 'MAESTRO' AS PaymentCardValidationType, 17 AS ValidLength
			UNION SELECT 'MAESTRO' AS PaymentCardValidationType, 18 AS ValidLength
			UNION SELECT 'MAESTRO' AS PaymentCardValidationType, 19 AS ValidLength
			) T
		INNER JOIN [dbo].[PaymentCardValidationType] PCVT ON PCVT.[Name] = T.PaymentCardValidationType
		LEFT JOIN [dbo].[PaymentCardValidationTypeLength] PCVTL ON PCVTL.PaymentCardValidationTypeId = PCVT.Id	
																AND PCVTL.ValidLength = T.ValidLength
		WHERE PCVTL.Id IS NULL
		;
		
		/**************************************************************/
		
		IF OBJECT_ID('tempdb..#PaymentCardType', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #PaymentCardType;
		END

		SELECT DISTINCT T.[Name], T.DisplayName, T.ValidationType
		INTO #PaymentCardType
		FROM (
			SELECT 'DELTA' AS [Name], 'Visa Debit' AS DisplayName, 'VISA' AS ValidationType
			UNION SELECT 'ELECTRON' AS [Name], 'Visa Electron' AS DisplayName, 'VISA' AS ValidationType
			UNION SELECT 'VISA' AS [Name], 'Visa' AS DisplayName, 'VISA' AS ValidationType
			UNION SELECT 'MASTERCARD' AS [Name], 'Mastercard' AS DisplayName, 'MASTERCARD' AS ValidationType
			UNION SELECT 'MASTERCARDDEBIT' AS [Name], 'Mastercard Debit' AS DisplayName, 'MASTERCARD' AS ValidationType
			UNION SELECT 'DINERS' AS [Name], 'Diners Club' AS DisplayName, 'DINERS' AS ValidationType
			UNION SELECT 'MAESTRO' AS [Name], 'Maestro' AS DisplayName, 'MAESTRO' AS ValidationType
			UNION SELECT 'DISCOVER' AS [Name], 'Discover' AS DisplayName, 'DISCOVER' AS ValidationType
			UNION SELECT 'AMEX' AS [Name], 'American Express' AS DisplayName, 'AMEX' AS ValidationType
			UNION SELECT 'JCB' AS [Name], 'JCB' AS DisplayName, 'JCB' AS ValidationType
			UNION SELECT 'OTHERCREDITCARD' AS [Name], 'Other Credit Card' AS DisplayName, 'OTHER' AS ValidationType
			UNION SELECT 'OTHERDEBITCARD' AS [Name], 'Other Debit Card' AS DisplayName, 'OTHER' AS ValidationType
			) AS T

		INSERT INTO [dbo].[PaymentCardType] ([Name], DisplayName, PaymentCardValidationTypeId)
		SELECT T.[Name], T.DisplayName, PCVT.Id AS PaymentCardValidationTypeId
		FROM #PaymentCardType AS T
		INNER JOIN [dbo].[PaymentCardValidationType] PCVT ON PCVT.[Name] = T.ValidationType
		LEFT JOIN [dbo].[PaymentCardType] PCT ON PCT.[Name] = T.[Name]
		WHERE PCT.Id IS NULL;
		
		UPDATE PCT
		SET PCT.DisplayName = T.DisplayName
		, PCT.PaymentCardValidationTypeId = PCVT.Id
		FROM #PaymentCardType AS T
		INNER JOIN [dbo].[PaymentCardValidationType] PCVT ON PCVT.[Name] = T.ValidationType
		INNER JOIN [dbo].[PaymentCardType] PCT ON PCT.[Name] = T.[Name]
		WHERE ISNULL(PCT.DisplayName,'') != T.DisplayName
		OR ISNULL(PCT.PaymentCardValidationTypeId,0) != PCVT.Id;
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
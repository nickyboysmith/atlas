/*
	SCRIPT: Populate DORSForceRegion Table
	Author: Robert Newnham
	Created: 16/10/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP045_01.02_PopulateTable_DORSForceRegion.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Populate DORSForceRegion Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		INSERT INTO dbo.Region([Name])
		SELECT DISTINCT T.[Name] 
		FROM (
			SELECT 'Bedfordshire' AS [Name]
			UNION SELECT 'City of London' AS [Name]
			UNION SELECT 'Cumbria' AS [Name]
			UNION SELECT 'Derbyshire' AS [Name]
			UNION SELECT 'Dorset' AS [Name]
			UNION SELECT 'Carmarthenshire' AS [Name]
			UNION SELECT 'Ceredigion' AS [Name]
			UNION SELECT 'Carmarthenshire' AS [Name]
			UNION SELECT 'Pembrokeshire' AS [Name]
			UNION SELECT 'Powys' AS [Name]
			UNION SELECT 'Hampshire' AS [Name]
			UNION SELECT 'Hertfordshire' AS [Name]
			UNION SELECT 'East Riding of Yorkshire' AS [Name]
			UNION SELECT 'Kingston upon Hull' AS [Name]
			UNION SELECT 'North East Lincolnshire' AS [Name]
			UNION SELECT 'North Lincolnshire' AS [Name]
			UNION SELECT 'Kent' AS [Name]
			UNION SELECT 'Lancashire' AS [Name]
			UNION SELECT 'Leicestershire' AS [Name]
			UNION SELECT 'Lincolnshire' AS [Name]
			UNION SELECT 'London' AS [Name]
			UNION SELECT 'Anglesey' AS [Name]
			UNION SELECT 'Conwy' AS [Name]
			UNION SELECT 'Denbighshire' AS [Name]
			UNION SELECT 'Flintshire' AS [Name]
			UNION SELECT 'Gwynedd and Wrexham' AS [Name]
			UNION SELECT 'North Yorkshire' AS [Name]
			UNION SELECT 'Northamptonshire' AS [Name]
			UNION SELECT 'Tyne and Wear' AS [Name]
			UNION SELECT 'Nottinghamshire' AS [Name]
			UNION SELECT 'Northern Ireland' AS [Name]
			UNION SELECT 'Scotland' AS [Name]
			UNION SELECT 'Surrey' AS [Name]
			UNION SELECT 'Buckinghamshire' AS [Name]
			UNION SELECT 'Oxfordshire' AS [Name]
			UNION SELECT 'Warwickshire' AS [Name]
			UNION SELECT 'Worcestershire' AS [Name]
			UNION SELECT 'Swindon' AS [Name]
			UNION SELECT 'Wiltshire' AS [Name]
		) T
		LEFT JOIN dbo.Region R ON R.[Name] = T.[Name]
		WHERE R.Id IS NULL;

		INSERT INTO dbo.DORSForceRegion([DORSForceId], [RegionId])
		SELECT DISTINCT
			DF.Id				AS [DORSForceId]	
			, R.[Id]			AS [RegionId]
		FROM DORSForce DF
		CROSS JOIN Region R
		WHERE 
		((DF.[Name] = 'CAMBRIDGESHIRE CONSTABULARY' AND R.[Name] = 'Cambridgeshire')
			OR (DF.[Name] = 'CHESHIRE' AND R.[Name] = 'Cheshire')
			OR (DF.[Name] = 'CLEVELAND POLICE' AND R.[Name] = 'Cleveland')
			OR (DF.[Name] = 'DEVON AND CORNWALL CONSTABULARY' AND R.[Name] = 'Cornwall')
			OR (DF.[Name] = 'DEVON AND CORNWALL CONSTABULARY' AND R.[Name] = 'Devon')
			OR (DF.[Name] = 'DURHAM CONSTABULARY' AND R.[Name] = 'Durham')
			OR (DF.[Name] = 'ESSEX POLICE' AND R.[Name] = 'Essex')
			OR (DF.[Name] = 'GLOUCESTERSHIRE CONSTABULARY' AND R.[Name] = 'Gloucestershire')
			OR (DF.[Name] = 'GREATER MANCHESTER POLICE' AND R.[Name] = 'Greater Manchester')
			OR (DF.[Name] = 'GWENT POLICE' AND R.[Name] = 'Gwent')
			OR (DF.[Name] = 'MERSEYSIDE POLICE' AND R.[Name] = 'Merseyside')
			OR (DF.[Name] = 'NORFOLK CONSTABULARY' AND R.[Name] = 'Norfolk')
			OR (DF.[Name] = 'SOUTH WALES POLICE' AND R.[Name] = 'South Wales')
			OR (DF.[Name] = 'SOUTH YORKSHIRE POLICE' AND R.[Name] = 'South Yorkshire')
			OR (DF.[Name] = 'STAFFORDSHIRE POLICE' AND R.[Name] = 'Staffordshire')
			OR (DF.[Name] = 'SUFFOLK CONSTABULARY' AND R.[Name] = 'Suffolk')
			OR (DF.[Name] = 'SUSSEX POLICE' AND R.[Name] = 'Sussex')
			OR (DF.[Name] = 'WEST MIDLANDS POLICE' AND R.[Name] = 'West Midlands')
			OR (DF.[Name] = 'WEST YORKSHIRE POLICE' AND R.[Name] = 'West Yorkshire')
			OR (DF.[Name] = 'AVON AND SOMERSET CONSTABULARY' AND R.[Name] = 'Avon & Somerset')
			OR (DF.[Name] = 'BEDFORDSHIRE POLICE' AND R.[Name] = 'Bedfordshire')
			OR (DF.[Name] = 'CITY OF LONDON POLICE' AND R.[Name] = 'City of London')
			OR (DF.[Name] = 'CUMBRIA CONSTABULARY' AND R.[Name] = 'Cumbria')
			OR (DF.[Name] = 'DERBYSHIRE CONSTABULARY' AND R.[Name] = 'Derbyshire')
			OR (DF.[Name] = 'DORSET POLICE' AND R.[Name] = 'Dorset')
			OR (DF.[Name] = 'DYFED-POWYS POLICE' AND R.[Name] = 'Carmarthenshire')
			OR (DF.[Name] = 'DYFED-POWYS POLICE' AND R.[Name] = 'Pembrokeshire')
			OR (DF.[Name] = 'DYFED-POWYS POLICE' AND R.[Name] = 'Powys')
			OR (DF.[Name] = 'HAMPSHIRE CONSTABULARY' AND R.[Name] = 'Hampshire')
			OR (DF.[Name] = 'HERTFORDSHIRE CONSTABULARY' AND R.[Name] = 'Hertfordshire')
			OR (DF.[Name] = 'HUMBERSIDE POLICE' AND R.[Name] = 'East Riding of Yorkshire')
			OR (DF.[Name] = 'HUMBERSIDE POLICE' AND R.[Name] = 'Kingston upon Hull')
			OR (DF.[Name] = 'HUMBERSIDE POLICE' AND R.[Name] = 'North East Lincolnshire')
			OR (DF.[Name] = 'HUMBERSIDE POLICE' AND R.[Name] = 'North Lincolnshire')
			OR (DF.[Name] = 'KENT COUNTY POLICE' AND R.[Name] = 'Kent')
			OR (DF.[Name] = 'LANCASHIRE CONSTABULARY' AND R.[Name] = 'Lancashire')
			OR (DF.[Name] = 'LEICESTERSHIRE CONSTABULARY' AND R.[Name] = 'Leicestershire')
			OR (DF.[Name] = 'LINCOLNSHIRE POLICE' AND R.[Name] = 'Lincolnshire')
			OR (DF.[Name] = 'METROPOLITAN POLICE' AND R.[Name] = 'London')
			OR (DF.[Name] = 'NORTH WALES POLICE' AND R.[Name] = 'Anglesey')
			OR (DF.[Name] = 'NORTH WALES POLICE' AND R.[Name] = 'Conwy')
			OR (DF.[Name] = 'NORTH WALES POLICE' AND R.[Name] = 'Denbighshire')
			OR (DF.[Name] = 'NORTH WALES POLICE' AND R.[Name] = 'Flintshire')
			OR (DF.[Name] = 'NORTH WALES POLICE' AND R.[Name] = 'Gwynedd and Wrexham')
			OR (DF.[Name] = 'NORTH YORKSHIRE POLICE' AND R.[Name] = 'North Yorkshire')
			OR (DF.[Name] = 'NORTHAMPTONSHIRE POLICE' AND R.[Name] = 'Northamptonshire')
			OR (DF.[Name] = 'NORTHUMBRIA POLICE' AND R.[Name] = 'Tyne and Wear')
			OR (DF.[Name] = 'NOTTINGHAMSHIRE POLICE' AND R.[Name] = 'Nottinghamshire')
			OR (DF.[Name] = 'POLICE SERVICE NORTHERN IRELAND' AND R.[Name] = 'Northern Ireland')
			OR (DF.[Name] = 'SCOTLAND RSS' AND R.[Name] = 'Scotland')
			OR (DF.[Name] = 'SURREY POLICE' AND R.[Name] = 'Surrey')
			OR (DF.[Name] = 'THAMES VALLEY POLICE' AND R.[Name] = 'Buckinghamshire')
			OR (DF.[Name] = 'THAMES VALLEY POLICE' AND R.[Name] = 'Oxfordshire')
			OR (DF.[Name] = 'WARWICKSHIRE POLICE' AND R.[Name] = 'Warwickshire')
			OR (DF.[Name] = 'WEST MERCIA CONSTABULARY' AND R.[Name] = 'Worcestershire')
			OR (DF.[Name] = 'WILTSHIRE CONSTABULARY' AND R.[Name] = 'Swindon')
			OR (DF.[Name] = 'WILTSHIRE CONSTABULARY' AND R.[Name] = 'Wiltshire')
		)
		AND NOT EXISTS (SELECT * 
						FROM dbo.DORSForceRegion DFC 
						WHERE DFC.[DORSForceId] = DF.Id
						AND DFC.[RegionId] = R.[Id]
						)
		;
		/**************************************************************************************************************************/
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END

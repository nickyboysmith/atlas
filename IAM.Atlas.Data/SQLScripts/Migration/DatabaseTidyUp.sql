/* Database Tidy Up */

--/*
		IF OBJECT_ID('tempdb..#Organisation', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #Organisation;
		END

		SELECT [OldName] AS [OldName]
				, [Name] AS [Name]
				, [Title] AS [Title]
				, GetDate() AS [CreationTime]
				, 'True' AS [Active]
				, [dbo].[udfGetSystemUserId]() AS [CreatedByUserId]
		INTO #Organisation
		FROM (
			SELECT 'Hartlepool Borough Council' AS [OldName], 'Hartlepool Borough Council' AS [Name], 'Hartlepool County Council' AS [Title]
			UNION
			SELECT 'Essex County Council' AS [OldName], 'Essex County Council' AS [Name], 'Essex County Council' AS [Title]
			UNION
			SELECT 'Gloucestershire County Council' AS [OldName], 'Gloucestershire County Council' AS [Name], 'Gloucestershire County Council' AS [Title]
			UNION
			SELECT 'DriveSafe' AS [OldName], 'DriveSafe' AS [Name], 'DriveSafe' AS [Title]
			UNION
			SELECT 'Norfolk County Council' AS [OldName], 'Norfolk County Council' AS [Name], 'Norfolk County Council' AS [Title]
			UNION
			SELECT 'Staffordshire County Council' AS [OldName], 'Staffordshire County Council' AS [Name], 'Staffordshire County Council' AS [Title]
			UNION
			SELECT 'Sussex County Council' AS [OldName], 'Sussex County Council' AS [Name], 'Sussex County Council' AS [Title]
			UNION
			SELECT 'PDS Ltd' AS [OldName], 'IAM RoadSmart' AS [Name], 'IAM RoadSmart' AS [Title]
			) Orgs

/*
		UPDATE O
		SET O.[Name] = Orgs.[Name]
		FROM [dbo].[Organisation] O
		INNER JOIN #Organisation Orgs ON Orgs.[OldName] = O.[Name]
										OR Orgs.[Title] = O.[Name]
		WHERE Orgs.[Name] != O.[Name]

--*/



/*
	--The following should not be assigned to Orgs they are Sys Admin Only
	DELETE AMIO
	FROM [dbo].[AdministrationMenuItemOrganisation] AMIO
	INNER JOIN [dbo].[AdministrationMenuItem] AMI ON AMI.Id = AMIO.[AdminMenuItemId]
	WHERE AMI.Title IN ('Organisation System Configuration'
					, 'Public Holiday'
					, 'Connection Settings'
					, 'Admin Menu Control'
					);
	
	DELETE AMGI
	FROM [dbo].[AdministrationMenuGroupItem] AMGI
	INNER JOIN [AdministrationMenuItem] AMI ON AMGI.[AdminMenuItemId] = AMI.Id
	WHERE AMI.Title = 'Blocked Outgoing Email Addresses'
	AND AMI.Controller = 'EmailBlockedOutgingAddressCtrl';
	
	DELETE AMIO
	FROM [dbo].[AdministrationMenuItemOrganisation] AMIO
	INNER JOIN [AdministrationMenuItem] AMI ON AMIO.[AdminMenuItemId] = AMI.Id
	WHERE AMI.Title = 'Blocked Outgoing Email Addresses'
	AND AMI.Controller = 'EmailBlockedOutgingAddressCtrl';
	
	DELETE AMIU
	FROM [dbo].[AdministrationMenuItemUser] AMIU
	INNER JOIN [AdministrationMenuItem] AMI ON AMIU.[AdminMenuItemId] = AMI.Id
	WHERE AMI.Title = 'Blocked Outgoing Email Addresses'
	AND AMI.Controller = 'EmailBlockedOutgingAddressCtrl';
	
	DELETE [AdministrationMenuItem]
	WHERE Title = 'Blocked Outgoing Email Addresses'
	AND Controller = 'EmailBlockedOutgingAddressCtrl';
	-------------------------------------------------------------------------------------------------------
	DELETE AMGI
	FROM [dbo].[AdministrationMenuGroupItem] AMGI
	INNER JOIN [AdministrationMenuItem] AMI ON AMGI.[AdminMenuItemId] = AMI.Id
	WHERE AMI.Title = 'Course Trainers'
	AND AMI.Controller = 'CourseTrainersCtrl';
	
	DELETE AMIO
	FROM [dbo].[AdministrationMenuItemOrganisation] AMIO
	INNER JOIN [AdministrationMenuItem] AMI ON AMIO.[AdminMenuItemId] = AMI.Id
	WHERE AMI.Title = 'Course Trainers'
	AND AMI.Controller = 'CourseTrainersCtrl';
	
	DELETE AMIU
	FROM [dbo].[AdministrationMenuItemUser] AMIU
	INNER JOIN [AdministrationMenuItem] AMI ON AMIU.[AdminMenuItemId] = AMI.Id
	WHERE AMI.Title = 'Course Trainers'
	AND AMI.Controller = 'CourseTrainersCtrl';
	
	DELETE [AdministrationMenuItem]
	WHERE Title = 'Course Trainers'
	AND Controller = 'CourseTrainersCtrl';
	-----------------------------------------------------------------------------------------------------------
	--SELECT AMG.Title AS GroupTitle, AMI.Title AS ItemTitle
	--FROM [AdministrationMenuItem] AMI
	--LEFT JOIN [dbo].[AdministrationMenuGroupItem] AMGI ON AMGI.[AdminMenuItemId] = AMI.Id
	--LEFT JOIN [dbo].[AdministrationMenuGroup] AMG ON AMG.Id = AMGI.[AdminMenuGroupId]
	--ORDER BY AMG.Title, AMI.Title

	--Initial Setup of Admin Menu Items
	INSERT INTO [dbo].[AdministrationMenuItemOrganisation] (OrganisationId, AdminMenuItemId)
	SELECT DISTINCT O.Id AS OrganisationId, AMI.Id AS AdminMenuItemId
	FROM Organisation O
	INNER JOIN [dbo].[OrganisationAdminUser] OAU ON OAU.OrganisationId = O.Id
	INNER JOIN #Organisation Orgs ON Orgs.[OldName] = O.[Name]
	, [AdministrationMenuItem] AMI
	WHERE AMI.Title IN (
						'Add Course'
						, 'Course Type'
						, 'Course Type Categories'
						, 'Venue'
						, 'Connection Details'
						, 'Document Management'
						, 'Letter Template Maintenance'
						, 'Referring Authority Details'
						, 'Payment Provider'
						, 'Payment Type'
						, 'Add Report'
						, 'Data View Maintenance'
						, 'Report Categories'
						, 'Reports'
						, 'Blocked Outgoing Email Addresses'
						, 'Dashboard Meter Maintenance & Exposure'
						, 'Delete Marked Clients'
						, 'Delete Marked Documents'
						, 'Document Statistics'
						, 'DORS Control'
						, 'Meter Availability'
						, 'Organisation Self Configuration'
						, 'Special Requirements'
						, 'System Control Configuration'
						, 'System Support Users'
						, 'System Tasks'
						, 'Assign Course Types'
						, 'Documents for All Trainers'
						, 'Trainer Search'
						, 'Trainer Settings'
						, 'User Maintenance'
						)
		AND NOT EXISTS (SELECT * 
						FROM [dbo].[AdministrationMenuItemOrganisation] A
						WHERE A.OrganisationId = O.Id
						AND A.AdminMenuItemId = AMI.Id)


	--*/

	
		IF OBJECT_ID('tempdb..#RefAuth', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #RefAuth;
		END

		SELECT O.Id AS OrgId
			, O.Name AS OrgName
			, RefAuth.RefAuthName
			, RefAuth.OrgName AS RefAuthOrgName
			, Orgs.[OldName]
		INTO #RefAuth
		FROM (
			SELECT 'AVON AND SOMERSET CONSTABULARY' AS RefAuthName, 'N/A' AS OrgName
			UNION SELECT 'BEDFORDSHIRE POLICE' AS RefAuthName, 'N/A' AS OrgName
			UNION SELECT 'CAMBRIDGESHIRE CONSTABULARY' AS RefAuthName, 'N/A' AS OrgName
			UNION SELECT 'CHESHIRE' AS RefAuthName, 'N/A' AS OrgName
			UNION SELECT 'CITY OF LONDON POLICE' AS RefAuthName, 'N/A' AS OrgName
			UNION SELECT 'CLEVELAND POLICE' AS RefAuthName, 'Hartlepool County Council' AS OrgName
			UNION SELECT 'CUMBRIA CONSTABULARY' AS RefAuthName, 'N/A' AS OrgName
			UNION SELECT 'DERBYSHIRE CONSTABULARY' AS RefAuthName, 'N/A' AS OrgName
			UNION SELECT 'DEVON AND CORNWALL CONSTABULARY' AS RefAuthName, 'N/A' AS OrgName
			UNION SELECT 'DORSET POLICE' AS RefAuthName, 'N/A' AS OrgName
			UNION SELECT 'DURHAM CONSTABULARY' AS RefAuthName, 'Hartlepool County Council' AS OrgName
			UNION SELECT 'DYFED-POWYS POLICE' AS RefAuthName, 'N/A' AS OrgName
			UNION SELECT 'ESSEX POLICE' AS RefAuthName, 'Essex County Council' AS OrgName
			UNION SELECT 'GLOUCESTERSHIRE CONSTABULARY' AS RefAuthName, 'Gloucestershire County Council' AS OrgName
			UNION SELECT 'GREATER MANCHESTER POLICE' AS RefAuthName, 'DriveSafe' AS OrgName
			UNION SELECT 'GWENT POLICE' AS RefAuthName, 'N/A' AS OrgName
			UNION SELECT 'HAMPSHIRE CONSTABULARY' AS RefAuthName, 'N/A' AS OrgName
			UNION SELECT 'HERTFORDSHIRE CONSTABULARY' AS RefAuthName, 'N/A' AS OrgName
			UNION SELECT 'HUMBERSIDE POLICE' AS RefAuthName, 'N/A' AS OrgName
			UNION SELECT 'KENT COUNTY POLICE' AS RefAuthName, 'N/A' AS OrgName
			UNION SELECT 'LANCASHIRE CONSTABULARY' AS RefAuthName, 'N/A' AS OrgName
			UNION SELECT 'LEICESTERSHIRE CONSTABULARY' AS RefAuthName, 'N/A' AS OrgName
			UNION SELECT 'LINCOLNSHIRE POLICE' AS RefAuthName, 'N/A' AS OrgName
			UNION SELECT 'MERSEYSIDE POLICE' AS RefAuthName, 'N/A' AS OrgName
			UNION SELECT 'METROPOLITAN POLICE' AS RefAuthName, 'N/A' AS OrgName
			UNION SELECT 'NORFOLK CONSTABULARY' AS RefAuthName, 'Norfolk County Council' AS OrgName
			UNION SELECT 'NORTH WALES POLICE' AS RefAuthName, 'N/A' AS OrgName
			UNION SELECT 'NORTH YORKSHIRE POLICE' AS RefAuthName, 'N/A' AS OrgName
			UNION SELECT 'NORTHAMPTONSHIRE POLICE' AS RefAuthName, 'N/A' AS OrgName
			UNION SELECT 'NORTHUMBRIA POLICE' AS RefAuthName, 'N/A' AS OrgName
			UNION SELECT 'NOTTINGHAMSHIRE POLICE' AS RefAuthName, 'N/A' AS OrgName
			UNION SELECT 'POLICE SERVICE NORTHERN IRELAND' AS RefAuthName, 'N/A' AS OrgName
			UNION SELECT 'SCOTLAND RSS' AS RefAuthName, 'N/A' AS OrgName
			UNION SELECT 'SOUTH WALES POLICE' AS RefAuthName, 'N/A' AS OrgName
			UNION SELECT 'SOUTH YORKSHIRE POLICE' AS RefAuthName, 'N/A' AS OrgName
			UNION SELECT 'STAFFORDSHIRE POLICE' AS RefAuthName, 'Staffordshire County Council' AS OrgName
			UNION SELECT 'SUFFOLK CONSTABULARY' AS RefAuthName, 'N/A' AS OrgName
			UNION SELECT 'SURREY POLICE' AS RefAuthName, 'N/A' AS OrgName
			UNION SELECT 'SUSSEX POLICE' AS RefAuthName, 'Sussex County Council' AS OrgName
			UNION SELECT 'THAMES VALLEY POLICE' AS RefAuthName, 'N/A' AS OrgName
			UNION SELECT 'WARWICKSHIRE POLICE' AS RefAuthName, 'N/A' AS OrgName
			UNION SELECT 'WEST MERCIA CONSTABULARY' AS RefAuthName, 'N/A' AS OrgName
			UNION SELECT 'WEST MIDLANDS POLICE' AS RefAuthName, 'N/A' AS OrgName
			UNION SELECT 'WEST YORKSHIRE POLICE' AS RefAuthName, 'N/A' AS OrgName
			UNION SELECT 'WILTSHIRE CONSTABULARY' AS RefAuthName, 'N/A' AS OrgName
			UNION SELECT 'FANTASIA SAFETY SERVICES' AS RefAuthName, 'IAM RoadSmart' AS OrgName
		) RefAuth
		LEFT JOIN #Organisation Orgs ON Orgs.[OldName] = RefAuth.OrgName
									OR Orgs.[Title] = RefAuth.OrgName
		LEFT JOIN [dbo].[Organisation] O ON O.[Name] = Orgs.[OldName]
		;

		--INSERT INTO [dbo].[ReferringAuthority] (
		--										[Name]
		--										, [Description]
		--										, [Disabled]
		--										, [AssociatedOrganisationId]
		--										, [CreatedByUserId]
		--										, [DateCreated]
		--										, [UpdatedByUserId]
		--										, [DateUpdated]
		--										)
		SELECT 		
				RA.RefAuthName AS [Name]
				, RA.RefAuthName AS  [Description]
				, 'False' AS [Disabled]
				, RA.OrgId AS[AssociatedOrganisationId]
				, [dbo].[udfGetSystemUserId]() AS [CreatedByUserId]
				, GetDate() AS [DateCreated]
				, [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId]
				, GetDate() AS [DateUpdated]
		FROM #RefAuth RA
		WHERE NOT EXISTS (SELECT * FROM [ReferringAuthority] R WHERE R.[Name] = RA.RefAuthName);



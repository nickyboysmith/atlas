

	BEGIN
		IF OBJECT_ID('tempdb..#TaskAction', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #TaskAction;
		END

		SELECT *
		INTO #TaskAction
		FROM (
			SELECT
				'Client – Expired Critical Date' AS [Name]
				, 'Client with an expired DORS critical date.' AS [Description]
				, 2 AS PriorityNumber
				, CAST('True' AS BIT) AS AssignToOrganisation
				, CAST('False' AS BIT) AS AssignToOrganisationAdminstrators
				, CAST('False' AS BIT) AS AssignToOrganisationSupportGroup
				, CAST('False' AS BIT) AS AssignToAtlasSytemAdministrators
				, CAST('False' AS BIT) AS AssignToAtlasSystemSupportGroup
			UNION
			SELECT
				'Client - Booked and Paid Online - Additional Requirements' AS [Name]
				, 'Client who has booked and paid online and has Additional Requirements' AS [Description]
				, 3 AS PriorityNumber
				, CAST('True' AS BIT) AS AssignToOrganisation
				, CAST('False' AS BIT) AS AssignToOrganisationAdminstrators
				, CAST('False' AS BIT) AS AssignToOrganisationSupportGroup
				, CAST('False' AS BIT) AS AssignToAtlasSytemAdministrators
				, CAST('False' AS BIT) AS AssignToAtlasSystemSupportGroup
			UNION
			SELECT
				'Client – Overdue Course Payment' AS [Name]
				, 'Client with overdue Course Payment' AS [Description]
				, 2 AS PriorityNumber
				, CAST('False' AS BIT) AS AssignToOrganisation
				, CAST('False' AS BIT) AS AssignToOrganisationAdminstrators
				, CAST('True' AS BIT) AS AssignToOrganisationSupportGroup
				, CAST('False' AS BIT) AS AssignToAtlasSytemAdministrators
				, CAST('False' AS BIT) AS AssignToAtlasSystemSupportGroup
			UNION
			SELECT
				'Course - Overdue Payment' AS [Name]
				, 'Course with Overdue Payment' AS [Description]
				, 2 AS PriorityNumber
				, CAST('False' AS BIT) AS AssignToOrganisation
				, CAST('False' AS BIT) AS AssignToOrganisationAdminstrators
				, CAST('True' AS BIT) AS AssignToOrganisationSupportGroup
				, CAST('False' AS BIT) AS AssignToAtlasSytemAdministrators
				, CAST('False' AS BIT) AS AssignToAtlasSystemSupportGroup
			UNION
			SELECT
				'Course - Overdue Attendance' AS [Name]
				, 'Course with overdue Attendance updates from Trainers' AS [Description]
				, 3 AS PriorityNumber
				, CAST('False' AS BIT) AS AssignToOrganisation
				, CAST('False' AS BIT) AS AssignToOrganisationAdminstrators
				, CAST('True' AS BIT) AS AssignToOrganisationSupportGroup
				, CAST('False' AS BIT) AS AssignToAtlasSytemAdministrators
				, CAST('False' AS BIT) AS AssignToAtlasSystemSupportGroup
			) TA;
	
		INSERT INTO [dbo].[TaskAction] (
			[Name]
			, [Description]
			, PriorityNumber
			, AssignToOrganisation
			, AssignToOrganisationAdminstrators
			, AssignToOrganisationSupportGroup
			, AssignToAtlasSytemAdministrators
			, AssignToAtlasSystemSupportGroup
			)
		SELECT DISTINCT 
			New_TA.[Name]
			, New_TA.[Description]
			, New_TA.PriorityNumber
			, New_TA.AssignToOrganisation
			, New_TA.AssignToOrganisationAdminstrators
			, New_TA.AssignToOrganisationSupportGroup
			, New_TA.AssignToAtlasSytemAdministrators
			, New_TA.AssignToAtlasSystemSupportGroup
		FROM #TaskAction New_TA
		LEFT JOIN [dbo].[TaskAction] TA ON TA.[Name] = New_TA.[Name]
		WHERE TA.Id IS NULL;

		UPDATE TA
		SET TA.[Description] = New_TA.[Description]
		FROM #TaskAction New_TA
		INNER JOIN TaskAction TA					ON TA.[Name] = New_TA.[Name]
		WHERE TA.[Description] != New_TA.[Description]
		;		

	END



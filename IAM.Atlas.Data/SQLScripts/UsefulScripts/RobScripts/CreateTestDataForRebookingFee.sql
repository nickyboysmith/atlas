
--Create Test Data For Rebooking Fee
/*

INSERT INTO [dbo].[CourseTypeRebookingFee] (
						OrganisationId
						, CourseTypeId
						, ConditionNumber
						, EffectiveDate
						, RebookingFee
						, DaysBefore
						, [Disabled]
						, AddedByUserId
						, DateAdded)
SELECT DISTINCT 
						OrganisationId
						, CourseTypeId
						, ConditionNumber
						, EffectiveDate
						, RebookingFee
						, DaysBefore
						, [Disabled]
						, AddedByUserId
						, DateAdded
FROM (
		SELECT DISTINCT
			OrganisationId
			, CourseTypeId
			, 1									AS ConditionNumber
			, EffectiveDate
			, ROUND((CourseFee * 0.3), 2)		AS RebookingFee
			, 6									AS DaysBefore
			, 'False'							AS [Disabled]
			, dbo.udfGetSystemUserId()			AS AddedByUserId
			, DATEADD(DAY, -20, GETDATE())		AS DateAdded
		FROM [dbo].[CourseTypeCategoryFee]
		UNION
		SELECT DISTINCT
			OrganisationId
			, CourseTypeId
			, 2									AS ConditionNumber
			, EffectiveDate
			, ROUND((CourseFee * 0.15), 2)		AS RebookingFee
			, 14								AS DaysBefore
			, 'False'							AS [Disabled]
			, dbo.udfGetSystemUserId()			AS AddedByUserId
			, DATEADD(DAY, -20, GETDATE())		AS DateAdded
		FROM [dbo].[CourseTypeCategoryFee]
		UNION
		SELECT DISTINCT
			OrganisationId
			, CourseTypeId
			, 3									AS ConditionNumber
			, EffectiveDate
			, ROUND((CourseFee * 0.07), 2)		AS RebookingFee
			, 20								AS DaysBefore
			, 'False'							AS [Disabled]
			, dbo.udfGetSystemUserId()			AS AddedByUserId
			, DATEADD(DAY, -20, GETDATE())		AS DateAdded
		FROM [dbo].[CourseTypeCategoryFee]
		UNION -- Some Future ones
		SELECT DISTINCT
			OrganisationId
			, CourseTypeId
			, 1									AS ConditionNumber
			, DATEADD(DAY, +40, GETDATE())		AS EffectiveDate
			, ROUND((CourseFee * 0.4), 2)		AS RebookingFee
			, 7									AS DaysBefore
			, 'False'							AS [Disabled]
			, dbo.udfGetSystemUserId()			AS AddedByUserId
			, GETDATE()							AS DateAdded
		FROM [dbo].[CourseTypeCategoryFee]
		UNION
		SELECT DISTINCT
			OrganisationId
			, CourseTypeId
			, 2									AS ConditionNumber
			, DATEADD(DAY, +40, GETDATE())		AS EffectiveDate
			, ROUND((CourseFee * 0.18), 2)		AS RebookingFee
			, 17								AS DaysBefore
			, 'False'							AS [Disabled]
			, dbo.udfGetSystemUserId()			AS AddedByUserId
			, GETDATE()							AS DateAdded
		FROM [dbo].[CourseTypeCategoryFee]
		UNION
		SELECT DISTINCT
			OrganisationId
			, CourseTypeId
			, 3									AS ConditionNumber
			, DATEADD(DAY, +40, GETDATE())		AS EffectiveDate
			, ROUND((CourseFee * 0.11), 2)		AS RebookingFee
			, 22								AS DaysBefore
			, 'False'							AS [Disabled]
			, dbo.udfGetSystemUserId()			AS AddedByUserId
			, GETDATE()							AS DateAdded
		FROM [dbo].[CourseTypeCategoryFee]
		UNION -- Some Past ones
		SELECT DISTINCT
			OrganisationId
			, CourseTypeId
			, 1									AS ConditionNumber
			, DATEADD(DAY, -40, GETDATE())		AS EffectiveDate
			, ROUND((CourseFee * 0.25), 2)		AS RebookingFee
			, 4									AS DaysBefore
			, 'False'							AS [Disabled]
			, dbo.udfGetSystemUserId()			AS AddedByUserId
			, DATEADD(DAY, -50, GETDATE())		AS DateAdded
		FROM [dbo].[CourseTypeCategoryFee]
		UNION
		SELECT DISTINCT
			OrganisationId
			, CourseTypeId
			, 2									AS ConditionNumber
			, DATEADD(DAY, -40, GETDATE())		AS EffectiveDate
			, ROUND((CourseFee * 0.12), 2)		AS RebookingFee
			, 12								AS DaysBefore
			, 'False'							AS [Disabled]
			, dbo.udfGetSystemUserId()			AS AddedByUserId
			, DATEADD(DAY, -50, GETDATE())		AS DateAdded
		FROM [dbo].[CourseTypeCategoryFee]
		UNION
		SELECT DISTINCT
			OrganisationId
			, CourseTypeId
			, 3									AS ConditionNumber
			, DATEADD(DAY, -40, GETDATE())		AS EffectiveDate
			, ROUND((CourseFee * 0.04), 2)		AS RebookingFee
			, 18								AS DaysBefore
			, 'False'							AS [Disabled]
			, dbo.udfGetSystemUserId()			AS AddedByUserId
			, DATEADD(DAY, -50, GETDATE())		AS DateAdded
		FROM [dbo].[CourseTypeCategoryFee]
		) T
WHERE NOT EXISTS (SELECT * FROM CourseTypeRebookingFee CTRF
				WHERE CTRF.OrganisationId = T.OrganisationId
				AND CTRF.CourseTypeId = T.CourseTypeId
				AND CTRF.ConditionNumber = T.ConditionNumber
				AND CTRF.RebookingFee = T.RebookingFee
				)


--*/

--/*

INSERT INTO [dbo].[CourseTypeCategoryRebookingFee] (
						OrganisationId
						, CourseTypeId
						, CourseTypeCategoryId
						, ConditionNumber
						, EffectiveDate
						, RebookingFee
						, DaysBefore
						, [Disabled]
						, AddedByUserId
						, DateAdded)
SELECT DISTINCT 
						OrganisationId
						, CourseTypeId
						, CourseTypeCategoryId
						, ConditionNumber
						, EffectiveDate
						, RebookingFee
						, DaysBefore
						, [Disabled]
						, AddedByUserId
						, DateAdded
FROM (
		SELECT DISTINCT
			OrganisationId
			, CourseTypeId
			, CourseTypeCategoryId
			, 1									AS ConditionNumber
			, EffectiveDate
			, ROUND((CourseFee * 0.3), 2)		AS RebookingFee
			, 6									AS DaysBefore
			, 'False'							AS [Disabled]
			, dbo.udfGetSystemUserId()			AS AddedByUserId
			, DATEADD(DAY, -20, GETDATE())		AS DateAdded
		FROM [dbo].[CourseTypeCategoryFee]
		UNION
		SELECT DISTINCT
			OrganisationId
			, CourseTypeId
			, CourseTypeCategoryId
			, 2									AS ConditionNumber
			, EffectiveDate
			, ROUND((CourseFee * 0.15), 2)		AS RebookingFee
			, 14								AS DaysBefore
			, 'False'							AS [Disabled]
			, dbo.udfGetSystemUserId()			AS AddedByUserId
			, DATEADD(DAY, -20, GETDATE())		AS DateAdded
		FROM [dbo].[CourseTypeCategoryFee]
		UNION
		SELECT DISTINCT
			OrganisationId
			, CourseTypeId
			, CourseTypeCategoryId
			, 3									AS ConditionNumber
			, EffectiveDate
			, ROUND((CourseFee * 0.07), 2)		AS RebookingFee
			, 20								AS DaysBefore
			, 'False'							AS [Disabled]
			, dbo.udfGetSystemUserId()			AS AddedByUserId
			, DATEADD(DAY, -20, GETDATE())		AS DateAdded
		FROM [dbo].[CourseTypeCategoryFee]
		UNION -- Some Future ones
		SELECT DISTINCT
			OrganisationId
			, CourseTypeId
			, CourseTypeCategoryId
			, 1									AS ConditionNumber
			, DATEADD(DAY, +40, GETDATE())		AS EffectiveDate
			, ROUND((CourseFee * 0.4), 2)		AS RebookingFee
			, 7									AS DaysBefore
			, 'False'							AS [Disabled]
			, dbo.udfGetSystemUserId()			AS AddedByUserId
			, GETDATE()							AS DateAdded
		FROM [dbo].[CourseTypeCategoryFee]
		UNION
		SELECT DISTINCT
			OrganisationId
			, CourseTypeId
			, CourseTypeCategoryId
			, 2									AS ConditionNumber
			, DATEADD(DAY, +40, GETDATE())		AS EffectiveDate
			, ROUND((CourseFee * 0.18), 2)		AS RebookingFee
			, 17								AS DaysBefore
			, 'False'							AS [Disabled]
			, dbo.udfGetSystemUserId()			AS AddedByUserId
			, GETDATE()							AS DateAdded
		FROM [dbo].[CourseTypeCategoryFee]
		UNION
		SELECT DISTINCT
			OrganisationId
			, CourseTypeId
			, CourseTypeCategoryId
			, 3									AS ConditionNumber
			, DATEADD(DAY, +40, GETDATE())		AS EffectiveDate
			, ROUND((CourseFee * 0.11), 2)		AS RebookingFee
			, 22								AS DaysBefore
			, 'False'							AS [Disabled]
			, dbo.udfGetSystemUserId()			AS AddedByUserId
			, GETDATE()							AS DateAdded
		FROM [dbo].[CourseTypeCategoryFee]
		UNION -- Some Past ones
		SELECT DISTINCT
			OrganisationId
			, CourseTypeId
			, CourseTypeCategoryId
			, 1									AS ConditionNumber
			, DATEADD(DAY, -40, GETDATE())		AS EffectiveDate
			, ROUND((CourseFee * 0.25), 2)		AS RebookingFee
			, 4									AS DaysBefore
			, 'False'							AS [Disabled]
			, dbo.udfGetSystemUserId()			AS AddedByUserId
			, DATEADD(DAY, -50, GETDATE())		AS DateAdded
		FROM [dbo].[CourseTypeCategoryFee]
		UNION
		SELECT DISTINCT
			OrganisationId
			, CourseTypeId
			, CourseTypeCategoryId
			, 2									AS ConditionNumber
			, DATEADD(DAY, -40, GETDATE())		AS EffectiveDate
			, ROUND((CourseFee * 0.12), 2)		AS RebookingFee
			, 12								AS DaysBefore
			, 'False'							AS [Disabled]
			, dbo.udfGetSystemUserId()			AS AddedByUserId
			, DATEADD(DAY, -50, GETDATE())		AS DateAdded
		FROM [dbo].[CourseTypeCategoryFee]
		UNION
		SELECT DISTINCT
			OrganisationId
			, CourseTypeId
			, CourseTypeCategoryId
			, 3									AS ConditionNumber
			, DATEADD(DAY, -40, GETDATE())		AS EffectiveDate
			, ROUND((CourseFee * 0.04), 2)		AS RebookingFee
			, 18								AS DaysBefore
			, 'False'							AS [Disabled]
			, dbo.udfGetSystemUserId()			AS AddedByUserId
			, DATEADD(DAY, -50, GETDATE())		AS DateAdded
		FROM [dbo].[CourseTypeCategoryFee]
		) T
WHERE NOT EXISTS (SELECT * FROM CourseTypeCategoryRebookingFee CTCRF
				WHERE CTCRF.OrganisationId = T.OrganisationId
				AND CTCRF.CourseTypeId = T.CourseTypeId
				AND CTCRF.CourseTypeCategoryId = T.CourseTypeCategoryId
				AND CTCRF.ConditionNumber = T.ConditionNumber
				AND CTCRF.RebookingFee = T.RebookingFee
				)


--*/

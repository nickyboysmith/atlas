
--TODO .... Test and UAT

EXEC [dbo].[uspCreateMigrationConnectionToOldAtlasDB]

EXEC [dbo].[uspCreateMigrationExternalTables]


		INSERT INTO dbo.PaymentMethod (Name, Description, Code, OrganisationId, Disabled)
		SELECT pmm_description AS Name, pmm_description AS Description, pmm_code AS Code, NewOrg.Id AS OrganisationId, 'False' AS Disabled
		FROM [migration].tbl_LU_PaymentMethod OldPM
		, ([migration].tbl_LU_Organisation OldOrg
			INNER JOIN [dbo].Organisation NewOrg ON NewOrg.Name = OldOrg.org_name )
		WHERE NOT EXISTS (SELECT * 
							FROM dbo.PaymentMethod NewPM
							WHERE NewPM.Name = OldPM.pmm_description
							AND NewPM.OrganisationId = NewOrg.Id
							)



EXEC [dbo].[uspDropMigrationExternalTables]

EXEC [dbo].[uspDropMigrationConnectionToOldAtlasDB]
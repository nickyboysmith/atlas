
/*
	SCRIPT: Create Public Holiday Table With Data
	Author: Nick Smith
	Created: 13/10/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP010_18.01_CreateAtlasPublicHolidayTablesWithData.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Public Holidays Data taken from https://www.gov.uk/bank-holidays';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		
		/*
			Create Table PublicHoliday
		*/
		IF OBJECT_ID('dbo.PublicHoliday', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.PublicHoliday;
		END

		
		CREATE TABLE [dbo].[PublicHoliday](
			Id int IDENTITY(1,1) PRIMARY KEY NOT NULL,
			Title varchar(100) NULL,
			[Country Code] varchar(3) NULL,
			[Date] datetime NULL
		);
		

		SET IDENTITY_INSERT [dbo].[PublicHoliday] ON
		INSERT [dbo].[PublicHoliday] ([Id], [Title], [Country Code], [Date]) VALUES (1, 'Christmas Day', 'ENG', CAST(0x0000A57900000000 AS DateTime))
		INSERT [dbo].[PublicHoliday] ([Id], [Title], [Country Code], [Date]) VALUES (2, 'Boxing Day', 'ENG', CAST(0x0000A57C00000000 AS DateTime))
		INSERT [dbo].[PublicHoliday] ([Id], [Title], [Country Code], [Date]) VALUES (3, 'New Year’s Day', 'ENG', CAST(0x0000A58000000000 AS DateTime))
		INSERT [dbo].[PublicHoliday] ([Id], [Title], [Country Code], [Date]) VALUES (4, 'Good Friday', 'ENG', CAST(0x0000A5D400000000 AS DateTime))
		INSERT [dbo].[PublicHoliday] ([Id], [Title], [Country Code], [Date]) VALUES (5, 'Easter Monday', 'ENG', CAST(0x0000A5D700000000 AS DateTime))
		INSERT [dbo].[PublicHoliday] ([Id], [Title], [Country Code], [Date]) VALUES (6, 'Early May bank holiday', 'ENG', CAST(0x0000A5FA00000000 AS DateTime))
		INSERT [dbo].[PublicHoliday] ([Id], [Title], [Country Code], [Date]) VALUES (7, 'Spring bank holiday', 'ENG', CAST(0x0000A61600000000 AS DateTime))
		INSERT [dbo].[PublicHoliday] ([Id], [Title], [Country Code], [Date]) VALUES (8, 'Summer bank holiday', 'ENG', CAST(0x0000A67100000000 AS DateTime))
		INSERT [dbo].[PublicHoliday] ([Id], [Title], [Country Code], [Date]) VALUES (9, 'Boxing Day', 'ENG', CAST(0x0000A6E800000000 AS DateTime))
		INSERT [dbo].[PublicHoliday] ([Id], [Title], [Country Code], [Date]) VALUES (10, 'Christmas Day', 'ENG', CAST(0x0000A6E900000000 AS DateTime))
		INSERT [dbo].[PublicHoliday] ([Id], [Title], [Country Code], [Date]) VALUES (11, 'Christmas Day', 'WAL', CAST(0x0000A57900000000 AS DateTime))
		INSERT [dbo].[PublicHoliday] ([Id], [Title], [Country Code], [Date]) VALUES (12, 'Boxing Day', 'WAL', CAST(0x0000A57C00000000 AS DateTime))
		INSERT [dbo].[PublicHoliday] ([Id], [Title], [Country Code], [Date]) VALUES (13, 'New Year’s Day', 'WAL', CAST(0x0000A58000000000 AS DateTime))
		INSERT [dbo].[PublicHoliday] ([Id], [Title], [Country Code], [Date]) VALUES (14, 'Good Friday', 'WAL', CAST(0x0000A5D400000000 AS DateTime))
		INSERT [dbo].[PublicHoliday] ([Id], [Title], [Country Code], [Date]) VALUES (15, 'Easter Monday', 'WAL', CAST(0x0000A5D700000000 AS DateTime))
		INSERT [dbo].[PublicHoliday] ([Id], [Title], [Country Code], [Date]) VALUES (16, 'Early May bank holiday', 'WAL', CAST(0x0000A5FA00000000 AS DateTime))
		INSERT [dbo].[PublicHoliday] ([Id], [Title], [Country Code], [Date]) VALUES (17, 'Spring bank holiday', 'WAL', CAST(0x0000A61600000000 AS DateTime))
		INSERT [dbo].[PublicHoliday] ([Id], [Title], [Country Code], [Date]) VALUES (18, 'Summer bank holiday', 'WAL', CAST(0x0000A67100000000 AS DateTime))
		INSERT [dbo].[PublicHoliday] ([Id], [Title], [Country Code], [Date]) VALUES (19, 'Boxing Day', 'WAL', CAST(0x0000A6E800000000 AS DateTime))
		INSERT [dbo].[PublicHoliday] ([Id], [Title], [Country Code], [Date]) VALUES (20, 'Christmas Day', 'WAL', CAST(0x0000A6E900000000 AS DateTime))
		INSERT [dbo].[PublicHoliday] ([Id], [Title], [Country Code], [Date]) VALUES (21, 'St Andrew’s Day', 'SCT', CAST(0x0000A56000000000 AS DateTime))
		INSERT [dbo].[PublicHoliday] ([Id], [Title], [Country Code], [Date]) VALUES (22, 'Christmas Day', 'SCT', CAST(0x0000A57900000000 AS DateTime))
		INSERT [dbo].[PublicHoliday] ([Id], [Title], [Country Code], [Date]) VALUES (23, 'Boxing Day', 'SCT', CAST(0x0000A57C00000000 AS DateTime))
		INSERT [dbo].[PublicHoliday] ([Id], [Title], [Country Code], [Date]) VALUES (24, 'New Year’s Day', 'SCT', CAST(0x0000A58000000000 AS DateTime))
		INSERT [dbo].[PublicHoliday] ([Id], [Title], [Country Code], [Date]) VALUES (25, '2nd January', 'SCT', CAST(0x0000A58300000000 AS DateTime))
		INSERT [dbo].[PublicHoliday] ([Id], [Title], [Country Code], [Date]) VALUES (26, 'Good Friday', 'SCT', CAST(0x0000A5D400000000 AS DateTime))
		INSERT [dbo].[PublicHoliday] ([Id], [Title], [Country Code], [Date]) VALUES (27, 'Early May bank holiday', 'SCT', CAST(0x0000A5FA00000000 AS DateTime))
		INSERT [dbo].[PublicHoliday] ([Id], [Title], [Country Code], [Date]) VALUES (28, 'Spring bank holiday', 'SCT', CAST(0x0000A61600000000 AS DateTime))
		INSERT [dbo].[PublicHoliday] ([Id], [Title], [Country Code], [Date]) VALUES (29, 'Summer bank holiday', 'SCT', CAST(0x0000A65500000000 AS DateTime))
		INSERT [dbo].[PublicHoliday] ([Id], [Title], [Country Code], [Date]) VALUES (30, 'St Andrew’s Day', 'SCT', CAST(0x0000A6CE00000000 AS DateTime))
		INSERT [dbo].[PublicHoliday] ([Id], [Title], [Country Code], [Date]) VALUES (31, 'Boxing Day', 'SCT', CAST(0x0000A6E800000000 AS DateTime))
		INSERT [dbo].[PublicHoliday] ([Id], [Title], [Country Code], [Date]) VALUES (32, 'Christmas Day', 'SCT', CAST(0x0000A6E900000000 AS DateTime))
		INSERT [dbo].[PublicHoliday] ([Id], [Title], [Country Code], [Date]) VALUES (33, 'Christmas Day', 'NIR', CAST(0x0000A57900000000 AS DateTime))
		INSERT [dbo].[PublicHoliday] ([Id], [Title], [Country Code], [Date]) VALUES (34, 'Boxing Day', 'NIR', CAST(0x0000A57C00000000 AS DateTime))
		INSERT [dbo].[PublicHoliday] ([Id], [Title], [Country Code], [Date]) VALUES (35, 'New Year’s Day', 'NIR', CAST(0x0000A58000000000 AS DateTime))
		INSERT [dbo].[PublicHoliday] ([Id], [Title], [Country Code], [Date]) VALUES (36, 'St Patrick’s Day', 'NIR', CAST(0x0000A5CC00000000 AS DateTime))
		INSERT [dbo].[PublicHoliday] ([Id], [Title], [Country Code], [Date]) VALUES (37, 'Good Friday', 'NIR', CAST(0x0000A5D400000000 AS DateTime))
		INSERT [dbo].[PublicHoliday] ([Id], [Title], [Country Code], [Date]) VALUES (38, 'Easter Monday', 'NIR', CAST(0x0000A5D700000000 AS DateTime))
		INSERT [dbo].[PublicHoliday] ([Id], [Title], [Country Code], [Date]) VALUES (39, 'Early May bank holiday', 'NIR', CAST(0x0000A5FA00000000 AS DateTime))
		INSERT [dbo].[PublicHoliday] ([Id], [Title], [Country Code], [Date]) VALUES (40, 'Spring bank holiday', 'NIR', CAST(0x0000A61600000000 AS DateTime))
		INSERT [dbo].[PublicHoliday] ([Id], [Title], [Country Code], [Date]) VALUES (41, 'Battle of the Boyne (Orangemen’s Day)', 'NIR', CAST(0x0000A64100000000 AS DateTime))
		INSERT [dbo].[PublicHoliday] ([Id], [Title], [Country Code], [Date]) VALUES (42, 'Summer bank holiday', 'NIR', CAST(0x0000A67100000000 AS DateTime))
		INSERT [dbo].[PublicHoliday] ([Id], [Title], [Country Code], [Date]) VALUES (43, 'Boxing Day', 'NIR', CAST(0x0000A6E800000000 AS DateTime))
		INSERT [dbo].[PublicHoliday] ([Id], [Title], [Country Code], [Date]) VALUES (44, 'Christmas Day', 'NIR', CAST(0x0000A6E900000000 AS DateTime))
		SET IDENTITY_INSERT [dbo].[PublicHoliday] OFF



		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;





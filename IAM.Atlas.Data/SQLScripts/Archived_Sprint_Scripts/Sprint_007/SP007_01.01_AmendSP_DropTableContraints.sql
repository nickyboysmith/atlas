

/*
	SCRIPT: SP007_01.01_AmendSP_DropTableContraints
	Author: Robert Newnham
	Amended: 18/08/2015
*/

IF OBJECT_ID ( 'dbo.uspDropTableContraints', 'P' ) IS NOT NULL 
    DROP PROCEDURE dbo.uspDropTableContraints;
GO

CREATE PROCEDURE uspDropTableContraints 
	@TableName Varchar(100)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @SQL NVARCHAR(MAX) = N'';

	SELECT @SQL += N'
	ALTER TABLE [' + OBJECT_NAME(PARENT_OBJECT_ID) + '] DROP CONSTRAINT ' + OBJECT_NAME(OBJECT_ID) + ';' 
	FROM SYS.OBJECTS
	WHERE TYPE_DESC LIKE '%CONSTRAINT' AND OBJECT_NAME(PARENT_OBJECT_ID) = @TableName
	ORDER BY OBJECT_NAME(OBJECT_ID) ASC; /*SO THAT "PK_" (Primary Keys) are Dropped Last */

	EXECUTE(@SQL)
END

GO




/*
	SCRIPT: Add update trigger to the CourseSchedule table
	Author: Dan Murray
	Created: 09/10/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP010_16.01_AddUpdateTriggerToCourseScheduleTable.sql';
DECLARE @ScriptComments VARCHAR(800) = '';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 	

IF OBJECT_ID('dbo.[TRG_CourseSchedule_UPDATE]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_CourseSchedule_UPDATE];
		END
GO
		CREATE TRIGGER TRG_CourseSchedule_UPDATE ON CourseSchedule FOR UPDATE
AS

DECLARE @bit INT ,
       @field INT ,
       @maxfield INT ,
       @char INT ,
       @fieldname VARCHAR(128) ,
       @TableName VARCHAR(128) ,
       @PKCols VARCHAR(1000) ,
       @sql VARCHAR(2000), 
       @UserName VARCHAR(128) = 'CreatedByUserId' ,
	   @CourseId VARCHAR(128) = 'CourseId',
       @Type CHAR(1) ,
       @PKSelect VARCHAR(1000)       

--You will need to change @TableName to match the table to be audited
SELECT @TableName = 'CourseSchedule'

-- Action
IF EXISTS (SELECT * FROM inserted)
       IF EXISTS (SELECT * FROM deleted)
               SELECT @Type = 'U'
       ELSE
               SELECT @Type = 'I'
ELSE
       SELECT @Type = 'D'

-- get list of columns
SELECT * INTO #ins FROM inserted
SELECT * INTO #del FROM deleted

-- Get primary key columns for full outer join
SELECT @PKCols = COALESCE(@PKCols + ' and', ' on') 
               + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
       FROM    INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk ,

              INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
       WHERE   pk.TABLE_NAME = @TableName
       AND     CONSTRAINT_TYPE = 'PRIMARY KEY'
       AND     c.TABLE_NAME = pk.TABLE_NAME
       AND     c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME

-- Get primary key select for insert
SELECT @PKSelect = '+convert(varchar(100),coalesce(i.' + COLUMN_NAME +',d.' + COLUMN_NAME + '))' 
       FROM    INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk ,
               INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
       WHERE   pk.TABLE_NAME = @TableName
       AND     CONSTRAINT_TYPE = 'PRIMARY KEY'
       AND     c.TABLE_NAME = pk.TABLE_NAME
       AND     c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
	   
SELECT @field = 0, 
       @maxfield = MAX(ORDINAL_POSITION) 
       FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @TableName
WHILE @field < @maxfield
BEGIN		
       SELECT @field = MIN(ORDINAL_POSITION) 
               FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = @TableName 
               AND ORDINAL_POSITION > @field
       SELECT @bit = (@field - 1 )% 8 + 1
       SELECT @bit = POWER(2,@bit - 1)
       SELECT @char = ((@field - 1) / 8) + 1
       IF SUBSTRING(COLUMNS_UPDATED(),@char, 1) & @bit > 0
                                       OR @Type IN ('I','D')
       BEGIN
               SELECT @fieldname = COLUMN_NAME 
                       FROM INFORMATION_SCHEMA.COLUMNS 
                       WHERE TABLE_NAME = @TableName 
                       AND ORDINAL_POSITION = @field
               
               SELECT @sql = '
						insert CourseLog (    
										CourseId,
										DateCreated,
										CreatedByUserId,
										Item,
										OldValue,
										NewValue
									   )
						select convert(int,coalesce(i.' + @CourseId +',d.' + @CourseId + '))
							  ,convert(varchar(19),getdate())
							  ,convert(int,coalesce(i.' + @UserName +',d.' + @UserName + '))
							  ,''' + @fieldname + '''
							  ,convert(varchar(1000),d.' + @fieldname + ')' + '
							  ,convert(varchar(1000),i.' + @fieldname + ')' + ' 
							  from #ins i full outer join #del d'
							   + @PKCols
							   + ' where i.' + @fieldname + ' <> d.' + @fieldname 
							   + ' or (i.' + @fieldname + ' is null and  d.'
														+ @fieldname
														+ ' is not null)' 
							   + ' or (i.' + @fieldname + ' is not null and  d.' 
														+ @fieldname
														+ ' is null)'  
               EXEC (@sql)
       END
END

GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP010_16.01_AddUpdateTriggerToCourseScheduleTable.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO
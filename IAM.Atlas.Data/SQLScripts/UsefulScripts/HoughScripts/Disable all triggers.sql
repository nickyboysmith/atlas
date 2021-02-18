DECLARE @DisableTriggerCommand NVARCHAR(4000)
DECLARE @TriggerTableName NVARCHAR(500)

DECLARE DisableTriggerCursor CURSOR
FOR
(
		SELECT NAME AS TableName
		FROM sysobjects
		WHERE id IN (
				SELECT parent_obj
				FROM sysobjects
				WHERE xtype = 'tr'
				)
		)

OPEN DisableTriggerCursor

FETCH NEXT
FROM DisableTriggerCursor
INTO @TriggerTableName

WHILE @@fetch_status = 0
BEGIN
	SET @DisableTriggerCommand = N'ALTER TABLE [' + @TriggerTableName + '] DISABLE TRIGGER ALL'

	PRINT 'Executing:   ' + @DisableTriggerCommand + CHAR(13)

	EXECUTE sp_executesql @DisableTriggerCommand

	FETCH NEXT
	FROM DisableTriggerCursor
	INTO @TriggerTableName
END

CLOSE DisableTriggerCursor

DEALLOCATE DisableTriggerCursor
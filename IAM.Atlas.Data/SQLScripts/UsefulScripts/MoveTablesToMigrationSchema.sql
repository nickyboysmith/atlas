
CREATE SCHEMA migration
AUTHORIZATION dbo


declare @newSchema varchar(100) = 'migration',
		@currentSchema varchar(100) = 'dbo';

--tables and views
select 'alter schema ' + @newSchema + ' transfer ' + TABLE_SCHEMA + '.[' + TABLE_NAME + ']'
from information_schema.TABLES where TABLE_SCHEMA = @currentSchema
union
--stored procs and functions
select 'alter schema ' + @newSchema + ' transfer ' + ROUTINE_SCHEMA + '.[' + ROUTINE_NAME + ']'
from information_schema.routines  
where ROUTINE_SCHEMA = @currentSchema
and left(ROUTINE_NAME, 3) NOT IN ('sp_', 'xp_', 'ms_');
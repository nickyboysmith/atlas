

select REPLACE(CAST(S1.text AS VARCHAR(MAX)) + CAST(ISNULL(S2.text,'') AS VARCHAR(MAX)), 'CREATE TRIGGER', CHAR(13) + CHAR(10) + 'GO' + CHAR(13) + CHAR(10) + 'ALTER TRIGGER') 
from syscomments S1
LEFT JOIN syscomments S2 ON S2.id = S1.id AND S2.colid = 2
where S1.text like '%CREATE TRIGGER%'
--AND S2.id IS NULL
AND S1.colid = 1


--select *
--from syscomments S1
--where text like '%CREATE TRIGGER%'
--AND S1.colid > 1
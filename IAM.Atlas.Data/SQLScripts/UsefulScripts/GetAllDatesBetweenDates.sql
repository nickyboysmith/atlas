


DECLARE @startdate datetime = CAST('01-Jan-2017' AS DATETIME), @enddate datetime = CAST('31-DEC-2017' AS DATETIME)

SELECT  TOP (DATEDIFF(DAY, @startdate, @enddate) + 1) Dates = DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY a.object_id) - 1, @startdate)
FROM sys.all_objects a CROSS JOIN sys.all_objects b;
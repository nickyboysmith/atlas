

IF OBJECT_ID('tempdb..#daterange', 'U') IS NOT NULL
BEGIN
	DROP TABLE #daterange;
END

declare @startDate date;
declare @endDate date;

select @startDate = '20170316';
select @endDate = '20181231';

--set @startDate = dateadd(DAY, 100, @startDate);
with dateRange as
(
  select dt = dateadd(dd, 1, @startDate)
  where dateadd(dd, 1, @startDate) < @endDate
  union all
  select dateadd(dd, 1, dt)
  from dateRange
  where dateadd(dd, 1, dt) < @endDate
)
SELECT *
INTO #daterange
from(
select TOP 100 dt, DATEPART(WEEKDAY,dt) dayNumber
from dateRange ) t
WHERE dayNumber BETWEEN 2 AND 6

INSERT INTO [dbo].[InterpreterAvailabilityDate] (InterpreterId, Date, SessionNumber)
SELECT DISTINCT I.Id AS InterpreterId, t2.dt as Date, t3.SessionNumber
FROM [dbo].[Interpreter] I
, (SELECT dt
	from #daterange )t2
, (SELECT 1 AS SessionNumber UNION SELECT 2 AS SessionNumber UNION SELECT 3 AS SessionNumber) t3
WHERE NOT EXISTS (SELECT * 
					FROM InterpreterAvailabilityDate IAD 
					WHERE IAD.InterpreterId = I.Id
					AND IAD.Date = t2.dt
					AND IAD.SessionNumber = t3.SessionNumber)
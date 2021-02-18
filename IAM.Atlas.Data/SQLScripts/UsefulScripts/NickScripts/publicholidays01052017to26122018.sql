

/* publicholidays 01/05/2017 to 26/12/2018 */

INSERT INTO PublicHoliday (Title, [Country Code], [Date])
SELECT T.Title, T.[Country Code], T.[Date]
FROM (
SELECT 'Early May bank holiday' AS Title, 'ENG' AS [Country Code], CONVERT(datetime, '01/05/2017', 103) AS [Date]
UNION SELECT 'Spring bank holiday' AS Title, 'ENG' AS [Country Code], CONVERT(datetime, '29/05/2017', 103) AS [Date]
UNION SELECT 'Summer bank holiday' AS Title, 'ENG' AS [Country Code], CONVERT(datetime, '28/08/2017', 103) AS [Date]
UNION SELECT 'Christmas Day' AS Title, 'ENG' AS [Country Code], CONVERT(datetime, '25/12/2017', 103) AS [Date]
UNION SELECT 'Boxing Day' AS Title, 'ENG' AS [Country Code], CONVERT(datetime, '26/12/2017', 103) AS [Date]
UNION SELECT 'New Year’s Day' AS Title, 'ENG' AS [Country Code], CONVERT(datetime, '01/01/2018', 103) AS [Date]
UNION SELECT 'Good Friday' AS Title, 'ENG' AS [Country Code], CONVERT(datetime, '30/03/2018', 103) AS [Date]
UNION SELECT 'Easter Monday' AS Title, 'ENG' AS [Country Code], CONVERT(datetime, '02/04/2018', 103) AS [Date]
UNION SELECT 'Early May bank holiday' AS Title, 'ENG' AS [Country Code], CONVERT(datetime, '07/05/2018', 103) AS [Date]
UNION SELECT 'Spring bank holiday' AS Title, 'ENG' AS [Country Code], CONVERT(datetime, '28/05/2018', 103) AS [Date]
UNION SELECT 'Summer bank holiday' AS Title, 'ENG' AS [Country Code], CONVERT(datetime, '27/08/2018', 103) AS [Date]
UNION SELECT 'Christmas Day' AS Title, 'ENG' AS [Country Code], CONVERT(datetime, '25/12/2018', 103) AS [Date]
UNION SELECT 'Boxing Day' AS Title, 'ENG' AS [Country Code], CONVERT(datetime, '26/12/2018', 103) AS [Date]

UNION SELECT 'Early May bank holiday' AS Title, 'WAL' AS [Country Code], CONVERT(datetime, '01/05/2017', 103) AS [Date]
UNION SELECT 'Spring bank holiday' AS Title, 'WAL' AS [Country Code], CONVERT(datetime, '29/05/2017', 103) AS [Date]
UNION SELECT 'Summer bank holiday' AS Title, 'WAL' AS [Country Code], CONVERT(datetime, '28/08/2017', 103) AS [Date]
UNION SELECT 'Christmas Day' AS Title, 'WAL' AS [Country Code], CONVERT(datetime, '25/12/2017', 103) AS [Date]
UNION SELECT 'Boxing Day' AS Title, 'WAL' AS [Country Code], CONVERT(datetime, '26/12/2017', 103) AS [Date]
UNION SELECT 'New Year’s Day' AS Title, 'WAL' AS [Country Code], CONVERT(datetime, '01/01/2018', 103) AS [Date]
UNION SELECT 'Good Friday' AS Title, 'WAL' AS [Country Code], CONVERT(datetime, '30/03/2018', 103) AS [Date]
UNION SELECT 'Easter Monday' AS Title, 'WAL' AS [Country Code], CONVERT(datetime, '02/04/2018', 103) AS [Date]
UNION SELECT 'Early May bank holiday' AS Title, 'WAL' AS [Country Code], CONVERT(datetime, '07/05/2018', 103) AS [Date]
UNION SELECT 'Spring bank holiday' AS Title, 'WAL' AS [Country Code], CONVERT(datetime, '28/05/2018', 103) AS [Date]
UNION SELECT 'Summer bank holiday' AS Title, 'WAL' AS [Country Code], CONVERT(datetime, '27/08/2018', 103) AS [Date]
UNION SELECT 'Christmas Day' AS Title, 'WAL' AS [Country Code], CONVERT(datetime, '25/12/2018', 103) AS [Date]
UNION SELECT 'Boxing Day' AS Title, 'WAL' AS [Country Code], CONVERT(datetime, '26/12/2018', 103) AS [Date]

UNION SELECT 'Early May bank holiday' AS Title, 'SCT' AS [Country Code], CONVERT(datetime, '01/05/2017', 103) AS [Date]
UNION SELECT 'Spring bank holiday' AS Title, 'SCT' AS [Country Code], CONVERT(datetime, '29/05/2017', 103) AS [Date]
UNION SELECT 'Summer bank holiday' AS Title, 'SCT' AS [Country Code], CONVERT(datetime, '07/08/2017', 103) AS [Date]
UNION SELECT 'St Andrew’s Day' AS Title, 'SCT' AS [Country Code], CONVERT(datetime, '30/11/2017', 103) AS [Date]
UNION SELECT 'Christmas Day' AS Title, 'SCT' AS [Country Code], CONVERT(datetime, '25/12/2017', 103) AS [Date]
UNION SELECT 'Boxing Day' AS Title, 'SCT' AS [Country Code], CONVERT(datetime, '26/12/2017', 103) AS [Date]
UNION SELECT 'New Year’s Day' AS Title, 'SCT' AS [Country Code], CONVERT(datetime, '01/01/2018', 103) AS [Date]
UNION SELECT '2nd January' AS Title, 'SCT' AS [Country Code], CONVERT(datetime, '02/01/2018', 103) AS [Date]
UNION SELECT 'Good Friday' AS Title, 'SCT' AS [Country Code], CONVERT(datetime, '30/03/2018', 103) AS [Date]
UNION SELECT 'Early May bank holiday' AS Title, 'SCT' AS [Country Code], CONVERT(datetime, '07/05/2018', 103) AS [Date]
UNION SELECT 'Spring bank holiday' AS Title, 'SCT' AS [Country Code], CONVERT(datetime, '28/05/2018', 103) AS [Date]
UNION SELECT 'Summer bank holiday' AS Title, 'SCT' AS [Country Code], CONVERT(datetime, '06/08/2018', 103) AS [Date]
UNION SELECT 'St Andrew’s Day' AS Title, 'SCT' AS [Country Code], CONVERT(datetime, '30/11/2018', 103) AS [Date]
UNION SELECT 'Christmas Day' AS Title, 'SCT' AS [Country Code], CONVERT(datetime, '25/12/2018', 103) AS [Date]
UNION SELECT 'Boxing Day' AS Title, 'SCT' AS [Country Code], CONVERT(datetime, '26/12/2018', 103) AS [Date]

UNION SELECT 'Early May bank holiday' AS Title, 'NIR' AS [Country Code], CONVERT(datetime, '01/05/2017', 103) AS [Date]
UNION SELECT 'Spring bank holiday' AS Title, 'NIR' AS [Country Code], CONVERT(datetime, '29/05/2017', 103) AS [Date]
UNION SELECT 'Battle of the Boyne (Orangemen’s Day)' AS Title, 'NIR' AS [Country Code], CONVERT(datetime, '12/07/2017', 103) AS [Date]
UNION SELECT 'Summer bank holiday' AS Title, 'NIR' AS [Country Code], CONVERT(datetime, '28/08/2017', 103) AS [Date]
UNION SELECT 'Christmas Day' AS Title, 'NIR' AS [Country Code], CONVERT(datetime, '25/12/2017', 103) AS [Date]
UNION SELECT 'Boxing Day' AS Title, 'NIR' AS [Country Code], CONVERT(datetime, '26/12/2017', 103) AS [Date]
UNION SELECT 'New Year’s Day' AS Title, 'NIR' AS [Country Code], CONVERT(datetime, '01/01/2018', 103) AS [Date]
UNION SELECT 'St Patrick’s Day' AS Title, 'NIR' AS [Country Code], CONVERT(datetime, '19/03/2018', 103) AS [Date]
UNION SELECT 'Good Friday' AS Title, 'NIR' AS [Country Code], CONVERT(datetime, '30/03/2018', 103) AS [Date]
UNION SELECT 'Easter Monday' AS Title, 'NIR' AS [Country Code], CONVERT(datetime, '02/04/2018', 103) AS [Date]
UNION SELECT 'Early May bank holiday' AS Title, 'NIR' AS [Country Code], CONVERT(datetime, '07/05/2018', 103) AS [Date]
UNION SELECT 'Spring bank holiday' AS Title, 'NIR' AS [Country Code], CONVERT(datetime, '28/05/2018', 103) AS [Date]
UNION SELECT 'Battle of the Boyne (Orangemen’s Day)' AS Title, 'NIR' AS [Country Code], CONVERT(datetime, '12/07/2018', 103) AS [Date]
UNION SELECT 'Summer bank holiday' AS Title, 'NIR' AS [Country Code], CONVERT(datetime, '27/08/2018', 103) AS [Date]
UNION SELECT 'Christmas Day' AS Title, 'NIR' AS [Country Code], CONVERT(datetime, '25/12/2018', 103) AS [Date]
UNION SELECT 'Boxing Day' AS Title, 'NIR' AS [Country Code], CONVERT(datetime, '26/12/2018', 103) AS [Date]

) T
LEFT JOIN PublicHoliday PH ON PH.Title = T.Title 
							AND PH.Date = T.Date
							AND PH.[Country Code] = T.[Country Code]
WHERE PH.Id IS NULL

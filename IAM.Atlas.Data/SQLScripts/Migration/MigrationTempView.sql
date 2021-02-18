




/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwMigration_OrgAlternateNames', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwMigration_OrgAlternateNames;
END		
GO
IF OBJECT_ID('migration.vwMigration_OrgAlternateNames', 'V') IS NOT NULL
BEGIN
	DROP VIEW migration.vwMigration_OrgAlternateNames;
END		
GO

CREATE VIEW migration.vwMigration_OrgAlternateNames
AS

	SELECT 'Root' AS Owner, '1' AS Id, 'Root' AS SubName, NULL AS ParentId
	UNION SELECT 'PDS' AS Owner, '14' AS Id, 'PDS' AS SubName, '1' AS ParentId
	UNION SELECT 'Staffordshire County Council' AS Owner, '115' AS Id, 'Staffordshire County Council' AS SubName, '14' AS ParentId
	UNION SELECT 'Essex County Council' AS Owner, '121' AS Id, 'Essex County Council' AS SubName, '14' AS ParentId
	UNION SELECT 'Drivesafe' AS Owner, '137' AS Id, 'Greater Manchester Provider Group' AS SubName, '14' AS ParentId
	UNION SELECT 'Fantasia Safety Services' AS Owner, '97' AS Id, 'Fantasia Safety Services' AS SubName, '14' AS ParentId
	UNION SELECT 'Sussex' AS Owner, '162' AS Id, 'Sussex' AS SubName, '14' AS ParentId
	UNION SELECT 'Norfolk' AS Owner, '180' AS Id, 'Norfolk' AS SubName, '14' AS ParentId
	UNION SELECT 'Cleveland' AS Owner, '208' AS Id, 'Cleveland' AS SubName, '14' AS ParentId
	UNION SELECT 'Gloucestershire' AS Owner, '254' AS Id, 'Gloucestershire' AS SubName, '14' AS ParentId
	UNION SELECT 'Fantasia Safety Services' AS Owner, '98' AS Id, 'NDIS Fantasia' AS SubName, '97' AS ParentId
	UNION SELECT 'Fantasia Safety Services' AS Owner, '100' AS Id, 'Keystone Cops Police Authority' AS SubName, '97' AS ParentId
	UNION SELECT 'Fantasia Safety Services' AS Owner, '102' AS Id, 'Speed Fantasia Futureland' AS SubName, '97' AS ParentId
	UNION SELECT 'Staffordshire County Council (a)' AS Owner, '116' AS Id, 'Staffordshire NDIS' AS SubName, '115' AS ParentId
	UNION SELECT 'Staffordshire County Council (a)' AS Owner, '117' AS Id, 'Staffordshire Speed' AS SubName, '115' AS ParentId
	UNION SELECT 'Staffordshire County Council (a)' AS Owner, '118' AS Id, 'Staffordshire Ride' AS SubName, '115' AS ParentId
	UNION SELECT 'Staffordshire County Council (a)' AS Owner, '123' AS Id, 'Staffordshire Fleet' AS SubName, '115' AS ParentId
	UNION SELECT 'Staffordshire County Council (a)' AS Owner, '132' AS Id, 'Staffordshire CC Images' AS SubName, '115' AS ParentId
	UNION SELECT 'Staffordshire County Council (a)' AS Owner, '241' AS Id, 'Staffordshire Alertness' AS SubName, '115' AS ParentId
	UNION SELECT 'Staffordshire County Council (a)' AS Owner, '273' AS Id, 'Staffordshire PPE' AS SubName, '115' AS ParentId
	UNION SELECT 'Staffordshire County Council (a)' AS Owner, '279' AS Id, 'Staffordshire TLAC' AS SubName, '115' AS ParentId
	UNION SELECT 'Staffordshire County Council (a)' AS Owner, '282' AS Id, 'Formscape Interface Installer' AS SubName, '115' AS ParentId
	UNION SELECT 'Staffordshire County Council (a)' AS Owner, '298' AS Id, 'Staffordshire D4C' AS SubName, '115' AS ParentId
	UNION SELECT 'Staffordshire County Council (a)' AS Owner, '312' AS Id, 'Staffordshire Crash' AS SubName, '115' AS ParentId
	UNION SELECT 'Staffordshire County Council (a)' AS Owner, '340' AS Id, 'Staffordshire NMSAC' AS SubName, '115' AS ParentId
	UNION SELECT 'Staffordshire County Council (a)' AS Owner, '130' AS Id, 'Staffordshire County Council' AS SubName, '116' AS ParentId
	UNION SELECT 'Staffordshire County Council (a)' AS Owner, '133' AS Id, 'Staffordshire County Council' AS SubName, '117' AS ParentId
	UNION SELECT 'Staffordshire County Council (a)' AS Owner, '134' AS Id, 'Staffordshire SCP' AS SubName, '117' AS ParentId
	UNION SELECT 'Staffordshire County Council (a)' AS Owner, '135' AS Id, 'Staffordshire County Council' AS SubName, '118' AS ParentId
	UNION SELECT 'Essex County Council' AS Owner, '124' AS Id, 'Essex NDIS' AS SubName, '121' AS ParentId
	UNION SELECT 'Essex County Council' AS Owner, '125' AS Id, 'Essex Speed' AS SubName, '121' AS ParentId
	UNION SELECT 'Essex County Council' AS Owner, '230' AS Id, 'Essex RIDE' AS SubName, '121' AS ParentId
	UNION SELECT 'Essex County Council' AS Owner, '252' AS Id, 'Essex BikeSafe' AS SubName, '121' AS ParentId
	UNION SELECT 'Essex County Council' AS Owner, '266' AS Id, 'Essex GD' AS SubName, '121' AS ParentId
	UNION SELECT 'Essex County Council' AS Owner, '288' AS Id, 'Essex Alert' AS SubName, '121' AS ParentId
	UNION SELECT 'Essex County Council' AS Owner, '323' AS Id, 'Essex WDU' AS SubName, '121' AS ParentId
	UNION SELECT 'Essex County Council' AS Owner, '324' AS Id, 'Essex D4C' AS SubName, '121' AS ParentId
	UNION SELECT 'Essex County Council' AS Owner, '326' AS Id, 'Essex NSAC20' AS SubName, '121' AS ParentId
	UNION SELECT 'Essex County Council' AS Owner, '342' AS Id, 'Essex MSAC' AS SubName, '121' AS ParentId
	UNION SELECT 'Essex County Council' AS Owner, '126' AS Id, 'Essex County Council' AS SubName, '124' AS ParentId
	UNION SELECT 'Essex County Council' AS Owner, '127' AS Id, 'Essex Police' AS SubName, '124' AS ParentId
	UNION SELECT 'Essex County Council' AS Owner, '128' AS Id, 'Essex County Council' AS SubName, '125' AS ParentId
	UNION SELECT 'Staffordshire County Council' AS Owner, '305' AS Id, 'Staffs Speed B' AS SubName, '133' AS ParentId
	UNION SELECT 'Drivesafe' AS Owner, '138' AS Id, 'GM NDIS' AS SubName, '137' AS ParentId
	UNION SELECT 'Drivesafe' AS Owner, '142' AS Id, 'GM NSAS' AS SubName, '137' AS ParentId
	UNION SELECT 'Drivesafe' AS Owner, '233' AS Id, 'Merseyside NDIS' AS SubName, '137' AS ParentId
	UNION SELECT 'Drivesafe' AS Owner, '234' AS Id, 'Merseyside NSAS' AS SubName, '137' AS ParentId
	UNION SELECT 'Drivesafe' AS Owner, '240' AS Id, 'GM Alertness' AS SubName, '137' AS ParentId
	UNION SELECT 'Drivesafe' AS Owner, '249' AS Id, 'GM TLAC' AS SubName, '137' AS ParentId
	UNION SELECT 'Drivesafe' AS Owner, '250' AS Id, 'Merseyside TLAC' AS SubName, '137' AS ParentId
	UNION SELECT 'Drivesafe' AS Owner, '281' AS Id, 'Merseyside NDAC' AS SubName, '137' AS ParentId
	UNION SELECT 'Drivesafe' AS Owner, '306' AS Id, 'GM D4C' AS SubName, '137' AS ParentId
	UNION SELECT 'Drivesafe' AS Owner, '307' AS Id, 'GM WDU' AS SubName, '137' AS ParentId
	UNION SELECT 'Drivesafe' AS Owner, '309' AS Id, 'GM Fleet' AS SubName, '137' AS ParentId
	UNION SELECT 'Drivesafe' AS Owner, '315' AS Id, 'Merseyside WDU' AS SubName, '137' AS ParentId
	UNION SELECT 'Drivesafe' AS Owner, '316' AS Id, 'Merseyside D4C' AS SubName, '137' AS ParentId
	UNION SELECT 'Drivesafe' AS Owner, '325' AS Id, 'GM NSAC 20' AS SubName, '137' AS ParentId
	UNION SELECT 'Drivesafe' AS Owner, '339' AS Id, 'Taxi Driver Assessment' AS SubName, '137' AS ParentId
	UNION SELECT 'Drivesafe' AS Owner, '341' AS Id, 'GM NMSAC' AS SubName, '137' AS ParentId
	UNION SELECT 'Drivesafe' AS Owner, '140' AS Id, 'Provider Group' AS SubName, '138' AS ParentId
	UNION SELECT 'Drivesafe' AS Owner, '141' AS Id, 'Greater Manchester Police' AS SubName, '138' AS ParentId
	UNION SELECT 'Drivesafe' AS Owner, '143' AS Id, 'Greater Manchester Provider Group' AS SubName, '142' AS ParentId
	UNION SELECT 'Drivesafe' AS Owner, '144' AS Id, 'Greater Manchester SCP' AS SubName, '142' AS ParentId
	UNION SELECT 'Drivesafe' AS Owner, '213' AS Id, 'Reports' AS SubName, '143' AS ParentId
	UNION SELECT 'Sussex' AS Owner, '170' AS Id, 'Sussex SAC' AS SubName, '162' AS ParentId
	UNION SELECT 'Sussex' AS Owner, '171' AS Id, 'Sussex DIS' AS SubName, '162' AS ParentId
	UNION SELECT 'Sussex' AS Owner, '263' AS Id, 'Sussex YDS' AS SubName, '162' AS ParentId
	UNION SELECT 'Sussex' AS Owner, '292' AS Id, 'Sussex DAC' AS SubName, '162' AS ParentId
	UNION SELECT 'Sussex' AS Owner, '319' AS Id, 'Sussex WDU' AS SubName, '162' AS ParentId
	UNION SELECT 'Sussex' AS Owner, '320' AS Id, 'Sussex D4C' AS SubName, '162' AS ParentId
	UNION SELECT 'Sussex' AS Owner, '343' AS Id, 'Sussex MSAC' AS SubName, '162' AS ParentId
	UNION SELECT 'Sussex' AS OWNER, '172' AS Id, 'East Sussex' AS SubName, '170' AS ParentId
	UNION SELECT 'Sussex' AS Owner, '173' AS Id, 'West Sussex' AS SubName, '170' AS ParentId
	UNION SELECT 'Sussex' AS Owner, '174' AS Id, 'East Sussex DIS' AS SubName, '171' AS ParentId
	UNION SELECT 'Sussex' AS Owner, '175' AS Id, 'West Sussex DIS' AS SubName, '171' AS ParentId
	UNION SELECT 'Sussex' AS Owner, '321' AS Id, 'Sussex Speed Combined' AS SubName, '173' AS ParentId
	UNION SELECT 'Norfolk' AS Owner, '181' AS Id, 'Speed' AS SubName, '180' AS ParentId
	UNION SELECT 'Norfolk' AS Owner, '182' AS Id, 'Driver Improvement' AS SubName, '180' AS ParentId
	UNION SELECT 'Norfolk' AS Owner, '183' AS Id, 'Maps' AS SubName, '180' AS ParentId
	UNION SELECT 'Norfolk' AS Owner, '265' AS Id, 'Driver Education and Behaviour' AS SubName, '180' AS ParentId
	UNION SELECT 'Norfolk' AS Owner, '295' AS Id, 'Driver Alertness' AS SubName, '180' AS ParentId
	UNION SELECT 'Norfolk' AS Owner, '329' AS Id, 'WDU' AS SubName, '180' AS ParentId
	UNION SELECT 'Norfolk' AS Owner, '330' AS Id, 'D4C' AS SubName, '180' AS ParentId
	UNION SELECT 'Norfolk' AS Owner, '331' AS Id, 'RiDE' AS SubName, '180' AS ParentId
	UNION SELECT 'Norfolk' AS Owner, '338' AS Id, 'Word' AS SubName, '181' AS ParentId
	UNION SELECT 'Cleveland' AS Owner, '210' AS Id, 'Cleveland Speed Awareness' AS SubName, '208' AS ParentId
	UNION SELECT 'Cleveland' AS Owner, '211' AS Id, 'Cleveland Driver Improvement' AS SubName, '208' AS ParentId
	UNION SELECT 'Cleveland' AS Owner, '212' AS Id, 'Cleveland RIDE' AS SubName, '208' AS ParentId
	UNION SELECT 'Cleveland' AS Owner, '290' AS Id, 'Cleveland Driver Alertness' AS SubName, '208' AS ParentId
	UNION SELECT 'Cleveland' AS Owner, '299' AS Id, 'Maps' AS SubName, '208' AS ParentId
	UNION SELECT 'Cleveland' AS Owner, '327' AS Id, 'Cleveland D4C' AS SubName, '208' AS ParentId
	UNION SELECT 'Cleveland' AS Owner, '328' AS Id, 'Cleveland WDU' AS SubName, '208' AS ParentId
	UNION SELECT 'Cleveland' AS Owner, '332' AS Id, 'Durham' AS SubName, '208' AS ParentId
	UNION SELECT 'Cleveland' AS Owner, '219' AS Id, 'Client Page Letter' AS SubName, '210' AS ParentId
	UNION SELECT 'Cleveland' AS Owner, '220' AS Id, 'Course Page Letter' AS SubName, '210' AS ParentId
	UNION SELECT 'Cleveland' AS Owner, '222' AS Id, 'Online Booking Images' AS SubName, '210' AS ParentId
	UNION SELECT 'Cleveland' AS Owner, '225' AS Id, 'Online Booking and Images' AS SubName, '211' AS ParentId
	UNION SELECT 'Essex County Council' AS Owner, '231' AS Id, 'Essex County Council' AS SubName, '230' AS ParentId
	UNION SELECT 'Essex County Council' AS Owner, '232' AS Id, 'Essex Police' AS SubName, '230' AS ParentId
	UNION SELECT 'Drivesafe' AS Owner, '236' AS Id, 'DriveSafe' AS SubName, '233' AS ParentId
	UNION SELECT 'Drivesafe' AS Owner, '237' AS Id, 'Police' AS SubName, '234' AS ParentId
	UNION SELECT 'Drivesafe' AS Owner, '238' AS Id, 'DriveSafe' AS SubName, '234' AS ParentId
	UNION SELECT 'Drivesafe' AS Owner, '243' AS Id, 'DriveSafe' AS SubName, '240' AS ParentId
	UNION SELECT 'Staffordshire County Council (a)' AS Owner, '245' AS Id, 'Staffordshire County Council Alertness' AS SubName, '241' AS ParentId
	UNION SELECT 'Staffordshire County Council (a)' AS Owner, '246' AS Id, 'Staffordshire Police Alertness' AS SubName, '241' AS ParentId
	UNION SELECT 'Gloucestershire' AS Owner, '255' AS Id, 'GCC Speed Awareness' AS SubName, '254' AS ParentId
	UNION SELECT 'Gloucestershire' AS Owner, '256' AS Id, 'GCC Driver Improvement' AS SubName, '254' AS ParentId
	UNION SELECT 'Gloucestershire' AS Owner, '310' AS Id, 'GCC WDU' AS SubName, '254' AS ParentId
	UNION SELECT 'Gloucestershire' AS Owner, '262' AS Id, 'Images Files' AS SubName, '255' AS ParentId
	UNION SELECT 'Gloucestershire' AS Owner, '257' AS Id, 'Client Page Documents' AS SubName, '256' AS ParentId
	UNION SELECT 'Gloucestershire' AS Owner, '259' AS Id, 'Images Files' AS SubName, '256' AS ParentId
	UNION SELECT 'Staffordshire County Council' AS Owner, '280' AS Id, 'Staffordshire Police' AS SubName, '279' AS ParentId
	UNION SELECT 'Drivesafe' AS Owner, '286' AS Id, 'Drivesafe' AS SubName, '281' AS ParentId
	UNION SELECT 'Sussex' AS Owner, '296' AS Id, 'East Sussex' AS SubName, '292' AS ParentId
	UNION SELECT 'Sussex' AS Owner, '297' AS Id, 'West Sussex' AS SubName, '292' AS ParentId
	UNION SELECT 'Staffordshire County Council (a)' AS Owner, '313' AS Id, 'Staffordshire County Council' AS SubName, '312' AS ParentId
	UNION SELECT 'Staffordshire County Council (a)' AS Owner, '314' AS Id, 'Staffordshire Police' AS SubName, '312' AS ParentId
	UNION SELECT 'Cleveland' AS Owner, '333' AS Id, 'NSAC' AS SubName, '332' AS ParentId
	UNION SELECT 'Cleveland' AS Owner, '334' AS Id, 'D4C' AS SubName, '332' AS ParentId
	UNION SELECT 'Cleveland' AS Owner, '335' AS Id, 'NDAC' AS SubName, '332' AS ParentId
	UNION SELECT 'Cleveland' AS Owner, '336' AS Id, 'WDU' AS SubName, '332' AS ParentId
	UNION SELECT 'Cleveland' AS Owner, '337' AS Id, 'Maps' AS SubName, '332' AS ParentId
	UNION SELECT 'Drivesafe' AS Owner, NULL AS Id, 'GMP Div F - Swinton' AS Subname, NULL AS ParentId
	UNION SELECT 'Drivesafe' AS Owner, NULL AS Id, 'GMP Div G - Tameside' AS Subname, NULL AS ParentId
	UNION SELECT 'Drivesafe' AS Owner, NULL AS Id, 'GMP Div J - Stockport' AS Subname, NULL AS ParentId
	UNION SELECT 'Drivesafe' AS Owner, NULL AS Id, 'GMP Div K - Bolton' AS Subname, NULL AS ParentId
	UNION SELECT 'Drivesafe' AS Owner, NULL AS Id, 'GMP Div L - Wigan' AS Subname, NULL AS ParentId
	UNION SELECT 'Drivesafe' AS Owner, NULL AS Id, 'GMP Div M - Trafford' AS Subname, NULL AS ParentId
	UNION SELECT 'Drivesafe' AS Owner, NULL AS Id, 'GMP Div N - Bury' AS Subname, NULL AS ParentId
	UNION SELECT 'Drivesafe' AS Owner, NULL AS Id, 'GMP Div P - Rochdale' AS Subname, NULL AS ParentId
	UNION SELECT 'Sussex' AS Owner, NULL AS Id, 'East Sussex County Council' AS Subname, NULL AS ParentId
	UNION SELECT 'Essex County Council' AS Owner, NULL AS Id, 'Essex County Council' AS Subname, NULL AS ParentId
	UNION SELECT 'Gloucestershire County Council' AS Owner, NULL AS Id, 'Gloucestershire Constabulary' AS Subname, NULL AS ParentId
	UNION SELECT 'Gloucestershire County Council' AS Owner, NULL AS Id, 'Gloucestershire County Council' AS Subname, NULL AS ParentId
	UNION SELECT 'Drivesafe' AS Owner, NULL AS Id, 'GMP Div A - North Manchester' AS Subname, NULL AS ParentId
	UNION SELECT 'Drivesafe' AS Owner, NULL AS Id, 'GMP Div B - Metropolitan' AS Subname, NULL AS ParentId
	UNION SELECT 'Drivesafe' AS Owner, NULL AS Id, 'GMP Div C - South Manchester' AS Subname, NULL AS ParentId
	UNION SELECT 'Drivesafe' AS Owner, NULL AS Id, 'GMP Div Q - Oldham' AS Subname, NULL AS ParentId
	UNION SELECT 'Drivesafe' AS Owner, NULL AS Id, 'Merseyside Police' AS Subname, NULL AS ParentId
	UNION SELECT 'Norfolk County Council' AS Owner, NULL AS Id, 'Norfolk Constabulary' AS Subname, NULL AS ParentId
	UNION SELECT 'Norfolk County Council' AS Owner, NULL AS Id, 'Norfolk County Council' AS Subname, NULL AS ParentId
	UNION SELECT 'Drivesafe' AS Owner, NULL AS Id, 'Prodrive' AS Subname, NULL AS ParentId
	UNION SELECT 'Staffordshire County Council (a)' AS Owner, NULL AS Id, 'Staffordshire County Council' AS Subname, NULL AS ParentId
	UNION SELECT 'Staffordshire County Council (a)' AS Owner, NULL AS Id, 'Staffordshire County Council (a)' AS Subname, NULL AS ParentId
	UNION SELECT 'Sussex County Council' AS Owner, NULL AS Id, 'Sussex County Council' AS Subname, NULL AS ParentId
	UNION SELECT 'Sussex County Council' AS Owner, NULL AS Id, 'Sussex Police' AS Subname, NULL AS ParentId
	UNION SELECT 'Sussex County Council' AS Owner, NULL AS Id, 'Sussex Safer Roads Partnership' AS Subname, NULL AS ParentId

	GO
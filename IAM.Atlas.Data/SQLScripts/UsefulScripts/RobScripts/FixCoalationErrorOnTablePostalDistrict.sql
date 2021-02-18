SELECT
    col.name, col.collation_name
FROM 
    sys.columns col
WHERE
    object_id = OBJECT_ID('PostalDistrict')
	
IF EXISTS(SELECT * FROM sys.indexes WHERE name = 'IX_PostalDistrict_PostcodeArea' AND object_id = OBJECT_ID('PostalDistrict'))
BEGIN
	DROP INDEX IX_PostalDistrict_PostcodeArea 
	ON dbo.PostalDistrict;
END

IF EXISTS(SELECT * FROM sys.indexes WHERE name = 'IX_PostalDistrict_PostcodeDistrict' AND object_id = OBJECT_ID('PostalDistrict'))
BEGIN
	DROP INDEX IX_PostalDistrict_PostcodeDistrict 
	ON dbo.PostalDistrict;
END

IF EXISTS(SELECT * FROM sys.indexes WHERE name = 'IX_PostalDistrict_PostTown' AND object_id = OBJECT_ID('PostalDistrict'))
BEGIN
	DROP INDEX IX_PostalDistrict_PostTown 
	ON dbo.PostalDistrict;
END

IF EXISTS(SELECT * FROM sys.indexes WHERE name = 'IX_PostalDistrict_FormerPostalCounty' AND object_id = OBJECT_ID('PostalDistrict'))
BEGIN
	DROP INDEX IX_PostalDistrict_FormerPostalCounty 
	ON dbo.PostalDistrict;
END

ALTER TABLE PostalDistrict
  ALTER COLUMN PostcodeArea VARCHAR(2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
  
ALTER TABLE PostalDistrict
  ALTER COLUMN PostcodeDistrict VARCHAR(4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
  
ALTER TABLE PostalDistrict
  ALTER COLUMN PostTown VARCHAR(200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
  
ALTER TABLE PostalDistrict
  ALTER COLUMN FormerPostalCounty VARCHAR(200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL

  
/*
	Create Index IX_PostalDistrict_PostcodeArea
*/
CREATE INDEX IX_PostalDistrict_PostcodeArea
ON dbo.PostalDistrict (PostcodeArea)

/*
	Create Index IX_PostalDistrict_PostcodeDistrict
*/
CREATE INDEX IX_PostalDistrict_PostcodeDistrict
ON dbo.PostalDistrict (PostcodeDistrict)

/*
	Create Index IX_PostalDistrict_PostTown
*/
CREATE INDEX IX_PostalDistrict_PostTown
ON dbo.PostalDistrict (PostTown)

/*
	Create Index IX_PostalDistrict_FormerPostalCounty
*/
CREATE INDEX IX_PostalDistrict_FormerPostalCounty
ON dbo.PostalDistrict (FormerPostalCounty)

SELECT
    col.name, col.collation_name
FROM 
    sys.columns col
WHERE
    object_id = OBJECT_ID('PostalDistrict')
	
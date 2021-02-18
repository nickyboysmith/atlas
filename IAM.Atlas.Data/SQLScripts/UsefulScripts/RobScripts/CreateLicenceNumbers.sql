

DECLARE @Name VARCHAR(5) = 'GARGANTUAL';
DECLARE @Number INT = 123450;

SELECT '|| drivingLicenseNumber == "' + @Name + CAST((@Number) AS VARCHAR) + 'RS9GD"'
UNION
SELECT '|| drivingLicenseNumber == "' + @Name + CAST((@Number + 1) AS VARCHAR) + 'RS9GD"'
UNION
SELECT '|| drivingLicenseNumber == "' + @Name + CAST((@Number + 2) AS VARCHAR) + 'RS9GD"'
UNION
SELECT '|| drivingLicenseNumber == "' + @Name + CAST((@Number + 3) AS VARCHAR) + 'RS9GD"'
UNION
SELECT '|| drivingLicenseNumber == "' + @Name + CAST((@Number + 4) AS VARCHAR) + 'RS9GD"'
UNION
SELECT '|| drivingLicenseNumber == "' + @Name + CAST((@Number + 5) AS VARCHAR) + 'RS9GD"'
UNION
SELECT '|| drivingLicenseNumber == "' + @Name + CAST((@Number + 6) AS VARCHAR) + 'RS9GD"'
UNION
SELECT '|| drivingLicenseNumber == "' + @Name + CAST((@Number + 7) AS VARCHAR) + 'RS9GD"'
UNION
SELECT '|| drivingLicenseNumber == "' + @Name + CAST((@Number + 8) AS VARCHAR) + 'RS9GD"'
UNION
SELECT '|| drivingLicenseNumber == "' + @Name + CAST((@Number + 9) AS VARCHAR) + 'RS9GD"'


SELECT '"' + @Name + CAST((@Number) AS VARCHAR) + 'RS9GD"'
UNION
SELECT '"' + @Name + CAST((@Number + 1) AS VARCHAR) + 'RS9GD"'
UNION
SELECT '"' + @Name + CAST((@Number + 2) AS VARCHAR) + 'RS9GD"'
UNION
SELECT '"' + @Name + CAST((@Number + 3) AS VARCHAR) + 'RS9GD"'
UNION
SELECT '"' + @Name + CAST((@Number + 4) AS VARCHAR) + 'RS9GD"'
UNION
SELECT '"' + @Name + CAST((@Number + 5) AS VARCHAR) + 'RS9GD"'
UNION
SELECT '"' + @Name + CAST((@Number + 6) AS VARCHAR) + 'RS9GD"'
UNION
SELECT '"' + @Name + CAST((@Number + 7) AS VARCHAR) + 'RS9GD"'
UNION
SELECT '"' + @Name + CAST((@Number + 8) AS VARCHAR) + 'RS9GD"'
UNION
SELECT '"' + @Name + CAST((@Number + 9) AS VARCHAR) + 'RS9GD"'
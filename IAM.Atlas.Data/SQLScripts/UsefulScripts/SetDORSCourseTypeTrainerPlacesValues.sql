-- the following line is commented out so the user is reminded to set the variable
-- DECLARE @organisationId INT;


BEGIN TRAN

UPDATE coursetype 
SET dorsonly = 1, mintheorytrainers = 1, maxtheorytrainers = 2, maxplaces = 26
WHERE organisationId = @organisationId 
AND title in ('National Speed Awareness Course', 
				'National Speed Awareness 20',
				'Motorcycle',
				'What''s Driving Us?');

UPDATE coursetype 
SET dorsonly = 1, 
	mintheorytrainers = 0, 
	maxtheorytrainers = 0,
	minpracticaltrainers = 1, 
	maxpracticaltrainers = 1, 
	maxplaces = 2
WHERE organisationId = @organisationId 
AND title in ('Driving 4 Change');
				
UPDATE coursetype 
SET dorsonly = 1, 
	mintheorytrainers = 1, 
	maxtheorytrainers = 2, 
	minpracticaltrainers = 1, 
	maxpracticaltrainers = 13, 
	maxplaces = 26
WHERE organisationId = @organisationId 
AND title in ('Driver Alertness');




-- rollback 
-- commit
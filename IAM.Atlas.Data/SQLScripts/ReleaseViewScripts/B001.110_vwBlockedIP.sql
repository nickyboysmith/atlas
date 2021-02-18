
/*
	SCRIPT: Create a view to show all data on table BlockIP
	Author: Dan Hough
	Created: 14/12/2016
*/

	/*
		Drop the Procedure if it already exists
	*/		
	IF OBJECT_ID('dbo.vwBlockedIP', 'V') IS NOT NULL
	BEGIN
		DROP VIEW dbo.vwBlockedIP;
	END		
	GO

	/*
		Create View vwBlockedIP
	*/
	CREATE VIEW dbo.vwBlockedIP AS	
		
		SELECT Id
			, BlockedIp
			, DateBlocked
			, BlockDisabled
			, CreatedBy
			, CreatedByUserId
			, BlockDisabledByUserId
			, Comments
		FROM dbo.BlockIP;


GO

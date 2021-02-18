
/*
	SCRIPT: Create a view to show some data from SystemControl
	Author: Nick Smith
	Created: 18/10/2017
*/

	/*
		Drop the Procedure if it already exists
	*/		
	IF OBJECT_ID('dbo.vwSystemStatus', 'V') IS NOT NULL
	BEGIN
		DROP VIEW dbo.vwSystemStatus;
	END		
	GO

	/*
		Create View vwSystemStatus
	*/
	CREATE VIEW dbo.vwSystemStatus AS	
		
		SELECT SystemAvailable
			, SystemStatus
			, SystemStatusColour
			, SystemBlockedMessage
			, AtlasSystemName
			, AtlasSystemCode
			, AtlasSystemType
			, OnlineBookingBlocked
			, OnlineBookingSystemNoticeOn
			, OnlineBookingSystemNoticeMessage
			, OnlineBookingSystemNoticeClickHereOn
			, OnlineBookingSystemNoticeClickHereMessage
			, OnlineBookingSystemNoticeClickHereLink
			, OnlineBookingSystemNoticeColour
		FROM dbo.SystemControl
		WHERE Id = 1; 

GO

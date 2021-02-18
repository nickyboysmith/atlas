		/*
			Drop the View if it already exists
			NB - Used in vwClientDetail
		*/
		IF OBJECT_ID('dbo.vwClientCourseBookingsCourseRemovals_SubView', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwClientCourseBookingsCourseRemovals_SubView;
		END		
		GO
		/*
			Create vwClientCourseBookingsCourseRemovals_SubView

			Shows a Client's course bookings and removals.  If the removedFromCourseId is null then they are still on the course.

		*/
		CREATE VIEW dbo.vwClientCourseBookingsCourseRemovals_SubView
		AS

			SELECT TOP 1
				cc.clientId AS clientId,
				cc.courseid AS bookedCourseId,
				cc.dateAdded AS dateAdded,
				ccr.courseid AS removedFromCourseId,
				ccr.dateRemoved AS dateRemoved
			FROM 
			courseClient cc
			LEFT JOIN courseclientREMOVED ccr ON cc.courseid = ccr.courseid 
												AND cc.clientId = ccr.clientId 
												AND cc.dateadded < ccr.dateremoved
			ORDER BY cc.dateAdded DESC, ccr.dateRemoved DESC;

		GO

		/*********************************************************************************************************************/
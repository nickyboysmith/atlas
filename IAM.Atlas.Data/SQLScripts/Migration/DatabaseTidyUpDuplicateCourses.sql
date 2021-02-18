
		--/*
		IF OBJECT_ID('tempdb..#TidyUpCourse', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #TidyUpCourse;
		END
		IF OBJECT_ID('tempdb..#CoursesToDelete', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #CoursesToDelete;
		END
		--*/

		
		PRINT('');PRINT('*CREATE #TidyUpCourse');
		SELECT DISTINCT TUC.PreviousCourseId AS PreviousCourseId
		INTO #TidyUpCourse
		FROM (
			SELECT CPI.PreviousCourseId, COUNT(*) AS CNT
			FROM [dbo].[CoursePreviousId] CPI
			GROUP BY CPI.PreviousCourseId
			HAVING COUNT(*) > 1
			) TUC
		WHERE TUC.PreviousCourseId IS NOT NULL
		
		PRINT('');PRINT('*CREATE #CoursesToDelete');
		SELECT CPI.PreviousCourseId, CPI.CourseId
		INTO #CoursesToDelete
		FROM #TidyUpCourse TUC
		INNER JOIN [dbo].[CoursePreviousId] CPI ON CPI.PreviousCourseId = TUC.PreviousCourseId
		INNER JOIN [dbo].[Course] C ON C.Id = CPI.CourseId
		WHERE C.Id NOT IN (SELECT TOP 1 CPI2.CourseId
								FROM [dbo].[CoursePreviousId] CPI2
								WHERE CPI2.PreviousCourseId = TUC.PreviousCourseId)


		PRINT('');PRINT('*DELETE ClientOnlineBookingState');
		DELETE D
		FROM #CoursesToDelete CTD
		INNER JOIN ClientOnlineBookingState D ON D.CourseId = CTD.CourseId
		WHERE CTD.CourseId IS NOT NULL
		
		PRINT('');PRINT('*DELETE CourseClient');
		DELETE D
		FROM #CoursesToDelete CTD
		INNER JOIN CourseClient D ON D.CourseId = CTD.CourseId
		WHERE CTD.CourseId IS NOT NULL
		
		PRINT('');PRINT('*DELETE CourseClientPayment');
		DELETE D
		FROM #CoursesToDelete CTD
		INNER JOIN CourseClientPayment D ON D.CourseId = CTD.CourseId
		WHERE CTD.CourseId IS NOT NULL
		
		PRINT('');PRINT('*DELETE CourseClientRemoved');
		DELETE D
		FROM #CoursesToDelete CTD
		INNER JOIN CourseClientRemoved D ON D.CourseId = CTD.CourseId
		WHERE CTD.CourseId IS NOT NULL
		
		PRINT('');PRINT('*DELETE CourseDate');
		DELETE D
		FROM #CoursesToDelete CTD
		INNER JOIN CourseDate D ON D.CourseId = CTD.CourseId
		WHERE CTD.CourseId IS NOT NULL
		
		PRINT('');PRINT('*DELETE CourseDateClientAttendance');
		DELETE D
		FROM #CoursesToDelete CTD
		INNER JOIN CourseDateClientAttendance D ON D.CourseId = CTD.CourseId
		WHERE CTD.CourseId IS NOT NULL
		
		PRINT('');PRINT('*DELETE CourseDateTrainerAttendance');
		DELETE D
		FROM #CoursesToDelete CTD
		INNER JOIN CourseDateTrainerAttendance D ON D.CourseId = CTD.CourseId
		WHERE CTD.CourseId IS NOT NULL
		
		PRINT('');PRINT('*DELETE CourseDocument');
		DELETE D
		FROM #CoursesToDelete CTD
		INNER JOIN CourseDocument D ON D.CourseId = CTD.CourseId
		WHERE CTD.CourseId IS NOT NULL
		
		PRINT('');PRINT('*DELETE CourseDocumentTemplate');
		DELETE D
		FROM #CoursesToDelete CTD
		INNER JOIN CourseDocumentTemplate D ON D.CourseId = CTD.CourseId
		WHERE CTD.CourseId IS NOT NULL
		
		PRINT('');PRINT('*DELETE CourseLanguage');
		DELETE D
		FROM #CoursesToDelete CTD
		INNER JOIN CourseLanguage D ON D.CourseId = CTD.CourseId
		WHERE CTD.CourseId IS NOT NULL
		
		PRINT('');PRINT('*DELETE CourseNote');
		DELETE D
		FROM #CoursesToDelete CTD
		INNER JOIN CourseNote D ON D.CourseId = CTD.CourseId
		WHERE CTD.CourseId IS NOT NULL
		
		PRINT('');PRINT('*DELETE CourseOverBookingNotification');
		DELETE D
		FROM #CoursesToDelete CTD
		INNER JOIN CourseOverBookingNotification D ON D.CourseId = CTD.CourseId
		WHERE CTD.CourseId IS NOT NULL
		
		PRINT('');PRINT('*DELETE CourseQuickSearch');
		DELETE D
		FROM #CoursesToDelete CTD
		INNER JOIN CourseQuickSearch D ON D.CourseId = CTD.CourseId
		WHERE CTD.CourseId IS NOT NULL
		
		PRINT('');PRINT('*DELETE CourseSchedule');
		DELETE D
		FROM #CoursesToDelete CTD
		INNER JOIN CourseSchedule D ON D.CourseId = CTD.CourseId
		WHERE CTD.CourseId IS NOT NULL
		
		PRINT('');PRINT('*DELETE CourseTrainer');
		DELETE D
		FROM #CoursesToDelete CTD
		INNER JOIN CourseTrainer D ON D.CourseId = CTD.CourseId
		WHERE CTD.CourseId IS NOT NULL
				
		PRINT('');PRINT('*DELETE CourseVenue');
		DELETE D
		FROM #CoursesToDelete CTD
		INNER JOIN CourseVenue D ON D.CourseId = CTD.CourseId
		WHERE CTD.CourseId IS NOT NULL
		
		PRINT('');PRINT('*DELETE CoursePreviousId');
		DELETE D
		FROM #CoursesToDelete CTD
		INNER JOIN CoursePreviousId D ON D.CourseId = CTD.CourseId
		WHERE CTD.CourseId IS NOT NULL
		
		PRINT('');PRINT('*DELETE Course');
		DELETE D
		FROM #CoursesToDelete CTD
		INNER JOIN Course D ON D.Id = CTD.CourseId
		WHERE CTD.CourseId IS NOT NULL




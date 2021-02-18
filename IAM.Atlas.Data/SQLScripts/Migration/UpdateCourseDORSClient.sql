
			INSERT INTO [dbo].[CourseDORSClient] (
						CourseId
						, ClientId
						, DateAdded
						, DORSNotified
						, DateDORSNotified
						, DORSAttendanceRef
						, DORSAttendanceStateIdentifier
						, NumberOfDORSNotificationAttempts
						, DateDORSNotificationAttempted
						, PaidInFull
						, OnlyPartPaymentMade
						, DatePaidInFull
						)
			SELECT DISTINCT
				CO.Id			AS CourseId
				, CL.Id			AS ClientId
				, CC.DateAdded	AS DateAdded
				, 'True'		AS DORSNotified
				, CC.DateAdded	AS DateDORSNotified
				, NULL			AS DORSAttendanceRef
				, 1				AS DORSAttendanceStateIdentifier
				, 0				AS NumberOfDORSNotificationAttempts
				, NULL			AS DateDORSNotificationAttempted
				, (CASE WHEN CCP.ID IS NULL 
						THEN 'False'
						ELSE 'True'
						END)		AS PaidInFull
				, 'False'			AS OnlyPartPaymentMade
				, P.TransactionDate	AS DatePaidInFull
			FROM [dbo].[Course] CO
			INNER JOIN [dbo].[CourseClient] CC ON CC.CourseId = CO.Id
			INNER JOIN [dbo].[Client] CL ON CL.Id = CC.ClientId
			LEFT JOIN [dbo].[CourseClientPayment] CCP ON CCP.CourseId = CO.Id
														AND CCP.ClientId = CC.ClientId
			LEFT JOIN [dbo].[Payment] P ON P.Id = CCP.PaymentId
			LEFT JOIN [dbo].[CourseDORSClient] CDC ON CDC.CourseId = CO.Id
													AND CDC.ClientId = CL.Id
			WHERE CO.DORSCourse = 'True' --Only if it is a DORS Course will data be inserted
			AND CDC.Id IS NULL -- Not Already on Table
			;


			UPDATE [dbo].[CourseDORSClient]
			SET DORSAttendanceStateIdentifier = 1
			WHERE DORSAttendanceStateIdentifier IS NULL;
			
			UPDATE [dbo].[CourseDORSClient]
			SET DORSAttendanceRef = ABS(Checksum(NewID()) % 123456785) + 10
			WHERE DORSAttendanceRef IS NULL;

			INSERT INTO [dbo].[ClientDORSData] (
					ClientId
					, DORSAttendanceRef
					, DateUpdated)
			SELECT DISTINCT
				CDC.ClientId
				, CDC.DORSAttendanceRef
				, CDC.DateAdded
			FROM [dbo].[CourseDORSClient] CDC
			LEFT JOIN [dbo].[ClientDORSData] CDD ON CDD.ClientId = CDC.ClientId
			WHERE CDD.Id IS NULL
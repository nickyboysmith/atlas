-- View Trainer Session Availability By Month
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwTrainerSessionAvailabilityByMonth', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwTrainerSessionAvailabilityByMonth;
		END		
		GO

		/*
			Create vwTrainerSessionAvailabilityByMonth
		*/
		CREATE VIEW vwTrainerSessionAvailabilityByMonth
		AS
			SELECT 
				T.Id					AS TrainerId
				, CDM.TheYear			AS TheYear
				, CDM.TheMonth			AS TheMonth
				, CDM.DateRowLetter		AS DateRowLetter
				, CDM.DateRowNumber		AS DateRowNumber
				--Monday
				, CDM.DateColumn1						AS DateColumn1
				, FORMAT(CDM.DateColumn1, 'dd MMM')		AS TitleColumn1
				, (CASE WHEN MONTH(CDM.DateColumn1) < CDM.TheMonth
						THEN 'True' ELSE 'False' END)	AS Column1PreviousMonthDate
				, (CASE WHEN MONTH(CDM.DateColumn1) > CDM.TheMonth
						THEN 'True' ELSE 'False' END)	AS Column1NextMonthDate
				, TSUM1.FullyBooked						AS Column1FullyBooked
				, TSUM1.PartiallyBooked					AS Column1PartiallyBooked
				, TSUM1.ShowSession1					AS ShowColumn1Session1Available
				, TSUM1.ShowSession1Booked				AS ShowColumn1Session1Booked
				, TSUM1.ShowSession2					AS ShowColumn1Session2Available
				, TSUM1.ShowSession2Booked				AS ShowColumn1Session2Booked
				, TSUM1.ShowSession3					AS ShowColumn1Session3Available
				, TSUM1.ShowSession3Booked				AS ShowColumn1Session3Booked
				--Tuesday
				, CDM.DateColumn2						AS DateColumn2
				, FORMAT(CDM.DateColumn2, 'dd MMM')		AS TitleColumn2
				, (CASE WHEN MONTH(CDM.DateColumn2) < CDM.TheMonth
						THEN 'True' ELSE 'False' END)	AS Column2PreviousMonthDate
				, (CASE WHEN MONTH(CDM.DateColumn2) > CDM.TheMonth
						THEN 'True' ELSE 'False' END)	AS Column2NextMonthDate
				, TSUM2.FullyBooked						AS Column2FullyBooked
				, TSUM2.PartiallyBooked					AS Column2PartiallyBooked
				, TSUM2.ShowSession1					AS ShowColumn2Session1Available
				, TSUM2.ShowSession1Booked				AS ShowColumn2Session1Booked
				, TSUM2.ShowSession2					AS ShowColumn2Session2Available
				, TSUM2.ShowSession2Booked				AS ShowColumn2Session2Booked
				, TSUM2.ShowSession3					AS ShowColumn2Session3Available
				, TSUM2.ShowSession3Booked				AS ShowColumn2Session3Booked
				--Wednesday
				, CDM.DateColumn3						AS DateColumn3
				, FORMAT(CDM.DateColumn3, 'dd MMM')		AS TitleColumn3
				, (CASE WHEN MONTH(CDM.DateColumn3) < CDM.TheMonth
						THEN 'True' ELSE 'False' END)	AS Column3PreviousMonthDate
				, (CASE WHEN MONTH(CDM.DateColumn3) > CDM.TheMonth
						THEN 'True' ELSE 'False' END)	AS Column3NextMonthDate
				, TSUM3.FullyBooked						AS Column3FullyBooked
				, TSUM3.PartiallyBooked					AS Column3PartiallyBooked
				, TSUM3.ShowSession1					AS ShowColumn3Session1Available
				, TSUM3.ShowSession1Booked				AS ShowColumn3Session1Booked
				, TSUM3.ShowSession2					AS ShowColumn3Session2Available
				, TSUM3.ShowSession2Booked				AS ShowColumn3Session2Booked
				, TSUM3.ShowSession3					AS ShowColumn3Session3Available
				, TSUM3.ShowSession3Booked				AS ShowColumn3Session3Booked
				--Thursday
				, CDM.DateColumn4						AS DateColumn4
				, FORMAT(CDM.DateColumn4, 'dd MMM')		AS TitleColumn4
				, (CASE WHEN MONTH(CDM.DateColumn4) < CDM.TheMonth
						THEN 'True' ELSE 'False' END)	AS Column4PreviousMonthDate
				, (CASE WHEN MONTH(CDM.DateColumn4) > CDM.TheMonth
						THEN 'True' ELSE 'False' END)	AS Column4NextMonthDate
				, TSUM4.FullyBooked						AS Column4FullyBooked
				, TSUM4.PartiallyBooked					AS Column4PartiallyBooked
				, TSUM4.ShowSession1					AS ShowColumn4Session1Available
				, TSUM4.ShowSession1Booked				AS ShowColumn4Session1Booked
				, TSUM4.ShowSession2					AS ShowColumn4Session2Available
				, TSUM4.ShowSession2Booked				AS ShowColumn4Session2Booked
				, TSUM4.ShowSession3					AS ShowColumn4Session3Available
				, TSUM4.ShowSession3Booked				AS ShowColumn4Session3Booked
				--Friday
				, CDM.DateColumn5						AS DateColumn5
				, FORMAT(CDM.DateColumn5, 'dd MMM')		AS TitleColumn5
				, (CASE WHEN MONTH(CDM.DateColumn5) < CDM.TheMonth
						THEN 'True' ELSE 'False' END)	AS Column5PreviousMonthDate
				, (CASE WHEN MONTH(CDM.DateColumn5) > CDM.TheMonth
						THEN 'True' ELSE 'False' END)	AS Column5NextMonthDate
				, TSUM5.FullyBooked						AS Column5FullyBooked
				, TSUM5.PartiallyBooked					AS Column5PartiallyBooked
				, TSUM5.ShowSession1					AS ShowColumn5Session1Available
				, TSUM5.ShowSession1Booked				AS ShowColumn5Session1Booked
				, TSUM5.ShowSession2					AS ShowColumn5Session2Available
				, TSUM5.ShowSession2Booked				AS ShowColumn5Session2Booked
				, TSUM5.ShowSession3					AS ShowColumn5Session3Available
				, TSUM5.ShowSession3Booked				AS ShowColumn5Session3Booked
				--Saturday
				, CDM.DateColumn6						AS DateColumn6
				, FORMAT(CDM.DateColumn6, 'dd MMM')		AS TitleColumn6
				, (CASE WHEN MONTH(CDM.DateColumn6) < CDM.TheMonth
						THEN 'True' ELSE 'False' END)	AS Column6PreviousMonthDate
				, (CASE WHEN MONTH(CDM.DateColumn6) > CDM.TheMonth
						THEN 'True' ELSE 'False' END)	AS Column6NextMonthDate
				, TSUM6.FullyBooked						AS Column6FullyBooked
				, TSUM6.PartiallyBooked					AS Column6PartiallyBooked
				, TSUM6.ShowSession1					AS ShowColumn6Session1Available
				, TSUM6.ShowSession1Booked				AS ShowColumn6Session1Booked
				, TSUM6.ShowSession2					AS ShowColumn6Session2Available
				, TSUM6.ShowSession2Booked				AS ShowColumn6Session2Booked
				, TSUM6.ShowSession3					AS ShowColumn6Session3Available
				, TSUM6.ShowSession3Booked				AS ShowColumn6Session3Booked
				--Sunday
				, CDM.DateColumn7						AS DateColumn7
				, FORMAT(CDM.DateColumn7, 'dd MMM')		AS TitleColumn7
				, (CASE WHEN MONTH(CDM.DateColumn7) < CDM.TheMonth
						THEN 'True' ELSE 'False' END)	AS Column7PreviousMonthDate
				, (CASE WHEN MONTH(CDM.DateColumn7) > CDM.TheMonth
						THEN 'True' ELSE 'False' END)	AS Column7NextMonthDate
				, TSUM7.FullyBooked						AS Column7FullyBooked
				, TSUM7.PartiallyBooked					AS Column7PartiallyBooked
				, TSUM7.ShowSession1					AS ShowColumn7Session1Available
				, TSUM7.ShowSession1Booked				AS ShowColumn7Session1Booked
				, TSUM7.ShowSession2					AS ShowColumn7Session2Available
				, TSUM7.ShowSession2Booked				AS ShowColumn7Session2Booked
				, TSUM7.ShowSession3					AS ShowColumn7Session3Available
				, TSUM7.ShowSession3Booked				AS ShowColumn7Session3Booked
			FROM Trainer T
			CROSS JOIN vwCalendarDatesByMonth CDM
			LEFT JOIN vwTrainerAvailabilitySessionSummaryFlags TSUM1			ON TSUM1.TrainerId = T.Id
																		AND TSUM1.[Date] = CDM.DateColumn1
			LEFT JOIN vwTrainerAvailabilitySessionSummaryFlags TSUM2			ON TSUM2.TrainerId = T.Id
																		AND TSUM2.[Date] = CDM.DateColumn2
			LEFT JOIN vwTrainerAvailabilitySessionSummaryFlags TSUM3			ON TSUM3.TrainerId = T.Id
																		AND TSUM3.[Date] = CDM.DateColumn3
			LEFT JOIN vwTrainerAvailabilitySessionSummaryFlags TSUM4			ON TSUM4.TrainerId = T.Id
																		AND TSUM4.[Date] = CDM.DateColumn4
			LEFT JOIN vwTrainerAvailabilitySessionSummaryFlags TSUM5			ON TSUM5.TrainerId = T.Id
																		AND TSUM5.[Date] = CDM.DateColumn5
			LEFT JOIN vwTrainerAvailabilitySessionSummaryFlags TSUM6			ON TSUM6.TrainerId = T.Id
																		AND TSUM6.[Date] = CDM.DateColumn6
			LEFT JOIN vwTrainerAvailabilitySessionSummaryFlags TSUM7			ON TSUM7.TrainerId = T.Id
																		AND TSUM7.[Date] = CDM.DateColumn7
			--ORDER BY
			--	TheYear
			--	, TheMonth
			--	, DateRowLetter
			--	, DateRowNumber
			;
			
		GO
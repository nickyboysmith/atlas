/*
	SCRIPT: Create a function to Split a Word With Upper Case Characters into it's Words
	Author: Robert Newnham
	Created: 26/04/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP039_23.01_CreateFunctionudfReturnDateTimeFromUKStringDate.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a function to return a DateTime From a Date in UK Date Format';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Function if it already exists
	*/		
	IF OBJECT_ID('dbo.udfReturnDateTimeFromUKStringDate', 'FN') IS NOT NULL
	BEGIN
		DROP FUNCTION dbo.udfReturnDateTimeFromUKStringDate;
	END		
	GO
	
	/*
		Create udfReturnDateTimeFromUKStringDate
	*/
	CREATE FUNCTION [dbo].[udfReturnDateTimeFromUKStringDate] (@UkStringDate VARCHAR(40))
	RETURNS DateTime
	AS
	BEGIN
		DECLARE @UkDateTime AS DATETIME = NULL;

		--This Function is Assuming Date or Date time in the Format "dd/mm/yyyy" or "dd/mm/yyyy hh:nn:ss"
		--									should also work for "dd-mm-yyyy" or "dd-mm-yyyy hh:nn:ss"
		--									should also work for "dd mm yyyy" or "dd mm yyyy hh:nn:ss"
		DECLARE @DatePartSeperator AS CHAR = SUBSTRING(@UkStringDate,3,1);

		SET @UkDateTime = CAST(
								REPLACE(
								REPLACE(
								REPLACE(
								REPLACE(
								REPLACE(
								REPLACE(
								REPLACE(
								REPLACE(
								REPLACE(
								REPLACE(
								REPLACE(
								REPLACE(@UkStringDate
										, @DatePartSeperator + '01' + @DatePartSeperator,'-Jan-')
										, @DatePartSeperator + '02' + @DatePartSeperator,'-Feb-')
										, @DatePartSeperator + '03' + @DatePartSeperator,'-Mar-')
										, @DatePartSeperator + '04' + @DatePartSeperator,'-Apr-')
										, @DatePartSeperator + '05' + @DatePartSeperator,'-May-')
										, @DatePartSeperator + '06' + @DatePartSeperator,'-Jun-')
										, @DatePartSeperator + '07' + @DatePartSeperator,'-Jul-')
										, @DatePartSeperator + '08' + @DatePartSeperator,'-Aug-')
										, @DatePartSeperator + '09' + @DatePartSeperator,'-Sep-')
										, @DatePartSeperator + '10' + @DatePartSeperator,'-Oct-')
										, @DatePartSeperator + '11' + @DatePartSeperator,'-Nov-')
										, @DatePartSeperator + '12' + @DatePartSeperator,'-Dec-')
								 AS DATETIME)

		RETURN @UkDateTime;
		
	END
	GO
	
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP039_23.01_CreateFunctionudfReturnDateTimeFromUKStringDate.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO

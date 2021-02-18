



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
	CREATE FUNCTION [dbo].[udfReturnDateTimeFromUKStringDate] ( @UkStringDate VARCHAR(40))
	RETURNS DateTime
	AS
	BEGIN
		DECLARE @UkDateTime AS DATETIME = NULL;

		--This Function is Assuming Date or Date time in the Format "dd/mm/yyyy" or "dd/mm/yyyy hh:nn:ss"
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
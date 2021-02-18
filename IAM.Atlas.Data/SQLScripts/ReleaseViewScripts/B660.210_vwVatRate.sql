

/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwVatRate', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwVatRate;
END		
GO
/*
	Create vwVatRate
*/
CREATE VIEW vwVatRate 
AS
	/**********************************************************************************************/
	SELECT DISTINCT
		VR.Id											AS VatRateId
		, VR.VATRate
		, VR.EffectiveFromDate
		, VR.AddedByUserId
		, VR.DateAdded
		, T.EffectiveToDate
		, CAST((CASE WHEN T.EffectiveToDate IS NULL
				THEN 'True' ELSE 'False' END) AS BIT)	AS CurrentVatRate
	FROM dbo.VatRate VR
	LEFT JOIN (
		SELECT 
			VR.[Id]											AS VatRateId
			, VR.[VATRate]									AS VATRate
			, VR.[EffectiveFromDate]						AS EffectiveFromDate
			, VR.[AddedByUserId]							AS AddedByUserId
			, VR.[DateAdded]								AS DateAdded
			, MIN(VR2.EffectiveFromDate)					AS EffectiveToDate
		FROM dbo.VatRate VR
		CROSS JOIN dbo.VatRate VR2 
		WHERE VR2.EffectiveFromDate > VR.EffectiveFromDate
		GROUP BY VR.[Id], VR.[VATRate], VR.[EffectiveFromDate], VR.[AddedByUserId], VR.[DateAdded]
		) T ON T.VatRateId = VR.Id
	WHERE VR.Deleted = 'False'
	;
GO
/*********************************************************************************************************************/
--Rob's script to delete duplicates whilst leaving the earlist entry (based on min(id))
-- select for testing


--DELETE CC
select * 
FROM [dbo].[ClientPayment] CC
--where paymentid = 5695260
INNER JOIN (
      SELECT paymentid, COUNT(*) AS CNT, MIN(Id) AS DTE
      FROM [dbo].[ClientPayment]
      GROUP BY paymentId
      HAVING COUNT(*) > 1
      ) CCT ON  CCT.PaymentId = CC.PaymentId
WHERE CC.Id != CCT.DTE;
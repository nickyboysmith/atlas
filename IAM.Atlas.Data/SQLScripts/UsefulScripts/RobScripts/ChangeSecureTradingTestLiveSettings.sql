/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [Id]
      ,[OrganisationId]
      ,[PaymentProviderId]
      ,[Key]
      ,[Value]
  FROM [dbo].[OrganisationPaymentProviderCredential]
  WHERE OrganisationId = 30

  UPDATE [OrganisationPaymentProviderCredential]
  SET [Value] = 'Atlas2016@iam.org.uk'
  WHERE OrganisationId = 30
  AND PaymentProviderId = 2
  AND [Key] = 'username'
  
  UPDATE [OrganisationPaymentProviderCredential]
  SET [Value] = 'Atlas2016Payment' --'Atlas2016Payment'
  WHERE OrganisationId = 30
  AND PaymentProviderId = 2
  AND [Key] = 'password'
  
  UPDATE [OrganisationPaymentProviderCredential]
  SET [Value] = 'test_pdse70272' --'pdsessex26545' --'test_pdse70272'
  WHERE OrganisationId = 30
  AND PaymentProviderId = 2
  AND [Key] = 'sitereference'




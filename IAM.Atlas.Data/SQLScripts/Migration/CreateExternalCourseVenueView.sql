

CREATE EXTERNAL TABLE [migration].[vwRobsMigrationView_CourseVenue](
		[crs_ID] [int] NOT NULL
		, [crs_ct_id] [int]
		, [crs_places] [int]
		, [crs_placesAutoReserved] [int]
		, [crs_vnu_ID] [int]
		, [orct_org_id] [int]
		, [org_name] VARCHAR(50)
		, [vnu_description] VARCHAR(64))
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/


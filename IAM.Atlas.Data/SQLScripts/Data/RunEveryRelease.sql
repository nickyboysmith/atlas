

/*
	RunEveryRelease.sql

	This script should be run every release.
	It will ensure certain System And Administration Tables are populated.
	The Scripts will need to allow for that the data may already exist.

	Date Created: 07/07/2015 By Robert Newnham
	Date Updated: 14/01/2016 By Robert Newnham Added DORS System States
	Date Updated: 29/07/2016 by Robert Newnham
	Date Updated: 26/08/2016 by Robert Newnham
	Date Updated: 17/10/2016 by Robert Newnham add TrainerVenue Update

	Updates:
*/

DECLARE @ScriptName VARCHAR(100) = 'RunEveryRelease.sql';
DECLARE @ScriptComments VARCHAR(800) = 'This Script Ensures Certain Data rows exist in tables.';


/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments;

	----Ensures 'Atlas System' user exists on the DB
	DECLARE @NewLine VARCHAR(2) = CHAR(13) + CHAR(10);
	DECLARE @processName VARCHAR(200) = 'RunEveryRelease.sql'
	DECLARE @processNumber INT = 0;

	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, 'Running RunEveryRelease: - Starting Process';

	IF NOT EXISTS(SELECT Name FROM [User] WHERE Name = 'Atlas System')
	BEGIN
		PRINT('');PRINT('*Ensures "Atlas System" user exists on the DB');
		INSERT INTO [User] (LoginId, [Password], Name, Email, [Disabled], PasswordChangeRequired, LoginNotified)
		VALUES ('AtlasSystem', 'Password', 'Atlas System', '', 1, 0, 1)
	END

	----- Adds data to SystemControl - only one record will be on this table.
	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - SystemControl';

	BEGIN
		PRINT('');PRINT('*Adds data to SystemControl - only one record will be on this table');

		BEGIN
			IF OBJECT_ID('tempdb..#SystemControl', 'U') IS NOT NULL
			BEGIN
				DROP TABLE #SystemControl;
			END

			DECLARE @SystemDBName VARCHAR(40);
			SELECT @SystemDBName=DB_NAME();

			SELECT 1 AS Id
				, 'True' AS SystemAvailable
				, '' AS SystemStatus
				, '' AS SystemStatusColour
				, '' AS SystemBlockedMessage
				, 3 AS MaxFailedLogins
				, 300 AS SystemInactivityTimeout
				, 30 AS SystemInactivityWarning
				, (SELECT TOP 1 Id FROM [User] WHERE Name = 'Atlas System') AS AtlasSystemUserId
				, 'Atlas System' AS AtlasSystemFromName
				, 'Atlas2016@iam.org.uk' AS AtlasSystemFromEmail
				, 'Atlas Administrators' AS FeedbackName
				, 'Atlas.SystemsAdministrators@iam.org.uk' AS FeedbackEmail
				, 500 AS MaxNumberEmailsToProcessAtOnce
				, 5000 AS MaxNumberEmailsToProcessPerDay
				, (CASE @SystemDBName WHEN  'Atlas_Dev' THEN 'Atlas Developer'
						WHEN 'Atlas_Test' THEN 'Atlas Test'
						WHEN'Atlas_UAT' THEN 'Atlas User Acceptance Testing'
						WHEN'Atlas_DEMO' THEN 'Atlas Demo'
						WHEN'Atlas_Live' THEN 'Atlas Live'
						ELSE '*UNKNOWN*' END) AS AtlasSystemName
				, (CASE @SystemDBName WHEN  'Atlas_Dev' THEN 'Dev'
						WHEN 'Atlas_Test' THEN 'Test'
						WHEN'Atlas_UAT' THEN 'UAT'
						WHEN'Atlas_DEMO' THEN 'Demo'
						WHEN'Atlas_Live' THEN 'Live'
						ELSE '????' END) AS AtlasSystemCode
				, (CASE @SystemDBName WHEN  'Atlas_Dev' THEN 'Dev'
						WHEN 'Atlas_Test' THEN 'Test'
						WHEN'Atlas_UAT' THEN 'Test'
						WHEN'Atlas_DEMO' THEN 'Demo'
						WHEN'Atlas_Live' THEN 'Live'
						ELSE 'Test' END) AS AtlasSystemType
			INTO #SystemControl;

			INSERT INTO SystemControl (Id
										, SystemAvailable
										, SystemStatus
										, SystemStatusColour
										, SystemBlockedMessage
										, MaxFailedLogins
										, SystemInactivityTimeout
										, SystemInactivityWarning
										, AtlasSystemUserId
										, AtlasSystemFromName
										, AtlasSystemFromEmail
										, FeedbackName
										, FeedbackEmail
										, MaxNumberEmailsToProcessAtOnce
										, MaxNumberEmailsToProcessPerDay
										, AtlasSystemName
										, AtlasSystemCode
										, AtlasSystemType
										)
			SELECT Id
				, SystemAvailable
				, SystemStatus
				, SystemStatusColour
				, SystemBlockedMessage
				, MaxFailedLogins
				, SystemInactivityTimeout
				, SystemInactivityWarning
				, AtlasSystemUserId
				, AtlasSystemFromName
				, AtlasSystemFromEmail
				, FeedbackName
				, FeedbackEmail
				, MaxNumberEmailsToProcessAtOnce
				, MaxNumberEmailsToProcessPerDay
				, AtlasSystemName
				, AtlasSystemCode
				, AtlasSystemType
			FROM #SystemControl
			WHERE NOT EXISTS (SELECT * FROM SystemControl WHERE Id = 1);

			UPDATE SC
				SET SC.SystemAvailable = (CASE WHEN SC.SystemAvailable IS NULL THEN SC2.SystemAvailable ELSE SC.SystemAvailable END)
				, SC.SystemStatus = (CASE WHEN SC.SystemStatus IS NULL THEN SC2.SystemStatus ELSE SC.SystemStatus END)
				, SC.SystemStatusColour = (CASE WHEN SC.SystemStatusColour IS NULL THEN SC2.SystemStatusColour ELSE SC.SystemStatusColour END)
				, SC.SystemBlockedMessage = (CASE WHEN SC.SystemBlockedMessage IS NULL THEN SC2.SystemBlockedMessage ELSE SC.SystemBlockedMessage END)
				, SC.MaxFailedLogins = (CASE WHEN SC.MaxFailedLogins IS NULL THEN SC2.MaxFailedLogins ELSE SC.MaxFailedLogins END)
				, SC.SystemInactivityTimeout = (CASE WHEN SC.SystemInactivityTimeout IS NULL THEN SC2.SystemInactivityTimeout ELSE SC.SystemInactivityTimeout END)
				, SC.SystemInactivityWarning = (CASE WHEN SC.SystemInactivityWarning IS NULL THEN SC2.SystemInactivityWarning ELSE SC.SystemInactivityWarning END)
				, SC.AtlasSystemUserId = (CASE WHEN SC.AtlasSystemUserId IS NULL THEN SC2.AtlasSystemUserId ELSE SC.AtlasSystemUserId END)
				, SC.AtlasSystemFromName = (CASE WHEN SC.AtlasSystemFromName IS NULL THEN SC2.AtlasSystemFromName ELSE SC.AtlasSystemFromName END)
				, SC.AtlasSystemFromEmail = (CASE WHEN SC.AtlasSystemFromEmail IS NULL THEN SC2.AtlasSystemFromEmail ELSE SC.AtlasSystemFromEmail END)
				, SC.FeedbackName = (CASE WHEN SC.FeedbackName IS NULL THEN SC2.FeedbackName ELSE SC.FeedbackName END)
				, SC.FeedbackEmail = (CASE WHEN SC.FeedbackEmail IS NULL THEN SC2.FeedbackEmail ELSE SC.FeedbackEmail END)
				, SC.MaxNumberEmailsToProcessAtOnce = (CASE WHEN SC.MaxNumberEmailsToProcessAtOnce IS NULL OR SC.MaxNumberEmailsToProcessAtOnce <=0
															THEN SC2.MaxNumberEmailsToProcessAtOnce
															ELSE SC.MaxNumberEmailsToProcessAtOnce END)
				, SC.MaxNumberEmailsToProcessPerDay = (CASE WHEN SC.MaxNumberEmailsToProcessPerDay IS NULL OR SC.MaxNumberEmailsToProcessPerDay <=0
															THEN SC2.MaxNumberEmailsToProcessPerDay
															ELSE SC.MaxNumberEmailsToProcessPerDay END)
				, SC.AtlasSystemName = (CASE WHEN SC.AtlasSystemName IS NULL THEN SC2.AtlasSystemName ELSE SC.AtlasSystemName END)
				, SC.AtlasSystemCode = (CASE WHEN SC.AtlasSystemCode IS NULL THEN SC2.AtlasSystemCode ELSE SC.AtlasSystemCode END)
				, SC.AtlasSystemType = (CASE WHEN SC.AtlasSystemType IS NULL THEN SC2.AtlasSystemType ELSE SC.AtlasSystemType END)
			FROM SystemControl SC
			INNER JOIN #SystemControl SC2 ON SC2.Id = SC.Id
			WHERE SC.Id = 1;
		END
	END


	/* Ensure SchedulerControl Table has required Row */
	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - SchedulerControl';
	BEGIN
		PRINT('');PRINT('*Ensure Control Table has required Row');
		INSERT INTO dbo.SchedulerControl (Id, EmailScheduleDisabled, ReportScheduleDisabled, ArchiveScheduleDisabled, SMSScheduleDisabled)
		SELECT 1 AS Id
				, 'False' AS EmailScheduleDisabled
				, 'False' AS ReportScheduleDisabled
				, 'False' AS ArchiveScheduleDisabled
				, 'False' AS SMSScheduleDisabled
		WHERE NOT EXISTS (SELECT * FROM dbo.SchedulerControl WHERE Id = 1);
	END

	--Administration Menu Groups
	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - Administration Menu Groups';
	BEGIN
		PRINT('');PRINT('*Administration Menu Groups');
		IF OBJECT_ID('tempdb..#AdministrationMenuGroup', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #AdministrationMenuGroup;
		END

		SELECT DISTINCT Title, Description, SortNumber
		INTO #AdministrationMenuGroup
		FROM (
				SELECT 'Organisation' AS Title, 'Organisation Administration Group' AS Description, 10 AS SortNumber
				UNION
				SELECT 'User' AS Title, 'User Administration Group' AS Description, 20 AS SortNumber
				UNION
				SELECT 'Security' AS Title, 'System Security Administration Group' AS Description, 30 AS SortNumber
				UNION
				SELECT 'Payment' AS Title, 'Payment Administration Group' AS Description, 40 AS SortNumber
				UNION
				SELECT 'Course' AS Title, 'Course Administration Group' AS Description, 50 AS SortNumber
				UNION
				SELECT 'Client' AS Title, 'Client Administration Group' AS Description, 60 AS SortNumber
				) AMG


		INSERT INTO dbo.AdministrationMenuGroup (Title, Description, SortNumber)
		SELECT DISTINCT Title, Description, SortNumber
		FROM #AdministrationMenuGroup NewAMG
		WHERE NOT EXISTS (SELECT * FROM dbo.AdministrationMenuGroup AMG WHERE NewAMG.Title = AMG.Title)
	END

	/* Populate Language Table */
	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - Populate Language Table';
	BEGIN
		PRINT('');PRINT('*Populate Language Table');
		INSERT INTO dbo.[Language] (EnglishName, NativeName, ISO_Code)
		SELECT EnglishName, NativeName, ISO_Code
		FROM (
			SELECT 'Abkhaz' AS EnglishName,'аҧсуа бызшәа, аҧсшәа' AS NativeName,'ab' AS ISO_Code
			UNION
			SELECT 'Afar','Afaraf','aa'
			UNION
			SELECT 'Afrikaans','Afrikaans','af'
			UNION
			SELECT 'Akan','Akan','ak'
			UNION
			SELECT 'Albanian','Shqip','sq'
			UNION
			SELECT 'Amharic','አማርኛ','am'
			UNION
			SELECT 'Arabic','العربية','ar'
			UNION
			SELECT 'Aragonese','aragonés','an'
			UNION
			SELECT 'Armenian','Հայերեն','hy'
			UNION
			SELECT 'Assamese','অসমীয়া','as'
			UNION
			SELECT 'Avaric','авар мацӀ, магӀарул мацӀ','av'
			UNION
			SELECT 'Avestan','avesta','ae'
			UNION
			SELECT 'Aymara','aymar aru','ay'
			UNION
			SELECT 'Azerbaijani','azərbaycan dili','az'
			UNION
			SELECT 'Bambara','bamanankan','bm'
			UNION
			SELECT 'Bashkir','башҡорт теле','ba'
			UNION
			SELECT 'Basque','euskara, euskera','eu'
			UNION
			SELECT 'Belarusian','беларуская мова','be'
			UNION
			SELECT 'Bengali, Bangla','বাংলা','bn'
			UNION
			SELECT 'Bihari','भोजपुरी','bh'
			UNION
			SELECT 'Bislama','Bislama','bi'
			UNION
			SELECT 'Bosnian','bosanski jezik','bs'
			UNION
			SELECT 'Breton','brezhoneg','br'
			UNION
			SELECT 'Bulgarian','български език','bg'
			UNION
			SELECT 'Burmese','ဗမာစာ','my'
			UNION
			SELECT 'Catalan','català','ca'
			UNION
			SELECT 'Chamorro','Chamoru','ch'
			UNION
			SELECT 'Chechen','нохчийн мотт','ce'
			UNION
			SELECT 'Chichewa, Chewa, Nyanja','chiCheŵa, chinyanja','ny'
			UNION
			SELECT 'Chinese','中文 (Zhōngwén), 汉语, 漢語','zh'
			UNION
			SELECT 'Chuvash','чӑваш чӗлхи','cv'
			UNION
			SELECT 'Cornish','Kernewek','kw'
			UNION
			SELECT 'Corsican','corsu, lingua corsa','co'
			UNION
			SELECT 'Cree','ᓀᐦᐃᔭᐍᐏᐣ','cr'
			UNION
			SELECT 'Croatian','hrvatski jezik','hr'
			UNION
			SELECT 'Czech','čeština, český jazyk','cs'
			UNION
			SELECT 'Danish','dansk','da'
			UNION
			SELECT 'Divehi, Dhivehi, Maldivian','ދިވެހި','dv'
			UNION
			SELECT 'Dutch','Nederlands, Vlaams','nl'
			UNION
			SELECT 'Dzongkha','རྫོང་ཁ','dz'
			UNION
			SELECT 'English','English','en'
			UNION
			SELECT 'Esperanto','Esperanto','eo'
			UNION
			SELECT 'Estonian','eesti, eesti keel','et'
			UNION
			SELECT 'Ewe','Eʋegbe','ee'
			UNION
			SELECT 'Faroese','føroyskt','fo'
			UNION
			SELECT 'Fijian','vosa Vakaviti','fj'
			UNION
			SELECT 'Finnish','suomi, suomen kieli','fi'
			UNION
			SELECT 'French','français, langue française','fr'
			UNION
			SELECT 'Fula, Fulah, Pulaar, Pular','Fulfulde, Pulaar, Pular','ff'
			UNION
			SELECT 'Galician','galego','gl'
			UNION
			SELECT 'Georgian','ქართული','ka'
			UNION
			SELECT 'German','Deutsch','de'
			UNION
			SELECT 'Greek (modern)','ελληνικά','el'
			UNION
			SELECT 'Guaraní','Avañe''ẽ','gn'
			UNION
			SELECT 'Gujarati','ગુજરાતી','gu'
			UNION
			SELECT 'Haitian, Haitian Creole','Kreyòl ayisyen','ht'
			UNION
			SELECT 'Hausa','(Hausa) هَوُسَ','ha'
			UNION
			SELECT 'Hebrew (modern)','עברית','he'
			UNION
			SELECT 'Herero','Otjiherero','hz'
			UNION
			SELECT 'Hindi','हिन्दी, हिंदी','hi'
			UNION
			SELECT 'Hiri Motu','Hiri Motu','ho'
			UNION
			SELECT 'Hungarian','magyar','hu'
			UNION
			SELECT 'Interlingua','Interlingua','ia'
			UNION
			SELECT 'Indonesian','Bahasa Indonesia','id'
			UNION
			SELECT 'Interlingue','Originally called Occidental; then Interlingue after WWII','ie'
			UNION
			SELECT 'Irish','Gaeilge','ga'
			UNION
			SELECT 'Igbo','Asụsụ Igbo','ig'
			UNION
			SELECT 'Inupiaq','Iñupiaq, Iñupiatun','ik'
			UNION
			SELECT 'Ido','Ido','io'
			UNION
			SELECT 'Icelandic','Íslenska','is'
			UNION
			SELECT 'Italian','italiano','it'
			UNION
			SELECT 'Inuktitut','ᐃᓄᒃᑎᑐᑦ','iu'
			UNION
			SELECT 'Japanese','日本語 (にほんご)','ja'
			UNION
			SELECT 'Javanese','basa Jawa','jv'
			UNION
			SELECT 'Kalaallisut, Greenlandic','kalaallisut, kalaallit oqaasii','kl'
			UNION
			SELECT 'Kannada','ಕನ್ನಡ','kn'
			UNION
			SELECT 'Kanuri','Kanuri','kr'
			UNION
			SELECT 'Kashmiri','कश्मीरी, كشميري‎','ks'
			UNION
			SELECT 'Kazakh','қазақ тілі','kk'
			UNION
			SELECT 'Khmer','ខ្មែរ, ខេមរភាសា, ភាសាខ្មែរ','km'
			UNION
			SELECT 'Kikuyu, Gikuyu','Gĩkũyũ','ki'
			UNION
			SELECT 'Kinyarwanda','Ikinyarwanda','rw'
			UNION
			SELECT 'Kyrgyz','Кыргызча, Кыргыз тили','ky'
			UNION
			SELECT 'Komi','коми кыв','kv'
			UNION
			SELECT 'Kongo','Kikongo','kg'
			UNION
			SELECT 'Korean','한국어, 조선어','ko'
			UNION
			SELECT 'Kurdish','Kurdî, كوردی‎','ku'
			UNION
			SELECT 'Kwanyama, Kuanyama','Kuanyama','kj'
			UNION
			SELECT 'Latin','latine, lingua latina','la'
			UNION
			SELECT 'Luxembourgish, Letzeburgesch','Lëtzebuergesch','lb'
			UNION
			SELECT 'Ganda','Luganda','lg'
			UNION
			SELECT 'Limburgish, Limburgan, Limburger','Limburgs','li'
			UNION
			SELECT 'Lingala','Lingála','ln'
			UNION
			SELECT 'Lao','ພາສາລາວ','lo'
			UNION
			SELECT 'Lithuanian','lietuvių kalba','lt'
			UNION
			SELECT 'Luba-Katanga','Tshiluba','lu'
			UNION
			SELECT 'Latvian','latviešu valoda','lv'
			UNION
			SELECT 'Manx','Gaelg, Gailck','gv'
			UNION
			SELECT 'Macedonian','македонски јазик','mk'
			UNION
			SELECT 'Malagasy','fiteny malagasy','mg'
			UNION
			SELECT 'Malay','bahasa Melayu, بهاس ملايو‎','ms'
			UNION
			SELECT 'Malayalam','മലയാളം','ml'
			UNION
			SELECT 'Maltese','Malti','mt'
			UNION
			SELECT 'Māori','te reo Māori','mi'
			UNION
			SELECT 'Marathi (Marāṭhī)','मराठी','mr'
			UNION
			SELECT 'Marshallese','Kajin M̧ajeļ','mh'
			UNION
			SELECT 'Mongolian','Монгол хэл','mn'
			UNION
			SELECT 'Nauru','Ekakairũ Naoero','na'
			UNION
			SELECT 'Navajo, Navaho','Diné bizaad','nv'
			UNION
			SELECT 'Northern Ndebele','isiNdebele','nd'
			UNION
			SELECT 'Nepali','नेपाली','ne'
			UNION
			SELECT 'Ndonga','Owambo','ng'
			UNION
			SELECT 'Norwegian Bokmål','Norsk bokmål','nb'
			UNION
			SELECT 'Norwegian Nynorsk','Norsk nynorsk','nn'
			UNION
			SELECT 'Norwegian','Norsk','no'
			UNION
			SELECT 'Nuosu','ꆈꌠ꒿ Nuosuhxop','ii'
			UNION
			SELECT 'Southern Ndebele','isiNdebele','nr'
			UNION
			SELECT 'Occitan','occitan, lenga d''òc','oc'
			UNION
			SELECT 'Ojibwe, Ojibwa','ᐊᓂᔑᓈᐯᒧᐎᓐ','oj'
			UNION
			SELECT 'Old Church Slavonic, Church Slavonic, Old Bulgarian','ѩзыкъ словѣньскъ','cu'
			UNION
			SELECT 'Oromo','Afaan Oromoo','om'
			UNION
			SELECT 'Oriya','ଓଡ଼ିଆ','or'
			UNION
			SELECT 'Ossetian, Ossetic','ирон æвзаг','os'
			UNION
			SELECT 'Panjabi, Punjabi','ਪੰਜਾਬੀ, پنجابی‎','pa'
			UNION
			SELECT 'Pāli','पाऴि','pi'
			UNION
			SELECT 'Persian (Farsi)','فارسی','fa'
			UNION
			SELECT 'Polish','język polski, polszczyzna','pl'
			UNION
			SELECT 'Pashto, Pushto','پښتو','ps'
			UNION
			SELECT 'Portuguese','português','pt'
			UNION
			SELECT 'Quechua','Runa Simi, Kichwa','qu'
			UNION
			SELECT 'Romansh','rumantsch grischun','rm'
			UNION
			SELECT 'Kirundi','Ikirundi','rn'
			UNION
			SELECT 'Romanian','limba română','ro'
			UNION
			SELECT 'Russian','Русский','ru'
			UNION
			SELECT 'Sanskrit (Saṁskṛta)','संस्कृतम्','sa'
			UNION
			SELECT 'Sardinian','sardu','sc'
			UNION
			SELECT 'Sindhi','सिन्धी, سنڌي، سندھی‎','sd'
			UNION
			SELECT 'Northern Sami','Davvisámegiella','se'
			UNION
			SELECT 'Samoan','gagana fa''a Samoa','sm'
			UNION
			SELECT 'Sango','yângâ tî sängö','sg'
			UNION
			SELECT 'Serbian','српски језик','sr'
			UNION
			SELECT 'Scottish Gaelic, Gaelic','Gàidhlig','gd'
			UNION
			SELECT 'Shona','chiShona','sn'
			UNION
			SELECT 'Sinhala, Sinhalese','සිංහල','si'
			UNION
			SELECT 'Slovak','slovenčina, slovenský jazyk','sk'
			UNION
			SELECT 'Slovene','slovenski jezik, slovenščina','sl'
			UNION
			SELECT 'Somali','Soomaaliga, af Soomaali','so'
			UNION
			SELECT 'Southern Sotho','Sesotho','st'
			UNION
			SELECT 'Spanish','español','es'
			UNION
			SELECT 'Sundanese','Basa Sunda','su'
			UNION
			SELECT 'Swahili','Kiswahili','sw'
			UNION
			SELECT 'Swati','SiSwati','ss'
			UNION
			SELECT 'Swedish','svenska','sv'
			UNION
			SELECT 'Tamil','தமிழ்','ta'
			UNION
			SELECT 'Telugu','తెలుగు','te'
			UNION
			SELECT 'Tajik','тоҷикӣ, toçikī, تاجیکی‎','tg'
			UNION
			SELECT 'Thai','ไทย','th'
			UNION
			SELECT 'Tigrinya','ትግርኛ','ti'
			UNION
			SELECT 'Tibetan Standard, Tibetan, Central','བོད་ཡིག','bo'
			UNION
			SELECT 'Turkmen','Türkmen, Түркмен','tk'
			UNION
			SELECT 'Tagalog','Wikang Tagalog, ᜏᜒᜃᜅ᜔ ᜆᜄᜎᜓᜄ᜔','tl'
			UNION
			SELECT 'Tswana','Setswana','tn'
			UNION
			SELECT 'Tonga (Tonga Islands)','faka Tonga','to'
			UNION
			SELECT 'Turkish','Türkçe','tr'
			UNION
			SELECT 'Tsonga','Xitsonga','ts'
			UNION
			SELECT 'Tatar','татар теле, tatar tele','tt'
			UNION
			SELECT 'Twi','Twi','tw'
			UNION
			SELECT 'Tahitian','Reo Tahiti','ty'
			UNION
			SELECT 'Uyghur','ئۇيغۇرچە‎, Uyghurche','ug'
			UNION
			SELECT 'Ukrainian','українська мова','uk'
			UNION
			SELECT 'Urdu','اردو','ur'
			UNION
			SELECT 'Uzbek','Oʻzbek, Ўзбек, أۇزبېك‎','uz'
			UNION
			SELECT 'Venda','Tshivenḓa','ve'
			UNION
			SELECT 'Vietnamese','Tiếng Việt','vi'
			UNION
			SELECT 'Volapük','Volapük','vo'
			UNION
			SELECT 'Walloon','walon','wa'
			UNION
			SELECT 'Welsh','Cymraeg','cy'
			UNION
			SELECT 'Wolof','Wollof','wo'
			UNION
			SELECT 'Western Frisian','Frysk','fy'
			UNION
			SELECT 'Xhosa','isiXhosa','xh'
			UNION
			SELECT 'Yiddish','ייִדיש','yi'
			UNION
			SELECT 'Yoruba','Yorùbá','yo'
			UNION
			SELECT 'Zhuang, Chuang','Saɯ cueŋƅ, Saw cuengh','za'
			UNION
			SELECT 'Zulu','isiZulu','zu'
			) Lan
		WHERE NOT EXISTS (SELECT *
							FROM dbo.[Language] L
							WHERE Lan.EnglishName = Lan.EnglishName
							AND L.ISO_Code = Lan.ISO_Code)
		;

		UPDATE dbo.[Language]
		SET [Disabled] = 'false'
		WHERE [Disabled] IS NULL;
	END

	/*Update the PostalDistrict table*/
	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - PostalDistrict Table';
	BEGIN
		PRINT('');PRINT('*Update the PostalDistrict table');
		BEGIN
			DELETE
			FROM dbo.PostalDistrict;

			INSERT INTO dbo.PostalDistrict (PostcodeArea, PostcodeDistrict, PostTown, FormerPostalCounty)
			VALUES
			('AB','AB10','ABERDEEN','(Aberdeenshire)'),
			('AB','AB11','ABERDEEN','(Aberdeenshire)'),
			('AB','AB12','ABERDEEN','(Aberdeenshire)'),
			('AB','AB15','ABERDEEN','(Aberdeenshire)'),
			('AB','AB16','ABERDEEN','(Aberdeenshire)'),
			('AB','AB21','ABERDEEN','(Aberdeenshire)'),
			('AB','AB22','ABERDEEN','(Aberdeenshire)'),
			('AB','AB23','ABERDEEN','(Aberdeenshire)'),
			('AB','AB24','ABERDEEN','(Aberdeenshire)'),
			('AB','AB25','ABERDEEN','(Aberdeenshire)'),
			('AB','AB99','ABERDEEN','(Aberdeenshire)'),
			('AB','AB13','MILLTIMBER','Aberdeenshire'),
			('AB','AB14','PETERCULTER','Aberdeenshire'),
			('AB','AB30','LAURENCEKIRK','Kincardineshire'),
			('AB','AB31','BANCHORY','Kincardineshire'),
			('AB','AB32','WESTHILL','Aberdeenshire'),
			('AB','AB33','ALFORD','Aberdeenshire'),
			('AB','AB34','ABOYNE','(Aberdeenshire)'),
			('AB','AB35','BALLATER','Aberdeenshire'),
			('AB','AB36','STRATHDON','(Aberdeenshire)'),
			('AB','AB37','BALLINDALLOCH','Banffshire'),
			('AB','AB38','ABERLOUR','Banffshire'),
			('AB','AB39','STONEHAVEN','Kincardineshire'),
			('AB','AB41','ELLON','Aberdeenshire'),
			('AB','AB42','PETERHEAD','Aberdeenshire'),
			('AB','AB43','FRASERBURGH','Aberdeenshire'),
			('AB','AB44','MACDUFF','Banffshire'),
			('AB','AB45','BANFF','(Banffshire)'),
			('AB','AB51','INVERURIE','Aberdeenshire'),
			('AB','AB52','INSCH','Aberdeenshire'),
			('AB','AB53','TURRIFF','Aberdeenshire'),
			('AB','AB54','HUNTLY','Aberdeenshire'),
			('AB','AB55','KEITH','Banffshire'),
			('AB','AB56','BUCKIE','Banffshire'),
			('AL','AL01','ST. ALBANS','Hertfordshire'),
			('AL','AL1','ST. ALBANS','Hertfordshire'),
			('AL','AL2','ST. ALBANS','Hertfordshire'),
			('AL','AL3','ST. ALBANS','Hertfordshire'),
			('AL','AL4','ST. ALBANS','Hertfordshire'),
			('AL','AL05','HARPENDEN','Hertfordshire'),
			('AL','AL5','HARPENDEN','Hertfordshire'),
			('AL','AL06','WELWYN','Hertfordshire'),
			('AL','AL6','WELWYN','Hertfordshire'),
			('AL','AL7','WELWYN','Hertfordshire'),
			('AL','AL07','WELWYN GARDEN CITY','Hertfordshire'),
			('AL','AL7','WELWYN GARDEN CITY','Hertfordshire'),
			('AL','AL8','WELWYN GARDEN CITY','Hertfordshire'),
			('AL','AL09','HATFIELD','Hertfordshire'),
			('AL','AL9','HATFIELD','Hertfordshire'),
			('AL','AL10','HATFIELD','Hertfordshire'),
			('B','B001','BIRMINGHAM','(West Midlands)'),
			('B','B1','BIRMINGHAM','(West Midlands)'),
			('B','B2','BIRMINGHAM','(West Midlands)'),
			('B','B3','BIRMINGHAM','(West Midlands)'),
			('B','B4','BIRMINGHAM','(West Midlands)'),
			('B','B5','BIRMINGHAM','(West Midlands)'),
			('B','B6','BIRMINGHAM','(West Midlands)'),
			('B','B7','BIRMINGHAM','(West Midlands)'),
			('B','B8','BIRMINGHAM','(West Midlands)'),
			('B','B9','BIRMINGHAM','(West Midlands)'),
			('B','B10','BIRMINGHAM','(West Midlands)'),
			('B','B11','BIRMINGHAM','(West Midlands)'),
			('B','B12','BIRMINGHAM','(West Midlands)'),
			('B','B13','BIRMINGHAM','(West Midlands)'),
			('B','B14','BIRMINGHAM','(West Midlands)'),
			('B','B15','BIRMINGHAM','(West Midlands)'),
			('B','B16','BIRMINGHAM','(West Midlands)'),
			('B','B17','BIRMINGHAM','(West Midlands)'),
			('B','B18','BIRMINGHAM','(West Midlands)'),
			('B','B19','BIRMINGHAM','(West Midlands)'),
			('B','B20','BIRMINGHAM','(West Midlands)'),
			('B','B21','BIRMINGHAM','(West Midlands)'),
			('B','B23','BIRMINGHAM','(West Midlands)'),
			('B','B24','BIRMINGHAM','(West Midlands)'),
			('B','B25','BIRMINGHAM','(West Midlands)'),
			('B','B26','BIRMINGHAM','(West Midlands)'),
			('B','B27','BIRMINGHAM','(West Midlands)'),
			('B','B28','BIRMINGHAM','(West Midlands)'),
			('B','B29','BIRMINGHAM','(West Midlands)'),
			('B','B30','BIRMINGHAM','(West Midlands)'),
			('B','B31','BIRMINGHAM','(West Midlands)'),
			('B','B32','BIRMINGHAM','(West Midlands)'),
			('B','B33','BIRMINGHAM','(West Midlands)'),
			('B','B34','BIRMINGHAM','(West Midlands)'),
			('B','B35','BIRMINGHAM','(West Midlands)'),
			('B','B36','BIRMINGHAM','(West Midlands)'),
			('B','B37','BIRMINGHAM','(West Midlands)'),
			('B','B38','BIRMINGHAM','(West Midlands)'),
			('B','B40','BIRMINGHAM','(West Midlands)'),
			('B','B42','BIRMINGHAM','(West Midlands)'),
			('B','B43','BIRMINGHAM','(West Midlands)'),
			('B','B44','BIRMINGHAM','(West Midlands)'),
			('B','B45','BIRMINGHAM','(West Midlands)'),
			('B','B46','BIRMINGHAM','(West Midlands)'),
			('B','B47','BIRMINGHAM','(West Midlands)'),
			('B','B48','BIRMINGHAM','(West Midlands)'),
			('B','B99','BIRMINGHAM','(West Midlands)'),
			('B','B049','ALCESTER','Warwickshire'),
			('B','B49','ALCESTER','Warwickshire'),
			('B','B50','ALCESTER','Warwickshire'),
			('B','B060','BROMSGROVE','Worcestershire'),
			('B','B60','BROMSGROVE','Worcestershire'),
			('B','B61','BROMSGROVE','Worcestershire'),
			('B','B062','HALESOWEN','West Midlands'),
			('B','B62','HALESOWEN','West Midlands'),
			('B','B63','HALESOWEN','West Midlands'),
			('B','B064','CRADLEY HEATH','West Midlands'),
			('B','B64','CRADLEY HEATH','West Midlands'),
			('B','B065','ROWLEY REGIS','West Midlands'),
			('B','B65','ROWLEY REGIS','West Midlands'),
			('B','B066','SMETHWICK','West Midlands'),
			('B','B66','SMETHWICK','West Midlands'),
			('B','B67','SMETHWICK','West Midlands'),
			('B','B068','OLDBURY','West Midlands'),
			('B','B68','OLDBURY','West Midlands'),
			('B','B69','OLDBURY','West Midlands'),
			('B','B070','WEST BROMWICH','West Midlands'),
			('B','B70','WEST BROMWICH','West Midlands'),
			('B','B71','WEST BROMWICH','West Midlands'),
			('B','B072','SUTTON COLDFIELD','West Midlands'),
			('B','B72','SUTTON COLDFIELD','West Midlands'),
			('B','B73','SUTTON COLDFIELD','West Midlands'),
			('B','B74','SUTTON COLDFIELD','West Midlands'),
			('B','B75','SUTTON COLDFIELD','West Midlands'),
			('B','B76','SUTTON COLDFIELD','West Midlands'),
			('B','B077','TAMWORTH','Staffordshire'),
			('B','B77','TAMWORTH','Staffordshire'),
			('B','B78','TAMWORTH','Staffordshire'),
			('B','B79','TAMWORTH','Staffordshire'),
			('B','B080','STUDLEY','Warwickshire'),
			('B','B80','STUDLEY','Warwickshire'),
			('B','B090','SOLIHULL','West Midlands'),
			('B','B90','SOLIHULL','West Midlands'),
			('B','B91','SOLIHULL','West Midlands'),
			('B','B92','SOLIHULL','West Midlands'),
			('B','B93','SOLIHULL','West Midlands'),
			('B','B94','SOLIHULL','West Midlands'),
			('B','B095','HENLEY-IN-ARDEN','West Midlands'),
			('B','B95','HENLEY-IN-ARDEN','West Midlands'),
			('B','B096','REDDITCH','Worcestershire'),
			('B','B96','REDDITCH','Worcestershire'),
			('B','B97','REDDITCH','Worcestershire'),
			('B','B98','REDDITCH','Worcestershire'),
			('BA','BA01','BATH','(Avon)'),
			('BA','BA1','BATH','(Avon)'),
			('BA','BA2','BATH','(Avon)'),
			('BA','BA03','RADSTOCK','Avon'),
			('BA','BA3','RADSTOCK','Avon'),
			('BA','BA04','SHEPTON MALLET','Somerset'),
			('BA','BA4','SHEPTON MALLET','Somerset'),
			('BA','BA05','WELLS','Somerset'),
			('BA','BA5','WELLS','Somerset'),
			('BA','BA06','GLASTONBURY','Somerset'),
			('BA','BA6','GLASTONBURY','Somerset'),
			('BA','BA07','CASTLE CARY','Somerset'),
			('BA','BA7','CASTLE CARY','Somerset'),
			('BA','BA08','TEMPLECOMBE','Somerset'),
			('BA','BA8','TEMPLECOMBE','Somerset'),
			('BA','BA09','WINCANTON','Somerset'),
			('BA','BA9','WINCANTON','Somerset'),
			('BA','BA09','BRUTON','Somerset'),
			('BA','BA9','BRUTON','Somerset'),
			('BA','BA10','BRUTON','Somerset'),
			('BA','BA11','FROME','Somerset'),
			('BA','BA12','WARMINSTER','Wiltshire'),
			('BA','BA13','WESTBURY','Wiltshire'),
			('BA','BA14','TROWBRIDGE','Wiltshire'),
			('BA','BA15','BRADFORD-ON-AVON','Wiltshire'),
			('BA','BA16','STREET','Somerset'),
			('BA','BA20','YEOVIL','Somerset'),
			('BA','BA21','YEOVIL','Somerset'),
			('BA','BA22','YEOVIL','Somerset'),
			('BB','BB01','BLACKBURN','(Lancashire)'),
			('BB','BB1','BLACKBURN','(Lancashire)'),
			('BB','BB2','BLACKBURN','(Lancashire)'),
			('BB','BB6','BLACKBURN','(Lancashire)'),
			('BB','BB03','DARWEN','Lancashire'),
			('BB','BB3','DARWEN','Lancashire'),
			('BB','BB04','ROSSENDALE','Lancashire'),
			('BB','BB4','ROSSENDALE','Lancashire'),
			('BB','BB05','ACCRINGTON','Lancashire'),
			('BB','BB5','ACCRINGTON','Lancashire'),
			('BB','BB07','CLITHEROE','Lancashire'),
			('BB','BB7','CLITHEROE','Lancashire'),
			('BB','BB08','COLNE','Lancashire'),
			('BB','BB8','COLNE','Lancashire'),
			('BB','BB09','NELSON','Lancashire'),
			('BB','BB9','NELSON','Lancashire'),
			('BB','BB10','BURNLEY','Lancashire'),
			('BB','BB11','BURNLEY','Lancashire'),
			('BB','BB12','BURNLEY','Lancashire'),
			('BB','BB18','BARNOLDSWICK','Lancashire'),
			('BB','BB94','BARNOLDSWICK','Lancashire'),
			('BD','BD01','BRADFORD','West Yorkshire'),
			('BD','BD1','BRADFORD','West Yorkshire'),
			('BD','BD2','BRADFORD','West Yorkshire'),
			('BD','BD3','BRADFORD','West Yorkshire'),
			('BD','BD4','BRADFORD','West Yorkshire'),
			('BD','BD5','BRADFORD','West Yorkshire'),
			('BD','BD6','BRADFORD','West Yorkshire'),
			('BD','BD7','BRADFORD','West Yorkshire'),
			('BD','BD8','BRADFORD','West Yorkshire'),
			('BD','BD9','BRADFORD','West Yorkshire'),
			('BD','BD10','BRADFORD','West Yorkshire'),
			('BD','BD11','BRADFORD','West Yorkshire'),
			('BD','BD12','BRADFORD','West Yorkshire'),
			('BD','BD13','BRADFORD','West Yorkshire'),
			('BD','BD14','BRADFORD','West Yorkshire'),
			('BD','BD15','BRADFORD','West Yorkshire'),
			('BD','BD98','BRADFORD','West Yorkshire'),
			('BD','BD99','BRADFORD','West Yorkshire'),
			('BD','BD16','BINGLEY','West Yorkshire'),
			('BD','BD97','BINGLEY','West Yorkshire'),
			('BD','BD17','SHIPLEY','West Yorkshire'),
			('BD','BD18','SHIPLEY','West Yorkshire'),
			('BD','BD98','SHIPLEY','West Yorkshire'),
			('BD','BD19','CLECKHEATON','West Yorkshire'),
			('BD','BD20','KEIGHLEY','West Yorkshire'),
			('BD','BD21','KEIGHLEY','West Yorkshire'),
			('BD','BD22','KEIGHLEY','West Yorkshire'),
			('BD','BD23','SKIPTON','North Yorkshire'),
			('BD','BD24','SKIPTON','North Yorkshire'),
			('BD','BD24','SETTLE','North Yorkshire'),
			('BF','BF01','BFPO','ZZZZ non-geographic'),
			('BF','BF1','BFPO','ZZZZ non-geographic'),
			('BH','BH01','BOURNEMOUTH','(Dorset)'),
			('BH','BH1','BOURNEMOUTH','(Dorset)'),
			('BH','BH2','BOURNEMOUTH','(Dorset)'),
			('BH','BH3','BOURNEMOUTH','(Dorset)'),
			('BH','BH4','BOURNEMOUTH','(Dorset)'),
			('BH','BH5','BOURNEMOUTH','(Dorset)'),
			('BH','BH6','BOURNEMOUTH','(Dorset)'),
			('BH','BH7','BOURNEMOUTH','(Dorset)'),
			('BH','BH8','BOURNEMOUTH','(Dorset)'),
			('BH','BH9','BOURNEMOUTH','(Dorset)'),
			('BH','BH10','BOURNEMOUTH','(Dorset)'),
			('BH','BH11','BOURNEMOUTH','(Dorset)'),
			('BH','BH12','POOLE','Dorset'),
			('BH','BH13','POOLE','Dorset'),
			('BH','BH14','POOLE','Dorset'),
			('BH','BH15','POOLE','Dorset'),
			('BH','BH16','POOLE','Dorset'),
			('BH','BH17','POOLE','Dorset'),
			('BH','BH18','BROADSTONE','Dorset'),
			('BH','BH19','SWANAGE','Dorset'),
			('BH','BH20','WAREHAM','Dorset'),
			('BH','BH21','WIMBORNE','Dorset'),
			('BH','BH22','FERNDOWN','Dorset'),
			('BH','BH23','CHRISTCHURCH','Dorset'),
			('BH','BH24','RINGWOOD','Hampshire'),
			('BH','BH25','NEW MILTON','Hampshire'),
			('BH','BH31','VERWOOD','Dorset'),
			('BL','BL00','BURY','Lancashire'),
			('BL','BL0','BURY','Lancashire'),
			('BL','BL8','BURY','Lancashire'),
			('BL','BL9','BURY','Lancashire'),
			('BL','BL01','BOLTON','(Lancashire)'),
			('BL','BL1','BOLTON','(Lancashire)'),
			('BL','BL2','BOLTON','(Lancashire)'),
			('BL','BL3','BOLTON','(Lancashire)'),
			('BL','BL4','BOLTON','(Lancashire)'),
			('BL','BL5','BOLTON','(Lancashire)'),
			('BL','BL6','BOLTON','(Lancashire)'),
			('BL','BL7','BOLTON','(Lancashire)'),
			('BL','BL11','BOLTON','(Lancashire)'),
			('BL','BL78','BOLTON','(Lancashire)'),
			('BN','BN01','BRIGHTON','(East Sussex)'),
			('BN','BN1','BRIGHTON','(East Sussex)'),
			('BN','BN2','BRIGHTON','(East Sussex)'),
			('BN','BN41','BRIGHTON','(East Sussex)'),
			('BN','BN42','BRIGHTON','(East Sussex)'),
			('BN','BN45','BRIGHTON','(East Sussex)'),
			('BN','BN50','BRIGHTON','(East Sussex)'),
			('BN','BN51','BRIGHTON','(East Sussex)'),
			('BN','BN88','BRIGHTON','(East Sussex)'),
			('BN','BN03','HOVE','East Sussex'),
			('BN','BN3','HOVE','East Sussex'),
			('BN','BN52','HOVE','East Sussex'),
			('BN','BN05','HENFIELD','West Sussex'),
			('BN','BN5','HENFIELD','West Sussex'),
			('BN','BN06','HASSOCKS','West Sussex'),
			('BN','BN6','HASSOCKS','West Sussex'),
			('BN','BN07','LEWES','East Sussex'),
			('BN','BN7','LEWES','East Sussex'),
			('BN','BN8','LEWES','East Sussex'),
			('BN','BN09','NEWHAVEN','East Sussex'),
			('BN','BN9','NEWHAVEN','East Sussex'),
			('BN','BN10','PEACEHAVEN','East Sussex'),
			('BN','BN11','WORTHING','West Sussex'),
			('BN','BN12','WORTHING','West Sussex'),
			('BN','BN13','WORTHING','West Sussex'),
			('BN','BN14','WORTHING','West Sussex'),
			('BN','BN91','WORTHING','West Sussex'),
			('BN','BN99','WORTHING','West Sussex'),
			('BN','BN15','LANCING','West Sussex'),
			('BN','BN99','LANCING','West Sussex'),
			('BN','BN16','LITTLEHAMPTON','West Sussex'),
			('BN','BN17','LITTLEHAMPTON','West Sussex'),
			('BN','BN18','ARUNDEL','West Sussex'),
			('BN','BN20','EASTBOURNE','East Sussex'),
			('BN','BN21','EASTBOURNE','East Sussex'),
			('BN','BN22','EASTBOURNE','East Sussex'),
			('BN','BN23','EASTBOURNE','East Sussex'),
			('BN','BN24','PEVENSEY','East Sussex'),
			('BN','BN25','SEAFORD','East Sussex'),
			('BN','BN26','POLEGATE','East Sussex'),
			('BN','BN27','HAILSHAM','East Sussex'),
			('BN','BN43','SHOREHAM-BY-SEA','West Sussex'),
			('BN','BN44','STEYNING','West Sussex'),
			('BR','BR01','BROMLEY','(Kent)'),
			('BR','BR1','BROMLEY','(Kent)'),
			('BR','BR2','BROMLEY','(Kent)'),
			('BR','BR02','KESTON','Kent'),
			('BR','BR2','KESTON','Kent'),
			('BR','BR03','BECKENHAM','Kent'),
			('BR','BR3','BECKENHAM','Kent'),
			('BR','BR04','WEST WICKHAM','Kent'),
			('BR','BR4','WEST WICKHAM','Kent'),
			('BR','BR05','ORPINGTON','Kent'),
			('BR','BR5','ORPINGTON','Kent'),
			('BR','BR6','ORPINGTON','Kent'),
			('BR','BR07','CHISLEHURST','Kent'),
			('BR','BR7','CHISLEHURST','Kent'),
			('BR','BR08','SWANLEY','Kent'),
			('BR','BR8','SWANLEY','Kent'),
			('BS','BS00','BRISTOL','(Avon)'),
			('BS','BS0','BRISTOL','(Avon)'),
			('BS','BS1','BRISTOL','(Avon)'),
			('BS','BS2','BRISTOL','(Avon)'),
			('BS','BS3','BRISTOL','(Avon)'),
			('BS','BS4','BRISTOL','(Avon)'),
			('BS','BS5','BRISTOL','(Avon)'),
			('BS','BS6','BRISTOL','(Avon)'),
			('BS','BS7','BRISTOL','(Avon)'),
			('BS','BS8','BRISTOL','(Avon)'),
			('BS','BS9','BRISTOL','(Avon)'),
			('BS','BS10','BRISTOL','(Avon)'),
			('BS','BS11','BRISTOL','(Avon)'),
			('BS','BS13','BRISTOL','(Avon)'),
			('BS','BS14','BRISTOL','(Avon)'),
			('BS','BS15','BRISTOL','(Avon)'),
			('BS','BS16','BRISTOL','(Avon)'),
			('BS','BS20','BRISTOL','(Avon)'),
			('BS','BS30','BRISTOL','(Avon)'),
			('BS','BS31','BRISTOL','(Avon)'),
			('BS','BS32','BRISTOL','(Avon)'),
			('BS','BS34','BRISTOL','(Avon)'),
			('BS','BS35','BRISTOL','(Avon)'),
			('BS','BS36','BRISTOL','(Avon)'),
			('BS','BS37','BRISTOL','(Avon)'),
			('BS','BS39','BRISTOL','(Avon)'),
			('BS','BS40','BRISTOL','(Avon)'),
			('BS','BS41','BRISTOL','(Avon)'),
			('BS','BS48','BRISTOL','(Avon)'),
			('BS','BS49','BRISTOL','(Avon)'),
			('BS','BS80','BRISTOL','(Avon)'),
			('BS','BS98','BRISTOL','(Avon)'),
			('BS','BS99','BRISTOL','(Avon)'),
			('BS','BS21','CLEVEDON','Avon'),
			('BS','BS22','WESTON-SUPER-MARE','Avon'),
			('BS','BS23','WESTON-SUPER-MARE','Avon'),
			('BS','BS24','WESTON-SUPER-MARE','Avon'),
			('BS','BS25','WINSCOMBE','Avon'),
			('BS','BS26','AXBRIDGE','Somerset'),
			('BS','BS27','CHEDDAR','Somerset'),
			('BS','BS28','WEDMORE','Somerset'),
			('BS','BS29','BANWELL','Avon'),
			('BT','BT01','BELFAST','(County Antrim)'),
			('BT','BT1','BELFAST','(County Antrim)'),
			('BT','BT2','BELFAST','(County Antrim)'),
			('BT','BT3','BELFAST','(County Antrim)'),
			('BT','BT4','BELFAST','(County Antrim)'),
			('BT','BT5','BELFAST','(County Antrim)'),
			('BT','BT6','BELFAST','(County Antrim)'),
			('BT','BT7','BELFAST','(County Antrim)'),
			('BT','BT8','BELFAST','(County Antrim)'),
			('BT','BT9','BELFAST','(County Antrim)'),
			('BT','BT10','BELFAST','(County Antrim)'),
			('BT','BT11','BELFAST','(County Antrim)'),
			('BT','BT12','BELFAST','(County Antrim)'),
			('BT','BT13','BELFAST','(County Antrim)'),
			('BT','BT14','BELFAST','(County Antrim)'),
			('BT','BT15','BELFAST','(County Antrim)'),
			('BT','BT16','BELFAST','(County Antrim)'),
			('BT','BT17','BELFAST','(County Antrim)'),
			('BT','BT29','BELFAST','(County Antrim)'),
			('BT','BT18','HOLYWOOD','County Down'),
			('BT','BT19','BANGOR','County Down'),
			('BT','BT20','BANGOR','County Down'),
			('BT','BT21','DONAGHADEE','County Down'),
			('BT','BT22','NEWTOWNARDS','County Down'),
			('BT','BT23','NEWTOWNARDS','County Down'),
			('BT','BT24','BALLYNAHINCH','County Down'),
			('BT','BT25','DROMORE','County Down'),
			('BT','BT26','HILLSBOROUGH','County Down'),
			('BT','BT27','LISBURN','County Antrim'),
			('BT','BT28','LISBURN','County Antrim'),
			('BT','BT29','CRUMLIN','County Antrim'),
			('BT','BT30','DOWNPATRICK','County Down'),
			('BT','BT31','CASTLEWELLAN','County Down'),
			('BT','BT32','BANBRIDGE','County Down'),
			('BT','BT33','NEWCASTLE','County Down'),
			('BT','BT34','NEWRY','County Down'),
			('BT','BT35','NEWRY','County Down'),
			('BT','BT36','NEWTOWNABBEY','County Antrim'),
			('BT','BT37','NEWTOWNABBEY','County Antrim'),
			('BT','BT58','NEWTOWNABBEY','County Antrim'),
			('BT','BT38','CARRICKFERGUS','County Antrim'),
			('BT','BT39','BALLYCLARE','County Antrim'),
			('BT','BT40','LARNE','County Antrim'),
			('BT','BT41','ANTRIM','(County Antrim)'),
			('BT','BT42','BALLYMENA','County Antrim'),
			('BT','BT43','BALLYMENA','County Antrim'),
			('BT','BT44','BALLYMENA','County Antrim'),
			('BT','BT45','MAGHERAFELT','County Londonderry'),
			('BT','BT46','MAGHERA','County Londonderry'),
			('BT','BT47','LONDONDERRY','(County Londonderry)'),
			('BT','BT48','LONDONDERRY','(County Londonderry)'),
			('BT','BT49','LIMAVADY','County Londonderry'),
			('BT','BT51','COLERAINE','County Londonderry'),
			('BT','BT52','COLERAINE','County Londonderry'),
			('BT','BT53','BALLYMONEY','County Antrim'),
			('BT','BT54','BALLYCASTLE','County Antrim'),
			('BT','BT55','PORTSTEWART','County Londonderry'),
			('BT','BT56','PORTRUSH','County Antrim'),
			('BT','BT57','BUSHMILLS','County Antrim'),
			('BT','BT60','ARMAGH','(County Armagh)'),
			('BT','BT61','ARMAGH','(County Armagh)'),
			('BT','BT62','CRAIGAVON','County Armagh'),
			('BT','BT63','CRAIGAVON','County Armagh'),
			('BT','BT64','CRAIGAVON','County Armagh'),
			('BT','BT65','CRAIGAVON','County Armagh'),
			('BT','BT66','CRAIGAVON','County Armagh'),
			('BT','BT67','CRAIGAVON','County Armagh'),
			('BT','BT68','CALEDON','County Tyrone'),
			('BT','BT69','AUGHNACLOY','County Tyrone'),
			('BT','BT70','DUNGANNON','County Tyrone'),
			('BT','BT71','DUNGANNON','County Tyrone'),
			('BT','BT74','ENNISKILLEN','County Fermanagh'),
			('BT','BT92','ENNISKILLEN','County Fermanagh'),
			('BT','BT93','ENNISKILLEN','County Fermanagh'),
			('BT','BT94','ENNISKILLEN','County Fermanagh'),
			('BT','BT75','FIVEMILETOWN','County Tyrone'),
			('BT','BT76','CLOGHER','County Tyrone'),
			('BT','BT77','AUGHER','County Tyrone'),
			('BT','BT78','OMAGH','County Tyrone'),
			('BT','BT79','OMAGH','County Tyrone'),
			('BT','BT80','COOKSTOWN','County Tyrone'),
			('BT','BT81','CASTLEDERG','County Tyrone'),
			('BT','BT82','STRABANE','County Tyrone'),
			('BX','BX00','ZZZZ not applicable','ZZZZ non-geographic'),
			('CA','CA01','CARLISLE','(Cumbria)'),
			('CA','CA1','CARLISLE','(Cumbria)'),
			('CA','CA2','CARLISLE','(Cumbria)'),
			('CA','CA3','CARLISLE','(Cumbria)'),
			('CA','CA4','CARLISLE','(Cumbria)'),
			('CA','CA5','CARLISLE','(Cumbria)'),
			('CA','CA6','CARLISLE','(Cumbria)'),
			('CA','CA99','CARLISLE','(Cumbria)'),
			('CA','CA07','WIGTON','Cumbria'),
			('CA','CA7','WIGTON','Cumbria'),
			('CA','CA08','BRAMPTON','Cumbria'),
			('CA','CA8','BRAMPTON','Cumbria'),
			('CA','CA09','ALSTON','Cumbria'),
			('CA','CA9','ALSTON','Cumbria'),
			('CA','CA10','PENRITH','Cumbria'),
			('CA','CA11','PENRITH','Cumbria'),
			('CA','CA12','KESWICK','Cumbria'),
			('CA','CA13','COCKERMOUTH','Cumbria'),
			('CA','CA14','WORKINGTON','Cumbria'),
			('CA','CA95','WORKINGTON','Cumbria'),
			('CA','CA15','MARYPORT','Cumbria'),
			('CA','CA16','APPLEBY-IN-WESTMORLAND','Cumbria'),
			('CA','CA17','KIRKBY STEPHEN','Cumbria'),
			('CA','CA18','RAVENGLASS','Cumbria'),
			('CA','CA19','HOLMROOK','Cumbria'),
			('CA','CA20','SEASCALE','Cumbria'),
			('CA','CA21','BECKERMET','Cumbria'),
			('CA','CA22','EGREMONT','Cumbria'),
			('CA','CA23','CLEATOR','Cumbria'),
			('CA','CA24','MOOR ROW','Cumbria'),
			('CA','CA25','CLEATOR MOOR','Cumbria'),
			('CA','CA26','FRIZINGTON','Cumbria'),
			('CA','CA27','ST. BEES','Cumbria'),
			('CA','CA28','WHITEHAVEN','Cumbria'),
			('CB','CB01','CAMBRIDGE','(Cambridgeshire)'),
			('CB','CB1','CAMBRIDGE','(Cambridgeshire)'),
			('CB','CB2','CAMBRIDGE','(Cambridgeshire)'),
			('CB','CB3','CAMBRIDGE','(Cambridgeshire)'),
			('CB','CB4','CAMBRIDGE','(Cambridgeshire)'),
			('CB','CB5','CAMBRIDGE','(Cambridgeshire)'),
			('CB','CB21','CAMBRIDGE','(Cambridgeshire)'),
			('CB','CB22','CAMBRIDGE','(Cambridgeshire)'),
			('CB','CB23','CAMBRIDGE','(Cambridgeshire)'),
			('CB','CB24','CAMBRIDGE','(Cambridgeshire)'),
			('CB','CB25','CAMBRIDGE','(Cambridgeshire)'),
			('CB','CB06','ELY','Cambridgeshire'),
			('CB','CB6','ELY','Cambridgeshire'),
			('CB','CB7','ELY','Cambridgeshire'),
			('CB','CB08','NEWMARKET','Suffolk'),
			('CB','CB8','NEWMARKET','Suffolk'),
			('CB','CB09','HAVERHILL','Suffolk'),
			('CB','CB9','HAVERHILL','Suffolk'),
			('CB','CB10','SAFFRON WALDEN','Essex'),
			('CB','CB11','SAFFRON WALDEN','Essex'),
			('CF','CF03','CARDIFF','(South Glamorgan)'),
			('CF','CF3','CARDIFF','(South Glamorgan)'),
			('CF','CF5','CARDIFF','(South Glamorgan)'),
			('CF','CF10','CARDIFF','(South Glamorgan)'),
			('CF','CF11','CARDIFF','(South Glamorgan)'),
			('CF','CF14','CARDIFF','(South Glamorgan)'),
			('CF','CF15','CARDIFF','(South Glamorgan)'),
			('CF','CF23','CARDIFF','(South Glamorgan)'),
			('CF','CF24','CARDIFF','(South Glamorgan)'),
			('CF','CF30','CARDIFF','(South Glamorgan)'),
			('CF','CF91','CARDIFF','(South Glamorgan)'),
			('CF','CF95','CARDIFF','(South Glamorgan)'),
			('CF','CF99','CARDIFF','(South Glamorgan)'),
			('CF','CF31','BRIDGEND','Mid Glamorgan'),
			('CF','CF32','BRIDGEND','Mid Glamorgan'),
			('CF','CF33','BRIDGEND','Mid Glamorgan'),
			('CF','CF35','BRIDGEND','Mid Glamorgan'),
			('CF','CF34','MAESTEG','Mid Glamorgan'),
			('CF','CF36','PORTHCAWL','Mid Glamorgan'),
			('CF','CF37','PONTYPRIDD','Mid Glamorgan'),
			('CF','CF38','PONTYPRIDD','Mid Glamorgan'),
			('CF','CF39','PORTH','Mid Glamorgan'),
			('CF','CF40','TONYPANDY','Mid Glamorgan'),
			('CF','CF41','PENTRE','Mid Glamorgan'),
			('CF','CF42','TREORCHY','Mid Glamorgan'),
			('CF','CF43','FERNDALE','Mid Glamorgan'),
			('CF','CF44','ABERDARE','Mid Glamorgan'),
			('CF','CF45','MOUNTAIN ASH','Mid Glamorgan'),
			('CF','CF46','TREHARRIS','Mid Glamorgan'),
			('CF','CF47','MERTHYR TYDFIL','Mid Glamorgan'),
			('CF','CF48','MERTHYR TYDFIL','Mid Glamorgan'),
			('CF','CF61','LLANTWIT MAJOR','South Glamorgan'),
			('CF','CF71','LLANTWIT MAJOR','South Glamorgan'),
			('CF','CF62','BARRY','South Glamorgan'),
			('CF','CF63','BARRY','South Glamorgan'),
			('CF','CF64','DINAS POWYS','South Glamorgan'),
			('CF','CF64','PENARTH','South Glamorgan'),
			('CF','CF71','COWBRIDGE','South Glamorgan'),
			('CF','CF72','PONTYCLUN','Mid Glamorgan'),
			('CF','CF81','BARGOED','Mid Glamorgan'),
			('CF','CF82','HENGOED','Mid Glamorgan'),
			('CF','CF83','CAERPHILLY','Mid Glamorgan'),
			('CH','CH01','CHESTER','(Cheshire)'),
			('CH','CH1','CHESTER','(Cheshire)'),
			('CH','CH2','CHESTER','(Cheshire)'),
			('CH','CH3','CHESTER','(Cheshire)'),
			('CH','CH4','CHESTER','(Cheshire)'),
			('CH','CH70','CHESTER','(Cheshire)'),
			('CH','CH88','CHESTER','(Cheshire)'),
			('CH','CH99','CHESTER','(Cheshire)'),
			('CH','CH05','DEESIDE','Clwyd'),
			('CH','CH5','DEESIDE','Clwyd'),
			('CH','CH06','BAGILLT','Clwyd'),
			('CH','CH6','BAGILLT','Clwyd'),
			('CH','CH06','FLINT','Clwyd'),
			('CH','CH6','FLINT','Clwyd'),
			('CH','CH07','BUCKLEY','Clwyd'),
			('CH','CH7','BUCKLEY','Clwyd'),
			('CH','CH07','MOLD','Clwyd'),
			('CH','CH7','MOLD','Clwyd'),
			('CH','CH08','HOLYWELL','Clwyd'),
			('CH','CH8','HOLYWELL','Clwyd'),
			('CH','CH25','BIRKENHEAD','Merseyside'),
			('CH','CH41','BIRKENHEAD','Merseyside'),
			('CH','CH42','BIRKENHEAD','Merseyside'),
			('CH','CH26','PRENTON','Merseyside'),
			('CH','CH43','PRENTON','Merseyside'),
			('CH','CH27','WALLASEY','Merseyside'),
			('CH','CH44','WALLASEY','Merseyside'),
			('CH','CH45','WALLASEY','Merseyside'),
			('CH','CH28','WIRRAL','Merseyside'),
			('CH','CH29','WIRRAL','Merseyside'),
			('CH','CH30','WIRRAL','Merseyside'),
			('CH','CH31','WIRRAL','Merseyside'),
			('CH','CH32','WIRRAL','Merseyside'),
			('CH','CH46','WIRRAL','Merseyside'),
			('CH','CH47','WIRRAL','Merseyside'),
			('CH','CH48','WIRRAL','Merseyside'),
			('CH','CH49','WIRRAL','Merseyside'),
			('CH','CH60','WIRRAL','Merseyside'),
			('CH','CH61','WIRRAL','Merseyside'),
			('CH','CH62','WIRRAL','Merseyside'),
			('CH','CH63','WIRRAL','Merseyside'),
			('CH','CH33','NESTON','(Merseyside)'),
			('CH','CH64','NESTON','(Merseyside)'),
			('CH','CH34','ELLESMERE PORT','(Merseyside)'),
			('CH','CH65','ELLESMERE PORT','(Merseyside)'),
			('CH','CH66','ELLESMERE PORT','(Merseyside)'),
			('CM','CM00','BURNHAM-ON-CROUCH','Essex'),
			('CM','CM0','BURNHAM-ON-CROUCH','Essex'),
			('CM','CM00','SOUTHMINSTER','Essex'),
			('CM','CM0','SOUTHMINSTER','Essex'),
			('CM','CM01','CHELMSFORD','(Essex)'),
			('CM','CM1','CHELMSFORD','(Essex)'),
			('CM','CM2','CHELMSFORD','(Essex)'),
			('CM','CM3','CHELMSFORD','(Essex)'),
			('CM','CM92','CHELMSFORD','(Essex)'),
			('CM','CM98','CHELMSFORD','(Essex)'),
			('CM','CM99','CHELMSFORD','(Essex)'),
			('CM','CM04','INGATESTONE','Essex'),
			('CM','CM4','INGATESTONE','Essex'),
			('CM','CM05','ONGAR','Essex'),
			('CM','CM5','ONGAR','Essex'),
			('CM','CM06','DUNMOW','Essex'),
			('CM','CM6','DUNMOW','Essex'),
			('CM','CM7','DUNMOW','Essex'),
			('CM','CM07','BRAINTREE','Essex'),
			('CM','CM7','BRAINTREE','Essex'),
			('CM','CM77','BRAINTREE','Essex'),
			('CM','CM08','WITHAM','Essex'),
			('CM','CM8','WITHAM','Essex'),
			('CM','CM09','MALDON','Essex'),
			('CM','CM9','MALDON','Essex'),
			('CM','CM11','BILLERICAY','Essex'),
			('CM','CM12','BILLERICAY','Essex'),
			('CM','CM13','BRENTWOOD','Essex'),
			('CM','CM14','BRENTWOOD','Essex'),
			('CM','CM15','BRENTWOOD','Essex'),
			('CM','CM16','EPPING','Essex'),
			('CM','CM17','HARLOW','Essex'),
			('CM','CM18','HARLOW','Essex'),
			('CM','CM19','HARLOW','Essex'),
			('CM','CM20','HARLOW','Essex'),
			('CM','CM21','SAWBRIDGEWORTH','Hertfordshire'),
			('CM','CM22','BISHOPS STORTFORD','Hertfordshire'),
			('CM','CM23','BISHOPS STORTFORD','Hertfordshire'),
			('CM','CM24','STANSTED','Essex'),
			('CO','CO01','COLCHESTER','(Essex)'),
			('CO','CO1','COLCHESTER','(Essex)'),
			('CO','CO2','COLCHESTER','(Essex)'),
			('CO','CO3','COLCHESTER','(Essex)'),
			('CO','CO4','COLCHESTER','(Essex)'),
			('CO','CO5','COLCHESTER','(Essex)'),
			('CO','CO6','COLCHESTER','(Essex)'),
			('CO','CO7','COLCHESTER','(Essex)'),
			('CO','CO08','BURES','Suffolk'),
			('CO','CO8','BURES','Suffolk'),
			('CO','CO09','HALSTEAD','Essex'),
			('CO','CO9','HALSTEAD','Essex'),
			('CO','CO10','SUDBURY','Suffolk'),
			('CO','CO11','MANNINGTREE','Essex'),
			('CO','CO12','HARWICH','Essex'),
			('CO','CO13','FRINTON-ON-SEA','Essex'),
			('CO','CO14','WALTON ON THE NAZE','Essex'),
			('CO','CO15','CLACTON-ON-SEA','Essex'),
			('CO','CO16','CLACTON-ON-SEA','Essex'),
			('CR','CR00','CROYDON','(Surrey)'),
			('CR','CR0','CROYDON','(Surrey)'),
			('CR','CR9','CROYDON','(Surrey)'),
			('CR','CR44','CROYDON','(Surrey)'),
			('CR','CR90','CROYDON','(Surrey)'),
			('CR','CR02','SOUTH CROYDON','Surrey'),
			('CR','CR2','SOUTH CROYDON','Surrey'),
			('CR','CR03','CATERHAM','Surrey'),
			('CR','CR3','CATERHAM','Surrey'),
			('CR','CR03','WHYTELEAFE','Surrey'),
			('CR','CR3','WHYTELEAFE','Surrey'),
			('CR','CR04','MITCHAM','Surrey'),
			('CR','CR4','MITCHAM','Surrey'),
			('CR','CR05','COULSDON','Surrey'),
			('CR','CR5','COULSDON','Surrey'),
			('CR','CR06','WARLINGHAM','Surrey'),
			('CR','CR6','WARLINGHAM','Surrey'),
			('CR','CR07','THORNTON HEATH','Surrey'),
			('CR','CR7','THORNTON HEATH','Surrey'),
			('CR','CR08','KENLEY','Surrey'),
			('CR','CR8','KENLEY','Surrey'),
			('CR','CR08','PURLEY','Surrey'),
			('CR','CR8','PURLEY','Surrey'),
			('CT','CT01','CANTERBURY','Kent'),
			('CT','CT1','CANTERBURY','Kent'),
			('CT','CT2','CANTERBURY','Kent'),
			('CT','CT3','CANTERBURY','Kent'),
			('CT','CT4','CANTERBURY','Kent'),
			('CT','CT05','WHITSTABLE','Kent'),
			('CT','CT5','WHITSTABLE','Kent'),
			('CT','CT06','HERNE BAY','Kent'),
			('CT','CT6','HERNE BAY','Kent'),
			('CT','CT07','BIRCHINGTON','Kent'),
			('CT','CT7','BIRCHINGTON','Kent'),
			('CT','CT9','BIRCHINGTON','Kent'),
			('CT','CT08','WESTGATE-ON-SEA','Kent'),
			('CT','CT8','WESTGATE-ON-SEA','Kent'),
			('CT','CT09','MARGATE','Kent'),
			('CT','CT9','MARGATE','Kent'),
			('CT','CT10','BROADSTAIRS','Kent'),
			('CT','CT11','RAMSGATE','Kent'),
			('CT','CT12','RAMSGATE','Kent'),
			('CT','CT13','SANDWICH','Kent'),
			('CT','CT14','DEAL','Kent'),
			('CT','CT15','DOVER','Kent'),
			('CT','CT16','DOVER','Kent'),
			('CT','CT17','DOVER','Kent'),
			('CT','CT18','FOLKESTONE','Kent'),
			('CT','CT19','FOLKESTONE','Kent'),
			('CT','CT20','FOLKESTONE','Kent'),
			('CT','CT50','FOLKESTONE','Kent'),
			('CT','CT21','HYTHE','Kent'),
			('CV','CV01','COVENTRY','(West Midlands)'),
			('CV','CV1','COVENTRY','(West Midlands)'),
			('CV','CV2','COVENTRY','(West Midlands)'),
			('CV','CV3','COVENTRY','(West Midlands)'),
			('CV','CV4','COVENTRY','(West Midlands)'),
			('CV','CV5','COVENTRY','(West Midlands)'),
			('CV','CV6','COVENTRY','(West Midlands)'),
			('CV','CV7','COVENTRY','(West Midlands)'),
			('CV','CV8','COVENTRY','(West Midlands)'),
			('CV','CV08','KENILWORTH','Warwickshire'),
			('CV','CV8','KENILWORTH','Warwickshire'),
			('CV','CV09','ATHERSTONE','Warwickshire'),
			('CV','CV9','ATHERSTONE','Warwickshire'),
			('CV','CV10','NUNEATON','Warwickshire'),
			('CV','CV11','NUNEATON','Warwickshire'),
			('CV','CV13','NUNEATON','Warwickshire'),
			('CV','CV12','BEDWORTH','Warwickshire'),
			('CV','CV21','RUGBY','Warwickshire'),
			('CV','CV22','RUGBY','Warwickshire'),
			('CV','CV23','RUGBY','Warwickshire'),
			('CV','CV31','LEAMINGTON SPA','Warwickshire'),
			('CV','CV32','LEAMINGTON SPA','Warwickshire'),
			('CV','CV33','LEAMINGTON SPA','Warwickshire'),
			('CV','CV34','WARWICK','(Warwickshire)'),
			('CV','CV35','WARWICK','(Warwickshire)'),
			('CV','CV36','SHIPSTON-ON-STOUR','Warwickshire'),
			('CV','CV37','SHIPSTON-ON-STOUR','Warwickshire'),
			('CV','CV37','STRATFORD-UPON-AVON','Warwickshire'),
			('CV','CV47','SOUTHAM','Warwickshire'),
			('CW','CW01','CREWE','(Cheshire)'),
			('CW','CW1','CREWE','(Cheshire)'),
			('CW','CW2','CREWE','(Cheshire)'),
			('CW','CW3','CREWE','(Cheshire)'),
			('CW','CW4','CREWE','(Cheshire)'),
			('CW','CW98','CREWE','(Cheshire)'),
			('CW','CW05','NANTWICH','Cheshire'),
			('CW','CW5','NANTWICH','Cheshire'),
			('CW','CW06','TARPORLEY','Cheshire'),
			('CW','CW6','TARPORLEY','Cheshire'),
			('CW','CW07','WINSFORD','Cheshire'),
			('CW','CW7','WINSFORD','Cheshire'),
			('CW','CW08','NORTHWICH','Cheshire'),
			('CW','CW8','NORTHWICH','Cheshire'),
			('CW','CW9','NORTHWICH','Cheshire'),
			('CW','CW10','MIDDLEWICH','Cheshire'),
			('CW','CW11','SANDBACH','Cheshire'),
			('CW','CW12','CONGLETON','Cheshire'),
			('DA','DA01','DARTFORD','(Kent)'),
			('DA','DA1','DARTFORD','(Kent)'),
			('DA','DA2','DARTFORD','(Kent)'),
			('DA','DA4','DARTFORD','(Kent)'),
			('DA','DA10','DARTFORD','(Kent)'),
			('DA','DA03','LONGFIELD','Kent'),
			('DA','DA3','LONGFIELD','Kent'),
			('DA','DA05','BEXLEY','Kent'),
			('DA','DA5','BEXLEY','Kent'),
			('DA','DA06','BEXLEYHEATH','Kent'),
			('DA','DA6','BEXLEYHEATH','Kent'),
			('DA','DA7','BEXLEYHEATH','Kent'),
			('DA','DA07','WELLING','Kent'),
			('DA','DA7','WELLING','Kent'),
			('DA','DA16','WELLING','Kent'),
			('DA','DA08','ERITH','Kent'),
			('DA','DA8','ERITH','Kent'),
			('DA','DA18','ERITH','Kent'),
			('DA','DA09','GREENHITHE','Kent'),
			('DA','DA9','GREENHITHE','Kent'),
			('DA','DA10','SWANSCOMBE','Kent'),
			('DA','DA11','GRAVESEND','Kent'),
			('DA','DA12','GRAVESEND','Kent'),
			('DA','DA13','GRAVESEND','Kent'),
			('DA','DA14','SIDCUP','Kent'),
			('DA','DA15','SIDCUP','Kent'),
			('DA','DA17','BELVEDERE','Kent'),
			('DD','DD01','DUNDEE','(Angus)'),
			('DD','DD1','DUNDEE','(Angus)'),
			('DD','DD2','DUNDEE','(Angus)'),
			('DD','DD3','DUNDEE','(Angus)'),
			('DD','DD4','DUNDEE','(Angus)'),
			('DD','DD5','DUNDEE','(Angus)'),
			('DD','DD06','NEWPORT-ON-TAY','Fife'),
			('DD','DD6','NEWPORT-ON-TAY','Fife'),
			('DD','DD06','TAYPORT','Fife'),
			('DD','DD6','TAYPORT','Fife'),
			('DD','DD07','CARNOUSTIE','Angus'),
			('DD','DD7','CARNOUSTIE','Angus'),
			('DD','DD08','FORFAR','Angus'),
			('DD','DD8','FORFAR','Angus'),
			('DD','DD08','KIRRIEMUIR','Angus'),
			('DD','DD8','KIRRIEMUIR','Angus'),
			('DD','DD09','BRECHIN','Angus'),
			('DD','DD9','BRECHIN','Angus'),
			('DD','DD10','MONTROSE','Angus'),
			('DD','DD11','ARBROATH','Angus'),
			('DE','DE01','DERBY','(Derbyshire)'),
			('DE','DE1','DERBY','(Derbyshire)'),
			('DE','DE3','DERBY','(Derbyshire)'),
			('DE','DE21','DERBY','(Derbyshire)'),
			('DE','DE22','DERBY','(Derbyshire)'),
			('DE','DE23','DERBY','(Derbyshire)'),
			('DE','DE24','DERBY','(Derbyshire)'),
			('DE','DE65','DERBY','(Derbyshire)'),
			('DE','DE72','DERBY','(Derbyshire)'),
			('DE','DE73','DERBY','(Derbyshire)'),
			('DE','DE74','DERBY','(Derbyshire)'),
			('DE','DE99','DERBY','(Derbyshire)'),
			('DE','DE04','MATLOCK','Derbyshire'),
			('DE','DE4','MATLOCK','Derbyshire'),
			('DE','DE05','RIPLEY','Derbyshire'),
			('DE','DE5','RIPLEY','Derbyshire'),
			('DE','DE06','ASHBOURNE','Derbyshire'),
			('DE','DE6','ASHBOURNE','Derbyshire'),
			('DE','DE07','ILKESTON','Derbyshire'),
			('DE','DE7','ILKESTON','Derbyshire'),
			('DE','DE11','SWADLINCOTE','Derbyshire'),
			('DE','DE12','SWADLINCOTE','Derbyshire'),
			('DE','DE13','BURTON-ON-TRENT','Staffordshire'),
			('DE','DE14','BURTON-ON-TRENT','Staffordshire'),
			('DE','DE15','BURTON-ON-TRENT','Staffordshire'),
			('DE','DE45','BAKEWELL','Derbyshire'),
			('DE','DE55','ALFRETON','Derbyshire'),
			('DE','DE56','BELPER','Derbyshire'),
			('DE','DE75','HEANOR','Derbyshire'),
			('DG','DG01','DUMFRIES','(Dumfriesshire)'),
			('DG','DG1','DUMFRIES','(Dumfriesshire)'),
			('DG','DG2','DUMFRIES','(Dumfriesshire)'),
			('DG','DG03','THORNHILL','Dumfriesshire'),
			('DG','DG3','THORNHILL','Dumfriesshire'),
			('DG','DG04','SANQUHAR','Dumfriesshire'),
			('DG','DG4','SANQUHAR','Dumfriesshire'),
			('DG','DG05','DALBEATTIE','Kirkcudbrightshire'),
			('DG','DG5','DALBEATTIE','Kirkcudbrightshire'),
			('DG','DG06','KIRKCUDBRIGHT','(Kirkcudbrightshire)'),
			('DG','DG6','KIRKCUDBRIGHT','(Kirkcudbrightshire)'),
			('DG','DG07','CASTLE DOUGLAS','Kirkcudbrightshire'),
			('DG','DG7','CASTLE DOUGLAS','Kirkcudbrightshire'),
			('DG','DG08','NEWTON STEWART','Wigtownshire'),
			('DG','DG8','NEWTON STEWART','Wigtownshire'),
			('DG','DG09','STRANRAER','Wigtownshire'),
			('DG','DG9','STRANRAER','Wigtownshire'),
			('DG','DG10','MOFFAT','Dumfriesshire'),
			('DG','DG11','LOCKERBIE','Dumfriesshire'),
			('DG','DG12','ANNAN','Dumfriesshire'),
			('DG','DG13','LANGHOLM','Dumfriesshire'),
			('DG','DG14','CANONBIE','Dumfriesshire'),
			('DG','DG16','GRETNA','Dumfriesshire'),
			('DH','DH01','DURHAM','(County Durham)'),
			('DH','DH1','DURHAM','(County Durham)'),
			('DH','DH6','DURHAM','(County Durham)'),
			('DH','DH7','DURHAM','(County Durham)'),
			('DH','DH8','DURHAM','(County Durham)'),
			('DH','DH97','DURHAM','(County Durham)'),
			('DH','DH98','DURHAM','(County Durham)'),
			('DH','DH99','DURHAM','(County Durham)'),
			('DH','DH02','CHESTER LE STREET','County Durham'),
			('DH','DH2','CHESTER LE STREET','County Durham'),
			('DH','DH3','CHESTER LE STREET','County Durham'),
			('DH','DH04','HOUGHTON LE SPRING','Tyne and Wear'),
			('DH','DH4','HOUGHTON LE SPRING','Tyne and Wear'),
			('DH','DH5','HOUGHTON LE SPRING','Tyne and Wear'),
			('DH','DH08','CONSETT','County Durham'),
			('DH','DH8','CONSETT','County Durham'),
			('DH','DH08','STANLEY','County Durham'),
			('DH','DH8','STANLEY','County Durham'),
			('DH','DH9','STANLEY','County Durham'),
			('DL','DL01','DARLINGTON','County Durham'),
			('DL','DL1','DARLINGTON','County Durham'),
			('DL','DL2','DARLINGTON','County Durham'),
			('DL','DL3','DARLINGTON','County Durham'),
			('DL','DL98','DARLINGTON','County Durham'),
			('DL','DL04','SHILDON','County Durham'),
			('DL','DL4','SHILDON','County Durham'),
			('DL','DL05','NEWTON AYCLIFFE','County Durham'),
			('DL','DL5','NEWTON AYCLIFFE','County Durham'),
			('DL','DL06','NORTHALLERTON','North Yorkshire'),
			('DL','DL6','NORTHALLERTON','North Yorkshire'),
			('DL','DL7','NORTHALLERTON','North Yorkshire'),
			('DL','DL08','BEDALE','North Yorkshire'),
			('DL','DL8','BEDALE','North Yorkshire'),
			('DL','DL08','HAWES','North Yorkshire'),
			('DL','DL8','HAWES','North Yorkshire'),
			('DL','DL08','LEYBURN','North Yorkshire'),
			('DL','DL8','LEYBURN','North Yorkshire'),
			('DL','DL09','CATTERICK GARRISON','North Yorkshire'),
			('DL','DL9','CATTERICK GARRISON','North Yorkshire'),
			('DL','DL10','RICHMOND','North Yorkshire'),
			('DL','DL11','RICHMOND','North Yorkshire'),
			('DL','DL12','BARNARD CASTLE','County Durham'),
			('DL','DL13','BISHOP AUCKLAND','County Durham'),
			('DL','DL14','BISHOP AUCKLAND','County Durham'),
			('DL','DL15','CROOK','County Durham'),
			('DL','DL16','SPENNYMOOR','County Durham'),
			('DL','DL16','FERRYHILL','County Durham'),
			('DL','DL17','FERRYHILL','County Durham'),
			('DN','DN01','DONCASTER','South Yorkshire'),
			('DN','DN1','DONCASTER','South Yorkshire');
		END

		BEGIN
			INSERT INTO dbo.PostalDistrict (PostcodeArea, PostcodeDistrict, PostTown, FormerPostalCounty)
			VALUES
			('DN','DN3','DONCASTER','South Yorkshire'),
			('DN','DN4','DONCASTER','South Yorkshire'),
			('DN','DN2','DONCASTER','South Yorkshire'),
			('DN','DN5','DONCASTER','South Yorkshire'),
			('DN','DN6','DONCASTER','South Yorkshire'),
			('DN','DN7','DONCASTER','South Yorkshire'),
			('DN','DN8','DONCASTER','South Yorkshire'),
			('DN','DN9','DONCASTER','South Yorkshire'),
			('DN','DN10','DONCASTER','South Yorkshire'),
			('DN','DN11','DONCASTER','South Yorkshire'),
			('DN','DN12','DONCASTER','South Yorkshire'),
			('DN','DN55','DONCASTER','South Yorkshire'),
			('DN','DN14','GOOLE','North Humberside'),
			('DN','DN15','SCUNTHORPE','South Humberside'),
			('DN','DN16','SCUNTHORPE','South Humberside'),
			('DN','DN17','SCUNTHORPE','South Humberside'),
			('DN','DN18','BARTON-UPON-HUMBER','South Humberside'),
			('DN','DN19','BARROW-UPON-HUMBER','South Humberside'),
			('DN','DN20','BRIGG','South Humberside'),
			('DN','DN21','GAINSBOROUGH','Lincolnshire'),
			('DN','DN22','RETFORD','Nottinghamshire'),
			('DN','DN31','GRIMSBY','South Humberside'),
			('DN','DN32','GRIMSBY','South Humberside'),
			('DN','DN33','GRIMSBY','South Humberside'),
			('DN','DN34','GRIMSBY','South Humberside'),
			('DN','DN36','GRIMSBY','South Humberside'),
			('DN','DN37','GRIMSBY','South Humberside'),
			('DN','DN41','GRIMSBY','South Humberside'),
			('DN','DN35','CLEETHORPES','South Humberside'),
			('DN','DN38','BARNETBY','South Humberside'),
			('DN','DN39','ULCEBY','South Humberside'),
			('DN','DN40','IMMINGHAM','South Humberside'),
			('DT','DT01','DORCHESTER','Dorset'),
			('DT','DT1','DORCHESTER','Dorset'),
			('DT','DT2','DORCHESTER','Dorset'),
			('DT','DT03','WEYMOUTH','Dorset'),
			('DT','DT3','WEYMOUTH','Dorset'),
			('DT','DT4','WEYMOUTH','Dorset'),
			('DT','DT05','PORTLAND','Dorset'),
			('DT','DT5','PORTLAND','Dorset'),
			('DT','DT06','BRIDPORT','Dorset'),
			('DT','DT6','BRIDPORT','Dorset'),
			('DT','DT07','LYME REGIS','Dorset'),
			('DT','DT7','LYME REGIS','Dorset'),
			('DT','DT08','BEAMINSTER','Dorset'),
			('DT','DT8','BEAMINSTER','Dorset'),
			('DT','DT09','SHERBORNE','Dorset'),
			('DT','DT9','SHERBORNE','Dorset'),
			('DT','DT10','STURMINSTER NEWTON','Dorset'),
			('DT','DT11','BLANDFORD FORUM','Dorset'),
			('DY','DY01','DUDLEY','West Midlands'),
			('DY','DY1','DUDLEY','West Midlands'),
			('DY','DY2','DUDLEY','West Midlands'),
			('DY','DY3','DUDLEY','West Midlands'),
			('DY','DY04','TIPTON','West Midlands'),
			('DY','DY4','TIPTON','West Midlands'),
			('DY','DY05','BRIERLEY HILL','West Midlands'),
			('DY','DY5','BRIERLEY HILL','West Midlands'),
			('DY','DY06','KINGSWINFORD','West Midlands'),
			('DY','DY6','KINGSWINFORD','West Midlands'),
			('DY','DY07','STOURBRIDGE','West Midlands'),
			('DY','DY7','STOURBRIDGE','West Midlands'),
			('DY','DY8','STOURBRIDGE','West Midlands'),
			('DY','DY9','STOURBRIDGE','West Midlands'),
			('DY','DY10','KIDDERMINSTER','Worcestershire'),
			('DY','DY11','KIDDERMINSTER','Worcestershire'),
			('DY','DY14','KIDDERMINSTER','Worcestershire'),
			('DY','DY12','BEWDLEY','Worcestershire'),
			('DY','DY13','STOURPORT-ON-SEVERN','Worcestershire'),
			('E','E001','LONDON','(London)'),
			('E','E1','LONDON','(London)'),
			('E','E1W','LONDON','(London)'),
			('E','E2','LONDON','(London)'),
			('E','E3','LONDON','(London)'),
			('E','E4','LONDON','(London)'),
			('E','E5','LONDON','(London)'),
			('E','E6','LONDON','(London)'),
			('E','E7','LONDON','(London)'),
			('E','E8','LONDON','(London)'),
			('E','E9','LONDON','(London)'),
			('E','E10','LONDON','(London)'),
			('E','E11','LONDON','(London)'),
			('E','E12','LONDON','(London)'),
			('E','E13','LONDON','(London)'),
			('E','E14','LONDON','(London)'),
			('E','E15','LONDON','(London)'),
			('E','E16','LONDON','(London)'),
			('E','E17','LONDON','(London)'),
			('E','E18','LONDON','(London)'),
			('E','E20','LONDON','(London)'),
			('E','E77','LONDON','(London)'),
			('E','E98','LONDON','(London)'),
			('EC','EC01','LONDON','(London)'),
			('EC','EC1A','LONDON','(London)'),
			('EC','EC1M','LONDON','(London)'),
			('EC','EC1N','LONDON','(London)'),
			('EC','EC1P','LONDON','(London)'),
			('EC','EC1R','LONDON','(London)'),
			('EC','EC1V','LONDON','(London)'),
			('EC','EC1Y','LONDON','(London)'),
			('EC','EC2A','LONDON','(London)'),
			('EC','EC2M','LONDON','(London)'),
			('EC','EC2N','LONDON','(London)'),
			('EC','EC2P','LONDON','(London)'),
			('EC','EC2R','LONDON','(London)'),
			('EC','EC2V','LONDON','(London)'),
			('EC','EC2Y','LONDON','(London)'),
			('EC','EC3A','LONDON','(London)'),
			('EC','EC3M','LONDON','(London)'),
			('EC','EC3N','LONDON','(London)'),
			('EC','EC3P','LONDON','(London)'),
			('EC','EC3R','LONDON','(London)'),
			('EC','EC3V','LONDON','(London)'),
			('EC','EC4A','LONDON','(London)'),
			('EC','EC4M','LONDON','(London)'),
			('EC','EC4N','LONDON','(London)'),
			('EC','EC4P','LONDON','(London)'),
			('EC','EC4R','LONDON','(London)'),
			('EC','EC4V','LONDON','(London)'),
			('EC','EC4Y','LONDON','(London)'),
			('EC','EC50','LONDON','(London)'),
			('EH','EH01','EDINBURGH','(Midlothian)'),
			('EH','EH1','EDINBURGH','(Midlothian)'),
			('EH','EH2','EDINBURGH','(Midlothian)'),
			('EH','EH3','EDINBURGH','(Midlothian)'),
			('EH','EH4','EDINBURGH','(Midlothian)'),
			('EH','EH5','EDINBURGH','(Midlothian)'),
			('EH','EH6','EDINBURGH','(Midlothian)'),
			('EH','EH7','EDINBURGH','(Midlothian)'),
			('EH','EH8','EDINBURGH','(Midlothian)'),
			('EH','EH9','EDINBURGH','(Midlothian)'),
			('EH','EH10','EDINBURGH','(Midlothian)'),
			('EH','EH11','EDINBURGH','(Midlothian)'),
			('EH','EH12','EDINBURGH','(Midlothian)'),
			('EH','EH13','EDINBURGH','(Midlothian)'),
			('EH','EH14','EDINBURGH','(Midlothian)'),
			('EH','EH15','EDINBURGH','(Midlothian)'),
			('EH','EH16','EDINBURGH','(Midlothian)'),
			('EH','EH17','EDINBURGH','(Midlothian)'),
			('EH','EH91','EDINBURGH','(Midlothian)'),
			('EH','EH95','EDINBURGH','(Midlothian)'),
			('EH','EH99','EDINBURGH','(Midlothian)'),
			('EH','EH14','BALERNO','Midlothian'),
			('EH','EH14','CURRIE','Midlothian'),
			('EH','EH14','JUNIPER GREEN','Midlothian'),
			('EH','EH18','LASSWADE','Midlothian'),
			('EH','EH19','BONNYRIGG','Midlothian'),
			('EH','EH20','LOANHEAD','Midlothian'),
			('EH','EH21','MUSSELBURGH','Midlothian'),
			('EH','EH22','DALKEITH','Midlothian'),
			('EH','EH23','GOREBRIDGE','Midlothian'),
			('EH','EH24','ROSEWELL','Midlothian'),
			('EH','EH25','ROSLIN','Midlothian'),
			('EH','EH26','PENICUIK','Midlothian'),
			('EH','EH27','KIRKNEWTON','Midlothian'),
			('EH','EH28','NEWBRIDGE','Midlothian'),
			('EH','EH29','KIRKLISTON','West Lothian'),
			('EH','EH30','SOUTH QUEENSFERRY','West Lothian'),
			('EH','EH31','GULLANE','East Lothian'),
			('EH','EH32','LONGNIDDRY','East Lothian'),
			('EH','EH32','PRESTONPANS','East Lothian'),
			('EH','EH33','TRANENT','East Lothian'),
			('EH','EH34','TRANENT','East Lothian'),
			('EH','EH35','TRANENT','East Lothian'),
			('EH','EH36','HUMBIE','East Lothian'),
			('EH','EH37','PATHHEAD','Midlothian'),
			('EH','EH38','HERIOT','Midlothian'),
			('EH','EH39','NORTH BERWICK','East Lothian'),
			('EH','EH40','EAST LINTON','East Lothian'),
			('EH','EH41','HADDINGTON','East Lothian'),
			('EH','EH42','DUNBAR','East Lothian'),
			('EH','EH43','WALKERBURN','Peeblesshire'),
			('EH','EH44','INNERLEITHEN','Peeblesshire'),
			('EH','EH45','PEEBLES','(Peeblesshire)'),
			('EH','EH46','WEST LINTON','Peeblesshire'),
			('EH','EH47','BATHGATE','West Lothian'),
			('EH','EH48','BATHGATE','West Lothian'),
			('EH','EH49','LINLITHGOW','West Lothian'),
			('EH','EH51','BONESS','West Lothian'),
			('EH','EH52','BROXBURN','West Lothian'),
			('EH','EH53','LIVINGSTON','West Lothian'),
			('EH','EH54','LIVINGSTON','West Lothian'),
			('EH','EH55','WEST CALDER','West Lothian'),
			('EN','EN01','ENFIELD','Middlesex'),
			('EN','EN1','ENFIELD','Middlesex'),
			('EN','EN2','ENFIELD','Middlesex'),
			('EN','EN3','ENFIELD','Middlesex'),
			('EN','EN04','BARNET','Hertfordshire'),
			('EN','EN4','BARNET','Hertfordshire'),
			('EN','EN5','BARNET','Hertfordshire'),
			('EN','EN06','POTTERS BAR','Hertfordshire'),
			('EN','EN6','POTTERS BAR','Hertfordshire'),
			('EN','EN07','WALTHAM CROSS','Hertfordshire'),
			('EN','EN7','WALTHAM CROSS','Hertfordshire'),
			('EN','EN8','WALTHAM CROSS','Hertfordshire'),
			('EN','EN77','WALTHAM CROSS','Hertfordshire'),
			('EN','EN09','WALTHAM ABBEY','Essex'),
			('EN','EN9','WALTHAM ABBEY','Essex'),
			('EN','EN10','BROXBOURNE','Hertfordshire'),
			('EN','EN11','BROXBOURNE','Hertfordshire'),
			('EN','EN11','HODDESDON','Hertfordshire'),
			('EX','EX01','EXETER','(Devon)'),
			('EX','EX1','EXETER','(Devon)'),
			('EX','EX2','EXETER','(Devon)'),
			('EX','EX3','EXETER','(Devon)'),
			('EX','EX4','EXETER','(Devon)'),
			('EX','EX5','EXETER','(Devon)'),
			('EX','EX6','EXETER','(Devon)'),
			('EX','EX07','DAWLISH','Devon'),
			('EX','EX7','DAWLISH','Devon'),
			('EX','EX08','EXMOUTH','Devon'),
			('EX','EX8','EXMOUTH','Devon'),
			('EX','EX09','BUDLEIGH SALTERTON','Devon'),
			('EX','EX9','BUDLEIGH SALTERTON','Devon'),
			('EX','EX10','SIDMOUTH','Devon'),
			('EX','EX11','OTTERY ST. MARY','Devon'),
			('EX','EX12','SEATON','Devon'),
			('EX','EX13','AXMINSTER','Devon'),
			('EX','EX14','HONITON','Devon'),
			('EX','EX15','CULLOMPTON','Devon'),
			('EX','EX16','TIVERTON','Devon'),
			('EX','EX17','CREDITON','Devon'),
			('EX','EX18','CHULMLEIGH','Devon'),
			('EX','EX19','WINKLEIGH','Devon'),
			('EX','EX20','NORTH TAWTON','Devon'),
			('EX','EX20','OKEHAMPTON','Devon'),
			('EX','EX21','BEAWORTHY','Devon'),
			('EX','EX22','HOLSWORTHY','Devon'),
			('EX','EX23','BUDE','Cornwall'),
			('EX','EX24','COLYTON','Devon'),
			('EX','EX31','BARNSTAPLE','Devon'),
			('EX','EX32','BARNSTAPLE','Devon'),
			('EX','EX33','BRAUNTON','Devon'),
			('EX','EX34','ILFRACOMBE','Devon'),
			('EX','EX34','WOOLACOMBE','Devon'),
			('EX','EX35','LYNMOUTH','Devon'),
			('EX','EX35','LYNTON','Devon'),
			('EX','EX36','SOUTH MOLTON','Devon'),
			('EX','EX37','UMBERLEIGH','Devon'),
			('EX','EX38','TORRINGTON','Devon'),
			('EX','EX39','BIDEFORD','Devon'),
			('FK','FK01','FALKIRK','(Stirlingshire)'),
			('FK','FK1','FALKIRK','(Stirlingshire)'),
			('FK','FK2','FALKIRK','(Stirlingshire)'),
			('FK','FK03','GRANGEMOUTH','Stirlingshire'),
			('FK','FK3','GRANGEMOUTH','Stirlingshire'),
			('FK','FK04','BONNYBRIDGE','Stirlingshire'),
			('FK','FK4','BONNYBRIDGE','Stirlingshire'),
			('FK','FK05','LARBERT','Stirlingshire'),
			('FK','FK5','LARBERT','Stirlingshire'),
			('FK','FK06','DENNY','Stirlingshire'),
			('FK','FK6','DENNY','Stirlingshire'),
			('FK','FK07','STIRLING','(Stirlingshire)'),
			('FK','FK7','STIRLING','(Stirlingshire)'),
			('FK','FK8','STIRLING','(Stirlingshire)'),
			('FK','FK9','STIRLING','(Stirlingshire)'),
			('FK','FK10','ALLOA','Clackmannanshire'),
			('FK','FK10','CLACKMANNAN','(Clackmannanshire)'),
			('FK','FK11','MENSTRIE','Clackmannanshire'),
			('FK','FK12','ALVA','Clackmannanshire'),
			('FK','FK13','TILLICOULTRY','Clackmannanshire'),
			('FK','FK14','DOLLAR','Clackmannanshire'),
			('FK','FK15','DUNBLANE','Perthshire'),
			('FK','FK16','DOUNE','Perthshire'),
			('FK','FK17','CALLANDER','Perthshire'),
			('FK','FK18','CALLANDER','Perthshire'),
			('FK','FK19','LOCHEARNHEAD','Perthshire'),
			('FK','FK20','CRIANLARICH','Perthshire'),
			('FK','FK21','KILLIN','Perthshire'),
			('FY','FY00','BLACKPOOL','(Lancashire)'),
			('FY','FY0','BLACKPOOL','(Lancashire)'),
			('FY','FY1','BLACKPOOL','(Lancashire)'),
			('FY','FY2','BLACKPOOL','(Lancashire)'),
			('FY','FY3','BLACKPOOL','(Lancashire)'),
			('FY','FY4','BLACKPOOL','(Lancashire)'),
			('FY','FY05','THORNTON-CLEVELEYS','Lancashire'),
			('FY','FY5','THORNTON-CLEVELEYS','Lancashire'),
			('FY','FY06','POULTON-LE-FYLDE','Lancashire'),
			('FY','FY6','POULTON-LE-FYLDE','Lancashire'),
			('FY','FY07','FLEETWOOD','Lancashire'),
			('FY','FY7','FLEETWOOD','Lancashire'),
			('FY','FY08','LYTHAM ST. ANNES','Lancashire'),
			('FY','FY8','LYTHAM ST. ANNES','Lancashire'),
			('G','G001','GLASGOW','(Lanarkshire)'),
			('G','G1','GLASGOW','(Lanarkshire)'),
			('G','G2','GLASGOW','(Lanarkshire)'),
			('G','G3','GLASGOW','(Lanarkshire)'),
			('G','G4','GLASGOW','(Lanarkshire)'),
			('G','G5','GLASGOW','(Lanarkshire)'),
			('G','G9','GLASGOW','(Lanarkshire)'),
			('G','G11','GLASGOW','(Lanarkshire)'),
			('G','G12','GLASGOW','(Lanarkshire)'),
			('G','G13','GLASGOW','(Lanarkshire)'),
			('G','G14','GLASGOW','(Lanarkshire)'),
			('G','G15','GLASGOW','(Lanarkshire)'),
			('G','G20','GLASGOW','(Lanarkshire)'),
			('G','G21','GLASGOW','(Lanarkshire)'),
			('G','G22','GLASGOW','(Lanarkshire)'),
			('G','G23','GLASGOW','(Lanarkshire)'),
			('G','G31','GLASGOW','(Lanarkshire)'),
			('G','G32','GLASGOW','(Lanarkshire)'),
			('G','G33','GLASGOW','(Lanarkshire)'),
			('G','G34','GLASGOW','(Lanarkshire)'),
			('G','G40','GLASGOW','(Lanarkshire)'),
			('G','G41','GLASGOW','(Lanarkshire)'),
			('G','G42','GLASGOW','(Lanarkshire)'),
			('G','G43','GLASGOW','(Lanarkshire)'),
			('G','G44','GLASGOW','(Lanarkshire)'),
			('G','G45','GLASGOW','(Lanarkshire)'),
			('G','G46','GLASGOW','(Lanarkshire)'),
			('G','G51','GLASGOW','(Lanarkshire)'),
			('G','G52','GLASGOW','(Lanarkshire)'),
			('G','G53','GLASGOW','(Lanarkshire)'),
			('G','G58','GLASGOW','(Lanarkshire)'),
			('G','G60','GLASGOW','(Lanarkshire)'),
			('G','G61','GLASGOW','(Lanarkshire)'),
			('G','G62','GLASGOW','(Lanarkshire)'),
			('G','G63','GLASGOW','(Lanarkshire)'),
			('G','G64','GLASGOW','(Lanarkshire)'),
			('G','G65','GLASGOW','(Lanarkshire)'),
			('G','G66','GLASGOW','(Lanarkshire)'),
			('G','G67','GLASGOW','(Lanarkshire)'),
			('G','G68','GLASGOW','(Lanarkshire)'),
			('G','G69','GLASGOW','(Lanarkshire)'),
			('G','G70','GLASGOW','(Lanarkshire)'),
			('G','G71','GLASGOW','(Lanarkshire)'),
			('G','G72','GLASGOW','(Lanarkshire)'),
			('G','G73','GLASGOW','(Lanarkshire)'),
			('G','G74','GLASGOW','(Lanarkshire)'),
			('G','G75','GLASGOW','(Lanarkshire)'),
			('G','G76','GLASGOW','(Lanarkshire)'),
			('G','G77','GLASGOW','(Lanarkshire)'),
			('G','G78','GLASGOW','(Lanarkshire)'),
			('G','G79','GLASGOW','(Lanarkshire)'),
			('G','G90','GLASGOW','(Lanarkshire)'),
			('G','G081','CLYDEBANK','Dunbartonshire'),
			('G','G81','CLYDEBANK','Dunbartonshire'),
			('G','G082','DUMBARTON','(Dunbartonshire)'),
			('G','G82','DUMBARTON','(Dunbartonshire)'),
			('G','G083','ALEXANDRIA','Dunbartonshire'),
			('G','G83','ALEXANDRIA','Dunbartonshire'),
			('G','G083','ARROCHAR','Dunbartonshire'),
			('G','G83','ARROCHAR','Dunbartonshire'),
			('G','G084','HELENSBURGH','Dunbartonshire'),
			('G','G84','HELENSBURGH','Dunbartonshire'),
			('GL','GL01','GLOUCESTER','(Gloucestershire)'),
			('GL','GL1','GLOUCESTER','(Gloucestershire)'),
			('GL','GL2','GLOUCESTER','(Gloucestershire)'),
			('GL','GL3','GLOUCESTER','(Gloucestershire)'),
			('GL','GL4','GLOUCESTER','(Gloucestershire)'),
			('GL','GL19','GLOUCESTER','(Gloucestershire)'),
			('GL','GL05','STROUD','Gloucestershire'),
			('GL','GL5','STROUD','Gloucestershire'),
			('GL','GL6','STROUD','Gloucestershire'),
			('GL','GL07','CIRENCESTER','Gloucestershire'),
			('GL','GL7','CIRENCESTER','Gloucestershire'),
			('GL','GL07','FAIRFORD','Gloucestershire'),
			('GL','GL7','FAIRFORD','Gloucestershire'),
			('GL','GL07','LECHLADE','Gloucestershire'),
			('GL','GL7','LECHLADE','Gloucestershire'),
			('GL','GL08','TETBURY','Gloucestershire'),
			('GL','GL8','TETBURY','Gloucestershire'),
			('GL','GL09','BADMINTON','Avon'),
			('GL','GL9','BADMINTON','Avon'),
			('GL','GL10','STONEHOUSE','Gloucestershire'),
			('GL','GL11','DURSLEY','Gloucestershire'),
			('GL','GL11','WOTTON-UNDER-EDGE','Gloucestershire'),
			('GL','GL12','WOTTON-UNDER-EDGE','Gloucestershire'),
			('GL','GL13','BERKELEY','Gloucestershire'),
			('GL','GL14','CINDERFORD','Gloucestershire'),
			('GL','GL14','NEWNHAM','Gloucestershire'),
			('GL','GL14','WESTBURY-ON-SEVERN','Gloucestershire'),
			('GL','GL15','BLAKENEY','Gloucestershire'),
			('GL','GL15','LYDNEY','Gloucestershire'),
			('GL','GL16','COLEFORD','Gloucestershire'),
			('GL','GL17','DRYBROOK','Gloucestershire'),
			('GL','GL17','LONGHOPE','Gloucestershire'),
			('GL','GL17','LYDBROOK','Gloucestershire'),
			('GL','GL17','MITCHELDEAN','Gloucestershire'),
			('GL','GL17','RUARDEAN','Gloucestershire'),
			('GL','GL18','DYMOCK','Gloucestershire'),
			('GL','GL18','NEWENT','Gloucestershire'),
			('GL','GL20','TEWKESBURY','Gloucestershire'),
			('GL','GL50','CHELTENHAM','Gloucestershire'),
			('GL','GL51','CHELTENHAM','Gloucestershire'),
			('GL','GL52','CHELTENHAM','Gloucestershire'),
			('GL','GL53','CHELTENHAM','Gloucestershire'),
			('GL','GL54','CHELTENHAM','Gloucestershire'),
			('GL','GL55','CHIPPING CAMPDEN','Gloucestershire'),
			('GL','GL56','MORETON-IN-MARSH','Gloucestershire'),
			('GU','GU01','GUILDFORD','Surrey'),
			('GU','GU1','GUILDFORD','Surrey'),
			('GU','GU2','GUILDFORD','Surrey'),
			('GU','GU3','GUILDFORD','Surrey'),
			('GU','GU4','GUILDFORD','Surrey'),
			('GU','GU5','GUILDFORD','Surrey'),
			('GU','GU06','CRANLEIGH','Surrey'),
			('GU','GU6','CRANLEIGH','Surrey'),
			('GU','GU07','GODALMING','Surrey'),
			('GU','GU7','GODALMING','Surrey'),
			('GU','GU8','GODALMING','Surrey'),
			('GU','GU09','FARNHAM','Surrey'),
			('GU','GU9','FARNHAM','Surrey'),
			('GU','GU10','FARNHAM','Surrey'),
			('GU','GU11','ALDERSHOT','Hampshire'),
			('GU','GU12','ALDERSHOT','Hampshire'),
			('GU','GU14','FARNBOROUGH','Hampshire'),
			('GU','GU15','CAMBERLEY','Surrey'),
			('GU','GU16','CAMBERLEY','Surrey'),
			('GU','GU17','CAMBERLEY','Surrey'),
			('GU','GU95','CAMBERLEY','Surrey'),
			('GU','GU18','LIGHTWATER','Surrey'),
			('GU','GU19','BAGSHOT','Surrey'),
			('GU','GU20','WINDLESHAM','Surrey'),
			('GU','GU21','WOKING','Surrey'),
			('GU','GU22','WOKING','Surrey'),
			('GU','GU23','WOKING','Surrey'),
			('GU','GU24','WOKING','Surrey'),
			('GU','GU25','VIRGINIA WATER','Surrey'),
			('GU','GU26','HINDHEAD','Surrey'),
			('GU','GU27','HINDHEAD','Surrey'),
			('GU','GU27','HASLEMERE','Surrey'),
			('GU','GU28','PETWORTH','West Sussex'),
			('GU','GU29','MIDHURST','West Sussex'),
			('GU','GU30','LIPHOOK','Hampshire'),
			('GU','GU31','PETERSFIELD','Hampshire'),
			('GU','GU32','PETERSFIELD','Hampshire'),
			('GU','GU33','LISS','Hampshire'),
			('GU','GU34','ALTON','Hampshire'),
			('GU','GU35','BORDON','Hampshire'),
			('GU','GU46','YATELEY','Hampshire'),
			('GU','GU47','SANDHURST','Berkshire'),
			('GU','GU51','FLEET','Hampshire'),
			('GU','GU52','FLEET','Hampshire'),
			('GY','GY01','GUERNSEY','(Channel Isles)not'),
			('GY','GY1','GUERNSEY','(Channel Isles)not'),
			('GY','GY2','GUERNSEY','(Channel Isles)not'),
			('GY','GY3','GUERNSEY','(Channel Isles)not'),
			('GY','GY4','GUERNSEY','(Channel Isles)not'),
			('GY','GY5','GUERNSEY','(Channel Isles)not'),
			('GY','GY6','GUERNSEY','(Channel Isles)not'),
			('GY','GY7','GUERNSEY','(Channel Isles)not'),
			('GY','GY8','GUERNSEY','(Channel Isles)not'),
			('GY','GY9','GUERNSEY','(Channel Isles)not'),
			('GY','GY10','GUERNSEY','(Channel Isles)not'),
			('HA','HA00','WEMBLEY','Middlesex'),
			('HA','HA0','WEMBLEY','Middlesex'),
			('HA','HA9','WEMBLEY','Middlesex'),
			('HA','HA01','HARROW','Middlesex'),
			('HA','HA1','HARROW','Middlesex'),
			('HA','HA2','HARROW','Middlesex'),
			('HA','HA3','HARROW','Middlesex'),
			('HA','HA04','RUISLIP','Middlesex'),
			('HA','HA4','RUISLIP','Middlesex'),
			('HA','HA05','PINNER','Middlesex'),
			('HA','HA5','PINNER','Middlesex'),
			('HA','HA06','NORTHWOOD','Middlesex'),
			('HA','HA6','NORTHWOOD','Middlesex'),
			('HA','HA07','STANMORE','Middlesex'),
			('HA','HA7','STANMORE','Middlesex'),
			('HA','HA08','EDGWARE','Middlesex'),
			('HA','HA8','EDGWARE','Middlesex'),
			('HD','HD01','HUDDERSFIELD','(West Yorkshire)'),
			('HD','HD1','HUDDERSFIELD','(West Yorkshire)'),
			('HD','HD2','HUDDERSFIELD','(West Yorkshire)'),
			('HD','HD3','HUDDERSFIELD','(West Yorkshire)'),
			('HD','HD4','HUDDERSFIELD','(West Yorkshire)'),
			('HD','HD5','HUDDERSFIELD','(West Yorkshire)'),
			('HD','HD7','HUDDERSFIELD','(West Yorkshire)'),
			('HD','HD8','HUDDERSFIELD','(West Yorkshire)'),
			('HD','HD06','BRIGHOUSE','West Yorkshire'),
			('HD','HD6','BRIGHOUSE','West Yorkshire'),
			('HD','HD09','HOLMFIRTH','West Yorkshire'),
			('HD','HD9','HOLMFIRTH','West Yorkshire'),
			('HG','HG01','HARROGATE','North Yorkshire'),
			('HG','HG1','HARROGATE','North Yorkshire'),
			('HG','HG2','HARROGATE','North Yorkshire'),
			('HG','HG3','HARROGATE','North Yorkshire'),
			('HG','HG04','RIPON','North Yorkshire'),
			('HG','HG4','RIPON','North Yorkshire'),
			('HG','HG05','KNARESBOROUGH','North Yorkshire'),
			('HG','HG5','KNARESBOROUGH','North Yorkshire'),
			('HP','HP01','HEMEL HEMPSTEAD','Hertfordshire'),
			('HP','HP1','HEMEL HEMPSTEAD','Hertfordshire'),
			('HP','HP2','HEMEL HEMPSTEAD','Hertfordshire'),
			('HP','HP3','HEMEL HEMPSTEAD','Hertfordshire'),
			('HP','HP04','BERKHAMSTED','Hertfordshire'),
			('HP','HP4','BERKHAMSTED','Hertfordshire'),
			('HP','HP05','CHESHAM','Buckinghamshire'),
			('HP','HP5','CHESHAM','Buckinghamshire'),
			('HP','HP06','AMERSHAM','Buckinghamshire'),
			('HP','HP6','AMERSHAM','Buckinghamshire'),
			('HP','HP7','AMERSHAM','Buckinghamshire'),
			('HP','HP08','CHALFONT ST. GILES','Buckinghamshire'),
			('HP','HP8','CHALFONT ST. GILES','Buckinghamshire'),
			('HP','HP09','BEACONSFIELD','Buckinghamshire'),
			('HP','HP9','BEACONSFIELD','Buckinghamshire'),
			('HP','HP10','HIGH WYCOMBE','Buckinghamshire'),
			('HP','HP11','HIGH WYCOMBE','Buckinghamshire'),
			('HP','HP12','HIGH WYCOMBE','Buckinghamshire'),
			('HP','HP13','HIGH WYCOMBE','Buckinghamshire'),
			('HP','HP14','HIGH WYCOMBE','Buckinghamshire'),
			('HP','HP15','HIGH WYCOMBE','Buckinghamshire'),
			('HP','HP16','GREAT MISSENDEN','Buckinghamshire'),
			('HP','HP17','AYLESBURY','Buckinghamshire'),
			('HP','HP18','AYLESBURY','Buckinghamshire'),
			('HP','HP19','AYLESBURY','Buckinghamshire'),
			('HP','HP20','AYLESBURY','Buckinghamshire'),
			('HP','HP21','AYLESBURY','Buckinghamshire'),
			('HP','HP22','AYLESBURY','Buckinghamshire'),
			('HP','HP22','PRINCES RISBOROUGH','Buckinghamshire'),
			('HP','HP27','PRINCES RISBOROUGH','Buckinghamshire'),
			('HP','HP23','TRING','Hertfordshire'),
			('HR','HR01','HEREFORD','(Herefordshire)'),
			('HR','HR1','HEREFORD','(Herefordshire)'),
			('HR','HR2','HEREFORD','(Herefordshire)'),
			('HR','HR3','HEREFORD','(Herefordshire)'),
			('HR','HR4','HEREFORD','(Herefordshire)'),
			('HR','HR05','KINGTON','Herefordshire'),
			('HR','HR5','KINGTON','Herefordshire'),
			('HR','HR06','LEOMINSTER','Herefordshire'),
			('HR','HR6','LEOMINSTER','Herefordshire'),
			('HR','HR07','BROMYARD','Herefordshire'),
			('HR','HR7','BROMYARD','Herefordshire'),
			('HR','HR08','LEDBURY','Herefordshire'),
			('HR','HR8','LEDBURY','Herefordshire'),
			('HR','HR09','ROSS-ON-WYE','Herefordshire'),
			('HR','HR9','ROSS-ON-WYE','Herefordshire'),
			('HS','HS01','STORNOWAY','Isle of Lewis'),
			('HS','HS1','STORNOWAY','Isle of Lewis'),
			('HS','HS02','ISLE OF LEWIS','Isle of Lewis'),
			('HS','HS2','ISLE OF LEWIS','Isle of Lewis'),
			('HS','HS03','ISLE OF HARRIS','Isle of Harris'),
			('HS','HS3','ISLE OF HARRIS','Isle of Harris'),
			('HS','HS5','ISLE OF HARRIS','Isle of Harris'),
			('HS','HS04','ISLE OF SCALPAY','Isle of Scalpay'),
			('HS','HS4','ISLE OF SCALPAY','Isle of Scalpay'),
			('HS','HS06','ISLE OF NORTH UIST','Isle of North Uist'),
			('HS','HS6','ISLE OF NORTH UIST','Isle of North Uist'),
			('HS','HS07','ISLE OF BENBECULA','Isle of Benbecula'),
			('HS','HS7','ISLE OF BENBECULA','Isle of Benbecula'),
			('HS','HS08','ISLE OF SOUTH UIST','Inverness-shire'),
			('HS','HS8','ISLE OF SOUTH UIST','Inverness-shire'),
			('HS','HS09','ISLE OF BARRA','Isle of Barra'),
			('HS','HS9','ISLE OF BARRA','Isle of Barra'),
			('HU','HU01','HULL','(North Humberside)'),
			('HU','HU1','HULL','(North Humberside)'),
			('HU','HU2','HULL','(North Humberside)'),
			('HU','HU3','HULL','(North Humberside)'),
			('HU','HU4','HULL','(North Humberside)'),
			('HU','HU5','HULL','(North Humberside)'),
			('HU','HU6','HULL','(North Humberside)'),
			('HU','HU7','HULL','(North Humberside)'),
			('HU','HU8','HULL','(North Humberside)'),
			('HU','HU9','HULL','(North Humberside)'),
			('HU','HU10','HULL','(North Humberside)'),
			('HU','HU11','HULL','(North Humberside)'),
			('HU','HU12','HULL','(North Humberside)'),
			('HU','HU13','HESSLE','North Humberside'),
			('HU','HU14','NORTH FERRIBY','North Humberside'),
			('HU','HU15','BROUGH','North Humberside'),
			('HU','HU16','COTTINGHAM','North Humberside'),
			('HU','HU20','COTTINGHAM','North Humberside'),
			('HU','HU17','BEVERLEY','North Humberside'),
			('HU','HU18','HORNSEA','North Humberside'),
			('HU','HU19','WITHERNSEA','North Humberside'),
			('HX','HX01','HALIFAX','West Yorkshire'),
			('HX','HX1','HALIFAX','West Yorkshire'),
			('HX','HX2','HALIFAX','West Yorkshire'),
			('HX','HX3','HALIFAX','West Yorkshire'),
			('HX','HX4','HALIFAX','West Yorkshire'),
			('HX','HX01','ELLAND','West Yorkshire'),
			('HX','HX1','ELLAND','West Yorkshire'),
			('HX','HX5','ELLAND','West Yorkshire'),
			('HX','HX06','SOWERBY BRIDGE','West Yorkshire'),
			('HX','HX6','SOWERBY BRIDGE','West Yorkshire'),
			('HX','HX07','HEBDEN BRIDGE','West Yorkshire'),
			('HX','HX7','HEBDEN BRIDGE','West Yorkshire'),
			('IG','IG01','ILFORD','Essex'),
			('IG','IG1','ILFORD','Essex'),
			('IG','IG2','ILFORD','Essex'),
			('IG','IG3','ILFORD','Essex'),
			('IG','IG4','ILFORD','Essex'),
			('IG','IG5','ILFORD','Essex'),
			('IG','IG6','ILFORD','Essex'),
			('IG','IG07','CHIGWELL','Essex'),
			('IG','IG7','CHIGWELL','Essex'),
			('IG','IG8','CHIGWELL','Essex'),
			('IG','IG08','WOODFORD GREEN','Essex'),
			('IG','IG8','WOODFORD GREEN','Essex'),
			('IG','IG09','BUCKHURST HILL','Essex'),
			('IG','IG9','BUCKHURST HILL','Essex'),
			('IG','IG10','LOUGHTON','Essex'),
			('IG','IG11','BARKING','Essex'),
			('IM','IM01','ISLE OF MAN','(Isle of Man)not'),
			('IM','IM1','ISLE OF MAN','(Isle of Man)not'),
			('IM','IM2','ISLE OF MAN','(Isle of Man)not'),
			('IM','IM3','ISLE OF MAN','(Isle of Man)not'),
			('IM','IM4','ISLE OF MAN','(Isle of Man)not'),
			('IM','IM5','ISLE OF MAN','(Isle of Man)not'),
			('IM','IM6','ISLE OF MAN','(Isle of Man)not'),
			('IM','IM7','ISLE OF MAN','(Isle of Man)not'),
			('IM','IM8','ISLE OF MAN','(Isle of Man)not'),
			('IM','IM9','ISLE OF MAN','(Isle of Man)not'),
			('IM','IM99','ISLE OF MAN','(Isle of Man)not'),
			('IP','IP01','IPSWICH','(Suffolk)'),
			('IP','IP1','IPSWICH','(Suffolk)'),
			('IP','IP2','IPSWICH','(Suffolk)'),
			('IP','IP3','IPSWICH','(Suffolk)'),
			('IP','IP4','IPSWICH','(Suffolk)'),
			('IP','IP5','IPSWICH','(Suffolk)'),
			('IP','IP6','IPSWICH','(Suffolk)'),
			('IP','IP7','IPSWICH','(Suffolk)'),
			('IP','IP8','IPSWICH','(Suffolk)'),
			('IP','IP9','IPSWICH','(Suffolk)'),
			('IP','IP10','IPSWICH','(Suffolk)'),
			('IP','IP11','FELIXSTOWE','Suffolk'),
			('IP','IP12','WOODBRIDGE','Suffolk'),
			('IP','IP13','WOODBRIDGE','Suffolk'),
			('IP','IP14','STOWMARKET','Suffolk'),
			('IP','IP15','ALDEBURGH','Suffolk'),
			('IP','IP16','LEISTON','Suffolk'),
			('IP','IP17','SAXMUNDHAM','Suffolk'),
			('IP','IP18','SOUTHWOLD','Suffolk'),
			('IP','IP19','HALESWORTH','Suffolk'),
			('IP','IP20','HARLESTON','Norfolk'),
			('IP','IP21','DISS','Norfolk'),
			('IP','IP22','DISS','Norfolk'),
			('IP','IP98','DISS','Norfolk'),
			('IP','IP21','EYE','Suffolk'),
			('IP','IP23','EYE','Suffolk'),
			('IP','IP24','THETFORD','Norfolk'),
			('IP','IP25','THETFORD','Norfolk'),
			('IP','IP26','THETFORD','Norfolk'),
			('IP','IP27','BRANDON','Suffolk'),
			('IP','IP28','BURY ST. EDMUNDS','Suffolk'),
			('IP','IP29','BURY ST. EDMUNDS','Suffolk'),
			('IP','IP30','BURY ST. EDMUNDS','Suffolk'),
			('IP','IP31','BURY ST. EDMUNDS','Suffolk'),
			('IP','IP32','BURY ST. EDMUNDS','Suffolk'),
			('IP','IP33','BURY ST. EDMUNDS','Suffolk'),
			('IV','IV01','INVERNESS','(Inverness-shire)'),
			('IV','IV1','INVERNESS','(Inverness-shire)'),
			('IV','IV2','INVERNESS','(Inverness-shire)'),
			('IV','IV3','INVERNESS','(Inverness-shire)'),
			('IV','IV5','INVERNESS','(Inverness-shire)'),
			('IV','IV13','INVERNESS','(Inverness-shire)'),
			('IV','IV63','INVERNESS','(Inverness-shire)'),
			('IV','IV99','INVERNESS','(Inverness-shire)'),
			('IV','IV04','BEAULY','Inverness-shire'),
			('IV','IV4','BEAULY','Inverness-shire'),
			('IV','IV06','MUIR OF ORD','Ross-shire'),
			('IV','IV6','MUIR OF ORD','Ross-shire'),
			('IV','IV07','DINGWALL','Ross-shire'),
			('IV','IV7','DINGWALL','Ross-shire'),
			('IV','IV15','DINGWALL','Ross-shire'),
			('IV','IV16','DINGWALL','Ross-shire'),
			('IV','IV08','MUNLOCHY','Ross-shire'),
			('IV','IV8','MUNLOCHY','Ross-shire'),
			('IV','IV09','AVOCH','Ross-shire'),
			('IV','IV9','AVOCH','Ross-shire'),
			('IV','IV10','FORTROSE','Ross-shire'),
			('IV','IV11','CROMARTY','Ross-shire'),
			('IV','IV12','NAIRN','(Nairnshire)'),
			('IV','IV14','STRATHPEFFER','Ross-shire'),
			('IV','IV17','ALNESS','Ross-shire'),
			('IV','IV18','INVERGORDON','Ross-shire'),
			('IV','IV19','TAIN','Ross-shire'),
			('IV','IV20','TAIN','Ross-shire'),
			('IV','IV21','GAIRLOCH','Ross-shire'),
			('IV','IV22','ACHNASHEEN','Ross-shire'),
			('IV','IV23','GARVE','Ross-shire'),
			('IV','IV24','ARDGAY','Sutherland'),
			('IV','IV25','DORNOCH','Sutherland'),
			('IV','IV26','ULLAPOOL','Ross-shire'),
			('IV','IV27','LAIRG','Sutherland'),
			('IV','IV28','ROGART','Sutherland'),
			('IV','IV30','ELGIN','Morayshire'),
			('IV','IV31','LOSSIEMOUTH','Morayshire'),
			('IV','IV32','FOCHABERS','Morayshire'),
			('IV','IV36','FORRES','Morayshire'),
			('IV','IV40','KYLE','Ross-shire'),
			('IV','IV41','ISLE OF SKYE','Isle of Skye'),
			('IV','IV42','ISLE OF SKYE','Isle of Skye'),
			('IV','IV43','ISLE OF SKYE','Isle of Skye'),
			('IV','IV44','ISLE OF SKYE','Isle of Skye'),
			('IV','IV45','ISLE OF SKYE','Isle of Skye'),
			('IV','IV46','ISLE OF SKYE','Isle of Skye'),
			('IV','IV47','ISLE OF SKYE','Isle of Skye'),
			('IV','IV48','ISLE OF SKYE','Isle of Skye'),
			('IV','IV49','ISLE OF SKYE','Isle of Skye'),
			('IV','IV55','ISLE OF SKYE','Isle of Skye'),
			('IV','IV56','ISLE OF SKYE','Isle of Skye'),
			('IV','IV51','PORTREE','Isle of Skye'),
			('IV','IV52','PLOCKTON','Ross-shire'),
			('IV','IV53','STROME FERRY','Ross-shire'),
			('IV','IV54','STRATHCARRON','Ross-shire'),
			('JE','JE01','JERSEY','(Channel Isles)not'),
			('JE','JE1','JERSEY','(Channel Isles)not'),
			('JE','JE2','JERSEY','(Channel Isles)not'),
			('JE','JE3','JERSEY','(Channel Isles)not'),
			('JE','JE4','JERSEY','(Channel Isles)not'),
			('JE','JE5','JERSEY','(Channel Isles)not'),
			('KA','KA01','KILMARNOCK','Ayrshire'),
			('KA','KA1','KILMARNOCK','Ayrshire'),
			('KA','KA2','KILMARNOCK','Ayrshire'),
			('KA','KA3','KILMARNOCK','Ayrshire'),
			('KA','KA04','GALSTON','Ayrshire'),
			('KA','KA4','GALSTON','Ayrshire'),
			('KA','KA05','MAUCHLINE','Ayrshire'),
			('KA','KA5','MAUCHLINE','Ayrshire'),
			('KA','KA06','AYR','(Ayrshire)'),
			('KA','KA6','AYR','(Ayrshire)'),
			('KA','KA7','AYR','(Ayrshire)'),
			('KA','KA8','AYR','(Ayrshire)'),
			('KA','KA09','PRESTWICK','Ayrshire'),
			('KA','KA9','PRESTWICK','Ayrshire'),
			('KA','KA10','TROON','Ayrshire'),
			('KA','KA11','IRVINE','Ayrshire'),
			('KA','KA12','IRVINE','Ayrshire'),
			('KA','KA13','KILWINNING','Ayrshire'),
			('KA','KA14','BEITH','Ayrshire'),
			('KA','KA15','BEITH','Ayrshire'),
			('KA','KA16','NEWMILNS','Ayrshire'),
			('KA','KA17','DARVEL','Ayrshire'),
			('KA','KA18','CUMNOCK','Ayrshire'),
			('KA','KA19','MAYBOLE','Ayrshire'),
			('KA','KA20','STEVENSTON','Ayrshire'),
			('KA','KA21','SALTCOATS','Ayrshire'),
			('KA','KA22','ARDROSSAN','Ayrshire'),
			('KA','KA23','WEST KILBRIDE','Ayrshire'),
			('KA','KA24','DALRY','Ayrshire'),
			('KA','KA25','KILBIRNIE','Ayrshire'),
			('KA','KA26','GIRVAN','Ayrshire'),
			('KA','KA27','ISLE OF ARRAN','Isle of Arran'),
			('KA','KA28','ISLE OF CUMBRAE','Isle of Cumbrae'),
			('KA','KA29','LARGS','Ayrshire'),
			('KA','KA30','LARGS','Ayrshire'),
			('KT','KT01','KINGSTON UPON THAMES','Surrey'),
			('KT','KT1','KINGSTON UPON THAMES','Surrey'),
			('KT','KT2','KINGSTON UPON THAMES','Surrey'),
			('KT','KT03','NEW MALDEN','Surrey'),
			('KT','KT3','NEW MALDEN','Surrey'),
			('KT','KT04','WORCESTER PARK','Surrey'),
			('KT','KT4','WORCESTER PARK','Surrey'),
			('KT','KT05','SURBITON','Surrey'),
			('KT','KT5','SURBITON','Surrey'),
			('KT','KT6','SURBITON','Surrey'),
			('KT','KT07','THAMES DITTON','Surrey'),
			('KT','KT7','THAMES DITTON','Surrey'),
			('KT','KT08','EAST MOLESEY','Surrey'),
			('KT','KT8','EAST MOLESEY','Surrey'),
			('KT','KT08','WEST MOLESEY','Surrey'),
			('KT','KT8','WEST MOLESEY','Surrey'),
			('KT','KT09','CHESSINGTON','Surrey'),
			('KT','KT9','CHESSINGTON','Surrey'),
			('KT','KT10','ESHER','Surrey'),
			('KT','KT11','COBHAM','Surrey'),
			('KT','KT12','WALTON-ON-THAMES','Surrey'),
			('KT','KT13','WEYBRIDGE','Surrey'),
			('KT','KT14','WEST BYFLEET','Surrey'),
			('KT','KT15','ADDLESTONE','Surrey'),
			('KT','KT16','CHERTSEY','Surrey'),
			('KT','KT17','EPSOM','Surrey'),
			('KT','KT18','EPSOM','Surrey'),
			('KT','KT19','EPSOM','Surrey'),
			('KT','KT20','TADWORTH','Surrey'),
			('KT','KT21','ASHTEAD','Surrey'),
			('KT','KT22','LEATHERHEAD','Surrey'),
			('KT','KT23','LEATHERHEAD','Surrey'),
			('KT','KT24','LEATHERHEAD','Surrey'),
			('KW','KW01','WICK','Caithness'),
			('KW','KW1','WICK','Caithness'),
			('KW','KW02','LYBSTER','Caithness'),
			('KW','KW2','LYBSTER','Caithness'),
			('KW','KW3','LYBSTER','Caithness'),
			('KW','KW05','LATHERON','Caithness'),
			('KW','KW5','LATHERON','Caithness'),
			('KW','KW06','DUNBEATH','Caithness'),
			('KW','KW6','DUNBEATH','Caithness'),
			('KW','KW07','BERRIEDALE','Caithness'),
			('KW','KW7','BERRIEDALE','Caithness'),
			('KW','KW08','HELMSDALE','Sutherland'),
			('KW','KW8','HELMSDALE','Sutherland'),
			('KW','KW09','BRORA','Sutherland'),
			('KW','KW9','BRORA','Sutherland'),
			('KW','KW10','GOLSPIE','Sutherland'),
			('KW','KW11','KINBRACE','Sutherland'),
			('KW','KW12','HALKIRK','Caithness'),
			('KW','KW13','FORSINARD','Sutherland'),
			('KW','KW14','THURSO','Caithness'),
			('KW','KW15','KIRKWALL','Orkney'),
			('KW','KW16','STROMNESS','Orkney'),
			('KW','KW17','ORKNEY','(Orkney)'),
			('KY','KY01','KIRKCALDY','Fife'),
			('KY','KY1','KIRKCALDY','Fife'),
			('KY','KY2','KIRKCALDY','Fife'),
			('KY','KY03','BURNTISLAND','Fife'),
			('KY','KY3','BURNTISLAND','Fife'),
			('KY','KY04','COWDENBEATH','Fife'),
			('KY','KY4','COWDENBEATH','Fife'),
			('KY','KY04','KELTY','Fife'),
			('KY','KY4','KELTY','Fife'),
			('KY','KY05','LOCHGELLY','Fife'),
			('KY','KY5','LOCHGELLY','Fife'),
			('KY','KY06','GLENROTHES','Fife'),
			('KY','KY6','GLENROTHES','Fife'),
			('KY','KY7','GLENROTHES','Fife'),
			('KY','KY08','LEVEN','Fife'),
			('KY','KY8','LEVEN','Fife'),
			('KY','KY9','LEVEN','Fife'),
			('KY','KY10','ANSTRUTHER','Fife'),
			('KY','KY11','DUNFERMLINE','Fife'),
			('KY','KY12','DUNFERMLINE','Fife'),
			('KY','KY99','DUNFERMLINE','Fife'),
			('KY','KY11','INVERKEITHING','Fife'),
			('KY','KY13','KINROSS','(Kinross-shire)'),
			('KY','KY14','CUPAR','Fife'),
			('KY','KY15','CUPAR','Fife'),
			('KY','KY16','ST. ANDREWS','Fife'),
			('L','L001','LIVERPOOL','(Merseyside)'),
			('L','L1','LIVERPOOL','(Merseyside)'),
			('L','L2','LIVERPOOL','(Merseyside)'),
			('L','L3','LIVERPOOL','(Merseyside)'),
			('L','L4','LIVERPOOL','(Merseyside)'),
			('L','L5','LIVERPOOL','(Merseyside)'),
			('L','L6','LIVERPOOL','(Merseyside)'),
			('L','L7','LIVERPOOL','(Merseyside)'),
			('L','L8','LIVERPOOL','(Merseyside)'),
			('L','L9','LIVERPOOL','(Merseyside)'),
			('L','L10','LIVERPOOL','(Merseyside)'),
			('L','L11','LIVERPOOL','(Merseyside)'),
			('L','L12','LIVERPOOL','(Merseyside)'),
			('L','L13','LIVERPOOL','(Merseyside)'),
			('L','L14','LIVERPOOL','(Merseyside)'),
			('L','L15','LIVERPOOL','(Merseyside)'),
			('L','L16','LIVERPOOL','(Merseyside)'),
			('L','L17','LIVERPOOL','(Merseyside)'),
			('L','L18','LIVERPOOL','(Merseyside)'),
			('L','L19','LIVERPOOL','(Merseyside)'),
			('L','L20','LIVERPOOL','(Merseyside)'),
			('L','L21','LIVERPOOL','(Merseyside)'),
			('L','L22','LIVERPOOL','(Merseyside)'),
			('L','L23','LIVERPOOL','(Merseyside)'),
			('L','L24','LIVERPOOL','(Merseyside)'),
			('L','L25','LIVERPOOL','(Merseyside)'),
			('L','L26','LIVERPOOL','(Merseyside)'),
			('L','L27','LIVERPOOL','(Merseyside)'),
			('L','L28','LIVERPOOL','(Merseyside)'),
			('L','L29','LIVERPOOL','(Merseyside)'),
			('L','L31','LIVERPOOL','(Merseyside)'),
			('L','L32','LIVERPOOL','(Merseyside)'),
			('L','L33','LIVERPOOL','(Merseyside)'),
			('L','L36','LIVERPOOL','(Merseyside)'),
			('L','L37','LIVERPOOL','(Merseyside)'),
			('L','L38','LIVERPOOL','(Merseyside)'),
			('L','L67','LIVERPOOL','(Merseyside)'),
			('L','L68','LIVERPOOL','(Merseyside)'),
			('L','L69','LIVERPOOL','(Merseyside)'),
			('L','L70','LIVERPOOL','(Merseyside)'),
			('L','L71','LIVERPOOL','(Merseyside)'),
			('L','L72','LIVERPOOL','(Merseyside)'),
			('L','L73','LIVERPOOL','(Merseyside)'),
			('L','L74','LIVERPOOL','(Merseyside)'),
			('L','L75','LIVERPOOL','(Merseyside)'),
			('L','L020','BOOTLE','Merseyside'),
			('L','L20','BOOTLE','Merseyside'),
			('L','L30','BOOTLE','Merseyside'),
			('L','L69','BOOTLE','Merseyside'),
			('L','L80','BOOTLE','Merseyside'),
			('L','GIR','BOOTLE','Merseyside'),
			('L','L034','PRESCOT','Merseyside'),
			('L','L34','PRESCOT','Merseyside'),
			('L','L35','PRESCOT','Merseyside'),
			('L','L039','ORMSKIRK','Lancashire'),
			('L','L39','ORMSKIRK','Lancashire'),
			('L','L40','ORMSKIRK','Lancashire'),
			('LA','LA01','LANCASTER','(Lancashire)'),
			('LA','LA1','LANCASTER','(Lancashire)'),
			('LA','LA2','LANCASTER','(Lancashire)'),
			('LA','LA03','MORECAMBE','Lancashire'),
			('LA','LA3','MORECAMBE','Lancashire'),
			('LA','LA4','MORECAMBE','Lancashire'),
			('LA','LA05','CARNFORTH','Lancashire'),
			('LA','LA5','CARNFORTH','Lancashire'),
			('LA','LA6','CARNFORTH','Lancashire'),
			('LA','LA07','MILNTHORPE','Cumbria'),
			('LA','LA7','MILNTHORPE','Cumbria'),
			('LA','LA08','KENDAL','Cumbria'),
			('LA','LA8','KENDAL','Cumbria'),
			('LA','LA9','KENDAL','Cumbria'),
			('LA','LA10','SEDBERGH','Cumbria'),
			('LA','LA11','GRANGE-OVER-SANDS','Cumbria'),
			('LA','LA12','ULVERSTON','Cumbria'),
			('LA','LA13','BARROW-IN-FURNESS','Cumbria'),
			('LA','LA14','BARROW-IN-FURNESS','Cumbria'),
			('LA','LA14','DALTON-IN-FURNESS','Cumbria'),
			('LA','LA15','DALTON-IN-FURNESS','Cumbria'),
			('LA','LA16','ASKAM-IN-FURNESS','Cumbria'),
			('LA','LA17','KIRKBY-IN-FURNESS','Cumbria');
		END

		BEGIN
			INSERT INTO dbo.PostalDistrict (PostcodeArea, PostcodeDistrict, PostTown, FormerPostalCounty)
			VALUES
			('LA','LA18','MILLOM','Cumbria'),
			('LA','LA19','MILLOM','Cumbria'),
			('LA','LA20','BROUGHTON-IN-FURNESS','Cumbria'),
			('LA','LA21','CONISTON','Cumbria'),
			('LA','LA22','AMBLESIDE','Cumbria'),
			('LA','LA23','WINDERMERE','Cumbria'),
			('LD','LD01','LLANDRINDOD WELLS','Powys'),
			('LD','LD1','LLANDRINDOD WELLS','Powys'),
			('LD','LD02','BUILTH WELLS','Powys'),
			('LD','LD2','BUILTH WELLS','Powys'),
			('LD','LD03','BRECON','Powys'),
			('LD','LD3','BRECON','Powys'),
			('LD','LD04','LLANGAMMARCH WELLS','Powys'),
			('LD','LD4','LLANGAMMARCH WELLS','Powys'),
			('LD','LD05','LLANWRTYD WELLS','Powys'),
			('LD','LD5','LLANWRTYD WELLS','Powys'),
			('LD','LD06','RHAYADER','Powys'),
			('LD','LD6','RHAYADER','Powys'),
			('LD','LD07','KNIGHTON','Powys'),
			('LD','LD7','KNIGHTON','Powys'),
			('LD','LD08','PRESTEIGNE','Powys'),
			('LD','LD8','PRESTEIGNE','Powys'),
			('LE','LE01','LEICESTER','(Leicestershire)'),
			('LE','LE1','LEICESTER','(Leicestershire)'),
			('LE','LE2','LEICESTER','(Leicestershire)'),
			('LE','LE3','LEICESTER','(Leicestershire)'),
			('LE','LE4','LEICESTER','(Leicestershire)'),
			('LE','LE5','LEICESTER','(Leicestershire)'),
			('LE','LE6','LEICESTER','(Leicestershire)'),
			('LE','LE7','LEICESTER','(Leicestershire)'),
			('LE','LE8','LEICESTER','(Leicestershire)'),
			('LE','LE9','LEICESTER','(Leicestershire)'),
			('LE','LE19','LEICESTER','(Leicestershire)'),
			('LE','LE21','LEICESTER','(Leicestershire)'),
			('LE','LE41','LEICESTER','(Leicestershire)'),
			('LE','LE55','LEICESTER','(Leicestershire)'),
			('LE','LE87','LEICESTER','(Leicestershire)'),
			('LE','LE94','LEICESTER','(Leicestershire)'),
			('LE','LE95','LEICESTER','(Leicestershire)'),
			('LE','LE10','HINCKLEY','Leicestershire'),
			('LE','LE11','LOUGHBOROUGH','Leicestershire'),
			('LE','LE12','LOUGHBOROUGH','Leicestershire'),
			('LE','LE13','MELTON MOWBRAY','Leicestershire'),
			('LE','LE14','MELTON MOWBRAY','Leicestershire'),
			('LE','LE15','OAKHAM','Leicestershire / Rutland'),
			('LE','LE16','MARKET HARBOROUGH','Leicestershire / Rutland'),
			('LE','LE17','LUTTERWORTH','Leicestershire'),
			('LE','LE18','WIGSTON','Leicestershire'),
			('LE','LE65','ASHBY-DE-LA-ZOUCH','Leicestershire'),
			('LE','LE67','COALVILLE','Leicestershire'),
			('LE','LE67','IBSTOCK','Leicestershire'),
			('LE','LE67','MARKFIELD','Leicestershire'),
			('LL','LL11','WREXHAM','Clwyd'),
			('LL','LL12','WREXHAM','Clwyd'),
			('LL','LL13','WREXHAM','Clwyd'),
			('LL','LL14','WREXHAM','Clwyd'),
			('LL','LL15','RUTHIN','Clwyd'),
			('LL','LL16','DENBIGH','Clwyd'),
			('LL','LL17','ST. ASAPH','Clwyd'),
			('LL','LL18','ST. ASAPH','Clwyd'),
			('LL','LL18','RHYL','Clwyd'),
			('LL','LL19','PRESTATYN','Clwyd'),
			('LL','LL20','LLANGOLLEN','Clwyd'),
			('LL','LL21','CORWEN','Clwyd'),
			('LL','LL22','ABERGELE','Clwyd'),
			('LL','LL23','BALA','Gwynedd'),
			('LL','LL24','BETWS-Y-COED','Gwynedd'),
			('LL','LL25','DOLWYDDELAN','Gwynedd'),
			('LL','LL26','LLANRWST','Gwynedd'),
			('LL','LL27','TREFRIW','Gwynedd'),
			('LL','LL28','COLWYN BAY','Clwyd'),
			('LL','LL29','COLWYN BAY','Clwyd'),
			('LL','LL30','LLANDUDNO','Gwynedd'),
			('LL','LL31','CONWY','Gwynedd'),
			('LL','LL32','CONWY','Gwynedd'),
			('LL','LL31','LLANDUDNO JUNCTION','Gwynedd'),
			('LL','LL33','LLANFAIRFECHAN','Gwynedd'),
			('LL','LL34','PENMAENMAWR','Gwynedd'),
			('LL','LL35','ABERDOVEY','Gwynedd'),
			('LL','LL36','TYWYN','Gwynedd'),
			('LL','LL37','LLWYNGWRIL','Gwynedd'),
			('LL','LL38','FAIRBOURNE','Gwynedd'),
			('LL','LL39','ARTHOG','Gwynedd'),
			('LL','LL40','DOLGELLAU','Gwynedd'),
			('LL','LL41','BLAENAU FFESTINIOG','Gwynedd'),
			('LL','LL42','BARMOUTH','Gwynedd'),
			('LL','LL43','TALYBONT','Gwynedd'),
			('LL','LL44','DYFFRYN ARDUDWY','Gwynedd'),
			('LL','LL45','LLANBEDR','Gwynedd'),
			('LL','LL46','HARLECH','Gwynedd'),
			('LL','LL47','TALSARNAU','Gwynedd'),
			('LL','LL48','PENRHYNDEUDRAETH','Gwynedd'),
			('LL','LL49','PORTHMADOG','Gwynedd'),
			('LL','LL51','GARNDOLBENMAEN','Gwynedd'),
			('LL','LL52','CRICCIETH','Gwynedd'),
			('LL','LL53','PWLLHELI','Gwynedd'),
			('LL','LL54','CAERNARFON','Gwynedd'),
			('LL','LL55','CAERNARFON','Gwynedd'),
			('LL','LL56','Y FELINHELI','Gwynedd'),
			('LL','LL57','BANGOR','Gwynedd'),
			('LL','LL58','BEAUMARIS','Gwynedd'),
			('LL','LL59','MENAI BRIDGE','Gwynedd'),
			('LL','LL60','GAERWEN','Gwynedd'),
			('LL','LL61','LLANFAIRPWLLGWYNGYLL','Gwynedd'),
			('LL','LL62','BODORGAN','Gwynedd'),
			('LL','LL63','TY CROES','Gwynedd'),
			('LL','LL64','RHOSNEIGR','Gwynedd'),
			('LL','LL77','RHOSNEIGR','Gwynedd'),
			('LL','LL65','HOLYHEAD','Gwynedd'),
			('LL','LL66','RHOSGOCH','Gwynedd'),
			('LL','LL67','CEMAES BAY','Gwynedd'),
			('LL','LL68','AMLWCH','Gwynedd'),
			('LL','LL69','PENYSARN','Gwynedd'),
			('LL','LL70','DULAS','Gwynedd'),
			('LL','LL71','LLANERCHYMEDD','Gwynedd'),
			('LL','LL72','MOELFRE','Gwynedd'),
			('LL','LL73','MARIANGLAS','Gwynedd'),
			('LL','LL74','TYN-Y-GONGL','Gwynedd'),
			('LL','LL75','PENTRAETH','Gwynedd'),
			('LL','LL76','LLANBEDRGOCH','Gwynedd'),
			('LL','LL77','LLANGEFNI','Gwynedd'),
			('LL','LL78','BRYNTEG','Gwynedd'),
			('LN','LN01','LINCOLN','(Lincolnshire)'),
			('LN','LN1','LINCOLN','(Lincolnshire)'),
			('LN','LN2','LINCOLN','(Lincolnshire)'),
			('LN','LN3','LINCOLN','(Lincolnshire)'),
			('LN','LN4','LINCOLN','(Lincolnshire)'),
			('LN','LN5','LINCOLN','(Lincolnshire)'),
			('LN','LN6','LINCOLN','(Lincolnshire)'),
			('LN','LN07','MARKET RASEN','Lincolnshire'),
			('LN','LN7','MARKET RASEN','Lincolnshire'),
			('LN','LN8','MARKET RASEN','Lincolnshire'),
			('LN','LN09','HORNCASTLE','Lincolnshire'),
			('LN','LN9','HORNCASTLE','Lincolnshire'),
			('LN','LN10','WOODHALL SPA','Lincolnshire'),
			('LN','LN11','LOUTH','Lincolnshire'),
			('LN','LN12','MABLETHORPE','Lincolnshire'),
			('LN','LN13','ALFORD','Lincolnshire'),
			('LS','LS01','LEEDS','(West Yorkshire)'),
			('LS','LS1','LEEDS','(West Yorkshire)'),
			('LS','LS2','LEEDS','(West Yorkshire)'),
			('LS','LS3','LEEDS','(West Yorkshire)'),
			('LS','LS4','LEEDS','(West Yorkshire)'),
			('LS','LS5','LEEDS','(West Yorkshire)'),
			('LS','LS6','LEEDS','(West Yorkshire)'),
			('LS','LS7','LEEDS','(West Yorkshire)'),
			('LS','LS8','LEEDS','(West Yorkshire)'),
			('LS','LS9','LEEDS','(West Yorkshire)'),
			('LS','LS10','LEEDS','(West Yorkshire)'),
			('LS','LS11','LEEDS','(West Yorkshire)'),
			('LS','LS12','LEEDS','(West Yorkshire)'),
			('LS','LS13','LEEDS','(West Yorkshire)'),
			('LS','LS14','LEEDS','(West Yorkshire)'),
			('LS','LS15','LEEDS','(West Yorkshire)'),
			('LS','LS16','LEEDS','(West Yorkshire)'),
			('LS','LS17','LEEDS','(West Yorkshire)'),
			('LS','LS18','LEEDS','(West Yorkshire)'),
			('LS','LS19','LEEDS','(West Yorkshire)'),
			('LS','LS20','LEEDS','(West Yorkshire)'),
			('LS','LS25','LEEDS','(West Yorkshire)'),
			('LS','LS26','LEEDS','(West Yorkshire)'),
			('LS','LS27','LEEDS','(West Yorkshire)'),
			('LS','LS88','LEEDS','(West Yorkshire)'),
			('LS','LS98','LEEDS','(West Yorkshire)'),
			('LS','LS99','LEEDS','(West Yorkshire)'),
			('LS','LS21','OTLEY','West Yorkshire'),
			('LS','LS22','WETHERBY','West Yorkshire'),
			('LS','LS23','WETHERBY','West Yorkshire'),
			('LS','LS24','TADCASTER','North Yorkshire'),
			('LS','LS28','PUDSEY','West Yorkshire'),
			('LS','LS29','ILKLEY','West Yorkshire'),
			('LU','LU01','LUTON','(Bedfordshire)'),
			('LU','LU1','LUTON','(Bedfordshire)'),
			('LU','LU2','LUTON','(Bedfordshire)'),
			('LU','LU3','LUTON','(Bedfordshire)'),
			('LU','LU4','LUTON','(Bedfordshire)'),
			('LU','LU05','DUNSTABLE','Bedfordshire'),
			('LU','LU5','DUNSTABLE','Bedfordshire'),
			('LU','LU6','DUNSTABLE','Bedfordshire'),
			('LU','LU07','LEIGHTON BUZZARD','Bedfordshire'),
			('LU','LU7','LEIGHTON BUZZARD','Bedfordshire'),
			('M','M001','MANCHESTER','(Lancashire)'),
			('M','M1','MANCHESTER','(Lancashire)'),
			('M','M2','MANCHESTER','(Lancashire)'),
			('M','M3','MANCHESTER','(Lancashire)'),
			('M','M4','MANCHESTER','(Lancashire)'),
			('M','M8','MANCHESTER','(Lancashire)'),
			('M','M9','MANCHESTER','(Lancashire)'),
			('M','M11','MANCHESTER','(Lancashire)'),
			('M','M12','MANCHESTER','(Lancashire)'),
			('M','M13','MANCHESTER','(Lancashire)'),
			('M','M14','MANCHESTER','(Lancashire)'),
			('M','M15','MANCHESTER','(Lancashire)'),
			('M','M16','MANCHESTER','(Lancashire)'),
			('M','M17','MANCHESTER','(Lancashire)'),
			('M','M18','MANCHESTER','(Lancashire)'),
			('M','M19','MANCHESTER','(Lancashire)'),
			('M','M20','MANCHESTER','(Lancashire)'),
			('M','M21','MANCHESTER','(Lancashire)'),
			('M','M22','MANCHESTER','(Lancashire)'),
			('M','M23','MANCHESTER','(Lancashire)'),
			('M','M24','MANCHESTER','(Lancashire)'),
			('M','M25','MANCHESTER','(Lancashire)'),
			('M','M26','MANCHESTER','(Lancashire)'),
			('M','M27','MANCHESTER','(Lancashire)'),
			('M','M28','MANCHESTER','(Lancashire)'),
			('M','M29','MANCHESTER','(Lancashire)'),
			('M','M30','MANCHESTER','(Lancashire)'),
			('M','M31','MANCHESTER','(Lancashire)'),
			('M','M32','MANCHESTER','(Lancashire)'),
			('M','M34','MANCHESTER','(Lancashire)'),
			('M','M35','MANCHESTER','(Lancashire)'),
			('M','M38','MANCHESTER','(Lancashire)'),
			('M','M40','MANCHESTER','(Lancashire)'),
			('M','M41','MANCHESTER','(Lancashire)'),
			('M','M43','MANCHESTER','(Lancashire)'),
			('M','M44','MANCHESTER','(Lancashire)'),
			('M','M45','MANCHESTER','(Lancashire)'),
			('M','M46','MANCHESTER','(Lancashire)'),
			('M','M60','MANCHESTER','(Lancashire)'),
			('M','M61','MANCHESTER','(Lancashire)'),
			('M','M90','MANCHESTER','(Lancashire)'),
			('M','M99','MANCHESTER','(Lancashire)'),
			('M','M003','SALFORD','(Lancashire)'),
			('M','M3','SALFORD','(Lancashire)'),
			('M','M5','SALFORD','(Lancashire)'),
			('M','M6','SALFORD','(Lancashire)'),
			('M','M7','SALFORD','(Lancashire)'),
			('M','M50','SALFORD','(Lancashire)'),
			('M','M60','SALFORD','(Lancashire)'),
			('M','M033','SALE','Cheshire'),
			('M','M33','SALE','Cheshire'),
			('ME','ME01','ROCHESTER','Kent'),
			('ME','ME1','ROCHESTER','Kent'),
			('ME','ME2','ROCHESTER','Kent'),
			('ME','ME3','ROCHESTER','Kent'),
			('ME','ME04','CHATHAM','Kent'),
			('ME','ME4','CHATHAM','Kent'),
			('ME','ME5','CHATHAM','Kent'),
			('ME','ME06','AYLESFORD','Kent'),
			('ME','ME6','AYLESFORD','Kent'),
			('ME','ME20','AYLESFORD','Kent'),
			('ME','ME06','SNODLAND','Kent'),
			('ME','ME6','SNODLAND','Kent'),
			('ME','ME06','WEST MALLING','Kent'),
			('ME','ME6','WEST MALLING','Kent'),
			('ME','ME19','WEST MALLING','Kent'),
			('ME','ME07','GILLINGHAM','Kent'),
			('ME','ME7','GILLINGHAM','Kent'),
			('ME','ME8','GILLINGHAM','Kent'),
			('ME','ME09','SITTINGBOURNE','Kent'),
			('ME','ME9','SITTINGBOURNE','Kent'),
			('ME','ME10','SITTINGBOURNE','Kent'),
			('ME','ME11','QUEENBOROUGH','Kent'),
			('ME','ME12','SHEERNESS','Kent'),
			('ME','ME13','FAVERSHAM','Kent'),
			('ME','ME14','MAIDSTONE','Kent'),
			('ME','ME15','MAIDSTONE','Kent'),
			('ME','ME16','MAIDSTONE','Kent'),
			('ME','ME17','MAIDSTONE','Kent'),
			('ME','ME18','MAIDSTONE','Kent'),
			('ME','ME99','MAIDSTONE','Kent'),
			('MK','MK01','MILTON KEYNES','(Buckinghamshire)'),
			('MK','MK1','MILTON KEYNES','(Buckinghamshire)'),
			('MK','MK2','MILTON KEYNES','(Buckinghamshire)'),
			('MK','MK3','MILTON KEYNES','(Buckinghamshire)'),
			('MK','MK4','MILTON KEYNES','(Buckinghamshire)'),
			('MK','MK5','MILTON KEYNES','(Buckinghamshire)'),
			('MK','MK6','MILTON KEYNES','(Buckinghamshire)'),
			('MK','MK7','MILTON KEYNES','(Buckinghamshire)'),
			('MK','MK8','MILTON KEYNES','(Buckinghamshire)'),
			('MK','MK9','MILTON KEYNES','(Buckinghamshire)'),
			('MK','MK10','MILTON KEYNES','(Buckinghamshire)'),
			('MK','MK11','MILTON KEYNES','(Buckinghamshire)'),
			('MK','MK12','MILTON KEYNES','(Buckinghamshire)'),
			('MK','MK13','MILTON KEYNES','(Buckinghamshire)'),
			('MK','MK14','MILTON KEYNES','(Buckinghamshire)'),
			('MK','MK15','MILTON KEYNES','(Buckinghamshire)'),
			('MK','MK17','MILTON KEYNES','(Buckinghamshire)'),
			('MK','MK19','MILTON KEYNES','(Buckinghamshire)'),
			('MK','MK77','MILTON KEYNES','(Buckinghamshire)'),
			('MK','MK16','NEWPORT PAGNELL','Buckinghamshire'),
			('MK','MK18','BUCKINGHAM','(Buckinghamshire)'),
			('MK','MK40','BEDFORD','(Bedfordshire)'),
			('MK','MK41','BEDFORD','(Bedfordshire)'),
			('MK','MK42','BEDFORD','(Bedfordshire)'),
			('MK','MK43','BEDFORD','(Bedfordshire)'),
			('MK','MK44','BEDFORD','(Bedfordshire)'),
			('MK','MK45','BEDFORD','(Bedfordshire)'),
			('MK','MK46','OLNEY','Buckinghamshire'),
			('ML','ML01','MOTHERWELL','Lanarkshire'),
			('ML','ML1','MOTHERWELL','Lanarkshire'),
			('ML','ML02','WISHAW','Lanarkshire'),
			('ML','ML2','WISHAW','Lanarkshire'),
			('ML','ML03','HAMILTON','Lanarkshire'),
			('ML','ML3','HAMILTON','Lanarkshire'),
			('ML','ML04','BELLSHILL','Lanarkshire'),
			('ML','ML4','BELLSHILL','Lanarkshire'),
			('ML','ML05','COATBRIDGE','Lanarkshire'),
			('ML','ML5','COATBRIDGE','Lanarkshire'),
			('ML','ML06','AIRDRIE','Lanarkshire'),
			('ML','ML6','AIRDRIE','Lanarkshire'),
			('ML','ML07','SHOTTS','Lanarkshire'),
			('ML','ML7','SHOTTS','Lanarkshire'),
			('ML','ML08','CARLUKE','Lanarkshire'),
			('ML','ML8','CARLUKE','Lanarkshire'),
			('ML','ML09','LARKHALL','Lanarkshire'),
			('ML','ML9','LARKHALL','Lanarkshire'),
			('ML','ML10','STRATHAVEN','Lanarkshire'),
			('ML','ML11','LANARK','(Lanarkshire)'),
			('ML','ML12','BIGGAR','Lanarkshire'),
			('N','N001','LONDON','(London)'),
			('N','N1','LONDON','(London)'),
			('N','N1C','LONDON','(London)'),
			('N','N1P','LONDON','(London)'),
			('N','N2','LONDON','(London)'),
			('N','N3','LONDON','(London)'),
			('N','N4','LONDON','(London)'),
			('N','N5','LONDON','(London)'),
			('N','N6','LONDON','(London)'),
			('N','N7','LONDON','(London)'),
			('N','N8','LONDON','(London)'),
			('N','N9','LONDON','(London)'),
			('N','N10','LONDON','(London)'),
			('N','N11','LONDON','(London)'),
			('N','N12','LONDON','(London)'),
			('N','N13','LONDON','(London)'),
			('N','N14','LONDON','(London)'),
			('N','N15','LONDON','(London)'),
			('N','N16','LONDON','(London)'),
			('N','N17','LONDON','(London)'),
			('N','N18','LONDON','(London)'),
			('N','N19','LONDON','(London)'),
			('N','N20','LONDON','(London)'),
			('N','N21','LONDON','(London)'),
			('N','N22','LONDON','(London)'),
			('N','N81','LONDON','(London)'),
			('NE','NE01','NEWCASTLE UPON TYNE','(Tyne and Wear)'),
			('NE','NE1','NEWCASTLE UPON TYNE','(Tyne and Wear)'),
			('NE','NE2','NEWCASTLE UPON TYNE','(Tyne and Wear)'),
			('NE','NE3','NEWCASTLE UPON TYNE','(Tyne and Wear)'),
			('NE','NE4','NEWCASTLE UPON TYNE','(Tyne and Wear)'),
			('NE','NE5','NEWCASTLE UPON TYNE','(Tyne and Wear)'),
			('NE','NE6','NEWCASTLE UPON TYNE','(Tyne and Wear)'),
			('NE','NE7','NEWCASTLE UPON TYNE','(Tyne and Wear)'),
			('NE','NE12','NEWCASTLE UPON TYNE','(Tyne and Wear)'),
			('NE','NE13','NEWCASTLE UPON TYNE','(Tyne and Wear)'),
			('NE','NE15','NEWCASTLE UPON TYNE','(Tyne and Wear)'),
			('NE','NE16','NEWCASTLE UPON TYNE','(Tyne and Wear)'),
			('NE','NE17','NEWCASTLE UPON TYNE','(Tyne and Wear)'),
			('NE','NE18','NEWCASTLE UPON TYNE','(Tyne and Wear)'),
			('NE','NE19','NEWCASTLE UPON TYNE','(Tyne and Wear)'),
			('NE','NE20','NEWCASTLE UPON TYNE','(Tyne and Wear)'),
			('NE','NE27','NEWCASTLE UPON TYNE','(Tyne and Wear)'),
			('NE','NE82','NEWCASTLE UPON TYNE','(Tyne and Wear)'),
			('NE','NE83','NEWCASTLE UPON TYNE','(Tyne and Wear)'),
			('NE','NE85','NEWCASTLE UPON TYNE','(Tyne and Wear)'),
			('NE','NE88','NEWCASTLE UPON TYNE','(Tyne and Wear)'),
			('NE','NE98','NEWCASTLE UPON TYNE','(Tyne and Wear)'),
			('NE','NE99','NEWCASTLE UPON TYNE','(Tyne and Wear)'),
			('NE','NE08','GATESHEAD','Tyne and Wear'),
			('NE','NE8','GATESHEAD','Tyne and Wear'),
			('NE','NE9','GATESHEAD','Tyne and Wear'),
			('NE','NE10','GATESHEAD','Tyne and Wear'),
			('NE','NE11','GATESHEAD','Tyne and Wear'),
			('NE','NE92','GATESHEAD','Tyne and Wear'),
			('NE','NE21','BLAYDON-ON-TYNE','Tyne and Wear'),
			('NE','NE22','BEDLINGTON','Northumberland'),
			('NE','NE23','CRAMLINGTON','Northumberland'),
			('NE','NE24','BLYTH','Northumberland'),
			('NE','NE25','WHITLEY BAY','Tyne and Wear'),
			('NE','NE26','WHITLEY BAY','Tyne and Wear'),
			('NE','NE28','WALLSEND','Tyne and Wear'),
			('NE','NE29','NORTH SHIELDS','Tyne and Wear'),
			('NE','NE30','NORTH SHIELDS','Tyne and Wear'),
			('NE','NE31','HEBBURN','Tyne and Wear'),
			('NE','NE32','JARROW','Tyne and Wear'),
			('NE','NE33','SOUTH SHIELDS','Tyne and Wear'),
			('NE','NE34','SOUTH SHIELDS','Tyne and Wear'),
			('NE','NE35','BOLDON COLLIERY','Tyne and Wear'),
			('NE','NE36','EAST BOLDON','Tyne and Wear'),
			('NE','NE37','WASHINGTON','Tyne and Wear'),
			('NE','NE38','WASHINGTON','Tyne and Wear'),
			('NE','NE39','ROWLANDS GILL','Tyne and Wear'),
			('NE','NE40','RYTON','Tyne and Wear'),
			('NE','NE41','WYLAM','Northumberland'),
			('NE','NE42','PRUDHOE','Northumberland'),
			('NE','NE43','STOCKSFIELD','Northumberland'),
			('NE','NE44','RIDING MILL','Northumberland'),
			('NE','NE45','CORBRIDGE','Northumberland'),
			('NE','NE46','HEXHAM','Northumberland'),
			('NE','NE47','HEXHAM','Northumberland'),
			('NE','NE48','HEXHAM','Northumberland'),
			('NE','NE49','HALTWHISTLE','Northumberland'),
			('NE','NE61','MORPETH','Northumberland'),
			('NE','NE65','MORPETH','Northumberland'),
			('NE','NE62','CHOPPINGTON','Northumberland'),
			('NE','NE63','ASHINGTON','Northumberland'),
			('NE','NE64','NEWBIGGIN-BY-THE-SEA','Northumberland'),
			('NE','NE66','ALNWICK','Northumberland'),
			('NE','NE66','BAMBURGH','Northumberland'),
			('NE','NE69','BAMBURGH','Northumberland'),
			('NE','NE67','CHATHILL','Northumberland'),
			('NE','NE68','SEAHOUSES','Northumberland'),
			('NE','NE70','BELFORD','Northumberland'),
			('NE','NE71','WOOLER','Northumberland'),
			('NG','NG01','NOTTINGHAM','(Nottinghamshire)'),
			('NG','NG1','NOTTINGHAM','(Nottinghamshire)'),
			('NG','NG2','NOTTINGHAM','(Nottinghamshire)'),
			('NG','NG3','NOTTINGHAM','(Nottinghamshire)'),
			('NG','NG4','NOTTINGHAM','(Nottinghamshire)'),
			('NG','NG5','NOTTINGHAM','(Nottinghamshire)'),
			('NG','NG6','NOTTINGHAM','(Nottinghamshire)'),
			('NG','NG7','NOTTINGHAM','(Nottinghamshire)'),
			('NG','NG8','NOTTINGHAM','(Nottinghamshire)'),
			('NG','NG9','NOTTINGHAM','(Nottinghamshire)'),
			('NG','NG10','NOTTINGHAM','(Nottinghamshire)'),
			('NG','NG11','NOTTINGHAM','(Nottinghamshire)'),
			('NG','NG12','NOTTINGHAM','(Nottinghamshire)'),
			('NG','NG13','NOTTINGHAM','(Nottinghamshire)'),
			('NG','NG14','NOTTINGHAM','(Nottinghamshire)'),
			('NG','NG15','NOTTINGHAM','(Nottinghamshire)'),
			('NG','NG16','NOTTINGHAM','(Nottinghamshire)'),
			('NG','NG17','NOTTINGHAM','(Nottinghamshire)'),
			('NG','NG80','NOTTINGHAM','(Nottinghamshire)'),
			('NG','NG90','NOTTINGHAM','(Nottinghamshire)'),
			('NG','NG17','SUTTON-IN-ASHFIELD','Nottinghamshire'),
			('NG','NG18','MANSFIELD','Nottinghamshire'),
			('NG','NG19','MANSFIELD','Nottinghamshire'),
			('NG','NG20','MANSFIELD','Nottinghamshire'),
			('NG','NG21','MANSFIELD','Nottinghamshire'),
			('NG','NG70','MANSFIELD','Nottinghamshire'),
			('NG','NG22','NEWARK','Nottinghamshire'),
			('NG','NG23','NEWARK','Nottinghamshire'),
			('NG','NG24','NEWARK','Nottinghamshire'),
			('NG','NG25','SOUTHWELL','Nottinghamshire'),
			('NG','NG31','GRANTHAM','Lincolnshire'),
			('NG','NG32','GRANTHAM','Lincolnshire'),
			('NG','NG33','GRANTHAM','Lincolnshire'),
			('NG','NG34','SLEAFORD','Lincolnshire'),
			('NN','NN01','NORTHAMPTON','(Northamptonshire)'),
			('NN','NN1','NORTHAMPTON','(Northamptonshire)'),
			('NN','NN2','NORTHAMPTON','(Northamptonshire)'),
			('NN','NN3','NORTHAMPTON','(Northamptonshire)'),
			('NN','NN4','NORTHAMPTON','(Northamptonshire)'),
			('NN','NN5','NORTHAMPTON','(Northamptonshire)'),
			('NN','NN6','NORTHAMPTON','(Northamptonshire)'),
			('NN','NN7','NORTHAMPTON','(Northamptonshire)'),
			('NN','NN08','WELLINGBOROUGH','Northamptonshire'),
			('NN','NN8','WELLINGBOROUGH','Northamptonshire'),
			('NN','NN9','WELLINGBOROUGH','Northamptonshire'),
			('NN','NN29','WELLINGBOROUGH','Northamptonshire'),
			('NN','NN10','RUSHDEN','Northamptonshire'),
			('NN','NN11','DAVENTRY','Northamptonshire'),
			('NN','NN12','TOWCESTER','Northamptonshire'),
			('NN','NN13','BRACKLEY','Northamptonshire'),
			('NN','NN14','KETTERING','Northamptonshire'),
			('NN','NN15','KETTERING','Northamptonshire'),
			('NN','NN16','KETTERING','Northamptonshire'),
			('NN','NN17','CORBY','Northamptonshire'),
			('NN','NN18','CORBY','Northamptonshire'),
			('NP','NP04','PONTYPOOL','Gwent'),
			('NP','NP4','PONTYPOOL','Gwent'),
			('NP','NP07','ABERGAVENNY','Gwent'),
			('NP','NP7','ABERGAVENNY','Gwent'),
			('NP','NP07','CRICKHOWELL','Powys'),
			('NP','NP7','CRICKHOWELL','Powys'),
			('NP','NP8','CRICKHOWELL','Powys'),
			('NP','NP10','NEWPORT','Gwent'),
			('NP','NP11','NEWPORT','Gwent'),
			('NP','NP18','NEWPORT','Gwent'),
			('NP','NP19','NEWPORT','Gwent'),
			('NP','NP20','NEWPORT','Gwent'),
			('NP','NP12','BLACKWOOD','Gwent'),
			('NP','NP13','ABERTILLERY','Gwent'),
			('NP','NP15','USK','Gwent'),
			('NP','NP16','CHEPSTOW','Gwent'),
			('NP','NP22','TREDEGAR','Gwent'),
			('NP','NP23','EBBW VALE','Gwent'),
			('NP','NP24','NEW TREDEGAR','Gwent'),
			('NP','NP25','MONMOUTH','Gwent'),
			('NP','NP26','CALDICOT','Gwent'),
			('NP','NP44','CWMBRAN','Gwent'),
			('NR','NR01','NORWICH','(Norfolk)'),
			('NR','NR1','NORWICH','(Norfolk)'),
			('NR','NR2','NORWICH','(Norfolk)'),
			('NR','NR3','NORWICH','(Norfolk)'),
			('NR','NR4','NORWICH','(Norfolk)'),
			('NR','NR5','NORWICH','(Norfolk)'),
			('NR','NR6','NORWICH','(Norfolk)'),
			('NR','NR7','NORWICH','(Norfolk)'),
			('NR','NR8','NORWICH','(Norfolk)'),
			('NR','NR9','NORWICH','(Norfolk)'),
			('NR','NR10','NORWICH','(Norfolk)'),
			('NR','NR11','NORWICH','(Norfolk)'),
			('NR','NR12','NORWICH','(Norfolk)'),
			('NR','NR13','NORWICH','(Norfolk)'),
			('NR','NR14','NORWICH','(Norfolk)'),
			('NR','NR15','NORWICH','(Norfolk)'),
			('NR','NR16','NORWICH','(Norfolk)'),
			('NR','NR18','NORWICH','(Norfolk)'),
			('NR','NR19','NORWICH','(Norfolk)'),
			('NR','NR26','NORWICH','(Norfolk)'),
			('NR','NR28','NORWICH','(Norfolk)'),
			('NR','NR99','NORWICH','(Norfolk)'),
			('NR','NR17','ATTLEBOROUGH','Norfolk'),
			('NR','NR18','WYMONDHAM','Norfolk'),
			('NR','NR19','DEREHAM','Norfolk'),
			('NR','NR20','DEREHAM','Norfolk'),
			('NR','NR21','FAKENHAM','Norfolk'),
			('NR','NR22','WALSINGHAM','Norfolk'),
			('NR','NR23','WELLS-NEXT-THE-SEA','Norfolk'),
			('NR','NR24','MELTON CONSTABLE','Norfolk'),
			('NR','NR25','HOLT','Norfolk'),
			('NR','NR26','SHERINGHAM','Norfolk'),
			('NR','NR27','CROMER','Norfolk'),
			('NR','NR28','NORTH WALSHAM','Norfolk'),
			('NR','NR29','GREAT YARMOUTH','Norfolk'),
			('NR','NR30','GREAT YARMOUTH','Norfolk'),
			('NR','NR31','GREAT YARMOUTH','Norfolk'),
			('NR','NR32','LOWESTOFT','Suffolk'),
			('NR','NR33','LOWESTOFT','Suffolk'),
			('NR','NR34','BECCLES','Suffolk'),
			('NR','NR35','BUNGAY','Suffolk'),
			('NW','NW01','LONDON','(London)'),
			('NW','NW1','LONDON','(London)'),
			('NW','NW1W','LONDON','(London)'),
			('NW','NW2','LONDON','(London)'),
			('NW','NW3','LONDON','(London)'),
			('NW','NW4','LONDON','(London)'),
			('NW','NW5','LONDON','(London)'),
			('NW','NW6','LONDON','(London)'),
			('NW','NW7','LONDON','(London)'),
			('NW','NW8','LONDON','(London)'),
			('NW','NW9','LONDON','(London)'),
			('NW','NW10','LONDON','(London)'),
			('NW','NW11','LONDON','(London)'),
			('NW','NW26','LONDON','(London)'),
			('OL','OL01','OLDHAM','(Lancashire)'),
			('OL','OL1','OLDHAM','(Lancashire)'),
			('OL','OL2','OLDHAM','(Lancashire)'),
			('OL','OL3','OLDHAM','(Lancashire)'),
			('OL','OL4','OLDHAM','(Lancashire)'),
			('OL','OL8','OLDHAM','(Lancashire)'),
			('OL','OL9','OLDHAM','(Lancashire)'),
			('OL','OL95','OLDHAM','(Lancashire)'),
			('OL','OL05','ASHTON-UNDER-LYNE','Lancashire'),
			('OL','OL5','ASHTON-UNDER-LYNE','Lancashire'),
			('OL','OL6','ASHTON-UNDER-LYNE','Lancashire'),
			('OL','OL7','ASHTON-UNDER-LYNE','Lancashire'),
			('OL','OL10','HEYWOOD','Lancashire'),
			('OL','OL11','ROCHDALE','Lancashire'),
			('OL','OL12','ROCHDALE','Lancashire'),
			('OL','OL16','ROCHDALE','Lancashire'),
			('OL','OL13','BACUP','Lancashire'),
			('OL','OL14','TODMORDEN','Lancashire'),
			('OL','OL15','LITTLEBOROUGH','Lancashire'),
			('OL','OL16','LITTLEBOROUGH','Lancashire'),
			('OX','OX01','OXFORD','(Oxfordshire)'),
			('OX','OX1','OXFORD','(Oxfordshire)'),
			('OX','OX2','OXFORD','(Oxfordshire)'),
			('OX','OX3','OXFORD','(Oxfordshire)'),
			('OX','OX4','OXFORD','(Oxfordshire)'),
			('OX','OX33','OXFORD','(Oxfordshire)'),
			('OX','OX44','OXFORD','(Oxfordshire)'),
			('OX','OX05','KIDLINGTON','Oxfordshire'),
			('OX','OX5','KIDLINGTON','Oxfordshire'),
			('OX','OX07','CHIPPING NORTON','Oxfordshire'),
			('OX','OX7','CHIPPING NORTON','Oxfordshire'),
			('OX','OX09','THAME','Oxfordshire'),
			('OX','OX9','THAME','Oxfordshire'),
			('OX','OX10','WALLINGFORD','Oxfordshire'),
			('OX','OX11','DIDCOT','Oxfordshire'),
			('OX','OX12','WANTAGE','Oxfordshire'),
			('OX','OX13','ABINGDON','Oxfordshire'),
			('OX','OX14','ABINGDON','Oxfordshire'),
			('OX','OX15','BANBURY','Oxfordshire'),
			('OX','OX16','BANBURY','Oxfordshire'),
			('OX','OX17','BANBURY','Oxfordshire'),
			('OX','OX18','BAMPTON','Oxfordshire'),
			('OX','OX18','BURFORD','Oxfordshire'),
			('OX','OX18','CARTERTON','Oxfordshire'),
			('OX','OX20','WOODSTOCK','Oxfordshire'),
			('OX','OX25','BICESTER','Oxfordshire'),
			('OX','OX26','BICESTER','Oxfordshire'),
			('OX','OX27','BICESTER','Oxfordshire'),
			('OX','OX28','WITNEY','Oxfordshire'),
			('OX','OX29','WITNEY','Oxfordshire'),
			('OX','OX39','CHINNOR','Oxfordshire'),
			('OX','OX49','WATLINGTON','Oxfordshire'),
			('PA','PA01','PAISLEY','Renfrewshire'),
			('PA','PA1','PAISLEY','Renfrewshire'),
			('PA','PA2','PAISLEY','Renfrewshire'),
			('PA','PA3','PAISLEY','Renfrewshire'),
			('PA','PA04','RENFREW','(Renfrewshire)'),
			('PA','PA4','RENFREW','(Renfrewshire)'),
			('PA','PA05','JOHNSTONE','Renfrewshire'),
			('PA','PA5','JOHNSTONE','Renfrewshire'),
			('PA','PA6','JOHNSTONE','Renfrewshire'),
			('PA','PA9','JOHNSTONE','Renfrewshire'),
			('PA','PA10','JOHNSTONE','Renfrewshire'),
			('PA','PA07','BISHOPTON','Renfrewshire'),
			('PA','PA7','BISHOPTON','Renfrewshire'),
			('PA','PA08','ERSKINE','Renfrewshire'),
			('PA','PA8','ERSKINE','Renfrewshire'),
			('PA','PA11','BRIDGE OF WEIR','Renfrewshire'),
			('PA','PA12','LOCHWINNOCH','Renfrewshire'),
			('PA','PA13','KILMACOLM','Renfrewshire'),
			('PA','PA14','PORT GLASGOW','Renfrewshire'),
			('PA','PA15','GREENOCK','Renfrewshire'),
			('PA','PA16','GREENOCK','Renfrewshire'),
			('PA','PA17','SKELMORLIE','Ayrshire'),
			('PA','PA18','WEMYSS BAY','Renfrewshire'),
			('PA','PA19','GOUROCK','Renfrewshire'),
			('PA','PA20','ISLE OF BUTE','Isle of Bute'),
			('PA','PA21','TIGHNABRUAICH','Argyll'),
			('PA','PA22','COLINTRAIVE','Argyll'),
			('PA','PA23','DUNOON','Argyll'),
			('PA','PA24','CAIRNDOW','Argyll'),
			('PA','PA25','CAIRNDOW','Argyll'),
			('PA','PA26','CAIRNDOW','Argyll'),
			('PA','PA27','CAIRNDOW','Argyll'),
			('PA','PA28','CAMPBELTOWN','Argyll'),
			('PA','PA29','TARBERT','Argyll'),
			('PA','PA30','LOCHGILPHEAD','Argyll'),
			('PA','PA31','LOCHGILPHEAD','Argyll'),
			('PA','PA32','INVERARAY','Argyll'),
			('PA','PA33','DALMALLY','Argyll'),
			('PA','PA34','OBAN','Argyll'),
			('PA','PA37','OBAN','Argyll'),
			('PA','PA80','OBAN','Argyll'),
			('PA','PA35','TAYNUILT','Argyll'),
			('PA','PA36','BRIDGE OF ORCHY','Argyll'),
			('PA','PA38','APPIN','Argyll'),
			('PA','PA41','ISLE OF GIGHA','Isle of Gigha'),
			('PA','PA42','ISLE OF ISLAY','Isle of Islay'),
			('PA','PA43','ISLE OF ISLAY','Isle of Islay'),
			('PA','PA44','ISLE OF ISLAY','Isle of Islay'),
			('PA','PA45','ISLE OF ISLAY','Isle of Islay'),
			('PA','PA46','ISLE OF ISLAY','Isle of Islay'),
			('PA','PA47','ISLE OF ISLAY','Isle of Islay'),
			('PA','PA48','ISLE OF ISLAY','Isle of Islay'),
			('PA','PA49','ISLE OF ISLAY','Isle of Islay'),
			('PA','PA60','ISLE OF JURA','Isle of Jura'),
			('PA','PA61','ISLE OF COLONSAY','Isle of Colonsay'),
			('PA','PA62','ISLE OF MULL','Isle of Mull'),
			('PA','PA63','ISLE OF MULL','Isle of Mull'),
			('PA','PA64','ISLE OF MULL','Isle of Mull'),
			('PA','PA65','ISLE OF MULL','Isle of Mull'),
			('PA','PA66','ISLE OF MULL','Isle of Mull'),
			('PA','PA67','ISLE OF MULL','Isle of Mull'),
			('PA','PA68','ISLE OF MULL','Isle of Mull'),
			('PA','PA69','ISLE OF MULL','Isle of Mull'),
			('PA','PA70','ISLE OF MULL','Isle of Mull'),
			('PA','PA71','ISLE OF MULL','Isle of Mull'),
			('PA','PA72','ISLE OF MULL','Isle of Mull'),
			('PA','PA73','ISLE OF MULL','Isle of Mull'),
			('PA','PA74','ISLE OF MULL','Isle of Mull'),
			('PA','PA75','ISLE OF MULL','Isle of Mull'),
			('PA','PA76','ISLE OF IONA','Isle of Iona'),
			('PA','PA77','ISLE OF TIREE','Isle of Tiree'),
			('PA','PA78','ISLE OF COLL','Isle of Coll'),
			('PE','PE01','PETERBOROUGH','(Cambridgeshire)'),
			('PE','PE1','PETERBOROUGH','(Cambridgeshire)'),
			('PE','PE2','PETERBOROUGH','(Cambridgeshire)'),
			('PE','PE3','PETERBOROUGH','(Cambridgeshire)'),
			('PE','PE4','PETERBOROUGH','(Cambridgeshire)'),
			('PE','PE5','PETERBOROUGH','(Cambridgeshire)'),
			('PE','PE6','PETERBOROUGH','(Cambridgeshire)'),
			('PE','PE7','PETERBOROUGH','(Cambridgeshire)'),
			('PE','PE8','PETERBOROUGH','(Cambridgeshire)'),
			('PE','PE99','PETERBOROUGH','(Cambridgeshire)'),
			('PE','PE09','STAMFORD','Lincolnshire'),
			('PE','PE9','STAMFORD','Lincolnshire'),
			('PE','PE10','BOURNE','Lincolnshire'),
			('PE','PE11','SPALDING','Lincolnshire'),
			('PE','PE12','SPALDING','Lincolnshire'),
			('PE','PE13','WISBECH','Cambridgeshire'),
			('PE','PE14','WISBECH','Cambridgeshire'),
			('PE','PE15','MARCH','Cambridgeshire'),
			('PE','PE16','CHATTERIS','Cambridgeshire'),
			('PE','PE19','ST. NEOTS','Cambridgeshire'),
			('PE','PE20','BOSTON','Lincolnshire'),
			('PE','PE21','BOSTON','Lincolnshire'),
			('PE','PE22','BOSTON','Lincolnshire'),
			('PE','PE23','SPILSBY','Lincolnshire'),
			('PE','PE24','SKEGNESS','Lincolnshire'),
			('PE','PE25','SKEGNESS','Lincolnshire'),
			('PE','PE26','HUNTINGDON','Cambridgeshire'),
			('PE','PE28','HUNTINGDON','Cambridgeshire'),
			('PE','PE29','HUNTINGDON','Cambridgeshire'),
			('PE','PE27','ST. IVES','Cambridgeshire'),
			('PE','PE30','KINGS LYNN','Norfolk'),
			('PE','PE31','KINGS LYNN','Norfolk'),
			('PE','PE32','KINGS LYNN','Norfolk'),
			('PE','PE33','KINGS LYNN','Norfolk'),
			('PE','PE34','KINGS LYNN','Norfolk'),
			('PE','PE35','SANDRINGHAM','Norfolk'),
			('PE','PE36','HUNSTANTON','Norfolk'),
			('PE','PE37','SWAFFHAM','Norfolk'),
			('PE','PE38','DOWNHAM MARKET','Norfolk'),
			('PH','PH01','PERTH','(Perthshire)'),
			('PH','PH1','PERTH','(Perthshire)'),
			('PH','PH2','PERTH','(Perthshire)'),
			('PH','PH14','PERTH','(Perthshire)'),
			('PH','PH03','AUCHTERARDER','Perthshire'),
			('PH','PH3','AUCHTERARDER','Perthshire'),
			('PH','PH4','AUCHTERARDER','Perthshire'),
			('PH','PH05','CRIEFF','Perthshire'),
			('PH','PH5','CRIEFF','Perthshire'),
			('PH','PH6','CRIEFF','Perthshire'),
			('PH','PH7','CRIEFF','Perthshire'),
			('PH','PH08','DUNKELD','Perthshire'),
			('PH','PH8','DUNKELD','Perthshire'),
			('PH','PH09','PITLOCHRY','Perthshire'),
			('PH','PH9','PITLOCHRY','Perthshire'),
			('PH','PH16','PITLOCHRY','Perthshire'),
			('PH','PH17','PITLOCHRY','Perthshire'),
			('PH','PH18','PITLOCHRY','Perthshire'),
			('PH','PH10','BLAIRGOWRIE','Perthshire'),
			('PH','PH11','BLAIRGOWRIE','Perthshire'),
			('PH','PH12','BLAIRGOWRIE','Perthshire'),
			('PH','PH13','BLAIRGOWRIE','Perthshire'),
			('PH','PH15','ABERFELDY','Perthshire'),
			('PH','PH19','DALWHINNIE','Inverness-shire'),
			('PH','PH20','NEWTONMORE','Inverness-shire'),
			('PH','PH21','KINGUSSIE','Inverness-shire'),
			('PH','PH22','AVIEMORE','Inverness-shire'),
			('PH','PH23','CARRBRIDGE','Inverness-shire'),
			('PH','PH24','BOAT OF GARTEN','Inverness-shire'),
			('PH','PH25','NETHY BRIDGE','Inverness-shire'),
			('PH','PH26','GRANTOWN-ON-SPEY','Morayshire'),
			('PH','PH30','CORROUR','Inverness-shire'),
			('PH','PH31','ROY BRIDGE','Inverness-shire'),
			('PH','PH32','FORT AUGUSTUS','Inverness-shire'),
			('PH','PH33','FORT WILLIAM','Inverness-shire'),
			('PH','PH34','SPEAN BRIDGE','Inverness-shire'),
			('PH','PH35','INVERGARRY','Inverness-shire'),
			('PH','PH36','ACHARACLE','Argyll'),
			('PH','PH37','GLENFINNAN','Inverness-shire'),
			('PH','PH38','LOCHAILORT','Inverness-shire'),
			('PH','PH39','ARISAIG','Inverness-shire'),
			('PH','PH40','MALLAIG','Inverness-shire'),
			('PH','PH41','MALLAIG','Inverness-shire'),
			('PH','PH42','ISLE OF EIGG','Isle of Eigg'),
			('PH','PH43','ISLE OF RUM','Isle of Rum'),
			('PH','PH44','ISLE OF CANNA','Isle of Canna'),
			('PH','PH49','BALLACHULISH','Argyll'),
			('PH','PH50','KINLOCHLEVEN','Argyll'),
			('PL','PL01','PLYMOUTH','(Devon)'),
			('PL','PL1','PLYMOUTH','(Devon)'),
			('PL','PL2','PLYMOUTH','(Devon)'),
			('PL','PL3','PLYMOUTH','(Devon)'),
			('PL','PL4','PLYMOUTH','(Devon)'),
			('PL','PL5','PLYMOUTH','(Devon)'),
			('PL','PL6','PLYMOUTH','(Devon)'),
			('PL','PL7','PLYMOUTH','(Devon)'),
			('PL','PL8','PLYMOUTH','(Devon)'),
			('PL','PL9','PLYMOUTH','(Devon)'),
			('PL','PL95','PLYMOUTH','(Devon)'),
			('PL','PL10','TORPOINT','Cornwall'),
			('PL','PL11','TORPOINT','Cornwall'),
			('PL','PL12','SALTASH','Cornwall'),
			('PL','PL13','LOOE','Cornwall'),
			('PL','PL14','LISKEARD','Cornwall'),
			('PL','PL15','LAUNCESTON','Cornwall'),
			('PL','PL16','LIFTON','Devon'),
			('PL','PL17','CALLINGTON','Cornwall'),
			('PL','PL18','CALSTOCK','Cornwall'),
			('PL','PL18','GUNNISLAKE','Cornwall'),
			('PL','PL19','TAVISTOCK','Devon'),
			('PL','PL20','YELVERTON','Devon'),
			('PL','PL21','IVYBRIDGE','Devon'),
			('PL','PL22','LOSTWITHIEL','Cornwall'),
			('PL','PL23','FOWEY','Cornwall'),
			('PL','PL24','PAR','Cornwall'),
			('PL','PL25','ST. AUSTELL','Cornwall'),
			('PL','PL26','ST. AUSTELL','Cornwall'),
			('PL','PL27','WADEBRIDGE','Cornwall'),
			('PL','PL28','PADSTOW','Cornwall'),
			('PL','PL29','PORT ISAAC','Cornwall'),
			('PL','PL30','BODMIN','Cornwall'),
			('PL','PL31','BODMIN','Cornwall'),
			('PL','PL32','CAMELFORD','Cornwall'),
			('PL','PL33','DELABOLE','Cornwall'),
			('PL','PL34','TINTAGEL','Cornwall'),
			('PL','PL35','BOSCASTLE','Cornwall'),
			('PO','PO01','PORTSMOUTH','(Hampshire)'),
			('PO','PO1','PORTSMOUTH','(Hampshire)'),
			('PO','PO2','PORTSMOUTH','(Hampshire)'),
			('PO','PO3','PORTSMOUTH','(Hampshire)'),
			('PO','PO6','PORTSMOUTH','(Hampshire)'),
			('PO','PO04','SOUTHSEA','Hampshire'),
			('PO','PO4','SOUTHSEA','Hampshire'),
			('PO','PO5','SOUTHSEA','Hampshire'),
			('PO','PO07','WATERLOOVILLE','Hampshire'),
			('PO','PO7','WATERLOOVILLE','Hampshire'),
			('PO','PO8','WATERLOOVILLE','Hampshire'),
			('PO','PO09','HAVANT','Hampshire'),
			('PO','PO9','HAVANT','Hampshire'),
			('PO','PO09','ROWLANDS CASTLE','Hampshire'),
			('PO','PO9','ROWLANDS CASTLE','Hampshire'),
			('PO','PO10','EMSWORTH','Hampshire'),
			('PO','PO11','HAYLING ISLAND','Hampshire'),
			('PO','PO12','GOSPORT','Hampshire'),
			('PO','PO13','GOSPORT','Hampshire'),
			('PO','PO12','LEE-ON-THE-SOLENT','Hampshire'),
			('PO','PO13','LEE-ON-THE-SOLENT','Hampshire'),
			('PO','PO14','FAREHAM','Hampshire'),
			('PO','PO15','FAREHAM','Hampshire'),
			('PO','PO16','FAREHAM','Hampshire'),
			('PO','PO17','FAREHAM','Hampshire'),
			('PO','PO18','CHICHESTER','West Sussex'),
			('PO','PO19','CHICHESTER','West Sussex'),
			('PO','PO20','CHICHESTER','West Sussex'),
			('PO','PO21','BOGNOR REGIS','West Sussex'),
			('PO','PO22','BOGNOR REGIS','West Sussex'),
			('PO','PO30','NEWPORT','Isle of Wight'),
			('PO','PO30','YARMOUTH','Isle of Wight'),
			('PO','PO41','YARMOUTH','Isle of Wight'),
			('PO','PO31','COWES','Isle of Wight'),
			('PO','PO32','EAST COWES','Isle of Wight'),
			('PO','PO33','RYDE','Isle of Wight'),
			('PO','PO34','SEAVIEW','Isle of Wight'),
			('PO','PO35','BEMBRIDGE','Isle of Wight'),
			('PO','PO36','SANDOWN','Isle of Wight'),
			('PO','PO36','SHANKLIN','Isle of Wight'),
			('PO','PO37','SHANKLIN','Isle of Wight'),
			('PO','PO38','VENTNOR','Isle of Wight'),
			('PO','PO39','TOTLAND BAY','Isle of Wight'),
			('PO','PO40','FRESHWATER','Isle of Wight'),
			('PR','PR00','PRESTON','(Lancashire)'),
			('PR','PR0','PRESTON','(Lancashire)'),
			('PR','PR1','PRESTON','(Lancashire)'),
			('PR','PR2','PRESTON','(Lancashire)'),
			('PR','PR3','PRESTON','(Lancashire)'),
			('PR','PR4','PRESTON','(Lancashire)'),
			('PR','PR5','PRESTON','(Lancashire)'),
			('PR','PR11','PRESTON','(Lancashire)'),
			('PR','PR06','CHORLEY','Lancashire'),
			('PR','PR6','CHORLEY','Lancashire'),
			('PR','PR7','CHORLEY','Lancashire'),
			('PR','PR08','SOUTHPORT','Merseyside'),
			('PR','PR8','SOUTHPORT','Merseyside'),
			('PR','PR9','SOUTHPORT','Merseyside'),
			('PR','PR25','LEYLAND','Lancashire'),
			('PR','PR26','LEYLAND','Lancashire'),
			('RG','RG01','READING','(Berkshire)'),
			('RG','RG1','READING','(Berkshire)'),
			('RG','RG2','READING','(Berkshire)'),
			('RG','RG4','READING','(Berkshire)'),
			('RG','RG5','READING','(Berkshire)'),
			('RG','RG6','READING','(Berkshire)'),
			('RG','RG7','READING','(Berkshire)'),
			('RG','RG8','READING','(Berkshire)'),
			('RG','RG10','READING','(Berkshire)'),
			('RG','RG19','READING','(Berkshire)'),
			('RG','RG30','READING','(Berkshire)'),
			('RG','RG31','READING','(Berkshire)'),
			('RG','RG09','HENLEY-ON-THAMES','Oxfordshire'),
			('RG','RG9','HENLEY-ON-THAMES','Oxfordshire'),
			('RG','RG12','BRACKNELL','Berkshire'),
			('RG','RG42','BRACKNELL','Berkshire'),
			('RG','RG14','NEWBURY','Berkshire'),
			('RG','RG20','NEWBURY','Berkshire'),
			('RG','RG17','HUNGERFORD','Berkshire'),
			('RG','RG18','THATCHAM','Berkshire'),
			('RG','RG19','THATCHAM','Berkshire'),
			('RG','RG21','BASINGSTOKE','Hampshire'),
			('RG','RG22','BASINGSTOKE','Hampshire'),
			('RG','RG23','BASINGSTOKE','Hampshire'),
			('RG','RG24','BASINGSTOKE','Hampshire'),
			('RG','RG25','BASINGSTOKE','Hampshire'),
			('RG','RG28','BASINGSTOKE','Hampshire'),
			('RG','RG26','TADLEY','Hampshire'),
			('RG','RG27','HOOK','Hampshire'),
			('RG','RG29','HOOK','Hampshire'),
			('RG','RG28','WHITCHURCH','Hampshire'),
			('RG','RG40','WOKINGHAM','Berkshire'),
			('RG','RG41','WOKINGHAM','Berkshire'),
			('RG','RG45','CROWTHORNE','Berkshire'),
			('RH','RH01','REDHILL','(Surrey)'),
			('RH','RH1','REDHILL','(Surrey)'),
			('RH','RH02','REIGATE','Surrey'),
			('RH','RH2','REIGATE','Surrey'),
			('RH','RH03','BETCHWORTH','Surrey'),
			('RH','RH3','BETCHWORTH','Surrey'),
			('RH','RH4','BETCHWORTH','Surrey'),
			('RH','RH04','DORKING','Surrey'),
			('RH','RH4','DORKING','Surrey'),
			('RH','RH5','DORKING','Surrey'),
			('RH','RH06','GATWICK','West Sussex'),
			('RH','RH6','GATWICK','West Sussex'),
			('RH','RH06','HORLEY','Surrey'),
			('RH','RH6','HORLEY','Surrey'),
			('RH','RH07','LINGFIELD','Surrey'),
			('RH','RH7','LINGFIELD','Surrey'),
			('RH','RH08','OXTED','Surrey'),
			('RH','RH8','OXTED','Surrey'),
			('RH','RH09','GODSTONE','Surrey');
		END

		BEGIN
			INSERT INTO dbo.PostalDistrict (PostcodeArea, PostcodeDistrict, PostTown, FormerPostalCounty)
			VALUES
			('RH','RH9','GODSTONE','Surrey'),
			('RH','RH10','CRAWLEY','West Sussex'),
			('RH','RH11','CRAWLEY','West Sussex'),
			('RH','RH77','CRAWLEY','West Sussex'),
			('RH','RH12','HORSHAM','West Sussex'),
			('RH','RH13','HORSHAM','West Sussex'),
			('RH','RH14','BILLINGSHURST','West Sussex'),
			('RH','RH15','BURGESS HILL','West Sussex'),
			('RH','RH16','HAYWARDS HEATH','West Sussex'),
			('RH','RH17','HAYWARDS HEATH','West Sussex'),
			('RH','RH18','FOREST ROW','East Sussex'),
			('RH','RH19','EAST GRINSTEAD','West Sussex'),
			('RH','RH20','PULBOROUGH','West Sussex'),
			('RM','RM01','ROMFORD','(Essex)'),
			('RM','RM1','ROMFORD','(Essex)'),
			('RM','RM2','ROMFORD','(Essex)'),
			('RM','RM3','ROMFORD','(Essex)'),
			('RM','RM4','ROMFORD','(Essex)'),
			('RM','RM5','ROMFORD','(Essex)'),
			('RM','RM6','ROMFORD','(Essex)'),
			('RM','RM7','ROMFORD','(Essex)'),
			('RM','RM08','DAGENHAM','Essex'),
			('RM','RM8','DAGENHAM','Essex'),
			('RM','RM9','DAGENHAM','Essex'),
			('RM','RM10','DAGENHAM','Essex'),
			('RM','RM11','HORNCHURCH','Essex'),
			('RM','RM12','HORNCHURCH','Essex'),
			('RM','RM13','RAINHAM','Essex'),
			('RM','RM14','UPMINSTER','Essex'),
			('RM','RM15','SOUTH OCKENDON','Essex'),
			('RM','RM16','GRAYS','Essex'),
			('RM','RM17','GRAYS','Essex'),
			('RM','RM20','GRAYS','Essex'),
			('RM','RM18','TILBURY','Essex'),
			('RM','RM19','PURFLEET','Essex'),
			('S','S001','SHEFFIELD','(South Yorkshire)'),
			('S','S1','SHEFFIELD','(South Yorkshire)'),
			('S','S2','SHEFFIELD','(South Yorkshire)'),
			('S','S3','SHEFFIELD','(South Yorkshire)'),
			('S','S4','SHEFFIELD','(South Yorkshire)'),
			('S','S5','SHEFFIELD','(South Yorkshire)'),
			('S','S6','SHEFFIELD','(South Yorkshire)'),
			('S','S7','SHEFFIELD','(South Yorkshire)'),
			('S','S8','SHEFFIELD','(South Yorkshire)'),
			('S','S9','SHEFFIELD','(South Yorkshire)'),
			('S','S10','SHEFFIELD','(South Yorkshire)'),
			('S','S11','SHEFFIELD','(South Yorkshire)'),
			('S','S12','SHEFFIELD','(South Yorkshire)'),
			('S','S13','SHEFFIELD','(South Yorkshire)'),
			('S','S14','SHEFFIELD','(South Yorkshire)'),
			('S','S17','SHEFFIELD','(South Yorkshire)'),
			('S','S20','SHEFFIELD','(South Yorkshire)'),
			('S','S21','SHEFFIELD','(South Yorkshire)'),
			('S','S25','SHEFFIELD','(South Yorkshire)'),
			('S','S26','SHEFFIELD','(South Yorkshire)'),
			('S','S35','SHEFFIELD','(South Yorkshire)'),
			('S','S36','SHEFFIELD','(South Yorkshire)'),
			('S','S95','SHEFFIELD','(South Yorkshire)'),
			('S','S96','SHEFFIELD','(South Yorkshire)'),
			('S','S97','SHEFFIELD','(South Yorkshire)'),
			('S','S98','SHEFFIELD','(South Yorkshire)'),
			('S','S99','SHEFFIELD','(South Yorkshire)'),
			('S','S018','DRONFIELD','Derbyshire'),
			('S','S18','DRONFIELD','Derbyshire'),
			('S','S032','HOPE VALLEY','Derbyshire'),
			('S','S32','HOPE VALLEY','Derbyshire'),
			('S','S33','HOPE VALLEY','Derbyshire'),
			('S','S040','CHESTERFIELD','Derbyshire'),
			('S','S40','CHESTERFIELD','Derbyshire'),
			('S','S41','CHESTERFIELD','Derbyshire'),
			('S','S42','CHESTERFIELD','Derbyshire'),
			('S','S43','CHESTERFIELD','Derbyshire'),
			('S','S44','CHESTERFIELD','Derbyshire'),
			('S','S45','CHESTERFIELD','Derbyshire'),
			('S','S49','CHESTERFIELD','Derbyshire'),
			('S','S060','ROTHERHAM','South Yorkshire'),
			('S','S60','ROTHERHAM','South Yorkshire'),
			('S','S61','ROTHERHAM','South Yorkshire'),
			('S','S62','ROTHERHAM','South Yorkshire'),
			('S','S63','ROTHERHAM','South Yorkshire'),
			('S','S65','ROTHERHAM','South Yorkshire'),
			('S','S66','ROTHERHAM','South Yorkshire'),
			('S','S97','ROTHERHAM','South Yorkshire'),
			('S','S064','MEXBOROUGH','South Yorkshire'),
			('S','S64','MEXBOROUGH','South Yorkshire'),
			('S','S070','BARNSLEY','South Yorkshire'),
			('S','S70','BARNSLEY','South Yorkshire'),
			('S','S71','BARNSLEY','South Yorkshire'),
			('S','S72','BARNSLEY','South Yorkshire'),
			('S','S73','BARNSLEY','South Yorkshire'),
			('S','S74','BARNSLEY','South Yorkshire'),
			('S','S75','BARNSLEY','South Yorkshire'),
			('S','S080','WORKSOP','Nottinghamshire'),
			('S','S80','WORKSOP','Nottinghamshire'),
			('S','S81','WORKSOP','Nottinghamshire'),
			('SA','SA01','SWANSEA','(West Glamorgan)'),
			('SA','SA1','SWANSEA','(West Glamorgan)'),
			('SA','SA2','SWANSEA','(West Glamorgan)'),
			('SA','SA3','SWANSEA','(West Glamorgan)'),
			('SA','SA4','SWANSEA','(West Glamorgan)'),
			('SA','SA5','SWANSEA','(West Glamorgan)'),
			('SA','SA6','SWANSEA','(West Glamorgan)'),
			('SA','SA7','SWANSEA','(West Glamorgan)'),
			('SA','SA8','SWANSEA','(West Glamorgan)'),
			('SA','SA9','SWANSEA','(West Glamorgan)'),
			('SA','SA80','SWANSEA','(West Glamorgan)'),
			('SA','SA99','SWANSEA','(West Glamorgan)'),
			('SA','SA10','NEATH','West Glamorgan'),
			('SA','SA11','NEATH','West Glamorgan'),
			('SA','SA12','PORT TALBOT','West Glamorgan'),
			('SA','SA13','PORT TALBOT','West Glamorgan'),
			('SA','SA14','LLANELLI','Dyfed'),
			('SA','SA15','LLANELLI','Dyfed'),
			('SA','SA16','BURRY PORT','Dyfed'),
			('SA','SA17','FERRYSIDE','Dyfed'),
			('SA','SA17','KIDWELLY','Dyfed'),
			('SA','SA18','AMMANFORD','Dyfed'),
			('SA','SA19','LLANDEILO','Dyfed'),
			('SA','SA19','LLANGADOG','Dyfed'),
			('SA','SA19','LLANWRDA','Dyfed'),
			('SA','SA20','LLANDOVERY','Dyfed'),
			('SA','SA31','CARMARTHEN','Dyfed'),
			('SA','SA32','CARMARTHEN','Dyfed'),
			('SA','SA33','CARMARTHEN','Dyfed'),
			('SA','SA34','WHITLAND','Dyfed'),
			('SA','SA35','LLANFYRNACH','Dyfed'),
			('SA','SA36','GLOGUE','Dyfed'),
			('SA','SA37','BONCATH','Dyfed'),
			('SA','SA38','NEWCASTLE EMLYN','Dyfed'),
			('SA','SA39','PENCADER','Dyfed'),
			('SA','SA40','LLANYBYDDER','Dyfed'),
			('SA','SA41','CRYMYCH','Dyfed'),
			('SA','SA42','NEWPORT','Dyfed'),
			('SA','SA43','CARDIGAN','Dyfed'),
			('SA','SA44','LLANDYSUL','Dyfed'),
			('SA','SA45','NEW QUAY','Dyfed'),
			('SA','SA46','ABERAERON','Dyfed'),
			('SA','SA48','ABERAERON','Dyfed'),
			('SA','SA47','LLANARTH','Dyfed'),
			('SA','SA48','LAMPETER','Dyfed'),
			('SA','SA61','HAVERFORDWEST','Dyfed'),
			('SA','SA62','HAVERFORDWEST','Dyfed'),
			('SA','SA63','CLARBESTON ROAD','Dyfed'),
			('SA','SA64','GOODWICK','Dyfed'),
			('SA','SA65','FISHGUARD','Dyfed'),
			('SA','SA66','CLYNDERWEN','Dyfed'),
			('SA','SA67','NARBERTH','Dyfed'),
			('SA','SA68','KILGETTY','Dyfed'),
			('SA','SA69','SAUNDERSFOOT','Dyfed'),
			('SA','SA70','TENBY','Dyfed'),
			('SA','SA71','PEMBROKE','Dyfed'),
			('SA','SA72','PEMBROKE','Dyfed'),
			('SA','SA72','PEMBROKE DOCK','Dyfed'),
			('SA','SA73','MILFORD HAVEN','Dyfed'),
			('SE','SE01','LONDON','(London)'),
			('SE','SE1','LONDON','(London)'),
			('SE','SE1P','LONDON','(London)'),
			('SE','SE2','LONDON','(London)'),
			('SE','SE3','LONDON','(London)'),
			('SE','SE4','LONDON','(London)'),
			('SE','SE5','LONDON','(London)'),
			('SE','SE6','LONDON','(London)'),
			('SE','SE7','LONDON','(London)'),
			('SE','SE8','LONDON','(London)'),
			('SE','SE9','LONDON','(London)'),
			('SE','SE10','LONDON','(London)'),
			('SE','SE11','LONDON','(London)'),
			('SE','SE12','LONDON','(London)'),
			('SE','SE13','LONDON','(London)'),
			('SE','SE14','LONDON','(London)'),
			('SE','SE15','LONDON','(London)'),
			('SE','SE16','LONDON','(London)'),
			('SE','SE17','LONDON','(London)'),
			('SE','SE18','LONDON','(London)'),
			('SE','SE19','LONDON','(London)'),
			('SE','SE20','LONDON','(London)'),
			('SE','SE21','LONDON','(London)'),
			('SE','SE22','LONDON','(London)'),
			('SE','SE23','LONDON','(London)'),
			('SE','SE24','LONDON','(London)'),
			('SE','SE25','LONDON','(London)'),
			('SE','SE26','LONDON','(London)'),
			('SE','SE27','LONDON','(London)'),
			('SE','SE28','LONDON','(London)'),
			('SG','SG01','STEVENAGE','Hertfordshire'),
			('SG','SG1','STEVENAGE','Hertfordshire'),
			('SG','SG2','STEVENAGE','Hertfordshire'),
			('SG','SG03','KNEBWORTH','Hertfordshire'),
			('SG','SG3','KNEBWORTH','Hertfordshire'),
			('SG','SG04','HITCHIN','Hertfordshire'),
			('SG','SG4','HITCHIN','Hertfordshire'),
			('SG','SG5','HITCHIN','Hertfordshire'),
			('SG','SG6','HITCHIN','Hertfordshire'),
			('SG','SG06','LETCHWORTH GARDEN CITY','Hertfordshire'),
			('SG','SG6','LETCHWORTH GARDEN CITY','Hertfordshire'),
			('SG','SG07','BALDOCK','Hertfordshire'),
			('SG','SG7','BALDOCK','Hertfordshire'),
			('SG','SG08','ROYSTON','Hertfordshire'),
			('SG','SG8','ROYSTON','Hertfordshire'),
			('SG','SG09','BUNTINGFORD','Hertfordshire'),
			('SG','SG9','BUNTINGFORD','Hertfordshire'),
			('SG','SG10','MUCH HADHAM','Hertfordshire'),
			('SG','SG11','WARE','Hertfordshire'),
			('SG','SG12','WARE','Hertfordshire'),
			('SG','SG13','HERTFORD','(Hertfordshire)'),
			('SG','SG14','HERTFORD','(Hertfordshire)'),
			('SG','SG15','ARLESEY','Bedfordshire'),
			('SG','SG16','HENLOW','Bedfordshire'),
			('SG','SG17','SHEFFORD','Bedfordshire'),
			('SG','SG18','BIGGLESWADE','Bedfordshire'),
			('SG','SG19','SANDY','Bedfordshire'),
			('SK','SK01','STOCKPORT','Cheshire'),
			('SK','SK1','STOCKPORT','Cheshire'),
			('SK','SK2','STOCKPORT','Cheshire'),
			('SK','SK3','STOCKPORT','Cheshire'),
			('SK','SK4','STOCKPORT','Cheshire'),
			('SK','SK5','STOCKPORT','Cheshire'),
			('SK','SK6','STOCKPORT','Cheshire'),
			('SK','SK7','STOCKPORT','Cheshire'),
			('SK','SK12','STOCKPORT','Cheshire'),
			('SK','SK08','CHEADLE','Cheshire'),
			('SK','SK8','CHEADLE','Cheshire'),
			('SK','SK09','ALDERLEY EDGE','Cheshire'),
			('SK','SK9','ALDERLEY EDGE','Cheshire'),
			('SK','SK09','WILMSLOW','Cheshire'),
			('SK','SK9','WILMSLOW','Cheshire'),
			('SK','SK10','MACCLESFIELD','Cheshire'),
			('SK','SK11','MACCLESFIELD','Cheshire'),
			('SK','SK13','GLOSSOP','Derbyshire'),
			('SK','SK14','HYDE','Cheshire'),
			('SK','SK15','STALYBRIDGE','Cheshire'),
			('SK','SK16','DUKINFIELD','Cheshire'),
			('SK','SK17','BUXTON','Derbyshire'),
			('SK','SK22','HIGH PEAK','Derbyshire'),
			('SK','SK23','HIGH PEAK','Derbyshire'),
			('SL','SL00','IVER','Buckinghamshire'),
			('SL','SL0','IVER','Buckinghamshire'),
			('SL','SL01','SLOUGH','(Berkshire)'),
			('SL','SL1','SLOUGH','(Berkshire)'),
			('SL','SL2','SLOUGH','(Berkshire)'),
			('SL','SL3','SLOUGH','(Berkshire)'),
			('SL','SL95','SLOUGH','(Berkshire)'),
			('SL','SL04','WINDSOR','Berkshire'),
			('SL','SL4','WINDSOR','Berkshire'),
			('SL','SL05','ASCOT','Berkshire'),
			('SL','SL5','ASCOT','Berkshire'),
			('SL','SL06','MAIDENHEAD','Berkshire'),
			('SL','SL6','MAIDENHEAD','Berkshire'),
			('SL','SL60','MAIDENHEAD','Berkshire'),
			('SL','SL07','MARLOW','Buckinghamshire'),
			('SL','SL7','MARLOW','Buckinghamshire'),
			('SL','SL08','BOURNE END','Buckinghamshire'),
			('SL','SL8','BOURNE END','Buckinghamshire'),
			('SL','SL09','GERRARDS CROSS','Buckinghamshire'),
			('SL','SL9','GERRARDS CROSS','Buckinghamshire'),
			('SM','SM01','SUTTON','Surrey'),
			('SM','SM1','SUTTON','Surrey'),
			('SM','SM2','SUTTON','Surrey'),
			('SM','SM3','SUTTON','Surrey'),
			('SM','SM04','MORDEN','Surrey'),
			('SM','SM4','MORDEN','Surrey'),
			('SM','SM05','CARSHALTON','Surrey'),
			('SM','SM5','CARSHALTON','Surrey'),
			('SM','SM06','WALLINGTON','Surrey'),
			('SM','SM6','WALLINGTON','Surrey'),
			('SM','SM07','BANSTEAD','Surrey'),
			('SM','SM7','BANSTEAD','Surrey'),
			('SN','SN01','SWINDON','(Wiltshire)'),
			('SN','SN1','SWINDON','(Wiltshire)'),
			('SN','SN2','SWINDON','(Wiltshire)'),
			('SN','SN3','SWINDON','(Wiltshire)'),
			('SN','SN4','SWINDON','(Wiltshire)'),
			('SN','SN5','SWINDON','(Wiltshire)'),
			('SN','SN6','SWINDON','(Wiltshire)'),
			('SN','SN25','SWINDON','(Wiltshire)'),
			('SN','SN26','SWINDON','(Wiltshire)'),
			('SN','SN38','SWINDON','(Wiltshire)'),
			('SN','SN99','SWINDON','(Wiltshire)'),
			('SN','SN07','FARINGDON','Oxfordshire'),
			('SN','SN7','FARINGDON','Oxfordshire'),
			('SN','SN08','MARLBOROUGH','Wiltshire'),
			('SN','SN8','MARLBOROUGH','Wiltshire'),
			('SN','SN09','PEWSEY','Wiltshire'),
			('SN','SN9','PEWSEY','Wiltshire'),
			('SN','SN10','DEVIZES','Wiltshire'),
			('SN','SN11','CALNE','Wiltshire'),
			('SN','SN12','MELKSHAM','Wiltshire'),
			('SN','SN13','CORSHAM','Wiltshire'),
			('SN','SN15','CORSHAM','Wiltshire'),
			('SN','SN14','CHIPPENHAM','Wiltshire'),
			('SN','SN15','CHIPPENHAM','Wiltshire'),
			('SN','SN16','MALMESBURY','Wiltshire'),
			('SO','SO14','SOUTHAMPTON','(Hampshire)'),
			('SO','SO15','SOUTHAMPTON','(Hampshire)'),
			('SO','SO16','SOUTHAMPTON','(Hampshire)'),
			('SO','SO17','SOUTHAMPTON','(Hampshire)'),
			('SO','SO18','SOUTHAMPTON','(Hampshire)'),
			('SO','SO19','SOUTHAMPTON','(Hampshire)'),
			('SO','SO30','SOUTHAMPTON','(Hampshire)'),
			('SO','SO31','SOUTHAMPTON','(Hampshire)'),
			('SO','SO32','SOUTHAMPTON','(Hampshire)'),
			('SO','SO40','SOUTHAMPTON','(Hampshire)'),
			('SO','SO45','SOUTHAMPTON','(Hampshire)'),
			('SO','SO52','SOUTHAMPTON','(Hampshire)'),
			('SO','SO97','SOUTHAMPTON','(Hampshire)'),
			('SO','SO20','STOCKBRIDGE','Hampshire'),
			('SO','SO21','WINCHESTER','Hampshire'),
			('SO','SO22','WINCHESTER','Hampshire'),
			('SO','SO23','WINCHESTER','Hampshire'),
			('SO','SO24','ALRESFORD','Hampshire'),
			('SO','SO40','LYNDHURST','Hampshire'),
			('SO','SO43','LYNDHURST','Hampshire'),
			('SO','SO41','LYMINGTON','Hampshire'),
			('SO','SO42','BROCKENHURST','Hampshire'),
			('SO','SO50','EASTLEIGH','Hampshire'),
			('SO','SO53','EASTLEIGH','Hampshire'),
			('SO','SO51','ROMSEY','Hampshire'),
			('SP','SP01','SALISBURY','(Wiltshire)'),
			('SP','SP1','SALISBURY','(Wiltshire)'),
			('SP','SP2','SALISBURY','(Wiltshire)'),
			('SP','SP3','SALISBURY','(Wiltshire)'),
			('SP','SP4','SALISBURY','(Wiltshire)'),
			('SP','SP5','SALISBURY','(Wiltshire)'),
			('SP','SP06','FORDINGBRIDGE','Hampshire'),
			('SP','SP6','FORDINGBRIDGE','Hampshire'),
			('SP','SP07','SHAFTESBURY','Dorset'),
			('SP','SP7','SHAFTESBURY','Dorset'),
			('SP','SP08','GILLINGHAM','Dorset'),
			('SP','SP8','GILLINGHAM','Dorset'),
			('SP','SP09','TIDWORTH','Hampshire'),
			('SP','SP9','TIDWORTH','Hampshire'),
			('SP','SP10','ANDOVER','Hampshire'),
			('SP','SP11','ANDOVER','Hampshire'),
			('SR','SR01','SUNDERLAND','(Tyne and Wear)'),
			('SR','SR1','SUNDERLAND','(Tyne and Wear)'),
			('SR','SR2','SUNDERLAND','(Tyne and Wear)'),
			('SR','SR3','SUNDERLAND','(Tyne and Wear)'),
			('SR','SR4','SUNDERLAND','(Tyne and Wear)'),
			('SR','SR5','SUNDERLAND','(Tyne and Wear)'),
			('SR','SR6','SUNDERLAND','(Tyne and Wear)'),
			('SR','SR9','SUNDERLAND','(Tyne and Wear)'),
			('SR','SR07','SEAHAM','County Durham'),
			('SR','SR7','SEAHAM','County Durham'),
			('SR','SR08','PETERLEE','County Durham'),
			('SR','SR8','PETERLEE','County Durham'),
			('SS','SS00','WESTCLIFF-ON-SEA','Essex'),
			('SS','SS0','WESTCLIFF-ON-SEA','Essex'),
			('SS','SS1','WESTCLIFF-ON-SEA','Essex'),
			('SS','SS01','SOUTHEND-ON-SEA','(Essex)'),
			('SS','SS1','SOUTHEND-ON-SEA','(Essex)'),
			('SS','SS2','SOUTHEND-ON-SEA','(Essex)'),
			('SS','SS3','SOUTHEND-ON-SEA','(Essex)'),
			('SS','SS22','SOUTHEND-ON-SEA','(Essex)'),
			('SS','SS99','SOUTHEND-ON-SEA','(Essex)'),
			('SS','SS04','ROCHFORD','Essex'),
			('SS','SS4','ROCHFORD','Essex'),
			('SS','SS05','HOCKLEY','Essex'),
			('SS','SS5','HOCKLEY','Essex'),
			('SS','SS06','RAYLEIGH','Essex'),
			('SS','SS6','RAYLEIGH','Essex'),
			('SS','SS07','BENFLEET','Essex'),
			('SS','SS7','BENFLEET','Essex'),
			('SS','SS08','CANVEY ISLAND','Essex'),
			('SS','SS8','CANVEY ISLAND','Essex'),
			('SS','SS09','LEIGH-ON-SEA','Essex'),
			('SS','SS9','LEIGH-ON-SEA','Essex'),
			('SS','SS11','WICKFORD','Essex'),
			('SS','SS12','WICKFORD','Essex'),
			('SS','SS13','BASILDON','Essex'),
			('SS','SS14','BASILDON','Essex'),
			('SS','SS15','BASILDON','Essex'),
			('SS','SS16','BASILDON','Essex'),
			('SS','SS17','STANFORD-LE-HOPE','Essex'),
			('ST','ST01','STOKE-ON-TRENT','(Staffordshire)'),
			('ST','ST1','STOKE-ON-TRENT','(Staffordshire)'),
			('ST','ST2','STOKE-ON-TRENT','(Staffordshire)'),
			('ST','ST3','STOKE-ON-TRENT','(Staffordshire)'),
			('ST','ST4','STOKE-ON-TRENT','(Staffordshire)'),
			('ST','ST6','STOKE-ON-TRENT','(Staffordshire)'),
			('ST','ST7','STOKE-ON-TRENT','(Staffordshire)'),
			('ST','ST8','STOKE-ON-TRENT','(Staffordshire)'),
			('ST','ST9','STOKE-ON-TRENT','(Staffordshire)'),
			('ST','ST10','STOKE-ON-TRENT','(Staffordshire)'),
			('ST','ST11','STOKE-ON-TRENT','(Staffordshire)'),
			('ST','ST12','STOKE-ON-TRENT','(Staffordshire)'),
			('ST','ST05','NEWCASTLE','Staffordshire'),
			('ST','ST5','NEWCASTLE','Staffordshire'),
			('ST','ST55','NEWCASTLE','Staffordshire'),
			('ST','ST13','LEEK','Staffordshire'),
			('ST','ST14','UTTOXETER','Staffordshire'),
			('ST','ST15','STONE','Staffordshire'),
			('ST','ST16','STAFFORD','(Staffordshire)'),
			('ST','ST17','STAFFORD','(Staffordshire)'),
			('ST','ST18','STAFFORD','(Staffordshire)'),
			('ST','ST19','STAFFORD','(Staffordshire)'),
			('ST','ST20','STAFFORD','(Staffordshire)'),
			('ST','ST21','STAFFORD','(Staffordshire)'),
			('SW','SW01','LONDON','(London)'),
			('SW','SW1A','LONDON','(London)'),
			('SW','SW1E','LONDON','(London)'),
			('SW','SW1H','LONDON','(London)'),
			('SW','SW1P','LONDON','(London)'),
			('SW','SW1V','LONDON','(London)'),
			('SW','SW1W','LONDON','(London)'),
			('SW','SW1X','LONDON','(London)'),
			('SW','SW1Y','LONDON','(London)'),
			('SW','SW2','LONDON','(London)'),
			('SW','SW3','LONDON','(London)'),
			('SW','SW4','LONDON','(London)'),
			('SW','SW5','LONDON','(London)'),
			('SW','SW6','LONDON','(London)'),
			('SW','SW7','LONDON','(London)'),
			('SW','SW8','LONDON','(London)'),
			('SW','SW9','LONDON','(London)'),
			('SW','SW10','LONDON','(London)'),
			('SW','SW11','LONDON','(London)'),
			('SW','SW12','LONDON','(London)'),
			('SW','SW13','LONDON','(London)'),
			('SW','SW14','LONDON','(London)'),
			('SW','SW15','LONDON','(London)'),
			('SW','SW16','LONDON','(London)'),
			('SW','SW17','LONDON','(London)'),
			('SW','SW18','LONDON','(London)'),
			('SW','SW19','LONDON','(London)'),
			('SW','SW20','LONDON','(London)'),
			('SW','SW95','LONDON','(London)'),
			('SY','SY01','SHREWSBURY','(Shropshire)'),
			('SY','SY1','SHREWSBURY','(Shropshire)'),
			('SY','SY2','SHREWSBURY','(Shropshire)'),
			('SY','SY3','SHREWSBURY','(Shropshire)'),
			('SY','SY4','SHREWSBURY','(Shropshire)'),
			('SY','SY5','SHREWSBURY','(Shropshire)'),
			('SY','SY99','SHREWSBURY','(Shropshire)'),
			('SY','SY06','CHURCH STRETTON','Shropshire'),
			('SY','SY6','CHURCH STRETTON','Shropshire'),
			('SY','SY07','BUCKNELL','Shropshire'),
			('SY','SY7','BUCKNELL','Shropshire'),
			('SY','SY07','CRAVEN ARMS','Shropshire'),
			('SY','SY7','CRAVEN ARMS','Shropshire'),
			('SY','SY07','LYDBURY NORTH','Shropshire'),
			('SY','SY7','LYDBURY NORTH','Shropshire'),
			('SY','SY08','LUDLOW','Shropshire'),
			('SY','SY8','LUDLOW','Shropshire'),
			('SY','SY09','BISHOPS CASTLE','Shropshire'),
			('SY','SY9','BISHOPS CASTLE','Shropshire'),
			('SY','SY10','OSWESTRY','Shropshire'),
			('SY','SY11','OSWESTRY','Shropshire'),
			('SY','SY12','ELLESMERE','Shropshire'),
			('SY','SY13','WHITCHURCH','Shropshire'),
			('SY','SY14','MALPAS','Cheshire'),
			('SY','SY15','MONTGOMERY','Powys'),
			('SY','SY16','NEWTOWN','Powys'),
			('SY','SY17','CAERSWS','Powys'),
			('SY','SY17','LLANDINAM','Powys'),
			('SY','SY18','LLANIDLOES','Powys'),
			('SY','SY19','LLANBRYNMAIR','Powys'),
			('SY','SY20','MACHYNLLETH','Powys'),
			('SY','SY21','WELSHPOOL','Powys'),
			('SY','SY22','LLANFECHAIN','Powys'),
			('SY','SY22','LLANFYLLIN','Powys'),
			('SY','SY22','LLANSANTFFRAID','Powys'),
			('SY','SY22','LLANYMYNECH','Powys'),
			('SY','SY22','MEIFOD','Powys'),
			('SY','SY23','ABERYSTWYTH','Dyfed'),
			('SY','SY23','LLANON','Dyfed'),
			('SY','SY23','LLANRHYSTUD','Dyfed'),
			('SY','SY24','BORTH','Dyfed'),
			('SY','SY24','BOW STREET','Dyfed'),
			('SY','SY24','TALYBONT','Dyfed'),
			('SY','SY25','TREGARON','Dyfed'),
			('SY','SY25','YSTRAD MEURIG','Dyfed'),
			('TA','TA01','TAUNTON','Somerset'),
			('TA','TA1','TAUNTON','Somerset'),
			('TA','TA2','TAUNTON','Somerset'),
			('TA','TA3','TAUNTON','Somerset'),
			('TA','TA4','TAUNTON','Somerset'),
			('TA','TA05','BRIDGWATER','Somerset'),
			('TA','TA5','BRIDGWATER','Somerset'),
			('TA','TA6','BRIDGWATER','Somerset'),
			('TA','TA7','BRIDGWATER','Somerset'),
			('TA','TA08','BURNHAM-ON-SEA','Somerset'),
			('TA','TA8','BURNHAM-ON-SEA','Somerset'),
			('TA','TA09','HIGHBRIDGE','Somerset'),
			('TA','TA9','HIGHBRIDGE','Somerset'),
			('TA','TA10','LANGPORT','Somerset'),
			('TA','TA11','SOMERTON','Somerset'),
			('TA','TA12','MARTOCK','Somerset'),
			('TA','TA13','SOUTH PETHERTON','Somerset'),
			('TA','TA14','STOKE-SUB-HAMDON','Somerset'),
			('TA','TA15','MONTACUTE','Somerset'),
			('TA','TA16','MERRIOTT','Somerset'),
			('TA','TA17','HINTON ST. GEORGE','Somerset'),
			('TA','TA18','CREWKERNE','Somerset'),
			('TA','TA19','ILMINSTER','Somerset'),
			('TA','TA20','CHARD','Somerset'),
			('TA','TA21','WELLINGTON','Somerset'),
			('TA','TA22','DULVERTON','Somerset'),
			('TA','TA23','WATCHET','Somerset'),
			('TA','TA24','MINEHEAD','Somerset'),
			('TD','TD01','GALASHIELS','Selkirkshire'),
			('TD','TD1','GALASHIELS','Selkirkshire'),
			('TD','TD02','LAUDER','Berwickshire'),
			('TD','TD2','LAUDER','Berwickshire'),
			('TD','TD03','GORDON','Berwickshire'),
			('TD','TD3','GORDON','Berwickshire'),
			('TD','TD04','EARLSTON','Berwickshire'),
			('TD','TD4','EARLSTON','Berwickshire'),
			('TD','TD05','KELSO','Roxburghshire'),
			('TD','TD5','KELSO','Roxburghshire'),
			('TD','TD06','MELROSE','Roxburghshire'),
			('TD','TD6','MELROSE','Roxburghshire'),
			('TD','TD07','SELKIRK','(Selkirkshire)'),
			('TD','TD7','SELKIRK','(Selkirkshire)'),
			('TD','TD08','JEDBURGH','Roxburghshire'),
			('TD','TD8','JEDBURGH','Roxburghshire'),
			('TD','TD09','HAWICK','Roxburghshire'),
			('TD','TD9','HAWICK','Roxburghshire'),
			('TD','TD09','NEWCASTLETON','Roxburghshire'),
			('TD','TD9','NEWCASTLETON','Roxburghshire'),
			('TD','TD10','DUNS','Berwickshire'),
			('TD','TD11','DUNS','Berwickshire'),
			('TD','TD12','COLDSTREAM','Berwickshire'),
			('TD','TD12','CORNHILL-ON-TWEED','Northumberland'),
			('TD','TD12','MINDRUM','Northumberland'),
			('TD','TD13','COCKBURNSPATH','Berwickshire'),
			('TD','TD14','EYEMOUTH','Berwickshire'),
			('TD','TD15','BERWICK-UPON-TWEED','(Northumberland)'),
			('TF','TF01','TELFORD','Shropshire'),
			('TF','TF1','TELFORD','Shropshire'),
			('TF','TF2','TELFORD','Shropshire'),
			('TF','TF3','TELFORD','Shropshire'),
			('TF','TF4','TELFORD','Shropshire'),
			('TF','TF5','TELFORD','Shropshire'),
			('TF','TF6','TELFORD','Shropshire'),
			('TF','TF7','TELFORD','Shropshire'),
			('TF','TF8','TELFORD','Shropshire'),
			('TF','TF09','MARKET DRAYTON','Shropshire'),
			('TF','TF9','MARKET DRAYTON','Shropshire'),
			('TF','TF10','NEWPORT','Shropshire'),
			('TF','TF11','SHIFNAL','Shropshire'),
			('TF','TF12','BROSELEY','Shropshire'),
			('TF','TF13','MUCH WENLOCK','Shropshire'),
			('TN','TN01','TUNBRIDGE WELLS','Kent'),
			('TN','TN1','TUNBRIDGE WELLS','Kent'),
			('TN','TN2','TUNBRIDGE WELLS','Kent'),
			('TN','TN3','TUNBRIDGE WELLS','Kent'),
			('TN','TN4','TUNBRIDGE WELLS','Kent'),
			('TN','TN02','WADHURST','East Sussex'),
			('TN','TN2','WADHURST','East Sussex'),
			('TN','TN5','WADHURST','East Sussex'),
			('TN','TN06','CROWBOROUGH','East Sussex'),
			('TN','TN6','CROWBOROUGH','East Sussex'),
			('TN','TN07','HARTFIELD','East Sussex'),
			('TN','TN7','HARTFIELD','East Sussex'),
			('TN','TN08','EDENBRIDGE','Kent'),
			('TN','TN8','EDENBRIDGE','Kent'),
			('TN','TN09','TONBRIDGE','Kent'),
			('TN','TN9','TONBRIDGE','Kent'),
			('TN','TN10','TONBRIDGE','Kent'),
			('TN','TN11','TONBRIDGE','Kent'),
			('TN','TN12','TONBRIDGE','Kent'),
			('TN','TN13','SEVENOAKS','Kent'),
			('TN','TN14','SEVENOAKS','Kent'),
			('TN','TN15','SEVENOAKS','Kent'),
			('TN','TN16','WESTERHAM','Kent'),
			('TN','TN17','CRANBROOK','Kent'),
			('TN','TN18','CRANBROOK','Kent'),
			('TN','TN19','ETCHINGHAM','East Sussex'),
			('TN','TN20','MAYFIELD','East Sussex'),
			('TN','TN21','HEATHFIELD','East Sussex'),
			('TN','TN22','UCKFIELD','East Sussex'),
			('TN','TN23','ASHFORD','Kent'),
			('TN','TN24','ASHFORD','Kent'),
			('TN','TN25','ASHFORD','Kent'),
			('TN','TN26','ASHFORD','Kent'),
			('TN','TN27','ASHFORD','Kent'),
			('TN','TN28','NEW ROMNEY','Kent'),
			('TN','TN29','ROMNEY MARSH','Kent'),
			('TN','TN30','TENTERDEN','Kent'),
			('TN','TN31','RYE','East Sussex'),
			('TN','TN32','ROBERTSBRIDGE','East Sussex'),
			('TN','TN33','BATTLE','East Sussex'),
			('TN','TN34','HASTINGS','East Sussex'),
			('TN','TN35','HASTINGS','East Sussex'),
			('TN','TN36','WINCHELSEA','East Sussex'),
			('TN','TN37','ST. LEONARDS-ON-SEA','East Sussex'),
			('TN','TN38','ST. LEONARDS-ON-SEA','East Sussex'),
			('TN','TN39','BEXHILL-ON-SEA','East Sussex'),
			('TN','TN40','BEXHILL-ON-SEA','East Sussex'),
			('TQ','TQ01','TORQUAY','(Devon)'),
			('TQ','TQ1','TORQUAY','(Devon)'),
			('TQ','TQ2','TORQUAY','(Devon)'),
			('TQ','TQ03','PAIGNTON','Devon'),
			('TQ','TQ3','PAIGNTON','Devon'),
			('TQ','TQ4','PAIGNTON','Devon'),
			('TQ','TQ05','BRIXHAM','Devon'),
			('TQ','TQ5','BRIXHAM','Devon'),
			('TQ','TQ06','DARTMOUTH','Devon'),
			('TQ','TQ6','DARTMOUTH','Devon'),
			('TQ','TQ07','KINGSBRIDGE','Devon'),
			('TQ','TQ7','KINGSBRIDGE','Devon'),
			('TQ','TQ08','SALCOMBE','Devon'),
			('TQ','TQ8','SALCOMBE','Devon'),
			('TQ','TQ09','TOTNES','Devon'),
			('TQ','TQ9','TOTNES','Devon'),
			('TQ','TQ09','SOUTH BRENT','Devon'),
			('TQ','TQ9','SOUTH BRENT','Devon'),
			('TQ','TQ10','SOUTH BRENT','Devon'),
			('TQ','TQ11','BUCKFASTLEIGH','Devon'),
			('TQ','TQ12','NEWTON ABBOT','Devon'),
			('TQ','TQ13','NEWTON ABBOT','Devon'),
			('TQ','TQ14','TEIGNMOUTH','Devon'),
			('TR','TR01','TRURO','Cornwall'),
			('TR','TR1','TRURO','Cornwall'),
			('TR','TR2','TRURO','Cornwall'),
			('TR','TR3','TRURO','Cornwall'),
			('TR','TR4','TRURO','Cornwall'),
			('TR','TR05','ST. AGNES','Cornwall'),
			('TR','TR5','ST. AGNES','Cornwall'),
			('TR','TR06','PERRANPORTH','Cornwall'),
			('TR','TR6','PERRANPORTH','Cornwall'),
			('TR','TR07','NEWQUAY','Cornwall'),
			('TR','TR7','NEWQUAY','Cornwall'),
			('TR','TR8','NEWQUAY','Cornwall'),
			('TR','TR09','ST. COLUMB','Cornwall'),
			('TR','TR9','ST. COLUMB','Cornwall'),
			('TR','TR10','PENRYN','Cornwall'),
			('TR','TR11','FALMOUTH','Cornwall'),
			('TR','TR12','HELSTON','Cornwall'),
			('TR','TR13','HELSTON','Cornwall'),
			('TR','TR14','CAMBORNE','Cornwall'),
			('TR','TR15','REDRUTH','Cornwall'),
			('TR','TR16','REDRUTH','Cornwall'),
			('TR','TR17','MARAZION','Cornwall'),
			('TR','TR18','PENZANCE','Cornwall'),
			('TR','TR19','PENZANCE','Cornwall'),
			('TR','TR20','PENZANCE','Cornwall'),
			('TR','TR21','ISLES OF SCILLY','(Isles of Scilly)'),
			('TR','TR22','ISLES OF SCILLY','(Isles of Scilly)'),
			('TR','TR23','ISLES OF SCILLY','(Isles of Scilly)'),
			('TR','TR24','ISLES OF SCILLY','(Isles of Scilly)'),
			('TR','TR25','ISLES OF SCILLY','(Isles of Scilly)'),
			('TR','TR26','ST. IVES','Cornwall'),
			('TR','TR27','HAYLE','Cornwall'),
			('TS','TS01','MIDDLESBROUGH','Cleveland'),
			('TS','TS1','MIDDLESBROUGH','Cleveland'),
			('TS','TS2','MIDDLESBROUGH','Cleveland'),
			('TS','TS3','MIDDLESBROUGH','Cleveland'),
			('TS','TS4','MIDDLESBROUGH','Cleveland'),
			('TS','TS5','MIDDLESBROUGH','Cleveland'),
			('TS','TS6','MIDDLESBROUGH','Cleveland'),
			('TS','TS7','MIDDLESBROUGH','Cleveland'),
			('TS','TS8','MIDDLESBROUGH','Cleveland'),
			('TS','TS9','MIDDLESBROUGH','Cleveland'),
			('TS','TS10','REDCAR','Cleveland'),
			('TS','TS11','REDCAR','Cleveland'),
			('TS','TS12','SALTBURN-BY-THE-SEA','Cleveland'),
			('TS','TS13','SALTBURN-BY-THE-SEA','Cleveland'),
			('TS','TS14','GUISBOROUGH','Cleveland'),
			('TS','TS15','YARM','Cleveland'),
			('TS','TS16','STOCKTON-ON-TEES','Cleveland'),
			('TS','TS17','STOCKTON-ON-TEES','Cleveland'),
			('TS','TS18','STOCKTON-ON-TEES','Cleveland'),
			('TS','TS19','STOCKTON-ON-TEES','Cleveland'),
			('TS','TS20','STOCKTON-ON-TEES','Cleveland'),
			('TS','TS21','STOCKTON-ON-TEES','Cleveland'),
			('TS','TS22','BILLINGHAM','Cleveland'),
			('TS','TS23','BILLINGHAM','Cleveland'),
			('TS','TS24','HARTLEPOOL','Cleveland'),
			('TS','TS25','HARTLEPOOL','Cleveland'),
			('TS','TS26','HARTLEPOOL','Cleveland'),
			('TS','TS27','HARTLEPOOL','Cleveland'),
			('TS','TS28','WINGATE','County Durham'),
			('TS','TS29','TRIMDON STATION','County Durham'),
			('TW','TW01','TWICKENHAM','(Middlesex)'),
			('TW','TW1','TWICKENHAM','(Middlesex)'),
			('TW','TW2','TWICKENHAM','(Middlesex)'),
			('TW','TW03','HOUNSLOW','(Middlesex)'),
			('TW','TW3','HOUNSLOW','(Middlesex)'),
			('TW','TW4','HOUNSLOW','(Middlesex)'),
			('TW','TW5','HOUNSLOW','(Middlesex)'),
			('TW','TW6','HOUNSLOW','(Middlesex)'),
			('TW','TW07','ISLEWORTH','Middlesex'),
			('TW','TW7','ISLEWORTH','Middlesex'),
			('TW','TW08','BRENTFORD','Middlesex'),
			('TW','TW8','BRENTFORD','Middlesex'),
			('TW','TW09','RICHMOND','Surrey'),
			('TW','TW9','RICHMOND','Surrey'),
			('TW','TW10','RICHMOND','Surrey'),
			('TW','TW11','TEDDINGTON','Middlesex'),
			('TW','TW12','HAMPTON','Middlesex'),
			('TW','TW13','FELTHAM','Middlesex'),
			('TW','TW14','FELTHAM','Middlesex'),
			('TW','TW15','ASHFORD','Middlesex'),
			('TW','TW16','SUNBURY-ON-THAMES','Middlesex'),
			('TW','TW17','SHEPPERTON','Middlesex'),
			('TW','TW18','STAINES-UPON-THAMES[11]','Middlesex'),
			('TW','TW19','STAINES-UPON-THAMES[11]','Middlesex'),
			('TW','TW20','EGHAM','Surrey'),
			('UB','UB01','SOUTHALL','Middlesex'),
			('UB','UB1','SOUTHALL','Middlesex'),
			('UB','UB2','SOUTHALL','Middlesex'),
			('UB','UB3','SOUTHALL','Middlesex'),
			('UB','UB03','HAYES','Middlesex'),
			('UB','UB3','HAYES','Middlesex'),
			('UB','UB4','HAYES','Middlesex'),
			('UB','UB05','NORTHOLT','Middlesex'),
			('UB','UB5','NORTHOLT','Middlesex'),
			('UB','UB05','GREENFORD','Middlesex'),
			('UB','UB5','GREENFORD','Middlesex'),
			('UB','UB6','GREENFORD','Middlesex'),
			('UB','UB18','GREENFORD','Middlesex'),
			('UB','UB07','WEST DRAYTON','Middlesex'),
			('UB','UB7','WEST DRAYTON','Middlesex'),
			('UB','UB8','WEST DRAYTON','Middlesex'),
			('UB','UB08','UXBRIDGE','Middlesex'),
			('UB','UB8','UXBRIDGE','Middlesex'),
			('UB','UB9','UXBRIDGE','Middlesex'),
			('UB','UB10','UXBRIDGE','Middlesex'),
			('UB','UB11','UXBRIDGE','Middlesex'),
			('W','W001','LONDON','(London)'),
			('W','W1A','LONDON','(London)'),
			('W','W1B','LONDON','(London)'),
			('W','W1C','LONDON','(London)'),
			('W','W1D','LONDON','(London)'),
			('W','W1F','LONDON','(London)'),
			('W','W1G','LONDON','(London)'),
			('W','W1H','LONDON','(London)'),
			('W','W1J','LONDON','(London)'),
			('W','W1K','LONDON','(London)'),
			('W','W1S','LONDON','(London)'),
			('W','W1T','LONDON','(London)'),
			('W','W1U','LONDON','(London)'),
			('W','W1W','LONDON','(London)'),
			('W','W2','LONDON','(London)'),
			('W','W3','LONDON','(London)'),
			('W','W4','LONDON','(London)'),
			('W','W5','LONDON','(London)'),
			('W','W6','LONDON','(London)'),
			('W','W7','LONDON','(London)'),
			('W','W8','LONDON','(London)'),
			('W','W9','LONDON','(London)'),
			('W','W10','LONDON','(London)'),
			('W','W11','LONDON','(London)'),
			('W','W12','LONDON','(London)'),
			('W','W13','LONDON','(London)'),
			('W','W14','LONDON','(London)'),
			('WA','WA01','WARRINGTON','(Cheshire)'),
			('WA','WA1','WARRINGTON','(Cheshire)'),
			('WA','WA2','WARRINGTON','(Cheshire)'),
			('WA','WA3','WARRINGTON','(Cheshire)'),
			('WA','WA4','WARRINGTON','(Cheshire)'),
			('WA','WA5','WARRINGTON','(Cheshire)'),
			('WA','WA55','WARRINGTON','(Cheshire)'),
			('WA','WA06','FRODSHAM','Cheshire'),
			('WA','WA6','FRODSHAM','Cheshire'),
			('WA','WA07','RUNCORN','Cheshire'),
			('WA','WA7','RUNCORN','Cheshire'),
			('WA','WA08','WIDNES','Cheshire'),
			('WA','WA8','WIDNES','Cheshire'),
			('WA','WA88','WIDNES','Cheshire'),
			('WA','WA09','ST. HELENS','Merseyside'),
			('WA','WA9','ST. HELENS','Merseyside'),
			('WA','WA10','ST. HELENS','Merseyside'),
			('WA','WA11','ST. HELENS','Merseyside'),
			('WA','WA12','NEWTON-LE-WILLOWS','Merseyside'),
			('WA','WA13','LYMM','Cheshire'),
			('WA','WA14','ALTRINCHAM','Cheshire'),
			('WA','WA15','ALTRINCHAM','Cheshire'),
			('WA','WA16','KNUTSFORD','Cheshire'),
			('WC','WC01','LONDON','(London)'),
			('WC','WC1A','LONDON','(London)'),
			('WC','WC1B','LONDON','(London)'),
			('WC','WC1E','LONDON','(London)'),
			('WC','WC1H','LONDON','(London)'),
			('WC','WC1N','LONDON','(London)'),
			('WC','WC1R','LONDON','(London)'),
			('WC','WC1V','LONDON','(London)'),
			('WC','WC1X','LONDON','(London)'),
			('WC','WC2A','LONDON','(London)'),
			('WC','WC2B','LONDON','(London)'),
			('WC','WC2E','LONDON','(London)'),
			('WC','WC2H','LONDON','(London)'),
			('WC','WC2N','LONDON','(London)'),
			('WC','WC2R','LONDON','(London)'),
			('WD','WD03','RICKMANSWORTH','Hertfordshire'),
			('WD','WD3','RICKMANSWORTH','Hertfordshire'),
			('WD','WD04','KINGS LANGLEY','Hertfordshire'),
			('WD','WD4','KINGS LANGLEY','Hertfordshire'),
			('WD','WD18','KINGS LANGLEY','Hertfordshire'),
			('WD','WD05','ABBOTS LANGLEY','Hertfordshire'),
			('WD','WD5','ABBOTS LANGLEY','Hertfordshire'),
			('WD','WD06','BOREHAMWOOD','Hertfordshire'),
			('WD','WD6','BOREHAMWOOD','Hertfordshire'),
			('WD','WD07','RADLETT','Hertfordshire'),
			('WD','WD7','RADLETT','Hertfordshire'),
			('WD','WD17','WATFORD','(Hertfordshire)'),
			('WD','WD18','WATFORD','(Hertfordshire)'),
			('WD','WD19','WATFORD','(Hertfordshire)'),
			('WD','WD24','WATFORD','(Hertfordshire)'),
			('WD','WD25','WATFORD','(Hertfordshire)'),
			('WD','WD99','WATFORD','(Hertfordshire)'),
			('WD','WD23','BUSHEY','(Hertfordshire)'),
			('WF','WF01','WAKEFIELD','West Yorkshire'),
			('WF','WF1','WAKEFIELD','West Yorkshire'),
			('WF','WF2','WAKEFIELD','West Yorkshire'),
			('WF','WF3','WAKEFIELD','West Yorkshire'),
			('WF','WF4','WAKEFIELD','West Yorkshire'),
			('WF','WF90','WAKEFIELD','West Yorkshire'),
			('WF','WF05','OSSETT','West Yorkshire'),
			('WF','WF5','OSSETT','West Yorkshire'),
			('WF','WF06','NORMANTON','West Yorkshire'),
			('WF','WF6','NORMANTON','West Yorkshire'),
			('WF','WF10','NORMANTON','West Yorkshire'),
			('WF','WF07','PONTEFRACT','West Yorkshire'),
			('WF','WF7','PONTEFRACT','West Yorkshire'),
			('WF','WF8','PONTEFRACT','West Yorkshire'),
			('WF','WF9','PONTEFRACT','West Yorkshire'),
			('WF','WF10','CASTLEFORD','West Yorkshire'),
			('WF','WF11','KNOTTINGLEY','West Yorkshire'),
			('WF','WF12','DEWSBURY','West Yorkshire'),
			('WF','WF13','DEWSBURY','West Yorkshire'),
			('WF','WF14','MIRFIELD','West Yorkshire'),
			('WF','WF15','LIVERSEDGE','West Yorkshire'),
			('WF','WF16','LIVERSEDGE','West Yorkshire'),
			('WF','WF16','HECKMONDWIKE','West Yorkshire'),
			('WF','WF17','BATLEY','West Yorkshire'),
			('WN','WN01','WIGAN','Lancashire'),
			('WN','WN1','WIGAN','Lancashire'),
			('WN','WN2','WIGAN','Lancashire'),
			('WN','WN3','WIGAN','Lancashire'),
			('WN','WN4','WIGAN','Lancashire'),
			('WN','WN5','WIGAN','Lancashire'),
			('WN','WN6','WIGAN','Lancashire'),
			('WN','WN8','WIGAN','Lancashire'),
			('WN','WN07','LEIGH','Lancashire'),
			('WN','WN7','LEIGH','Lancashire'),
			('WN','WN08','SKELMERSDALE','Lancashire'),
			('WN','WN8','SKELMERSDALE','Lancashire'),
			('WR','WR01','WORCESTER','(Worcestershire)'),
			('WR','WR1','WORCESTER','(Worcestershire)'),
			('WR','WR2','WORCESTER','(Worcestershire)'),
			('WR','WR3','WORCESTER','(Worcestershire)'),
			('WR','WR4','WORCESTER','(Worcestershire)'),
			('WR','WR5','WORCESTER','(Worcestershire)'),
			('WR','WR6','WORCESTER','(Worcestershire)'),
			('WR','WR7','WORCESTER','(Worcestershire)'),
			('WR','WR8','WORCESTER','(Worcestershire)'),
			('WR','WR78','WORCESTER','(Worcestershire)'),
			('WR','WR99','WORCESTER','(Worcestershire)'),
			('WR','WR09','DROITWICH','Worcestershire'),
			('WR','WR9','DROITWICH','Worcestershire'),
			('WR','WR10','PERSHORE','Worcestershire'),
			('WR','WR11','EVESHAM','Worcestershire'),
			('WR','WR11','BROADWAY','Worcestershire'),
			('WR','WR12','BROADWAY','Worcestershire'),
			('WR','WR13','MALVERN','Worcestershire'),
			('WR','WR14','MALVERN','Worcestershire'),
			('WR','WR15','TENBURY WELLS','Worcestershire'),
			('WS','WS01','WALSALL','(West Midlands)'),
			('WS','WS1','WALSALL','(West Midlands)'),
			('WS','WS2','WALSALL','(West Midlands)'),
			('WS','WS3','WALSALL','(West Midlands)'),
			('WS','WS4','WALSALL','(West Midlands)'),
			('WS','WS5','WALSALL','(West Midlands)'),
			('WS','WS6','WALSALL','(West Midlands)'),
			('WS','WS8','WALSALL','(West Midlands)'),
			('WS','WS9','WALSALL','(West Midlands)'),
			('WS','WS07','BURNTWOOD','Staffordshire'),
			('WS','WS7','BURNTWOOD','Staffordshire'),
			('WS','WS10','WEDNESBURY','West Midlands'),
			('WS','WS11','CANNOCK','Staffordshire'),
			('WS','WS12','CANNOCK','Staffordshire'),
			('WS','WS13','LICHFIELD','Staffordshire'),
			('WS','WS14','LICHFIELD','Staffordshire'),
			('WS','WS15','RUGELEY','Staffordshire'),
			('WV','WV01','WOLVERHAMPTON','(West Midlands)'),
			('WV','WV1','WOLVERHAMPTON','(West Midlands)'),
			('WV','WV2','WOLVERHAMPTON','(West Midlands)'),
			('WV','WV3','WOLVERHAMPTON','(West Midlands)'),
			('WV','WV4','WOLVERHAMPTON','(West Midlands)'),
			('WV','WV5','WOLVERHAMPTON','(West Midlands)'),
			('WV','WV6','WOLVERHAMPTON','(West Midlands)'),
			('WV','WV7','WOLVERHAMPTON','(West Midlands)'),
			('WV','WV8','WOLVERHAMPTON','(West Midlands)'),
			('WV','WV9','WOLVERHAMPTON','(West Midlands)'),
			('WV','WV10','WOLVERHAMPTON','(West Midlands)'),
			('WV','WV11','WOLVERHAMPTON','(West Midlands)'),
			('WV','WV98','WOLVERHAMPTON','(West Midlands)'),
			('WV','WV01','WILLENHALL','West Midlands'),
			('WV','WV1','WILLENHALL','West Midlands'),
			('WV','WV12','WILLENHALL','West Midlands'),
			('WV','WV13','WILLENHALL','West Midlands'),
			('WV','WV14','BILSTON','West Midlands'),
			('WV','WV15','BRIDGNORTH','Shropshire'),
			('WV','WV16','BRIDGNORTH','Shropshire'),
			('YO','YO01','YORK','(North Yorkshire)'),
			('YO','YO1','YORK','(North Yorkshire)'),
			('YO','YO10','YORK','(North Yorkshire)'),
			('YO','YO19','YORK','(North Yorkshire)'),
			('YO','YO23','YORK','(North Yorkshire)'),
			('YO','YO24','YORK','(North Yorkshire)'),
			('YO','YO26','YORK','(North Yorkshire)'),
			('YO','YO30','YORK','(North Yorkshire)'),
			('YO','YO31','YORK','(North Yorkshire)'),
			('YO','YO32','YORK','(North Yorkshire)'),
			('YO','YO41','YORK','(North Yorkshire)'),
			('YO','YO42','YORK','(North Yorkshire)'),
			('YO','YO43','YORK','(North Yorkshire)'),
			('YO','YO51','YORK','(North Yorkshire)'),
			('YO','YO60','YORK','(North Yorkshire)'),
			('YO','YO61','YORK','(North Yorkshire)'),
			('YO','YO62','YORK','(North Yorkshire)'),
			('YO','YO90','YORK','(North Yorkshire)'),
			('YO','YO91','YORK','(North Yorkshire)'),
			('YO','YO07','THIRSK','North Yorkshire'),
			('YO','YO7','THIRSK','North Yorkshire'),
			('YO','YO08','SELBY','North Yorkshire'),
			('YO','YO8','SELBY','North Yorkshire'),
			('YO','YO11','SCARBOROUGH','North Yorkshire'),
			('YO','YO12','SCARBOROUGH','North Yorkshire'),
			('YO','YO13','SCARBOROUGH','North Yorkshire'),
			('YO','YO14','FILEY','North Yorkshire'),
			('YO','YO15','BRIDLINGTON','North Humberside'),
			('YO','YO16','BRIDLINGTON','North Humberside'),
			('YO','YO17','MALTON','North Yorkshire'),
			('YO','YO18','PICKERING','North Yorkshire'),
			('YO','YO21','WHITBY','North Yorkshire'),
			('YO','YO22','WHITBY','North Yorkshire'),
			('YO','YO25','DRIFFIELD','North Humberside'),
			('ZE','ZE01','SHETLAND','(Shetland Islands)'),
			('ZE','ZE1','SHETLAND','(Shetland Islands)'),
			('ZE','ZE2','SHETLAND','(Shetland Islands)'),
			('ZE','ZE3','SHETLAND','(Shetland Islands)');
		END

	END

	/** Populate ScheduledEmailState **/
	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - ScheduledEmailState';
	BEGIN
		PRINT('');PRINT('*Populate ScheduledEmailState');
		INSERT INTO dbo.[ScheduledEmailState] (Id, Name)
		SELECT Id, Name
		FROM (
			SELECT 1 AS Id,'Pending' AS Name
			UNION
			SELECT 2 AS Id,'Sent' AS Name
			UNION
			SELECT 3 AS Id,'Failed - Retrying' AS Name
			UNION
			SELECT 4 AS Id,'Failed' AS Name
		) SES
		WHERE NOT EXISTS (
							SELECT *
							FROM dbo.[ScheduledEmailState] S
							WHERE SES.Name = SES.Name
							AND S.Id = S.Id
						);
	END

	--System States and DORS System States
	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - System States and DORS System States';
	BEGIN
		PRINT('');PRINT('*System States and DORS System States');
		BEGIN
			IF OBJECT_ID('tempdb..#NewSystemStates', 'U') IS NOT NULL
			BEGIN
				DROP TABLE #NewSystemStates;
			END

			SELECT Id, Colour, ColourHexCode, ImageName
			INTO #NewSystemStates
			FROM (SELECT 0 AS Id, 'Unknown' AS Colour, 'CCFFFF' AS ColourHexCode, 'bullet_Level0.png' AS ImageName
				UNION SELECT 1, 'Green', 'ADEBAD', 'bullet_Level1.png'
				UNION SELECT 2, 'Grey', 'D9D9D9', 'bullet_Level2.png'
				UNION SELECT 3, 'Amber', 'FFBF00', 'bullet_Level3.png'
				UNION SELECT 4, 'Red', 'FF9999', 'bullet_Level4.png'
				) NewStates

			INSERT INTO dbo.SystemState(Id, Colour, ColourHexCode, ImageName)
			SELECT Id, Colour, ColourHexCode, ImageName
			FROM #NewSystemStates NSS
			WHERE NOT EXISTS (SELECT * FROM dbo.SystemState SS WHERE SS.Id = NSS.Id);

			UPDATE SS
			SET Colour = NSS.Colour
			, ColourHexCode = NSS.ColourHexCode
			, ImageName = NSS.ImageName
			FROM dbo.SystemState SS
			INNER JOIN #NewSystemStates NSS ON NSS.Id = SS.Id;
		END

		BEGIN
			IF OBJECT_ID('tempdb..#NewDORSStates', 'U') IS NOT NULL
			BEGIN
				DROP TABLE #NewDORSStates;
			END

			SELECT Id, Name, [Description], SystemStateId
			INTO #NewDORSStates
			FROM (SELECT 0 AS Id, 'Unknown' AS Name, 'Unknown' AS [Description], 2 AS SystemStateId
				UNION SELECT 1, 'Normal', 'DORS is operating as expected', 1
				UNION SELECT 2, 'Error1', 'DORS is running but has reported an error', 3
				UNION SELECT 3, 'Disabled', 'DORS has been disabled', 4
				UNION SELECT 4, 'Error2', 'DORS has reported an error and is not running', 4
				UNION SELECT 5, 'Warning', 'DORS Connection Details need Updating', 2
				UNION SELECT 6, 'Warning2', 'DORS Connection Details need Updating', 3
				) NewStates

			INSERT INTO dbo.DORSState(Id, Name, [Description], SystemStateId)
			SELECT Id, Name, [Description], SystemStateId
			FROM #NewDORSStates NDS
			WHERE NOT EXISTS (SELECT * FROM dbo.DORSState DS WHERE DS.Id = NDS.Id OR DS.Name = NDS.Name);

			UPDATE DS
			SET Name = NDS.Name
			, Description = NDS.Description
			, SystemStateId = NDS.SystemStateId
			FROM dbo.DORSState DS
			INNER JOIN #NewDORSStates NDS ON NDS.Id = DS.Id;
		END
	END


	--DORS Trainer Licence States
	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - DORS Trainer Licence States';
	BEGIN
		PRINT('');PRINT('*DORS Trainer Licence States');
		BEGIN
			IF OBJECT_ID('tempdb..#NewDORSTrainerLicenceState', 'U') IS NOT NULL
			BEGIN
				DROP TABLE #NewDORSTrainerLicenceState;
			END

			SELECT Identifier, [Name]
			INTO #NewDORSTrainerLicenceState
			FROM (SELECT 1 AS Identifier, 'Provisional / Conditional' AS [Name]
				UNION SELECT 2 AS Identifier, 'Full' AS [Name]
				UNION SELECT 3 AS Identifier, 'Suspended' AS [Name]
				UNION SELECT 4 AS Identifier, 'Revoked' AS [Name]
				UNION SELECT 5 AS Identifier, 'Surrendered' AS [Name]
				UNION SELECT 6 AS Identifier, 'Expired' AS [Name]
				) NewDORSTrainerLicenceState

			INSERT INTO dbo.DORSTrainerLicenceState(Identifier, [Name])
			SELECT Identifier, [Name]
			FROM #NewDORSTrainerLicenceState NDTLS
			WHERE NOT EXISTS (SELECT * FROM dbo.DORSTrainerLicenceState DTLS WHERE DTLS.[Name] = NDTLS.[Name]);

			UPDATE DTLS
			SET Identifier = NDTLS.Identifier
			FROM dbo.DORSTrainerLicenceState DTLS
			INNER JOIN #NewDORSTrainerLicenceState NDTLS ON NDTLS.[Name] = DTLS.[Name];
		END

	END

	--Inserts data in to CourseReferenceGenerator table
	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - CourseReferenceGenerator';
	BEGIN
		PRINT('');PRINT('*Inserts data in to CourseReferenceGenerator table');
		IF OBJECT_ID('tempdb..#CourseRefGeneratorInsert', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #CourseRefGeneratorInsert;
		END

		SELECT Id, Code, Title, [Description]
		INTO #CourseRefGeneratorInsert
		FROM (
			SELECT 0 AS Id, 'AN' AS Code, 'Auto Generated Number' AS Title, 'Automatically Generate a number. This will be an incremental number.' + CHAR(13) + 'e.g. ''12345''' AS [Description]
			UNION
			SELECT 1, 'ANP', 'Auto Generated Number with Prefix', 'Automatically Generate a number with a Prefix. This will be an incremental number with a set Prefix.' + CHAR(13) + 'e.g. ''PREFIX12345'''
			UNION
			SELECT 2, 'ANS', 'Auto Generated Number with Suffix', 'Automatically Generate a number with a Suffix. This will be an incremental number with a set Suffix.' + CHAR(13) + 'e.g. ''12345SUFFIX'''
			UNION
			SELECT 3, 'ANPS', 'Auto Generated Number with Prefix & Suffix', 'Automatically Generate a number with a Prefix and a Suffix. This will be an incremental number with a set Prefix and a set Suffix.'+ CHAR(13) + 'e.g. ''PREFIX12345SUFFIX'''
			UNION
			SELECT 4, 'PSAN', 'Prefix, Separator and Auto Generated Number', 'Starts with a set Prefix followed by a Separator and then an Automatically Generated Number.' + CHAR(13) + 'e.g. ''PREFIX - 12345'''
			UNION
			SELECT 5, 'ANSP', 'Auto Generated Number, Separator and a Suffix', 'Starts with an Automatically Generated Number followed by a Separator and then a set Suffix.' + CHAR(13) + 'eg. ''12345 - SUFFIX'''
			UNION
			SELECT 6, 'VAN', 'Venue and Auto Generated Number', 'Starts with the Venue Code followed by an Automatically Generated Number.' + CHAR(13) + 'e.g. ''VEN12345'''
			UNION
			SELECT 7, 'VSAN', 'Venue, Separator and Auto Generated Number', 'Starts with the Venue Code then a Separator followed by an Automatically Generated Number.' + CHAR(13) + 'e.g. ''VEN - 12345'''
			UNION
			SELECT 8, 'TAN', 'Course Type and Auto Generated Number', 'Starts with the Course Type Code followed by an Automatically Generated Number.' + CHAR(13) + 'e.g. ''CT12345'''
			UNION
			SELECT 9, 'TSAN', 'Course Type, Separator and Auto Generated Number', 'Starts with the Course Type Code then a Separator followed by an Automatically Generated Number.' + CHAR(13) + 'e.g. ''CT - 12345'''
			UNION
			SELECT 10, 'TD', 'Course Type and Formatted Date', 'Starts with the Course Type Code followed by a Formatted Date.' + CHAR(13) + 'e.g. ''CT20160315'''
			UNION
			SELECT 11, 'TSD', 'Course Type, Separator and Formatted Date', 'Starts with the Course Type Code then a Separator followed by a Formatted Date.' + CHAR(13) + 'e.g. ''CT - 2016-03-15'''
			) CourseRefGeneratorInfo

		SET IDENTITY_INSERT dbo.CourseReferenceGenerator ON;
		INSERT INTO dbo.CourseReferenceGenerator(Id, Code, Title, [Description])
		SELECT Id, Code, Title, [Description]
		FROM #CourseRefGeneratorInsert CRGI
		WHERE NOT EXISTS (SELECT *
							FROM dbo.CourseReferenceGenerator CRG
							WHERE CRG.Id = CRGI.Id);
		SET IDENTITY_INSERT dbo.CourseReferenceGenerator OFF;

	END

	--Inserts data in to ReportDataType table
	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - ReportDataType';
	BEGIN
		PRINT('');PRINT('*Inserts data in to ReportDataType table');
		IF OBJECT_ID('tempdb..#ReportDataTypeInsert', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #ReportDataTypeInsert;
		END

		SELECT Title, DataTypeName, SelectIdentifier
		INTO #ReportDataTypeInsert
		FROM (
			SELECT 'String' AS Title, 'String' as DataTypeName, '' AS SelectIdentifier
			UNION
			SELECT 'Date', 'Date', ''
			UNION
			SELECT 'Between Date', 'BDate', ''
			UNION
			SELECT 'Number', 'Number', ''
			UNION
			SELECT 'Currency', 'Currency', ''
			UNION
			SELECT 'Decimal', 'Decimal', ''
			UNION
			SELECT 'Boolean', 'Boolean', ''
			UNION
			SELECT 'Course Type - Single Select', 'CourseType', 'CourseTypeId'
			UNION
			SELECT 'Course Type Category - Single Select', 'CourseTypeCategory', 'CourseTypeCategoryId'
			UNION
			SELECT 'Payment Method - Single Select', 'PaymentMethod', 'PaymentMethodId'
			UNION
			SELECT 'Payment Type - Single Select', 'PaymentType', 'PaymentTypeId'
			UNION
			SELECT 'Payment Provider - Single Select', 'PaymentProvider', 'PaymentProviderId'
			UNION
			SELECT 'Course Type - Multiple Select', 'CourseTypeMultiple', 'CourseTypeId'
			UNION
			SELECT 'Course Type Category - Multiple Select', 'CourseTypeCategoryMultiple', 'CourseTypeCategoryId'
			UNION
			SELECT 'Payment Method - Multiple Select', 'PaymentMethodMultiple', 'PaymentMethodId'
			UNION
			SELECT 'Payment Type - Multiple Select', 'PaymentTypeMultiple', 'PaymentTypeId'
			UNION
			SELECT 'Payment Provider - Multiple Select', 'PaymentProviderMultiple', 'PaymentProviderId'
			UNION
			SELECT 'Venue - Multiple Select', 'VenueMultiple', 'VenueId'
			UNION
			SELECT 'Venue - Single Select', 'VenueSingle', 'VenueId'
			UNION
			SELECT 'Trainer - Multiple Select', 'TrainerMultiple', 'TrainerId'
			UNION
			SELECT 'Trainer - Single Select', 'TrainerSingle', 'TrainerId'
			UNION
			SELECT 'Referring Authority - Multiple Select', 'ReferringAuthorityMultiple', 'ReferringAuthorityId'
			UNION
			SELECT 'Referring Authority - Single Select', 'ReferringAuthoritySingle', 'ReferringAuthorityId'
			UNION
			SELECT 'Course List: Recent and Future - Single Select', 'CoursesRecentFutureSingle', 'CourseId'
			UNION
			SELECT 'Course List: Past Courses - Single Select', 'CoursesPastSingle', 'CourseId'
			) ReportDataTypeInfo

		--SET IDENTITY_INSERT dbo.ReportDataType ON;
		INSERT INTO dbo.ReportDataType(Title, DataTypeName)
		SELECT DISTINCT Title, DataTypeName
		FROM #ReportDataTypeInsert RDTI
		WHERE NOT EXISTS (SELECT *
							FROM dbo.ReportDataType RDT
							WHERE RDT.DataTypeName = RDTI.DataTypeName);
		--SET IDENTITY_INSERT dbo.ReportDataType OFF;

		UPDATE RDT
		SET RDT.Title = RDTI.Title
		FROM #ReportDataTypeInsert RDTI
		INNER JOIN dbo.ReportDataType RDT ON RDT.DataTypeName = RDTI.DataTypeName
		WHERE RDT.Title != RDTI.Title;

		INSERT INTO dbo.ReportDataTypeSelectIdentifier (ReportDataTypeId, SelectIdentifier)
		SELECT DISTINCT RDT.Id AS ReportDataTypeId, RDTI.SelectIdentifier AS SelectIdentifier
		FROM #ReportDataTypeInsert RDTI
		INNER JOIN dbo.ReportDataType RDT ON RDT.DataTypeName = RDTI.DataTypeName
		LEFT JOIN dbo.ReportDataTypeSelectIdentifier RDTSI ON RDTSI.ReportDataTypeId = RDT.Id
															AND RDTSI.SelectIdentifier = RDTI.SelectIdentifier
		WHERE LEN(ISNULL(RDTI.SelectIdentifier,'')) > 0
		AND RDTSI.Id IS NULL;

	END

	-- SMS Message Tag
	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - SMS Message Tag';
	BEGIN
		PRINT('');PRINT('*SMS Message Tag');
		IF OBJECT_ID('tempdb..#SMSMessageTag', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #SMSMessageTag;
		END

		DBCC CHECKIDENT (SMSMessageTag, RESEED, 0);

		SELECT DISTINCT Name, Description, AverageSize
		INTO #SMSMessageTag
		FROM (
				SELECT 'Client Name' AS Name, 'Client Name' AS Description, 20 AS AverageSize
				UNION
				SELECT 'Course Type' AS Name, 'Course Type' AS Description, 32 AS AverageSize
				UNION
				SELECT 'Course Date' AS Name, 'Course Date' AS Description, 11 AS AverageSize
				UNION
				SELECT 'Course Date & Time' AS Name, 'Course Date & Time' AS Description, 16 AS AverageSize
				UNION
				SELECT 'Date' AS Name, 'The Current Date' AS Description, 11 AS AverageSize
				UNION
				SELECT 'Date Time' AS Name, 'The Current Date and Time' AS Description, 16 AS AverageSize
				) SMT

		INSERT INTO dbo.SMSMessageTag (Name, Description, AverageSize)
		SELECT DISTINCT Name, Description, AverageSize
		FROM #SMSMessageTag NewSMT
		WHERE NOT EXISTS (SELECT * FROM dbo.SMSMessageTag SMT WHERE NewSMT.Name = SMT.Name)
	END

	-- Dashboard Meters
	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - Dashboard Meters';
	BEGIN
		PRINT('');PRINT('*Dashboard Meters');
		IF OBJECT_ID('tempdb..#DashboardMeter', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #DashboardMeter;
		END

		INSERT INTO DashboardMeterCategory ([Name], PictureName, DefaultCategory)
		SELECT [Name], PictureName, DefaultCategory
		FROM (SELECT 'Payments' AS [Name], 'payment.png' AS PictureName, 'False' AS DefaultCategory
			UNION SELECT 'Clients' AS [Name], 'clients.png' AS PictureName, 'False' AS DefaultCategory
			UNION SELECT 'Courses' AS [Name], 'courses.png' AS PictureName, 'False' AS DefaultCategory
			UNION SELECT 'Email' AS [Name], 'email.png' AS PictureName, 'False' AS DefaultCategory
			UNION SELECT 'Documents' AS [Name], 'documents.png' AS PictureName, 'False' AS DefaultCategory
			UNION SELECT 'Other' AS [Name], 'other.png' AS PictureName, 'True' AS DefaultCategory
			UNION SELECT 'Speed' AS [Name], 'speed.png' AS PictureName, 'True' AS DefaultCategory
			UNION SELECT 'TimeUp' AS [Name], 'timeup.png' AS PictureName, 'True' AS DefaultCategory
			UNION SELECT 'DORS' AS [Name], 'timeup.png' AS PictureName, 'True' AS DefaultCategory
			) DMC
		WHERE NOT EXISTS (SELECT * FROM DashboardMeterCategory DMC2 WHERE DMC2.[Name] = DMC.[Name]);

		DECLARE @DrilldownInformation VARCHAR(200) = @NewLine + @NewLine + 'This Meter also allows you to drill down into the summary data to see where the data has come from.';
		SELECT Name, Title, [Description], RefreshRate, AssignToAllSystemsAdmins, AssignAllOrganisationAdmin, AssignWholeOrganisation, ExcludeReferringAuthorityOrganisation, ExcludeTrainers, DashboardMeterCategoryId
		INTO #DashboardMeter
		FROM (
			SELECT
				'Payments' AS [Name]
				, 'Payments' AS [Title]
				, 'The Payments Meter will provide summary information on recorded payments split by "Online", "Unallocated" and "Refunded"' + @DrilldownInformation AS [Description]
				, 120 AS [RefreshRate]
				, 'True' AS AssignToAllSystemsAdmins
				, 'True' AS AssignAllOrganisationAdmin
				, 'False' AS AssignWholeOrganisation
				, 'True' AS ExcludeReferringAuthorityOrganisation
				, 'True' AS ExcludeTrainers
				, (SELECT TOP 1 Id FROM DashboardMeterCategory WHERE [Name] = 'Payments') AS DashboardMeterCategoryId
			UNION
			SELECT
				'Clients' AS [Name]
				, 'Clients' AS [Title]
				, 'The Clients Meter provides information on Registration counts and the number of unpaid courses.' + @DrilldownInformation AS [Description]
				, 120 AS [RefreshRate]
				, 'True' AS AssignToAllSystemsAdmins
				, 'True' AS AssignAllOrganisationAdmin
				, 'False' AS AssignWholeOrganisation
				, 'True' AS ExcludeReferringAuthorityOrganisation
				, 'True' AS ExcludeTrainers
				, (SELECT TOP 1 Id FROM DashboardMeterCategory WHERE [Name] = 'Clients') AS DashboardMeterCategoryId
			UNION
			SELECT
				'Courses' AS [Name]
				,'Courses' AS [Title]
				,'The Courses Meter provides information on the number of Course Attendances which are due'
					+ ', how many Attendance Verifications are due and provides summary of Outstanding Amounts' + @DrilldownInformation AS [Description]
				, 120 AS [RefreshRate]
				, 'True' AS AssignToAllSystemsAdmins
				, 'True' AS AssignAllOrganisationAdmin
				, 'False' AS AssignWholeOrganisation
				, 'True' AS ExcludeReferringAuthorityOrganisation
				, 'True' AS ExcludeTrainers
				, (SELECT TOP 1 Id FROM DashboardMeterCategory WHERE [Name] = 'Courses') AS DashboardMeterCategoryId
			UNION
			SELECT
				'Email' AS [Name]
				,'Email' AS [Title]
				,'The Email Meter allows you to keep an eye on the number of emails the System is sending on your Organisations behalf.' AS [Description]
				, 120 AS [RefreshRate]
				, 'True' AS AssignToAllSystemsAdmins
				, 'True' AS AssignAllOrganisationAdmin
				, 'False' AS AssignWholeOrganisation
				, 'True' AS ExcludeReferringAuthorityOrganisation
				, 'True' AS ExcludeTrainers
				, (SELECT TOP 1 Id FROM DashboardMeterCategory WHERE [Name] = 'Email') AS DashboardMeterCategoryId
			UNION
			SELECT
				'Documents' AS [Name]
				,'Documents' AS [Title]
				,'This Meter provides information on the Document within the System. It will show how many exist and how much space they are using.' AS [Description]
				, 120 AS [RefreshRate]
				, 'True' AS AssignToAllSystemsAdmins
				, 'True' AS AssignAllOrganisationAdmin
				, 'False' AS AssignWholeOrganisation
				, 'True' AS ExcludeReferringAuthorityOrganisation
				, 'True' AS ExcludeTrainers
				, (SELECT TOP 1 Id FROM DashboardMeterCategory WHERE [Name] = 'Documents') AS DashboardMeterCategoryId
			UNION
			SELECT
				'SystemDocuments' AS [Name]
				,'SystemDocuments' AS [Title]
				,'This Meter will provide information on the use of Document throughout the Atlas System.' AS [Description]
				, 120 AS [RefreshRate]
				, 'True' AS AssignToAllSystemsAdmins
				, 'False' AS AssignAllOrganisationAdmin
				, 'False' AS AssignWholeOrganisation
				, 'True' AS ExcludeReferringAuthorityOrganisation
				, 'True' AS ExcludeTrainers
				, (SELECT TOP 1 Id FROM DashboardMeterCategory WHERE [Name] = 'Documents') AS DashboardMeterCategoryId
			UNION
			SELECT
				'DORSOfferWithdrawn' AS [Name]
				,'DORS Withdrawn Offers' AS [Title]
				,'This Meter will provide summary information DORS Offers which have been Withdrawn.' + @DrilldownInformation AS [Description]
				, 120 AS [RefreshRate]
				, 'True' AS AssignToAllSystemsAdmins
				, 'True' AS AssignAllOrganisationAdmin
				, 'False' AS AssignWholeOrganisation
				, 'True' AS ExcludeReferringAuthorityOrganisation
				, 'True' AS ExcludeTrainers
				, (SELECT TOP 1 Id FROM DashboardMeterCategory WHERE [Name] = 'DORS') AS DashboardMeterCategoryId
			) DashboardMeter
		;

		INSERT INTO dbo.DashboardMeter(
				[Name]
				, [Title]
				, [Description]
				, [RefreshRate]
				, [DashboardMeterCategoryId]
				, [AssignToAllSystemsAdmins]
				, [AssignAllOrganisationAdmin]
				, [AssignWholeOrganisation]
				, [ExcludeReferringAuthorityOrganisation]
				, [ExcludeTrainers]
				)
		SELECT
				[Name]
				, [Title]
				, [Description]
				, [RefreshRate]
				, [DashboardMeterCategoryId]
				, [AssignToAllSystemsAdmins]
				, [AssignAllOrganisationAdmin]
				, [AssignWholeOrganisation]
				, [ExcludeReferringAuthorityOrganisation]
				, [ExcludeTrainers]
		FROM #DashboardMeter NewDM
		WHERE NOT EXISTS (SELECT *
							FROM dbo.DashboardMeter DM
							WHERE DM.[Name] = NewDM.[Name]);

		--Endure that the Titles, Descriptions and RefreshRates are up-to-date
		UPDATE DM
		SET DM.[Title] = NewDM.[Title]
		, DM.[Description] = NewDM.[Description]
		, DM.[RefreshRate] = NewDM.[RefreshRate]
		, DM.[DashboardMeterCategoryId] = NewDM.[DashboardMeterCategoryId]
		, DM.[AssignToAllSystemsAdmins] = NewDM.[AssignToAllSystemsAdmins]
		, DM.[AssignAllOrganisationAdmin] = NewDM.[AssignAllOrganisationAdmin]
		, DM.[AssignWholeOrganisation] = NewDM.[AssignWholeOrganisation]
		, DM.[ExcludeReferringAuthorityOrganisation] = NewDM.[ExcludeReferringAuthorityOrganisation]
		, DM.[ExcludeTrainers] = NewDM.[ExcludeTrainers]
		FROM DashboardMeter DM
		INNER JOIN #DashboardMeter NewDM ON NewDM.[Name] = DM.[Name]
		WHERE DM.[Title] != NewDM.[Title] OR DM.[Title] IS NULL
		OR DM.[Description] != NewDM.[Description] OR DM.[Description] IS NULL
		OR DM.[RefreshRate] != NewDM.[RefreshRate] OR DM.[RefreshRate] IS NULL
		OR DM.[DashboardMeterCategoryId] != NewDM.[DashboardMeterCategoryId] OR DM.[DashboardMeterCategoryId] IS NULL
		OR DM.[AssignToAllSystemsAdmins] != NewDM.[AssignToAllSystemsAdmins] OR DM.[AssignToAllSystemsAdmins] IS NULL
		OR DM.[AssignAllOrganisationAdmin] != NewDM.[AssignAllOrganisationAdmin] OR DM.[AssignAllOrganisationAdmin] IS NULL
		OR DM.[AssignWholeOrganisation] != NewDM.[AssignWholeOrganisation] OR DM.[AssignWholeOrganisation] IS NULL
		OR DM.[ExcludeReferringAuthorityOrganisation] != NewDM.[ExcludeReferringAuthorityOrganisation] OR DM.[ExcludeReferringAuthorityOrganisation] IS NULL
		OR DM.[ExcludeTrainers] != NewDM.[ExcludeTrainers] OR DM.[ExcludeTrainers] IS NULL;

		--ENSURE All Current System Administrators Have all Meters
		--ENSURE All Current Organisation Administrators Have Certain Meters
		EXEC dbo.uspEnsureDefaultMeterAssignments;

	END

	--Setup Existing Payment Card Suppliers and their Providers
	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - Setup Existing Payment Card Suppliers and their Providers';
	BEGIN
		PRINT('');PRINT('*Setup Existing Payment Card Suppliers and their Providers');
		IF OBJECT_ID('tempdb..#PaymentCardSupplierProvider', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #PaymentCardSupplierProvider;
		END

		SELECT DISTINCT Supplier, Provider
		INTO #PaymentCardSupplierProvider
		FROM (
			SELECT  'ActionAid' AS Supplier, 'The Co-operative Bank' AS Provider
			UNION
			SELECT  'Albion (West Bromwich Albion FC)' AS Supplier, 'Creation Financial Services' AS Provider
			UNION
			SELECT  'American Airlines' AS Supplier, 'MBNA Limited' AS Provider
			UNION
			SELECT  'American Express' AS Supplier, 'American Express' AS Provider
			UNION
			SELECT  'Amnesty International' AS Supplier, 'The Co-operative Bank' AS Provider
			UNION
			SELECT  'aqua' AS Supplier, 'NewDay Ltd' AS Provider
			UNION
			SELECT  'Argos' AS Supplier, 'Vanquis Bank' AS Provider
			UNION
			SELECT  'Arsenal FC' AS Supplier, 'MBNA Limited' AS Provider
			UNION
			SELECT  'ASDA' AS Supplier, 'ASDA Money' AS Provider
			UNION
			SELECT  'Aston Villa FC' AS Supplier, 'MBNA Limited' AS Provider
			UNION
			SELECT  'British Airways' AS Supplier, 'American Express' AS Provider
			UNION
			SELECT  'Bank of China UK' AS Supplier, 'Bank of China UK' AS Provider
			UNION
			SELECT  'Bank of Ireland (UK)' AS Supplier, 'Bank of Ireland (UK)' AS Provider
			UNION
			SELECT  'Bank of Scotland' AS Supplier, 'Bank of Scotland' AS Provider
			UNION
			SELECT  'Barclaycard' AS Supplier, 'Barclaycard' AS Provider
			UNION
			SELECT  'Black Diamond ' AS Supplier, 'Vanquis bank' AS Provider
			UNION
			SELECT  'Born Free' AS Supplier, 'MBNA Limited' AS Provider
			UNION
			SELECT  'Breakthrough Breast Cancer' AS Supplier, 'MBNA Limited' AS Provider
			UNION
			SELECT  'British Heart Foundation' AS Supplier, 'MBNA Limited' AS Provider
			UNION
			SELECT  'Burton' AS Supplier, 'NewDay Ltd' AS Provider
			UNION
			SELECT  'C. Hoare & Co' AS Supplier, 'C. Hoare & Co' AS Provider
			UNION
			SELECT  'CAFOD' AS Supplier, 'The Co-operative Bank' AS Provider
			UNION
			SELECT  'Capital One Bank' AS Supplier, 'Capital One Bank' AS Provider
			UNION
			SELECT  'Cats Protection' AS Supplier, 'MBNA Limited' AS Provider
			UNION
			SELECT  'Chelsea FC' AS Supplier, 'MBNA Limited' AS Provider
			UNION
			SELECT  'Christian Aid' AS Supplier, 'The Co-operative Bank' AS Provider
			UNION
			SELECT  'Clydesdale Bank' AS Supplier, 'Clydesdale Bank' AS Provider
			UNION
			SELECT  'Coutts & Co' AS Supplier, 'Coutts & Co' AS Provider
			UNION
			SELECT  'Creation Financial Services' AS Supplier, 'Creation Financial Services' AS Provider
			UNION
			SELECT  'Danske Bank ' AS Supplier, 'Danske Bank' AS Provider
			UNION
			SELECT  'Debenhams' AS Supplier, 'NewDay Ltd' AS Provider
			UNION
			SELECT  'Dogs Trust' AS Supplier, 'MBNA Limited' AS Provider
			UNION
			SELECT  'Dorothy Perkins ' AS Supplier, 'NewDay Ltd' AS Provider
			UNION
			SELECT  'Emirates Skyward ' AS Supplier, 'MBNA Limited' AS Provider
			UNION
			SELECT  'Etihad' AS Supplier, 'MBNA Limited' AS Provider
			UNION
			SELECT  'Evans' AS Supplier, 'NewDay Ltd' AS Provider
			UNION
			SELECT  'Everton FC' AS Supplier, 'Creation Financial Services' AS Provider
			UNION
			SELECT  'first direct' AS Supplier, 'First Direct' AS Provider
			UNION
			SELECT  'First Trust Bank (NI)' AS Supplier, 'First Trust Bank (NI)' AS Provider
			UNION
			SELECT  'Fluid' AS Supplier, 'MBNA Limited' AS Provider
			UNION
			SELECT  'Flybe' AS Supplier, 'Creation Financial Services' AS Provider
			UNION
			SELECT  'Friends of the Earth' AS Supplier, 'The Co-operative Bank' AS Provider
			UNION
			SELECT  'Fulham FC' AS Supplier, 'Creation Financial Services' AS Provider
			UNION
			SELECT  'Glasgow Calendonian University ' AS Supplier, 'MBNA Limited' AS Provider
			UNION
			SELECT  'granite' AS Supplier, 'Vanquis Bank' AS Provider
			UNION
			SELECT  'Great Ormond Street' AS Supplier, 'MBNA Limited' AS Provider
			UNION
			SELECT  'Greenpeace' AS Supplier, 'The Co-operative Bank' AS Provider
			UNION
			SELECT  'Guide Dogs for the Blind' AS Supplier, 'MBNA Limited' AS Provider
			UNION
			SELECT  'Halifax ' AS Supplier, 'Bank of Scotland' AS Provider
			UNION
			SELECT  'Help the Hospices' AS Supplier, 'The Co-operative Bank' AS Provider
			UNION
			SELECT  'Hilton HHonors' AS Supplier, 'Barclaycard' AS Provider
			UNION
			SELECT  'House of Fraser' AS Supplier, 'NewDay Ltd' AS Provider
			UNION
			SELECT  'HSBC' AS Supplier, 'HSBC' AS Provider
			UNION
			SELECT  'John Lewis Financial Services' AS Supplier, 'John Lewis Financial Services' AS Provider
			UNION
			SELECT  'Labour Party' AS Supplier, 'The Co-operative Bank' AS Provider
			UNION
			SELECT  'Laura Ashley' AS Supplier, 'NewDay Ltd' AS Provider
			UNION
			SELECT  'Liberal Democrat Party' AS Supplier, 'The Co-Operative Bank' AS Provider
			UNION
			SELECT  'Liverpool FC' AS Supplier, 'MBNA Limited' AS Provider
			UNION
			SELECT  'Lloyds Bank ' AS Supplier, 'Lloyds Bank' AS Provider
			UNION
			SELECT  'Manchester United FC' AS Supplier, 'MBNA Limited' AS Provider
			UNION
			SELECT  'M&S Bank' AS Supplier, 'M&S Bank' AS Provider
			UNION
			SELECT  'Maximiles' AS Supplier, 'Creation Financial Services' AS Provider
			UNION
			SELECT  'Mencap' AS Supplier, 'MBNA Limited' AS Provider
			UNION
			SELECT  'Metro Bank' AS Supplier, 'Metro Bank' AS Provider
			UNION
			SELECT  'Miles & More' AS Supplier, 'MBNA Limited' AS Provider
			UNION
			SELECT  'National Trust' AS Supplier, 'MBNA Limited' AS Provider
			UNION
			SELECT  'Nationwide BS' AS Supplier, 'Nationwide BS' AS Provider
			UNION
			SELECT  'NatWest' AS Supplier, 'NatWest' AS Provider
			UNION
			SELECT  'Danske Bank' AS Supplier, 'Danske Bank' AS Provider
			UNION
			SELECT  'Norwich & Peterborough BS' AS Supplier, 'MBNA Limited' AS Provider
			UNION
			SELECT  'Ocean Credit ' AS Supplier, 'Capital One' AS Provider
			UNION
			SELECT  'Outfit' AS Supplier, 'NewDay Ltd' AS Provider
			UNION
			SELECT  'Owls (Sheffield Wednesday FC)' AS Supplier, 'Creation Financial Services' AS Provider
			UNION
			SELECT  'Oxfam' AS Supplier, 'The Co-operative Bank' AS Provider
			UNION
			SELECT  'PDSA' AS Supplier, 'MBNA Limited' AS Provider
			UNION
			SELECT  'Post Office Money' AS Supplier, 'Bank of Ireland (UK)' AS Provider
			UNION
			SELECT  'Rams (Derby County FC)' AS Supplier, 'Creation Financial Services' AS Provider
			UNION
			SELECT  'Rangers FC' AS Supplier, 'MBNA Limited' AS Provider
			UNION
			SELECT  'Rotary Club' AS Supplier, 'MBNA Limited' AS Provider
			UNION
			SELECT  'Royal Bank of Scotland' AS Supplier, 'Royal Bank of Scotland' AS Provider
			UNION
			SELECT  'The Royal British Legion' AS Supplier, 'MBNA Limited' AS Provider
			UNION
			SELECT  'RSPB' AS Supplier, 'The Co-operative Bank' AS Provider
			UNION
			SELECT  'RSPCA' AS Supplier, 'MBNA Limited' AS Provider
			UNION
			SELECT  'Ryanair' AS Supplier, 'NewDay Ltd' AS Provider
			UNION
			SELECT  'SAGA' AS Supplier, 'SAGA' AS Provider
			UNION
			SELECT  'Sainsbury''s Bank' AS Supplier, 'Sainsbury''s Bank' AS Provider
			UNION
			SELECT  'Santander' AS Supplier, 'Santander' AS Provider
			UNION
			SELECT  'Save the Children' AS Supplier, 'The Co-operative Bank' AS Provider
			UNION
			SELECT  'Shelter' AS Supplier, 'The Co-operative Bank' AS Provider
			UNION
			SELECT  'Smile' AS Supplier, 'The Co-operative Bank' AS Provider
			UNION
			SELECT  'Starwood ' AS Supplier, 'American Express' AS Provider
			UNION
			SELECT  'Tearfund' AS Supplier, 'The Co-operative Bank' AS Provider
			UNION
			SELECT  'Tesco Bank' AS Supplier, 'Tesco Bank' AS Provider
			UNION
			SELECT  'Tottenham Hotspur FC' AS Supplier, 'MBNA Limited' AS Provider
			UNION
			SELECT  'The Co-operative Bank' AS Supplier, 'The Co-operative Bank' AS Provider
			UNION
			SELECT  'tsb' AS Supplier, 'tsb' AS Provider
			UNION
			SELECT  'Ulster Bank' AS Supplier, 'Ulster Bank' AS Provider
			UNION
			SELECT  'United Airlines' AS Supplier, 'MBNA Limited' AS Provider
			UNION
			SELECT  'Vanquis Bank' AS Supplier, 'Vanquis Bank' AS Provider
			UNION
			SELECT  'Very' AS Supplier, 'Capital One Bank' AS Provider
			UNION
			SELECT  'Virgin Atlantic' AS Supplier, 'MBNA Limited' AS Provider
			UNION
			SELECT  'Virgin Money' AS Supplier, 'Virgin Money' AS Provider
			UNION
			SELECT  'Water Aid' AS Supplier, 'The Co-operative Bank' AS Provider
			UNION
			SELECT  'West Ham United FC' AS Supplier, 'MBNA Limited' AS Provider
			UNION
			SELECT  'Woodland Trust' AS Supplier, 'The Co-operative Bank' AS Provider
			UNION
			SELECT  'Wolves (Wolverhampton Wanderers FC)' AS Supplier, 'Creation Financial Services' AS Provider
			UNION
			SELECT  'WWF' AS Supplier, 'MBNA Limited' AS Provider
			UNION
			SELECT  'Yorkshire Bank' AS Supplier, 'Yorkshire Bank' AS Provider
			UNION
			SELECT  '*UNKNOWN*' AS Supplier, '*UNKNOWN*' AS Provider
			) AS SP

		--Ensure Providers Exist
		INSERT INTO [dbo].[PaymentCardProvider] (Name)
		SELECT DISTINCT NewPCSP.Provider AS Name
		FROM #PaymentCardSupplierProvider NewPCSP
		WHERE NOT EXISTS (SELECT *
							FROM [dbo].[PaymentCardProvider] PCP
							WHERE PCP.[Name] = NewPCSP.Provider)

		--INSERT Suppliers Linked to Providers
		INSERT INTO [dbo].[PaymentCardSupplier] (Name, Disabled, PaymentCardProviderId)
		SELECT DISTINCT NewPCSP.Supplier AS Name, 'False' AS Disabled, PCP.Id AS PaymentCardProviderId
		FROM [dbo].[PaymentCardProvider] PCP
		INNER JOIN #PaymentCardSupplierProvider NewPCSP ON PCP.[Name] = NewPCSP.Provider
		WHERE NOT EXISTS (SELECT *
							FROM [dbo].[PaymentCardSupplier] PCS
							WHERE PCS.[Name] = NewPCSP.Supplier)
	END

	----- Adds data to DORSControl - only one record will be on this table.
	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - Adds data to DORSControl';
	BEGIN
		PRINT('');PRINT('*Adds data to DORSControl - only one record will be on this table');

		BEGIN
			IF OBJECT_ID('tempdb..#DORSControl', 'U') IS NOT NULL
			BEGIN
				DROP TABLE #DORSControl;
			END

			SELECT 1 AS Id
				, 'True' AS DORSEnabled
				, 36 AS PasswordExpiryDays
				, (SELECT TOP 1 Id FROM [DORSState] WHERE Name = 'Unknown') AS DORSStateId
				, 100 AS MaximumPostsPerSession
			INTO #DORSControl;

			INSERT INTO DORSControl (Id, DORSEnabled, PasswordExpiryDays, DORSStateId, MaximumPostsPerSession)
			SELECT Id, DORSEnabled, PasswordExpiryDays, DORSStateId, MaximumPostsPerSession
			FROM #DORSControl
			WHERE NOT EXISTS (SELECT * FROM DORSControl WHERE Id = 1);

			UPDATE DC
				SET DC.DORSEnabled = (CASE WHEN DC.DORSEnabled IS NULL THEN DC2.DORSEnabled ELSE DC.DORSEnabled END)
				, DC.PasswordExpiryDays = (CASE WHEN DC.PasswordExpiryDays IS NULL THEN DC2.PasswordExpiryDays ELSE DC.PasswordExpiryDays END)
				, DC.DORSStateId = (CASE WHEN DC.DORSStateId IS NULL THEN DC2.DORSStateId ELSE DC.DORSStateId END)
				, DC.MaximumPostsPerSession = (CASE WHEN DC.MaximumPostsPerSession IS NULL THEN DC2.MaximumPostsPerSession ELSE DC.MaximumPostsPerSession END)
			FROM DORSControl DC
			INNER JOIN #DORSControl DC2 ON DC2.Id = DC.Id
			WHERE DC.Id = 1;
		END
	END

	-- EmailService
	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - EmailService';
	BEGIN
		PRINT('');PRINT('*EmailService');
		IF OBJECT_ID('tempdb..#EmailService', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #EmailService;
		END

		SELECT [Name], [Server]
		INTO #EmailService
		FROM (
			SELECT 'TotalSend' AS [Name], 'Atlas' AS [Server]
			UNION SELECT 'MailGun' AS [Name], 'Atlas' AS [Server]
			UNION SELECT 'Mandrill' AS [Name], 'Atlas' AS [Server]
			UNION SELECT 'SparkPost' AS [Name], 'Atlas' AS [Server]
			UNION SELECT 'SendInBlue' AS [Name], 'Atlas' AS [Server]
			UNION SELECT 'SendGrid' AS [Name], 'Atlas' AS [Server]
			UNION SELECT 'MailJet' AS [Name], 'Atlas' AS [Server]
			) EmailService

		INSERT INTO dbo.EmailService([Name], [Server], DateUpdated, UpdatedByUserId)
		SELECT [Name], [Server], GetDate() AS DateUpdated, [dbo].[udfGetSystemUserId]() AS UpdatedByUserId
		FROM #EmailService NewES
		WHERE NOT EXISTS (SELECT *
							FROM dbo.EmailService ES
							WHERE ES.[Name] = NewES.[Name]);

		--Endure that the [Server] is up-to-date
		UPDATE ES
		SET ES.[Server] = NewES.[Server]
		, DateUpdated = GetDate()
		, UpdatedByUserId = [dbo].[udfGetSystemUserId]()
		FROM EmailService ES
		INNER JOIN #EmailService NewES ON NewES.[Name] = ES.[Name]
		WHERE ES.[Server] != NewES.[Server];

		--Update EmailServiceCredential
		IF OBJECT_ID('tempdb..#EmailServiceCredential', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #EmailServiceCredential;
		END

		SELECT [EmailServiceId], [Key], [Value]
		INTO #EmailServiceCredential
		FROM (
				SELECT ES.Id AS [EmailServiceId], 'url' AS [Key], 'https://transactional.totalsend.com/SendMessage' AS [Value]
				FROM [dbo].[EmailService] ES
				WHERE ES.[Name] = 'TotalSend'
				UNION SELECT ES.Id AS [EmailServiceId], 'UserName' AS [Key], 'mike.jones@iam.org.uk' AS [Value]
				FROM [dbo].[EmailService] ES
				WHERE ES.[Name] = 'TotalSend'
				UNION SELECT ES.Id AS [EmailServiceId], 'APIKey' AS [Key], '6v0-jdOk-0K4J-RuDf-eFKr-M8tL' AS [Value]
				FROM [dbo].[EmailService] ES
				WHERE ES.[Name] = 'TotalSend'
				UNION SELECT ES.Id AS [EmailServiceId], 'url' AS [Key], 'https://api.mailgun.net/v3/iamroadsmart.com/messages' AS [Value]
				FROM [dbo].[EmailService] ES
				WHERE ES.[Name] = 'MailGun'
				UNION SELECT ES.Id AS [EmailServiceId], 'api' AS [Key], 'key-67ac75d750257f6c3c5d6e6290199539' AS [Value]
				FROM [dbo].[EmailService] ES
				WHERE ES.[Name] = 'MailGun'
				UNION SELECT ES.Id AS [EmailServiceId], 'domain' AS [Key], 'iamroadsmart.com' AS [Value]
				FROM [dbo].[EmailService] ES
				WHERE ES.[Name] = 'MailGun'
				UNION SELECT ES.Id AS [EmailServiceId], 'APIKey' AS [Key], '682ca9e8d935bc746a10f3f7d82d517bec121551' AS [Value]
				FROM [dbo].[EmailService] ES
				WHERE ES.[Name] = 'SparkPost'
				UNION SELECT ES.Id AS [EmailServiceId], 'url' AS [Key], 'https://sparkpost.com' AS [Value]
				FROM [dbo].[EmailService] ES
				WHERE ES.[Name] = 'SparkPost'
				UNION SELECT ES.Id AS [EmailServiceId], 'apiKey' AS [Key], 'EPVFQN5m1BHqXd70' AS [Value]
				FROM [dbo].[EmailService] ES
				WHERE ES.[Name] = 'SendInBlue'
				UNION SELECT ES.Id AS [EmailServiceId], 'url' AS [Key], 'https://api.sendinblue.com/v2.0/email' AS [Value]
				FROM [dbo].[EmailService] ES
				WHERE ES.[Name] = 'SendInBlue'
				UNION SELECT ES.Id AS [EmailServiceId], 'apiKey' AS [Key], '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' AS [Value]
				FROM [dbo].[EmailService] ES
				WHERE ES.[Name] = 'SendGrid'
				UNION SELECT ES.Id AS [EmailServiceId], 'url' AS [Key], 'https://sendgrid.com' AS [Value]
				FROM [dbo].[EmailService] ES
				WHERE ES.[Name] = 'SendGrid'
				UNION SELECT ES.Id AS [EmailServiceId], 'publicAPIKey' AS [Key], 'dd26924d7e80b2bc3fd9638045892778' AS [Value]
				FROM [dbo].[EmailService] ES
				WHERE ES.[Name] = 'MailJet'
				UNION SELECT ES.Id AS [EmailServiceId], 'privateAPIKey' AS [Key], 'f9f8680339ef396bfbc40f28c40cdd64' AS [Value]
				FROM [dbo].[EmailService] ES
				WHERE ES.[Name] = 'MailJet'
				UNION SELECT ES.Id AS [EmailServiceId], 'url' AS [Key], 'https://api.mailjet.com/v3/REST/send' AS [Value]
				FROM [dbo].[EmailService] ES
				WHERE ES.[Name] = 'MailJet'
				) EmailServiceCredential;


		INSERT INTO [dbo].[EmailServiceCredential] ([EmailServiceId], [Key], [Value], DateUpdated, UpdatedByUserId)
		SELECT NewESC.[EmailServiceId], NewESC.[Key], NewESC.[Value], GetDate() AS DateUpdated, [dbo].[udfGetSystemUserId]() AS UpdatedByUserId
		FROM #EmailServiceCredential NewESC
		LEFT JOIN EmailServiceCredential ESC ON ESC.[EmailServiceId] = NewESC.[EmailServiceId]
											AND ESC.[Key] = NewESC.[Key]
		WHERE ESC.[Id] IS NULL;

		UPDATE ESC
		SET ESC.[Value] = NewESC.[Value]
		, DateUpdated = GetDate()
		, UpdatedByUserId = [dbo].[udfGetSystemUserId]()
		FROM EmailServiceCredential ESC
		INNER JOIN #EmailServiceCredential NewESC ON NewESC.[EmailServiceId] = ESC.[EmailServiceId]
													AND NewESC.[Key] = ESC.[Key]
		WHERE ESC.[Value] != NewESC.[Value];
	END


	/* Ensures required rows are in "SystemTask" table */
	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - SystemTask';
	BEGIN
		PRINT('');PRINT('*Ensures required rows are in "SystemTask" table');

		IF OBJECT_ID('tempdb..#SystemTask', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #SystemTask;
		END

		SELECT *
		INTO #SystemTask
		FROM (
			SELECT
				'DOCS_NotifyDocumentMarkedForDelete' AS [Name]
				, 'Notification of Documents Marked For Delete' AS Title
				, 'Every Document that is marked for deletion System Support Users will be Notified.' AS [Description]
				, 'This is a Trigger on table DocumentMarkedForDelete' AS DevelopersNotes
				, 'Email System Support Users' AS EmailOptionCaption
				, 'Send an Internal Message to System Support Users' AS InternalMessageOptionCaption
			UNION SELECT
				'COURSE_MonitorCourseOverBookings' AS [Name]
				, 'Monitor Courses for Over Bookings' AS Title
				, 'The System will be monitored for Courses that have been Over Booked. An appropriate message will be sent.' AS [Description]
				, 'This is done in SP uspMonitorCourseBookings. Which is called by the Scheduler via the Web Service.' AS DevelopersNotes
				, 'Email System Support Users' AS EmailOptionCaption
				, 'Send an Internal Message to System Support Users' AS InternalMessageOptionCaption
			UNION SELECT
				'CLIENT_MonitorClientsWithSpecialRequirements' AS [Name]
				, 'Monitor new Client Courses for Additional Requirements' AS Title
				, 'The System will be monitored for Client bookings on Courses with Additional Requirements.' AS [Description]
				, 'This is done as part of a Trigger in table ClientSpecialRequirement' AS DevelopersNotes
				, 'Email System Support Users' AS EmailOptionCaption
				, 'Send an Internal Message to System Support Users' AS InternalMessageOptionCaption
			UNION SELECT
				'EMAIL_MultipleEmailSendFailure' AS [Name]
				, 'Send Messages about Multiple Email Send Failure' AS Title
				, 'The System disables Emails which have Multiple Send Failures (usually three)' AS [Description]
				, 'This is done as part of a Trigger in table ScheduledEmail' AS DevelopersNotes
				, 'Email System Support Users' AS EmailOptionCaption
				, 'Send an Internal Message to System Support Users' AS InternalMessageOptionCaption
			) T
		;

		INSERT INTO dbo.SystemTask (
								[Name]
								, Title
								, [Description]
								, DevelopersNotes
								, EmailOptionCaption
								, InternalMessageOptionCaption
								, [Disabled]
								, DateCreated
								)
		SELECT
			TST.[Name]
			, TST.Title
			, TST.[Description]
			, TST.DevelopersNotes
			, TST.EmailOptionCaption
			, TST.InternalMessageOptionCaption
			, 'False' AS [Disabled]
			, GetDate() AS DateCreated
		FROM #SystemTask TST
		LEFT JOIN dbo.SystemTask ST ON ST.[Name] = TST.[Name]
		WHERE ST.Id IS NULL;

		--Ensure Task Descriptions etc are correct
		UPDATE ST
		SET ST.Title = TST.Title
		, ST.[Description] = TST.[Description]
		, ST.DevelopersNotes = TST.DevelopersNotes
		, ST.EmailOptionCaption = TST.EmailOptionCaption
		, ST.InternalMessageOptionCaption = TST.InternalMessageOptionCaption
		FROM dbo.SystemTask ST
		INNER JOIN #SystemTask TST ON ST.[Name] = TST.[Name];

		PRINT('');PRINT('*Ensures required rows are in "SystemTask" table - Disable Those not in the list.');
		UPDATE dbo.SystemTask
		SET [Disabled] = 'True'
		WHERE [Name] NOT IN (SELECT [Name] FROM #SystemTask);

		--Disable Email by Default for these Tasks
		UPDATE OSTM
		SET OSTM.[SendMessagesViaEmail] = 'False'
		FROM [dbo].[OrganisationSystemTaskMessaging] OSTM
		INNER JOIN dbo.SystemTask ST ON ST.Id = OSTM.[SystemTaskId]
		WHERE ST.[Name] IN ('EMAIL_MultipleEmailSendFailure')
		AND OSTM.[SendMessagesViaEmail] != 'False';

	END

	/* Ensures required rows are in "DORSAttendanceState" table */
	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - DORSAttendanceState';
	BEGIN
		PRINT('');PRINT('*Ensures required rows are in "DORSAttendanceState" table');

		IF OBJECT_ID('tempdb..#DORSAttendanceState', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #DORSAttendanceState;
		END

		/* NB. The DORS Attendance State (Status) Id is set by DORS. The table should not have "Identity" set against the Id Column. */

		SELECT *
		INTO #DORSAttendanceState
		FROM (
			SELECT
				1 AS [DORSAttendanceStateIdentifier]
				, 'Booking Pending' AS [Name]
				, 'Booking Pending' AS [Description]
				, dbo.udfGetSystemUserId() AS [UpdatedByUserId]
				, Getdate() AS [DateUpdated]
			UNION SELECT
				2 AS [DORSAttendanceStateIdentifier]
				, 'Booked' AS [Name]
				, 'Booked' AS [Description]
				, dbo.udfGetSystemUserId() AS [UpdatedByUserId]
				, Getdate() AS [DateUpdated]
			UNION SELECT
				3 AS [DORSAttendanceStateIdentifier]
				, 'Booked and Paid' AS [Name]
				, 'Booked and Paid' AS [Description]
				, dbo.udfGetSystemUserId() AS [UpdatedByUserId]
				, Getdate() AS [DateUpdated]
			UNION SELECT
				4 AS [DORSAttendanceStateIdentifier]
				, 'Attended and Completed' AS [Name]
				, 'Attended and Completed' AS [Description]
				, dbo.udfGetSystemUserId() AS [UpdatedByUserId]
				, Getdate() AS [DateUpdated]
			UNION SELECT
				5 AS [DORSAttendanceStateIdentifier]
				, 'Attended and Not Completed' AS [Name]
				, 'Attended and Not Completed' AS [Description]
				, dbo.udfGetSystemUserId() AS [UpdatedByUserId]
				, Getdate() AS [DateUpdated]
			UNION SELECT
				6 AS [DORSAttendanceStateIdentifier]
				, 'Did Not Attend' AS [Name]
				, 'Did Not Attend' AS [Description]
				, dbo.udfGetSystemUserId() AS [UpdatedByUserId]
				, Getdate() AS [DateUpdated]
			UNION SELECT
				7 AS [DORSAttendanceStateIdentifier]
				, 'Offer Withdrawn' AS [Name]
				, 'Offer Withdrawn' AS [Description]
				, dbo.udfGetSystemUserId() AS [UpdatedByUserId]
				, Getdate() AS [DateUpdated]
			) T
		;

		--Insert if Not Already There
		INSERT INTO dbo.DORSAttendanceState (
								[DORSAttendanceStateIdentifier]
								, [Name]
								, [Description]
								, [UpdatedByUserId]
								, [DateUpdated]
								)
		SELECT
			TDAS.[DORSAttendanceStateIdentifier]
			, TDAS.[Name]
			, TDAS.[Description]
			, TDAS.[UpdatedByUserId]
			, TDAS.[DateUpdated]
		FROM #DORSAttendanceState TDAS
		LEFT JOIN dbo.DORSAttendanceState DAS ON DAS.[DORSAttendanceStateIdentifier] = TDAS.[DORSAttendanceStateIdentifier]
		WHERE DAS.Id IS NULL;

		--Update if Changed
		UPDATE DAS
		SET DAS.[Name] = TDAS.[Name]
		, DAS.[Description] = TDAS.[Description]
		, DAS.[UpdatedByUserId] = dbo.udfGetSystemUserId()
		, DAS.[DateUpdated] = Getdate()
		FROM dbo.DORSAttendanceState DAS
		INNER JOIN #DORSAttendanceState TDAS ON TDAS.[DORSAttendanceStateIdentifier] = DAS.[DORSAttendanceStateIdentifier]
		WHERE DAS.[Name] <> TDAS.[Name]
		OR DAS.[Description] <> TDAS.[Description];

	END

	/* Ensures required System Feature */
	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - Ensures required System Feature';
	BEGIN
		PRINT('');PRINT('*Ensures required System Feature');
		BEGIN
			PRINT('');PRINT('*Ensures required rows are in "SystemFeatureItem" table');

			IF OBJECT_ID('tempdb..#SystemFeatureItem', 'U') IS NOT NULL
			BEGIN
				DROP TABLE #SystemFeatureItem;
			END

			SELECT *
			INTO #SystemFeatureItem
			FROM (
			 SELECT 'Add Course' AS [Name]
				, 'Add Course' AS [Title]
				, 'Course Maintenance' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'Add Report' AS [Name]
				, 'Add Report' AS [Title]
				, 'Add a Report' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'Admin Menu Control' AS [Name]
				, 'Admin Menu Control' AS [Title]
				, 'Admin Menu Maintenance' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'Assign Course Types' AS [Name]
				, 'Assign Course Types' AS [Title]
				, 'Assign Course Type Categories' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'Blocked Outgoing Email Addresses' AS [Name]
				, 'Blocked Outgoing Email Addresses' AS [Title]
				, 'Maintain Blocked Outgoing Email Addresses' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'DORS Connection Details' AS [Name]
				, 'DORS Connection Details' AS [Title]
				, 'Edit DORS Connection Details' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'DORS Connection Settings' AS [Name]
				, 'DORS Connection Settings' AS [Title]
				, 'Edit DORS  Connection Settings' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'Course Trainers' AS [Name]
				, 'Course Trainers' AS [Title]
				, 'Manage Course Trainer Allocations' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'Course Type Categories' AS [Name]
				, 'Course Type Categories' AS [Title]
				, 'Course Type Category Maintenance' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'Course Type' AS [Name]
				, 'Course Type' AS [Title]
				, 'Course Type Maintenance' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'Dashboard Meter Maintenance & Exposure' AS [Name]
				, 'Dashboard Meter Maintenance & Exposure' AS [Title]
				, 'Configure Dashboard Meters' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'Data View Maintenance' AS [Name]
				, 'Data View Maintenance' AS [Title]
				, 'Data View Maintenance' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'Delete Marked Clients' AS [Name]
				, 'Delete Marked Clients' AS [Title]
				, 'Delete Marked Clients' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'Delete Marked Documents' AS [Name]
				, 'Delete Marked Documents' AS [Title]
				, 'Delete Marked Documents' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'Document Management' AS [Name]
				, 'Document Management' AS [Title]
				, 'Manage an Organisation''s documents' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'Document Statistics' AS [Name]
				, 'Document Statistics' AS [Title]
				, 'Document Statistics and Administration' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'Documents for All Course Types' AS [Name]
				, 'Documents for All Course Types' AS [Title]
				, 'Documents for all Course Types Administration' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'Documents for All Courses' AS [Name]
				, 'Documents for All Courses' AS [Title]
				, 'Documents for all Courses Administration' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'Documents for All Trainers' AS [Name]
				, 'Documents for All Trainers' AS [Title]
				, 'Documents for all Trainers Administration' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'DORS Control' AS [Name]
				, 'DORS Control' AS [Title]
				, 'Configure DORS Control Settings' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'Letter Template Maintenance' AS [Name]
				, 'Letter Template Maintenance' AS [Title]
				, 'Maintain Letter Templates' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'Meter Availability' AS [Name]
				, 'Meter Availability' AS [Title]
				, 'Dashboard Meter Availability' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'Organisation Self Configuration' AS [Name]
				, 'Organisation Self Configuration' AS [Title]
				, 'Configure Self Organisation' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'Organisation System Configuration' AS [Name]
				, 'Organisation System Configuration' AS [Title]
				, 'Configure System Organisation' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'Payment Provider' AS [Name]
				, 'Payment Provider' AS [Title]
				, 'Payment Provider Maintenance' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'Payment Type' AS [Name]
				, 'Payment Type' AS [Title]
				, 'Payment Type Maintenance' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'Public Holiday' AS [Name]
				, 'Public Holiday' AS [Title]
				, 'Public Holiday Maintenance' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'Referring Authority Details' AS [Name]
				, 'Referring Authority Details' AS [Title]
				, 'Manage an Organisations Referring Authority' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'Report Categories' AS [Name]
				, 'Report Categories' AS [Title]
				, 'Edit Report Categories' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'Reports' AS [Name]
				, 'Reports' AS [Title]
				, 'Search for Reports' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'Scheduler Control Configuration' AS [Name]
				, 'Scheduler Control Configuration' AS [Title]
				, 'Configure Scheduler Control' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'Special Requirements' AS [Name]
				, 'Additional Requirements' AS [Title]
				, 'Additional Requirements Maintenance' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'System Control Configuration' AS [Name]
				, 'System Control Configuration' AS [Title]
				, 'Configure System Control' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'System Feature Configuration' AS [Name]
				, 'System Feature Configuration' AS [Title]
				, 'Configure System Features' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'System Support Users' AS [Name]
				, 'System Support Users' AS [Title]
				, 'System Support Users' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'System Tasks' AS [Name]
				, 'System Tasks' AS [Title]
				, 'System Tasks Maintenance' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'Trainer Search' AS [Name]
				, 'Trainer Search' AS [Title]
				, 'Trainer Search' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'Trainer Settings' AS [Name]
				, 'Trainer Settings' AS [Title]
				, 'Trainer Settings' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'User Maintenance' AS [Name]
				, 'User Maintenance' AS [Title]
				, 'User Maintenance' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'Venue' AS [Name]
				, 'Venue' AS [Title]
				, 'Venue Maintenance' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'System Feature Configuration' AS [Name]
				, 'System Feature Configuration' AS [Title]
				, 'Configure System Features' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'Create Multi-Course Stencil' AS [Name]
				, 'Create Multi-Course Stencil' AS [Title]
				, 'This feature will allow the User to create a new Course Stencil which can be used to Create Multiple Courses over many Dates into the Future.' AS [Description]
				, 'False' AS [SystemAdministratorOnly]
				, 'False' AS [OrganisationAdministratorOnly]
				, [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId]
				, GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'Create Stencil Courses' AS [Name]
				, 'Create Stencil Courses' AS [Title]
				, 'This feature will allow the User to view a list of all course stencils, edit existing ones, create courses, remove courses and create new Course Stencils' AS [Description]
				, 'False' AS [SystemAdministratorOnly]
				, 'False' AS [OrganisationAdministratorOnly]
				, [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId]
				, GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'Course Reminder Email Template' AS [Name]
				, 'Course Reminder Email Template' AS [Title]
				, 'This feature will allow the editing of the email template sent out to Clients for Course Reminders' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'Course Reminder SMS Template' AS [Name]
				, 'Course Reminder SMS Template' AS [Title]
				, 'This feature will allow the editing of the SMS template sent out to Clients for Course Reminders' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'Netcall Maintenance' AS [Name]
				, 'Netcall Maintenance' AS [Title]
				, 'This feature allows the Administrators to add Users as Netcall Agents and set their Netcall Number' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			UNION SELECT 'Clone Course' AS [Name]
				, 'Clone Course' AS [Title]
				, 'This feature allows the cloning of a course. All Course Features will be copied, including Course Type, Venue, Number of Places etc' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			UNION SELECT 'Scheduler Control' AS [Name]
				, 'Scheduler Control' AS [Title]
				, 'This feature can be used to stop the running of the various Scheduled Processes in Atlas' AS [Description]
				, 'True' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			UNION SELECT 'Archive Control' AS [Name]
				, 'Archive Control' AS [Title]
				, 'This feature can be used to how often Archiving processes happen. For the System and for each Organisation' AS [Description]
				, 'True' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			UNION SELECT 'Course Fee Maintenance' AS [Name]
				, 'Course Fee Maintenance' AS [Title]
				, 'This feature can be used to manage the amount payable for Course Bookings, based on the Course Type and/or Course Type Category' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			UNION SELECT 'Administer Blocked IPs' AS [Name]
				, 'Administer Blocked IPs' AS [Title]
				, 'This feature can be used to view Blocked IP Addresses and Unblock them if required' AS [Description]
				, 'True' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			UNION SELECT 'Course Rebooking Fee Maintenance' AS [Name]
				, 'Course Rebooking Fee Maintenance' AS [Title]
				, 'This feature can be used to manage the amount payable for Course Re-Bookings, based on the Course Type and/or Course Type Category' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			UNION SELECT 'Interpreter Administration' AS [Name]
				, 'Interpreter Administration' AS [Title]
				, 'This feature can be used to manage the Interpreters and Language for an Organisation' AS [Description]
				, 'True' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			UNION SELECT 'Task Category' AS [Name]
				, 'Task Category' AS [Title]
				, 'Manage the list of Task Categories for an Organisation' AS [Description]
				, 'True' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			UNION SELECT 'Trainer Vehicle Maintenance' AS [Name]
				, 'Trainer Vehicle' AS [Title]
				, 'Manage the list of Vehicles for a Trainer' AS [Description]
				, 'True' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			UNION SELECT 'Course Trainer Reference Generation Settings' AS [Name]
				, 'Course Trainer Reference Generation Settings' AS [Title]
				, 'Manage the Course Trainer for Reference Generation Settings' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			UNION SELECT 'Course Interpreter Reference Generation Settings' AS [Name]
				, 'Course Interpreter Reference Generation Settings' AS [Title]
				, 'Manage the Course Interpreter for Reference Generation Settings' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			) SFI
			;

			INSERT INTO [dbo].[SystemFeatureItem] (
									[Name]
									, [Title]
									, [Description]
									, [SystemAdministratorOnly]
									, [OrganisationAdministratorOnly]
									, [UpdatedByUserId]
									, [DateUpdated]
									, [Disabled]
									)
			SELECT
				New_SFI.[Name]
				, New_SFI.[Title]
				, New_SFI.[Description]
				, New_SFI.[SystemAdministratorOnly]
				, New_SFI.[OrganisationAdministratorOnly]
				, New_SFI.[UpdatedByUserId]
				, New_SFI.[DateUpdated]
				, New_SFI.[Disabled]
			FROM #SystemFeatureItem New_SFI
			LEFT JOIN dbo.SystemFeatureItem SFI ON SFI.[Name] = New_SFI.[Name]
			WHERE SFI.Id IS NULL;

			--Ensure Task Descriptions etc are correct
			UPDATE SFI
			SET SFI.[Title] = New_SFI.[Title]
			, SFI.[Description] = New_SFI.[Description]
			, SFI.[SystemAdministratorOnly] = New_SFI.[SystemAdministratorOnly]
			, SFI.[OrganisationAdministratorOnly] = New_SFI.[OrganisationAdministratorOnly]
			, SFI.[UpdatedByUserId] = [dbo].[udfGetSystemUserId]()
			, SFI.[DateUpdated] = GetDate()
			FROM dbo.SystemFeatureItem SFI
			INNER JOIN #SystemFeatureItem New_SFI ON SFI.[Name] = New_SFI.[Name]
			WHERE SFI.[SystemAdministratorOnly] != New_SFI.[SystemAdministratorOnly]
			OR SFI.[Title] != New_SFI.[Title]
			OR SFI.[Description] != New_SFI.[Description]
			OR SFI.[OrganisationAdministratorOnly] != New_SFI.[OrganisationAdministratorOnly];

			--Link Menus to Features.
			UPDATE AMI
			SET AMI.[SystemFeatureItemId] = SFI.Id
			FROM [dbo].[AdministrationMenuItem] AMI
			INNER JOIN dbo.SystemFeatureItem SFI ON SFI.[Name] = REPLACE(AMI.[Title], '''', '')
			WHERE [SystemFeatureItemId] IS NULL;
		END

		BEGIN
			PRINT('');PRINT('*Ensures required rows are in "SystemFeatureGroup" table');

			IF OBJECT_ID('tempdb..#SystemFeatureGroup', 'U') IS NOT NULL
			BEGIN
				DROP TABLE #SystemFeatureGroup;
			END

			SELECT *
			INTO #SystemFeatureGroup
			FROM (
			SELECT 'Client' AS [Name]
				, 'Client' AS [Title]
				, 'Client Administration' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'Course' AS [Name]
				, 'Course' AS [Title]
				, 'Course Administration' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'DORS' AS [Name]
				, 'DORS' AS [Title]
				, 'DORS Administration' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'Organisation' AS [Name]
				, 'Organisation' AS [Title]
				, 'Organisation Administration' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'Other' AS [Name]
				, 'Other' AS [Title]
				, 'Other Administration' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'Payment' AS [Name]
				, 'Payment' AS [Title]
				, 'Payment Administration' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'Reporting' AS [Name]
				, 'Reporting' AS [Title]
				, 'Reporting Administration' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'Security' AS [Name]
				, 'Security' AS [Title]
				, 'System Security Administration' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'System Admin' AS [Name]
				, 'System Admin' AS [Title]
				, 'System Administration' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'Trainer' AS [Name]
				, 'Trainer' AS [Title]
				, 'Trainer' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			 UNION SELECT 'User' AS [Name]
				, 'User' AS [Title]
				, 'User Administration' AS [Description]
				, 'False' AS [SystemAdministratorOnly], 'False' AS [OrganisationAdministratorOnly], [dbo].[udfGetSystemUserId]() AS [UpdatedByUserId], GetDate() AS [DateUpdated], 'False' AS [Disabled]
			) SFG


			INSERT INTO [dbo].[SystemFeatureGroup] (
									[Name]
									, [Title]
									, [Description]
									, [SystemAdministratorOnly]
									, [OrganisationAdministratorOnly]
									, [UpdatedByUserId]
									, [DateUpdated]
									, [Disabled]
									)
			SELECT
				New_SFI.[Name]
				, New_SFI.[Title]
				, New_SFI.[Description]
				, New_SFI.[SystemAdministratorOnly]
				, New_SFI.[OrganisationAdministratorOnly]
				, New_SFI.[UpdatedByUserId]
				, New_SFI.[DateUpdated]
				, New_SFI.[Disabled]
			FROM #SystemFeatureGroup New_SFI
			LEFT JOIN dbo.SystemFeatureGroup SFI ON SFI.[Name] = New_SFI.[Name]
			WHERE SFI.Id IS NULL;

			--Ensure Task Descriptions etc are correct
			UPDATE SFI
			SET SFI.[SystemAdministratorOnly] = New_SFI.[SystemAdministratorOnly]
			, SFI.[OrganisationAdministratorOnly] = New_SFI.[OrganisationAdministratorOnly]
			, SFI.[UpdatedByUserId] = [dbo].[udfGetSystemUserId]()
			, SFI.[DateUpdated] = GetDate()
			FROM dbo.SystemFeatureGroup SFI
			INNER JOIN #SystemFeatureGroup New_SFI ON SFI.[Name] = New_SFI.[Name]
			WHERE SFI.[SystemAdministratorOnly] != New_SFI.[SystemAdministratorOnly]
			OR SFI.[OrganisationAdministratorOnly] != New_SFI.[OrganisationAdministratorOnly];
		END

		--Now put Items in Groups. Using Menus as a Guide
		BEGIN
			PRINT('');PRINT('*Ensures we now put Items in Groups. Using Menus as a Guide');
			INSERT INTO [dbo].[SystemFeatureGroupItem] (SystemFeatureGroupId, SystemFeatureItemId)
			SELECT DISTINCT
				SFG.Id AS [SystemFeatureGroupId]
				, SFI.Id AS [SystemFeatureItemId]
			FROM [dbo].[AdministrationMenuGroupItem] AMGI
			INNER JOIN [dbo].[AdministrationMenuGroup] AMG ON AMG.[Id] = AMGI.[AdminMenuGroupId]
			INNER JOIN [dbo].[AdministrationMenuItem] AMI ON AMI.[Id] = AMGI.[AdminMenuItemId]
			INNER JOIN [dbo].[SystemFeatureGroup] SFG ON SFG.[Name] = REPLACE(AMG.[Title], '''', '')
			INNER JOIN [dbo].[SystemFeatureItem] SFI ON SFI.[Name] = REPLACE(AMI.[Title], '''', '')
			LEFT JOIN [dbo].[SystemFeatureGroupItem] SFGI ON SFGI.[SystemFeatureGroupId] = SFG.Id
															AND SFGI.[SystemFeatureItemId] = SFI.Id
			WHERE SFGI.Id IS NULL;
		END

	END

--/* Setup Initial Email Template Messages for Organisations */
--	SET @processNumber = @processNumber + 1;
--	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - Setup Initial Email Template Messages for Organisations';
--	BEGIN
--		PRINT('');PRINT('*Setup Initial Email Template Messages for Organisations');
--		IF OBJECT_ID('tempdb..#OrganisationEmailTemplateMessage', 'U') IS NOT NULL
--		BEGIN
--			DROP TABLE #OrganisationEmailTemplateMessage;
--		END

--		SELECT *
--		INTO #OrganisationEmailTemplateMessage
--		FROM (
--			SELECT DISTINCT
--					O.Id											AS [OrganisationId]
--					, 'CourseReminder'								AS [Code]
--					, 'Course Reminder'								AS [Name]
--					, 'Road Safety Course Booking Confirmation'		AS [Subject]
--					, 'Dear <!Client Name!>,'
--						+ @NewLine + @NewLine + 'Thank you for booking your course “<!Course Type!>” for “<!Course Date!>”.'
--						+ @NewLine + 'Please note it is essential you bring photo ID.'
--						+ @NewLine + @NewLine + 'Regards'
--						+ @NewLine + @NewLine + 'The Administration Team'
--													AS [Content]
--			FROM Organisation O
--			UNION
--			SELECT DISTINCT
--					O.Id							AS [OrganisationId]
--					, 'ClientEmailChangeReq'		AS [Code]
--					, 'Client Email Change Request'	AS [Name]
--					, 'Email Change Request'		AS [Subject]
--					, 'Dear <!Client Name!>,'
--						+ @NewLine + @NewLine + 'You have requested a change to your email address from “<!Previous Email!>” for “<!New Email!>”.'
--						+ @NewLine + 'If you did not request this please report this to our administration team.'
--						+ @NewLine + @NewLine + 'To confirm the email change you must enter this code: "<!Change Request Code!>".'
--						+ @NewLine + @NewLine + 'Regards'
--						+ @NewLine + @NewLine + 'The Administration Team'
--						+ @NewLine + @NewLine + '<!Organisation Display Name!>'
--													AS [Content]
--			FROM Organisation O
--			UNION
--			SELECT DISTINCT
--					O.Id							AS [OrganisationId]
--					, 'CourseTransReq'				AS [Code]
--					, 'Client Email for Course Transfer Request'	AS [Name]
--					, 'Course Transfer Request'		AS [Subject]
--					, 'Dear <!Client Name!>,'
--						+ @NewLine + @NewLine + 'You have requested a change to your course booking.'
--						+ @NewLine + @NewLine + 'You have requested a change to Course "<!From Course Type Name!>", "<!From Course Date!>" to '
--						+ ' "<!To Course Type Name!>", "<!To Course Date!>". '
--						+ @NewLine + @NewLine + '<!Re-Booking Fee Message!>'
--						+ @NewLine + @NewLine + 'Your request is being processed.'
--						+ @NewLine + @NewLine + 'If you did not request this please report this to our administration team.'
--						+ @NewLine + @NewLine + 'Regards'
--						+ @NewLine + @NewLine + 'The Administration Team'
--						+ @NewLine + @NewLine + '<!Organisation Display Name!>'
--													AS [Content]
--			FROM Organisation O
--			UNION
--			SELECT DISTINCT
--					O.Id							AS [OrganisationId]
--					, 'CourseVenueAvail'			AS [Code]
--					, 'Course Venue Availability'	AS [Name]
--					, 'Venue Availability'		AS [Subject]
--					, 'The Venue Administrators'
--						+ @NewLine + '<!Venue Name!>'
--						+ @NewLine + @NewLine + 'Dear Sir or Madam,'
--						+ @NewLine + @NewLine + 'We are checking the availability for us to run our "<!Course Type Name!>" Course at your Venue.'
--						+ @NewLine + @NewLine + 'The date and time we would require is between "<!Course Start Date!>" and "<!Course End Date!>". '
--						+ @NewLine + @NewLine + 'Can you please confirm this availability.'
--						+ @NewLine + @NewLine + 'Regards'
--						+ @NewLine + @NewLine + 'The Administration Team'
--						+ @NewLine + @NewLine + '<!Organisation Display Name!>'
--						+ @NewLine + @NewLine + 'Email: <!Reply Email Address!>'
--													AS [Content]
--			FROM Organisation O
--			UNION
--			SELECT DISTINCT
--					O.Id								AS [OrganisationId]
--					, 'PayRefRequest-User'				AS [Code]
--					, 'Payment Refund Request - User'	AS [Name]
--					, 'Payment Refund Processing Request - Acknowledgement'	AS [Subject]
--					, '<!Organisation Display Name!> - Payment Refund Processing Request'
--						+ @NewLine + 'Hello <!User Name!>,'
--						+ @NewLine + @NewLine + 'We have received your request for a Payment Refund to be Processed.'
--						+ @NewLine + 'The details of your request are as follows:'
--						+ @NewLine + @NewLine + 'When Request Sent: "<!DateCreated!>". '
--						+ @NewLine + 'Requested Refund Date: "<!RequestDate!>".'
--						+ @NewLine + 'Payee: "<!ActualPayeeName!>".'
--						+ @NewLine + 'Refund Amount: "<!Amount!>".'
--						+ @NewLine + @NewLine + 'Relating to Client: "<!Client Name!>" (Client Id: <!ClientId!>; DOB: <!ClientDateOfBirth!>)'
--						+ @NewLine + 'Relating to Course: "<!Course Type!>, <!Course Reference!>, <!Course Date!>"'
--						+ @NewLine + 'Refunding Payment: "<!Payment Date!>, <!Payment Name!>, <!Payment Method!>"'

--						+ @NewLine + @NewLine + 'Regards'
--						+ @NewLine + @NewLine + 'The Atlas Administration Team'
--						+ @NewLine + @NewLine
--													AS [Content]
--			FROM Organisation O
--			UNION
--			SELECT DISTINCT
--					O.Id								AS [OrganisationId]
--					, 'PayRefRequest-Admin'				AS [Code]
--					, 'Payment Refund Request - Admin'	AS [Name]
--					, 'Payment Refund Processing Request'	AS [Subject]
--					, 'Payment Refund Processing Request From: "<!Organisation Display Name!>"'
--						+ @NewLine + 'Hello Atlas Administrators,'
--						+ @NewLine + @NewLine + 'User: <!Created By User Name!> at <!Organisation Display Name!> has requested a Payment Refund to be Processed.'
--						+ @NewLine + 'The details of your request are as follows:'
--						+ @NewLine + @NewLine + 'When Request Sent: "<!DateCreated!>". '
--						+ @NewLine + 'Requested Refund Date: "<!RequestDate!>".'
--						+ @NewLine + 'Payee: "<!ActualPayeeName!>".'
--						+ @NewLine + 'Refund Amount: "<!Amount!>".'
--						+ @NewLine + @NewLine + 'Relating to Client: "<!Client Name!>" (Client Id: <!ClientId!>; DOB: <!ClientDateOfBirth!>)'
--						+ @NewLine + 'Relating to Course: "<!Course Type!>, <!Course Reference!>, <!Course Date!>"'
--						+ @NewLine + 'Refunding Payment: "<!Payment Date!>, <!Payment Name!>, <!Payment Method!>"'

--						+ @NewLine + @NewLine + 'Regards'
--						+ @NewLine + @NewLine + 'The Atlas System'
--						+ @NewLine + @NewLine
--													AS [Content]
--			FROM Organisation O
--			UNION
--			SELECT DISTINCT
--					O.Id											AS [OrganisationId]
--					, 'CanRefRequest-User'							AS [Code]
--					, 'Payment Refund Request Cancellation - User'	AS [Name]
--					, 'Payment Refund Request Cancellation'			AS [Subject]
--					, '<!Organisation Display Name!> - Payment Refund Processing Request Cancelled'
--						+ @NewLine + 'Hello <!User Name!>,'
--						+ @NewLine + @NewLine + 'The following request for a Payment Refund to be Processed has been CANCELLED.'
--						+ @NewLine + @NewLine + 'Cancellation Reason: "<!CancellationReason!>"'
--						+ @NewLine + @NewLine + 'The details of the request were as follows:'
--						+ @NewLine + @NewLine + 'When Request Sent: "<!DateCreated!>". '
--						+ @NewLine + 'Requested Refund Date: "<!RequestDate!>".'
--						+ @NewLine + 'Payee: "<!ActualPayeeName!>".'
--						+ @NewLine + 'Refund Amount: "<!Amount!>".'
--						+ @NewLine + @NewLine + 'Relating to Client: "<!Client Name!>" (Client Id: <!ClientId!>; DOB: <!ClientDateOfBirth!>)'
--						+ @NewLine + 'Relating to Course: "<!Course Type!>, <!Course Reference!>, <!Course Date!>"'
--						+ @NewLine + 'Refunding Payment: "<!Payment Date!>, <!Payment Name!>, <!Payment Method!>"'

--						+ @NewLine + @NewLine + 'Regards'
--						+ @NewLine + @NewLine + 'The Atlas Administration Team'
--						+ @NewLine + @NewLine
--													AS [Content]
--			FROM Organisation O
--			UNION
--			SELECT DISTINCT
--			O.Id											AS [OrganisationId]
--			, 'TrainerBookConf'								AS [Code]
--			, 'Trainer Booking Confirmation'				AS [Name]
--			, '<!CourseType!> Course Booking'				AS [Subject]
--			, 'Dear <!TrainerDisplayName!>'
--				+ @NewLine + @NewLine + 'Having checked your online availability, I confirm your booking as follows:'
--				+ @NewLine + @NewLine + 'Course reference: <!CourseReference!>'
--				+ @NewLine + @NewLine + 'Course Venue: <!CourseVenueTitle!>'
--				+ @NewLine + '<!CourseVenueAddress!>'
--				+ @NewLine + @NewLine + 'Course Date: <!CourseStartDate!> - <!CourseEndDate!>'
--				+ @NewLine + @NewLine + 'Sessions Required: <!CourseSessions!>'
--				+ @NewLine + @NewLine + 'It is your responsibility to double check all course bookings and/or cancellation dates by logging into ATLAS.'
--				+ @NewLine + @NewLine + 'Should the course be cancelled for any reason, or you are not required due to low client numbers, you will receive a cancellation email within the agreed notice period.'
--				+ @NewLine + @NewLine + 'Should you have any queries, please contact the Admin Centre ASAP quoting the Course Ref Number above.'
--				+ @NewLine + @NewLine + 'PLEASE NOTE: You must NOT arrange "Swaps" with your colleagues - only the Admin Centre staff, are able to allocate trainers who have shown themselves as ''available'' for a particular day.'
--				+ @NewLine + @NewLine + 'Regards'
--				+ @NewLine + @NewLine + 'Paul Murphy'
--				+ @NewLine + 'Road Safety Project Officer'
--				+ @NewLine + @NewLine + 'Tel: 01429 523803'
--				+ @NewLine + 'Email: speedawareness@hartlepool.gov.uk'
--				+ @NewLine + @NewLine + '*** Please remember to always keep your availability calendar up to date by logging on to http://atlas.iamroadsmart.com <http://atlas.iamroadsmart.com> . If your availability is not kept up to date, this not only causes problems for the Admin Centre staff, but will also result in you receiving less offers of work***'
--														AS [Content]
--			FROM Organisation O
--			WHERE O.Name = 'Cleveland Driver Improvement Group'
--			UNION
--			SELECT DISTINCT
--			O.Id											AS [OrganisationId]
--			, 'TrainerCancConf'								AS [Code]
--			, 'Trainer Cancellation Confirmation'			AS [Name]
--			, '***CANCELLATION OF INSTRUCTOR BOOKING***'	AS [Subject]
--			, 'Dear <!TrainerDisplayName!>'
--				+ @NewLine + @NewLine + 'This email is confirmation that you are no longer required for the following course:'
--				+ @NewLine + @NewLine + 'Course Type: <!CourseType!>'
--				+ @NewLine + @NewLine + 'Course reference: <!CourseReference!>'
--				+ @NewLine + @NewLine + 'Course Venue: <!CourseVenueTitle!>'
--				+ @NewLine + '<!CourseVenueAddress!>'
--				+ @NewLine + @NewLine + 'Course Date: <!CourseStartDate!> - <!CourseEndDate!>'
--				+ @NewLine + @NewLine + 'Sessions Required: <!CourseSessions!>'
--				+ @NewLine + @NewLine + 'It is your responsibility to double check all course bookings and/or cancellation dates by logging into ATLAS.'
--				+ @NewLine + @NewLine + 'Should the course be cancelled for any reason, or you are not required due to low client numbers, you will receive a cancellation email within the agreed notice period.'
--				+ @NewLine + @NewLine + 'Should you have any queries, please contact the Admin Centre ASAP quoting the Course Ref Number above.'
--				+ @NewLine + @NewLine + 'PLEASE NOTE: You must NOT arrange "Swaps" with your colleagues - only the Admin Centre staff, are able to allocate trainers who have shown themselves as ''available'' for a particular day.'
--				+ @NewLine + @NewLine + 'Regards'
--				+ @NewLine + @NewLine + 'Paul Murphy'
--				+ @NewLine + 'Road Safety Project Officer'
--				+ @NewLine + @NewLine + 'Tel: 01429 523803'
--				+ @NewLine + 'Email: speedawareness@hartlepool.gov.uk'
--				+ @NewLine + @NewLine + '*** Please remember to always keep your availability calendar up to date by logging on to http://atlas.iamroadsmart.com <http://atlas.iamroadsmart.com> . If your availability is not kept up to date, this not only causes problems for the Admin Centre staff, but will also result in you receiving less offers of work***'
--															AS [Content]
--			FROM Organisation O
--			WHERE O.Name = 'Cleveland Driver Improvement Group'
--			) EmailTemplate

--		INSERT INTO [dbo].[OrganisationEmailTemplateMessage] (
--				[OrganisationId]
--				, [Code]
--				, [Name]
--				, [Subject]
--				, [Content]
--				, [DateLastUpdated]
--				, [UpdatedByUserId]
--				)
--		SELECT DISTINCT
--				New_OETM.[OrganisationId]		AS [OrganisationId]
--				, New_OETM.[Code]				AS [Code]
--				, New_OETM.[Name]				AS [Name]
--				, New_OETM.[Subject]			AS [Subject]
--				, New_OETM.[Content]			AS [Content]
--				, GetDate()						AS [DateLastUpdated]
--				, [dbo].[udfGetSystemUserId]()	AS [UpdatedByUserId]
--		FROM #OrganisationEmailTemplateMessage New_OETM
--		LEFT JOIN [dbo].[OrganisationEmailTemplateMessage] OETM ON OETM.OrganisationId = New_OETM.OrganisationId
--																AND OETM.Code = New_OETM.Code
--		WHERE OETM.Id IS NULL;

--		UPDATE OETM
--		SET OETM.[Subject] = New_OETM.[Subject]
--		, OETM.[Content] = New_OETM.[Content]
--		, OETM.[Name] = New_OETM.[Name]
--		FROM #OrganisationEmailTemplateMessage New_OETM
--		INNER JOIN [dbo].[OrganisationEmailTemplateMessage] OETM ON OETM.OrganisationId = New_OETM.OrganisationId
--																	AND OETM.Code = New_OETM.Code
--		WHERE OETM.[Subject] != New_OETM.[Subject]
--		OR OETM.[Content] != New_OETM.[Content]
--		OR OETM.[Name] != New_OETM.[Name]
--		;
--	END

--	/* Setup Initial SMS Template Messages for Organisations */
--	SET @processNumber = @processNumber + 1;
--	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - Setup Initial SMS Template Messages for Organisations';
--	BEGIN
--		PRINT('');PRINT('*Setup Initial SMS Template Messages for Organisations');
--		IF OBJECT_ID('tempdb..#OrganisationSMSTemplateMessage', 'U') IS NOT NULL
--		BEGIN
--			DROP TABLE #OrganisationSMSTemplateMessage;
--		END

--		SELECT DISTINCT
--				O.Id							AS [OrganisationId]
--				, 'CourseReminder'				AS [Code]
--				, 'Course Reminder'				AS [Name]
--				, '<!Client Name!>,'
--					+ @NewLine + 'Your course: “<!Course Type!>” is on “<!Course Date!>” @ <!VenueTitle!> <!VenuePostCode!>'
--					+ @NewLine + 'Please arrive on time - don''t forget your photo ID'
--												AS [Content]
--		INTO #OrganisationSMSTemplateMessage
--		FROM Organisation O;

--		INSERT INTO [dbo].[OrganisationSMSTemplateMessage] (
--				[OrganisationId]
--				, [Code]
--				, [Name]
--				, [Content]
--				, [DateLastUpdated]
--				, [UpdatedByUserId]
--				)
--		SELECT DISTINCT
--				New_OSTM.[OrganisationId]		AS [OrganisationId]
--				, New_OSTM.[Code]				AS [Code]
--				, New_OSTM.[Name]				AS [Name]
--				, New_OSTM.[Content]			AS [Content]
--				, GetDate()						AS [DateLastUpdated]
--				, [dbo].[udfGetSystemUserId]()	AS [UpdatedByUserId]
--		FROM #OrganisationSMSTemplateMessage New_OSTM
--		LEFT JOIN [dbo].[OrganisationSMSTemplateMessage] OSTM ON OSTM.OrganisationId = New_OSTM.OrganisationId
--																AND OSTM.Code = New_OSTM.Code
--		WHERE OSTM.Id IS NULL;

--	END

	/* Ensure Message Categories Exist */
	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - Ensure Message Categories Exist';
	BEGIN
		IF OBJECT_ID('tempdb..#MessageCategory', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #MessageCategory;
		END

		SELECT *
		INTO #MessageCategory
		FROM (
			SELECT 'GENERAL' AS [Name], '#8080FF' AS [CategoryColour]
			UNION SELECT 'PRIVATE' AS [Name], '#80CC80' AS [CategoryColour]
			UNION SELECT 'WARNING' AS [Name], '#FF8C8C' AS [CategoryColour]
			UNION SELECT 'ERROR' AS [Name], '#752D39' AS [CategoryColour]
			) CAT;

		INSERT INTO [dbo].[MessageCategory] ([Name], [CategoryColour])
		SELECT New_MC.[Name], New_MC.[CategoryColour]
		FROM #MessageCategory New_MC
		LEFT JOIN [dbo].[MessageCategory] MC ON MC.[Name] = New_MC.[Name]
		WHERE MC.Id IS NULL;

		UPDATE MC
		SET MC.[CategoryColour] = New_MC.[CategoryColour]
		FROM [dbo].[MessageCategory] MC
		INNER JOIN #MessageCategory New_MC ON MC.[Name] = New_MC.[Name]
		WHERE MC.[CategoryColour] != New_MC.[CategoryColour];
	END


	/* Ensure Payment Providers Exist */
	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - Ensure Payment Providers Exist';
	BEGIN
		PRINT('');PRINT('*Ensure Payment Providers Exist*');

		DECLARE @CurrentSystemType VARCHAR(4);
		SELECT @CurrentSystemType=AtlasSystemType FROM dbo.SystemControl WHERE [Id] = 1;

		IF OBJECT_ID('tempdb..#PaymentProvider', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #PaymentProvider;
		END

		DECLARE @SecureTrading VARCHAR(200) = 'Secure Trading';
		DECLARE @BarclaysSmartPay VARCHAR(200) = 'Barclays Smart Pay';
		DECLARE @NetBanx VARCHAR(200) = 'NetBanx';

		PRINT('');PRINT('-INSERT INTO #PaymentProvider');
		SELECT [Name], [Disabled], [NOTES], [SystemDefault]
		INTO #PaymentProvider
		FROM (
			SELECT @SecureTrading AS [Name], 'False' AS [Disabled], '' AS [NOTES], 'True' AS [SystemDefault]
			UNION SELECT @BarclaysSmartPay AS [Name], 'False' AS [Disabled], '' AS [NOTES], 'False' AS [SystemDefault]
			UNION SELECT @NetBanx AS [Name], 'False' AS [Disabled], '' AS [NOTES], 'False' AS [SystemDefault]
			) PP

		PRINT('');PRINT('-INSERT INTO dbo.PaymentProvider');
		INSERT INTO dbo.PaymentProvider ([Name], [Disabled], [NOTES], [SystemDefault])
		SELECT [Name], [Disabled], [NOTES], [SystemDefault]
		FROM #PaymentProvider NewPP
		WHERE NOT EXISTS (SELECT *
							FROM dbo.PaymentProvider PP
							WHERE PP.[Name] = NewPP.[Name]);

		-- Update Table OrganisationPaymentProvider
		IF OBJECT_ID('tempdb..#OrganisationPaymentProvider', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #OrganisationPaymentProvider;
		END

		-- OrganisationPaymentProviderMatch
		IF OBJECT_ID('tempdb..#OrganisationPaymentProviderMatch', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #OrganisationPaymentProviderMatch;
		END

		PRINT('');PRINT('-INSERT INTO #OrganisationPaymentProviderMatch');
		SELECT OrganisationName, PPName
		INTO #OrganisationPaymentProviderMatch
		FROM (
				--Secure Trading
				SELECT 'Cleveland' AS OrganisationName, @SecureTrading AS PPName
				UNION SELECT 'Durham' AS OrganisationName, @SecureTrading AS PPName
				UNION SELECT 'Essex' AS OrganisationName, @SecureTrading AS PPName
				UNION SELECT 'Gloucestershire' AS OrganisationName, @SecureTrading AS PPName
				UNION SELECT 'Norfolk' AS OrganisationName, @SecureTrading AS PPName
				UNION SELECT 'Staffordshire' AS OrganisationName, @SecureTrading AS PPName
				-- NetBanx
				UNION SELECT 'Sussex' AS OrganisationName, @NetBanx AS PPName
				-- Barclays Smart Pay
				UNION SELECT 'DriveSafe' AS OrganisationName, @BarclaysSmartPay AS PPName
			) OPPM;

		-- PaymentProviderDefault
		--IF (@CurrentSystemType = 'Test' OR @CurrentSystemType = 'Dev')
		BEGIN
			PRINT('');PRINT('-Test/Dev Data');
			PRINT('');PRINT('-INSERT INTO #PaymentProviderDefault');
			IF OBJECT_ID('tempdb..#PaymentProviderDefault', 'U') IS NOT NULL
			BEGIN
				DROP TABLE #PaymentProviderDefault;
			END
			SELECT PPName, PPCode, PPShortCode
			INTO #PaymentProviderDefault
			FROM (
					SELECT @SecureTrading AS PPName, 'SecureTrading' AS PPCode, 'ST_O' AS PPShortCode
					UNION SELECT @NetBanx AS PPName, 'NetBanx' AS PPCode, '' AS PPShortCode
					UNION SELECT @BarclaysSmartPay AS PPName, 'Barclays Smart Pay' AS PPCode, 'B_SP' AS PPShortCode
				) OPPM;
		END
		--ELSE IF (@CurrentSystemType = 'Live')
		--BEGIN
		--	PRINT('');PRINT('-Live Data');
		--	PRINT('');PRINT('-INSERT INTO #PaymentProviderDefault');
		--	IF OBJECT_ID('tempdb..#PaymentProviderDefault', 'U') IS NOT NULL
		--	BEGIN
		--		DROP TABLE #PaymentProviderDefault;
		--	END
		--	SELECT PPName, PPCode, PPShortCode
		--	INTO #PaymentProviderDefault
		--	FROM (
		--			SELECT @SecureTrading AS PPName, 'SecureTrading' AS PPCode, 'ST_O' AS PPShortCode
		--			UNION SELECT @NetBanx AS PPName, '' AS PPCode, '' AS PPShortCode
		--			UNION SELECT @BarclaysSmartPay AS PPName, 'Barclays Smart Pay' AS PPCode, 'B_SP' AS PPShortCode
		--		) OPPM;
		--END

		-- #PaymentProviderCredential
		--IF (@CurrentSystemType = 'Test' OR @CurrentSystemType = 'Dev')
		--BEGIN
		--	PRINT('');PRINT('-Test/Dev Data');
		--	PRINT('');PRINT('-INSERT INTO #PaymentProviderCredential');
		--	IF OBJECT_ID('tempdb..#PaymentProviderCredential', 'U') IS NOT NULL
		--	BEGIN
		--		DROP TABLE #PaymentProviderCredential;
		--	END
		--	SELECT PPName, PPKey, PPValue
		--	INTO #PaymentProviderCredential
		--	FROM (
		--		SELECT @SecureTrading AS PPName, 'username' AS PPKey, 'Atlas2016@iam.org.uk' AS PPValue
		--		UNION SELECT @SecureTrading AS PPName, 'password' AS PPKey, 'Atlas2016Payment' AS PPValue
		--		UNION SELECT @SecureTrading AS PPName, 'sitereference' AS PPKey, 'test_pdsessex35193' AS PPValue
		--		--
		--		UNION SELECT @BarclaysSmartPay AS PPName, 'username' AS PPKey, 'ws_935316@Company.GMPTE' AS PPValue
		--		UNION SELECT @BarclaysSmartPay AS PPName, 'password' AS PPKey, 'mGTctGdu+h3mzziXXm?g>6N&g' AS PPValue
		--		UNION SELECT @BarclaysSmartPay AS PPName, 'merchantAccount' AS PPKey, 'GMPTEINT' AS PPValue
		--		UNION SELECT @BarclaysSmartPay AS PPName, 'motoAccount' AS PPKey, 'GMPTEMOTO' AS PPValue
		--		--
		--		UNION SELECT @NetBanx AS PPName, 'apiKey' AS PPKey, '54980-1001062640:B-qa2-0-579b6ae6-0-302c02141ead14073770742efadb459bbb34f175688d7b87021477d550ad443f981ae5e61ec5046727f6abf46fbe' AS PPValue
		--		UNION SELECT @NetBanx AS PPName, 'accountNumber' AS PPKey, '1001062640' AS PPValue
		--		) PPC;
		--END
		--ELSE IF (@CurrentSystemType = 'Live')
		--BEGIN
		--	PRINT('');PRINT('-Live');
		--	PRINT('');PRINT('-INSERT INTO #PaymentProviderCredential');
		--	IF OBJECT_ID('tempdb..#PaymentProviderCredential', 'U') IS NOT NULL
		--	BEGIN
		--		DROP TABLE #PaymentProviderCredential;
		--	END
		--	SELECT PPName, PPKey, PPValue
		--	INTO #PaymentProviderCredential
		--	FROM (
		--		SELECT @SecureTrading AS PPName, 'username' AS PPKey, 'Atlas2016@iam.org.uk' AS PPValue
		--		UNION SELECT @SecureTrading AS PPName, 'password' AS PPKey, 'Atlas2016Payment' AS PPValue
		--		UNION SELECT @SecureTrading AS PPName, 'sitereference' AS PPKey, 'pdsessex26545' AS PPValue
		--		--
		--		UNION SELECT @BarclaysSmartPay AS PPName, 'username' AS PPKey, 'ws_935316@Company.GMPTE' AS PPValue
		--		UNION SELECT @BarclaysSmartPay AS PPName, 'password' AS PPKey, 'mGTctGdu+h3mzziXXm?g>6N&g' AS PPValue
		--		UNION SELECT @BarclaysSmartPay AS PPName, 'merchantAccount' AS PPKey, 'GMPTEINT' AS PPValue
		--		UNION SELECT @BarclaysSmartPay AS PPName, 'motoAccount' AS PPKey, 'GMPTEMOTO' AS PPValue
		--		) PPC;
		--END

		-- Update Table OrganisationPaymentProviderCredential
		--IF OBJECT_ID('tempdb..#OrganisationPaymentProviderCredential', 'U') IS NOT NULL
		--BEGIN
		--	DROP TABLE #OrganisationPaymentProviderCredential;
		--END

		----Now Update Table OrganisationPaymentProvider
		--BEGIN
		--	PRINT('');PRINT('-INSERT INTO #OrganisationPaymentProvider');
		--	SELECT OrganisationName, OPPM.PPName, PPCode, PPShortCode
		--	INTO #OrganisationPaymentProvider
		--	FROM #OrganisationPaymentProviderMatch OPPM
		--	INNER JOIN #PaymentProviderDefault PPC ON PPC.PPName = OPPM.PPName;

		--	PRINT('');PRINT('-INSERT INTO [OrganisationPaymentProvider]');
		--	INSERT INTO [dbo].[OrganisationPaymentProvider] (OrganisationId, PaymentProviderId, ProviderCode, ShortCode)
		--	SELECT DISTINCT
		--		O.Id AS OrganisationId
		--		, PP.Id AS PaymentProviderId
		--		, NewOPP.PPCode AS ProviderCode
		--		, NewOPP.PPShortCode AS ShortCode
		--	FROM Organisation O
		--	INNER JOIN #OrganisationPaymentProvider NewOPP ON O.[Name] LIKE '%' + NewOPP.OrganisationName + '%'
		--	INNER JOIN dbo.PaymentProvider PP ON PP.[Name] = NewOPP.PPName
		--	LEFT JOIN [dbo].[OrganisationPaymentProvider] OPP ON OPP.OrganisationId = O.Id
		--														AND OPP.PaymentProviderId = PP.Id
		--	WHERE OPP.Id IS NULL; --IE Not Already Inserted

		--	PRINT('');PRINT('-UPDATE [OrganisationPaymentProvider]');
		--	UPDATE OPP
		--	SET OPP.ProviderCode = NewOPP.PPCode
		--	, OPP.ShortCode = NewOPP.PPShortCode
		--	FROM [dbo].[OrganisationPaymentProvider] OPP
		--	INNER JOIN Organisation O ON O.Id = OPP.OrganisationId
		--	INNER JOIN dbo.PaymentProvider PP ON PP.Id = OPP.PaymentProviderId
		--	INNER JOIN #OrganisationPaymentProvider NewOPP ON O.[Name] LIKE '%' + NewOPP.OrganisationName + '%'
		--													AND NewOPP.PPName = PP.[Name]
		--	WHERE OPP.ProviderCode != NewOPP.PPCode
		--	OR OPP.ShortCode != NewOPP.PPShortCode;
		--END
		-----

		--Now Update Table OrganisationPaymentProviderCredential
		--BEGIN
		--	PRINT('');PRINT('-INSERT INTO #OrganisationPaymentProviderCredential');
		--	SELECT OrganisationName, OPPM.PPName, PPKey, PPValue
		--	INTO #OrganisationPaymentProviderCredential
		--	FROM #OrganisationPaymentProviderMatch OPPM
		--	INNER JOIN #PaymentProviderCredential PPD ON PPD.PPName = OPPM.PPName;

		--	PRINT('');PRINT('-INSERT INTO [OrganisationPaymentProviderCredential]');
		--	INSERT INTO [dbo].[OrganisationPaymentProviderCredential] (OrganisationId, PaymentProviderId, [Key], [Value])
		--	SELECT DISTINCT
		--		O.Id AS OrganisationId
		--		, PP.Id AS PaymentProviderId
		--		, NewOPPC.PPKey AS [Key]
		--		, NewOPPC.PPValue AS [Value]
		--	FROM Organisation O
		--	INNER JOIN #OrganisationPaymentProviderCredential NewOPPC ON O.[Name] LIKE '%' + NewOPPC.OrganisationName + '%'
		--	INNER JOIN dbo.PaymentProvider PP ON PP.[Name] = NewOPPC.PPName
		--	LEFT JOIN [dbo].[OrganisationPaymentProviderCredential] OPPC ON OPPC.OrganisationId = O.Id
		--																AND OPPC.PaymentProviderId = PP.Id
		--																AND OPPC.[Key] = NewOPPC.PPKey
		--	WHERE OPPC.Id IS NULL; --IE Not Already Inserted

		--	PRINT('');PRINT('-UPDATE [OrganisationPaymentProviderCredential]');
		--	UPDATE OPPC
		--	SET OPPC.[Value] = NewOPPC.PPValue
		--	FROM [dbo].[OrganisationPaymentProviderCredential] OPPC
		--	INNER JOIN Organisation O ON O.Id = OPPC.OrganisationId
		--	INNER JOIN dbo.PaymentProvider PP ON PP.Id = OPPC.PaymentProviderId
		--	INNER JOIN #OrganisationPaymentProviderCredential NewOPPC ON O.[Name] LIKE '%' + NewOPPC.OrganisationName + '%'
		--																AND NewOPPC.PPName = PP.[Name]
		--																AND OPPC.[Key] = NewOPPC.PPKey
		--	WHERE OPPC.[Value] != NewOPPC.PPValue;
		--END
		-----

	END

	/* ENSURE CourseTypeTolerance is Populated */
	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - ENSURE CourseTypeTolerance is Populated';
	BEGIN
		PRINT('');PRINT('*ENSURE CourseTypeTolerance is Populated*');
		IF OBJECT_ID('tempdb..#CourseTypeTolerance', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #CourseTypeTolerance;
		END

		SELECT *
		INTO #CourseTypeTolerance
		FROM (
			SELECT
				'NSAC' AS CourseCode
				, 1 AS FirstRatio
				, 12 AS SecondRatio
				, 26 AS MaximumAttendees
				, 10 AS Tolerance
			UNION SELECT
				'NSAC20' AS CourseCode
				, 1 AS FirstRatio
				, 12 AS SecondRatio
				, 26 AS MaximumAttendees
				, 10 AS Tolerance
			UNION SELECT
				'WDU' AS CourseCode
				, 1 AS FirstRatio
				, 12 AS SecondRatio
				, 26 AS MaximumAttendees
				, 10 AS Tolerance
			UNION SELECT
				'Motorway' AS CourseCode
				, 1 AS FirstRatio
				, 12 AS SecondRatio
				, 26 AS MaximumAttendees
				, 10 AS Tolerance
			UNION SELECT
				'NDAC (Theory)' AS CourseCode
				, 1 AS FirstRatio
				, 12 AS SecondRatio
				, 26 AS MaximumAttendees
				, 10 AS Tolerance
			UNION SELECT
				'Ride' AS CourseCode
				, 1 AS FirstRatio
				, 8 AS SecondRatio
				, 26 AS MaximumAttendees
				, 10 AS Tolerance
			UNION SELECT
				'WDU (Practical)' AS CourseCode
				, 1 AS FirstRatio
				, 2 AS SecondRatio
				, 2 AS MaximumAttendees
				, 0 AS Tolerance
			UNION SELECT
				'NDAC (Practical)' AS CourseCode
				, 1 AS FirstRatio
				, 2 AS SecondRatio
				, 2 AS MaximumAttendees
				, 0 AS Tolerance
			) T

		INSERT INTO [dbo].[CourseTypeTolerance] (CourseTypeId, Notes, FirstRatio, SecondRatio, MaximumAttendees, Tolerance, EffectiveDate, UpdatedByUserId, DateUpdated)
		SELECT DISTINCT
			CT.Id AS CourseTypeId
			, '' AS Notes
			, CTL_New.FirstRatio, CTL_New.SecondRatio, CTL_New.MaximumAttendees, CTL_New.Tolerance
			, GetDate() AS EffectiveDate
			, [dbo].[udfGetSystemUserId]() AS UpdatedByUserId
			, GetDate() AS DateUpdated
		FROM #CourseTypeTolerance CTL_New
		INNER JOIN [dbo].[CourseType] CT ON CT.Code = CTL_New.CourseCode
		LEFT JOIN [dbo].[CourseTypeTolerance] CTL ON CTL.CourseTypeId = CT.Id
		WHERE CTL.Id IS NULL;

		UPDATE CTL
		SET CTL.FirstRatio = CTL_New.FirstRatio
			, CTL.SecondRatio = CTL_New.SecondRatio
			, CTL.MaximumAttendees = CTL_New.MaximumAttendees
			, CTL.Tolerance = CTL_New.Tolerance
			, UpdatedByUserId = [dbo].[udfGetSystemUserId]()
			, DateUpdated = GetDate()
		FROM [dbo].[CourseTypeTolerance] CTL
		INNER JOIN [dbo].[CourseType] CT ON CT.Id = CTL.CourseTypeId
		INNER JOIN #CourseTypeTolerance CTL_New ON CTL_New.CourseCode = CT.Code
		WHERE CTL.FirstRatio != CTL_New.FirstRatio
		OR CTL.SecondRatio != CTL_New.SecondRatio
		OR CTL.MaximumAttendees != CTL_New.MaximumAttendees
		OR CTL.Tolerance != CTL_New.Tolerance;
	END

	/* ENSURE Columns in certain Tables have the correct default values and are not NULL */
	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - ENSURE Columns in certain Tables have the correct default values and are not NULL';
	BEGIN
		PRINT('');PRINT('*ENSURE Columns in certain Tables have the correct default values and are not NULL*');

		EXEC uspEnsureOrganisationalData;

		PRINT('');PRINT(' .. Course');
		UPDATE Course
		SET DORSCourse = (CASE WHEN DORSCourse IS NULL THEN 'False' ELSE DORSCourse END)
		, DORSNotificationRequested = (CASE WHEN DORSNotificationRequested IS NULL THEN 'False' ELSE DORSNotificationRequested END)
		, DORSNotified = (CASE WHEN DORSNotified IS NULL THEN 'False' ELSE DORSNotified END)
		WHERE DORSCourse IS NULL
		OR DORSNotificationRequested IS NULL
		OR DORSNotified IS NULL
		;
	END

	/* ENSURE ScheduledSMSState is Populated */
	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - ENSURE ScheduledSMSState is Populated';
	BEGIN
		INSERT INTO [dbo].[ScheduledSMSState] ([Name])
		SELECT [Name]
		FROM (SELECT 'Pending' AS [Name]
			UNION SELECT 'Sent' AS [Name]
			UNION SELECT 'Failed - Retrying' AS [Name]
			UNION SELECT 'Failed' AS [Name]
			) T
		WHERE T.[Name] NOT IN (SELECT DISTINCT [Name] FROM [dbo].[ScheduledSMSState]);
	END

	/* Required Data for LastRunLog */
	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - Required Data for LastRunLog';
	BEGIN
		/* Ensure LastRunLog Items Exist */
		IF OBJECT_ID('tempdb..#LastRunLog', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #LastRunLog;
		END

		SELECT T.ItemName, T.ItemDescription
		INTO #LastRunLog
		FROM (SELECT 'DORSOfferWithdrawnCheck' AS ItemName
					, 'This service periodically checks DORS for any Client Offers that may have been withdrawn' AS ItemDescription
			UNION SELECT 'DORSNotifyNewCourseClients' AS ItemName
					, 'This service periodically check the database for Clients added to DORS Courses and notify DORS.' AS ItemDescription
			UNION SELECT 'DORSNotifyRemoveCourseClients' AS ItemName
					, 'This service periodically check the database for Clients removed from DORS Courses and notify DORS.' AS ItemDescription
			UNION SELECT 'DORSCancelledCourse' AS ItemName
					, 'This service periodically checks if there are Courses which are DORS Courses and DORS has not been notified then call the DORS service, notify DORS.' AS ItemDescription
			UNION SELECT 'DORSRemoveFromCourse' AS ItemName
					, 'This service periodically check the database for Clients are to be removed from DORS Courses and notifies DORS.' AS ItemDescription
			UNION SELECT 'DORSClientTransferredFromCourse' AS ItemName
					, 'This service periodically check the database for Clients who have transferred from DORS Courses and notifies DORS.' AS ItemDescription
			UNION SELECT 'DORSNewCourses' AS ItemName
					, 'This service periodically check the database for new DORS Courses and notifies DORS.' AS ItemDescription
			UNION SELECT 'CheckforLockedClientRecords' AS ItemName
					, 'This service periodically check the database for Locked Client Records and removes the lock if the ''MaximumMinutesToLockClientsFor'' has been exceeded.' AS ItemDescription
			UNION SELECT 'uspArchiveEmails' AS ItemName
					, 'This stored procedure looks for emails that are ready to be archived and archives them' as ItemDescription
			UNION SELECT 'uspDeleteOldArchivedEmails' AS ItemName
					, 'This stored procedure looks for old archived emails that are ready to be deleted' as ItemDescription
			UNION SELECT 'uspArchiveSMSs' AS ItemName
					, 'This stored procedure looks for SMSs that are ready to be archived' as ItemDescription
			UNION SELECT 'uspDeleteOldArchivedSMSs' AS ItemName
					, 'This stored procedure looks for old archived SMSs that are ready to be deleted' as ItemDescription
			UNION SELECT 'uspRunSystemStoredProceduresPeriodically' AS ItemName
					, 'This stored procedure runs a variety of SPs periodically.' as ItemDescription
			UNION SELECT 'uspEnsureTrainerLimitationAndSummaryDataSetup' AS ItemName
					, 'This stored procedure Ensures certain Trainer Data is Set-up Annually.' as ItemDescription
			UNION SELECT 'uspDashboardDataRefresh' AS ItemName
					, 'This stored procedure Refreshes the Dashboard Data.' as ItemDescription
			UNION SELECT 'uspDashboardDataRefresh_Client' AS ItemName
					, 'This stored procedure Refreshes the Dashboard Data Clients.' as ItemDescription
			UNION SELECT 'uspDashboardDataRefresh_Course' AS ItemName
					, 'This stored procedure Refreshes the Dashboard Data Courses.' as ItemDescription
			UNION SELECT 'uspDashboardDataRefresh_DocumentStat' AS ItemName
					, 'This stored procedure Refreshes the Dashboard Data Document Statistics.' as ItemDescription
			UNION SELECT 'uspDashboardDataRefresh_DORSOfferWithdrawn' AS ItemName
					, 'This stored procedure Refreshes the Dashboard Data DORS Offers Withdrawn.' as ItemDescription
			UNION SELECT 'uspDashboardDataRefresh_Email' AS ItemName
					, 'This stored procedure Refreshes the Dashboard Data Emails.' as ItemDescription
			UNION SELECT 'uspDashboardDataRefresh_OnlineClientsSpecialRequirement' AS ItemName
					, 'This stored procedure Refreshes the Dashboard Data Special Requirements Recorded Online.' as ItemDescription
			UNION SELECT 'uspDashboardDataRefresh_Payment' AS ItemName
					, 'This stored procedure Refreshes the Dashboard Data Payments.' as ItemDescription
			UNION SELECT 'uspDashboardDataRefresh_UnpaidBookedCourse' AS ItemName
					, 'This stored procedure Refreshes the Dashboard Data Unpaid Booked Courses.' as ItemDescription
			UNION SELECT 'uspAllocateUnallocatedEmailToClient' AS ItemName
					, 'This stored procedure ensures emails which have been sent to clients are added to their history' as ItemDescription
			UNION SELECT 'uspEnsureReferringAuthoritySetForClient' AS ItemName
					, 'This stored procedure ensures the Referring Authority Id is Assigned for a DORS Client or All Clients' as ItemDescription
			UNION SELECT 'uspCheckForDuplicateClientsNotifySystemAdmins' AS ItemName
					, 'This stored procedure the System for Duplicate Client Details over the last 7 days' as ItemDescription					
			UNION SELECT 'uspInsertAnyMissingClientPaymentData' AS ItemName
					, 'This stored procedure will Insert Missing Data into the ClientPayment Table' as ItemDescription		
					
			) T

		INSERT INTO [dbo].[LastRunLog] (ItemName, ItemDescription)
		SELECT T.ItemName, T.ItemDescription
		FROM #LastRunLog T
		LEFT JOIN [dbo].[LastRunLog] LRL ON LRL.ItemName = T.ItemName
		WHERE LRL.Id IS NULL;

		UPDATE LRL
		SET LRL.ItemDescription = New_LRL.ItemDescription
		FROM [dbo].[LastRunLog] LRL
		INNER JOIN #LastRunLog New_LRL ON LRL.ItemName = New_LRL.ItemName
		WHERE LRL.ItemDescription != New_LRL.ItemDescription;
	END

	/* Required Data for TrainerVenue */
	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - Required Data for TrainerVenue';
	BEGIN
		INSERT INTO [dbo].[TrainerVenue] (
			TrainerId
			, VenueId
			, DistanceHomeToVenueInMiles
			, TrainerExcluded
			, DateUpdated
			, UpdatedByUserId
			)
		SELECT DISTINCT
			T.Id							AS TrainerId
			, V.Id							AS VenueId
			, -1							AS DistanceHomeToVenueInMiles
			, 'False'						AS TrainerExcluded
			, GETDATE()						AS DateUpdated
			, dbo.udfGetSystemUserId()		AS UpdatedByUserId
		FROM [dbo].[Organisation] O
		INNER JOIN [dbo].[TrainerOrganisation] TRO ON TRO.OrganisationId = O.Id
		INNER JOIN [dbo].[Trainer] T ON T.Id = TRO.TrainerId
		INNER JOIN [dbo].[Venue] V ON V.OrganisationId = O.Id
		LEFT JOIN [dbo].[TrainerVenue] TV ON TV.TrainerId = T.Id
											AND TV.VenueId = V.Id
		WHERE TV.Id IS NULL;
	END

	/* Ensure that the Minimum Payment Types are inserted for every Organisation.*/
	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - Ensure that the Minimum Payment Types are inserted for every Organisation.';
	BEGIN
		IF OBJECT_ID('tempdb..#MissingOrgPaymentType', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #MissingOrgPaymentType;
		END

		--Get The Missing Organisation Payment Types
		SELECT DISTINCT
			O.Id AS OrganisationId
			, PTN.PaymentTypeName AS PaymentTypeName
		INTO #MissingOrgPaymentType
		FROM Organisation O
		, (SELECT 'Full' AS PaymentTypeName
			UNION
			SELECT 'Partial' AS PaymentTypeName
			) PTN
		WHERE NOT EXISTS (
						SELECT *
						FROM Organisation O2
						INNER JOIN OrganisationPaymentType OPT ON OPT.OrganisationId = O2.Id
						INNER JOIN PaymentType PT ON PT.Id = OPT.PaymentTypeId
						WHERE O2.Id = O.Id
						AND PT.[Name] = PTN.PaymentTypeName
						)
		;

		INSERT INTO PaymentType ([Name])
		SELECT DISTINCT PaymentTypeName + '!~!' + CAST(OrganisationId AS VARCHAR) --Temp so that we can IDENTIFY THEM
		FROM #MissingOrgPaymentType;

		IF OBJECT_ID('tempdb..#OrgPaymentTypeToInsert', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #OrgPaymentTypeToInsert;
		END

		SELECT
			SUBSTRING(PT.[Name]
						, 1
						, CHARINDEX('!~!',PT.[Name],1) - 1
						) AS NewNameValue
			, CAST(SUBSTRING([Name]
						, CHARINDEX('!~!',PT.[Name],1) + 3
						, LEN(PT.[Name]) - CHARINDEX('!~!',PT.[Name],1) - 2
						) AS INT) AS OrganisationId
			, PT.Id AS PaymentTypeId
		INTO #OrgPaymentTypeToInsert
		FROM PaymentType PT
		WHERE PT.[Name] LIKE ('%!~!%');

		INSERT INTO OrganisationPaymentType (OrganisationId, PaymentTypeId)
		SELECT DISTINCT I.OrganisationId, I.PaymentTypeId
		FROM #OrgPaymentTypeToInsert I
		LEFT JOIN OrganisationPaymentType OPT ON OPT.OrganisationId = I.OrganisationId
												AND OPT.PaymentTypeId = I.PaymentTypeId
		WHERE OPT.Id IS NULL;

		UPDATE PT
		SET PT.[Name] = I.NewNameValue
		FROM #OrgPaymentTypeToInsert I
		INNER JOIN PaymentType PT ON PT.Id = I.PaymentTypeId
		;

	END

	/* Ensure Organisation Regions are Linked */
	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - Ensure Organisation Regions are Linked';
	BEGIN
		INSERT INTO [dbo].[OrganisationRegion] (OrganisationId, RegionId, Disabled)
		SELECT DISTINCT
			O.Id		AS OrganisationId
			, R.Id		AS RegionId
			, 'False'	AS Disabled
		FROM [dbo].[Organisation] O
		, [dbo].[Region] R
		WHERE NOT EXISTS (SELECT *
							FROM [dbo].[OrganisationRegion] ORe
							WHERE ORe.OrganisationId = O.Id
							AND ORe.RegionId = R.Id)
		;
	END

	/* Ensure Training Session Data Exists */
	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - Ensure Training Session Data Exists';
	BEGIN
		IF OBJECT_ID('tempdb..#TrainingSession', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #TrainingSession;
		END

		SELECT *
		INTO #TrainingSession
		FROM(
			SELECT
				1								AS Number
				, 'AM'							AS Title
				, '08:00'						AS StartTime
				, '11:59'						AS EndTime
				, GETDATE()						AS DateCreated
				, dbo.udfGetSystemUserId()		AS CreatedByUserId
				, GETDATE()						AS DateUpdated
				, dbo.udfGetSystemUserId()		AS UpdatedByUserId
			UNION SELECT
				2								AS Number
				, 'PM'							AS Title
				, '12:00'						AS StartTime
				, '16:59'						AS EndTime
				, GETDATE()						AS DateCreated
				, dbo.udfGetSystemUserId()		AS CreatedByUserId
				, GETDATE()						AS DateUpdated
				, dbo.udfGetSystemUserId()		AS UpdatedByUserId
			UNION SELECT
				3								AS Number
				, 'EVE'							AS Title
				, '17:00'						AS StartTime
				, '23:59'						AS EndTime
				, GETDATE()						AS DateCreated
				, dbo.udfGetSystemUserId()		AS CreatedByUserId
				, GETDATE()						AS DateUpdated
				, dbo.udfGetSystemUserId()		AS UpdatedByUserId
			UNION SELECT
				4								AS Number
				, 'AM & PM'						AS Title
				, '08:00'						AS StartTime
				, '16:59'						AS EndTime
				, GETDATE()						AS DateCreated
				, dbo.udfGetSystemUserId()		AS CreatedByUserId
				, GETDATE()						AS DateUpdated
				, dbo.udfGetSystemUserId()		AS UpdatedByUserId
			UNION SELECT
				5								AS Number
				, 'PM & EVE'						AS Title
				, '12:00'						AS StartTime
				, '23:59'						AS EndTime
				, GETDATE()						AS DateCreated
				, dbo.udfGetSystemUserId()		AS CreatedByUserId
				, GETDATE()						AS DateUpdated
				, dbo.udfGetSystemUserId()		AS UpdatedByUserId
			UNION SELECT
				6								AS Number
				, 'AM & PM & EVE'				AS Title
				, '08:00'						AS StartTime
				, '23:59'						AS EndTime
				, GETDATE()						AS DateCreated
				, dbo.udfGetSystemUserId()		AS CreatedByUserId
				, GETDATE()						AS DateUpdated
				, dbo.udfGetSystemUserId()		AS UpdatedByUserId
			) TS

		INSERT INTO [dbo].[TrainingSession] (
			Number
			, Title
			, StartTime
			, EndTime
			, DateCreated
			, CreatedByUserId
			, DateUpdated
			, UpdatedByUserId
			)
		SELECT
			TS1.Number
			, TS1.Title
			, TS1.StartTime
			, TS1.EndTime
			, TS1.DateCreated
			, TS1.CreatedByUserId
			, TS1.DateUpdated
			, TS1.UpdatedByUserId
		FROM #TrainingSession TS1
		LEFT JOIN [dbo].[TrainingSession] TS2 ON TS2.Number = TS1.Number
		WHERE TS2.Id IS NULL;

		UPDATE TS2
			SET TS2.Title = TS1.Title
			, TS2.StartTime = TS1.StartTime
			, TS2.EndTime = TS1.EndTime
			, TS2.DateUpdated = GETDATE()
			, TS2.UpdatedByUserId = dbo.udfGetSystemUserId()
		FROM #TrainingSession TS1
		INNER JOIN [dbo].[TrainingSession] TS2 ON TS2.Number = TS1.Number
		WHERE TS2.Title != TS1.Title
		OR TS2.StartTime != TS1.StartTime
		OR TS2.EndTime != TS1.EndTime
		;
	END

	/* Ensure Table OrganisationPayment is Populated Correctly */
	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - Ensure Table OrganisationPayment is Populated Correctly';
	BEGIN
		IF OBJECT_ID('tempdb..#OrganisationPayment', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #OrganisationPayment;
		END

		SELECT DISTINCT
			(CASE WHEN OPT.OrganisationId IS NOT NULL THEN OPT.OrganisationId
				WHEN PM.OrganisationId IS NOT NULL THEN PM.OrganisationId
				WHEN CO.OrganisationId IS NOT NULL THEN CO.OrganisationId
				WHEN OU.OrganisationId IS NOT NULL AND SAU.Id IS NULL THEN OU.OrganisationId
				ELSE NULL END)		AS OrganisationId
			, I.Id					AS PaymentId
		INTO #OrganisationPayment
		FROM [dbo].Payment I
		LEFT JOIN [dbo].[OrganisationPaymentType] OPT		ON OPT.PaymentTypeId = I.PaymentTypeId	--Find Organisation By Payment Type
		LEFT JOIN [dbo].[PaymentMethod] PM					ON PM.Id = I.PaymentMethodId -- In Case No Payment Type Use Payment Method to Get Organisation
		LEFT JOIN [dbo].[ClientPayment] CP					ON CP.PaymentId = I.Id
		LEFT JOIN [dbo].[ClientOrganisation] CO				ON CO.ClientId = CP.ClientId
		LEFT JOIN [dbo].[OrganisationUser] OU				ON OU.UserId = I.CreatedByUserId -- If No Payment Method The Use the User Id
		LEFT JOIN [dbo].[SystemAdminUser] SAU				ON SAU.UserId = I.CreatedByUserId -- DO Not Allow User Organisation if a System Administration User Id is Used
		LEFT JOIN [dbo].[OrganisationPayment] OP			ON OP.PaymentId = I.Id
		WHERE OP.Id IS NULL; --Only Insert if Not Already on the Table

		/*
			NB. There is a Chance here that a Payment Created by a System Administrator will not get assigned to an Organisation.
				There is a Trigger in the Table ClientPayment that will pick it up there.
		*/
		ALTER TABLE #OrganisationPayment
		ADD TempId INT IDENTITY(1,1);

		INSERT INTO [dbo].[OrganisationPayment] (OrganisationId, PaymentId)
		SELECT DISTINCT
			OP.OrganisationId		AS OrganisationId
			, OP.PaymentId			AS PaymentId
		FROM #OrganisationPayment OP
		INNER JOIN (SELECT OP3.PaymentId AS PaymentId, MIN(TempId) AS ValidId
					FROM #OrganisationPayment OP3
					GROUP BY OP3.PaymentId
					) VOP		ON VOP.PaymentId = OP.PaymentId
								AND VOP.ValidId = OP.TempId
		INNER JOIN Organisation O							ON O.Id = OP.OrganisationId -- Only Valid Organisations. Will Exclude NULLS too
		LEFT JOIN [dbo].[OrganisationPayment] OP2			ON OP2.PaymentId = OP.PaymentId
		WHERE OP.OrganisationId IS NOT NULL
		AND OP2.Id IS NULL; --Only Insert if Not Already on the Table
	END

	--/*Ensure Payment Card Type is populated*/
	--SET @processNumber = @processNumber + 1;
	--EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - Ensure Payment Card Type is populated';
	--BEGIN

	--	INSERT INTO [dbo].[PaymentCardType] ([Name], DisplayName)
	--	SELECT T.[Name], T.DisplayName
	--	FROM (
	--		SELECT 'DELTA' AS [Name], 'Visa Debit' AS DisplayName
	--		UNION SELECT 'ELECTRON' AS [Name], 'Visa Electron' AS DisplayName
	--		UNION SELECT 'VISA' AS [Name], 'Visa' AS DisplayName
	--		UNION SELECT 'MASTERCARD' AS [Name], 'Mastercard' AS DisplayName
	--		UNION SELECT 'MASTERCARDDEBIT' AS [Name], 'Mastercard Debit' AS DisplayName
	--		UNION SELECT 'DINERS' AS [Name], 'Diners Club' AS DisplayName
	--		UNION SELECT 'MAESTRO' AS [Name], 'Maestro' AS DisplayName
	--		UNION SELECT 'DISCOVER' AS [Name], 'Discover' AS DisplayName
	--		UNION SELECT 'AMEX' AS [Name], 'American Express' AS DisplayName
	--		UNION SELECT 'JCB' AS [Name], 'JCB' AS DisplayName
	--		) AS T
	--	LEFT JOIN [dbo].[PaymentCardType] PCT ON PCT.[Name] = T.[Name]
	--	WHERE PCT.Id IS NULL;

	--END

	/*Ensure PaymentCardTypePaymentMethod is populated*/
	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - Ensure PaymentCardTypePaymentMethod is populated';
	BEGIN
		IF OBJECT_ID('tempdb..#PaymentCardTypePaymentMethodPopulation', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #PaymentCardTypePaymentMethodPopulation;
		END

		SELECT PCT.Id as PaymentCardTypeId,  PM.Id PaymentMethodId
		INTO #PaymentCardTypePaymentMethodPopulation
		FROM PAYMENTCARDTYPE PCT
		CROSS JOIN dbo.PaymentMethod PM
		WHERE (PCT.[Name] = 'DELTA' AND PM.[Name] = 'Debit Card')
				OR (PCT.[Name] = 'ELECTRON' AND PM.[Name] = 'Credit Card')
				OR (PCT.[Name] = 'VISA' AND PM.[Name] = 'Credit Card')
				OR (PCT.[Name] = 'MASTERCARD' AND PM.[Name] = 'Credit Card')
				OR (PCT.[Name] = 'MASTERCARDDEBIT' AND PM.[Name] = 'Debit Card')
				OR (PCT.[Name] = 'DINERS' AND PM.[Name] = 'Credit Card')
				OR (PCT.[Name] = 'MAESTRO' AND PM.[Name] = 'Credit Card')
				OR (PCT.[Name] = 'DISCOVER' AND PM.[Name] = 'Credit Card')
				OR (PCT.[Name] = 'AMEX' AND PM.[Name] = 'Credit Card')
				OR (PCT.[Name] = 'JCB' AND PM.[Name] = 'Credit Card')

			INSERT INTO dbo.PaymentCardTypePaymentMethod(PaymentCardTypeId, PaymentMethodId)
			SELECT PaymentCardTypeId, PaymentMethodId
			FROM #PaymentCardTypePaymentMethodPopulation
			WHERE NOT EXISTS(SELECT PaymentCardTypeId, PaymentMethodId
							 FROM dbo.PaymentCardTypePaymentMethod PCTM
							 WHERE PCTM.PaymentCardTypeId = #PaymentCardTypePaymentMethodPopulation.PaymentCardTypeId
								AND PCTM.PaymentMethodId = #PaymentCardTypePaymentMethodPopulation.PaymentMethodId)
		;

		IF OBJECT_ID('tempdb..#PaymentCardTypePaymentMethodPopulation', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #PaymentCardTypePaymentMethodPopulation;
		END

	END

	/*Ensure Course Type Fee is populated*/
	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - Ensure Course Type Fee is populated';
	--BEGIN

	--	INSERT INTO [dbo].[CourseTypeFee]
	--		(
	--		OrganisationId
	--		, CourseTypeId
	--		, EffectiveDate
	--		, CourseFee
	--		, BookingSupplement
	--		, PaymentDays
	--		, AddedByUserId
	--		, DateAdded
	--		)
	--	SELECT
	--		O.Id						AS OrganisationId
	--		, CT.Id						AS CourseTypeId
	--		, (GETDATE() - 1)			AS EffectiveDate
	--		, 45.67						AS CourseFee
	--		, 0							AS BookingSupplement
	--		, 7							AS PaymentDays
	--		, dbo.udfGetSystemUserId()	AS AddedByUserId
	--		, GetDate()					AS DateAdded
	--	FROM Organisation O
	--	INNER JOIN CourseType CT		ON CT.OrganisationId = O.Id
	--	LEFT JOIN CourseTypeFee CTF		ON CTF.OrganisationId = O.Id
	--									AND CTF.CourseTypeId = CT.Id
	--	WHERE CTF.Id IS NULL;


	--	INSERT INTO [dbo].[CourseTypeCategoryFee]
	--		(
	--		OrganisationId
	--		, CourseTypeId
	--		, CourseTypeCategoryId
	--		, EffectiveDate
	--		, CourseFee
	--		, BookingSupplement
	--		, PaymentDays
	--		, AddedByUserId
	--		, DateAdded
	--		, [Disabled]
	--		)
	--	SELECT
	--		O.Id						AS OrganisationId
	--		, CT.Id						AS CourseTypeId
	--		, CTC.Id					AS CourseTypeCategoryId
	--		, (GETDATE() - 1)			AS EffectiveDate
	--		, 45.67						AS CourseFee
	--		, 0							AS BookingSupplement
	--		, 7							AS PaymentDays
	--		, dbo.udfGetSystemUserId()	AS AddedByUserId
	--		, GetDate()					AS DateAdded
	--		, 'False'					AS [Disabled]
	--	FROM Organisation O
	--	INNER JOIN CourseType CT				ON CT.OrganisationId = O.Id
	--	INNER JOIN CourseTypeCategory CTC		ON CTC.CourseTypeId = CT.Id
	--	LEFT JOIN CourseTypeCategoryFee CTCF	ON CTCF.OrganisationId = O.Id
	--											AND CTCF.CourseTypeId = CT.Id
	--											AND CTCF.CourseTypeCategoryId = CTC.Id
	--	WHERE CTCF.Id IS NULL;
	--END

	/* ENSURE CourseVenueEmailReason is Populated */
	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - ENSURE CourseVenueEmailReason is Populated';
	BEGIN
		INSERT INTO [dbo].[CourseVenueEmailReason] ([Name])
		SELECT [Name]
		FROM (SELECT 'Venue Availability Request' AS [Name]
			UNION SELECT 'Course Date Change - Venue Availability Request' AS [Name]
			) T
		WHERE T.[Name] NOT IN (SELECT DISTINCT [Name] FROM [dbo].[CourseVenueEmailReason]);
	END

	/*
	--Ensure uspEnsureTrainerLimitationAndSummaryDataSetup is in dbo.AnnualSPJob
	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - Ensure uspEnsureTrainerLimitationAndSummaryDataSetup is in dbo.AnnualSPJob';
	BEGIN
		BEGIN
			INSERT INTO dbo.AnnualSPJob (
				StoredProcedureName
				,DueDate
				,[Disabled]
				)
			SELECT
				'uspEnsureTrainerLimitationAndSummaryDataSetup' AS StoredProcedureName
				, CAST('01-Jan-2017' AS DATETIME)				AS DueDate
				, 'False'										AS [Disabled]
			WHERE NOT EXISTS (SELECT *
							FROM AnnualSPJob
							WHERE StoredProcedureName = 'uspEnsureTrainerLimitationAndSummaryDataSetup')
		END
	END
	--*/

	--Ensure Certain SPs are in dbo.PeriodicalSPJob
	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - Ensure Certain SPs are in dbo.PeriodicalSPJob';
	BEGIN
		IF OBJECT_ID('tempdb..#tempPeriodicalSPJob', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #tempPeriodicalSPJob;
		END

		SELECT
			StoredProcedureName
			, DueDate
			, DueDateTime
			, [Disabled]
			, RunEveryAfterMinutes
			, RunAfterDays
			, RunAfterMonths
			, RunOnlyOnWeekends
		INTO #tempPeriodicalSPJob
		FROM (
			SELECT
				'uspEnsureTrainerLimitationAndSummaryDataSetup' AS StoredProcedureName
				, CAST('01-Jan-2017' AS DATETIME)				AS DueDate
				, CAST('01-Jan-2017' AS DATETIME)				AS DueDateTime
				, 'False'										AS [Disabled]
				, 0												AS RunEveryAfterMinutes
				, 0												AS RunAfterDays
				, 12											AS RunAfterMonths
				, 'False'										AS RunOnlyOnWeekends	

			UNION SELECT
				'uspDashboardDataRefresh'						AS StoredProcedureName
				, CAST('01-Jan-2017' AS DATETIME)				AS DueDate
				, CAST('01-Jan-2017' AS DATETIME)				AS DueDateTime
				, 'True'										AS [Disabled]
				, 5												AS RunEveryAfterMinutes
				, 0												AS RunAfterDays
				, 0												AS RunAfterMonths
				, 'False'										AS RunOnlyOnWeekends	

			UNION SELECT
				'uspDashboardDataRefresh_Client'				AS StoredProcedureName
				, CAST('01-Jan-2017' AS DATETIME)				AS DueDate
				, CAST('01-Jan-2017' AS DATETIME)				AS DueDateTime
				, 'False'										AS [Disabled]
				, 2												AS RunEveryAfterMinutes
				, 0												AS RunAfterDays
				, 0												AS RunAfterMonths
				, 'False'										AS RunOnlyOnWeekends	

			UNION SELECT
				'uspDashboardDataRefresh_Course'				AS StoredProcedureName
				, CAST('17-Jul-2017 17:01' AS DATETIME)				AS DueDate
				, CAST('17-Jul-2017 17:01' AS DATETIME)				AS DueDateTime
				, 'False'										AS [Disabled]
				, 10											AS RunEveryAfterMinutes
				, 0												AS RunAfterDays
				, 0												AS RunAfterMonths
				, 'False'										AS RunOnlyOnWeekends	

			UNION SELECT
				'uspDashboardDataRefresh_DocumentStat'			AS StoredProcedureName
				, CAST('17-Jul-2017 17:11' AS DATETIME)			AS DueDate
				, CAST('17-Jul-2017 17:11' AS DATETIME)			AS DueDateTime
				, 'False'										AS [Disabled]
				, 60											AS RunEveryAfterMinutes
				, 0												AS RunAfterDays
				, 0												AS RunAfterMonths
				, 'False'										AS RunOnlyOnWeekends	

			UNION SELECT
				'uspDashboardDataRefresh_DORSOfferWithdrawn'	AS StoredProcedureName
				, CAST('17-Jul-2017 17:07' AS DATETIME)			AS DueDate
				, CAST('17-Jul-2017 17:07' AS DATETIME)			AS DueDateTime
				, 'False'										AS [Disabled]
				, 120											AS RunEveryAfterMinutes
				, 0												AS RunAfterDays
				, 0												AS RunAfterMonths
				, 'False'										AS RunOnlyOnWeekends	

			UNION SELECT
				'uspDashboardDataRefresh_Email'					AS StoredProcedureName
				, CAST('16-Jul-2017 22:00' AS DATETIME)			AS DueDate
				, CAST('16-Jul-2017 22:00' AS DATETIME)			AS DueDateTime
				, 'False'										AS [Disabled]
				, 0												AS RunEveryAfterMinutes
				, 1												AS RunAfterDays
				, 0												AS RunAfterMonths
				, 'False'										AS RunOnlyOnWeekends	

			UNION SELECT
				'uspDashboardDataRefresh_OnlineClientsSpecialRequirement'	AS StoredProcedureName
				, CAST('17-Jul-2017 17:03' AS DATETIME)			AS DueDate
				, CAST('17-Jul-2017 17:03' AS DATETIME)			AS DueDateTime
				, 'False'										AS [Disabled]
				, 30											AS RunEveryAfterMinutes
				, 0												AS RunAfterDays
				, 0												AS RunAfterMonths
				, 'False'										AS RunOnlyOnWeekends	

			UNION SELECT
				'uspDashboardDataRefresh_Payment'				AS StoredProcedureName
				, CAST('17-Jul-2017 17:01' AS DATETIME)			AS DueDate
				, CAST('17-Jul-2017 17:01' AS DATETIME)			AS DueDateTime
				, 'False'										AS [Disabled]
				, 5												AS RunEveryAfterMinutes
				, 0												AS RunAfterDays
				, 0												AS RunAfterMonths
				, 'False'										AS RunOnlyOnWeekends	

			UNION SELECT
				'uspDashboardDataRefresh_UnpaidBookedCourse'	AS StoredProcedureName
				, CAST('17-Jul-2017 17:17' AS DATETIME)			AS DueDate
				, CAST('17-Jul-2017 17:17' AS DATETIME)			AS DueDateTime
				, 'False'										AS [Disabled]
				, 30											AS RunEveryAfterMinutes
				, 0												AS RunAfterDays
				, 0												AS RunAfterMonths
				, 'False'										AS RunOnlyOnWeekends	

			UNION SELECT
				'uspAllocateUnallocatedEmailToClient'			AS StoredProcedureName
				, CAST('19-Jul-2017 21:23' AS DATETIME)			AS DueDate
				, CAST('19-Jul-2017 21:23' AS DATETIME)			AS DueDateTime
				, 'False'										AS [Disabled]
				, 20											AS RunEveryAfterMinutes
				, 0												AS RunAfterDays
				, 0												AS RunAfterMonths
				, 'False'										AS RunOnlyOnWeekends	
						
			UNION SELECT
				'uspEnsureReferringAuthoritySetForClient'		AS StoredProcedureName
				, CAST('19-Jul-2017 22:31' AS DATETIME)			AS DueDate
				, CAST('19-Jul-2017 22:31' AS DATETIME)			AS DueDateTime
				, 'False'										AS [Disabled]
				, 75											AS RunEveryAfterMinutes
				, 0												AS RunAfterDays
				, 0												AS RunAfterMonths
				, 'False'										AS RunOnlyOnWeekends	
					
			UNION SELECT
				'uspCheckForDuplicateClientsNotifySystemAdmins'	AS StoredProcedureName
				, CAST('23-Jul-2017 23:38' AS DATETIME)			AS DueDate
				, CAST('23-Jul-2017 23:38' AS DATETIME)			AS DueDateTime
				, 'False'										AS [Disabled]
				, 720											AS RunEveryAfterMinutes
				, 0												AS RunAfterDays
				, 0												AS RunAfterMonths
				, 'False'										AS RunOnlyOnWeekends	
				
						
			UNION SELECT
				'uspDashboardDataRefresh_UnableToUpdateInDORS'	AS StoredProcedureName
				, CAST('02-Aug-2017 14:00' AS DATETIME)			AS DueDate
				, CAST('02-Aug-2017 14:00' AS DATETIME)			AS DueDateTime
				, 'False'										AS [Disabled]
				, 30											AS RunEveryAfterMinutes
				, 0												AS RunAfterDays
				, 0												AS RunAfterMonths		
				, 'False'										AS RunOnlyOnWeekends	

			UNION SELECT
				'uspDashboardDataRefresh_AttendanceNotUploadedToDORS'	AS StoredProcedureName
				, CAST('11-Aug-2017 09:26' AS DATETIME)			AS DueDate
				, CAST('11-Aug-2017 09:26' AS DATETIME)			AS DueDateTime
				, 'False'										AS [Disabled]
				, 30											AS RunEveryAfterMinutes
				, 0												AS RunAfterDays
				, 0												AS RunAfterMonths
				, 'False'										AS RunOnlyOnWeekends	
					
			UNION SELECT
				'uspInsertAnyMissingClientPaymentData'			AS StoredProcedureName
				, CAST('05-Aug-2017 07:16' AS DATETIME)			AS DueDate
				, CAST('05-Aug-2017 07:16' AS DATETIME)			AS DueDateTime
				, 'False'										AS [Disabled]
				, 60											AS RunEveryAfterMinutes
				, 0												AS RunAfterDays
				, 0												AS RunAfterMonths
				, 'False'										AS RunOnlyOnWeekends	
			UNION SELECT
				'uspVenuesWithNoRegionAssigned'					AS StoredProcedureName
				, CAST('05-Aug-2017 07:16' AS DATETIME)			AS DueDate
				, CAST('05-Aug-2017 07:16' AS DATETIME)			AS DueDateTime
				, 'False'										AS [Disabled]
				, 720											AS RunEveryAfterMinutes
				, 0												AS RunAfterDays
				, 0												AS RunAfterMonths	
				, 'False'										AS RunOnlyOnWeekends	
			UNION SELECT
				'uspArchiveClientEmail'							AS StoredProcedureName
				, CAST('18-Nov-2017 07:16' AS DATETIME)			AS DueDate
				, CAST('18-Nov-2017 07:16' AS DATETIME)			AS DueDateTime
				, 'False'										AS [Disabled]
				, 0												AS RunEveryAfterMinutes
				, 0												AS RunAfterDays
				, 0												AS RunAfterMonths	
				, 'True'										AS RunOnlyOnWeekends
			UNION SELECT
				'uspMarkForDeletionRecentlyCreatedDuplicates'	AS StoredProcedureName
				, CAST('18-Nov-2017 07:00' AS DATETIME)			AS DueDate
				, CAST('18-Nov-2017 07:00' AS DATETIME)			AS DueDateTime
				, 'False'										AS [Disabled]
				, 720											AS RunEveryAfterMinutes
				, 0												AS RunAfterDays
				, 0												AS RunAfterMonths
				, 'False'										AS RunOnlyOnWeekends	
			) T
			
				
		INSERT INTO dbo.PeriodicalSPJob (
			StoredProcedureName
			, DueDate
			, DueDateTime
			, [Disabled]
			, RunEveryAfterMinutes
			, RunAfterDays
			, RunAfterMonths
			, RunOnlyOnWeekends
			)
		SELECT
			StoredProcedureName
			, DueDate
			, DueDateTime
			, [Disabled]
			, RunEveryAfterMinutes
			, RunAfterDays
			, RunAfterMonths
			, RunOnlyOnWeekends
		FROM #tempPeriodicalSPJob T
		WHERE NOT EXISTS (SELECT *
						FROM PeriodicalSPJob P
						WHERE P.StoredProcedureName = T.StoredProcedureName)
		;

		UPDATE PSPJ
		SET PSPJ.[Disabled] = T.[Disabled]
		, PSPJ.RunEveryAfterMinutes = T.RunEveryAfterMinutes
		, PSPJ.RunAfterDays = T.RunAfterDays
		, PSPJ.RunAfterMonths = T.RunAfterMonths
		FROM #tempPeriodicalSPJob T
		INNER JOIN PeriodicalSPJob PSPJ ON PSPJ.StoredProcedureName = T.StoredProcedureName
		WHERE PSPJ.[Disabled] <> T.[Disabled]
		OR PSPJ.RunEveryAfterMinutes <> T.RunEveryAfterMinutes
		OR PSPJ.RunAfterDays <> T.RunAfterDays
		OR PSPJ.RunAfterMonths <> T.RunAfterMonths
		;

	END

	/* ENSURE CourseDocumentRequestType is Populated */
	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - ENSURE CourseDocumentRequestType is Populated';
	BEGIN
		INSERT INTO dbo.CourseDocumentRequestType ([Name], [Description])
		SELECT [Name], [Description]
		FROM (
			SELECT 'Course Attendance Sign-In' AS [Name]
				, 'Will contain a list of all Expected on the Course and Course Information. Can be used for Client Registration.' AS [Description]
			UNION
			SELECT 'Course Register' AS [Name]
				, 'Will contain a list of all Expected on the Course and Course Information. Can be used for course registration.' AS [Description]
		) CDRT
		WHERE NOT EXISTS (
							SELECT *
							FROM dbo.CourseDocumentRequestType cd
							WHERE cdrt.[Name] = cd.[Name]
							AND cdrt.[Description] = cd.[Description]
						);
	END

	/* Correct Client Phone Data*/
	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - Correct Client Phone Data';
	BEGIN
		--Ensure the Default Number has been set.

		--Set the Default Number to the First Entry
		UPDATE CP3
		SET CP3.DefaultNumber = 'True'
		FROM (
			SELECT CP.ClientId, MIN(Id) AS Id
			FROM ClientPhone CP
			WHERE CP.DefaultNumber IS NULL
			AND NOT EXISTS (SELECT *
							FROM ClientPhone CP2
							WHERE CP2.ClientId = CP.ClientId
							AND ISNULL(CP2.DefaultNumber, 'False') = 'True')
			GROUP BY CP.ClientId
			) CPU
		INNER JOIN ClientPhone CP3 ON CP3.Id = CPU.Id;

		--Set Default to False for the Rest
		UPDATE ClientPhone
		SET DefaultNumber = 'False'
		WHERE DefaultNumber IS NULL;
	END


	/* ENSURE RefundMethod is Populated */
	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - ENSURE RefundMethod is Populated';
	BEGIN
		INSERT INTO dbo.RefundMethod ([Name], OrganisationId)
		SELECT OrgRM.[Name], OrgRM.OrganisationId
		FROM (
			SELECT PMT.[Name], o.Id AS OrganisationId
			FROM (
				SELECT 'Credit Card' AS [Name]
				UNION
				SELECT 'Debit Card' AS [Name]
				UNION
				SELECT 'Cheque' AS [Name]
				UNION
				SELECT 'Banker''s Draft' AS [Name]
				UNION
				SELECT 'Postal Order' AS [Name]
				UNION
				SELECT 'Bank Transfer' AS [Name]
				UNION
				SELECT 'Unknown' AS [Name]
				) PMT
			CROSS JOIN dbo.Organisation o
			) OrgRM
		WHERE NOT EXISTS (
							SELECT *
							FROM dbo.RefundMethod rm
							WHERE OrgRM.[Name] = rm.[Name]
							AND OrgRM.OrganisationId = rm.OrganisationId
						);
	END

	/* ENSURE RefundType is Populated */
	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - ENSURE RefundType is Populated';
	BEGIN
		INSERT INTO dbo.RefundType ([Name], OrganisationId)
		SELECT OrgRT.[Name], OrgRT.OrganisationId
		FROM (
			SELECT RT.[Name], o.Id AS OrganisationId
			FROM (
				SELECT 'Partial Refund' AS [Name]
				UNION
				SELECT 'Full Refund' AS [Name]
				UNION
				SELECT 'Cancelled Course' AS [Name]
				UNION
				SELECT 'Over Payment' AS [Name]
				UNION
				SELECT 'Unknown' AS [Name]
				) RT
			CROSS JOIN dbo.Organisation o
			) OrgRT
		WHERE NOT EXISTS (
							SELECT *
							FROM dbo.RefundType rt
							WHERE OrgRT.[Name] = rt.[Name]
							AND OrgRT.OrganisationId = rt.OrganisationId
						);
	END
	
	/* Ensure Note Types Exist */
	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - Ensure Note Types Exist';
	BEGIN
		IF OBJECT_ID('tempdb..#NoteType', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #NoteType;
		END

		SELECT *
		INTO #NoteType
		FROM (
			SELECT 'General' AS Title
			UNION SELECT 'Instructor' AS Title
			UNION SELECT 'Register' AS Title
			UNION SELECT 'Private' AS Title
			) NT;

		INSERT INTO [dbo].[NoteType] (Name)
		SELECT DISTINCT New_NT.Title AS Name
		FROM #NoteType New_NT
		LEFT JOIN [dbo].[NoteType] NT ON NT.Name = New_NT.Title
		WHERE NT.Id IS NULL;

		DELETE #NoteType
		WHERE Title = 'Private';

		INSERT INTO [dbo].[CourseNoteType] (Title)
		SELECT DISTINCT New_NT.Title
		FROM #NoteType New_NT
		LEFT JOIN [dbo].[CourseNoteType] NT ON NT.Title = New_NT.Title
		WHERE NT.Id IS NULL;

	END

	/* Ensure Task Categories Exist */
	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - Ensure Task Categories Exist';
	BEGIN
		IF OBJECT_ID('tempdb..#TaskCategory', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #TaskCategory;
		END

		SELECT *
		INTO #TaskCategory
		FROM (
			SELECT 'Client Notification' AS Title, 'Client Notification' AS [Description], 'LightYellow' AS ColourName
			UNION SELECT 'Course Notification' AS Title, 'Course Notification' AS [Description], 'LightYellow' AS ColourName
			UNION SELECT 'Trainer Notification' AS Title, 'Trainer Notification' AS [Description], 'LightYellow' AS ColourName
			UNION SELECT 'Venue Notification' AS Title, 'Venue Notification' AS [Description], 'LightYellow' AS ColourName
			UNION SELECT 'Other' AS Title, 'Other' AS [Description], 'LightYellow' AS ColourName
			UNION SELECT 'General' AS Title, 'General' AS [Description], 'LightYellow' AS ColourName
			) TC;

		INSERT INTO [dbo].[TaskCategory] (Title, [Description], [Disabled], CreatedByUserId, DateCreated, ColourName)
		SELECT DISTINCT
			New_TC.Title				AS Title
			, New_TC.[Description]		AS [Description]
			, 'False'					AS [Disabled]
			, dbo.udfGetSystemUserId()	AS CreatedByUserId
			, GETDATE()					AS DateCreated
			, New_TC.ColourName		AS ColourName
		FROM #TaskCategory New_TC
		LEFT JOIN [dbo].[TaskCategory] TC ON TC.Title = New_TC.Title
		WHERE TC.Id IS NULL;

		UPDATE TC
		SET TC.[Description] = New_TC.[Description]
		, TC.ColourName = New_TC.ColourName
		FROM #TaskCategory New_TC
		INNER JOIN TaskCategory TC					ON TC.Title = New_TC.Title
		LEFT JOIN TaskCategoryForOrganisation TCFO	ON TCFO.TaskCategoryId = TC.Id
		WHERE TCFO.Id IS NULL
		AND (TC.[Description] != New_TC.[Description]
			OR TC.Title != New_TC.Title);


	END


	/* Ensure Task Actions Exist */
	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - Ensure Task Actions Exist';
	BEGIN
		IF OBJECT_ID('tempdb..#TaskAction', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #TaskAction;
		END


		SELECT *
		INTO #TaskAction
		FROM (
			SELECT
				'Client – Expired Critical Date' AS [Name]
				, 'Client with an expired DORS critical date.' AS [Description]
				, 2 AS PriorityNumber
				, CAST('True' AS BIT) AS AssignToOrganisation
				, CAST('False' AS BIT) AS AssignToOrganisationAdminstrators
				, CAST('False' AS BIT) AS AssignToOrganisationSupportGroup
				, CAST('False' AS BIT) AS AssignToAtlasSystemAdministrators
				, CAST('False' AS BIT) AS AssignToAtlasSystemSupportGroup
			UNION
			SELECT
				'Client - Booked and Paid Online - Additional Requirements' AS [Name]
				, 'Client who has booked and paid online and has Additional Requirements' AS [Description]
				, 3 AS PriorityNumber
				, CAST('True' AS BIT) AS AssignToOrganisation
				, CAST('False' AS BIT) AS AssignToOrganisationAdminstrators
				, CAST('False' AS BIT) AS AssignToOrganisationSupportGroup
				, CAST('False' AS BIT) AS AssignToAtlasSystemAdministrators
				, CAST('False' AS BIT) AS AssignToAtlasSystemSupportGroup
			UNION
			SELECT
				'Client – Overdue Course Payment' AS [Name]
				, 'Client with overdue Course Payment' AS [Description]
				, 2 AS PriorityNumber
				, CAST('False' AS BIT) AS AssignToOrganisation
				, CAST('False' AS BIT) AS AssignToOrganisationAdminstrators
				, CAST('True' AS BIT) AS AssignToOrganisationSupportGroup
				, CAST('False' AS BIT) AS AssignToAtlasSystemAdministrators
				, CAST('False' AS BIT) AS AssignToAtlasSystemSupportGroup
			UNION
			SELECT
				'Course - Overdue Payment' AS [Name]
				, 'Course with Overdue Payment' AS [Description]
				, 2 AS PriorityNumber
				, CAST('False' AS BIT) AS AssignToOrganisation
				, CAST('False' AS BIT) AS AssignToOrganisationAdminstrators
				, CAST('True' AS BIT) AS AssignToOrganisationSupportGroup
				, CAST('False' AS BIT) AS AssignToAtlasSystemAdministrators
				, CAST('False' AS BIT) AS AssignToAtlasSystemSupportGroup
			UNION
			SELECT
				'Course - Overdue Attendance' AS [Name]
				, 'Course with overdue Attendance updates from Trainers' AS [Description]
				, 3 AS PriorityNumber
				, CAST('False' AS BIT) AS AssignToOrganisation
				, CAST('False' AS BIT) AS AssignToOrganisationAdminstrators
				, CAST('True' AS BIT) AS AssignToOrganisationSupportGroup
				, CAST('False' AS BIT) AS AssignToAtlasSystemAdministrators
				, CAST('False' AS BIT) AS AssignToAtlasSystemSupportGroup
			UNION
			SELECT
				'Venue - DORS Validated' AS [Name]
				, 'New Venue has been validated by DORS' AS [Description]
				, 3 AS PriorityNumber
				, CAST('True' AS BIT) AS AssignToOrganisation
				, CAST('False' AS BIT) AS AssignToOrganisationAdminstrators
				, CAST('False' AS BIT) AS AssignToOrganisationSupportGroup
				, CAST('False' AS BIT) AS AssignToAtlasSystemAdministrators
				, CAST('False' AS BIT) AS AssignToAtlasSystemSupportGroup
			) TA;


		INSERT INTO [dbo].[TaskAction] (
			[Name]
			, [Description]
			, PriorityNumber
			, AssignToOrganisation
			, AssignToOrganisationAdminstrators
			, AssignToOrganisationSupportGroup
			, AssignToAtlasSystemAdministrators
			, AssignToAtlasSystemSupportGroup
			)
		SELECT DISTINCT
			New_TA.[Name]
			, New_TA.[Description]
			, New_TA.PriorityNumber
			, New_TA.AssignToOrganisation
			, New_TA.AssignToOrganisationAdminstrators
			, New_TA.AssignToOrganisationSupportGroup
			, New_TA.AssignToAtlasSystemAdministrators
			, New_TA.AssignToAtlasSystemSupportGroup
		FROM #TaskAction New_TA
		LEFT JOIN [dbo].[TaskAction] TA ON TA.[Name] = New_TA.[Name]
		WHERE TA.Id IS NULL;



		UPDATE TA
		SET TA.[Description] = New_TA.[Description]
		FROM #TaskAction New_TA
		INNER JOIN TaskAction TA					ON TA.[Name] = New_TA.[Name]
		WHERE TA.[Description] != New_TA.[Description]
		;

	END

	/* Ensure certain Vehicle Types Exist */
	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - Ensure certain Vehicle Types Exist';
	BEGIN
		INSERT INTO [dbo].[VehicleType] (Name, Description, Disabled, Automatic, OrganisationId, DateCreated, CreatedByUserId)
		SELECT DISTINCT
			T.[Name]
			, T.[Description]
			, 'False' AS [Disabled]
			, T.[Automatic] AS [Automatic]
			, O.Id AS OrganisationId
			, GETDATE() AS DateCreated
			, dbo.udfGetSystemUserId() AS CreatedByUserId
		FROM(
			SELECT 'Car Man' AS [Name], 'Car - Manual' AS [Description], 'False' AS [Automatic]
			UNION SELECT 'm/cycle' AS [Name], 'Motorcycle' AS [Description], 'False' AS [Automatic]
			UNION SELECT 'Car Auto' AS [Name], 'Car - [Automatic]' AS [Description], 'False' AS [Automatic]
			UNION SELECT 'SAV' AS [Name], 'Clients Own (specially adapted)' AS [Description], 'False' AS [Automatic]
			UNION SELECT 'N/A' AS [Name], 'N/A' AS [Description], 'False' AS [Automatic]
			UNION SELECT '1 - 1 Manual' AS [Name], 'Client 1:1 Manual' AS [Description], 'False' AS [Automatic]
			UNION SELECT '1 - 1 Auto' AS [Name], 'Client 1:1 Auto' AS [Description], 'True' AS [Automatic]
			UNION SELECT 'Motorcycle (RIDE)' AS [Name], 'Motorcycle (RIDE)' AS [Description], 'False' AS [Automatic]
			UNION SELECT 'C1 7.5' AS [Name], 'C 1 up to 7.5 ton gross weight' AS [Description], 'False' AS [Automatic]
			UNION SELECT 'C over 7.5 ton' AS [Name], 'C Any Rigid Vehicle above 7.5 ton gross' AS [Description], 'False' AS [Automatic]
			UNION SELECT 'C+E Articul' AS [Name], 'C+E Articulated Vehicle with Trailer' AS [Description], 'False' AS [Automatic]
			UNION SELECT 'D1' AS [Name], 'D1 Minibus with 9 -16 seats' AS [Description], 'False' AS [Automatic]
			UNION SELECT 'D' AS [Name], 'D Bus/Coach/Autos/Decker 16 seats upwards' AS [Description], 'False' AS [Automatic]
			UNION SELECT '*UNKNOWN*' AS [Name], '*UNKNOWN*' AS [Description], 'False' AS [Automatic]
		) T
		CROSS JOIN dbo.Organisation O
		LEFT JOIN [dbo].[VehicleType] VT ON VT.[Name] = T.[Name]
										AND VT.[OrganisationId] = O.[Id]
		WHERE VT.Id IS NULL;

	END
	
	/* Ensure DataViews used in reports are correctly recorded */
	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - Ensure DataViews used in reports are correctly recorded';
	BEGIN

		EXEC uspUpdateDataViewColumn 'vwClientDetail'
		EXEC uspUpdateDataViewColumn 'vwClientHistory'
		EXEC uspUpdateDataViewColumn 'vwClientPayment'
		EXEC uspUpdateDataViewColumn 'vwClientsWithinCourse'
		EXEC uspUpdateDataViewColumn 'vwCourseClient'
		EXEC uspUpdateDataViewColumn 'vwCourseDetail'
		EXEC uspUpdateDataViewColumn 'vwCourseHistory'
		EXEC uspUpdateDataViewColumn 'vwCoursesWithinVenue'
		EXEC uspUpdateDataViewColumn 'vwPaymentDetail'
		EXEC uspUpdateDataViewColumn 'vwClientsCreatedToday'
		EXEC uspUpdateDataViewColumn 'vwClientsCreatedYesterday'
		EXEC uspUpdateDataViewColumn 'vwClientCourseBasicData'

	END


	/* Ensure certain Letter Categories and Template Information Exist */
	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - Ensure certain Letter Categories and Template Information Exist';
	BEGIN	
		DECLARE @DefaultDataViewId INT;
		DECLARE @ClientDetailDataViewId INT;

		SELECT TOP 1 @ClientDetailDataViewId=Id 
		FROM dbo.DataView 
		WHERE [Name] = 'vwClientDetail';

		SET @DefaultDataViewId = @ClientDetailDataViewId;

		IF OBJECT_ID('tempdb..#TempLetterCategory', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #TempLetterCategory;
		END

		SELECT Code, Title, Title AS [Description], @DefaultDataViewId AS DataViewId, IdKeyName
		INTO #TempLetterCategory
		FROM (
			SELECT 'BookConf' AS Code, 'Booking Confirmation' AS Title, @DefaultDataViewId AS DataViewId, 'ClientId' AS IdKeyName
			UNION SELECT 'ReArr' AS Code, 'Rearrange' AS Title, @DefaultDataViewId AS DataViewId, 'ClientId' AS IdKeyName
			UNION SELECT 'ReArrFee' AS Code, 'Rearrange (Fee)' AS Title, @DefaultDataViewId AS DataViewId, 'ClientId' AS IdKeyName
			UNION SELECT 'Removal' AS Code, 'Removal' AS Title, @DefaultDataViewId AS DataViewId, 'ClientId' AS IdKeyName
			UNION SELECT 'Blank' AS Code, 'Blank Template' AS Title, @DefaultDataViewId AS DataViewId, 'ClientId' AS IdKeyName
			UNION SELECT 'Blank2' AS Code, 'Blank Template' AS Title, @DefaultDataViewId AS DataViewId, 'ClientId' AS IdKeyName
			UNION SELECT 'Blank3' AS Code, 'Blank Template' AS Title, @DefaultDataViewId AS DataViewId, 'ClientId' AS IdKeyName
			UNION SELECT 'Blank4' AS Code, 'Blank Template' AS Title, @DefaultDataViewId AS DataViewId, 'ClientId' AS IdKeyName
			UNION SELECT 'Blank5' AS Code, 'Blank Template' AS Title, @DefaultDataViewId AS DataViewId, 'ClientId' AS IdKeyName
			UNION SELECT 'Blank6' AS Code, 'Blank Template' AS Title, @DefaultDataViewId AS DataViewId, 'ClientId' AS IdKeyName
			UNION SELECT 'Blank7' AS Code, 'Blank Template' AS Title, @DefaultDataViewId AS DataViewId, 'ClientId' AS IdKeyName
			UNION SELECT 'Blank8' AS Code, 'Blank Template' AS Title, @DefaultDataViewId AS DataViewId, 'ClientId' AS IdKeyName
			UNION SELECT 'PayRec' AS Code, 'Payment Receipt' AS Title, @DefaultDataViewId AS DataViewId, 'ClientId' AS IdKeyName
			UNION SELECT 'PayRemnd' AS Code, 'Payment Reminder' AS Title, @DefaultDataViewId AS DataViewId, 'ClientId' AS IdKeyName
			UNION SELECT 'NoAttend' AS Code, 'Failed to Attend' AS Title, @DefaultDataViewId AS DataViewId, 'ClientId' AS IdKeyName
			UNION SELECT 'Special' AS Code, 'Special Requirements' AS Title, @DefaultDataViewId AS DataViewId, 'ClientId' AS IdKeyName
			UNION SELECT 'HearLoop' AS Code, 'Hearing Loop' AS Title, @DefaultDataViewId AS DataViewId, 'ClientId' AS IdKeyName
			) T

		INSERT INTO [dbo].[LetterCategory] (Code, Title, [Description], DataViewId, IdKeyName)
		SELECT T.Code, T.Title, T.Title AS [Description], T.DataViewId, T.IdKeyName
		FROM #TempLetterCategory T
		LEFT JOIN [dbo].[LetterCategory] LC ON LC.[Code] = T.Code
		WHERE LC.Id IS NULL;

		UPDATE LC
		SET LC.Title = T.Title
		, LC.DataViewId = T.DataViewId
		, LC.IdKeyName = T.IdKeyName
		FROM #TempLetterCategory T
		INNER JOIN [dbo].[LetterCategory] LC ON LC.[Code] = T.Code
		WHERE ISNULL(LC.Title,'') <> T.Title
		OR ISNULL(LC.DataViewId,-1) <> T.DataViewId
		OR ISNULL(LC.IdKeyName,'') <> T.IdKeyName;

		INSERT INTO [dbo].[LetterCategoryColumn] (LetterCategoryId, DataViewColumnId, TagName)
		SELECT LC.Id AS LetterCategoryId, DVC.Id AS DataViewColumnId, DVC.[Name] AS TagName
		FROM [dbo].[LetterCategory] LC
		INNER JOIN [dbo].[DataView] DV ON DV.Id = LC.DataViewId
		INNER JOIN [dbo].[DataViewColumn] DVC ON DVC.[DataViewId] = DV.Id
		WHERE LC.Code IN ('Blank', 'Blank2', 'Blank3','Blank4','Blank5','Blank6','Blank7','Blank8','BookConf', 'HearLoop', 'NoAttend', 'PayRec', 'PayRemnd', 'ReArr', 'ReArrFee', 'Removal') 
		AND DV.Id = @ClientDetailDataViewId
		AND DVC.[Name] IN ('Address'
							, 'AmountPaidByClient'
							, 'ClientId'
							, 'CourseEndTime'
							, 'CourseFee'
							, 'CoursePaymentDueDate'
							, 'CourseReference'
							, 'CourseStartDate'
							, 'CourseStartTime'
							, 'CourseStartDate2'
							, 'CourseStartTime2'
							, 'CourseType'
							, 'DateOfBirth'
							, 'DORSExpiryDate'
							, 'FirstName'
							, 'LicenceNumber'
							, 'OrganisationName'
							, 'PostCode'
							, 'ReferralReference'
							, 'ReferralAuthority'
							, 'Surname'
							, 'Title'
							, 'TotalPaymentDueByClient'
							, 'VenueAddress'
							, 'VenueDirection' 
							, 'VenueName'
							, 'VenuePostCode'
							)
		AND NOT EXISTS (SELECT * FROM [dbo].[LetterCategoryColumn] LCC WHERE LCC.LetterCategoryId = LC.Id AND LCC.DataViewColumnId = DVC.Id)
		UNION
			SELECT LC.Id AS LetterCategoryId, DVC.Id AS DataViewColumnId, DVC.[Name] AS TagName
			FROM [dbo].[LetterCategory] LC
			INNER JOIN [dbo].[DataView] DV ON DV.Id = LC.DataViewId
			INNER JOIN [dbo].[DataViewColumn] DVC ON DVC.[DataViewId] = DV.Id
			WHERE LC.Code = 'Special'
			AND DV.Id = @ClientDetailDataViewId
			AND DVC.[Name] IN ('Address'
								, 'AmountPaidByClient'
								, 'ClientCreatedDate'
								, 'ClientId'
								, 'CourseEndTime'
								, 'CourseFee'
								, 'CoursePaymentDueDate'
								, 'CourseReference'
								, 'CourseStartDate'
								, 'CourseStartTime'
								, 'CourseStartDate2'
								, 'CourseStartTime2'
								, 'CourseType'
								, 'DateOfBirth'
								, 'DORSExpiryDate'
								, 'FirstName'
								, 'LicenceNumber'
								, 'OrganisationName'
								, 'PostCode'
								, 'ReferralReference'
								, 'ReferralAuthority'
								, 'SpecialRequirements'
								, 'Surname'
								, 'Title'
								, 'TotalPaymentDueByClient'
								, 'VenueAddress'
								, 'VenueDirection' 
								, 'VenueName'
								, 'VenuePostCode'
								)
		AND NOT EXISTS (SELECT * FROM [dbo].[LetterCategoryColumn] LCC WHERE LCC.LetterCategoryId = LC.Id AND LCC.DataViewColumnId = DVC.Id)
		;
	END

	/* Ensure VAT Rate Table is populated */

	IF OBJECT_ID('tempdb..#VatRate', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #VatRate;
	END

	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - Ensure VATRate Table is populated';
	BEGIN	
		SELECT *
		INTO #VatRate
		FROM (
			SELECT CAST(15.0 AS FLOAT) AS VATRate, CAST('1979-06-18' AS DATE) AS EffectiveFromDate, dbo.udfGetSystemUserId() AS AddedByUserId, GETDATE() AS DateAdded
			UNION
			SELECT CAST(17.5 AS FLOAT) AS VATRate, CAST('1991-03-19' AS DATE) AS EffectiveFromDate, dbo.udfGetSystemUserId() AS AddedByUserId, GETDATE() AS DateAdded
			UNION
			SELECT CAST(15.0 AS FLOAT) AS VATRate, CAST('2008-01-12' AS DATE) AS EffectiveFromDate, dbo.udfGetSystemUserId() AS AddedByUserId, GETDATE() AS DateAdded
			UNION
			SELECT CAST(17.5 AS FLOAT) AS VATRate, CAST('2010-01-01' AS DATE) AS EffectiveFromDate, dbo.udfGetSystemUserId() AS AddedByUserId, GETDATE() AS DateAdded
			UNION
			SELECT CAST(20.0 AS FLOAT) AS VATRate, CAST('2011-04-01' AS DATE) AS EffectiveFromDate, dbo.udfGetSystemUserId() AS AddedByUserId, GETDATE() AS DateAdded
			) VR

		INSERT INTO dbo.VATRate (VATRate, EffectiveFromDate, AddedByUserId, DateAdded)
		SELECT TVR.VATRate, TVR.EffectiveFromDate, TVR.AddedByUserId, TVR.DateAdded
		FROM #VatRate TVR
		LEFT JOIN dbo.VATRate VR ON TVR.VATRate = VR.VATRate
									AND TVR.EffectiveFromDate = VR.EffectiveFromDate
		WHERE VR.VATRate IS NULL;
	END
	
	/* Ensure SystemTrainerInformation is populated */

	IF OBJECT_ID('tempdb..#SystemTrainerInformation', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #SystemTrainerInformation;
	END

	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - Ensure SystemTrainerInformation Table is populated';
	BEGIN	
		SELECT 'atlasquery@pdsuk.co.uk' AS AdminContactEmailAddress
				, '0870 224 0278' AS AdminContactPhoneNumber
				, 'If you have any System Issue please contact IAM RoadSmart on ' AS DisplayedMessage
		INTO #SystemTrainerInformation 
		
		INSERT INTO [dbo].[SystemTrainerInformation]
				([AdminContactEmailAddress]
				,[AdminContactPhoneNumber]
				,[DisplayedMessage])
		SELECT TSTI.AdminContactEmailAddress, TSTI.AdminContactPhoneNumber, TSTI.DisplayedMessage
		FROM #SystemTrainerInformation TSTI
		LEFT JOIN dbo.SystemTrainerInformation STI ON TSTI.AdminContactEmailAddress = STI.AdminContactEmailAddress
									AND TSTI.AdminContactPhoneNumber = STI.AdminContactPhoneNumber
		WHERE STI.AdminContactEmailAddress IS NULL;
	END

	/* Ensure SystemTrainerInformationByOrganisation is populated */

	IF OBJECT_ID('tempdb..#SystemTrainerInformationByOrganisation', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #SystemTrainerInformationByOrganisation;
	END

	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '				: - Ensure SystemTrainerInformationByOrganisation Table is populated';
	BEGIN	

		DECLARE @Id INT;
		SELECT @Id = Id FROM Organisation WHERE Name = 'Cleveland Driver Improvement Group'
		
		SELECT  @Id AS OrganisationId
				,'speedawareness@hartlepool.gov.uk' AS AdminContactEmailAddress
				, '01429 523803' AS AdminContactPhoneNumber
				, 'For any Course Booking queries please contact' AS DisplayedMessage
		INTO #SystemTrainerInformationByOrganisation
		
		INSERT INTO [dbo].[SystemTrainerInformationByOrganisation]
				([OrganisationId]
				,[AdminContactEmailAddress]
				,[AdminContactPhoneNumber]
				,[DisplayedMessage])
		SELECT TSTIBO.OrganisationId, TSTIBO.AdminContactEmailAddress, TSTIBO.AdminContactPhoneNumber, TSTIBO.DisplayedMessage
		FROM #SystemTrainerInformationByOrganisation TSTIBO
		LEFT JOIN dbo.SystemTrainerInformationByOrganisation STIBO ON TSTIBO.OrganisationId = STIBO.OrganisationId
		WHERE STIBO.OrganisationId IS NULL;
	END

	/************************************************************************************************************************/
	/** End of Scripts **/
	/************************************************************************************************************************/

	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, '*TIDY UP';

	/* TIDY UP */
	PRINT('');PRINT('*TIDY UP');

	IF OBJECT_ID('tempdb..#TaskAction', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #TaskAction;
	END

	IF OBJECT_ID('tempdb..#TaskCategory', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #TaskCategory;
	END

	IF OBJECT_ID('tempdb..#AdministrationMenuGroup', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #AdministrationMenuGroup;
	END

	IF OBJECT_ID('tempdb..#NewDORSStates', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #NewDORSStates;
	END

	IF OBJECT_ID('tempdb..#NewSystemStates', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #NewSystemStates;
	END

	IF OBJECT_ID('tempdb..#CourseRefGeneratorInsert', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #CourseRefGeneratorInsert;
	END

	IF OBJECT_ID('tempdb..#ReportDataTypeInsert', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #ReportDataTypeInsert;
	END

	IF OBJECT_ID('tempdb..#SMSMessageTag', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #SMSMessageTag;
	END

	IF OBJECT_ID('tempdb..#DashboardMeter', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #DashboardMeter;
	END

	IF OBJECT_ID('tempdb..#PaymentCardSupplierProvider', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #PaymentCardSupplierProvider;
	END

	IF OBJECT_ID('tempdb..#EmailService', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #EmailService;
	END

	IF OBJECT_ID('tempdb..#EmailServiceCredential', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #EmailServiceCredential;
	END

	IF OBJECT_ID('tempdb..#SystemControl', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #SystemControl;
	END

	IF OBJECT_ID('tempdb..#DORSControl', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #DORSControl;
	END

	IF OBJECT_ID('tempdb..#SystemTask', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #SystemTask;
	END

	IF OBJECT_ID('tempdb..#DORSAttendanceState', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #DORSAttendanceState;
	END

	IF OBJECT_ID('tempdb..#MessageCategory', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #MessageCategory;
	END

	IF OBJECT_ID('tempdb..#LetterAction', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #LetterAction;
	END

	IF OBJECT_ID('tempdb..#PaymentProvider', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #PaymentProvider;
	END

	IF OBJECT_ID('tempdb..#SystemFeatureItem', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #SystemFeatureItem;
	END

	IF OBJECT_ID('tempdb..#SystemFeatureGroup', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #SystemFeatureGroup;
	END

	IF OBJECT_ID('tempdb..#OrganisationEmailTemplateMessage', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #OrganisationEmailTemplateMessage;
	END

	IF OBJECT_ID('tempdb..#OrganisationSMSTemplateMessage', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #OrganisationSMSTemplateMessage;
	END

	IF OBJECT_ID('tempdb..#CourseTypeTolerance', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #CourseTypeTolerance;
	END

	IF OBJECT_ID('tempdb..#LastRunLog', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #LastRunLog;
	END

	IF OBJECT_ID('tempdb..#PaymentCardTypePaymentMethodPopulation', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #PaymentCardTypePaymentMethodPopulation;
	END

	IF OBJECT_ID('tempdb..#VatRate', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #VatRate;
	END

	IF OBJECT_ID('tempdb..#SystemTrainerInformation', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #SystemTrainerInformation;
	END

	IF OBJECT_ID('tempdb..#SystemTrainerInformationByOrganisation', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #SystemTrainerInformationByOrganisation;
	END

	PRINT('');PRINT('******************************************');

	EXEC dbo.uspScriptCompleted @ScriptName;

	/************************************************************************************************************************/
	/** Don't delete this line '1 rows affected'**/
	/** as it will stop the script 'InitialDatViews_RunAfterNewRelease' running **/
	/************************************************************************************************************************/

	SET @processNumber = @processNumber + 1;
	EXEC dbo.uspRecordInProcessMonitor @processName, @processNumber, 'Running RunEveryRelease: - Ending Process';

	PRINT('');PRINT('(1 rows affected)');

	/************************************************************************************************************************/
	/** Dudes No Scripts Beyond this point **/
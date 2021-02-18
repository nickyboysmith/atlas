/****** Script for SelectTopNRows command from SSMS  ******/
DECLARE @ScriptName VARCHAR(100) = 'SP003_08.01_CreateAtlasMenuTables.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Created UserMenuOptions, UserMenuFavourite tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
                BEGIN
                                EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
                                /***START OF SCRIPT***/

                                /*
                                                Drop Constraints if they Exist
                                */
                                                EXEC dbo.uspDropTableContraints 'UserMenuOptionUser'
                                                EXEC dbo.uspDropTableContraints 'UserMenuUser'    
                                /*
                                                Create Table UserMenuOption
                                */
                                IF OBJECT_ID('dbo.UserMenuOption', 'U') IS NOT NULL
                                BEGIN
                                                DROP TABLE dbo.UserMenuOption;
                                                
                                END

                                CREATE TABLE UserMenuOption(
                                                Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
                                                , UserId int 
                                                , AccessToClients bit
                                                , AccessToCourses bit
                                                , AccessToReports bit
                                                , CONSTRAINT FK_UserMenuOption_User FOREIGN KEY (UserId) REFERENCES [User](Id)
                                );

                                /*
                                                Create Table UserMenuFavourite
                                */
                                IF OBJECT_ID('dbo.UserMenuFavourite', 'U') IS NOT NULL
                                BEGIN
                                                DROP TABLE dbo.[UserMenuFavourite];
                                END

                                CREATE TABLE [UserMenuFavourite](
                                                Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
                                                , UserId int 
                                                , Title varchar(100)
                                                , Link varchar(400)
												, [Parameters] varchar(400)
												, Modal bit
                                                , CONSTRAINT FK_UserMenuFavourite_User FOREIGN KEY (UserId) REFERENCES [User](Id)
                                );
                                
                                /***END OF SCRIPT***/
                                EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
                END
ELSE
                BEGIN
                                PRINT '******Script "' + @ScriptName + '" Not Run******';
                END
;

/*
 * SCRIPT: Create Course Type Category Table
 * Author: Miles Stewart
 * Created: 28/10/2015
 */
DECLARE @ScriptName VARCHAR(100) = 'SP010_22.01_CreateTableTrainerCourseTypeCategory.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Creates table to store the trainer course type category';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */

		EXEC dbo.uspDropTableContraints 'TrainerCourseTypeCategory'


		/*
		 *	Drop tables in this order to avoid errors due to foreign key constraints
		 */
		IF OBJECT_ID('dbo.TrainerCourseTypeCategory', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.TrainerCourseTypeCategory;
		END

		/*
		 *	Create Table CourseTypeCategory
		 */
		CREATE TABLE TrainerCourseTypeCategory (
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, TrainerId INT NOT NULL
			, CourseTypeCategoryId INT NOT NULL
			, CONSTRAINT FK_TrainerCourseTypeCategoryTrainerId_Trainer FOREIGN KEY (TrainerId) REFERENCES [Trainer](Id)
			, CONSTRAINT FK_TrainerCourseTypeCategoryCourseTypeCategoryId_CourseTypeCategory FOREIGN KEY (CourseTypeCategoryId) REFERENCES [CourseTypeCategory](Id)
		);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;



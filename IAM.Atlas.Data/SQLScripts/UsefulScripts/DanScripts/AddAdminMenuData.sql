--Variables for the User and Menu Group to be used
DECLARE @UserId int = 0
DECLARE @MenuGroupId int = 0

--Variables for the Admin Menu Item to be added
DECLARE @title varchar(100) = ''
DECLARE @url varchar(100) = ''
DECLARE @description varchar(100) = ''
DECLARE @modal bit = 0
DECLARE @disabled bit = 0

--Working variables
DECLARE @AdminMenuItemId int = 0
DECLARE @ExistingAdminMenuUserId int = 0

--Create the AdmininstrationMenuItem entry
INSERT INTO AdministrationMenuItem
				(
				Title,
				Url,
				Description,
				Modal,
				Disabled
				)
VALUES
				(
				@title,
				@url,
				@description,
				@modal,
				@disabled
				)
SET @AdminMenuItemId = SCOPE_IDENTITY()

--Create the AdministrationMenuGroupItem entry
INSERT INTO AdministrationMenuGroupItem
				(
				AdminMenuGroupId,
				AdminMenuItemId
				)
VALUES			
				(
				@MenuGroupId,
				@AdminMenuItemId
				)

--Create the AdministrationMenuItemUser entry
INSERT INTO AdministrationMenuItemUser
				(
				AdminMenuItemId,
				UserId
				)
VALUES
				(
				@AdminMenuItemId,
				@UserId
				)

--Create the AdministrationMenuUser entry if required
SELECT			@ExistingAdminMenuUserId = Id
FROM			AdministrationMenuUser
WHERE			UserId = @UserId

IF NOT @ExistingAdminMenuUserId > 0
BEGIN
	INSERT INTO AdministrationMenuUser
					(
					UserId
					)
	VALUES
					(
					@UserId
					)
END
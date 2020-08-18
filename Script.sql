CREATE DATABASE BDProjectNotice
GO
USE BDProjectNotice
GO 

--CREACION DE TABLAS

--TABLA DE ROLES
CREATE TABLE Roles
(
RoleId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_RoleId PRIMARY KEY,
RoleName VARCHAR(25) NOT NULL,
IsDeleted BIT NOT NULL DEFAULT 0
);
GO
--TABLA DE USUARIOS
CREATE TABLE Users
(
UserId NVARCHAR(128) NOT NULL CONSTRAINT PK_UserId PRIMARY KEY,
Username VARCHAR(15) NOT NULL,
Pass VARCHAR(1500) NOT NULL,
FirstName VARCHAR(40) NOT NULL, 
LastName VARCHAR(40) NOT NULL,
Email VARCHAR(35) NOT NULL,
TelephoneNumber VARCHAR(14) NOT NULL,
CellphoneNumber VARCHAR(15) DEFAULT '1(000)-000-0000',
RoleId INT NOT NULL CONSTRAINT FK_Users_Roles FOREIGN KEY REFERENCES Roles(RoleId),
IsDeleted BIT NOT NULL DEFAULT 0 
);
GO
--TABLA DE CATEGORIAS
CREATE TABLE Categories
(
CategoryId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_CategoryId PRIMARY KEY, 
Category VARCHAR(30) NOT NULL,
IsDeleted BIT NOT NULL DEFAULT 0
);
GO
--TABLA DE ARTICULOS
CREATE TABLE Articles
(
	ArticleId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ArticleId PRIMARY KEY,
	Title NVARCHAR(255) NOT NULL,
	Summary NVARCHAR(500) NOT NULL,
	MainImage VARBINARY(MAX),
	Content NVARCHAR(MAX),
    CreatedUserId NVARCHAR(128) NOT NULL CONSTRAINT FK_News_Users FOREIGN KEY REFERENCES [Users]([UserId]),
	CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
	IsDeleted BIT NOT NULL DEFAULT 0,
	PublishedUserId NVARCHAR(128),
	IsPublished BIT NOT NULL DEFAULT 0,
	PublishedAt DATETIME
);
GO
--TABLA INTERMEDIA DE ARTICULOS Y CATEGORIAS
CREATE TABLE ArticleCategories
(
ArticleId INT NOT NULL CONSTRAINT FK_Article_Categories FOREIGN KEY REFERENCES Articles(ArticleId),
CategoryId INT NOT NULL CONSTRAINT FK_Categorie_Articles FOREIGN KEY REFERENCES Categories(CategoryId),
CONSTRAINT PKArticleIdCategoryId PRIMARY KEY(ArticleId,CategoryId) 
);
GO

--PROCEDIMIENTOS ALMACENADOS
/*
CREATE PROCEDURE AddCategory
(
	@Name VARCHAR(30),
	@Message VARCHAR(60) OUTPUT,
	@UserToken VARCHAR(50),
	@UserId INT,
	@IsUserLoggedIn BIT OUTPUT
)
AS 
BEGIN 
	IF((SELECT COUNT(*) FROM [UserTokens] WHERE [UserId] = @UserId AND [Token] = @UserToken) = 1)
	BEGIN
		SET @IsUserLoggedIn = 1;
		IF((SELECT COUNT(*) FROM [Categories] WHERE [Name] = @Name) = 0)
		BEGIN 
			INSERT INTO [Categories]([Name],[IsCategoryDeleted]) VALUES (@Name, 0);
			SET @Message = 'The category has been added successfully';
		END 
		ELSE
		BEGIN
			SET @Message = 'The category colud not be added, because it already exists';
		END
	END
	ELSE
	BEGIN
		SET @IsUserLoggedIn = 0;
		SET @Message = 'User is not logged in';
	END
END 

GO

CREATE TYPE ArticleCategoriesAdding AS TABLE(
	CategoryId INT
)

GO 

ALTER PROCEDURE AddArticle
(
	@Title NVARCHAR(255),
	@Summary NVARCHAR(500),
	@MainImage VARBINARY(MAX),
	@Body NVARCHAR(MAX),
	@CreatedAt DATETIME,
	@IsDeleted BIT,
	@IsPublished BIT,
	@PublishedAt DATETIME,
	@Categories ArticleCategoriesAdding READONLY,
	@Message VARCHAR(150) OUTPUT
) 
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRANSACTION 
	BEGIN TRY 
		IF((SELECT COUNT(*) FROM [UserTokens] WHERE [UserId] = 3 AND [Token] = @UserToken) = 1)
		BEGIN
			SET @IsUserLoggedIn = 1;

			INSERT INTO [Articles]
			([Title],
			[Summary],
			[MainImage],
			[Body],
			[UploadedUserId], 
			[CreatedAt], 
			[IsDeleted], 
			[IsPublished], 
			[PublishedAt]) 
			VALUES 
			(@Title,
			@Summary,
			@MainImage,
			@Body,
			@UserId,
			@CreatedAt, 
			@IsDeleted,
			@IsPublished,
			@PublishedAt)

			INSERT INTO [ArticleCategories]
			([ArticleId],
			[CategoryId]
			)
			SELECT SCOPE_IDENTITY(), [CategoryId] FROM @Categories
			SET @Message = 'The article has been created';
		END
		ELSE 
		BEGIN
			SET @IsUserloggedIn = 0; 
			SET @Message = 'The user is not logged in';
		END
	END TRY
	BEGIN CATCH 
		IF @@TRANCOUNT > 0 
		BEGIN
			ROLLBACK TRANSACTION 
		END
		DECLARE @ErrorMessage VARCHAR(MAX) = CONCAT('The following error has occurred: ', ERROR_MESSAGE());
		RAISERROR(@ErrorMessage, 16, 1);
	END CATCH 

	
	IF @@TRANCOUNT > 0 
	BEGIN
		COMMIT TRANSACTION 
	END
END

GO

CREATE PROCEDURE PublishArticle
(
	@ArticleId INT,
	@UserId INT,
	@UserToken VARCHAR(50),
	@Message VARCHAR(150),
	@IsUserLoggedIn BIT OUTPUT
)
AS 
BEGIN 
	SET NOCOUNT ON
	BEGIN TRY
	IF((SELECT [RoleId] FROM [Users] WHERE [UserId] = @UserId) = 1 
	AND (SELECT COUNT(*) FROM [UserTokens] WHERE [UserId] = @UserId AND [Token] = @UserToken) = 1)
	BEGIN
		SET @IsUserLoggedIn = 1;
		UPDATE [Articles] SET [PublishedAt] = GETDATE(), IsPublished = 1 WHERE [ArticleId] = @ArticleId 
		SET @Message = 'The article has been published';
	END
	ELSE 
	BEGIN
		SET @IsUserLoggedIn = 0;
		SET @Message = 'The article could not be published beacuse the user is not an administrator or is not logged in';
	END
	END TRY 
	BEGIN CATCH 
		SET @Message = CONCAT('The following error has occurred: ', ERROR_MESSAGE()); 
	END CATCH
END

GO
*/
------------------------------------------------------------------------------------------------------------------------------------

alter PROCEDURE GetAllArticles
AS 
BEGIN
    SET NOCOUNT ON
    SELECT [ArticleId],
        [Title],
        [Summary],
        [MainImage],
        [Content],
        CreatedUserId, 
        [CreatedAt], 
        [IsDeleted], 
        [IsPublished], 
        [PublishedAt] 
    FROM [Articles]
	where  IsDeleted=0
END
EXECUTE GetAllArticles
GO

select 
alter PROCEDURE GetAllPublishedArticles
AS 
BEGIN
    SET NOCOUNT ON
    SELECT [ArticleId],
        [Title],
        [Summary],
        [MainImage],
        [Content],
        CreatedUserId, 
        [CreatedAt], 
        [IsDeleted], 
        [IsPublished], 
		[PublishedUserId],
        [PublishedAt] 
    FROM [Articles]
    WHERE [IsPublished] = 1
	and  IsDeleted=0

END
EXECUTE GetAllPublishedArticles
GO
--Seguir
--CREATE PROCEDURE GetAllUnpublishedArticles
--(
--    @UserId INT,
--    @UserToken VARCHAR(50),
--    @IsUserLoggedIn BIT OUTPUT,
--    @Message VARCHAR(200) OUTPUT
--)
--AS 
--BEGIN
--    BEGIN TRY
--        IF ((SELECT COUNT(*) FROM [Users] WHERE [UserId] = @UserId) = 1 AND (SELECT COUNT(*) FROM [UserTokens] WHERE [UserId] = @UserId AND [Token] = @UserToken) = 1) 
--        BEGIN 
--            SET @IsUserLoggedIn = 1; 
--            SELECT [ArticleId],
--               [Title],
--               [Summary],
--               [MainImage],
--               [Content],
--               [UploadedUserId], 
--               [CreatedAt], 
--               [IsDeleted], 
--               [IsPublished], 
--               [PublishedAt] 
--            FROM [Articles]
--            WHERE [IsPublished] = 0

--            SET @Message = 'Success';
--        END 
--        ELSE
--        BEGIN
--            SET    @IsUserLoggedIn = 0;
--            SET @Message = 'The user is not logged in';
--        END
--    END TRY 
--    BEGIN CATCH 
--        SET @Message = CONCAT('The following error has occurred: ', ERROR_MESSAGE())
--    END CATCH
--END
--GO
drop procedure GetPublishedArticlesById
alter PROCEDURE GetPublishedArticlesById2
(
    @ArticleId INT
)
AS 
BEGIN
    SET NOCOUNT ON
        SELECT [ArticleId],
        [Title],
        [Summary],
        [MainImage],
        [Content],
        [CreatedUserId], 
        [CreatedAt], 
        [IsDeleted], 
        [IsPublished], 
		[PublishedUserId],
        [PublishedAt] 
    FROM [Articles]
    WHERE [ArticleId] = @ArticleId
    AND [IsPublished] =1
	AND IsDeleted=0
	
END
EXECUTE GetPublishedArticlesById2 2133
GO

alter PROCEDURE [dbo].[GetPublishedArticlesByTitle]
(
    @Title VARCHAR(255) 
)
AS 
BEGIN
    SELECT [ArticleId], 
        [Title], 
        [Summary], 
        [MainImage],
        [Content],
        [CreatedUserId], 
        [CreatedAt], 
        [IsDeleted], 
        [IsPublished], 
		[PublishedUserId],
        [PublishedAt] 
    FROM [Articles]
    WHERE [isPublished] = 1 AND UPPER([Title]) LIKE '%' + UPPER(@Title) + '%';        
END
EXECUTE GetPublishedArticlesByTitle 'a'

GO
alter PROCEDURE GetArticleCategoriesById
(
    @ArticleId INT
)
AS
BEGIN
    SELECT [CategoryId], [Category] FROM [Categories] WHERE [CategoryId] IN (SELECT [CategoryId]
                                             FROM [ArticleCategories]
                                             WHERE [ArticleId] = @ArticleId);
END
EXECUTE GetArticleCategoriesById 2129
GO

alter PROCEDURE GetPublishedArticlesByCategory
(
    @CategoryId INT
)
AS 
BEGIN
    SELECT * FROM [Articles] 
    WHERE [ArticleId] IN (SELECT [ArticleId] 
                                 FROM [ArticleCategories] 
                                 WHERE [CategoryId] = @CategoryId)
                                 AND [IsPublished] = 1
END
EXECUTE GetPublishedArticlesByCategory 1
GO

CREATE PROCEDURE GetPublishedArticlesByCategoryAndTitle
(
    @CategoryId INT,
    @Title NVARCHAR(255)
)
AS 
BEGIN
    SELECT * FROM [Articles] 
    WHERE [ArticleId] IN (SELECT [ArticleId] 
    FROM [ArticleCategories] 
    WHERE [CategoryId] = @CategoryId)
    AND [IsPublished] = 1
    AND UPPER([Title]) LIKE '%' + UPPER(@Title) + '%';
END
EXECUTE GetPublishedArticlesByCategoryAndTitle 1,'CORONAVIRUS'
GO


select*from Articles

select*from ArticleCategories

delete Articles where ArticleId=2116


UPDATE [Articles]
SET [MainImage] =
(Select BulkColumn
from Openrowset (Bulk 'C:\Users\Hansel Bastardo\OneDrive - Universidad Central del Este\Escritorio\Proyecto\luis-abinader-responde-a-raymond-pozo-nuestro-compromiso-es-garantizar-el-acceso-a-una-salud-de-calidad.jpeg', Single_Blob) as Image)
where ArticleId=2117


Insert into Articles([Title], 
        [Summary], 
        [MainImage],
        [Content],
        [CreatedUserId], 
        [CreatedAt], 
        [IsDeleted], 
        [IsPublished], 
        [PublishedAt] )
  SELECT  
        [Title], 
        [Summary], 
        [MainImage],
        [Content],
        [CreatedUserId], 
        [CreatedAt], 
        [IsDeleted], 
        [IsPublished], 
        [PublishedAt] 
    FROM [Articles]

	select*from Articles


Data Source=MSI\SQLEXPRESS;Initial Catalog=BDProjectNotice;Integrated Security=True
var articles = GetService.GetArticleService().GetPublishedArticles();

CREATE PROCEDURE GetAllCategories
AS
BEGIN
    SELECT [CategoryId], Category FROM [Categories] WHERE [IsDeleted] = 0;
END

execute GetAllCategories

select*from Articles
select*from users


CREATE PROCEDURE AddArticle
(
    @Title NVARCHAR(255),
    @Summary NVARCHAR(500),
    @MainImage VARBINARY(MAX),
    @Content NVARCHAR(MAX),
    @CreatedAt DATETIME,
    @IsDeleted BIT,
    @Categories ArticleCategoriesAdding READONLY,
    @UserId NVARCHAR(128)
) 
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRANSACTION 
    BEGIN TRY 

 

            INSERT INTO [Articles]
            ([Title],
            [Summary],
            [MainImage],
            [Content],
            [CreatedUserId], 
            [CreatedAt], 
            [IsDeleted], 
            [IsPublished], 
            [PublishedAt]) 
            VALUES 
            (@Title,
            @Summary,
            @MainImage,
            @Content,
            @UserId,
            @CreatedAt, 
            0,
            0,
            null)

 

            INSERT INTO [ArticleCategories]
            ([ArticleId],
            [CategoryId]
            )
            SELECT SCOPE_IDENTITY(), [CategoryId] FROM @Categories
    END TRY
    BEGIN CATCH 
        IF @@TRANCOUNT > 0 
        BEGIN
            ROLLBACK TRANSACTION 
        END
        DECLARE @ErrorMessage VARCHAR(MAX) = CONCAT('The following error has occurred: ', ERROR_MESSAGE());
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH 

 

    
    IF @@TRANCOUNT > 0 
    BEGIN
        COMMIT TRANSACTION 
    END
END
 


 CREATE TYPE ArticleCategoriesAdding AS TABLE(
    CategoryId INT
)




create PROCEDURE PublishArticle
(
    @ArticleId INT,
    @UserId NVARCHAR(128)
)
AS 
BEGIN 
    SET NOCOUNT ON
    BEGIN TRY

 

        UPDATE [Articles] SET [PublishedAt] = GETDATE(), IsPublished = 1, [PublishedUserId] = @UserId WHERE [ArticleId] = @ArticleId 

 

    END TRY 
    BEGIN CATCH 
        DECLARE @ErrorMessage VARCHAR(1000)= CONCAT('The following error has occurred: ', ERROR_MESSAGE()); 
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END




create PROCEDURE GetAllUnpublishedArticles
AS 
BEGIN
	BEGIN TRY
			SELECT [ArticleId],
			   [Title],
			   [Summary],
			   [MainImage],
			   [content],
			   [CreatedUserId],
			   [CreatedAt], 
			   [IsDeleted], 
			   [IsPublished], 
			   [PublishedAt] 
			FROM [Articles]
			WHERE [IsPublished] = 0
			AND [IsDeleted] = 0

	END TRY 
	BEGIN CATCH 
		DECLARE @ErrorMessage VARCHAR(1000) = CONCAT('The following error has occurred: ', ERROR_MESSAGE())
		RAISERROR(@ErrorMessage, 16, 1); 
	END CATCH
END;


CREATE PROCEDURE DeleteArticle
(
    @ArticleId INT
)
AS
BEGIN
    UPDATE [Articles]
    SET [IsDeleted] = 1
    WHERE [ArticleId] = @ArticleId
END




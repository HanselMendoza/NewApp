CREATE PROCEDURE GetAllArticlesById
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
        Content, 
        [CreatedAt], 
        [IsDeleted], 
        [IsPublished], 
        [PublishedAt] 
    FROM [Articles]
    WHERE [ArticleId] = @ArticleId

 

END
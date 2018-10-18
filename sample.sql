/*
EXEC msdb.dbo.sp_delete_database_backuphistory
	@database_name = N'ViewWithSchemaBinding'
GO

USE [master]
GO

ALTER DATABASE [ViewWithSchemaBinding]
	SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO

USE [master]
GO

DROP DATABASE [ViewWithSchemaBinding]
GO
*/
USE [master]
GO

CREATE DATABASE [ViewWithSchemaBinding]
GO

USE [ViewWithSchemaBinding]
GO

CREATE SCHEMA [Products]
GO

CREATE TABLE [Products].[ProductMains]
(
	[No]			INT NOT NULL,
	[Name]			NVARCHAR(50),

	[UnitPrice]		SMALLMONEY,
	[IsStock]		BIT,

	[whenCreated]	SMALLDATETIME DEFAULT (GETDATE()),

	CONSTRAINT [pk_ProductMains] PRIMARY KEY ([No])
)
GO

INSERT INTO [Products].[ProductMains] ([No],[Name],[UnitPrice],[IsStock])
	VALUES (1,N'Google Pixel 3 64GB',27700,1)
INSERT INTO [Products].[ProductMains] ([No],[Name],[UnitPrice],[IsStock])
	VALUES (2,N'Google Pixel 3 128GB',30700,1)
INSERT INTO [Products].[ProductMains] ([No],[Name],[UnitPrice],[IsStock])
	VALUES (3,N'Google Pixel 3 XL 64GB',31100,1)
INSERT INTO [Products].[ProductMains] ([No],[Name],[UnitPrice],[IsStock])
	VALUES (4,N'Google Pixel 3 XL 128GB',34100,1)
GO

--建立商品價格 > 0 的商品清單
--	並指定 SCHEMABINDING
CREATE VIEW [Products].[Products]
	WITH SCHEMABINDING
AS
	SELECT [No]
		,[Name]
		,[UnitPrice]
		,[IsStock]
	FROM [Products].[ProductMains]
	WHERE [UnitPrice] > 0
GO

SELECT * FROM [Products].[ProductMains]
GO

--取得檢視表內容
SELECT * FROM [Products].[Products]
GO

RETURN

--------------------------------------
-- 進行 SCHEMABINDING 驗證
--------------------------------------

--------------------------------------
--與 [Products].[Products] 沒有關聯的物件時沒有問題
--------------------------------------

--新增一個資料欄位
ALTER TABLE [Products].[ProductMains]
	ADD [MemberCreated] NVARCHAR(50)
GO 

--刪除沒有相關參考的欄位也沒有問題
ALTER TABLE [Products].[ProductMains]
	DROP COLUMN [MemberCreated]
GO

--------------------------------------
--當異動跟檢視表 [Products].[ProductMains] 參考欄位有相關時
--	就會出現 exception
--------------------------------------

--變更參考欄位 (Name) 的欄位型態
ALTER TABLE [Products].[ProductMains]
	ALTER COLUMN [Name] NVARCHAR(150)
GO

--將參考欄位 (Name) 進行刪除時也會回傳錯誤訊息
ALTER TABLE [Products].[ProductMains]
	DROP COLUMN [Name]
GO
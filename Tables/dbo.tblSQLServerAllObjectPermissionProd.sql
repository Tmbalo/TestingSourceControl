CREATE TABLE [dbo].[tblSQLServerAllObjectPermissionProd]
(
[ServerName] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DatabaseName] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[login_name] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserName] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserType] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RoleName] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Permission_Type] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Permission_State] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Objecct_Type] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Object_Name] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Date_Modified] [datetime] NULL,
[Date_Created] [datetime] NULL,
[Date_Added] [datetime] NULL,
[Is_Disabled] [int] NULL
) ON [PRIMARY]
GO

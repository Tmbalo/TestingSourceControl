CREATE TABLE [dbo].[BlitzResults]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[ServerName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CheckDate] [datetimeoffset] NULL,
[Priority] [tinyint] NULL,
[FindingsGroup] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Finding] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[URL] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Details] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QueryPlan] [xml] NULL,
[QueryPlanFiltered] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CheckID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BlitzResults] ADD CONSTRAINT [PK_4430295E-8F95-40AF-915B-97A5483507E0] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO

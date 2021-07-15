CREATE TABLE [dbo].[CounterDetails]
(
[CounterID] [int] NOT NULL IDENTITY(1, 1),
[MachineName] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ObjectName] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CounterName] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CounterType] [int] NOT NULL,
[DefaultScale] [int] NOT NULL,
[InstanceName] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InstanceIndex] [int] NULL,
[ParentName] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ParentObjectID] [int] NULL,
[TimeBaseA] [int] NULL,
[TimeBaseB] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CounterDetails] ADD CONSTRAINT [PK__CounterD__F12879E4C7AA3B6F] PRIMARY KEY CLUSTERED ([CounterID]) ON [PRIMARY]
GO

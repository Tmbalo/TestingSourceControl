CREATE TABLE [dbo].[Monitor_Blocking]
(
[LogId] [int] NOT NULL IDENTITY(1, 1),
[LogDateTime] [datetime2] (0) NOT NULL CONSTRAINT [DF_Monitor_Blocking_LogDateTime] DEFAULT (getdate()),
[LeadingBlocker] [smallint] NULL,
[BlockedSpidCount] [int] NULL,
[DbName] [sys].[sysname] NOT NULL,
[HostName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoginName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoginTime] [datetime2] (3) NULL,
[LastRequestStart] [datetime2] (3) NULL,
[LastRequestEnd] [datetime2] (3) NULL,
[TransactionCnt] [int] NULL,
[Command] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WaitTime] [int] NULL,
[WaitResource] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SqlText] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InputBuffer] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SqlStatement] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Monitor_Blocking] ADD CONSTRAINT [PK_Monitor_Blocking] PRIMARY KEY CLUSTERED ([LogDateTime], [LogId]) ON [PRIMARY]
GO

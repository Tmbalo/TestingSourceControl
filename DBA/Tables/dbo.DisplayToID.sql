CREATE TABLE [dbo].[DisplayToID]
(
[GUID] [uniqueidentifier] NOT NULL,
[RunID] [int] NULL,
[DisplayString] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LogStartTime] [char] (24) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LogStopTime] [char] (24) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NumberOfRecords] [int] NULL,
[MinutesToUTC] [int] NULL,
[TimeZoneName] [char] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DisplayToID] ADD CONSTRAINT [PK__DisplayT__15B69B8EFE2A956C] PRIMARY KEY CLUSTERED ([GUID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DisplayToID] ADD CONSTRAINT [UQ__DisplayT__FA63CFA69D6001F7] UNIQUE NONCLUSTERED ([DisplayString]) ON [PRIMARY]
GO

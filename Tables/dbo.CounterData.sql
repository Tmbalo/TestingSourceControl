CREATE TABLE [dbo].[CounterData]
(
[GUID] [uniqueidentifier] NOT NULL,
[CounterID] [int] NOT NULL,
[RecordIndex] [int] NOT NULL,
[CounterDateTime] [char] (24) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CounterValue] [float] NOT NULL,
[FirstValueA] [int] NULL,
[FirstValueB] [int] NULL,
[SecondValueA] [int] NULL,
[SecondValueB] [int] NULL,
[MultiCount] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CounterData] ADD CONSTRAINT [PK__CounterD__1FB2147BCD72ACBF] PRIMARY KEY CLUSTERED ([CounterID], [CounterDateTime]) ON [PRIMARY]
GO

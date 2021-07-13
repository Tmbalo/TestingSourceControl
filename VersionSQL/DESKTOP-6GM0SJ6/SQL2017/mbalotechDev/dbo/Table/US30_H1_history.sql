/****** Object:  Table [dbo].[US30_H1_history]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[US30_H1_history](
	[Date] [datetime2](7) NOT NULL,
	[Time] [datetime2](7) NOT NULL,
	[Range_in_Pips] [nvarchar](50) NOT NULL
) ON [PRIMARY]
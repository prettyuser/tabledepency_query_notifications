USE [TestDB]
GO
CREATE SERVICE [dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771_Receiver]  ON QUEUE [dbo].[dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771_Receiver] 

USE [TestDB]
GO
CREATE SERVICE [dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771_Sender]  ON QUEUE [dbo].[dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771_Sender] 
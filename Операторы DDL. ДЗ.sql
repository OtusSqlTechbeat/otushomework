-- Exported from QuickDBD: https://www.quickdatabasediagrams.com/
-- NOTE! If you have used non-SQL datatypes in your design, you will have to change these here.

-- Modify this code to update the DB schema diagram.
-- To reset the sample schema, replace everything with
-- two dots ('..' - without quotes).

CREATE DATABASE EmployeesStructure
WAITFOR DELAY '00:00:05';
go
USE EmployeesStructure
go

SET XACT_ABORT ON

BEGIN TRANSACTION QUICKDBD

CREATE TABLE [Employees] (
    [EmployeeID] int IDENTITY(1,1)  NOT NULL ,
    [Name] varchar(100)  NOT NULL ,
    [InternalPhone] varchar(4)  NOT NULL ,
    [MobilePhone] varchar(20)  NOT NULL ,
    [Birthday] date  NOT NULL ,
    CONSTRAINT [PK_Employees] PRIMARY KEY CLUSTERED (
        [EmployeeID] ASC
    ),
	  -- Ограничение на уникальность мобильного телефона
    CONSTRAINT [UQ_MobilePhone] UNIQUE ([MobilePhone]),
    
    -- Ограничение на формат номера
    CONSTRAINT [CK_MobilePhone_Format] CHECK (
        [MobilePhone] LIKE '+7[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
        OR
        [MobilePhone] LIKE '7[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
    ),
    
    -- Ограничение на длину номера
    CONSTRAINT [CK_MobilePhone_Length] CHECK (
        LEN([MobilePhone]) BETWEEN 11 AND 20
    ),
    
    -- Ограничение на допустимые символы
    CONSTRAINT [CK_MobilePhone_ValidChars] CHECK (
        [MobilePhone] NOT LIKE '%[^0-9+()-]%'
    )
)


CREATE TABLE [Cfos] (
    [Cfo] varchar(10)  NOT NULL ,
    [ParentCfo] varchar(10)  NOT NULL ,
    [CfoName] varchar(100)  NOT NULL ,
    [DateFrom] date  NOT NULL ,
    CONSTRAINT [PK_Cfos] PRIMARY KEY CLUSTERED (
        [Cfo] ASC
    )
)

CREATE TABLE [EmployeesCfoStructure] (
    [EmployeesCfoStructureId] int  NOT NULL ,
    [EmployeeID] int  NOT NULL ,
    [Cfo] varchar(10)  NOT NULL ,
    [IsActive] bit  NOT NULL ,
    [DateFrom] date  NOT NULL ,
    CONSTRAINT [PK_EmployeesCfoStructure] PRIMARY KEY CLUSTERED (
        [EmployeesCfoStructureId] ASC
    )
)

CREATE TABLE [Roles] (
    [RoleID] int  NOT NULL ,
    [RoleName] varchar(100)  NOT NULL ,
    CONSTRAINT [PK_Roles] PRIMARY KEY CLUSTERED (
        [RoleID] ASC
    )
)

CREATE TABLE [EmployeeRole] (
    [EmployeeID] int  NOT NULL ,
    [RoleID] int  NOT NULL 
)

CREATE TABLE [Reports] (
    [ReportId] int  NOT NULL ,
    [ReportName] varchar(100)  NOT NULL ,
    CONSTRAINT [PK_Reports] PRIMARY KEY CLUSTERED (
        [ReportId] ASC
    )
)

CREATE TABLE [EmployeeReport] (
    [EmployeeID] int  NOT NULL ,
    [ReportId] int  NOT NULL 
)

ALTER TABLE [EmployeesCfoStructure] WITH CHECK ADD CONSTRAINT [FK_EmployeesCfoStructure_EmployeeID] FOREIGN KEY([EmployeeID])
REFERENCES [Employees] ([EmployeeID])

ALTER TABLE [EmployeesCfoStructure] CHECK CONSTRAINT [FK_EmployeesCfoStructure_EmployeeID]

ALTER TABLE [EmployeesCfoStructure] WITH CHECK ADD CONSTRAINT [FK_EmployeesCfoStructure_Cfo] FOREIGN KEY([Cfo])
REFERENCES [Cfos] ([Cfo])

ALTER TABLE [EmployeesCfoStructure] CHECK CONSTRAINT [FK_EmployeesCfoStructure_Cfo]

ALTER TABLE [EmployeeRole] WITH CHECK ADD CONSTRAINT [FK_EmployeeRole_EmployeeID] FOREIGN KEY([EmployeeID])
REFERENCES [Employees] ([EmployeeID])

ALTER TABLE [EmployeeRole] CHECK CONSTRAINT [FK_EmployeeRole_EmployeeID]

ALTER TABLE [EmployeeRole] WITH CHECK ADD CONSTRAINT [FK_EmployeeRole_RoleID] FOREIGN KEY([RoleID])
REFERENCES [Roles] ([RoleID])

ALTER TABLE [EmployeeRole] CHECK CONSTRAINT [FK_EmployeeRole_RoleID]

ALTER TABLE [EmployeeReport] WITH CHECK ADD CONSTRAINT [FK_EmployeeReport_EmployeeID] FOREIGN KEY([EmployeeID])
REFERENCES [Employees] ([EmployeeID])

ALTER TABLE [EmployeeReport] CHECK CONSTRAINT [FK_EmployeeReport_EmployeeID]

ALTER TABLE [EmployeeReport] WITH CHECK ADD CONSTRAINT [FK_EmployeeReport_ReportId] FOREIGN KEY([ReportId])
REFERENCES [Reports] ([ReportId])

ALTER TABLE [EmployeeReport] CHECK CONSTRAINT [FK_EmployeeReport_ReportId]

COMMIT TRANSACTION QUICKDBD
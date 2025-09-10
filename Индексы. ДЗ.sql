CREATE NONCLUSTERED INDEX IX_Employees_Birthday
ON Employees (Birthday);


CREATE NONCLUSTERED INDEX IX_Employees_Name
ON Employees (Name);


CREATE NONCLUSTERED INDEX IX_EmployeesCfoStructure_DateFrom
ON EmployeesCfoStructure (DateFrom);

CREATE NONCLUSTERED INDEX IX_EmployeeReport_ReportId
ON EmployeeReport (ReportId);

--получить информацию на дату, без деталки по сотрудникам
EXEC [EmployeesStructure].[dbo].[GetStructureOnDate] @DT='2025-03-05'

--все на текущий момент, без деталки по сотрудникам
EXEC [EmployeesStructure].[dbo].[GetStructureOnDate] 

--все на дату, с деталкой по сотрудникам
EXEC [EmployeesStructure].[dbo].[GetStructureOnDate] @DT='2025-06-05',@WithAdditionalInfo=1

--на дату по конкретному ЦФО, без деталки по сотрудникам
EXEC [EmployeesStructure].[dbo].[GetStructureOnDate] @DT='2025-06-05',@CFO='910.2'

--на дату по конкретному ЦФО, без деталки по сотрудникам. Изменение ЦФО у сотрудника Пирогов Петр Давидович
EXEC [EmployeesStructure].[dbo].[GetStructureOnDate] @DT='2025-03-05',@CFO='910.4'

--на дату по конкретному ЦФО, с деталкой по сотрудникам
EXEC [EmployeesStructure].[dbo].[GetStructureOnDate] @DT='2025-03-05',@CFO='101.2',@WithAdditionalInfo=1

--получаем какие сотрудники имеют доступ к отчету
SELECT * FROM [EmployeesStructure].[dbo].[GetEmployeesByReportName]('звон')

--получаем к каким отчетам сотрудник имеет доступ
SELECT * FROM [EmployeesStructure].[dbo].[GetReportsByEmployeeName]('Петров')

--добавляем информацию по новому сотруднику
EXEC [EmployeesStructure].[dbo].[InsertEmployeeInfo] @Name='Петров Алексей Алексеевич',@InternalPhone='3059',@MobilePhone='79160613994',@Birthday='2001-11-07',@CFO='910',@Roleid=3

--проверяем
SELECT e.*
,ecs.Cfo
,ecs.DateFrom
,ecs.IsActive
,r.RoleName
FROM [EmployeesStructure].[dbo].[Employees] e
LEFT JOIN [EmployeesStructure].[dbo].[EmployeesCfoStructure] ecs On ecs.EmployeeID=e.EmployeeID
LEFT JOIN [EmployeesStructure].[dbo].EmployeeRole er On er.EmployeeID=e.EmployeeID
LEFT JOIN [EmployeesStructure].[dbo].Roles r On r.RoleID=er.RoleID
WHERE e.EmployeeID=127



--Добавляем доступ к отчету для сотрудника
exec [EmployeesStructure].[dbo].[LinkReporttoEmployee] @EmployeeID=105,@ReportID=4



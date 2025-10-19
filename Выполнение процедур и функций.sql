
--�������� ���������� �� ����, ��� ������� �� �����������
EXEC [EmployeesStructure].[dbo].[GetStructureOnDate] @DT='2025-03-05'

--��� �� ������� ������, ��� ������� �� �����������
EXEC [EmployeesStructure].[dbo].[GetStructureOnDate] 

--��� �� ����, � �������� �� �����������
EXEC [EmployeesStructure].[dbo].[GetStructureOnDate] @DT='2025-06-05',@WithAdditionalInfo=1

--�� ���� �� ����������� ���, ��� ������� �� �����������
EXEC [EmployeesStructure].[dbo].[GetStructureOnDate] @DT='2025-06-05',@CFO='910.2'

--�� ���� �� ����������� ���, ��� ������� �� �����������. ��������� ��� � ���������� ������� ���� ���������
EXEC [EmployeesStructure].[dbo].[GetStructureOnDate] @DT='2025-03-05',@CFO='910.4'

--�� ���� �� ����������� ���, � �������� �� �����������
EXEC [EmployeesStructure].[dbo].[GetStructureOnDate] @DT='2025-03-05',@CFO='101.2',@WithAdditionalInfo=1

--�������� ����� ���������� ����� ������ � ������
SELECT * FROM [EmployeesStructure].[dbo].[GetEmployeesByReportName]('����')

--�������� � ����� ������� ��������� ����� ������
SELECT * FROM [EmployeesStructure].[dbo].[GetReportsByEmployeeName]('������')

--��������� ���������� �� ������ ����������
EXEC [EmployeesStructure].[dbo].[InsertEmployeeInfo] @Name='������ ������� ����������',@InternalPhone='3059',@MobilePhone='79160613994',@Birthday='2001-11-07',@CFO='910',@Roleid=3

--���������
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



--��������� ������ � ������ ��� ����������
exec [EmployeesStructure].[dbo].[LinkReporttoEmployee] @EmployeeID=105,@ReportID=4



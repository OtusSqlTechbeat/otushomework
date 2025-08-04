CREATE ASSEMBLY hw_clr
FROM 'C:\hw_clr.dll'
WITH PERMISSION_SET = SAFE;

GO
/*
DROP FUNCTION dbo.hw_clr
DROP  ASSEMBLY hw_clr
*/
CREATE FUNCTION dbo.hw_clr(@input nvarchar(100))  
RETURNS nvarchar(100)
AS EXTERNAL NAME hw_clr.[hw_clr.Class1].ApplyMask;

SELECT dbo.hw_clr('9161607322')

SELECT dbo.hw_clr('0019161607322')

SELECT dbo.hw_clr('1607322')

SELECT dbo.hw_clr('3224')


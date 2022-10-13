SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON
SET ANSI_WARNINGS OFF
SET ARITHABORT OFF
SET ARITHIGNORE ON
SET TEXTSIZE 2147483647


-----------------------------------------------------------------------------------------------------------------------------
--Script Details: Listing Of Standard Details Related To The Script
-----------------------------------------------------------------------------------------------------------------------------

--Purpose: Date Calendar Cross-Reference Table
--Create Date (MM/DD/YYYY): 10/29/2009
--Developer: Sean Smith (s.smith.sql AT gmail DOT com)
--Latest Release: http://www.sqlservercentral.com/scripts/Date/68389/
--Script Library: http://www.sqlservercentral.com/Authors/Scripts/Sean_Smith/776614/
--LinkedIn Profile: https://www.linkedin.com/in/seanmsmith/


-----------------------------------------------------------------------------------------------------------------------------
--Modification History: Listing Of All Modifications Since Original Implementation
-----------------------------------------------------------------------------------------------------------------------------

--Description: Fixed Bug Affecting "Month_Weekdays_Remaining" And "Quarter_Weekdays_Remaining" Columns
--Date (MM/DD/YYYY): 07/02/2014


-----------------------------------------------------------------------------------------------------------------------------
--Declarations / Sets: Declare And Set Variables
-----------------------------------------------------------------------------------------------------------------------------

DECLARE @Date_Start AS datetime,
        @Date_End AS datetime


SET @Date_Start = '20000101'


SET @Date_End = '20501231'


-----------------------------------------------------------------------------------------------------------------------------
--Error Trapping: Check If Permanent Table(s) Already Exist(s) And Drop If Applicable
-----------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID(N'dbo.Date_Calendar', N'U') IS NOT NULL
BEGIN

  DROP TABLE dbo.Date_Calendar

END


-----------------------------------------------------------------------------------------------------------------------------
--Permanent Table: Create Date Xref Table
-----------------------------------------------------------------------------------------------------------------------------

CREATE TABLE dbo.Date_Calendar (
  Calendar_Date datetime NOT NULL CONSTRAINT PK_Date_Calendar_Calendar_Date PRIMARY KEY CLUSTERED,
  Calendar_Year smallint NULL,
  Calendar_Month tinyint NULL,
  Calendar_Day tinyint NULL,
  Calendar_Quarter tinyint NULL,
  First_Day_in_Week datetime NULL,
  Last_Day_in_Week datetime NULL,
  Is_Week_in_Same_Month int NULL,
  First_Day_in_Month datetime NULL,
  Last_Day_in_Month datetime NULL,
  Is_Last_Day_in_Month int NULL,
  First_Day_in_Quarter datetime NULL,
  Last_Day_in_Quarter datetime NULL,
  Is_Last_Day_in_Quarter int NULL,
  Day_of_Week tinyint NULL,
  Week_of_Month tinyint NULL,
  Week_of_Quarter tinyint NULL,
  Week_of_Year tinyint NULL,
  Days_in_Month tinyint NULL,
  Month_Days_Remaining tinyint NULL,
  Weekdays_in_Month tinyint NULL,
  Month_Weekdays_Remaining tinyint NULL,
  Month_Weekdays_Completed tinyint NULL,
  Days_in_Quarter tinyint NULL,
  Quarter_Days_Remaining tinyint NULL,
  Quarter_Days_Completed tinyint NULL,
  Weekdays_in_Quarter tinyint NULL,
  Quarter_Weekdays_Remaining tinyint NULL,
  Quarter_Weekdays_Completed tinyint NULL,
  Day_of_Year smallint NULL,
  Year_Days_Remaining smallint NULL,
  Is_Weekday int NULL,
  Is_Leap_Year int NULL,
  Day_Name varchar(10) NULL,
  Month_Day_Name_Instance tinyint NULL,
  Quarter_Day_Name_Instance tinyint NULL,
  Year_Day_Name_Instance tinyint NULL,
  Month_Name varchar(10) NULL,
  Year_Week char(6) NULL,
  Year_Month char(6) NULL,
  Year_Quarter char(6) NULL
)


-----------------------------------------------------------------------------------------------------------------------------
--Table Insert: Populate Base Date Values Into Permanent Table Using Common Table Expression (CTE)
-----------------------------------------------------------------------------------------------------------------------------

;
WITH CTE_Date_Base_Table
AS (SELECT
  @Date_Start AS Calendar_Date

UNION ALL

SELECT
  DATEADD(DAY, 1, cDBT.Calendar_Date)
FROM CTE_Date_Base_Table cDBT
WHERE DATEADD(DAY, 1, cDBT.Calendar_Date) <= @Date_End)

INSERT INTO dbo.Date_Calendar (Calendar_Date)

  SELECT
    cDBT.Calendar_Date
  FROM CTE_Date_Base_Table cDBT
  OPTION (MAXRECURSION 0)


-----------------------------------------------------------------------------------------------------------------------------
--Table Update I: Populate Additional Date Xref Table Fields (Pass I)
-----------------------------------------------------------------------------------------------------------------------------

UPDATE dbo.Date_Calendar
SET Calendar_Year = DATEPART(YEAR, Calendar_Date),
    Calendar_Month = DATEPART(MONTH, Calendar_Date),
    Calendar_Day = DATEPART(DAY, Calendar_Date),
    Calendar_Quarter = DATEPART(QUARTER, Calendar_Date),
    First_Day_in_Week = DATEADD(DAY, -DATEPART(WEEKDAY, Calendar_Date) + 1, Calendar_Date),
    First_Day_in_Month = CONVERT(varchar(6), Calendar_Date, 112) + '01',
    Day_of_Week = DATEPART(WEEKDAY, Calendar_Date),
    Week_of_Year = DATEPART(WEEK, Calendar_Date),
    Day_of_Year = DATEPART(DAYOFYEAR, Calendar_Date),
    Is_Weekday = (CASE
      WHEN ((@@DATEFIRST - 1) + (DATEPART(WEEKDAY, Calendar_Date) - 1)) % 7 NOT IN (5, 6) THEN 1
      ELSE 0
    END),
    Day_Name = DATENAME(WEEKDAY, Calendar_Date),
    Month_Name = DATENAME(MONTH, Calendar_Date)


ALTER TABLE dbo.Date_Calendar ALTER COLUMN Calendar_Year int NOT NULL


ALTER TABLE dbo.Date_Calendar ALTER COLUMN Calendar_Month int NOT NULL


ALTER TABLE dbo.Date_Calendar ALTER COLUMN Calendar_Day int NOT NULL


ALTER TABLE dbo.Date_Calendar ALTER COLUMN Calendar_Quarter int NOT NULL


ALTER TABLE dbo.Date_Calendar ALTER COLUMN First_Day_in_Week datetime NOT NULL


ALTER TABLE dbo.Date_Calendar ALTER COLUMN First_Day_in_Month datetime NOT NULL


ALTER TABLE dbo.Date_Calendar ALTER COLUMN Day_of_Week int NOT NULL


ALTER TABLE dbo.Date_Calendar ALTER COLUMN Week_of_Year int NOT NULL


ALTER TABLE dbo.Date_Calendar ALTER COLUMN Day_of_Year int NOT NULL


ALTER TABLE dbo.Date_Calendar ALTER COLUMN Is_Weekday int NOT NULL


ALTER TABLE dbo.Date_Calendar ALTER COLUMN Day_Name varchar(10) NOT NULL


ALTER TABLE dbo.Date_Calendar ALTER COLUMN Month_Name varchar(10) NOT NULL


CREATE NONCLUSTERED INDEX IX_Date_Calendar_Calendar_Year ON dbo.Date_Calendar (Calendar_Year)


CREATE NONCLUSTERED INDEX IX_Date_Calendar_Calendar_Month ON dbo.Date_Calendar (Calendar_Month)


CREATE NONCLUSTERED INDEX IX_Date_Calendar_Calendar_Quarter ON dbo.Date_Calendar (Calendar_Quarter)


CREATE NONCLUSTERED INDEX IX_Date_Calendar_First_Day_in_Week ON dbo.Date_Calendar (First_Day_in_Week)


CREATE NONCLUSTERED INDEX IX_Date_Calendar_Day_of_Week ON dbo.Date_Calendar (Day_of_Week)


CREATE NONCLUSTERED INDEX IX_Date_Calendar_Is_Weekday ON dbo.Date_Calendar (Is_Weekday)


-----------------------------------------------------------------------------------------------------------------------------
--Table Update II: Populate Additional Date Xref Table Fields (Pass II)
-----------------------------------------------------------------------------------------------------------------------------

UPDATE DC
SET DC.Last_Day_in_Week = DC.First_Day_in_Week + 6,
    DC.Last_Day_in_Month = DATEADD(MONTH, 1, DC.First_Day_in_Month) - 1,
    DC.First_Day_in_Quarter = sqDC.First_Day_in_Quarter,
    DC.Last_Day_in_Quarter = sqDC.Last_Day_in_Quarter,
    DC.Week_of_Month = DATEDIFF(WEEK, DC.First_Day_in_Month, DC.Calendar_Date) + 1,
    DC.Week_of_Quarter = (DC.Week_of_Year - sqDC.min_Week_of_Year_in_quarter) + 1,
    DC.Is_Leap_Year = (CASE
      WHEN DC.Calendar_Year % 400 = 0 THEN 1
      WHEN DC.Calendar_Year % 100 = 0 THEN 0
      WHEN DC.Calendar_Year % 4 = 0 THEN 1
      ELSE 0
    END),
    DC.Year_Week = CONVERT(varchar(4), DC.Calendar_Year) + RIGHT('0' + CONVERT(varchar(2), DC.Week_of_Year), 2),
    DC.Year_Month = CONVERT(varchar(4), DC.Calendar_Year) + RIGHT('0' + CONVERT(varchar(2), DC.Calendar_Month), 2),
    DC.Year_Quarter = CONVERT(varchar(4), DC.Calendar_Year) + 'Q' + CONVERT(varchar(1), DC.Calendar_Quarter)
FROM dbo.Date_Calendar DC
INNER JOIN (SELECT
  DC.Calendar_Year,
  DC.Calendar_Quarter,
  MIN(DC.Calendar_Date) AS First_Day_in_Quarter,
  MAX(DC.Calendar_Date) AS Last_Day_in_Quarter,
  MIN(DC.Week_of_Year) AS min_Week_of_Year_in_quarter
FROM dbo.Date_Calendar DC
GROUP BY DC.Calendar_Year,
         DC.Calendar_Quarter) sqDC
  ON sqDC.Calendar_Year = DC.Calendar_Year
  AND sqDC.Calendar_Quarter = DC.Calendar_Quarter


ALTER TABLE dbo.Date_Calendar ALTER COLUMN Last_Day_in_Week datetime NOT NULL


ALTER TABLE dbo.Date_Calendar ALTER COLUMN Last_Day_in_Month datetime NOT NULL


ALTER TABLE dbo.Date_Calendar ALTER COLUMN First_Day_in_Quarter datetime NOT NULL


ALTER TABLE dbo.Date_Calendar ALTER COLUMN Last_Day_in_Quarter datetime NOT NULL


ALTER TABLE dbo.Date_Calendar ALTER COLUMN Week_of_Month int NOT NULL


ALTER TABLE dbo.Date_Calendar ALTER COLUMN Week_of_Quarter int NOT NULL


ALTER TABLE dbo.Date_Calendar ALTER COLUMN Is_Leap_Year int NOT NULL


ALTER TABLE dbo.Date_Calendar ALTER COLUMN Year_Week varchar(6) NOT NULL


ALTER TABLE dbo.Date_Calendar ALTER COLUMN Year_Month varchar(6) NOT NULL


ALTER TABLE dbo.Date_Calendar ALTER COLUMN Year_Quarter varchar(6) NOT NULL


CREATE NONCLUSTERED INDEX IX_Date_Calendar_Last_Day_in_Week ON dbo.Date_Calendar (Last_Day_in_Week)


CREATE NONCLUSTERED INDEX IX_Date_Calendar_Year_Month ON dbo.Date_Calendar (Year_Month)


CREATE NONCLUSTERED INDEX IX_Date_Calendar_Year_Quarter ON dbo.Date_Calendar (Year_Quarter)


-----------------------------------------------------------------------------------------------------------------------------
--Table Update III: Populate Additional Date Xref Table Fields (Pass III)
-----------------------------------------------------------------------------------------------------------------------------

UPDATE DC
SET DC.Is_Last_Day_in_Month = (CASE
      WHEN DC.Last_Day_in_Month = DC.Calendar_Date THEN 1
      ELSE 0
    END),
    DC.Is_Last_Day_in_Quarter = (CASE
      WHEN DC.Last_Day_in_Quarter = DC.Calendar_Date THEN 1
      ELSE 0
    END),
    DC.Days_in_Month = DATEPART(DAY, DC.Last_Day_in_Month),
    DC.Weekdays_in_Month = sqDC1.Weekdays_in_Month,
    DC.Days_in_Quarter = DATEDIFF(DAY, DC.First_Day_in_Quarter, DC.Last_Day_in_Quarter) + 1,
    DC.Quarter_Days_Remaining = DATEDIFF(DAY, DC.Calendar_Date, DC.Last_Day_in_Quarter),
    DC.Weekdays_in_Quarter = sqDC2.Weekdays_in_Quarter,
    DC.Year_Days_Remaining = (365 + DC.Is_Leap_Year) - DC.Day_of_Year
FROM dbo.Date_Calendar DC
INNER JOIN (SELECT
  DC.Year_Month,
  SUM(DC.Is_Weekday) AS Weekdays_in_Month
FROM dbo.Date_Calendar DC
GROUP BY DC.Year_Month) sqDC1
  ON sqDC1.Year_Month = DC.Year_Month

INNER JOIN (SELECT
  DC.Year_Quarter,
  SUM(DC.Is_Weekday) AS Weekdays_in_Quarter
FROM dbo.Date_Calendar DC
GROUP BY DC.Year_Quarter) sqDC2
  ON sqDC2.Year_Quarter = DC.Year_Quarter


ALTER TABLE dbo.Date_Calendar ALTER COLUMN Is_Last_Day_in_Month int NOT NULL


ALTER TABLE dbo.Date_Calendar ALTER COLUMN Is_Last_Day_in_Quarter int NOT NULL


ALTER TABLE dbo.Date_Calendar ALTER COLUMN Days_in_Month int NOT NULL


ALTER TABLE dbo.Date_Calendar ALTER COLUMN Weekdays_in_Month int NOT NULL


ALTER TABLE dbo.Date_Calendar ALTER COLUMN Days_in_Quarter int NOT NULL


ALTER TABLE dbo.Date_Calendar ALTER COLUMN Quarter_Days_Remaining int NOT NULL


ALTER TABLE dbo.Date_Calendar ALTER COLUMN Weekdays_in_Quarter int NOT NULL


ALTER TABLE dbo.Date_Calendar ALTER COLUMN Year_Days_Remaining int NOT NULL


-----------------------------------------------------------------------------------------------------------------------------
--Table Update IV: Populate Additional Date Xref Table Fields (Pass IV)
-----------------------------------------------------------------------------------------------------------------------------

UPDATE DC
SET DC.Month_Weekdays_Remaining = DC.Weekdays_in_Month - sqDC.Month_Weekdays_Remaining_subtraction,
    DC.Quarter_Weekdays_Remaining = DC.Weekdays_in_Quarter - sqDC.Quarter_Weekdays_Remaining_subtraction
FROM dbo.Date_Calendar DC
INNER JOIN (SELECT
  DC.Calendar_Date,
  ROW_NUMBER() OVER
  (
  PARTITION BY
  DC.Year_Month
  ORDER BY
  DC.Calendar_Date
  ) AS Month_Weekdays_Remaining_subtraction,
  ROW_NUMBER() OVER
  (
  PARTITION BY
  DC.Year_Quarter
  ORDER BY
  DC.Calendar_Date
  ) AS Quarter_Weekdays_Remaining_subtraction
FROM dbo.Date_Calendar DC
WHERE DC.Is_Weekday = 1) sqDC
  ON sqDC.Calendar_Date = DC.Calendar_Date


-----------------------------------------------------------------------------------------------------------------------------
--Table Update V: Populate Additional Date Xref Table Fields (Pass V)
-----------------------------------------------------------------------------------------------------------------------------

UPDATE DC
SET DC.Month_Weekdays_Remaining = (CASE
      WHEN DC1.Calendar_Month = DC.Calendar_Month AND
        DC1.Month_Weekdays_Remaining IS NOT NULL THEN DC1.Month_Weekdays_Remaining
      WHEN DC2.Calendar_Month = DC.Calendar_Month AND
        DC2.Month_Weekdays_Remaining IS NOT NULL THEN DC2.Month_Weekdays_Remaining
      ELSE DC.Weekdays_in_Month
    END),
    DC.Quarter_Weekdays_Remaining = (CASE
      WHEN DC1.Calendar_Quarter = DC.Calendar_Quarter AND
        DC1.Quarter_Weekdays_Remaining IS NOT NULL THEN DC1.Quarter_Weekdays_Remaining
      WHEN DC2.Calendar_Quarter = DC.Calendar_Quarter AND
        DC2.Quarter_Weekdays_Remaining IS NOT NULL THEN DC2.Quarter_Weekdays_Remaining
      ELSE DC.Weekdays_in_Quarter
    END)
FROM dbo.Date_Calendar DC
LEFT JOIN dbo.Date_Calendar DC1
  ON DATEADD(DAY, 1, DC1.Calendar_Date) = DC.Calendar_Date
LEFT JOIN dbo.Date_Calendar DC2
  ON DATEADD(DAY, 2, DC2.Calendar_Date) = DC.Calendar_Date
WHERE DC.Month_Weekdays_Remaining IS NULL


ALTER TABLE dbo.Date_Calendar ALTER COLUMN Month_Weekdays_Remaining int NOT NULL


ALTER TABLE dbo.Date_Calendar ALTER COLUMN Quarter_Weekdays_Remaining int NOT NULL


-----------------------------------------------------------------------------------------------------------------------------
--Table Update VI: Populate Additional Date Xref Table Fields (Pass VI)
-----------------------------------------------------------------------------------------------------------------------------

UPDATE DC
SET DC.Is_Week_in_Same_Month = sqDC.Is_Week_in_Same_Month,
    DC.Month_Days_Remaining = DC.Days_in_Month - DC.Calendar_Day,
    DC.Month_Weekdays_Completed = DC.Weekdays_in_Month - DC.Month_Weekdays_Remaining,
    DC.Quarter_Days_Completed = DC.Days_in_Quarter - DC.Quarter_Days_Remaining,
    DC.Quarter_Weekdays_Completed = DC.Weekdays_in_Quarter - DC.Quarter_Weekdays_Remaining,
    DC.Month_Day_Name_Instance = sqDC.Month_Day_Name_Instance,
    DC.Quarter_Day_Name_Instance = sqDC.Quarter_Day_Name_Instance,
    DC.Year_Day_Name_Instance = sqDC.Year_Day_Name_Instance
FROM dbo.Date_Calendar DC
INNER JOIN (SELECT
  DC.Calendar_Date,
  (CASE
    WHEN DATEDIFF(MONTH, DC.First_Day_in_Week, DC.Last_Day_in_Week) = 0 THEN 1
    ELSE 0
  END) AS Is_Week_in_Same_Month,
  ROW_NUMBER() OVER
  (
  PARTITION BY
  DC.Year_Month, DC.Day_Name
  ORDER BY
  DC.Calendar_Date
  ) AS Month_Day_Name_Instance,
  ROW_NUMBER() OVER
  (
  PARTITION BY
  DC.Year_Quarter, DC.Day_Name
  ORDER BY
  DC.Calendar_Date
  ) AS Quarter_Day_Name_Instance,
  ROW_NUMBER() OVER
  (
  PARTITION BY
  DC.Calendar_Year, DC.Day_Name
  ORDER BY
  DC.Calendar_Date
  ) AS Year_Day_Name_Instance
FROM dbo.Date_Calendar DC) sqDC
  ON sqDC.Calendar_Date = DC.Calendar_Date


ALTER TABLE dbo.Date_Calendar ALTER COLUMN Is_Week_in_Same_Month int NOT NULL


ALTER TABLE dbo.Date_Calendar ALTER COLUMN Month_Days_Remaining int NOT NULL


ALTER TABLE dbo.Date_Calendar ALTER COLUMN Month_Weekdays_Completed int NOT NULL


ALTER TABLE dbo.Date_Calendar ALTER COLUMN Quarter_Days_Completed int NOT NULL


ALTER TABLE dbo.Date_Calendar ALTER COLUMN Quarter_Weekdays_Completed int NOT NULL


ALTER TABLE dbo.Date_Calendar ALTER COLUMN Month_Day_Name_Instance int NOT NULL


ALTER TABLE dbo.Date_Calendar ALTER COLUMN Quarter_Day_Name_Instance int NOT NULL


ALTER TABLE dbo.Date_Calendar ALTER COLUMN Year_Day_Name_Instance int NOT NULL


-----------------------------------------------------------------------------------------------------------------------------
--Main Query: Final Display / Output
-----------------------------------------------------------------------------------------------------------------------------

SELECT
  DC.*
FROM dbo.Date_Calendar DC
ORDER BY DC.Calendar_Date
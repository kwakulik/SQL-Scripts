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

--Description: Fixed Bug Affecting "month_weekdays_remaining" And "quarter_weekdays_remaining" Columns
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

IF OBJECT_ID(N'dbo.date_calendar', N'U') IS NOT NULL
BEGIN

  DROP TABLE dbo.date_calendar

END


-----------------------------------------------------------------------------------------------------------------------------
--Permanent Table: Create Date Xref Table
-----------------------------------------------------------------------------------------------------------------------------

CREATE TABLE dbo.date_calendar (
  calendar_date datetime NOT NULL CONSTRAINT PK_date_calendar_calendar_date PRIMARY KEY CLUSTERED,
  calendar_year smallint NULL,
  calendar_month tinyint NULL,
  calendar_day tinyint NULL,
  calendar_quarter tinyint NULL,
  first_day_in_week datetime NULL,
  last_day_in_week datetime NULL,
  is_week_in_same_month int NULL,
  first_day_in_month datetime NULL,
  last_day_in_month datetime NULL,
  is_last_day_in_month int NULL,
  first_day_in_quarter datetime NULL,
  last_day_in_quarter datetime NULL,
  is_last_day_in_quarter int NULL,
  day_of_week tinyint NULL,
  week_of_month tinyint NULL,
  week_of_quarter tinyint NULL,
  week_of_year tinyint NULL,
  days_in_month tinyint NULL,
  month_days_remaining tinyint NULL,
  weekdays_in_month tinyint NULL,
  month_weekdays_remaining tinyint NULL,
  month_weekdays_completed tinyint NULL,
  days_in_quarter tinyint NULL,
  quarter_days_remaining tinyint NULL,
  quarter_days_completed tinyint NULL,
  weekdays_in_quarter tinyint NULL,
  quarter_weekdays_remaining tinyint NULL,
  quarter_weekdays_completed tinyint NULL,
  day_of_year smallint NULL,
  year_days_remaining smallint NULL,
  is_weekday int NULL,
  is_leap_year int NULL,
  day_name varchar(10) NULL,
  month_day_name_instance tinyint NULL,
  quarter_day_name_instance tinyint NULL,
  year_day_name_instance tinyint NULL,
  month_name varchar(10) NULL,
  year_week char(6) NULL,
  year_month char(6) NULL,
  year_quarter char(6) NULL
)


-----------------------------------------------------------------------------------------------------------------------------
--Table Insert: Populate Base Date Values Into Permanent Table Using Common Table Expression (CTE)
-----------------------------------------------------------------------------------------------------------------------------

;
WITH CTE_Date_Base_Table
AS (SELECT
  @Date_Start AS calendar_date

UNION ALL

SELECT
  DATEADD(DAY, 1, cDBT.calendar_date)
FROM CTE_Date_Base_Table cDBT
WHERE DATEADD(DAY, 1, cDBT.calendar_date) <= @Date_End)

INSERT INTO dbo.date_calendar (calendar_date)

  SELECT
    cDBT.calendar_date
  FROM CTE_Date_Base_Table cDBT
  OPTION (MAXRECURSION 0)


-----------------------------------------------------------------------------------------------------------------------------
--Table Update I: Populate Additional Date Xref Table Fields (Pass I)
-----------------------------------------------------------------------------------------------------------------------------

UPDATE dbo.date_calendar
SET calendar_year = DATEPART(YEAR, calendar_date),
    calendar_month = DATEPART(MONTH, calendar_date),
    calendar_day = DATEPART(DAY, calendar_date),
    calendar_quarter = DATEPART(QUARTER, calendar_date),
    first_day_in_week = DATEADD(DAY, -DATEPART(WEEKDAY, calendar_date) + 1, calendar_date),
    first_day_in_month = CONVERT(varchar(6), calendar_date, 112) + '01',
    day_of_week = DATEPART(WEEKDAY, calendar_date),
    week_of_year = DATEPART(WEEK, calendar_date),
    day_of_year = DATEPART(DAYOFYEAR, calendar_date),
    is_weekday = (CASE
      WHEN ((@@DATEFIRST - 1) + (DATEPART(WEEKDAY, calendar_date) - 1)) % 7 NOT IN (5, 6) THEN 1
      ELSE 0
    END),
    day_name = DATENAME(WEEKDAY, calendar_date),
    month_name = DATENAME(MONTH, calendar_date)


ALTER TABLE dbo.date_calendar ALTER COLUMN calendar_year int NOT NULL


ALTER TABLE dbo.date_calendar ALTER COLUMN calendar_month int NOT NULL


ALTER TABLE dbo.date_calendar ALTER COLUMN calendar_day int NOT NULL


ALTER TABLE dbo.date_calendar ALTER COLUMN calendar_quarter int NOT NULL


ALTER TABLE dbo.date_calendar ALTER COLUMN first_day_in_week datetime NOT NULL


ALTER TABLE dbo.date_calendar ALTER COLUMN first_day_in_month datetime NOT NULL


ALTER TABLE dbo.date_calendar ALTER COLUMN day_of_week int NOT NULL


ALTER TABLE dbo.date_calendar ALTER COLUMN week_of_year int NOT NULL


ALTER TABLE dbo.date_calendar ALTER COLUMN day_of_year int NOT NULL


ALTER TABLE dbo.date_calendar ALTER COLUMN is_weekday int NOT NULL


ALTER TABLE dbo.date_calendar ALTER COLUMN day_name varchar(10) NOT NULL


ALTER TABLE dbo.date_calendar ALTER COLUMN month_name varchar(10) NOT NULL


CREATE NONCLUSTERED INDEX IX_date_calendar_calendar_year ON dbo.date_calendar (calendar_year)


CREATE NONCLUSTERED INDEX IX_date_calendar_calendar_month ON dbo.date_calendar (calendar_month)


CREATE NONCLUSTERED INDEX IX_date_calendar_calendar_quarter ON dbo.date_calendar (calendar_quarter)


CREATE NONCLUSTERED INDEX IX_date_calendar_first_day_in_week ON dbo.date_calendar (first_day_in_week)


CREATE NONCLUSTERED INDEX IX_date_calendar_day_of_week ON dbo.date_calendar (day_of_week)


CREATE NONCLUSTERED INDEX IX_date_calendar_is_weekday ON dbo.date_calendar (is_weekday)


-----------------------------------------------------------------------------------------------------------------------------
--Table Update II: Populate Additional Date Xref Table Fields (Pass II)
-----------------------------------------------------------------------------------------------------------------------------

UPDATE DC
SET DC.last_day_in_week = DC.first_day_in_week + 6,
    DC.last_day_in_month = DATEADD(MONTH, 1, DC.first_day_in_month) - 1,
    DC.first_day_in_quarter = sqDC.first_day_in_quarter,
    DC.last_day_in_quarter = sqDC.last_day_in_quarter,
    DC.week_of_month = DATEDIFF(WEEK, DC.first_day_in_month, DC.calendar_date) + 1,
    DC.week_of_quarter = (DC.week_of_year - sqDC.min_week_of_year_in_quarter) + 1,
    DC.is_leap_year = (CASE
      WHEN DC.calendar_year % 400 = 0 THEN 1
      WHEN DC.calendar_year % 100 = 0 THEN 0
      WHEN DC.calendar_year % 4 = 0 THEN 1
      ELSE 0
    END),
    DC.year_week = CONVERT(varchar(4), DC.calendar_year) + RIGHT('0' + CONVERT(varchar(2), DC.week_of_year), 2),
    DC.year_month = CONVERT(varchar(4), DC.calendar_year) + RIGHT('0' + CONVERT(varchar(2), DC.calendar_month), 2),
    DC.year_quarter = CONVERT(varchar(4), DC.calendar_year) + 'Q' + CONVERT(varchar(1), DC.calendar_quarter)
FROM dbo.date_calendar DC
INNER JOIN (SELECT
  DC.calendar_year,
  DC.calendar_quarter,
  MIN(DC.calendar_date) AS first_day_in_quarter,
  MAX(DC.calendar_date) AS last_day_in_quarter,
  MIN(DC.week_of_year) AS min_week_of_year_in_quarter
FROM dbo.date_calendar DC
GROUP BY DC.calendar_year,
         DC.calendar_quarter) sqDC
  ON sqDC.calendar_year = DC.calendar_year
  AND sqDC.calendar_quarter = DC.calendar_quarter


ALTER TABLE dbo.date_calendar ALTER COLUMN last_day_in_week datetime NOT NULL


ALTER TABLE dbo.date_calendar ALTER COLUMN last_day_in_month datetime NOT NULL


ALTER TABLE dbo.date_calendar ALTER COLUMN first_day_in_quarter datetime NOT NULL


ALTER TABLE dbo.date_calendar ALTER COLUMN last_day_in_quarter datetime NOT NULL


ALTER TABLE dbo.date_calendar ALTER COLUMN week_of_month int NOT NULL


ALTER TABLE dbo.date_calendar ALTER COLUMN week_of_quarter int NOT NULL


ALTER TABLE dbo.date_calendar ALTER COLUMN is_leap_year int NOT NULL


ALTER TABLE dbo.date_calendar ALTER COLUMN year_week varchar(6) NOT NULL


ALTER TABLE dbo.date_calendar ALTER COLUMN year_month varchar(6) NOT NULL


ALTER TABLE dbo.date_calendar ALTER COLUMN year_quarter varchar(6) NOT NULL


CREATE NONCLUSTERED INDEX IX_date_calendar_last_day_in_week ON dbo.date_calendar (last_day_in_week)


CREATE NONCLUSTERED INDEX IX_date_calendar_year_month ON dbo.date_calendar (year_month)


CREATE NONCLUSTERED INDEX IX_date_calendar_year_quarter ON dbo.date_calendar (year_quarter)


-----------------------------------------------------------------------------------------------------------------------------
--Table Update III: Populate Additional Date Xref Table Fields (Pass III)
-----------------------------------------------------------------------------------------------------------------------------

UPDATE DC
SET DC.is_last_day_in_month = (CASE
      WHEN DC.last_day_in_month = DC.calendar_date THEN 1
      ELSE 0
    END),
    DC.is_last_day_in_quarter = (CASE
      WHEN DC.last_day_in_quarter = DC.calendar_date THEN 1
      ELSE 0
    END),
    DC.days_in_month = DATEPART(DAY, DC.last_day_in_month),
    DC.weekdays_in_month = sqDC1.weekdays_in_month,
    DC.days_in_quarter = DATEDIFF(DAY, DC.first_day_in_quarter, DC.last_day_in_quarter) + 1,
    DC.quarter_days_remaining = DATEDIFF(DAY, DC.calendar_date, DC.last_day_in_quarter),
    DC.weekdays_in_quarter = sqDC2.weekdays_in_quarter,
    DC.year_days_remaining = (365 + DC.is_leap_year) - DC.day_of_year
FROM dbo.date_calendar DC
INNER JOIN (SELECT
  DC.year_month,
  SUM(DC.is_weekday) AS weekdays_in_month
FROM dbo.date_calendar DC
GROUP BY DC.year_month) sqDC1
  ON sqDC1.year_month = DC.year_month

INNER JOIN (SELECT
  DC.year_quarter,
  SUM(DC.is_weekday) AS weekdays_in_quarter
FROM dbo.date_calendar DC
GROUP BY DC.year_quarter) sqDC2
  ON sqDC2.year_quarter = DC.year_quarter


ALTER TABLE dbo.date_calendar ALTER COLUMN is_last_day_in_month int NOT NULL


ALTER TABLE dbo.date_calendar ALTER COLUMN is_last_day_in_quarter int NOT NULL


ALTER TABLE dbo.date_calendar ALTER COLUMN days_in_month int NOT NULL


ALTER TABLE dbo.date_calendar ALTER COLUMN weekdays_in_month int NOT NULL


ALTER TABLE dbo.date_calendar ALTER COLUMN days_in_quarter int NOT NULL


ALTER TABLE dbo.date_calendar ALTER COLUMN quarter_days_remaining int NOT NULL


ALTER TABLE dbo.date_calendar ALTER COLUMN weekdays_in_quarter int NOT NULL


ALTER TABLE dbo.date_calendar ALTER COLUMN year_days_remaining int NOT NULL


-----------------------------------------------------------------------------------------------------------------------------
--Table Update IV: Populate Additional Date Xref Table Fields (Pass IV)
-----------------------------------------------------------------------------------------------------------------------------

UPDATE DC
SET DC.month_weekdays_remaining = DC.weekdays_in_month - sqDC.month_weekdays_remaining_subtraction,
    DC.quarter_weekdays_remaining = DC.weekdays_in_quarter - sqDC.quarter_weekdays_remaining_subtraction
FROM dbo.date_calendar DC
INNER JOIN (SELECT
  DC.calendar_date,
  ROW_NUMBER() OVER
  (
  PARTITION BY
  DC.year_month
  ORDER BY
  DC.calendar_date
  ) AS month_weekdays_remaining_subtraction,
  ROW_NUMBER() OVER
  (
  PARTITION BY
  DC.year_quarter
  ORDER BY
  DC.calendar_date
  ) AS quarter_weekdays_remaining_subtraction
FROM dbo.date_calendar DC
WHERE DC.is_weekday = 1) sqDC
  ON sqDC.calendar_date = DC.calendar_date


-----------------------------------------------------------------------------------------------------------------------------
--Table Update V: Populate Additional Date Xref Table Fields (Pass V)
-----------------------------------------------------------------------------------------------------------------------------

UPDATE DC
SET DC.month_weekdays_remaining = (CASE
      WHEN DC1.calendar_month = DC.calendar_month AND
        DC1.month_weekdays_remaining IS NOT NULL THEN DC1.month_weekdays_remaining
      WHEN DC2.calendar_month = DC.calendar_month AND
        DC2.month_weekdays_remaining IS NOT NULL THEN DC2.month_weekdays_remaining
      ELSE DC.weekdays_in_month
    END),
    DC.quarter_weekdays_remaining = (CASE
      WHEN DC1.calendar_quarter = DC.calendar_quarter AND
        DC1.quarter_weekdays_remaining IS NOT NULL THEN DC1.quarter_weekdays_remaining
      WHEN DC2.calendar_quarter = DC.calendar_quarter AND
        DC2.quarter_weekdays_remaining IS NOT NULL THEN DC2.quarter_weekdays_remaining
      ELSE DC.weekdays_in_quarter
    END)
FROM dbo.date_calendar DC
LEFT JOIN dbo.date_calendar DC1
  ON DATEADD(DAY, 1, DC1.calendar_date) = DC.calendar_date
LEFT JOIN dbo.date_calendar DC2
  ON DATEADD(DAY, 2, DC2.calendar_date) = DC.calendar_date
WHERE DC.month_weekdays_remaining IS NULL


ALTER TABLE dbo.date_calendar ALTER COLUMN month_weekdays_remaining int NOT NULL


ALTER TABLE dbo.date_calendar ALTER COLUMN quarter_weekdays_remaining int NOT NULL


-----------------------------------------------------------------------------------------------------------------------------
--Table Update VI: Populate Additional Date Xref Table Fields (Pass VI)
-----------------------------------------------------------------------------------------------------------------------------

UPDATE DC
SET DC.is_week_in_same_month = sqDC.is_week_in_same_month,
    DC.month_days_remaining = DC.days_in_month - DC.calendar_day,
    DC.month_weekdays_completed = DC.weekdays_in_month - DC.month_weekdays_remaining,
    DC.quarter_days_completed = DC.days_in_quarter - DC.quarter_days_remaining,
    DC.quarter_weekdays_completed = DC.weekdays_in_quarter - DC.quarter_weekdays_remaining,
    DC.month_day_name_instance = sqDC.month_day_name_instance,
    DC.quarter_day_name_instance = sqDC.quarter_day_name_instance,
    DC.year_day_name_instance = sqDC.year_day_name_instance
FROM dbo.date_calendar DC
INNER JOIN (SELECT
  DC.calendar_date,
  (CASE
    WHEN DATEDIFF(MONTH, DC.first_day_in_week, DC.last_day_in_week) = 0 THEN 1
    ELSE 0
  END) AS is_week_in_same_month,
  ROW_NUMBER() OVER
  (
  PARTITION BY
  DC.year_month, DC.day_name
  ORDER BY
  DC.calendar_date
  ) AS month_day_name_instance,
  ROW_NUMBER() OVER
  (
  PARTITION BY
  DC.year_quarter, DC.day_name
  ORDER BY
  DC.calendar_date
  ) AS quarter_day_name_instance,
  ROW_NUMBER() OVER
  (
  PARTITION BY
  DC.calendar_year, DC.day_name
  ORDER BY
  DC.calendar_date
  ) AS year_day_name_instance
FROM dbo.date_calendar DC) sqDC
  ON sqDC.calendar_date = DC.calendar_date


ALTER TABLE dbo.date_calendar ALTER COLUMN is_week_in_same_month int NOT NULL


ALTER TABLE dbo.date_calendar ALTER COLUMN month_days_remaining int NOT NULL


ALTER TABLE dbo.date_calendar ALTER COLUMN month_weekdays_completed int NOT NULL


ALTER TABLE dbo.date_calendar ALTER COLUMN quarter_days_completed int NOT NULL


ALTER TABLE dbo.date_calendar ALTER COLUMN quarter_weekdays_completed int NOT NULL


ALTER TABLE dbo.date_calendar ALTER COLUMN month_day_name_instance int NOT NULL


ALTER TABLE dbo.date_calendar ALTER COLUMN quarter_day_name_instance int NOT NULL


ALTER TABLE dbo.date_calendar ALTER COLUMN year_day_name_instance int NOT NULL


-----------------------------------------------------------------------------------------------------------------------------
--Main Query: Final Display / Output
-----------------------------------------------------------------------------------------------------------------------------

SELECT
  DC.*
FROM dbo.date_calendar DC
ORDER BY DC.calendar_date
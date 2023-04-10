
use international_debt
go

CREATE TABLE international_debt
(
  country_name character varying(50),
  country_code character varying(50),
  indicator_name text,
  indicator_code text,
  debt numeric
);

BULK INSERT international_debt
FROM 'Desktop/Projects/SQL-Analysis/Analyze International Debt Statistics/datasets/international_debt.csv'
WITH (FORMAT = 'CSV', FIELDTERMINATOR = ',', FIRSTROW = 2);


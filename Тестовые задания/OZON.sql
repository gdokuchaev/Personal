-- Задание 1
CREATE SCHEMA sps
GO

CREATE TABLE sps.[order] (
	id int primary key, 
	number varchar(50), 
	clientid int,
	[date] date,
	date_approved date)

CREATE TABLE sps.order_status (
	orderid int, 
	[status] int, 
	itemid int,
	discount float,
	price float,
	quantity int)

CREATE TABLE sps.item_info (
	id int, 
	[name] varchar(50), 
	companyid int)

CREATE TABLE sps.company_info (
	id int, 
	[name] varchar(50))

SELECT
	company_info.name,
	count(distinct clientid) unique_clients,
	sum(cost) sales,
	sum(cost)/count(distinct orderid) avg_order
FROM
	sps.[order] orders JOIN (
		SELECT *, price*quantity-discount cost
		FROM sps.order_status 
		) order_status ON id = orderid JOIN 
	sps.item_info ON itemid = item_info.id JOIN
	sps.company_info ON companyid = company_info.id
WHERE company_info.name = 'Well'
GROUP BY company_info.name
GO

-- Задание 2
CREATE TABLE sps.dates (
	id int,
	date date)
GO

SELECT 
	dates.date, 
	lag(dates.date) OVER (ORDER BY dates.date) AS prev_date,
	lead(dates.date) OVER (ORDER BY dates.date) AS next_date,
	first_value(dates.date) OVER (PARTITION BY year, month ORDER BY year, month) AS first_day_of_month,
	last_value(dates.date) OVER (PARTITION BY year, month ORDER BY year, month) AS last_day_of_month,
	datediff(day, dates.date, datefromparts(year, 12, 31)) AS remaining_days
FROM sps.dates JOIN (
	SELECT
		date,
		year(date) AS year,
		month(date) AS month
	FROM sps.dates
	) temp ON temp.date = dates.date
ORDER BY dates.date
GO

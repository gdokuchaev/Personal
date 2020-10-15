-- Задание 1
CREATE SCHEMA sps

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

SELECT company_info.name, 	
	(
	SELECT Count(sps.[Order].clientid) AS unique_clients
	FROM
		sps.order_status INNER JOIN
		sps.[Order] ON sps.[Order].id = sps.order_status.orderid INNER JOIN
		sps.item_info ON sps.order_status.itemid = sps.item_info.id INNER JOIN
		sps.company_info ON sps.item_info.companyid = sps.company_info.id
	WHERE company_info.[name]='Well'
	) AS unique_clients,
	(
	SELECT Sum(sps.order_status.quantity*sps.order_status.price-sps.order_status.discount) AS sales
	FROM
		sps.order_status INNER JOIN
		sps.[Order] ON sps.[Order].id = sps.order_status.orderid INNER JOIN
		sps.item_info ON sps.order_status.itemid = sps.item_info.id INNER JOIN
		sps.company_info ON sps.item_info.companyid = sps.company_info.id
	WHERE company_info.[name]='Well'
	) AS sales,
	(
	SELECT Count(sps.[Order].clientid) AS unique_clients
	FROM
		sps.order_status INNER JOIN
		sps.[Order] ON sps.[Order].id = sps.order_status.orderid INNER JOIN
		sps.item_info ON sps.order_status.itemid = sps.item_info.id INNER JOIN
		sps.company_info ON sps.item_info.companyid = sps.company_info.id
	WHERE company_info.[name]='Well'
	) AS avg_order
FROM sps.company_info
WHERE company_info.[name]='Well'
GO


-- Задание 2
IF object_id ('sps.dates') IS NOT NULL DROP TABLE sps.dates
GO

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
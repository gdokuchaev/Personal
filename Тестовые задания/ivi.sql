/*
Написать SQL-запрос для расчета top10 фильмов по количеству уникальных
пользователей в разбивке по месяцам. Посчитать динамику в процентах от
месяца к месяцу для фильмов из top10. Для фильмов, которые пришли в top10
первый раз считать, что в предыдущем месяце у них не было показов.
*/

-- Решение написано на синтаксисе PostgreSQL

-- Создадим временные таблицы

DROP TABLE IF EXISTS content;
CREATE TEMP TABLE IF NOT EXISTS content (content_id int, title varchar);

DROP TABLE IF EXISTS сontent_watch;
CREATE TEMP TABLE IF NOT EXISTS сontent_watch (
	watch_id  varchar,
	content_id int,
	show_date timestamp,
	user_id int);

DROP TABLE IF EXISTS calendar;
CREATE TEMP TABLE calendar (date timestamp);

INSERT INTO calendar VALUES ('2020-01-01');
INSERT INTO calendar VALUES ('2020-01-02');
INSERT INTO calendar VALUES ('2020-01-03');
INSERT INTO calendar VALUES ('2020-02-01');
INSERT INTO calendar VALUES ('2020-02-02');
INSERT INTO calendar VALUES ('2020-02-05');
INSERT INTO calendar VALUES ('2019-12-01');

INSERT INTO content VALUES (1, 'Маша и медведь: Первая встреча');
INSERT INTO content VALUES (2, 'Маша и медведь: До весны не будить');

INSERT INTO сontent_watch VALUES (1, 2, '2020-01-05 10:00', 2);
INSERT INTO сontent_watch VALUES (2, 2, '2020-01-08 10:00', 5);
INSERT INTO сontent_watch VALUES (3, 1, '2020-01-08 11:00', 7);
INSERT INTO сontent_watch VALUES (4, 1, '2020-02-08 11:00', 7);
INSERT INTO сontent_watch VALUES (5, 1, '2020-02-10 11:00', 6);
INSERT INTO сontent_watch VALUES (6, 2, '2020-02-10 11:00', 8);
INSERT INTO сontent_watch VALUES (7, 1, '2020-02-10 11:00', 8);
INSERT INTO сontent_watch VALUES (8, 1, '2019-12-02 11:00', 8);

/* 
План решения задачи решения:
1. Составим список календарных месяцев.
2. Создадим декартово произвение месяцев и просмотров, где оставим только
	те просмотры, которые произошли в соответствующий каледарный месяц.
3. Сагрегируем строки, посчитав количество уникальных пользователей.
4. Применив оконные функции, посчитаем позицию в рейтинге и 
	оставим для каждого месяца только десять 
	самых популярных фильмов.
5. Посчитаем разницу с прошлым месяцем.
*/

WITH months AS (
SELECT date AS month
FROM calendar
WHERE EXTRACT(day FROM date) = 1
ORDER BY 1
),
rating AS (
SELECT 
	month::date,
	content_id,
	count(distinct user_id) unique_users
FROM
	months m,
	сontent_watch c 
WHERE
	EXTRACT(year FROM month) = EXTRACT(year FROM show_date) AND
	EXTRACT(month FROM month) = EXTRACT(month FROM show_date)
GROUP BY
	month, content_id
),
r AS (
SELECT
	month,
	row_number() OVER (PARTITION BY month ORDER BY unique_users) AS position,
	content_id,
	unique_users
FROM rating)
SELECT 
	month,
	position,
	title,
	unique_users,
	COALESCE(unique_users / 
		lag(unique_users) OVER
			(PARTITION BY content_id ORDER BY month) - 1, 1) change
FROM
	r LEFT JOIN
	content USING (content_id)
WHERE position <= 10

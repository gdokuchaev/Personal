go
if object_id ('T') is not null drop table T
go
create table T (id int primary key, Number varchar(50), Price money)
go
insert into T (id, Number, Price) values (1, 'A', 100.00)
insert into T (id, Number, Price) values (2, 'A', 90.00)
insert into T (id, Number, Price) values (3, 'B', 200.00)
insert into T (id, Number, Price) values (4, 'C', 100.00)
insert into T (id, Number, Price) values (5, 'C', 300.00)
insert into T (id, Number, Price) values (6, 'D', 300.00)
insert into T (id, Number, Price) values (7, 'D', 300.00)

DELETE FROM T
WHERE T.id in (SELECT tab.id FROM (
    SELECT Min(id) AS id, T.Number, Max(T.Price) AS Price
    FROM T
    GROUP BY Number
    HAVING (Count(T.Price)>1)
    ) AS tab)

DELETE FROM T WHERE id NOT IN 
	(
	SELECT max(id) AS id
	FROM 
		(
		SELECT id, Number, Price,
			(
			SELECT sum(T3.Price) AS Price FROM 
				(
				SELECT T1.Number, Max(T1.Price) AS Price
				FROM T AS T1
				GROUP BY Number
				HAVING T.Number = T1.Number
				) AS T3
			) AS mPrice
		FROM T
		) AS T4
	WHERE Price = mPrice
	GROUP BY Number
	)

DELETE FROM T WHERE id NOT IN (
	SELECT id
	FROM T
	WHERE id%2 <>0
	)

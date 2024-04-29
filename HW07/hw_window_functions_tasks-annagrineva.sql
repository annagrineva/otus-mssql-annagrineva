/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters
/*
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/
set statistics time, io on
--Время ЦП = 62641 мс, затраченное время = 64699 мс.

SELECT
	inv.[InvoiceID],
	cst.[CustomerName],
	inv.[InvoiceDate],
	(SELECT 
		SUM([Quantity]*[UnitPrice]) as Summa
	FROM [Sales].[InvoiceLines] inl2
	WHERE inv.[InvoiceID] = inl2.[InvoiceID]
	GROUP BY inl2.[InvoiceID]
	) as [Сумма продажи],
	(SELECT
		SUM([Quantity]*[UnitPrice]) as Summa
	FROM [Sales].[Invoices] inv2
	JOIN [Sales].[InvoiceLines] inl2 on inl2.[InvoiceID] = inv2.[InvoiceID]
	WHERE inv2.[InvoiceDate] >= '2015-01-01'		
		and ((YEAR(inv2.[InvoiceDate]) <= YEAR(inv.[InvoiceDate]) and MONTH(inv2.[InvoiceDate]) <= MONTH(inv.[InvoiceDate]))
		or (YEAR(inv2.[InvoiceDate]) < YEAR(inv.[InvoiceDate]) and MONTH(inv2.[InvoiceDate]) > MONTH(inv.[InvoiceDate])))
	) as [Сумма накопительно]
FROM [Sales].[Invoices] inv
JOIN [Sales].[InvoiceLines] inl on inl.[InvoiceID] = inv.[InvoiceID]
JOIN [Sales].[Customers] cst on cst.[CustomerID] = inv.[CustomerID]
WHERE inv.[InvoiceDate] >= '2015-01-01'
ORDER BY inv.[InvoiceDate], inv.[InvoiceID]

/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/
set statistics time, io on
--Время ЦП = 266 мс, затраченное время = 885 мс.

SELECT
	inv.[InvoiceID],
	cst.[CustomerName],
	inv.[InvoiceDate],
	sum([Quantity]*[UnitPrice]) over (partition by inv.[InvoiceID]) as [Сумма продажи],
	sum([Quantity]*[UnitPrice]) over (order by year([InvoiceDate]),month([InvoiceDate]) range between unbounded preceding and current row) as [Сумма накопительно]
FROM [Sales].[Invoices] inv
JOIN [Sales].[InvoiceLines] inl on inl.[InvoiceID] = inv.[InvoiceID]
JOIN [Sales].[Customers] cst on cst.[CustomerID] = inv.[CustomerID]
WHERE inv.[InvoiceDate] >= '2015-01-01'
ORDER BY inv.[InvoiceDate], inv.[InvoiceID]

/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/

WITH RankCTE AS (
SELECT
	MONTH([InvoiceDate]) as InvoiceMonth,
	[StockItemID],
	SUM([Quantity]) as ItemQty,
	ROW_NUMBER() over (partition by MONTH([InvoiceDate]) order by SUM([Quantity]) DESC) as ItemRank
FROM [Sales].[Invoices] inv
JOIN [Sales].[InvoiceLines] inl on inl.[InvoiceID] = inv.[InvoiceID]
WHERE inv.[InvoiceDate] between '2016-01-01' and '2016-12-31'
GROUP BY MONTH([InvoiceDate]),[StockItemID]
)

SELECT
	r.InvoiceMonth,
	r.StockItemID,
	i.StockItemName
FROM RankCTE r
JOIN [Warehouse].[StockItems] i on i.[StockItemID] = r.StockItemID
WHERE ItemRank in (1,2)
ORDER BY InvoiceMonth, ItemRank

/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/

SELECT
	[StockItemID],
	[StockItemName],
	[Brand],
	[UnitPrice],
	ROW_NUMBER() over (order by left([StockItemName], 1)) as [Номера строк],
	COUNT(StockItemName) over (order by [StockItemID] rows between unbounded preceding and unbounded following) as [Кол-во товаров],
	COUNT([StockItemID]) over (partition by left([StockItemName],1)) as [Кол-во по первой букве],
	LEAD([StockItemID]) over (order by [StockItemName]) as [Следующий ИД],
	LAG([StockItemID]) over (order by [StockItemName]) as [Предыдущий ИД],
	COALESCE(LAG(StockItemName, 2) over (order by [StockItemName]), 'No items') as [2 строки назад],
	NTILE(30) over (order by [TypicalWeightPerUnit]) as [Группа]
FROM [Warehouse].[StockItems]
ORDER BY [StockItemID]

/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/

WITH RowCTE AS (
SELECT
	[SalespersonPersonID],
	inv.[InvoiceID],
	[CustomerID],
	[InvoiceDate],
	SUM([Quantity]*[UnitPrice]) as Summa,
	ROW_NUMBER() over (partition by [SalespersonPersonID] order by [InvoiceDate] DESC, inv.[InvoiceID] DESC) as RowNum
FROM [Sales].[Invoices] inv
JOIN [Sales].[InvoiceLines] inl on inl.[InvoiceID] = inv.[InvoiceID]
GROUP BY [SalespersonPersonID],inv.[InvoiceID],[CustomerID],[InvoiceDate]
)

SELECT
	r.[SalespersonPersonID],
	SUBSTRING([FullName], CHARINDEX(' ', [FullName])+1, LEN([FullName]) - CHARINDEX(' ', [FullName])+1) as Surname,
	r.[CustomerID],
	cst.[CustomerName],
	r.[InvoiceDate],
	r.[Summa]
FROM RowCTE r
JOIN [Application].[People] ppl on ppl.[PersonID] = r.[SalespersonPersonID]
JOIN [Sales].[Customers] cst on cst.[CustomerID] = r.[CustomerID]
WHERE r.RowNum = 1
ORDER BY r.[SalespersonPersonID];

/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

WITH rankcte AS (
SELECT
	[CustomerID],
	[StockItemID],
	AVG([UnitPrice]) as UnitPrice,
	MAX([InvoiceDate]) as InvoiceDate,
	DENSE_RANK() over (partition by [CustomerID] order by AVG([UnitPrice]) DESC) as PriceRank
FROM [Sales].[Invoices] inv
JOIN [Sales].[InvoiceLines] inl on inv.[InvoiceID] = inl.[InvoiceID]
GROUP BY [CustomerID],[StockItemID]
)

SELECT
	r.[CustomerID],
	cst.[CustomerName],
	r.[StockItemID],
	r.[UnitPrice],
	r.[InvoiceDate]
FROM rankcte r
JOIN [Sales].[Customers] cst on cst.[CustomerID] = r.[CustomerID]
WHERE r.PriceRank in (1,2)
ORDER BY r.[CustomerID], r.[UnitPrice] DESC;

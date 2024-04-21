/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

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
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам.
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT
	 YEAR([InvoiceDate]) as [Год продажи]
	,MONTH([InvoiceDate]) as [Месяц продажи]
	,AVG([UnitPrice]) as [Средняя цена]
	,SUM([Quantity]*[UnitPrice]) as [Общая сумма продаж]
FROM [Sales].[Invoices] inv
JOIN [Sales].[InvoiceLines] inln on inln.[InvoiceID] = inv.[InvoiceID]
GROUP BY YEAR([InvoiceDate]), MONTH([InvoiceDate])
ORDER BY YEAR([InvoiceDate]), MONTH([InvoiceDate])


/*
2. Отобразить все месяцы, где общая сумма продаж превысила 4 600 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT
	 YEAR([InvoiceDate]) as [Год продажи]
	,MONTH([InvoiceDate]) as [Месяц продажи]
	,SUM([Quantity]*[UnitPrice]) as [Общая сумма продаж]
FROM [Sales].[Invoices] inv
JOIN [Sales].[InvoiceLines] inln on inln.[InvoiceID] = inv.[InvoiceID]
GROUP BY YEAR([InvoiceDate]), MONTH([InvoiceDate])
HAVING SUM([Quantity]*[UnitPrice]) > 4600000
ORDER BY YEAR([InvoiceDate]), MONTH([InvoiceDate])

/*
3. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT
	 YEAR(inv_1.[InvoiceDate]) as [Год продажи]
	,MONTH(inv_1.[InvoiceDate]) as [Месяц продажи]
	,sti.[StockItemName] as [Наименование товара]
	,SUM([Quantity]*inln.[UnitPrice]) as [Сумма продаж]
	,MIN([InvoiceDate]) as [Дата первой продажи]
	,SUM([Quantity]) as [Количество проданного]
FROM [Sales].[Invoices] inv_1
JOIN [Sales].[InvoiceLines] inln on inln.[InvoiceID] = inv_1.[InvoiceID]
JOIN [Warehouse].[StockItems] sti on sti.[StockItemID] = inln.[StockItemID]
WHERE inln.[StockItemID] = (
							SELECT
								inln.[StockItemID]
							FROM [Sales].[Invoices] inv_2
							JOIN [Sales].[InvoiceLines] inln on inln.[InvoiceID] = inv_2.[InvoiceID]
							JOIN [Warehouse].[StockItems] sti on sti.[StockItemID] = inln.[StockItemID]
							WHERE 1=1
								and YEAR(inv_2.[InvoiceDate]) = YEAR(inv_1.[InvoiceDate])
								and MONTH(inv_2.[InvoiceDate]) = MONTH(inv_1.[InvoiceDate])
							GROUP BY inln.[StockItemID], YEAR(inv_2.[InvoiceDate]), MONTH(inv_2.[InvoiceDate])
							HAVING SUM(inln.[Quantity]) < 50
							)
GROUP BY YEAR([InvoiceDate]),MONTH([InvoiceDate]),sti.[StockItemName]

-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
Написать запросы 2-3 так, чтобы если в каком-то месяце не было продаж,
то этот месяц также отображался бы в результатах, но там были нули.
*/
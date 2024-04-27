/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "05 - Операторы CROSS APPLY, PIVOT, UNPIVOT".

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
1. Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys.
Имя клиента нужно поменять так чтобы осталось только уточнение.
Например, исходное значение "Tailspin Toys (Gasport, NY)" - вы выводите только "Gasport, NY".
Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT | Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2        |     2
01.02.2013   |      7             |        3           |      4      |      2        |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/

SELECT
	CONVERT(varchar, BeginMonth, 104) as InvoiceMonth, [Peeples Valley, AZ], [Medicine Lodge, KS], [Gasport, NY], [Sylvanite, MT], [Jessie, ND]
FROM (
		SELECT
			DATETRUNC(month, [InvoiceDate]) as BeginMonth, 
			SUBSTRING([CustomerName], 16, len([CustomerName])-16) as CustomerName,
			OrderID
		FROM [Sales].[Invoices] inv
		JOIN [Sales].[Customers] cst on cst.[CustomerID] = inv.[CustomerID]
		WHERE inv.[CustomerID] between 2 and 6
	  ) AS SourceTable
PIVOT (COUNT(OrderID) FOR CustomerName IN ([Gasport, NY], [Jessie, ND], [Medicine Lodge, KS], [Peeples Valley, AZ], [Sylvanite, MT])) as PivotTable
ORDER BY BeginMonth;

/*
2. Для всех клиентов с именем, в котором есть "Tailspin Toys"
вывести все адреса, которые есть в таблице, в одной колонке.

Пример результата:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/

SELECT rq.CustomerName, rq.AddressLine
FROM (
		SELECT CustomerName, Column_name, AddressLine
		FROM [Sales].[Customers]
		UNPIVOT(AddressLine FOR Column_name IN ([DeliveryAddressLine1],[DeliveryAddressLine2],[PostalAddressLine1],[PostalAddressLine2]))AS UnpivotTable
		WHERE [CustomerName] like '%Tailspin Toys%'
	  ) rq;

/*
3. В таблице стран (Application.Countries) есть поля с цифровым кодом страны и с буквенным.
Сделайте выборку ИД страны, названия и ее кода так, 
чтобы в поле с кодом был либо цифровой либо буквенный код.

Пример результата:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/

WITH Countries as (
SELECT 
	CountryID,CountryName,IsoAlpha3Code,CAST(IsoNumericCode as nvarchar(3)) as IsoNumericCode
FROM [Application].[Countries]
)
SELECT rq.CountryID, rq.CountryName, rq.Code
FROM (
		SELECT 
			CountryID,CountryName, Column_name, Code
		FROM Countries
		UNPIVOT(Code FOR Column_name IN ([IsoAlpha3Code],[IsoNumericCode]))AS UnpivotTable
	 ) rq;

/*
4. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

SELECT
	cst.[CustomerID],
	cst.[CustomerName],
	ap.[StockItemID],
	ap.[UnitPrice],
	ap.[InvoiceDate]
FROM [Sales].[Customers] cst
CROSS APPLY (
			SELECT TOP (2) [StockItemID], [UnitPrice], [InvoiceDate]
			FROM [Sales].[Invoices] inv
			JOIN [Sales].[InvoiceLines] inl on inl.[InvoiceID] = inv.[InvoiceID]
			WHERE inv.[CustomerID] = cst.[CustomerID]
			ORDER BY [UnitPrice] DESC
			) ap;

/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, JOIN".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД WideWorldImporters можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

SELECT 
	 [StockItemID] as [ИД товара]
	,[StockItemName] as [Наименование товара]
FROM [Warehouse].[StockItems]
WHERE [StockItemName] like '%urgent%' or [StockItemName] like 'Animal%'


/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

SELECT
	 ps.[SupplierID] as [ИД поставщика]
	,ps.[SupplierName] as [Наименование поставщика]
FROM [Purchasing].[Suppliers] ps
LEFT JOIN [Purchasing].[PurchaseOrders] po on po.[SupplierID] = ps.[SupplierID]
WHERE po.PurchaseOrderID is null


/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

SELECT distinct
	 ord.[OrderID] as [ID заказа]
	,convert(varchar, ord.[OrderDate], 104) as [Дата заказа] 
	,datename(month,ord.[OrderDate]) as [Месяц заказа]
	,datepart(quarter,ord.[OrderDate]) as [Номер квартала]
	,ceiling(cast(month(ord.[OrderDate]) as float)/4) as [Треть года]
	,cst.[CustomerName] as [Имя заказчика]
FROM [Sales].[Orders] ord
JOIN [Sales].[OrderLines] orln on orln.[OrderID] = ord.[OrderID]
JOIN [Sales].[Customers] cst on cst.[CustomerID] = ord.[CustomerID]
WHERE orln.[PickingCompletedWhen] is not null
	and (orln.[UnitPrice] > 100 or orln.[Quantity] > 20)
ORDER BY [Номер квартала], [Треть года], [Дата заказа] 


--Второй вариант

SELECT distinct
	 ord.[OrderID] as [ID заказа]
	,convert(varchar, ord.[OrderDate], 104) as [Дата заказа] 
	,datename(month,ord.[OrderDate]) as [Месяц заказа]
	,datepart(quarter,ord.[OrderDate]) as [Номер квартала]
	,ceiling(cast(month(ord.[OrderDate]) as float)/4) as [Треть года]
	,cst.[CustomerName] as [Имя заказчика]
FROM [Sales].[Orders] ord
JOIN [Sales].[OrderLines] orln on orln.[OrderID] = ord.[OrderID]
JOIN [Sales].[Customers] cst on cst.[CustomerID] = ord.[CustomerID]
WHERE orln.[PickingCompletedWhen] is not null
	and (orln.[UnitPrice] > 100 or orln.[Quantity] > 20)
ORDER BY [Номер квартала], [Треть года], [Дата заказа] OFFSET 1000 ROWS
FETCH NEXT 100 ROWS ONLY


/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

SELECT 
	 dm.[DeliveryMethodName] as [Способ доставки]
	,po.[ExpectedDeliveryDate] as [Дата доставки]
	,ps.[SupplierName] as [Имя поставщика]
	,ppl.[FullName] as [Имя контактного лица принимавшего заказ]
FROM [Purchasing].[PurchaseOrders] po
JOIN [Purchasing].[Suppliers] ps on ps.[SupplierID] = po.[SupplierID]
JOIN [Application].[People] ppl on ppl.[PersonID] = po.[ContactPersonID]
JOIN [Application].[DeliveryMethods] dm on dm.[DeliveryMethodID] = po.[DeliveryMethodID]
WHERE po.[ExpectedDeliveryDate] between '2013-01-01' and '2013-01-31'
	and po.[IsOrderFinalized] = 1
	and dm.[DeliveryMethodName] in ('Air Freight','Refrigerated Air Freight')

/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

SELECT top 10
	 ord.[OrderID]
	,cst.[CustomerName]
	,ppl.[FullName]
FROM [Sales].[Orders] ord
JOIN [Sales].[Customers] cst on ord.[CustomerID] = cst.[CustomerID]
JOIN [Application].[People] ppl on ppl.[PersonID] = ord.[SalespersonPersonID]
ORDER BY [OrderDate] desc

/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

SELECT DISTINCT
	 ord.[CustomerID]
	,cst.[CustomerName]
	,cst.[PhoneNumber]
FROM [Sales].[Orders] ord
join [Sales].[OrderLines] ol on ol.[OrderID] = ord.[OrderID]
join [Warehouse].[StockItems] sti on sti.[StockItemID] = ol.[StockItemID] and sti.[StockItemName] = 'Chocolate frogs 250g'
join [Sales].[Customers] cst on cst.[CustomerID] = ord.[CustomerID]

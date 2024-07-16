/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "12 - Хранимые процедуры, функции, триггеры, курсоры".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

USE WideWorldImporters

/*
Во всех заданиях написать хранимую процедуру / функцию и продемонстрировать ее использование.
*/

/*
1) Написать функцию возвращающую Клиента с наибольшей суммой покупки.
*/

CREATE FUNCTION FnCustomerIdMaxInvoice
()
RETURNS INTEGER
AS
BEGIN
   DECLARE @CustomerNo INT;
 
	SELECT @CustomerNo = [CustomerID]
	FROM [Sales].[InvoiceLines] il
		JOIN [Sales].[Invoices] inv on inv.[InvoiceID] = il.[InvoiceID]
	GROUP BY [CustomerID], inv.[InvoiceID]
	HAVING sum(Quantity*UnitPrice) = (
						SELECT max(rq.Cost)
						FROM (
							SELECT sum(Quantity*UnitPrice) as Cost
							FROM [Sales].[InvoiceLines] il
								JOIN [Sales].[Invoices] inv on inv.[InvoiceID] = il.[InvoiceID]
							GROUP BY [CustomerID],inv.[InvoiceID]
							) rq
						);
 
   RETURN @CustomerNo
 
END;


SELECT dbo.FnCustomerIdMaxInvoice();

/*
2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
Использовать таблицы :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines
*/

CREATE PROCEDURE CustInvoiceSumma 
(
    @CustomerId INT
)
AS
BEGIN
   
	SELECT sum(Quantity*UnitPrice) as Summa
	FROM [Sales].[InvoiceLines] il
		JOIN [Sales].[Invoices] inv on inv.[InvoiceID] = il.[InvoiceID]
	WHERE [CustomerID] = @CustomerId
	GROUP BY [CustomerID]

END
 
EXEC CustInvoiceSumma 834;

/*
3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
*/

--Создадим функцию аналогичную предыдущей процедуре, возвращаюшую общую сумму покупок по клиенту

CREATE FUNCTION FnCustInvoiceSumma 
( @CustomerId INT )
RETURNS DECIMAL(18,2)
AS
BEGIN
   DECLARE @Summa DECIMAL(18,2);
 
	SELECT  @Summa = sum(Quantity*UnitPrice)
	FROM [Sales].[InvoiceLines] il
		JOIN [Sales].[Invoices] inv on inv.[InvoiceID] = il.[InvoiceID]
	WHERE [CustomerID] = @CustomerId
	GROUP BY [CustomerID]
 
   RETURN @Summa
 
END;

--По SET STATISTICS IO, TIME ON особой разницы между процедурой и функцией нет, actual план запроса показывает что функция дешевле процедуры

SET STATISTICS IO, TIME ON

EXEC CustInvoiceSumma  29;

select dbo.FnCustInvoiceSumma(29);

SET STATISTICS IO, TIME OFF

/*
4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла. 
*/

--Создадим функцию которая показывает имена всех менеджеров, которые продавали что-либо клиенту

CREATE FUNCTION FnManagerList
(
   @CustomerId INT
)
RETURNS TABLE
AS
RETURN(

	SELECT [CustomerID],[FullName]
	FROM [Sales].[Invoices] inv
		JOIN [Application].[People] ppl on ppl.[PersonID] = inv.[SalespersonPersonID]
	WHERE [CustomerID] = @CustomerId
	GROUP BY [CustomerID], [FullName]

)

--Для каждого клиента применим функцию и получим кол-во записей, которое = кол-ву менеджеров

SELECT [CustomerID], [CustomerName], ca.[FullName]
FROM [Sales].[Customers] cst
CROSS APPLY (
				SELECT [FullName]
				FROM dbo.FnManagerList([CustomerID])
			) ca

/*
5) Опционально. Во всех процедурах укажите какой уровень изоляции транзакций вы бы использовали и почему. 
*/

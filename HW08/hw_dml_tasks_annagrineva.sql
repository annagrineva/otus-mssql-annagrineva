/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "10 - Операторы изменения данных".

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
1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers 
*/

INSERT INTO [Sales].[Customers]
([CustomerName],[BillToCustomerID],[CustomerCategoryID],[PrimaryContactPersonID]
,[DeliveryMethodID],[DeliveryCityID],[PostalCityID],[AccountOpenedDate]
,[StandardDiscountPercentage],[IsStatementSent],[IsOnCreditHold],[PaymentDays]
,[PhoneNumber],[FaxNumber],[WebsiteURL],[DeliveryAddressLine1],[DeliveryPostalCode]
,[PostalAddressLine1],[PostalPostalCode],[LastEditedBy])
VALUES
('James Cameron', 1062,	7, 3260, 3,	22090,	22090, '2000-01-01',	25.000,	0,	0,	7,	'(200) 555-5555',	'(200) 555-5555',	'http://www.microsoft.com/',	'California',	90669,	'PO Box 800', 90669,	1),
('David Fincher' , 1063,	7, 3260, 3,	22090,	22090, '2000-01-01',	15.000,	0,	0,	7,	'(200) 666-6666',	'(200) 666-6666',	'http://www.microsoft.com/',	'California',	90669,	'PO Box 801', 90669,	1),
('Christopher Nolan' , 1064,	7, 3260, 3,	22090,	22090, '2000-01-01',	10.000,	0,	0,	7,	'(200) 333-2222',	'(200) 333-2222',	'http://www.microsoft.com/',	'California',	90669,	'PO Box 802', 90669,	1),
('Ridley Scott' , 1065,	7, 3260, 3,	22090,	22090, '2000-01-01',	5.000,	0,	0,	7,	'(185) 202-5855',	'(185) 202-5855',	'http://www.microsoft.com/',	'California',	90669,	'PO Box 803', 90669,	1),
('Steven Spielberg' , 1066,	7, 3260, 3,	22090,	22090, '2000-01-01',	5.000,	0,	0,	7,	'(387) 777-3443',	'(387) 777-3443',	'http://www.microsoft.com/',	'California',	90669,	'PO Box 804', 90669,	1)

/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/

DELETE FROM [Sales].[Customers]
WHERE [CustomerID] = 1065


/*
3. Изменить одну запись, из добавленных через UPDATE
*/

UPDATE [Sales].[Customers]
SET [CustomerName] = REVERSE([CustomerName])
WHERE [CustomerID] = 1066

/*
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/

SELECT *
INTO [Sales].[Customers_Copy]
FROM [Sales].[Customers]
WHERE 1=2

INSERT INTO [Sales].[Customers_Copy]
([CustomerID],[CustomerName],[BillToCustomerID],[CustomerCategoryID],[PrimaryContactPersonID]
,[DeliveryMethodID],[DeliveryCityID],[PostalCityID],[AccountOpenedDate]
,[StandardDiscountPercentage],[IsStatementSent],[IsOnCreditHold],[PaymentDays]
,[PhoneNumber],[FaxNumber],[WebsiteURL],[DeliveryAddressLine1],[DeliveryPostalCode]
,[PostalAddressLine1],[PostalPostalCode],[LastEditedBy],[ValidFrom],[ValidTo])
VALUES
(1062,'Arnold Schwarzenegger', 1062,	7, 3260, 3,	22090,	22090, '2000-01-01',	25.000,	0,	0,	7,	'(200) 555-5555',	'(200) 555-5555',	'http://www.microsoft.com/',	'California',	90669,	'PO Box 800', 90669,	1, '2024-05-04 14:16:02.7195869',	'9999-12-31 23:59:59.9999999'),
(1063,'Jodie Foster' , 1063,	7, 3260, 3,	22090,	22090, '2000-01-01',	15.000,	0,	0,	7,	'(200) 666-6666',	'(200) 666-6666',	'http://www.microsoft.com/',	'California',	90669,	'PO Box 801', 90669,	1, '2024-05-04 14:16:02.7195869',	'9999-12-31 23:59:59.9999999'),
(1064,'Matthew McConaughey' , 1064,	7, 3260, 3,	22090,	22090, '2000-01-01',	10.000,	0,	0,	7,	'(200) 333-2222',	'(200) 333-2222',	'http://www.microsoft.com/',	'California',	90669,	'PO Box 802', 90669,	1, '2024-05-04 14:16:02.7195869',	'9999-12-31 23:59:59.9999999'),
(1065,'Sigourney Weaver' , 1065,	7, 3260, 3,	22090,	22090, '2000-01-01',	5.000,	0,	0,	7,	'(185) 202-5855',	'(185) 202-5855',	'http://www.microsoft.com/',	'California',	90669,	'PO Box 803', 90669,	1, '2024-05-04 14:16:02.7195869',	'9999-12-31 23:59:59.9999999'),
(1066,'Sam Neill' , 1066,	7, 3260, 3,	22090,	22090, '2000-01-01',	5.000,	0,	0,	7,	'(387) 777-3443',	'(387) 777-3443',	'http://www.microsoft.com/',	'California',	90669,	'PO Box 804', 90669,	1, '2024-05-04 14:16:02.7195869',	'9999-12-31 23:59:59.9999999')


MERGE [Sales].[Customers] as target
USING [Sales].[Customers_Copy] as source
	on target.[CustomerID] = source.[CustomerID]
WHEN MATCHED THEN 
			UPDATE SET target.[CustomerName] = source.[CustomerName]
WHEN NOT MATCHED THEN			 
			INSERT	([CustomerID],[CustomerName],[BillToCustomerID],[CustomerCategoryID],[PrimaryContactPersonID]
					,[DeliveryMethodID],[DeliveryCityID],[PostalCityID],[AccountOpenedDate]
					,[StandardDiscountPercentage],[IsStatementSent],[IsOnCreditHold],[PaymentDays]
					,[PhoneNumber],[FaxNumber],[WebsiteURL],[DeliveryAddressLine1],[DeliveryPostalCode]
					,[PostalAddressLine1],[PostalPostalCode],[LastEditedBy])
			VALUES (source.[CustomerID],source.[CustomerName],source.[BillToCustomerID],source.[CustomerCategoryID],
					source.[PrimaryContactPersonID],source.[DeliveryMethodID],source.[DeliveryCityID],source.[PostalCityID],
					source.[AccountOpenedDate],source.[StandardDiscountPercentage],source.[IsStatementSent],
					source.[IsOnCreditHold],source.[PaymentDays],source.[PhoneNumber],source.[FaxNumber],source.[WebsiteURL],
					source.[DeliveryAddressLine1],source.[DeliveryPostalCode],source.[PostalAddressLine1],
					source.[PostalPostalCode],source.[LastEditedBy])
;

DROP TABLE [Sales].[Customers_Copy];

/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bcp in
*/

DECLARE @out varchar(250);
set @out = 'bcp WideWorldImporters.Sales.Customers OUT "E:\BCP\Customers_Backup.txt" -T -S ' + @@SERVERNAME + ' -c';
PRINT @out;

EXEC master..xp_cmdshell @out

DROP TABLE IF EXISTS WideWorldImporters.Sales.Customers_Copy;
SELECT * INTO WideWorldImporters.Sales.Customers_Copy FROM WideWorldImporters.Sales.Customers
WHERE 1 = 2; 


DECLARE @in varchar(250);
set @in = 'bcp WideWorldImporters.Sales.Customers_Copy IN "E:\BCP\Customers_Backup.txt" -T -S ' + @@SERVERNAME + ' -c';

EXEC master..xp_cmdshell @in;

SELECT *
FROM [WideWorldImporters].[Sales].[Customers_Copy];
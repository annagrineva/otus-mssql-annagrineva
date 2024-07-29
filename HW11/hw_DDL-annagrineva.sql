CREATE DATABASE MyDWH;

CREATE TABLE Item (
Id int NOT NULL CONSTRAINT PK_Item PRIMARY KEY,
Name varchar(100) NOT NULL);


CREATE TABLE MovementType (
Id smallint NOT NULL CONSTRAINT PK_MovementType PRIMARY KEY,
Name varchar(100) NOT NULL);


CREATE TABLE Warehouse (
Id int NOT NULL CONSTRAINT PK_Warehouse PRIMARY KEY,
Name varchar(100) NOT NULL,
Virtual tinyint NOT NULL);
	 

CREATE TABLE ItemMovement (
OperationId int IDENTITY(1,1) NOT NULL CONSTRAINT PK_ItemMovement PRIMARY KEY,
ItemId int NOT NULL,
MovementTypeId smallint NOT NULL,
Date date NOT NULL,
PlaceFromID int,
PlaceToID int
CONSTRAINT FK_ItemId FOREIGN KEY (ItemId) REFERENCES Item (Id)
     ON DELETE NO ACTION
     ON UPDATE NO ACTION,
CONSTRAINT FK_MovementType FOREIGN KEY (MovementTypeId) REFERENCES MovementType (Id)
     ON DELETE NO ACTION
     ON UPDATE NO ACTION );


CREATE VIEW vItemMovement AS 

SELECT
	OperationId,
	ItemId,
	i.Name as ItemName,
	MovementTypeId,
	m.Name as MovementName,
	Date,
	PlaceFromID,
	w1.Name as PlaceFrom,
	PlaceToID,
	w2.Name as PlaceTo
FROM ItemMovement im
LEFT JOIN Item i on i.Id = im.ItemId
LEFT JOIN MovementType m on m.Id = im.MovementTypeId
LEFT JOIN Warehouse w1 on w1.Id = im.PlaceFromID
LEFT JOIN Warehouse w2 on w2.Id = im.PlaceToID
;
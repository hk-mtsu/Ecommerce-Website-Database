CREATE DATABASE Ecommerce;
GO

USE Ecommerce
GO

Create Schema Company;
Go


CREATE TABLE Company.Customer (
    UserID VARCHAR(50) Not Null,
	Email varchar(50),
	Passwrd varchar(MAX) Null,
	FirstName varchar(50),
    LastName varchar(50),
    Address varchar(255),
    Phone varchar(25) 
	PRIMARY KEY (UserID)
);

CREATE TABLE Company.CreditCard(
	CreditCardID INT PRIMARY KEY NOT NULL,
	CardNumber varchar(Max) NOT NULL,
	HolderName nvarchar (50),
	ExpDate VARCHAR(20)  NOT NULL,
	CreditCard_Ends_With VARCHAR(5),
	CVC_Code VARCHAR(3) MASKED WITH (FUNCTION = 'partial(0,"XXXXXXX",0)') NOT NULL,
	BillingAddr varchar(255),
	OwnerID VARCHAR(50) Not NULL  
	CONSTRAINT FK_OwnerID FOREIGN KEY (OwnerID)
    REFERENCES Company.Customer(UserID)
	);

CREATE TABLE Company.Product(
	ProductID INT PRIMARY KEY,
	Name VARCHAR(50), 
	Quantity INT, 
	Description VARCHAR(50), 
	Cost_Price VARBINARY(MAX), 
	Sales_Price DECIMAL(15,2), 
	Discount DECIMAL(15,2))

CREATE TABLE Company.Orders(
	OrderID INT NOT NULL PRIMARY KEY,
	UserID VARCHAR(50) NOT NULL,
	Order_Date varchar(50),
	Total_Amount DECIMAL(20,2) DEFAULT(0.0),
	CreditCardID INT NOT NULL,
	Shipping_address varchar(255),
	Del_Status varchar(50),
	CONSTRAINT FK_UserID FOREIGN KEY (UserID)
	REFERENCES Company.Customer(UserID),
	CONSTRAINT FK_CreditCardID FOREIGN KEY (CreditCardID)
    REFERENCES Company.CreditCard(CreditCardID),
	CONSTRAINT chk_Del_Status CHECK (Del_Status IN ('placed', 'in preparation', 'ready to ship', 'shipped'))

	);

CREATE TABLE Company.OrderItem(
	OrderID INT, 
	ProductID INT, 
	PaidPrice DECIMAL(15,2), 
	Quantity INT
	CONSTRAINT FK_ProductID FOREIGN KEY (ProductID)
	REFERENCES Company.Product(ProductID),
	CONSTRAINT FK_OrderID FOREIGN KEY (OrderID)
	REFERENCES Company.Orders(OrderID),
	CONSTRAINT PK_Composite PRIMARY KEY (OrderID, ProductID));
GO

CREATE TABLE Company.ProductAudit
(
	AuditID  INT  IDENTITY PRIMARY KEY, 
    ProductID INT NOT null,
	oldName VARCHAR(50), 
	oldQuantity INT, 
	oldDescription VARCHAR(50), 
	oldCost_Price VARBINARY(MAX), 
	oldSales_Price DECIMAL(15,2), 
	oldDiscount DECIMAL(15,2),
	newName VARCHAR(50), 
	newQuantity INT, 
	newDescription VARCHAR(50), 
	newCost_Price VARBINARY(MAX), 
	newSales_Price DECIMAL(15,2), 
	newDiscount DECIMAL(15,2),
	UserID VARCHAR(50),
	LastUpdated DATETIME
);
GO

CREATE VIEW Company.vwProduct As SELECT ProductID, Name, Quantity, Description, Sales_Price, Discount FROM Company.Product;
GO

CREATE VIEW Company.vwCreditCard As SELECT * FROM Company.CreditCard WHERE OwnerID = USER_NAME();
GO

CREATE VIEW Company.vwCustomer As SELECT * FROM Company.Customer WHERE UserID = USER_NAME();
Go


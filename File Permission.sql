USE Ecommerce;
Go

CREATE ROLE Customers;
CREATE ROLE CustomerService;
CREATE ROLE Sales;
CREATE ROLE SalesManager;
CREATE ROLE OrderProcessor;

CREATE LOGIN C01 WITH PASSWORD = 'C01';
CREATE USER C01 FOR LOGIN C01;

CREATE LOGIN C02 WITH PASSWORD = 'C02';
CREATE USER C02 FOR LOGIN C02;

CREATE LOGIN CS01 WITH PASSWORD = 'CS01';
CREATE USER CS01 FOR LOGIN CS01;

CREATE LOGIN CS02 WITH PASSWORD = 'CS02';
CREATE USER CS02 FOR LOGIN CS02;

CREATE LOGIN S01 WITH PASSWORD = 'S01';
CREATE USER S01 FOR LOGIN S01;

CREATE LOGIN S02 WITH PASSWORD = 'S02';
CREATE USER S02 FOR LOGIN S02;

CREATE LOGIN SM01 WITH PASSWORD = 'SM01';
CREATE USER SM01 FOR LOGIN SM01;

CREATE LOGIN SM02 WITH PASSWORD = 'SM02';
CREATE USER SM02 FOR LOGIN SM02;

CREATE LOGIN OP01 WITH PASSWORD = 'OP01';
CREATE USER OP01 FOR LOGIN OP01;

CREATE LOGIN OP02 WITH PASSWORD = 'OP02';
CREATE USER OP02 FOR LOGIN OP02;


ALTER ROLE Customers ADD MEMBER C01;
ALTER ROLE Customers ADD MEMBER C02;

ALTER ROLE CustomerService ADD MEMBER CS01;
ALTER ROLE CustomerService ADD MEMBER CS02;


ALTER ROLE Sales ADD MEMBER S01;
ALTER ROLE Sales ADD MEMBER S02;

ALTER ROLE SalesManager ADD MEMBER SM01;
ALTER ROLE SalesManager ADD MEMBER SM02;

ALTER ROLE OrderProcessor ADD MEMBER OP01;
ALTER ROLE OrderProcessor ADD MEMBER OP02;


--Grant access to customer role

--1) User can see all products except CostPrice
GRANT SELECT ON Company.vwProduct TO Customers;

--2)Customer can view their credit card detail and last 4 digits
GRANT SELECT ON Company.vwCreditCard TO Customers;
GRANT SELECT ON Company.vwCustomer TO Customers;

--3)Update their own info
GRANT UPDATE ON Company.vwCustomer(Email, Passwrd, FirstName, LastName, Address, Phone) TO Customers;

--4)Can Insert/Remove credit card 
GRANT INSERT, DELETE ON Company.vwCreditCard TO Customers

--5) Can update HolderName and Billing Address
GRANT UPDATE ON Company.vwCreditCard(HolderName,BillingAddr) TO Customers


--For Encryption of password and credit card after insert update made on CreditCard table and Customer table
GRANT Control ON SYMMETRIC KEY::SQLSymmetricKey TO Customers;  
GO  
GRANT Control ON CERTIFICATE::SelfSignedCertificate TO Customers;  
GO  


 

--CUSTOMER SERVICE

--1) Can view Information of all products excluding CostPrice
GRANT SELECT ON Company.vwProduct TO CustomerService;

--2) Can view customer information and orders
GRANT SELECT ON Company.Customer TO CustomerService;
GRANT SELECT ON Company.Orders TO CustomerService;
GRANT SELECT ON Company.OrderItem TO CustomerService;

--3) Can remove an order item from a place order only if the order status is 'in Preparation' and order have no OrderItem
GRANT DELETE ON Company.Orders TO CustomerService; 

--4) Can update Quantity of an order item only if order status is 'in preparation'
GRANT UPDATE ON Company.OrderItem(Quantity) TO CustomerService; 

--5) Can insert a new order item to a placed order only if the order status is “inpreparation”. 
GRANT INSERT ON Company.OrderItem TO CustomerService;

--Assigning Encryption key for CostPrice encryption
GRANT Control ON SYMMETRIC KEY::ProductSymmetricKey TO CustomerService;  
GO  
GRANT Control ON CERTIFICATE::CompanySignedCertificate TO CustomerService;  
GO  

--SALES

--1)  Can select/insert/update product table
GRANT SELECT, INSERT ON Company.Product TO Sales;


--2) Cannot modify Cost_Price, Sales_Price, and Discount attributes.
GRANT UPDATE ON Company.Product(Name, Quantity, Description) TO Sales


--Assigning Encryption key for CostPrice encryption
GRANT Control ON SYMMETRIC KEY::ProductSymmetricKey TO Sales;  
GO  
GRANT Control ON CERTIFICATE::CompanySignedCertificate TO Sales;  
GO  

--SALES MANAGER
--1) can select/insert/update product table,
--2) can update Cost_Price, Sales_Price, and Discount attributes of product.

GRANT SELECT, INSERT ON Company.Product TO SalesManager;

GRANT UPDATE ON Company.Product(Name, Quantity, Description, Cost_Price, Sales_Price, Discount) TO SalesManager;

--Assigning Encryption key for CostPrice encryption
GRANT Control ON SYMMETRIC KEY::ProductSymmetricKey TO SalesManager;  
GO  
GRANT Control ON CERTIFICATE::CompanySignedCertificate TO SalesManager;  
GO  

--3)can remove a product from database if its quantity is 0.GRANT DELETE ON Company.Product TO SalesManager; --4) no permission on all other tables
DENY SELECT,INSERT,DELETE,UPDATE ON Company.CreditCard TO SalesManager;
DENY SELECT,INSERT,DELETE,UPDATE ON Company.Customer TO SalesManager;
DENY SELECT,INSERT,DELETE,UPDATE ON Company.Orders TO SalesManager;
DENY SELECT,INSERT,DELETE,UPDATE ON Company.OrderItem TO SalesManager;

--ORDER PROCESSOR
--1)Can view Order excluding Total_Amount, Credit_Card_ID attributes;

GRANT SELECT ON Company.Orders(OrderID,UserID,Order_Date,Shipping_address,Del_Status) TO OrderProcessor;

--2) Can view OrderItem excluding PaidPrice;
GRANT SELECT ON Company.OrderItem(OrderID, ProductID, Quantity) TO OrderProcessor;

--3) Only modify Status attribute of Order table.

GRANT UPDATE ON Company.Orders(Del_Status) TO OrderProcessor;


GRANT Control ON SYMMETRIC KEY::SQLSymmetricKey TO OrderProcessor;  
GO  
GRANT Control ON CERTIFICATE::SelfSignedCertificate TO OrderProcessor;  
GO  

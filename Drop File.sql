USE Ecommerce
Go

--Drop TRIGGER 
DROP TRIGGER Company.OrderItem_Instead_INSERT;
DROP TRIGGER Company.TR_OrderItem_Update;
DROP TRIGGER Company.Orders_UPDATE;
DROP TRIGGER Company.Orders_DELETE ;
DROP TRIGGER Company.OrderItem_DELETE;
DROP Trigger Company.vwCustomer_Update;
DROP TRIGGER Company.Customer_INSERT;
DROP TRIGGER Company.vwCreditCard_INSERT;
DROP TRIGGER Company.TR_vwCreditCard_Update;
DROP Trigger Company.Product_INSERT;
DROP Trigger Company.Product_UPDATE;
DROP Trigger Company.TR_Product_Delete;
DROP TRIGGER Company.TR_CreditCard_Delete;
DROP Trigger Company.CreditCard_INSERT;
DROP TRIGGER Company.TR_AUDIT_Update;
DROP TRIGGER Company.TR_AUDIT_Insert;
DROP TRIGGER Company.TR_AUDIT_Delete;
DROP PROCEDURE Company.CreditCardInsert ;
DROP PROCEDURE Company.vwCreditCardInsert ;
  
--Drop constarints
Alter Table Company.Orders
DROP CONSTRAINT chk_Del_Status;

--Drop view
DROP VIEW Company.vwCreditCard;
DROP VIEW Company.vwCustomer;
DROP VIEW Company.vwProduct;


--Drop Table 
DROP TABLE Company.OrderItem;
DROP TABLE Company.Orders;
DROP TABLE Company.Product;
DROP TABLE Company.CreditCard;
DROP TABLE Company.Customer;
DROP TABLE Company.ProductAudit;

--Drop Keys
Drop SYMMETRIC KEY SQLSymmetricKey;
Drop SYMMETRIC KEY ProductSymmetricKey
Drop CERTIFICATE SelfSignedCertificate
Drop CERTIFICATE CompanySignedCertificate;

--Drop Schema
DROP SCHEMA Company;

--DROP USERS;
DROP USER C01;  
DROP USER C02; 
DROP USER CS01;  
DROP USER CS02;
DROP USER S01;  
DROP USER S02;  
DROP USER SM01;  
DROP USER SM02;  
DROP USER OP01;  
DROP USER OP02;

--DROP LOGIN

DROP LOGIN C01 ;  
DROP LOGIN C02; 
DROP LOGIN CS01;  
DROP LOGIN CS02;
DROP LOGIN S01;  
DROP LOGIN S02;  
DROP LOGIN SM01;  
DROP LOGIN SM02;  
DROP LOGIN OP01;  
DROP LOGIN OP02;

--DROP ROLES
DROP ROLE Customers;
DROP ROLE CustomerService;
DROP ROLE Sales;
DROP ROLE SalesManager
DROP ROLE OrderProcessor

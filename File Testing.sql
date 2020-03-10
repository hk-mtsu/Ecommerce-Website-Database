

------------------------------------------------      Testing Constraints     --------------------------------------------------------------

--- To test constrains you should login as DBO. The other roles will not be able to  cross check all the constrains

USE Ecommerce
GO
-- 1) OrderItem.PaidPrice should always be greater or equal to the cost price of the product. The company will never lose money by selling a product

-- ProductID 1 have Cost_PRICE = 90 and Sales Price = 120.00 and Discount is 50 %, Paid Price = 60.00-- So Cost Price > Paid Price
INSERT INTO Company.OrderItem(OrderID, ProductID, PaidPrice, Quantity)
VALUES( 1, 1, NULL, 1 );			 --ERROR "Order cannot be placed Cost_Price is greater than Paid Price"
SELECT * FROM Company.OrderItem;

-- 2) OrderItem.PaidPrice and Order.Total_Amount should always be calculated automatically and consistent.

--PaidPrice = (1-(Discount/100))*SalesPrice; = (1-(5/100)*44 = 41.80

--TotalAmount = (Paid Price * Quantity) = (41.80 * 2) = 83.60

SELECT * FROM Company.OrderItem WHERE OrderID = 1; 
SELECT * FROM Company.Orders WHERE OrderID = 1;
SELECT * FROM Company.Product WHERE ProductID = 6;


-- 3) Start charging the credit card whenever the order status is changed to [shipped]. Charge can be completed by printing a message of the following format:
-- Credit Card ending with 1234 is charged $111.11 for the order with order id 1111111.UPDATE Company.Orders SET Del_Status = 'in preparation' WHERE OrderID = 1; --No Message is diplayedUPDATE Company.Orders SET Del_Status = 'Shipped' WHERE OrderID = 1; --Message is diplayed "Credit Card ending with 5897 is charged 83.60 for the order with order id 1."UPDATE Company.Orders SET Del_Status = 'Cannot deliver' WHERE OrderID = 1; ---ERROR: The UPDATE statement conflicted with the CHECK constraint "chk_Del_Status". 'Cannot deliver' is not a valid status.-- 4) When an order is placed, deduct OrderItem.Quantity from Product.Quantity for each order item. SELECT * FROM Company.Product WHERE ProductID = 8; -- Quantity is 15 for product 8 INSERT INTO Company.Orders(OrderID,UserID,Order_Date,Total_Amount,CreditCardID,Shipping_address,Del_Status) --Placing a new order
 VALUES(9,'C07','04-15-2019',0,5,'Florida','placed') INSERT INTO Company.OrderItem(OrderID, ProductID, PaidPrice, Quantity) VALUES( 9, 8, NULL, 4 ); -- Placing orderItem with Order Quantity 4 and ProductID 8

 SELECT * FROM Company.Product WHERE ProductID = 8; -- Quantity is deducted from 15 to 11 for product 8

--- Insert Another orderitem with Quantity greater than storage quantity of the product

 Select * from Company.Product where ProductID = 9;
 INSERT INTO Company.OrderItem(OrderID, ProductID, PaidPrice, Quantity) VALUES( 9, 9, NULL, 16 ); --ERROR : Order Quantity is greater than product Quantity

-- 5) When an order item is removed, add OrderItem.Quantity back to Product.Quantity.

SELECT * FROM Company.Product WHERE ProductID = 8;    --Quantity is 11
SELECT * FROM Company.OrderItem WHERE OrderID = 9 AND ProductID = 8; --OrderItem contains Order Quantity 4 of ProductID 8
DELETE FROM Company.OrderItem WHERE OrderID = 9 AND ProductID = 8; 
SELECT * FROM Company.Product WHERE ProductID = 8; --Quantity is reinstated, Quantity becomes 15




-- 6) Password, credit card number, and Product.Cost_Price must be encrypted.

SELECT * FROM Company.CreditCard; --Card number is encrypted  
SELECT * FROM Company.Customer; -- Password is encrypted
SELECT * FROM Company.Product; -- Cost Price is encrypted


-- 7) No one can modify user id, credit card id, order id, product id.UPDATE Company.Product SET ProductID = 12 WHERE Quantity = 10;  ----Error, you cannot change Primary Key columns
SELECT * FROM company.Product;

UPDATE Company.CreditCard SET CreditCardID = 11 WHERE CreditCardID = 7; ----Error, you cannot change Primary Key columns
SELECT * FROM Company.CreditCard;

UPDATE Company.Customer SET UserID = 'C011' WHERE UserID = 'C08'; ----Error, you cannot change Primary Key columns
SELECT * FROM Company.CreditCard;


-- Testing Each Roles permission 


-----------------------------------------------------------------------------------------    CUSTOMER     ---------------------------------------------------------------------------------------

--Login as Customer (Login = C01, passward = 'C01') 
USE Ecommerce
Go
--1) Customer can view information of all products excluding Cost_Price
SELECT * FROM Company.vwProduct;

--2)Customer can view their credit card detail and last 4 digits
SELECT * FROM Company.vwCreditCard;  --Login user is C01 hence only his details are visible 
SELECT * FROM Company.vwCustomer; 

--3) Customer can update their info

--Update users information in Customer Table
UPDATE Company.vwCustomer SET Address = 'Tampa' WHERE UserID = 'C01';
SELECT * FROM company.vwCustomer;

--Cannot update other users information
UPDATE Company.vwCustomer SET Address = 'Manali' WHERE UserID = 'C02';
SELECT * FROM company.vwCustomer;

--Cannot update userID
UPDATE Company.vwCustomer SET UserID = 'C15' WHERE UserID = 'C01'; -- The UPDATE permission was denied on the column 'UserID' 

--Update users information Taking care of password encryption on password update 
UPDATE Company.vwCustomer SET Passwrd = 'newpassword' WHERE UserID = 'C01'; -- user can set new password. You can cross check from 'file encrypt.sql'
SELECT * FROM company.vwCustomer;

--Update Only (Customer Cannot insert a new customer in Customer table)
Insert into Company.vwCustomer(UserID, Email, Passwrd, FirstName, LastName, Address, Phone)
Values('C09','Koetrl@yahoo.com','koetrl12345','Koela','Kayle','Lousiana','495-609-3685') --ERROR The INSERT permission was denied on the object 'vwCustomer'


--4)User can insert/Remove a credit card

--Insert
INSERT INTO Company.vwCreditCard
(CreditCardID,CardNumber,HolderName,ExpDate,CreditCard_Ends_With,CVC_Code,BillingAddr,OwnerID) -- New card is inserted
VALUES(9, '1452145214521234', 'Nisha Mains', '07/25', NULL,'654', 'Franklin', 'C01')
SELECT * FROM Company.vwCreditCard;

INSERT INTO Company.vwCreditCard
(CreditCardID,CardNumber,HolderName,ExpDate,CreditCard_Ends_With,CVC_Code,BillingAddr,OwnerID)  -- New card is inserted
VALUES(10, '9872198714521452', 'Nisha Mains', '07/25', NULL,'258', 'Franklin', 'C01')
SELECT * FROM Company.vwCreditCard;

--Delete your card 
-----Cannot delete using cardNumber, You need to use decryption while using cardNumber to delete

DELETE FROM Company.vwCreditCard WHERE CreditCardID = 6  --No rows will be deleted creditcard 6 does not belongs to C01
SELECT * FROM Company.vwCreditCard;

DELETE FROM Company.vwCreditCard WHERE CreditCardID = 9 --Rows will be deleted creditcard 9 belongs to C01
SELECT * FROM Company.vwCreditCard;

DELETE FROM Company.vwCreditCard -- All cards of user C01 are deleted if there is no Orders placed by the owner
SELECT * FROM Company.vwCreditCard;


--Since you must have delete All the credit card in the previous query you can run the below query to insert CreditCard for further testing
INSERT INTO Company.vwCreditCard
(CreditCardID,CardNumber,HolderName,ExpDate,CreditCard_Ends_With,CVC_Code,BillingAddr,OwnerID) -- New card is inserted
VALUES(9, '1452145214521452', 'Nisha Mains', '07/25', NULL,'654', 'Franklin', 'C01')


--5)Update HolderName or Billing address only
UPDATE Company.vwCreditCard SET HolderName = 'Nisha Mane'; -- Holder name will be updated in all the credit card of this owner
SELECT * FROM Company.vwCreditCard;


UPDATE Company.vwCreditCard SET ExpDate = '07/21'; -- The UPDATE permission was denied on the column 'ExpDate' for all the records
SELECT * FROM Company.vwCreditCard;


UPDATE Company.vwCreditCard SET ExpDate = '07/21' WHERE CreditCardID = 9; -- The UPDATE permission was denied on the column 'ExpDate' for ID 9
SELECT * FROM Company.vwCreditCard;


UPDATE Company.vwCreditCard SET BillingAddr = 'Columbia' WHERE CreditCardID = 1; --Nothing Happens as you can only Update HolderName and BillingAddress for your card
SELECT * FROM company.vwCreditCard;  --CreditCard 1 does not belongs to user C01.

UPDATE Company.vwCreditCard SET BillingAddr = 'Columbia' WHERE CreditCardID = 2; --BillingAddress for your card is now columbia
SELECT * FROM company.vwCreditCard;

--------------------------------------------------------------------------    CUSTOMER SERVICE    ------------------------------------------------------------------------------------------------------------
--(Login = CS01, passward = 'CS01')

--CUSTOMER SERVICE - Reconnect with LOGIN CS01 for User CS01 with password 'CS01' 
USE Ecommerce
Go
--1) Can view Information of all products excluding CostPrice

SELECT * FROM Company.vwProduct;

--2) Can view customer information and orders

SELECT * FROM Company.Customer;
SELECT * FROM Company.Orders;
SELECT * FROM Company.OrderItem;


--4)can update the quantity of an order item from a placed order only if the order status is “in preparation”.

UPDATE Company.OrderItem SET Quantity = 3 WHERE OrderID = 8 AND ProductID = 7;  --Update happens
Select * from Company.Orders;  -- Totalamount for Order 8 is updated to 231
SELECT * FROM Company.OrderItem; 
SELECT * FROM Company.vwProduct;  --Quantity of product in product table is updated to 12 

UPDATE Company.OrderItem SET PaidPrice = 102 WHERE OrderID = 1;  -- The UPDATE permission was denied on the column 'PaidPrice' of the object 'OrderItem'.

--5) Can insert a new order item to a placed order only if the order status is “in preparation”. 

SELECT * FROM Company.Orders;

INSERT INTO Company.OrderItem(OrderID, ProductID, PaidPrice, Quantity) VALUES( 8, 8, NULL, 2 ); --Successfully inserted because Status of ordrID 8 is 'in preparation'
SELECT * FROM Company.OrderItem;

INSERT INTO Company.OrderItem(OrderID, ProductID, PaidPrice, Quantity) VALUES( 2, 8, NULL, 1); -- Unsuccessful as OrderID 2 status is 'placed'
SELECT * FROM Company.OrderItem;

INSERT INTO Company.OrderItem(OrderID, ProductID, PaidPrice, Quantity) VALUES( 1, 8, NULL, 1); -- Unsuccessful as OrderID 1 status is 'shipped'
SELECT * FROM Company.OrderItem;


--3) Can remove an order item from a place order only if the order status is 'in Preparation' and order have no OrderItem

--OrderID 3 is in shipped status and has a correspoding OrderItem, hence cannot be deleted
DELETE FROM Company.Orders WHERE OrderID = 3;
SELECT * FROM Company.Orders;

--OrderID 7 is in shipped status but doesn't have a correspoding OrderItem, hence it is deleted
DELETE FROM Company.Orders WHERE OrderID = 7;
SELECT * FROM Company.Orders;

--No corresponding item in OrderItem table, So orderID 6 gets deleted
SELECT * FROM Company.OrderItem;

DELETE FROM Company.Orders WHERE OrderID = 6;
SELECT * FROM Company.Orders;

-- All the items that are 'in preparation' was removed. Also, If an order doesn’t contain order items, the order should also be removed;

DELETE FROM Company.Orders;  --Order 5 is removed as there was no OrderItem for that record
							 --Order 4 and 8 are removed as they were 'in preparation' status
SELECT * FROM Company.Orders;
SELECT * FROM Company.OrderItem;


--------------------------------------------------------------------------------   SALES   ----------------------------------------------------------------------------------------------
--SALES (Login - S01, password - S01) 

USE Ecommerce
Go
--1)  can select/insert/update product table

--SELECT
SELECT * FROM Company.Product;

--INSERT Record - Row inserted and CostPrice is Encrypted and stored
INSERT INTO Company.Product(ProductID, Name, Quantity, Description, Cost_Price, Sales_Price, Discount)
VALUES(10,'Reebok Sports',15,'Sneakers', 45,85,0)
SELECT * FROM Company.Product;

--UPDATE

--Updating Description is successful
 UPDATE Company.Product SET Description = 'Crocs' WHERE ProductID = 1;
 SELECT * FROM Company.Product;

 --Updating SalesPrice, Cost_Price and Discount Denied
 UPDATE Company.Product SET Sales_Price = 130 WHERE ProductID = 1; --The UPDATE permission was denied on the column 'Sales_Price' of the object 'Product', database 'Ecommerce', schema 'Company'.
 SELECT * FROM Company.Product;

  UPDATE Company.Product SET Cost_Price = 45 WHERE ProductID = 1; --The UPDATE permission was denied on the column 'Cost_price' of the object 'Product', database 'Ecommerce', schema 'Company'.
 SELECT * FROM Company.Product;

  UPDATE Company.Product SET Discount = 10 WHERE ProductID = 1; --The UPDATE permission was denied on the column 'Discount' of the object 'Product', database 'Ecommerce', schema 'Company'.
 SELECT * FROM Company.Product;

-------------------------------------------------------------------------------------------   SALES MANAGER    --------------------------------------------------------------------------------------
--SALES MANAGER (Login - SM01, Password - SM01) -- select Ecommerce as default database
USE Ecommerce
Go
--1) Sales Manager can select/insert/update product table,
--2) Sales Manager can update Cost_Price, Sales_Price, and Discount attributes of product.

UPDATE Company.Product SET Cost_Price = 65 WHERE ProductID = 1;
SELECT * FROM Company.Product;	

UPDATE Company.Product SET Sales_Price = 165 WHERE ProductID = 1;
SELECT * FROM Company.Product;	

----Sales Manager can vew Costprice as well
OPEN SYMMETRIC KEY ProductSymmetricKey  
DECRYPTION BY CERTIFICATE CompanySignedCertificate; 
SELECT ProductID, Name, Quantity, Description, CONVERT(int, DecryptByKey(Cost_Price)) AS Cost_Price, Sales_Price, Discount FROM Company.Product;

--INSERT Record - Row inserted and CostPrice is Encrypted and stored
INSERT INTO Company.Product(ProductID, Name, Quantity, Description, Cost_Price, Sales_Price, Discount)
VALUES(11,'Gucci',10,'Sneakers', 120,200,0)
INSERT INTO Company.Product(ProductID, Name, Quantity, Description, Cost_Price, Sales_Price, Discount)
VALUES(12,'Gucci',0,'Crocs', 130,150,0)
SELECT * FROM Company.Product;

--3) Sales Manager can remove a product from database if its quantity is 0.

DELETE FROM Company.Product WHERE Name = 'Gucci'; -- Only deletes the record where Quantity is 0
SELECT * FROM Company.Product; --ProductID 12 is deleted

DELETE FROM Company.Product;  -- Nothing Happens 'Sales Manager can only delete items with quantity 0'
SELECT * FROM Company.Product;

--4) Sales Manager should have No permission on all other tables 

--Nothing will execute --  
SELECT * FROM Company.Customer;   --The SELECT permission was denied
Select * FROM Company.CreditCard;  --The SELECT permission was denied
Select * FROM Company.OrderItem;   --The SELECT permission was denied
Select * FROM Company.Orders;      --The SELECT permission was denied

--No update permission to sales Manager
UPDATE Company.CreditCard SET BillingAddr = 'Columbia' WHERE CreditCardID = 2;  -- The UPDATE permission was denied on the object 'vwCreditCard'                            

UPDATE Company.OrderItem SET Quantity = 2 WHERE OrderID = 2; ---The UPDATE permission was denied on the object 'OrderItem'

UPDATE Company.Orders SET Order_Date = '04-04-2019' WHERE OrderID = 2; ---The UPDATE permission was denied on the object 'Orders'	

UPDATE Company.Customer SET FirstName = 'Shea' WHERE UserID = 'C01';  ----The UPDATE permission was denied on the object 'Customer',

DELETE FROM Company.OrderItem;  --The DELETE permission was denied on the object 'OrderItem',
DELETE FROM Company.Orders;   --The DELETE permission was denied on the object 'Orders',
DELETE FROM Company.Customer;  --The DELETE permission was denied on the object 'Customer',
DELETE FROM Company.CreditCard;   --The DELETE permission was denied on the object 'CreditCard',


------------------------------------------------       ORDER PROCESSORS         ------------------------------------------------------------------
--ORDER PROCESSORS (Login - OP01, Password - OP01) 
USE Ecommerce
Go
--1)Can view Order excluding Total_Amount, Credit_Card_ID attributes;

SELECT OrderID,UserID,Order_Date,Shipping_address,Del_Status FROM Company.Orders; -- Executes

SELECT * FROM Company.Orders -- Error - The SELECT permission was denied on the column 'Total_Amount' and 'CreditCardID'

--2) Can view OrderItem excluding PaidPrice;
SELECT OrderID, ProductID, Quantity FROM Company.OrderItem; --Executes

SELECT * FROM Company.OrderItem -- Error - The SELECT permission was denied on the column 'PaidPrice' 


--3) Only modify 'Status' attribute of Order table.

UPDATE Company.Orders SET Shipping_address = 'Nashville' WHERE OrderID = 1; -- The UPDATE permission was denied on the column 'Shipping_address' 

UPDATE Company.Orders SET Del_Status = 'shipped' WHERE OrderID = 1; --Message 'Credit Card ending with 5897 is charged 83.60 for the order with order id 1.'

UPDATE Company.Orders SET Del_Status = 'in preparation' WHERE OrderID = 2; -- Executes But No Message is dispalyed
SELECT OrderID,UserID,Order_Date,Shipping_address,Del_Status FROM Company.Orders;

INSERT INTO Company.Orders(OrderID,UserID,Order_Date,Total_Amount,CreditCardID,Shipping_address,Del_Status)
VALUES(11,'C02','04-14-2019',0,3,'New orleans','in preparation') -- This SHOULD NOT work because the user "OP01" does not have insert permission on Orders 

INSERT INTO Company.OrderItem(OrderID, ProductID, PaidPrice, Quantity) VALUES( 2, 3, NULL, 2 ); -- This SHOULD NOT work because the user "OP01" does not have insert permission on OrderItem

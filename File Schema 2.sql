
--Insert Statement should be executed after executing triggers in Object File
USE Ecommerce;
GO
--Insert into Customer
Insert into Company.Customer(UserID, Email, Passwrd, FirstName, LastName, Address, Phone)
Values('C01','abc@gmail.com','abc789','Karen','Liyo','Nashville','655-609-3697')
Insert into Company.Customer(UserID, Email, Passwrd, FirstName, LastName, Address, Phone)
Values('C02','lizo@yahoo.com','lizp123','lizo','ken','New Jersey','455-609-3697')
Insert into Company.Customer(UserID, Email, Passwrd, FirstName, LastName, Address, Phone)
Values('C03','Ted_kool@gmail.com','Ted852','Ted','Mosby','New York','555-609-3697')
Insert into Company.Customer(UserID, Email, Passwrd, FirstName, LastName, Address, Phone)
Values('C04','abc@gmail.com','marshal','Marshall','Erickson','Nashville','655-609-3697')
Insert into Company.Customer(UserID, Email, Passwrd, FirstName, LastName, Address, Phone)
Values('C05','CamH@gmail.com','cam','Cam','heather','Columbia','655-609-3697')
Insert into Company.Customer(UserID, Email, Passwrd, FirstName, LastName, Address, Phone)
Values('C06','SarahWhite@gmail.com','$arah','Sarah','white','California','755-609-3697')
Insert into Company.Customer(UserID, Email, Passwrd, FirstName, LastName, Address, Phone)
Values('C07','KhannaAmitc@gmail.com','AMT123','Amit','khanna','Louisville','955-609-3697')
Insert into Company.Customer(UserID, Email, Passwrd, FirstName, LastName, Address, Phone)
Values('C08','Koel@gmail.com','koel12345','Koel','Kayle','Lousiana','455-609-3685')


Insert into Company.CreditCard(CreditCardID,CardNumber,HolderName,ExpDate,CreditCard_Ends_With,CVC_Code,BillingAddr,OwnerID)
VALUES(1, '4526458962355897','Amit Khanna','06/20',Null,'558','Louisville','C04')
Insert into Company.CreditCard(CreditCardID,CardNumber,HolderName,ExpDate,CreditCard_Ends_With,CVC_Code,BillingAddr,OwnerID)
VALUES(2, '1234567812345678','Karen Liyo','05/23',Null,'859','Nashville','C01')
Insert into Company.CreditCard(CreditCardID,CardNumber,HolderName,ExpDate,CreditCard_Ends_With,CVC_Code,BillingAddr,OwnerID)
VALUES(3, '9874563298745632','lizo ken','01/25',Null,'658','New Jersey','C02')
Insert into Company.CreditCard(CreditCardID,CardNumber,HolderName,ExpDate,CreditCard_Ends_With,CVC_Code,BillingAddr,OwnerID)
VALUES(4, '3256985678541452','Ted Mosby','07/19',Null,'987','New York','C03')
Insert into Company.CreditCard(CreditCardID,CardNumber,HolderName,ExpDate,CreditCard_Ends_With,CVC_Code,BillingAddr,OwnerID)
VALUES(5, '7894523652369874','Marshall Erickson','12/21',Null,'123','Nashville','C07')
Insert into Company.CreditCard(CreditCardID,CardNumber,HolderName,ExpDate,CreditCard_Ends_With,CVC_Code,BillingAddr,OwnerID)
VALUES(6, '9856985698569856','Marshall Erickson','12/24',Null,'987','Nashville','C04')
Insert into Company.CreditCard(CreditCardID,CardNumber,HolderName,ExpDate,CreditCard_Ends_With,CVC_Code,BillingAddr,OwnerID)
VALUES(7, '5858585898989875','Sarah white','12/22',Null,'145','California','C06')
Insert into Company.CreditCard(CreditCardID,CardNumber,HolderName,ExpDate,CreditCard_Ends_With,CVC_Code,BillingAddr,OwnerID)
VALUES(8, '5252878963638784','Cam heather','12/22',Null,'885','Columbia','C05')

	
INSERT INTO Company.Product(ProductID, Name, Quantity, Description, Cost_Price, Sales_Price, Discount)
VALUES(1,'Nike Air Bag',10,'Sneaker', 90,120,50)
INSERT INTO Company.Product(ProductID, Name, Quantity, Description, Cost_Price, Sales_Price, Discount)
VALUES(2,'Nike Revolution',20,'Sport Shoes', 20,44,10)
INSERT INTO Company.Product(ProductID, Name, Quantity, Description, Cost_Price, Sales_Price, Discount)
VALUES(3,'Addidas',15,'Sport Shoes', 80,110,5)
INSERT INTO Company.Product(ProductID, Name, Quantity, Description, Cost_Price, Sales_Price, Discount)
VALUES(4,'Addidas Grove',25,'Boats', 40,70,10)
INSERT INTO Company.Product(ProductID, Name, Quantity, Description, Cost_Price, Sales_Price, Discount)
VALUES(5,'Reebok Classic',5,'Sneakers', 60,100,15)
INSERT INTO Company.Product(ProductID, Name, Quantity, Description, Cost_Price, Sales_Price, Discount)
VALUES(6,'Aldo Classic',5,'Loafers', 20,44,5)
INSERT INTO Company.Product(ProductID, Name, Quantity, Description, Cost_Price, Sales_Price, Discount)
VALUES(7,'Abercrombie & Fitch',15,'Loafers', 55,77,0)
INSERT INTO Company.Product(ProductID, Name, Quantity, Description, Cost_Price, Sales_Price, Discount)
VALUES(8,'Abercrombie & Fitch',15,'Sneakers', 20,45,0)
INSERT INTO Company.Product(ProductID, Name, Quantity, Description, Cost_Price, Sales_Price, Discount)
VALUES(9,'Nike',15,'Sneakers', 45,85,0)


INSERT INTO Company.Orders(OrderID,UserID,Order_Date,Total_Amount,CreditCardID,Shipping_address,Del_Status)
VALUES(1,'C02','03-26-2019',0,1,'New Jersey','placed')
INSERT INTO Company.Orders(OrderID,UserID,Order_Date,Total_Amount,CreditCardID,Shipping_address,Del_Status)
VALUES(2,'C03','04-03-2019',0,3,'Florida','placed')
INSERT INTO Company.Orders(OrderID,UserID,Order_Date,Total_Amount,CreditCardID,Shipping_address,Del_Status)
VALUES(3,'C01','03-24-2019',0,1,'New York','Shipped')
INSERT INTO Company.Orders(OrderID,UserID,Order_Date,Total_Amount,CreditCardID,Shipping_address,Del_Status)
VALUES(4,'C02','04-03-2019',0,3,'Florida','in preparation')
INSERT INTO Company.Orders(OrderID,UserID,Order_Date,Total_Amount,CreditCardID,Shipping_address,Del_Status)
VALUES(5,'C01','04-03-2019',0,1,'Florida','placed')
INSERT INTO Company.Orders(OrderID,UserID,Order_Date,Total_Amount,CreditCardID,Shipping_address,Del_Status)
VALUES(6,'C04','04-03-2019',0,1,'New jersey','placed')
INSERT INTO Company.Orders(OrderID,UserID,Order_Date,Total_Amount,CreditCardID,Shipping_address,Del_Status)
VALUES(7,'C04','04-04-2019',0,2,'New orleans','shipped')
INSERT INTO Company.Orders(OrderID,UserID,Order_Date,Total_Amount,CreditCardID,Shipping_address,Del_Status)
VALUES(8,'C02','04-14-2019',0,3,'New orleans','in preparation')


INSERT INTO Company.OrderItem(OrderID, ProductID, PaidPrice, Quantity) VALUES( 2, 3, NULL, 2 );
INSERT INTO Company.OrderItem(OrderID, ProductID, PaidPrice, Quantity) VALUES( 3, 2, NULL, 3 );
INSERT INTO Company.OrderItem(OrderID, ProductID, PaidPrice, Quantity) VALUES( 3, 5, NULL, 1 );
INSERT INTO Company.OrderItem(OrderID, ProductID, PaidPrice, Quantity) VALUES( 4, 4, NULL, 2 );
INSERT INTO Company.OrderItem(OrderID, ProductID, PaidPrice, Quantity) VALUES( 4, 5, NULL, 2 );
INSERT INTO Company.OrderItem(OrderID, ProductID, PaidPrice, Quantity) VALUES( 1, 6, NULL, 2 );
INSERT INTO Company.OrderItem(OrderID, ProductID, PaidPrice, Quantity) VALUES( 8, 7, NULL, 1 );

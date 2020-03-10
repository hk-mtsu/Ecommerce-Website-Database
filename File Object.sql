
USE Ecommerce;
GO

--Stored procedure called by CreditCard_Insert trigger and VwCreditCard_Insert trigger to encrypt Credit card information
if (OBJECT_ID('Company.CreditCardInsert', 'P') is NOT NULL)
     Drop procedure Company.CreditCardInsert;
	 GO
     
Create Procedure Company.CreditCardInsert
@CreditCardID int, @CardNumber varchar(Max),@HolderName nvarchar (50),@ExpDate VARCHAR(20), 
@CVC_Code VARCHAR(3), @BillingAddr varchar(255), @OwnerID VARCHAR(50)
AS
BEGIN
		
		 DECLARE @LastDigits VARCHAR(20); 
		 Declare @CardNo varbinary(max); 
		

			OPEN SYMMETRIC KEY SQLSymmetricKey  
			DECRYPTION BY CERTIFICATE SelfSignedCertificate;
	
			SET @LastDigits = (SELECT CardNumber FROM Company.CreditCard WHERE CreditCardID = @CreditCardID);
			SET @CardNo = (SELECT EncryptByKey(Key_GUID('SQLSymmetricKey'), CardNumber) FROM Company.CreditCard WHERE CreditCardID = @CreditCardID);

			UPDATE Company.CreditCard  
			SET [CardNumber] = CONVERT(VARCHAR(max), @CardNo, 1), [CreditCard_Ends_With] = RIGHT( @LastDigits, 4 )
			WHERE CreditCardID = @CreditCardID; 
	    
			CLOSE SYMMETRIC KEY SQLSymmetricKey;

		
END
GO

---Stored procedure to insert data in CreditCard table when data is coming from vwCreditCard

if (OBJECT_ID('Company.vwCreditCardInsert', 'P') is NOT NULL)
     Drop procedure Company.vwCreditCardInsert;
	 GO
     
Create Procedure Company.vwCreditCardInsert
@CreditCardID int, @CardNumber varchar(Max),@HolderName nvarchar (50),@ExpDate VARCHAR(20), 
@CVC_Code VARCHAR(3), @BillingAddr varchar(255), @OwnerID VARCHAR(50)
AS
BEGIN
		
			INSERT INTO Company.CreditCard(CreditCardID,CardNumber,HolderName,ExpDate,CreditCard_Ends_With,CVC_Code,BillingAddr,OwnerID)
			SELECT @CreditCardID, @CardNumber, @HolderName, @ExpDate, Null, @CVC_Code, @BillingAddr, @OwnerID;
		
END
GO


---trigger for Constraint PaidPrice calculation and check if paid price is greater than cost price
--Deduct Quantity from Product when OrderItem is inserted/ Calculates Total Amount 
--Order Quantity should not be greater that total product Quantity
Create Trigger Company.OrderItem_Instead_INSERT
ON Company.OrderItem
INSTEAD OF INSERT
AS
BEGIN
	
	OPEN SYMMETRIC KEY ProductSymmetricKey  
	DECRYPTION BY CERTIFICATE CompanySignedCertificate; 
	Declare @Q1 int;
	Declare @Q2 int;
	Declare @Status VARCHAR(100);
	DECLARE @PaidPrice Decimal(15,2);
	DECLARE @SalesPrice Decimal(15,2);
	DECLARE @Discount DECIMAL(15,2);
	DECLARE @OrderID INT;
    DECLARE @ProductID INT;
	DECLARE @Quantity INT
	DECLARE @Cost_Price int;
	DECLARE @Total_Amt Decimal(15,2);
	
	 DECLARE iterate CURSOR FOR
      SELECT OrderID, ProductID, Quantity
        FROM inserted;

OPEN iterate
FETCH NEXT FROM iterate INTO @OrderID, @ProductID, @Quantity
WHILE @@FETCH_STATUS = 0
BEGIN
	SET @Status = (SELECT Del_Status FROM Company.Orders WHERE OrderID = @OrderID);
	IF ((IS_ROLEMEMBER('CustomerService') = 1 AND CHARINDEX('in preparation',@Status) > 0 ) OR IS_ROLEMEMBER('CustomerService') = 0 OR USER_NAME() = 'dbo')
	BEGIN

		SET @SalesPrice = (SELECT Sales_Price FROM Company.Product WHERE ProductID = @ProductID);
		SET @Discount = (SELECT Discount FROM Company.Product WHERE ProductID = @ProductID);
		SET @PaidPrice = (1-(@Discount/100))*@SalesPrice;
		SET @Q1 = (Select Quantity from inserted where OrderID = @OrderID);
		SET @Q2 = (Select Quantity from Company.Product where ProductID = @ProductID );
		SET @Cost_Price = (SELECT CONVERT(int, DecryptByKey(Cost_Price)) FROM Company.Product WHERE ProductID = @ProductID)
		IF (@Cost_Price > @PaidPrice)
			BEGIN
				RAISERROR (N'Order cannot be placed Cost_Price is greater than Paid Price',11,2);
				ROLLBACK;
			END
		ELSE
		BEGIN
			IF (@Q1 > @Q2)
			BEGIN
				RAISERROR (N' Order Quantity is greater than product Quantity',11,2);
				ROLLBACK;
			END
			ELSE
				BEGIN
					INSERT INTO Company.OrderItem(OrderID, ProductID, PaidPrice, Quantity) 
					values (@OrderID, @ProductID, Null, @Quantity);

					--Calculate total Amount
					SET @Total_Amt = @Quantity * @PaidPrice;
				
					--Update PaidPRice
					Update Company.OrderItem
					set  PaidPrice = @PaidPrice
					where OrderID = @OrderID AND ProductID = @ProductID;


					--Update total amount
					UPDATE Company.Orders
					set  Total_Amount = (Total_Amount + @Total_Amt)
					where OrderID = @OrderID;

					--Update Quantity
					Update Company.Product
					set  Quantity = (Quantity - @Quantity)
					where ProductID = @ProductID;
					END
			
			END
		END
		FETCH NEXT FROM iterate INTO @OrderID, @ProductID, @Quantity  
	END
	CLOSE iterate
	DEALLOCATE iterate;

END
GO

--When order Quantity is updated re-calculate total amount and Quantity
CREATE TRIGGER Company.TR_OrderItem_Update
ON Company.OrderItem
INSTEAD OF UPDATE
AS
BEGIN
	DECLARE @OrderID INT;
	DECLARE @Del_Status VARCHAR(15);
	DECLARE @ProductID INT;
	DECLARE @Quantity INT;
	DECLARE @TotalAmount DECIMAL(15,2);
	DECLARE @PaidPrice DECIMAL(15,2);
	DECLARE @Quant DECIMAL(15,2);
	Declare @Q1 int;

	DECLARE iterateInsert CURSOR FOR
      SELECT OrderID, ProductID, PaidPrice, Quantity
        FROM inserted;

	OPEN iterateInsert
    FETCH NEXT FROM iterateInsert INTO @OrderID, @ProductID,@PaidPrice, @Quantity
    WHILE @@FETCH_STATUS = 0
		BEGIN
		SET @Quant = (SELECT Quantity FROM Company.OrderItem WHERE OrderID = @OrderID AND ProductID = @ProductID);
		SET @Del_Status = (SELECT Del_status FROM Company.Orders WHERE OrderID = @OrderID);
		SET @Q1 = (Select Quantity from Company.Product where ProductID = @ProductID );

		IF CHARINDEX('in preparation',@Del_Status) > 0
		BEGIN
			IF @Quant > @Quantity 
			BEGIN
					SET @TotalAmount = @Quantity * @PaidPrice;
					UPDATE Company.OrderItem SET Quantity = @Quantity WHERE OrderID = @OrderID AND ProductID = @ProductID;			
					UPDATE Company.Orders SET Total_Amount = @TotalAmount WHERE OrderID = @OrderID;
					UPDATE Company.Product SET Quantity = (Quantity + (@Quant - @Quantity)) WHERE ProductID = @ProductID;
			END
            IF @Quant < @Quantity 
			BEGIN
				IF @Q1 < (@Quantity - @Quant)
					BEGIN
						RAISERROR (N' Order Quantity is greater than product Quantity',11,2);
						ROLLBACK;
					END
				ELSE
					BEGIN
						SET @TotalAmount = @Quantity * @PaidPrice;
						UPDATE Company.OrderItem SET Quantity = @Quantity WHERE OrderID = @OrderID AND ProductID = @ProductID;			
						UPDATE Company.Orders SET Total_Amount = @TotalAmount WHERE OrderID = @OrderID;
						UPDATE Company.Product SET Quantity = (Quantity - (@Quantity - @Quant)) WHERE ProductID = @ProductID;
					END
			End
		END	
		FETCH NEXT FROM iterateInsert INTO @OrderID, @ProductID, @PaidPrice, @Quantity
		END
		
    CLOSE iterateInsert
	DEALLOCATE iterateInsert;

END
GO
	

--After update trigger for Delivery status change to shipped display message
CREATE TRIGGER Company.Orders_UPDATE 
ON Company.Orders
AFTER UPDATE
AS
IF UPDATE(Del_Status)
BEGIN
	DECLARE @T1 TABLE(item VARCHAR(100));
	DECLARE @CardNumber NVARCHAR(25);
	DECLARE @Order_ID INT;
	DECLARE @total_amt DECIMAL(15,2);
	DECLARE @Print VARCHAR(100);
	DECLARE @Del_Status VARCHAR(15);
	DECLARE @CreditCardID INT;
	DECLARE @OrderID INT;
	
	 DECLARE iterateInsert CURSOR FOR
      SELECT OrderID, CreditCardID
        FROM inserted;

		OPEN SYMMETRIC KEY SQLSymmetricKey  
		DECRYPTION BY CERTIFICATE SelfSignedCertificate; 

			OPEN iterateInsert
			FETCH NEXT FROM iterateInsert INTO @OrderID, @CreditCardID
			WHILE @@FETCH_STATUS = 0
			BEGIN
 
				SET @Order_ID = (SELECT OrderID FROM Company.Orders WHERE OrderId = @OrderID );
				SET @total_amt = (SELECT Total_Amount FROM Company.Orders WHERE OrderId = @OrderID );
				SET @CardNumber = (SELECT CONVERT(varchar, DecryptByKey(CONVERT(varbinary(max), CardNumber, 1))) FROM Company.CreditCard WHERE CreditCardID = @CreditCardID);
				SET @CardNumber = (SELECT RIGHT( @CardNumber, 4 ));
				SET @Del_Status = (SELECT Del_Status FROM Company.Orders WHERE OrderID = @OrderID);

				IF CHARINDEX('shipped',@Del_Status) > 0
				Begin
					SET @Print = N'Credit Card ending with ' + @CardNumber + ' is charged '+ convert(varchar(10),@total_amt) +' for the order with order id '+ convert(varchar(10),@Order_ID) + '.';
					Insert Into @T1(Item) SELECT @Print;
				END
			FETCH NEXT FROM iterateInsert INTO @OrderID, @CreditCardID
			END
			CLOSE iterateInsert
			DEALLOCATE iterateInsert;
		CLOSE SYMMETRIC KEY SQLSymmetricKey;  
	SELECT item AS Message FROM @T1 ;
END
--Primary Key constarint for no update on OrderID
IF UPDATE (OrderID)
BEGIN
	RAISERROR('Error, you cannot change Primary Key columns', 16, 1)
	ROLLBACK
	RETURN
END
GO

---Delete order if 'in preparation ' status
CREATE TRIGGER Company.Orders_DELETE 
ON Company.Orders
INSTEAD OF DELETE
AS
BEGIN 

DECLARE @Prod TABLE(ProductId INT, Quantity int); 
DECLARE @status VARCHAR(50);
DECLARE @OrderID INT;
DECLARE @Quant INT;
DECLARE @ProductID INT;



		DECLARE iterateItem CURSOR FOR
        SELECT OrderID, Del_Status
        FROM deleted;

		OPEN iterateItem
		FETCH NEXT FROM iterateItem INTO @OrderID, @status
		WHILE @@FETCH_STATUS = 0
		BEGIN

			IF CHARINDEX('in preparation', @status) > 0 
			BEGIN
				
				Insert Into @Prod(ProductId, Quantity) (SELECT ProductID, Quantity FROM Company.OrderItem WHERE OrderID = @OrderID);
				UPDATE prod SET prod.Quantity = (prod.Quantity + tmp.Quantity) FROM Company.Product prod INNER JOIN @Prod tmp ON prod.ProductID = tmp.ProductId;

				DELETE FROM Company.OrderItem WHERE OrderID = @OrderID;

				DELETE FROM Company.Orders WHERE OrderID = @OrderID;

			END
			IF @OrderID NOT IN (SELECT OrderID FROM Company.OrderItem) 
				BEGIN
					DELETE FROM Company.Orders WHERE OrderID = @OrderID;
				END

		FETCH NEXT FROM iterateItem INTO @OrderID, @status
		END
		CLOSE iterateItem
		DEALLOCATE iterateItem;
		
END
GO

-- Constraint to reinstate the quantity in product table when order item is deleted
CREATE TRIGGER Company.OrderItem_DELETE 
ON Company.OrderItem
INSTEAD of DELETE
AS
BEGIN

		Declare @Quantity int;
		Declare @OrderID int;
		DECLARE @ProductId INT;
		DECLARE iterate CURSOR FOR
			SELECT OrderID, ProductID, Quantity
			FROM Deleted;

						OPEN iterate
						FETCH NEXT FROM iterate INTO @OrderID, @ProductId, @Quantity
						WHILE @@FETCH_STATUS = 0
						BEGIN
								
								DELETE FROM Company.OrderItem WHERE OrderID = @OrderID AND ProductID = @ProductId;

								Update Company.Product
								SET  Quantity = (Quantity + @Quantity)
								WHERE ProductID = @ProductId;

						FETCH NEXT FROM iterate INTO @OrderID, @ProductId, @Quantity
						END
						CLOSE iterate
						DEALLOCATE iterate;
	
END
GO

--Encryption password customer table
Create Trigger Company.Customer_INSERT
ON Company.Customer
AFTER INSERT
AS
BEGIN

	OPEN SYMMETRIC KEY SQLSymmetricKey  
	DECRYPTION BY CERTIFICATE SelfSignedCertificate;

	Declare @Pass varbinary(max); 
	SET @Pass = (SELECT EncryptByKey(Key_GUID('SQLSymmetricKey'), Passwrd) FROM Company.Customer WHERE UserID IN (SELECT a.UserID FROM inserted a));

	UPDATE Company.Customer  
	SET [Passwrd] = CONVERT(VARCHAR(max), @Pass, 1)
	WHERE UserID IN (SELECT a.UserID FROM inserted a); 

	CLOSE SYMMETRIC KEY SQLSymmetricKey;  

END
GO


--Trigger called when customer updates their information takes care of password encryption and decryption
CREATE TRIGGER Company.vwCustomer_Update
ON Company.vwCustomer
INSTEAD OF UPDATE
AS
IF UPDATE (UserID)
BEGIN
	RAISERROR('Error, you cannot change Primary Key columns', 16, 1)
	ROLLBACK
	RETURN
END
BEGIN
	
	UPDATE Company.Customer SET Email = a.Email, Passwrd = a.Passwrd, FirstName = a.FirstName, LastName = a.LastName, Address = a.Address, Phone = a.Phone from inserted a inner join
			Company.Customer b on a.UserID = b.UserID;

		Declare @Userid varchar(25);
		DECLARE @newPass VARCHAR(MAX);
		DECLARE @oldPass VARCHAR(MAX);
	
		DECLARE iterate CURSOR FOR
			SELECT UserID
			FROM Inserted;

						OPEN iterate
						FETCH NEXT FROM iterate INTO @UserID
						WHILE @@FETCH_STATUS = 0
						BEGIN

						SET @newPass = (SELECT a.Passwrd FROM inserted a where a.UserID = @UserID);
						SET @oldPass = (SELECT a.Passwrd FROM deleted a where a.UserID = @UserID);

						IF CHARINDEX(@newPass,@oldPass) <=  0
						Begin
							OPEN SYMMETRIC KEY SQLSymmetricKey  
							DECRYPTION BY CERTIFICATE SelfSignedCertificate;

							Declare @Pass varbinary(max); 
							SET @Pass = (SELECT EncryptByKey(Key_GUID('SQLSymmetricKey'), Passwrd) FROM Company.Customer WHERE UserID = @Userid);

							UPDATE Company.Customer  
							SET [Passwrd] = CONVERT(VARCHAR(max), @Pass, 1)
							WHERE UserID IN (SELECT a.UserID FROM inserted a); 
							CLOSE SYMMETRIC KEY SQLSymmetricKey;  
						END
				FETCH NEXT FROM iterate INTO @UserId
				END
			CLOSE iterate
		DEALLOCATE iterate;
END
GO


--Insert through the view into credit card table
Create Trigger Company.vwCreditCard_INSERT
ON Company.vwCreditCard
INSTEAD OF INSERT
AS
BEGIN
	
	
	DECLARE iterateIns CURSOR FOR
    SELECT CreditCardID, CardNumber, HolderName, ExpDate, CVC_Code, BillingAddr, OwnerID
    FROM inserted;

	DECLARE @CreditCardID INT;
	DECLARE @CardNumber varchar(Max);
	DECLARE @HolderName nvarchar (50);
	DECLARE @ExpDate VARCHAR(20);
	DECLARE @CVC_Code VARCHAR(3); 
	DECLARE @BillingAddr varchar(255);
	DECLARE @OwnerID VARCHAR(50);

	OPEN iterateIns
    FETCH NEXT FROM iterateIns INTO @CreditCardID, @CardNumber, @HolderName, @ExpDate, @CVC_Code, @BillingAddr, @OwnerID
    WHILE @@FETCH_STATUS = 0
    BEGIN

	EXEC Company.vwCreditCardInsert @CreditCardID, @CardNumber, @HolderName, @ExpDate, @CVC_Code, @BillingAddr, @OwnerID;
	 
	FETCH NEXT FROM iterateIns INTO @CreditCardID, @CardNumber, @HolderName, @ExpDate, @CVC_Code, @BillingAddr, @OwnerID;
    END
    CLOSE iterateIns
	DEALLOCATE iterateIns;
END
GO


--Encrypt card number insert through the table CreditCard 
Create Trigger Company.CreditCard_INSERT
ON Company.CreditCard
AFTER INSERT
AS
BEGIN

	DECLARE iterateIn CURSOR FOR
    SELECT CreditCardID, CardNumber, HolderName, ExpDate, CVC_Code, BillingAddr, OwnerID
    FROM inserted;

	DECLARE @CreditCardID INT;
	DECLARE @CardNumber varchar(Max);
	DECLARE @HolderName nvarchar (50);
	DECLARE @ExpDate VARCHAR(20);
	DECLARE @CVC_Code VARCHAR(3); 
	DECLARE @BillingAddr varchar(255);
	DECLARE @OwnerID VARCHAR(50);

	OPEN iterateIn
    FETCH NEXT FROM iterateIn INTO @CreditCardID, @CardNumber, @HolderName, @ExpDate, @CVC_Code, @BillingAddr, @OwnerID
    WHILE @@FETCH_STATUS = 0
    BEGIN

	EXEC Company.CreditCardInsert @CreditCardID, @CardNumber, @HolderName, @ExpDate, @CVC_Code, @BillingAddr, @OwnerID;
	   
	
	FETCH NEXT FROM iterateIn INTO @CreditCardID, @CardNumber, @HolderName, @ExpDate, @CVC_Code, @BillingAddr, @OwnerID;
    END
    CLOSE iterateIn
	DEALLOCATE iterateIn;
END
GO


---DELETE CREDIT CARD BELONGING TO CURRENT USER ONLY
CREATE TRIGGER Company.TR_CreditCard_Delete  
ON Company.vwCreditCard
WITH ENCRYPTION 
INSTEAD OF DELETE
AS
BEGIN TRANSACTION CreditCard_Delete

	DELETE Company.CreditCard FROM Company.CreditCard T
		INNER JOIN deleted D
				ON		T.CreditCardID = D.CreditCardID
				WHERE D.OwnerID = USER_NAME()

	IF @@ERROR <> 0 
	BEGIN
			ROLLBACK TRANSACTION CreditCard_Delete
	END ELSE BEGIN
			COMMIT TRANSACTION CreditCard_Delete
	END
GO


---CREATE TRIGGER FOR CREDIT CARD UPDATE ON HOLDERNAME AND BILLING ADDRESS
Create trigger Company.TR_vwCreditCard_Update
ON Company.vwCreditCard
INSTEAD OF UPDATE
AS
	BEGIN
		UPDATE Company.CreditCard SET 
			HolderName = a.HolderName,
			BillingAddr = a.BillingAddr
			from inserted a inner join
			Company.CreditCard b on a.CreditCardID = b.CreditCardID WHERE a.OwnerID = USER_NAME(); 

	END
GO

---Cost Price Encryption
Create Trigger Company.Product_INSERT
ON Company.Product
AFTER INSERT
AS
BEGIN
		DECLARE @ProductID INT;
		DECLARE iterate CURSOR FOR
		 SELECT ProductID
        FROM inserted;

		OPEN iterate
		FETCH NEXT FROM iterate INTO @ProductID
		WHILE @@FETCH_STATUS = 0
		BEGIN

		OPEN SYMMETRIC KEY ProductSymmetricKey  
		DECRYPTION BY CERTIFICATE CompanySignedCertificate; 

			DECLARE @CostPrice varbinary(MAX); 
			SET @CostPrice = (SELECT Cost_Price FROM Company.Product WHERE ProductID = @ProductID);
			SET @CostPrice = (ENCRYPTBYKEY(Key_GUID('ProductSymmetricKey'), @CostPrice));
			UPDATE Company.Product  
			SET [Cost_Price] = @CostPrice
			WHERE ProductID = @ProductID; 

		FETCH NEXT FROM iterate INTO @ProductID
		END
		CLOSE iterate
		DEALLOCATE iterate;
		CLOSE SYMMETRIC KEY ProductSymmetricKey;  
END
GO

--Trigger called to take care of encryption during Cost_Price update
Create Trigger Company.Product_Update
ON Company.Product
AFTER UPDATE
AS
IF UPDATE (Cost_Price)
BEGIN
		DECLARE @ProductID INT;
		DECLARE iterate CURSOR FOR
		 SELECT ProductID
        FROM inserted;

		OPEN iterate
		FETCH NEXT FROM iterate INTO @ProductID
		WHILE @@FETCH_STATUS = 0
		BEGIN

		OPEN SYMMETRIC KEY ProductSymmetricKey  
		DECRYPTION BY CERTIFICATE CompanySignedCertificate; 

			DECLARE @CostPrice varbinary(MAX); 
			SET @CostPrice = (SELECT Cost_Price FROM Company.Product WHERE ProductID = @ProductID);
			SET @CostPrice = (ENCRYPTBYKEY(Key_GUID('ProductSymmetricKey'), @CostPrice));
			UPDATE Company.Product  
			SET [Cost_Price] = @CostPrice
			WHERE ProductID = @ProductID; 

		FETCH NEXT FROM iterate INTO @ProductID
		END
		CLOSE iterate
		DEALLOCATE iterate;
		CLOSE SYMMETRIC KEY ProductSymmetricKey;
END
IF UPDATE (ProductID)
BEGIN
	RAISERROR('Error, you cannot change Primary Key columns', 16, 1)
	ROLLBACK
	RETURN
END
GO

-- Sales Manager can delete only if product Quantity is zero
CREATE TRIGGER Company.TR_Product_Delete  
ON Company.Product
   INSTEAD OF DELETE
AS
	BEGIN TRANSACTION Product_Delete

	IF IS_ROLEMEMBER('SalesManager') = 1
	BEGIN
	DELETE Company.Product FROM Company.Product T
		INNER JOIN deleted D
				ON		T.ProductID = D.ProductID
				WHERE D.Quantity = 0;
	END
	ELSE
	BEGIN
	DELETE Company.Product FROM Company.Product T
		INNER JOIN deleted D
				ON		T.ProductID = D.ProductID
	END
	IF @@ERROR <> 0 
	BEGIN
			ROLLBACK TRANSACTION Product_Delete
	END ELSE BEGIN
			COMMIT TRANSACTION Product_Delete
	END
GO

--No Primary key update
CREATE TRIGGER Company.TR_CreditCard_Update
ON Company.CreditCard
FOR UPDATE
AS
IF UPDATE (CreditCardID)
BEGIN
	RAISERROR('Error, you cannot change Primary Key columns', 16, 1)
	ROLLBACK
	RETURN
END
GO

---No Primary key upadate 
CREATE TRIGGER Company.TR_Customer_Update
ON Company.Customer
FOR UPDATE
AS
IF UPDATE (UserID)
BEGIN
	RAISERROR('Error, you cannot change Primary Key columns', 16, 1)
	ROLLBACK
	RETURN
END
GO

-- 1) Track changes made to the product table


--Trigger to audit update on product table
CREATE TRIGGER TR_AUDIT_Update
ON Company.Product
FOR UPDATE
AS
If Update(Cost_Price)
BEGIN

	OPEN SYMMETRIC KEY ProductSymmetricKey  
	DECRYPTION BY CERTIFICATE CompanySignedCertificate; 
       INSERT INTO ProductAudit (ProductID, oldName, oldQuantity, oldDescription, oldCost_Price, oldSales_Price, oldDiscount, newName, newQuantity, newDescription, newCost_Price, newSales_Price, newDiscount, UserID, LastUpdated)
       SELECT 
           COALESCE(I.ProductID, D.ProductID),
		   D.Name, D.Quantity, D.Description, CONVERT(int, DecryptByKey(D.Cost_Price)), D.Sales_Price, D.Discount,
           I.Name, I.Quantity, I.Description, I.Cost_Price, I.Sales_Price, I.Discount, USER_NAME(), GETDATE()
       FROM 
	  INSERTED I FULL OUTER JOIN DELETED D ON I.ProductID = D.ProductID;
	ClOSE SYMMETRIC KEY ProductSymmetricKey  
END
ELSE
BEGIN
	OPEN SYMMETRIC KEY ProductSymmetricKey  
	DECRYPTION BY CERTIFICATE CompanySignedCertificate; 
       INSERT INTO ProductAudit (ProductID, oldName, oldQuantity, oldDescription, oldCost_Price, oldSales_Price, oldDiscount, newName, newQuantity, newDescription, newCost_Price, newSales_Price, newDiscount, UserID, LastUpdated)
       SELECT 
           COALESCE(I.ProductID, D.ProductID),
		   D.Name, D.Quantity, D.Description, CONVERT(int, DecryptByKey(D.Cost_Price)), D.Sales_Price, D.Discount,
           I.Name, I.Quantity, I.Description, CONVERT(int, DecryptByKey(I.Cost_Price)), I.Sales_Price, I.Discount, USER_NAME(), GETDATE()
       FROM 
	  INSERTED I FULL OUTER JOIN DELETED D ON I.ProductID = D.ProductID;
	ClOSE SYMMETRIC KEY ProductSymmetricKey  

END
GO


--Trigger to audit insert on product table
CREATE TRIGGER TR_AUDIT_Insert
ON Company.Product
FOR INSERT
AS
	BEGIN
			INSERT INTO ProductAudit (ProductID, oldName, oldQuantity, oldDescription, oldCost_Price, oldSales_Price, oldDiscount, newName, newQuantity, newDescription, newCost_Price, newSales_Price, newDiscount, UserID, LastUpdated)
			   SELECT 
				   COALESCE(I.ProductID, D.ProductID),
				   D.Name, D.Quantity, D.Description, D.Cost_Price, D.Sales_Price, D.Discount,
				   I.Name, I.Quantity, I.Description, I.Cost_Price, I.Sales_Price, I.Discount, USER_NAME(), GETDATE()
			   FROM 
			  INSERTED I FULL OUTER JOIN DELETED D ON I.ProductID = D.ProductID;
	END
GO


--Trigger to audit delete on product table
CREATE TRIGGER TR_AUDIT_Delete
ON Company.Product
FOR DELETE
AS
	BEGIN
	OPEN SYMMETRIC KEY ProductSymmetricKey  
	DECRYPTION BY CERTIFICATE CompanySignedCertificate; 
       INSERT INTO ProductAudit (ProductID, oldName, oldQuantity, oldDescription, oldCost_Price, oldSales_Price, oldDiscount, newName, newQuantity, newDescription, newCost_Price, newSales_Price, newDiscount, UserID, LastUpdated)
       SELECT 
           COALESCE(I.ProductID, D.ProductID),
		   D.Name, D.Quantity, D.Description, CONVERT(int, DecryptByKey(D.Cost_Price)), D.Sales_Price, D.Discount,
           I.Name, I.Quantity, I.Description, I.Cost_Price, I.Sales_Price, I.Discount, USER_NAME(), GETDATE()
       FROM 
	  INSERTED I FULL OUTER JOIN DELETED D ON I.ProductID = D.ProductID;
	ClOSE SYMMETRIC KEY ProductSymmetricKey  
	END
GO








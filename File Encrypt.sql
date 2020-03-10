
--Create Master key
CREATE MASTER KEY ENCRYPTION BY  
PASSWORD = 'Password-1'  
GO 

--Create the Symmetric key
CREATE CERTIFICATE SelfSignedCertificate  
WITH SUBJECT = 'Password Encryption';  
GO  

CREATE SYMMETRIC KEY SQLSymmetricKey  
WITH ALGORITHM = AES_128  
ENCRYPTION BY CERTIFICATE SelfSignedCertificate;  
GO  


--Another symmetric for cost price encryption
CREATE CERTIFICATE CompanySignedCertificate  
WITH SUBJECT = 'Password Encrypt';  
GO  

CREATE SYMMETRIC KEY ProductSymmetricKey  
WITH ALGORITHM = AES_128  
ENCRYPTION BY CERTIFICATE CompanySignedCertificate;  
GO  


--encrypted data

USE Ecommerce;  
GO  



---Decrypt CostPrice
OPEN SYMMETRIC KEY ProductSymmetricKey  
DECRYPTION BY CERTIFICATE CompanySignedCertificate; 
SELECT CONVERT(int, DecryptByKey(Cost_Price)) AS Cost_Price FROM Company.Product;


---Decrypt Password
OPEN SYMMETRIC KEY SQLSymmetricKey  
DECRYPTION BY CERTIFICATE SelfSignedCertificate; 
select CONVERT(varchar, DecryptByKey(CONVERT(varbinary(max), Passwrd, 1))) AS Password from Company.Customer;

---Decrypt Credit Card Number
OPEN SYMMETRIC KEY SQLSymmetricKey  
DECRYPTION BY CERTIFICATE SelfSignedCertificate; 
select CONVERT(varchar, DecryptByKey(CONVERT(varbinary(max), CardNumber, 1))) AS CardNumber from Company.CreditCard;




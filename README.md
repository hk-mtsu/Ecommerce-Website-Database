# Ecommerce-Website-Database
 Design and development of a database system to support the online shopping business.
 
 Steps to Run the Files

1. Run "File Schema 1.sql" --Create Database, Schema, tables and views
2. Create Audit folder in C drive : C:\Audit
3. Run "File Auditing 1.sql" -- Enable Server and Database Auditing, Create tracking file 
4. Run "File Object.sql"	--Create Triggers Insert, Update and Delete, stored procedure
5. Run "File Encrypt.sql"  --Create master key, symmetric key and certificates -- Contains decrypt statement as well
6. Run "File Schema 2.sql"  -- Test Data 
7. Run "File Permission.sql" --Create user logins and permission

Test File

Run commands to test scenarios using these two files
8. "File Testing.sql"  -- Testcases (Follow the comments while executing each statement) 
9. "File Auditing 2.sql" -- Testcase for different audit scenarios .. Audit file is stored in C:\Audit\ drive

To drop all data
10. Run "Drop File.sql" --Drop everything



----------------------------------------------------------------  1.  PRODUCT TABLE AUDITING  --------------------------------------------------------------------------


--1) Track changes made to the product table, including information of the user who makes the change and data before and after the change.
--ON INSERT OLD VALUES ARE NULL
--ON UPDATE Both new and old value is displayed 
--ON DELETE OLD deleted value is shown new value is null
Use Ecommerce 
Go 
SELECT ProductID, oldName, oldQuantity, oldDescription, CONVERT(INT, oldCost_Price) AS Old_CostPrice, oldSales_Price, oldDiscount, 
	newName, newQuantity, newDescription, CONVERT(INT, newCost_Price) AS New_CostPrice, newSales_Price, newDiscount, UserID , LastUpdated
	FROM Company.ProductAudit
	Order by LastUpdated desc;


-------------------------------------------------------- 2.  GRANT/REVOKE/DENY  ---------------------------------------------------------


--2 )Track any permission changes by GRANT/REVOKE/DENY statements.

--Grant (Action_ID = G) --Revoke (Action_ID = R) --Deny (Action_ID = D)

--General info with few important columns
SELECT database_principal_name as Grantor ,target_database_principal_name as Grantee, database_name, schema_name, object_name, statement, action_id 
FROM sys.fn_get_audit_file ('C:\Audit\Login_Audit_8294917C-3823-41CD-BD98-889D7CA5513A_0_132002014622410000*',default,default)
WHERE action_id In ('G', 'R', 'D') 

--Full session info with all the colums
SELECT * FROM sys.fn_get_audit_file ('C:\Audit\Login_Audit_8294917C-3823-41CD-BD98-889D7CA5513A_0_132002014622410000*',default,default)
WHERE action_id In ('G', 'R', 'D')  


--2) Another way to track any permission changes by GRANT/REVOKE/DENY statements.
select permission_name, 
       state_desc, 
       type_desc,
	   T.modify_date,
       U.name GranteeName, 
       U2.name GrantorName, 
       OBJECT_NAME(major_id) AS ObjectName
  from sys.database_permissions P  
       JOIN sys.tables T ON P.major_id = T.object_id 
       JOIN sysusers U ON U.uid = P.grantee_principal_id
       JOIN sysusers U2 ON U2.uid = P.grantor_principal_id
  ORDER BY t.modify_date;

----------------------------------------------- 3. FAILED/SUCCESSFUL LOGINS   -----------------------------------------------------

--3) Audit successful/failed login and logout events.  

-----3.1) FAILED LOGIN

--------------------------------------    FAILED LOGIN(action_id = 'LGIF') and SUCCESSFUL LOGIN(action_id = 'LGIS') ------------------------------- 
select TOP(1000) *
from fn_get_audit_file('C:\Audit\Login_Audit_8294917C-3823-41CD-BD98-889D7CA5513A_0_132002014622410000*',NULL,null)
WHERE action_id = 'LGIF'
order by event_time desc, sequence_number

select TOP(1000) *
from fn_get_audit_file('C:\Audit\Login_Audit_8294917C-3823-41CD-BD98-889D7CA5513A_0_132002014622410000*',NULL,null)
WHERE action_id = 'LGIS'
order by event_time desc, sequence_number

--------------------------------------    Session information of user   -----------------------------

--3.2) Session information of USER S01 

SELECT * FROM fn_get_audit_file('C:\Audit\Login_Audit_8294917C-3823-41CD-BD98-889D7CA5513A_0_132002014622410000*',NULL,null)
WHERE server_principal_name = 'S01'
order by event_time desc, sequence_number

--Successful Login event
SELECT Top 1 * FROM fn_get_audit_file('C:\Audit\Login_Audit_8294917C-3823-41CD-BD98-889D7CA5513A_0_132002014622410000*',NULL,null)
WHERE server_principal_name = 'S01' AND action_id = 'LGIS'
order by event_time desc, sequence_number

--Successful Logout event
--see logout time (LGO) of S01
SELECT Top 1 * FROM fn_get_audit_file('C:\Audit\Login_Audit_8294917C-3823-41CD-BD98-889D7CA5513A_0_132002014622410000*',NULL,null) 
WHERE server_principal_name = 'S01' AND (action_id = 'LG0')
order by event_time desc, sequence_number


--------------------------------------------------  Tracking Login - Logout Session  ----------------------------------------------------------
---3. Tracking all Session information from Login to Logout

--All the session event is tracked (EventClass 15 is Logout event and EventClass 14 is Login event)

SELECT NTUserName, ApplicationName, LoginName, SPID, Duration, StartTime, EndTime, ServerName, EventClass, LoginSid
FROM fn_trace_gettable('C:\Audit\SessionTracking.trc', default)
where (EventClass = 14 or EventClass = 15) and loginName = 'S01' --Change login name for different users
order by EndTime desc, StartTime desc ;
GO 


--Another way to find user session information
SELECT top(1) login_time As Logon,login_name, *
FROM sys.dm_exec_sessions
where login_name = 'C01'
order by session_id desc





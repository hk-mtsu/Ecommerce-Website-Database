
--------------------------------------------------------  LOGIN AUDIT ENABLING---------------------------------------------------------
Use Master
Go

--Enable Auditing and Creating a log file 
CREATE SERVER AUDIT [Login_Audit]
TO FILE
( FILEPATH = N'C:\Audit'
,MAXSIZE = 0 MB
,MAX_ROLLOVER_FILES = 2147483647
,RESERVE_DISK_SPACE = OFF
)
WITH
( QUEUE_DELAY = 1000
  ,ON_FAILURE = CONTINUE
)
GO

ALTER SERVER AUDIT [Login_Audit]
WITH (STATE = ON)
GO

CREATE SERVER AUDIT SPECIFICATION
[ServerAuditSpecification-LoginAudit]
FOR SERVER AUDIT [Login_Audit]
ADD (FAILED_LOGIN_GROUP),
ADD (SUCCESSFUL_LOGIN_GROUP),
ADD (LOGOUT_GROUP)

ALTER SERVER AUDIT SPECIFICATION
[ServerAuditSpecification-LoginAudit]
WITH (STATE = ON)


------------------------------------------------------------------------- GRANT/REVOKE/DENY Enable-------------------------
--CREATE DATABASE AUDIT FOR PERMISSION CHANGE
USE Ecommerce;
GO
CREATE DATABASE AUDIT SPECIFICATION [ServerAuditSpecification-LoginAudit]
FOR SERVER AUDIT [Login_Audit]
ADD (SCHEMA_OBJECT_PERMISSION_CHANGE_GROUP)
WITH (STATE = ON);
GO


-----------------------------------------------------------------    Tracking Session   --------------------------------------

DECLARE @RC int, @TraceID int, @on BIT  
EXEC @rc = sp_trace_create @TraceID output, 0, N'C:\Audit\SessionTracking'  
  
-- Select the return code to see if the trace creation was successful.  
SELECT RC = @RC, TraceID = @TraceID  
  
-- Set the events and data columns you need to capture.  
SELECT @on = 1  
  
  
EXEC SP_TRACE_SETEVENT @TraceID, 14, 6, @on -- NTUserName
EXEC SP_TRACE_SETEVENT @TraceID, 14, 10, @on -- ApplicationName
EXEC SP_TRACE_SETEVENT @TraceID, 14, 11, @on -- LoginName
EXEC SP_TRACE_SETEVENT @TraceID, 14, 14, @on -- StartTime
EXEC SP_TRACE_SETEVENT @TraceID, 14, 41, @on -- LoginSid
EXEC SP_TRACE_SETEVENT @TraceID, 14, 64, @on -- SessionLoginName


------ Audit Logout
------ Occurs when a user logs out of SQL Server.

EXEC SP_TRACE_SETEVENT @TraceID, 15, 6, @on -- NTUserName
EXEC SP_TRACE_SETEVENT @TraceID, 15, 10, @on -- ApplicationName
EXEC SP_TRACE_SETEVENT @TraceID, 15, 11, @on -- LoginName
EXEC SP_TRACE_SETEVENT @TraceID, 15, 13, @on -- Duration
EXEC SP_TRACE_SETEVENT @TraceID, 15, 15, @on -- EndTime
EXEC SP_TRACE_SETEVENT @TraceID, 15, 41, @on -- LoginSid
EXEC SP_TRACE_SETEVENT @TraceID, 15, 64, @on -- SessionLoginName
 
EXEC @RC = sp_trace_setstatus @TraceID, 1  
GO  


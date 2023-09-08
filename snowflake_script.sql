CREATE OR REPLACE PROCEDURE reader_from_actions()
  RETURNS STRING
  LANGUAGE SQL
  EXECUTE AS CALLER
AS
$$
DECLARE
  RESULT STRING;
  SQL_STMT STRING;
  LOCATOR STRING;

BEGIN
  -- Create a managed account
  SQL_STMT := 'CREATE MANAGED ACCOUNT MANAGED_ACCOUNT12445599 
               ADMIN_NAME = ''ADMIN'' 
               ADMIN_PASSWORD = ''Welcome@123'' 
               TYPE = READER';
  EXECUTE IMMEDIATE SQL_STMT;

  -- Insert data into reader_details
  SQL_STMT := 'INSERT INTO GH_ACTIONS_DB.GH_ACTIONS_SCM.reader_details 
               (reader_account_details, cust_name, add_time_stamp) 
               SELECT PARSE_JSON($1), ''YourCustomerName'', CURRENT_TIMESTAMP() 
               FROM TABLE(result_scan(LAST_QUERY_ID()))';
  EXECUTE IMMEDIATE SQL_STMT;

  -- Fetch the first accountLocator
  LOCATOR := (
    SELECT reader_account_details:accountLocator
    FROM GH_ACTIONS_DB.GH_ACTIONS_SCM.reader_details
     order by add_time_stamp desc LIMIT 1
  );

  -- Create or replace a share
  SQL_STMT := 'CREATE OR REPLACE SHARE CUST_SHARE';
  EXECUTE IMMEDIATE SQL_STMT;

  -- Grant USAGE on DATABASE
  SQL_STMT := 'GRANT USAGE ON DATABASE GH_ACTIONS_DB TO SHARE CUST_SHARE';
  EXECUTE IMMEDIATE SQL_STMT;

  -- Grant USAGE on SCHEMA
  SQL_STMT := 'GRANT USAGE ON SCHEMA GH_ACTIONS_DB.GH_ACTIONS_SCM TO SHARE CUST_SHARE';
  EXECUTE IMMEDIATE SQL_STMT;
  SQL_STMT := 'GRANT SELECT ON ALL TABLES IN SCHEMA GH_ACTIONS_DB.GH_ACTIONS_SCM TO SHARE CUST_SHARE';
  EXECUTE IMMEDIATE SQL_STMT;

  -- Alter the share and add the account without quotes
  SQL_STMT := 'ALTER SHARE CUST_SHARE ADD ACCOUNT = ' || LOCATOR || '';
  EXECUTE IMMEDIATE SQL_STMT;

  RESULT := 'Reader Account, Share has been created, and reader account has been added to the Share';

  RETURN RESULT;
END;
$$;
call reader_from_actions();

CREATE OR REPLACE PROCEDURE &{CUST_RAW_DB}.&{CUST_SCHEMA}.reader_from_actions()
  RETURNS STRING
  LANGUAGE SQL
  EXECUTE AS CALLER
AS
$$
DECLARE
  RESULT STRING;
  SQL_STMT STRING;
  LOCATOR STRING;
  READER_NAME STRING;
  SHARE_NAME STRING;
BEGIN
  READER_NAME := '&{CUST_NAME}' || '_READER';
  SHARE_NAME := '&{CUST_NAME}' || '_SHARE';

  SQL_STMT := 'CREATE MANAGED ACCOUNT ' || READER_NAME || '
               ADMIN_NAME = ''ADMIN'' ADMIN_PASSWORD = ''Welcome@123'' TYPE = READER';
  EXECUTE IMMEDIATE SQL_STMT;
  
  SQL_STMT := 'INSERT INTO &{CUST_RAW_DB}.&{CUST_SCHEMA}.reader_details 
               (reader_account_details,cust_name,add_time_stamp) 
               SELECT PARSE_JSON($1),${CUST_NAME}, CURRENT_TIMESTAMP() 
               FROM TABLE(result_scan(LAST_QUERY_ID()))';
  EXECUTE IMMEDIATE SQL_STMT;

  LOCATOR := (
    SELECT reader_account_details:accountLocator
    FROM &{CUST_RAW_DB}.&{CUST_SCHEMA}.reader_details
    ORDER BY add_time_stamp DESC LIMIT 1
  );

  SQL_STMT := 'CREATE OR REPLACE SHARE ' || SHARE_NAME;
  EXECUTE IMMEDIATE SQL_STMT;

  SQL_STMT := 'GRANT USAGE ON DATABASE &{CUST_RAW_DB} TO SHARE ' || SHARE_NAME;
  EXECUTE IMMEDIATE SQL_STMT;

  SQL_STMT := 'GRANT USAGE ON SCHEMA &{CUST_RAW_DB}.&{CUST_SCHEMA} TO SHARE ' || SHARE_NAME;
  EXECUTE IMMEDIATE SQL_STMT;

  SQL_STMT := 'GRANT SELECT ON ALL TABLES IN SCHEMA &{CUST_RAW_DB}.&{CUST_SCHEMA} TO SHARE ' || SHARE_NAME;
  EXECUTE IMMEDIATE SQL_STMT;

  SQL_STMT := 'ALTER SHARE ' || SHARE_NAME || ' ADD ACCOUNT =  '|| LOCATOR ||'';
  EXECUTE IMMEDIATE SQL_STMT;

  RESULT := 'Reader Account, Share has been created, and reader account has been added to the Share';
  RETURN RESULT;
END;
$$;

CALL &{CUST_RAW_DB}.&{CUST_SCHEMA}.reader_from_actions();

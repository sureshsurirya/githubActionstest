#use role accountadmin;
#CREATE DATABASE ADVARRA_ONCORE_RAW FROM SHARE &{MAIN_LOCATOR}.&{CUST_NAME} ||_SHARE;
#Define the variables using SET
SET MAIN_LOCATOR = '&{MAIN_LOCATOR}';
SET CUST_NAME = '&{CUST_NAME}';
SET SHARE = :MAIN_LOCATOR || :CUST_NAME || '_SHARE';
#Use the variables in your SQL query
USE ROLE ACCOUNTADMIN;
CREATE DATABASE ADVARRA_ONCORE_RAW FROM SHARE :SHARE;


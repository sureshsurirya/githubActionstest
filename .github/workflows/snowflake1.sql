CREATE OR REPLACE PROCEDURE CREATE_SAMPLE_TABLE()
RETURNS STRING
LANGUAGE SQL
EXECUTE AS CALLER
AS
$$
BEGIN
    -- Create a sample table named "my_sample_table"
    CREATE OR REPLACE TABLE Actions (id INT,name STRING,age INT);

    -- Return a success message
    RETURN 'Sample table created successfully.';
END;
$$;

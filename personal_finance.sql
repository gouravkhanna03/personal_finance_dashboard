/* Table Creation */


/* Table Source has Income and Expense */

CREATE TABLE source(
                source_id INT PRIMARY KEY,
                source_name VARCHAR(9)
								 );

/* Table Category categories and a relation with source */

CREATE TABLE category(
                  category_id INT PRIMARY KEY,
									category_name VARCHAR(13),
									source_id INT REFERENCES source(source_id)
									);

/* Table Finance is a fact table everything connected with it */

CREATE TABLE finance(
									 transaction_id SERIAL PRIMARY KEY,
									 transaction_date TIMESTAMP(0) DEFAULT CURRENT_TIMESTAMP,
									 amount NUMERIC(5, 2),
									 transaction_type VARCHAR(9) NOT NULL,
									 note TEXT,
									 source_id INT NOT NULL REFERENCES source(source_id),
									 category_id INT NOT NULL REFERENCES category(category_id)
                  );


/* Table audit_log is a additional table to display actions like: Update, Restore, Delete's */

CREATE TABLE audit_log(
									audit_id SERIAL PRIMARY KEY,
									action TEXT NOT NULL,
									transaction_id INT NOT NULL,	
									old_transaction_date TIMESTAMP,
									new_transaction_date TIMESTAMP,
									old_amount NUMERIC(12, 2),
									new_amount NUMERIC(12, 2),
									old_category INT,
									new_category INT,
									old_source INT,
									new_source INT,
									old_transaction_type VARCHAR(9),
									old_transaction_type VARCHAR(9),
									changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
								 )
								 

/* Tabel Archive also a additional table that has deleted values of finance table */

CREATE TABLE archive (
                  archieve_id SERIAL PRIMARY KEY,
									transaction_id INT NOT NULL REFERENCES finance(transaction_id),
								  transaction_date TIMESTAMP(0) DEFAULT CURRENT_TIMESTAMP,
								  amount NUMERIC(5, 2),
								  transaction_type VARCHAR(9) NOT NULL,
								  note TEXT,
								  source_id INT NOT NULL REFERENCES source(source_id),
								  category_id INT NOT NULL REFERENCES category(category_id),
									deletion_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
								 );



-- Table audit_calender it shares a many to many relationship with audit_log

CREATE OR REPLACE VIEW audit_calender AS (
SELECT audit_id,
       changed_at,
       EXTRACT(MONTH FROM changed_at)::INT AS month,
			 EXTRACT(YEAR FROM changed_at)::INT AS year,
			 TO_CHAR(changed_at, 'Mon')::TEXT AS month_name,
			 TO_CHAR(changed_at, 'YYYY-MM')::TEXT AS month_year
FROM audit_log
);



-- Table finance_calender it shares a many to many relationship with finance
CREATE OR REPLACE VIEW finace_calender AS (
SELECT transaction_id,
       transaction_date,
       EXTRACT(MONTH FROM transaction_date)::INT AS month,
			 EXTRACT(YEAR FROM transaction_date)::INT AS year,
			 TO_CHAR(transaction_date, 'Mon')::TEXT AS month_name,
			 TO_CHAR(transaction_date, 'YYYY-MM')::TEXT AS month_year,
			 transaction_date::DATE AS trans_date
FROM finance
);


-- Only these types you can add on finance TABLE
ALTER TABLE finance
ADD CONSTRAINT transaction_type CHECK(transaction_type IN ('Cash', 'Accounts'));


-- You can''t add additional text's apart from these 
ALTER TABLE finance
ADD CONSTRAINT source_name CHECK(source_name IN ('Income', 'Expense'));

-- You can''t add additional text's apart from these
ALTER TABLE finance
ADD CONSTRAINT category_name CHECK(category_name IN ('Donation', 'Bill', 'Salary', 'Grooming', 'Health', 
                                                      'Food', 'Clothe', 'Saving', 'Bonus', 'Communication',
																											'Household', 'Pet'));

-- It let's to enter big digit value's
ALTER TABLE finance
ALTER COLUMN amount TYPE NUMERIC(12, 2);



-- new source can't be NULL
ALTER TABLE source
ALTER COLUMN source_name SET NOT NULL;

-- new category can't be NULL
ALTER TABLE category
ALTER COLUMN category_name SET NOT NULL;

-- You can't enter zero or less than value
ALTER TABLE finance
ADD CONSTRAINT amount CHECK (amount > 0);


-- source and category table's PK should be UNIQUE
ALTER TABLE category
ADD CONSTRAINT uq_category_source
UNIQUE (category_id, source_id);










-- For archive amount COLUMN

ALTER TABLE archive
ALTER COLUMN amount TYPE NUMERIC(12,2);



/* Trigger and Function for Delete audit_log and archive table */



CREATE OR REPLACE FUNCTION fun_delete_from_finance()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS $$
BEGIN 


        IF EXISTS (SELECT 1
				           FROM audit_log
									 WHERE transaction_id = OLD.transaction_id
									 AND action = 'DELETE'
									 )
				THEN RAISE EXCEPTION 'transaction: % has been already deleted', OLD.transaction_id;

        ELSE

        INSERT INTO archive(transaction_id, transaction_date, amount, transaction_type, note, source_id, category_id)
				              VALUES(OLD.transaction_id, OLD.transaction_date, OLD.amount, OLD.transaction_type, OLD.note,
											        OLD.source_id, OLD.category_id);

				INSERT INTO audit_log(action, transaction_id, old_amount, new_amount, old_category, new_category, old_source_id,
				                      new_source_id, old_transaction_type, new_transaction_type, old_transaction_date, new_transaction_date)
				               VALUES('DELETE', OLD.transaction_id, OLD.amount, NULL, OLD.category_id, NULL, OLD.source_id, NULL, 
															 OLD.transaction_type, NULL, OLD.transaction_date, NULL);


				RAISE NOTICE 'transaction: % has been successfully deleted and a copy of same moved to Archieve table as well as audit_log', 
				                OLD.transaction_id;

        END IF;
				
       RETURN OLD;
 END;
$$;



CREATE OR REPLACE TRIGGER trg_delete_from_finance
BEFORE DELETE ON finance
FOR EACH ROW
EXECUTE FUNCTION fun_delete_from_finance();




/* Trigger and Function to Update audit_log table */


CREATE OR REPLACE FUNCTION fun_update_from_finance()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS $$
BEGIN 

       
				INSERT INTO audit_log(action, transaction_id, old_amount, new_amount, old_category, new_category, old_source_id,
				                      new_source_id, old_transaction_type, new_transaction_type, old_transaction_date, new_transaction_date)
				               VALUES('UPDATE', OLD.transaction_id, OLD.amount, CASE WHEN OLD.amount = NEW.amount THEN NULL ELSE NEW.amount END, 
											         OLD.category_id, CASE WHEN OLD.category_id = NEW.category_id THEN NULL ELSE NEW.category_id END, 
															 OLD.source_id, CASE WHEN OLD.source_id = NEW.source_id THEN NULL ELSE NEW.source_id END, 
															 OLD.transaction_type, CASE WHEN OLD.transaction_type = NEW.transaction_type THEN NULL ELSE NEW.transaction_type END, 
															 OLD.transaction_date, CASE WHEN OLD.transaction_date = NEW.transaction_date THEN NULL ELSE NEW.transaction_date END);


        RETURN NEW;
END;
$$;



CREATE OR REPLACE TRIGGER trg_update_from_finance
AFTER UPDATE ON finance
FOR EACH ROW EXECUTE
FUNCTION fun_update_from_finance();




/* Set Threshold Limit for a month. If equal to or above 50,000 show error */



CREATE OR REPLACE FUNCTION fun_threshold_amount()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
 v_month_year TEXT;
 v_amount NUMERIC(12, 2);
BEGIN


		 SELECT COALESCE(SUM(amount), 0),
		        TO_CHAR(NEW.transaction_date, 'YYYY-Month') INTO v_amount, v_month_year
		 FROM finance
		 WHERE source_id = 1
		 AND DATE_TRUNC('month', transaction_date) = DATE_TRUNC('month', NEW.transaction_date)
		 AND DATE_TRUNC('year',  transaction_date) =  DATE_TRUNC('year', NEW.transaction_date);
	      

     IF v_amount >= 50000
     THEN RAISE NOTICE 'Spent: % for the month: %, It''s more than the threshold limit!', v_amount, v_month_year;
     END IF;

		 RETURN NEW;
END;
$$;
		 


CREATE OR REPLACE TRIGGER trg_insert_threshold_limit_finance
AFTER INSERT ON finance
FOR EACH ROW EXECUTE
FUNCTION fun_threshold_amount();



/* Function to restore deleted transaction's, Only works with APP */


CREATE OR REPLACE FUNCTION fun_restore_transaction(p_transaction_id INT)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_new_transaction_id INT;
    v_archive_row archive%ROWTYPE;
BEGIN

    -- Find the deleted transaction in archive
    SELECT *
    INTO v_archive_row
    FROM archive
    WHERE transaction_id = p_transaction_id
    ORDER BY deletion_time DESC
    LIMIT 1;

    IF NOT FOUND THEN
        RAISE EXCEPTION
            'transaction_id: % not found in archive or it has already been restored!',
            p_transaction_id;
    END IF;

    -- Re-insert as a new transaction
    INSERT INTO finance(
        transaction_date,
        amount,
        transaction_type,
        note,
        source_id,
        category_id
    )
    VALUES(
        v_archive_row.transaction_date,
        v_archive_row.amount,
        v_archive_row.transaction_type,
        v_archive_row.note,
        v_archive_row.source_id,
        v_archive_row.category_id
    )
    RETURNING transaction_id
    INTO v_new_transaction_id;

    -- Log the restore action
    INSERT INTO audit_log(
        action,
        transaction_id,
        new_amount,
        new_category,
        new_source_id,
        new_transaction_type,
        new_transaction_date
    )
    VALUES(
        'RESTORE',
        v_new_transaction_id,
        v_archive_row.amount,
        v_archive_row.category_id,
        v_archive_row.source_id,
        v_archive_row.transaction_type,
        v_archive_row.transaction_date
    );

    -- Remove restored transaction from archive
    DELETE FROM archive
    WHERE transaction_id = p_transaction_id;

    RAISE NOTICE
        'Original transaction_id: % has been successfully restored as new transaction_id: %.',
        p_transaction_id,
        v_new_transaction_id;

    RAISE NOTICE
        'Original transaction_id: % has been deleted from archive.',
        p_transaction_id;

    RETURN v_new_transaction_id;

END;
$$;


/* Highest Savings This Year Month */


WITH income_expense AS (
SELECT DATE_TRUNC('Month', transaction_date) AS mm,
       SUM(amount) FILTER (WHERE source_id = 1) AS expense,
			 SUM(amount) FILTER (WHERE source_id = 2) AS income
FROM finance
WHERE DATE_TRUNC('Year', transaction_date) = DATE_TRUNC('Year', CURRENT_DATE)
GROUP BY DATE_TRUNC('Month', transaction_date)
)
SELECT TO_CHAR(mm, 'MM-YYYY') month_year,
       FIRST_VALUE(income - expense) OVER(ORDER BY (income - expense) DESC) AS savings
FROM income_expense
LIMIT 1



/* INSERT INTO FINANCE */


INSERT INTO finance(amount, transaction_type, note, source_id, category_id)
              VALUES(52.55, 'Accounts', 'Bank Charges ICICI Sms', 1, 2);



-- Update NEW and Same OLD values to NEW values NULL

BEGIN;

UPDATE audit_log
SET new_amount = CASE WHEN old_amount = new_amount THEN NULL ELSE new_amount END,
new_category = CASE WHEN old_category = new_category THEN NULL ELSE new_category END,
new_source_id = CASE WHEN old_source_id = new_source_id THEN NULL ELSE new_source_id END,
new_transaction_type = CASE WHEN old_transaction_type = new_transaction_type THEN NULL ELSE new_transaction_type END,
new_transaction_date = CASE WHEN old_transaction_date = new_transaction_date THEN NULL ELSE new_transaction_date END
WHERE action = 'UPDATE';


ROLLBACK;

COMMIT;




--- Current year Income vs Previous Year

WITH current AS (
SELECT SUM(amount) AS current_year
FROM finance
WHERE source_id = 2
AND EXTRACT(YEAR from transaction_date) = EXTRACT(YEAR FROM CURRENT_DATE)
),
previous AS (
SELECT SUM(amount) AS previous_year
FROM finance
WHERE source_id = 2
AND EXTRACT(YEAR from transaction_date) = EXTRACT(YEAR FROM CURRENT_DATE)-1
)
SELECT *
FROM current AS c
CROSS JOIN previous;



----------------------------------------------------------------------------------------------------------------------------------------


SELECT *
FROM finance;

SELECT *
FROM category;

SELECT *
FROM source;

SELECT *
FROM audit_log;

SELECT *
FROM archive;

SELECT *
FROM audit_calender;

SELECT *
FROM finace_calender;

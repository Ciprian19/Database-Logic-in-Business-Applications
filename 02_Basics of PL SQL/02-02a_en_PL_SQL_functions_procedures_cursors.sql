------------------------------------------------------------------------
--          Simple examples of functions, procedures and cursors
------------------------------------------------------------------------

------------------------------------------------------------------------
-- next function returns VAT percent for a given product (identified by code)
CREATE OR REPLACE FUNCTION f_vat_percent (product_id_ products.product_id%TYPE) 
	RETURN products.VAT_percent%TYPE 
AS
	v_VAT_percent products.VAT_percent%TYPE ;
BEGIN
	SELECT VAT_percent INTO v_VAT_percent FROM products WHERE product_id = product_id_ ;
	RETURN v_VAT_percent ;
END ;
/

-- tests
SELECT f_vat_percent(1) FROM dual
/
SELECT f_vat_percent(999999) FROM dual
/

------------------------------------------------------------------------
-- the same function but with EXCEPTION section
CREATE OR REPLACE FUNCTION f_vat_percent (product_id_ products.product_id%TYPE) 
	RETURN products.VAT_percent%TYPE 
AS
	v_VAT_percent products.VAT_percent%TYPE ;
BEGIN
	SELECT VAT_percent INTO v_VAT_percent FROM products WHERE product_id = product_id_ ;
	RETURN v_VAT_percent ;
EXCEPTION
	WHEN NO_DATA_FOUND THEN 
		RETURN 0;
	WHEN OTHERS THEN 
		RETURN NULL ;
END ;
/

-- tests
SELECT f_vat_percent(1) FROM dual
/

SELECT f_vat_percent(999999) FROM dual
/


------------------------------------------------------------------------
-- function that computes total amount (included valued-added tax -VAT) 
--     for a given invoice 
CREATE OR REPLACE FUNCTION f_total_invoice (invoice_no_ invoices.invoice_no%TYPE)
	RETURN NUMERIC 
AS
	v_amount NUMERIC(14,2) ;
BEGIN
	SELECT COALESCE(SUM(quantity * unit_price * (1 + f_vat_percent(product_id))) ,0)
		INTO v_amount FROM invoice_details WHERE invoice_no = invoice_no_ ;
	RETURN v_amount ;
EXCEPTION
	WHEN NO_DATA_FOUND THEN 
		RETURN 0;
	WHEN OTHERS THEN 
		RETURN NULL ;
END ;
/

-- tests
SELECT f_total_invoice(1111) FROM dual
/
SELECT f_total_invoice(1112) FROM dual
/
SELECT f_total_invoice(89899) FROM dual
/


-----------------------------------------------------------------------------
-- function that computes, for a given invoice, the cumulative amount of all
--   preceding invoices     

CREATE OR REPLACE FUNCTION f_cumulative_preced (invoice_no_ invoices.invoice_no%TYPE)
	RETURN NUMERIC 
AS
	v_amount NUMERIC(16,2) ;
BEGIN
    SELECT COALESCE(SUM(quantity * unit_price * (1 + f_vat_percent(product_id))) ,0)
		INTO v_amount FROM invoice_details WHERE invoice_no < invoice_no_ ;
	RETURN v_amount ;
EXCEPTION
	WHEN NO_DATA_FOUND THEN 
		RETURN 0;
	WHEN OTHERS THEN 
		RETURN NULL ;
END ;


-- test
SELECT f_cumulative_preced(1111) FROM dual
/
SELECT f_cumulative_preced(1112) FROM dual
/
SELECT f_cumulative_preced(1113) FROM dual
/
SELECT f_cumulative_preced(1) FROM dual
/
SELECT f_cumulative_preced(3333) FROM dual
/

invoice_no_



------------------------------------------------------------------------------------------------
-- a procedure that displays, for a given (current) invoice, 
--    the invoice amount and the cumulative
--     amount of current invoice and all preceding invoices 
-- explicit cursor usage - syntax 1
CREATE OR REPLACE PROCEDURE p_amount_preceding (invoice_no_ invoices.invoice_no%TYPE)
IS
    -- cursor declaration
	CURSOR c_invoices IS 
        SELECT invoice_no, invoice_date, f_total_invoice(invoice_no) AS amount
		FROM invoices 
		WHERE invoice_no <= invoice_no_ 
		ORDER BY 1;
		
    rec_invoice c_invoices%ROWTYPE ;
	v_total NUMBER(16,2) := 0 ;
	
BEGIN 
    -- open the cursor
	OPEN c_invoices ;
	
	-- fetch the first record of the cursor
	FETCH c_invoices INTO rec_invoice ;
	LOOP 
	    -- exit from the loop when there are no more records in the cursor
		EXIT WHEN c_invoices%NOTFOUND ;
		
		-- increment the amount of preceding invoices
		v_total := v_total + NVL(rec_invoice.amount,0) ;
		
		-- display the two amounts for each preceding invoice
		DBMS_OUTPUT.PUT_LINE (rec_invoice.invoice_no || ' - ' || rec_invoice.invoice_date || 
			' - ' || TO_CHAR(NVL(rec_invoice.amount,0), '999999999999.99') || ' - ' || 
			TO_CHAR(v_total, '999999999999.99') ) ;
		
		-- fetch next record of the cursor
		FETCH c_invoices INTO rec_invoice ;						
	END LOOP ;
	
	-- close the cursor
	CLOSE c_invoices ;
		
END ;
/


-- tests
EXECUTE p_amount_preceding(1111)

EXECUTE p_amount_preceding(1112)

EXECUTE p_amount_preceding(1113)

EXECUTE p_amount_preceding(1)

EXECUTE p_amount_preceding(3333)


------------------------------------------------------------------------------------------------
-- a procedure that displays, for a given (current) invoice, 
--    the invoice amount and the cumulative
--     amount of current invoice and all preceding invoices 
-- explicit cursor usage - syntax 2
CREATE OR REPLACE PROCEDURE p_amount_preceding_2 (invoice_no_ invoices.invoice_no%TYPE)
IS
    -- cursor declaration is postponed to the moment of its opening
		
	-- no need to declare the row variable assigned to an invoice	
    --  rec_invoice c_invoices%ROWTYPE ;
	
	v_total NUMBER(16,2) := 0 ;
	
BEGIN 
    -- a FOR loop automatically opens the cursor, loops through its records and closes it
    FOR rec_invoice IN (
        SELECT invoice_no, invoice_date, f_total_invoice(invoice_no) AS amount
		FROM invoices 
		WHERE invoice_no <= invoice_no_)    LOOP
		
    		-- increment the amount of preceding invoices
	    	v_total := v_total + NVL(rec_invoice.amount,0) ;

    		-- display the two amounts for each preceding invoice
	    	DBMS_OUTPUT.PUT_LINE (rec_invoice.invoice_no || ' - ' || rec_invoice.invoice_date || 
		    	' - ' || TO_CHAR(NVL(rec_invoice.amount,0), '999999999999.99') || ' - ' || 
			    TO_CHAR(v_total, '999999999999.99') ) ;
	END LOOP ;
END ;
/


-- tests
EXECUTE p_amount_preceding_2(1111)

EXECUTE p_amount_preceding_2(1112)

EXECUTE p_amount_preceding_2(1113)

EXECUTE p_amount_preceding_2(1)

EXECUTE p_amount_preceding_2(3333)












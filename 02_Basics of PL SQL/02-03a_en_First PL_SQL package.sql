--------------------------------------------------------------
--      First PL/SQL package gathers previously created
--   independent functions and procedures (and some other new)
--------------------------------------------------------------

--------------------------------------------------------------
-- package signature (declaration or specifications)
CREATE OR REPLACE PACKAGE pac_sales AS

    -- this is a public variabile (at session level)
	v_trg_invoice_details BOOLEAN := FALSE ;

    -- this is a public cursor (at session level, too) 
    CURSOR c_invoices IS 
	    SELECT i.invoice_no, i.invoice_date FROM invoices i ;

    -- two overloading functions: first was already discussed...
    FUNCTION f_vat_percent (product_id_ products.product_id%TYPE) 
	    RETURN products.VAT_percent%TYPE  ;

    -- ...the second one gets a product name (which is also unique) and
    --     returns the VAT percent of that product
    FUNCTION f_vat_percent (product_name_ products.product_name%TYPE) 
	    RETURN products.VAT_percent%TYPE  ;
	
    -- a procedure that displays, for a given (current) invoice, the invoice 
    --   amount and the cumulative amount of current invoice and all preceding invoices 
    FUNCTION f_total_invoice (invoice_no_ invoices.invoice_no%TYPE)
	    RETURN NUMERIC ;

    -- function that computes, for a given invoice, the cumulative amount of all
    --   preceding invoices     
    FUNCTION f_cumulative_preced (invoice_no_ invoices.invoice_no%TYPE)
	    RETURN NUMERIC ;

    -- a procedure that displays, for a given invoice, 
    --    the amount of all the preceding invoices and the cumulative
    --     amount for every preceding invoice
    PROCEDURE p_amount_preceding (invoice_no_ invoices.invoice_no%TYPE) ;

END ; -- end of package specifications
/


-- package body
--------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY pac_sales AS
--------------------------------------------------------------

--------------------------------------------------------------
FUNCTION f_vat_percent (product_id_ products.product_id%TYPE) 
	RETURN products.VAT_percent%TYPE 
IS
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

--------------------------------------------------------------
FUNCTION f_vat_percent (product_name_ products.product_name%TYPE) 
	RETURN products.VAT_percent%TYPE 
IS
	v_VAT_percent products.VAT_percent%TYPE ;
BEGIN
	SELECT VAT_percent INTO v_VAT_percent FROM products WHERE product_name = product_name_ ;
	RETURN v_VAT_percent ;
EXCEPTION
	WHEN NO_DATA_FOUND THEN 
		RETURN 0;
	WHEN OTHERS THEN 
		RETURN NULL ;
END ;

------------------------------------------------------------------------
FUNCTION f_total_invoice (invoice_no_ invoices.invoice_no%TYPE)
	RETURN NUMERIC 
IS
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



-----------------------------------------------------------------------------
FUNCTION f_cumulative_preced (invoice_no_ invoices.invoice_no%TYPE)
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

------------------------------------------------------------------------------------------------
PROCEDURE p_amount_preceding (invoice_no_ invoices.invoice_no%TYPE)
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


END ; -- end of package body
/


------------------------------------------------------------------------


-- package functions and procedures call 
SELECT pac_sales.f_vat_percent(1) FROM dual
/
SELECT pac_sales.f_vat_percent(999999) FROM dual
/
SELECT pac_sales.f_total_invoice(1111) FROM dual
/
SELECT pac_sales.f_total_invoice(1112) FROM dual
/
SELECT pac_sales.f_total_invoice(89899) FROM dual
/
SELECT pac_sales.f_cumulative_preced(1111) FROM dual
/
SELECT pac_sales.f_cumulative_preced(1112) FROM dual
/
SELECT pac_sales.f_cumulative_preced(1113) FROM dual
/
SELECT pac_sales.f_cumulative_preced(1) FROM dual
/
SELECT pac_sales.f_cumulative_preced(3333) FROM dual
/
EXECUTE p_amount_preceding(1)

EXECUTE p_amount_preceding(1111)

EXECUTE p_amount_preceding(1112)

EXECUTE p_amount_preceding(3333)











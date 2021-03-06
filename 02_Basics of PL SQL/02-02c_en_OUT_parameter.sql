/* Next procedure returns (exactly, a procedure can return a value like a function)
    the greatest N value from five numbers.
    Those five numbers are IN OUT parameters.
  
  Example. Given five numbers (120, 100, 1, 5, 10)
    - the second greatest value (N=2) is 100
    - the forth greatest value (N=4) is 5
    - the (first) greatest value (N=1) is 120   
*/
CREATE OR REPLACE PROCEDURE p_the_N_th_from_5_numbers (
    N IN NUMBER, 
    v1_ IN OUT NUMBER, 
    v2_ IN OUT NUMBER, 
    v3_ IN OUT NUMBER, 
    v4_ IN OUT NUMBER, 
    v5_ IN OUT NUMBER,
    vmax_ OUT NUMBER ) 
AS
BEGIN
    /* The solution is a bit strange (but slightly interesting):
    
    We get, N times, the greatest value of five numbers and replace it with 0!
      
    Example:
    Given five numbers (120, 100, 1, 5, 10)
    We want to get the third value (N=3)
        - at first passing through the next loop (when i = 1), vmax_ = 120, so v1_ will be set on 0;
            the five numbers are now (0, 100, 1, 5, 10)
        - at second passing through the loop (when i = 2), vmax_ = 100, so v2_ will be set on 0;
            the five numbers are now (0, 0, 1, 5, 10)
        - at third passing through the loop (when i = 3), vmax_ = 10, so v3_ will be set on 0;
            the five numbers are now (0, 0, 1, 5, 0)
        
        - after that i becomes 4, 4 is > N (3), and vmax_ value (which is 10) is returned     
    */
    FOR i IN 1..N LOOP
        vmax_ := f_max_val_from_5(v1_, v2_, v3_, v4_, v5_) ;
	
        IF v1_ = vmax_ THEN 
            v1_ := 0 ;
            CONTINUE; -- we need that for situations when numbers are not distinct
        END IF ;
        IF v2_ = vmax_ THEN 
            v2_ := 0 ;
            CONTINUE; -- we need that for situations when numbers are not distinct
        END IF ;
        IF v3_ = vmax_ THEN 
            v3_ := 0 ;
            CONTINUE; -- we need that for situations when numbers are not distinct        
        END IF ;
        IF v4_ = vmax_ THEN 
            v4_ := 0 ;
            CONTINUE; -- we need that for situations when numbers are not distinct        
        END IF ;
        IF v5_ = vmax_ THEN 
            v5_ := 0 ;
            CONTINUE; -- we need that for situations when numbers are not distinct        
        END IF ;
    END LOOP ;
END ;
/

---------------------------------------------
-- test
DECLARE 
    vmax NUMBER := 1 ; -- does't matter which value we set for vmax
    N NUMBER := 3 ;  -- we want the third greatest value
    
    x1 NUMBER := 120 ;
    x2 NUMBER := 100 ;
    x3 NUMBER := 1 ;
    x4 NUMBER := 5 ;
    x5 NUMBER := 10 ;
    v_initial VARCHAR2(1000) := x1 || ', ' ||
      x2 || ', ' || x3 || ', ' || x4 || ', ' || x5 ;
BEGIN
   p_the_N_th_from_5_numbers ( N,  x1, x2, x3, x4, x5, vmax  ) ;
   DBMS_OUTPUT.PUT_LINE ('The ' || N || CASE N WHEN 1 THEN 'st' WHEN 2 THEN 'nd'
    WHEN 3 THEN 'rd' ELSE 'th' END ||
   ' value from ' || v_initial || ' is ' ||
    vmax) ;
END ;
/

---------------------------------------------------------------------------------
/* Next function uses the above procedure for returning (as a function does :-) )
    the greatest N value from five numbers */
CREATE OR REPLACE FUNCTION f_the_N_th_from_5_numbers (
    N IN NUMBER, 
    v1 IN NUMBER, 
    v2 IN NUMBER, 
    v3 IN NUMBER, 
    v4 IN NUMBER, 
    v5 IN NUMBER ) RETURN NUMBER
AS
    vmax NUMBER ;
    v1_ NUMBER := v1  ;
    v2_ NUMBER := v2  ;
    v3_ NUMBER := v3  ;
    v4_ NUMBER := v4  ;
    v5_ NUMBER := v5  ;

BEGIN
    p_the_N_th_from_5_numbers (N, v1_, v2_, v3_, v4_, v5_, vmax) ;
    RETURN vmax ;
END ;
/


-- test the functions
BEGIN
    DBMS_OUTPUT.PUT_LINE (f_the_N_th_from_5_numbers ( 3,  /* N */ 
      120,  /* v1  */ 
      120, /* v2  */ 
      1, /* v3  */
      5, /* v4  */
      10  /* v5  */
      ) ) ;
END ;
/

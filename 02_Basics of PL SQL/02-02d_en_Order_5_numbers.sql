/* Next procedure orders five numbers using function "f_the_N_th_from_5_numbers"
  from previous script (03_02c) */ 

CREATE OR REPLACE PROCEDURE p_order_5_numbers (
    num1 IN INTEGER, 
    num2 IN INTEGER, 
    num3 IN INTEGER, 
    num4 IN INTEGER, 
    num5 IN INTEGER )
AS
    v1_ INTEGER ;
    v2_ INTEGER ;
    v3_ INTEGER ;
    v4_ INTEGER ;
    v5_ INTEGER ;
BEGIN

    FOR i IN 1..5 LOOP
        v1_ := num1 ;
        v2_ := num2 ;
        v3_ := num3 ;
        v4_ := num4 ;
        v5_ := num5 ;
        DBMS_OUTPUT.PUT_LINE ('Number no. '|| i ||' is: '|| 
            f_the_N_th_from_5_numbers(i, v1_, v2_, v3_, v4_, v5_) );
	END LOOP ;
END ;
/



-- test
BEGIN
    p_order_5_numbers ( 
      4,  /* num1  */ 
      67, /* num2  */ 
      45, /* num3  */
      32, /* num4  */
      22  /* num5  */
      ) ;
END ;
/


/* next (embarassing) function get five numbers and returns the greatest one */
CREATE OR REPLACE FUNCTION f_max_val_from_5 (
    v1 IN NUMBER, v2 IN NUMBER, v3 IN NUMBER, 
    v4 IN NUMBER, v5 IN NUMBER ) RETURN NUMBER
AS
    vmax NUMBER := v1 ;
BEGIN
    IF v2 > vmax THEN
        vmax := v2 ;
    END IF ;

    IF v3 > vmax THEN
        vmax := v3 ;
    END IF ;

    IF v4 > vmax THEN
        vmax := v4 ;
    END IF ;

    IF v5 > vmax THEN
        vmax := v5 ;
    END IF ;

    RETURN vmax ;

END ;
/

-- test
BEGIN 
    DBMS_OUTPUT.PUT_LINE (f_max_val_from_5 (345, 23, 433, 6677, 6)) ;
END ;
/




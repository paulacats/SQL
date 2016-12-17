create or replace FUNCTION num_subtotal_sf
  (p_id IN NUMBER)
  RETURN NUMBER
 IS
lv_subtotal_num NUMBER(6,2) := 0;

/*
developer: paula hodgkins
date: 27-Mar-16
purpose: this function returns the subtotal for the basket id entered
*/

BEGIN
 SELECT SUM(price * quantity) 
 INTO lv_subtotal_num
 FROM bb_basketitem
 WHERE idbasket = p_id
 GROUP BY idbasket;
RETURN lv_subtotal_num;
EXCEPTION --if the basket number does not exist 
 WHEN NO_DATA_FOUND THEN
 DBMS_OUTPUT.PUT_LINE('Invalid basket number.');
 RETURN 0;
END;

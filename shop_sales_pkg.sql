CREATE OR REPLACE PACKAGE shop_sales_pkg 
IS
FUNCTION num_subtotal_pf
  (p_id IN NUMBER)
  RETURN NUMBER;
PROCEDURE shop_sales_sum_pp;
END; 

CREATE OR REPLACE PACKAGE BODY shop_sales_pkg IS
FUNCTION num_subtotal_pf
  (p_id IN NUMBER)
  RETURN NUMBER
 IS
lv_subtotal_num NUMBER(6,2) := 0;
BEGIN
 SELECT SUM(price * quantity) --multiply the values in price and quantity columns
 INTO lv_subtotal_num
 FROM bb_basketitem
 WHERE idbasket = p_id
 GROUP BY idbasket;
RETURN lv_subtotal_num; --return the value to the caller
EXCEPTION --if the basket number does not exist 
 WHEN NO_DATA_FOUND THEN
 DBMS_OUTPUT.PUT_LINE('Invalid basket number.');
 RETURN 0;
END num_subtotal_pf;
PROCEDURE shop_sales_sum_pp
IS
CURSOR cur_purchases IS
SELECT idshopper id, SUM(bi.quantity*bi.price) total --sum the quantity multiplied by the price values
   FROM bb_shopper s INNER JOIN bb_basket b
    USING (idshopper)
INNER JOIN bb_basketitem bi
    USING (idbasket)
   WHERE orderplaced = 1
   GROUP BY idshopper;
TYPE type_purchases IS RECORD --define the record
(id bb_basket.idshopper%TYPE,
total bb_basket.subtotal%TYPE);
rec_purchases type_purchases;
BEGIN
OPEN cur_purchases;
LOOP
FETCH cur_purchases INTO rec_purchases; 
--let the user know if the table was not updated
IF cur_purchases%ROWCOUNT = 0 THEN
       DBMS_OUTPUT.PUT_LINE('There were no orders placed; table not updated.');
EXIT;
ELSE
  EXIT WHEN cur_purchases%NOTFOUND;
     INSERT INTO bb_shop_sales (idshopper, total)
         VALUES (rec_purchases.id, rec_purchases.total);
END IF;
END LOOP;
END shop_sales_sum_pp;
END; --end of package

--test the code
DECLARE
  lv_id_num NUMBER(3) := 3;
  lv_subtotal_num NUMBER(5,2);
BEGIN
  lv_subtotal_num := shop_sales_pkg.num_subtotal_pf(lv_id_num);
  DBMS_OUTPUT.PUT_LINE('Subtotal for the basket is: ' || lv_subtotal_num);
END;

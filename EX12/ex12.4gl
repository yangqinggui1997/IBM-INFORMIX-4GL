DATABASE test4gl
GLOBALS
    DEFINE gr_ordship RECORD
                customer_num LIKE customer.customer_num,
                company LIKE customer.company,
                order_num INTEGER,
                order_date LIKE orders.order_date
            END RECORD,
        gr_charges RECORD
                tax_rate DECIMAL(5,3),
                ship_charge LIKE orders.ship_charge,
                sales_tax MONEY(9),
                order_total MONEY(11)
            END RECORD,
        gr_ship RECORD
                ship_date LIKE orders.ship_date,
                ship_instruct LIKE orders.ship_instruct,
                ship_weight LIKE orders.ship_weight,
                ship_charge LIKE orders.ship_charge
            END RECORD
    DEFINE ga_dsplymsg ARRAY[5] OF CHAR(48)
END GLOBALS

MAIN
    DEFINE upd_stat INTEGER
    OPTIONS
        #HELP FILE "hlpmsgs",
        COMMENT LINE 1,
        MESSAGE LINE LAST
    DEFER INTERRUPT
    OPEN WINDOW w_main AT 2,3 WITH 19 ROWS, 76 COLUMNS ATTRIBUTE (BORDER)
    OPEN FORM f_ship FROM "f_ship"
    DISPLAY FORM f_ship
    IF find_order() 
    THEN
        DISPLAY " Press Accept to save shipping info. Press CTRL-W for Help." AT 17, 1 ATTRIBUTE (REVERSE, YELLOW)
        DISPLAY " Press Cancel to exit w/out saving." AT 18, 1 ATTRIBUTE (REVERSE, YELLOW)

        CALL calc_order(gr_ordship.order_num)

        SELECT ship_date, ship_instruct, ship_weight, ship_charge
        INTO gr_ship.*
        FROM orders
        WHERE order_num = gr_ordship.order_num
        
        IF input_ship()
        THEN
            LET upd_stat = upd_order(gr_ordship.order_num)
            IF (upd_stat < 0) 
            THEN
                ERROR upd_stat USING "-<<<<<<<<<<<", ": Unable to update the order."
            ELSE
                CALL msg("Order updated with shipping information.")
            END IF
        END IF
    END IF
    CLOSE FORM f_ship
    CLOSE WINDOW w_main
    CLEAR SCREEN
END MAIN

FUNCTION find_order()
    DEFINE cust_num LIKE customer.customer_num,
        last_key SMALLINT
    
    CALL clear_lines(1, 3)
    DISPLAY "ORDER SEARCH" AT 2, 34
    
    CALL clear_lines(2, 17)
    DISPLAY " Enter customer number and order number then press Accept." AT 17, 1 ATTRIBUTE (REVERSE, YELLOW)
    DISPLAY " Press Cancel to exit without searching. Press CTRL-W for Help." AT 18, 1 ATTRIBUTE (REVERSE, YELLOW)

    LET int_flag = FALSE
    INPUT BY NAME gr_ordship.customer_num, gr_ordship.order_num HELP 110
        BEFORE FIELD customer_num
            MESSAGE "Enter a customer number or press F5 (CTRL-F) for a list."
            AFTER FIELD customer_num
                IF gr_ordship.customer_num IS NULL 
                THEN
                    ERROR "You must enter a customer number. Please try again."
                    NEXT FIELD customer_num
                END IF
                
                SELECT company
                INTO gr_ordship.company
                FROM customer
                WHERE customer_num = gr_ordship.customer_num
                
                IF (status = NOTFOUND) 
                THEN
                    ERROR "Unknown customer number. Use F5 (CTRL-F) to see valid customers."
                    LET gr_ordship.customer_num = NULL
                    NEXT FIELD customer_num
                END IF
                
                DISPLAY BY NAME gr_ordship.company
                MESSAGE ""
        BEFORE FIELD order_num
            MESSAGE rder number or press F5 (CTRL-F) for a list."
        AFTER FIELD order_num
            LET last_key = FGL_LASTKEY()
            IF (last_key <> FGL_KEYVAL("left") ) AND (last_key <> FGL_KEYVAL("up") )
            THEN
                IF gr_ordship.order_num IS NULL 
                THEN
                    ERROR "You must enter an order number. Please try again."
                    NEXT FIELD order_num
                END IF
                
                SELECT order_date, customer_num
                INTO gr_ordship.order_date, cust_num
                FROM orders
                WHERE order_num = gr_ordship.order_num
                
                IF (status = NOTFOUND) 
                THEN
                    ERROR "Unknown order number. Use F5 (CTRL-F) to see valid orders."
                    LET gr_ordship.order_num = NULL
                    NEXT FIELD order_num
                END IF
                IF (cust_num <> gr_ordship.customer_num) 
                THEN
                    ERROR "Order ", gr_ordship.order_num USING "<<<<<<<<<<<", " is not for customer ", gr_ordship.customer_num USING "<<<<<<<<<<<"
                    LET gr_ordship.order_num = NULL
                    DISPLAY BY NAME gr_ordship.order_num
                    NEXT FIELD customer_num
                END IF
                DISPLAY BY NAME gr_ordship.order_date
                ELSE
                    LET gr_ordship.order_num = NULL
                    DISPLAY BY NAME gr_ordship.order_num
                END IF
                MESSAGE ""
        ON KEY (F5, CONTROL-F)
            IF INFIELD(customer_num) 
            THEN
                CALL cust_popup2() RETURNING gr_ordship.customer_num, gr_ordship.company
                IF gr_ordship.customer_num IS NULL 
                THEN
                    IF gr_ordship.company IS NULL 
                    THEN
                        LET ga_dsplymsg[1] = "No customers exist in the database!"
                        CALL message_window(11, 12)
                    END IF
                    NEXT FIELD customer_num
                END IF
                DISPLAY BY NAME gr_ordship.customer_num, gr_ordship.company
                MESSAGE ""
                NEXT FIELD order_num
            END IF
            IF INFIELD(order_num) 
            THEN
                CALL order_popup(gr_ordship.customer_num) RETURNING gr_ordship.order_num, gr_ordship.order_date
                IF gr_ordship.order_num IS NULL 
                THEN
                    IF gr_ordship.order_date IS NULL 
                    THEN
                        LET ga_dsplymsg[1] = "No orders exists for customer ", gr_ordship.customer_num USING "<<<<<<<<<<<", "."
                        CALL message_window(11, 12)
                        LET gr_ordship.customer_num = NULL
                        LET gr_ordship.company = NULL
                        DISPLAY BY NAME gr_ordship.company
                        NEXT FIELD customer_num
                    ELSE
                        NEXT FIELD order_num
                    END IF
                END IF
                DISPLAY BY NAME gr_ordship.order_num, gr_ordship.order_date
                MESSAGE ""
                EXIT INPUT
            END IF
        AFTER INPUT
        IF NOT int_flag 
        THEN
            IF (gr_ordship.customer_num IS NULL) OR (gr_ordship.order_num IS NULL) 
            THEN
                ERROR "Enter the customer and order numbers or press Cancel to exit."
                NEXT FIELD customer_num
            END IF
        END IF
    END INPUT
    IF int_flag 
    THEN
        LET int_flag = FALSE
        CALL clear_lines(2, 17)
        CALL msg("Order search terminated.")
        RETURN (FALSE)
    END IF
    CALL clear_lines(2, 17)
    RETURN (TRUE)
END FUNCTION -- find_order --

FUNCTION cust_popup2()
    DEFINE pa_cust ARRAY[10] OF RECORD
            customer_num LIKE customer.customer_num,
            company LIKE customer.company
        END RECORD,
        idx SMALLINT,
        i SMALLINT,
        cust_cnt SMALLINT,
        fetch_custs SMALLINT,
        array_size SMALLINT,
        total_custs INTEGER,
        number_to_see INTEGER,
        curr_pa SMALLINT
    
    LET array_size = 10
    LET fetch_custs = FALSE
    SELECT COUNT(*)
    INTO total_custs
    FROM customer

    IF total_custs = 0 
    THEN
        LET pa_cust[1].customer_num = NULL
        LET pa_cust[1].company = NULL
        RETURN pa_cust[1].customer_num, pa_cust[1].company
    END IF
    
    OPEN WINDOW w_custpop AT 8, 13 WITH 12 ROWS, 50 COLUMNS ATTRIBUTE(BORDER, FORM LINE 4)
    OPEN FORM f_custsel FROM "f_custsel" 
    DISPLAY FORM f_custsel
    DISPLAY "Move cursor using F3, F4, and arrow keys." AT 1,2 DISPLAY "Press Accept to select a customer." AT 2,2
    LET number_to_see = total_custs
    LET idx = 0
    
    DECLARE c_custpop CURSOR FOR
    SELECT customer_num, company
    FROM customer
    ORDER BY customer_num

    WHENEVER ERROR CONTINUE
    OPEN c_custpop
    WHENEVER ERROR STOP
    
    IF (status = 0) THEN
        LET fetch_custs = TRUE
    ELSE
        CALL msg("Unable to open cursor.")
        LET idx = 1
        LET pa_cust[idx].customer_num = NULL
        LET pa_cust[idx].company = NULL
    END IF
    
    WHILE fetch_custs
        WHILE (idx < array_size)
            LET idx = idx + 1
            FETCH c_custpop INTO pa_cust[idx].*
            IF (status = NOTFOUND) THEN --* no more orders to see
                LET fetch_custs = FALSE
                LET idx = idx - 1
                EXIT WHILE
            END IF
        END WHILE
        IF (number_to_see > array_size) 
        THEN
            MESSAGE "On last row, press F5 (CTRL-B) for more customers."
        END IF
        
        IF (idx = 0) 
        THEN
            CALL msg("No customers exist in the database.")
            LET idx = 1
            LET pa_cust[idx].customer_num = NULL
        ELSE
            CALL SET_COUNT(idx)
            LET int_flag = FALSE
            DISPLAY ARRAY pa_cust TO sa_cust.*
            ON KEY (F5, CONTROL-B)
                LET curr_pa = ARR_CURR()
                IF (curr_pa = idx) 
                THEN
                    LET number_to_see = number_to_see - idx
                    IF (number_to_see > 0) 
                    THEN
                        LET idx = 0
                        EXIT DISPLAY
                    ELSE
                        CALL msg("No more customers to see.")
                    END IF
                ELSE
                    CALL msg("Not on last customer row.")
                    MESSAGE "On last row, press F5 (CTRL-B) for more customers."
                END IF
                END DISPLAY
                IF (idx <> 0) 
                THEN
                    LET idx = ARR_CURR()
                    LET fetch_custs = FALSE
                END IF
                IF int_flag 
                THEN
                    LET int_flag = FALSE
                    CALL msg("No customer number selected.")
                    LET pa_cust[idx].customer_num = NULL
                END IF 
        END IF
    END WHILE
    CLOSE FORM f_custsel
    CLOSE WINDOW w_custpop
    RETURN pa_cust[idx].customer_num, pa_cust[idx].company
END FUNCTION -- cust_popup2 --

FUNCTION order_popup(cust_num)
    DEFINE cust_num LIKE customer.customer_num,
            pa_order ARRAY[10] OF RECORD
            order_num LIKE orders.order_num,
            order_date LIKE orders.order_date,
            po_num LIKE orders.po_num,
            ship_date LIKE orders.ship_date,
            paid_date LIKE orders.paid_date
        END RECORD,
        idx SMALLINT,
        i SMALLINT,
        order_cnt SMALLINT,
        fetch_orders SMALLINT,
        array_size SMALLINT,
        total_orders INTEGER,
        number_to_see INTEGER,
        curr_pa SMALLINT

    LET array_size = 10
    LET fetch_orders = FALSE
    SELECT COUNT(*)
    INTO total_orders
    FROM orders
    WHERE customer_num = cust_num

    IF total_orders = 0 
    THEN
        LET pa_order[1].order_num = NULL
        LET pa_order[1].order_date = NULL
        RETURN pa_order[1].order_num, pa_order[1].order_date
    END IF
    OPEN WINDOW w_orderpop AT 9, 5 WITH 12 ROWS, 71 COLUMNS ATTRIBUTE(BORDER, FORM LINE 4)
    OPEN FORM f_ordersel FROM "f_ordersel"
    DISPLAY FORM f_ordersel
    DISPLAY "Move cursor using F3, F4, and arrow keys." AT 1,2
    DISPLAY "Press Accept to select an order." AT 2,2
    
    LET number_to_see = total_orders
    LET idx = 0
    DECLARE c_orderpop CURSOR FOR
    SELECT order_num, order_date, po_num, ship_date, paid_date
    FROM orders
    WHERE customer_num = cust_num
    ORDER BY order_num

    WHENEVER ERROR CONTINUE
    OPEN c_orderpop
    WHENEVER ERROR STOP
    IF (status = 0) 
    THEN
        LET fetch_orders = TRUE
    ELSE
        CALL msg("Unable to open cursor.")
        LET idx = 1
        LET pa_order[idx].order_num = NULL
        LET pa_order[idx].order_date = NULL
    END IF
    WHILE fetch_orders
        WHILE (idx < array_size)
            LET idx = idx + 1
            FETCH c_orderpop INTO pa_order[idx].*
            IF (status = NOTFOUND) 
            THEN --* no more orders to see
                LET fetch_orders = FALSE
                LET idx = idx - 1
                EXIT WHILE
            END IF
        END WHILE
        IF (number_to_see > array_size) 
        THEN
            MESSAGE "On last row, press F5 (CTRL-B) for more orders."
        END IF
        IF (idx = 0) 
        THEN
            CALL msg("No orders exist in the database.")
            LET idx = 1
            LET pa_order[idx].order_num = NULL
        ELSE
            CALL SET_COUNT(idx)
            LET int_flag = FALSE
            DISPLAY ARRAY pa_order TO sa_order.*
            ON KEY (F5, CONTROL-B)
                LET curr_pa = ARR_CURR()
                IF (curr_pa = idx) 
                THEN
                    LET number_to_see = number_to_see - idx
                    IF (number_to_see > 0) 
                    THEN
                        LET idx = 0
                        EXIT DISPLAY
                    ELSE
                        CALL msg("No more orders to see.")
                    END IF
                ELSE
                    CALL msg("Not on last order row.")
                    MESSAGE "On last row, press F5 (CTRL-B) for more orders."
                END IF
                END DISPLAY
                IF idx <> 0 
                THEN
                    LET idx = ARR_CURR()
                    LET fetch_orders = FALSE
                END IF
                
                IF int_flag 
                THEN
                    LET int_flag = FALSE
                    CALL msg("No order number selected.")
                    LET pa_order[idx].order_num = NULL
                END IF
        END IF
    END WHILE
    
    CLOSE FORM f_ordersel
    CLOSE WINDOW w_orderpop
    RETURN pa_order[idx].order_num, pa_order[idx].order_date
END FUNCTION -- orders_popup --

FUNCTION calc_order(ord_num)
    DEFINE ord_num LIKE orders.order_num,
        state_code LIKE customer.state
    
    SELECT ship_charge, state
    INTO gr_charges.ship_charge, state_code
    FROM orders, customer
    WHERE order_num = ord_num AND orders.customer_num = customer.customer_num
    
    IF gr_charges.ship_charge IS NULL 
    THEN
        LET gr_charges.ship_charge = 0.00
    END IF
    
    SELECT SUM(total_price)
    INTO gr_charges.order_total
    FROM items
    WHERE order_num = ord_num
 
    IF gr_charges.order_total IS NULL 
    THEN
        LET gr_charges.order_total = 0.00
    END IF

    CALL tax_rates(state_code) RETURNING gr_charges.tax_rate
    LET gr_charges.sales_tax = gr_charges.order_total * (gr_charges.tax_rate / 100)
    LET gr_charges.order_total = gr_charges.order_total + gr_charges.sales_tax
END FUNCTION -- calc_order --


FUNCTION upd_order(ord_num)
    DEFINE ord_num LIKE orders.order_num
    
    WHENEVER ERROR CONTINUE
    UPDATE orders SET (ship_date, ship_instruct, ship_weight, ship_charge) = (gr_ship.ship_date, gr_ship.ship_instruct, gr_ship.ship_weight, gr_ship.ship_charge)
    WHERE order_num = ord_num
    WHENEVER ERROR STOP
    RETURN (status)
END FUNCTION -- upd_order --

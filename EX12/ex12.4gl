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

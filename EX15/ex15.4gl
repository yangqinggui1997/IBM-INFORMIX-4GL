DATABASE test4gl
GLOBALS
    DEFINE _grCustomer RECORD LIKE customer.*,
            _grOrders RECORD
            _orderNum LIKE orders._orderNum,
            order_date LIKE orders.order_date,
            po_num LIKE orders.po_num,
            order_amount MONEY(8,2),
            order_total MONEY(10,2)
        END RECORD,
        ga_items ARRAY[10] OF RECORD
            item_num LIKE items.item_num,
            stock_num LIKE items.stock_num,
            manu_code LIKE items.manu_code,
            description LIKE stock.description,
            quantity LIKE items.quantity,
            unit_price LIKE stock.unit_price,
            total_price LIKE items.total_price
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
    OPTIONS
        HELP FILE "hlpmsgs",
        FORM LINE 2,
        COMMENT LINE 1,
        MESSAGE LINE LAST

    DEFER INTERRUPT
    OPEN WINDOW w_main AT 2,3 WITH 18 ROWS, 76 COLUMNS ATTRIBUTE (BORDER)
    OPEN FORM f_orders FROM "f_orders"
    DISPLAY FORM f_orders
    CALL add_order2()
    CLEAR SCREEN
END MAIN

FUNCTION add_order2()
    INITIALIZE _grOrders.* TO NULL
    DISPLAY "ORDER ADD" AT 2, 34
    CALL clear_lines(2, 16)
    DISPLAY " Press Cancel to exit without saving." AT 17, 1 ATTRIBUTE (REVERSE, YELLOW)
    IF input_cust() 
    THEN
        IF input_order()
        THEN
            IF input_items() 
            THEN
                CALL dsply_taxes()
                IF prompt_window("Do you want to ship this order now?", 8, 12) THEN
                    CALL ship_order()
                ELSE
                    LET gr_ship.ship_date = NULL
                END IF
                CALL clear_lines(2, 16)
                LET ga_dsplymsg[1] = "Order entry complete."
                
                IF prompt_window("Are you ready to save this order?", 8, 12) 
                THEN
                    IF order_tx() 
                    THEN
                        CALL clear_lines(2, 16)
                        LET ga_dsplymsg[1] = "Order Number: ", _grOrders._orderNum USING "<<<<<<<<<<<"
                        LET ga_dsplymsg[2] = " has been placed for Customer: ", _grCustomer.customer_num USING "<<<<<<<<<<<"
                        LET ga_dsplymsg[3] = "Order Date: ", _grOrders.order_date
                        CALL message_window(9, 13)
                        CLEAR FORM
                        CALL invoice()
                    END IF
                ELSE
                    CLEAR FORM
                    CALL msg("Order has been terminated.")
                END IF
            END IF
        END IF
    END IF
END FUNCTION -- add_order2 --

FUNCTION invoice()
    DEFINE pr_invoice RECORD
            _orderNum LIKE orders._orderNum,
            order_date LIKE orders.order_date,
            ship_instruct LIKE orders.ship_instruct,
            po_num LIKE orders.po_num,
            ship_date LIKE orders.ship_date,
            ship_weight LIKE orders.ship_weight,
            ship_charge LIKE orders.ship_charge,
            item_num LIKE items.item_num,
            stock_num LIKE items.stock_num,
            description LIKE stock.description,
            manu_code LIKE items.manu_code,
            manu_name LIKE manufact.manu_name,
            quantity LIKE items.quantity,
            total_price LIKE items.total_price,
            unit LIKE stock.unit,
            unit_price LIKE stock.unit_price
        END RECORD,
        file_name CHAR(20),
        inv_msg CHAR(40),
        print_option CHAR(1),
        scr_flag SMALLINT
    
    LET print_option = report_output("ORDER INVOICE", 13, 10)

    CASE (print_option)
    WHEN "F"
        LET file_name = "inv", _grOrders._orderNum USING "<<<<&",".out"
        START REPORT invoice_rpt TO file_name
        MESSAGE "Writing invoice to ", file_name CLIPPED," -- please wait."
    WHEN "P"
        START REPORT invoice_rpt TO PRINTER
        MESSAGE "Sending invoice to printer -- please wait."
    WHEN "S"
        START REPORT invoice_rpt
        MESSAGE "Preparing invoice for screen -- please wait."
    END CASE

    SELECT *
    INTO _grCustomer.*
    FROM customer
    WHERE customer_num = _grCustomer.customer_num
    
    LET gr_charges.ship_charge = gr_ship.ship_charge
    
    IF print_option = "S" 
    THEN
        LET scr_flag = TRUE
    ELSE
        LET scr_flag = FALSE
    END IF
    
    DECLARE c_invoice CURSOR FOR
    SELECT o._orderNum, o.order_date, o.ship_instruct, o.po_num, o.ship_date, o.ship_weight, o.ship_charge, i.item_num, i.stock_num, s.description, i.manu_code, m.manu_name, i.quantity, i.total_price, s.unit, s.unit_price
    FROM orders o, items i, stock s, manufact m
    WHERE ( (o._orderNum = _grOrders._orderNum) AND (i._orderNum = o._orderNum) AND (i.stock_num = s.stock_num AND i.manu_code = s.manu_code) AND (i.manu_code = m.manu_code) )
    ORDER BY 8

    FOREACH c_invoice INTO pr_invoice.*
        OUTPUT TO REPORT invoice_rpt (_grCustomer.*, pr_invoice.*, gr_charges.*, scr_flag)
    END FOREACH
    FINISH REPORT invoice_rpt
    
    CASE (print_option)
    WHEN "F"
        LET inv_msg = "Invoice written to file ", file_name CLIPPED
    WHEN "P"
        LET inv_msg = "Invoice sent to the printer."
    WHEN "S"
        LET inv_msg = "Invoice sent to the screen."
    END CASE
    CALL msg(inv_msg)
END FUNCTION -- invoice --

FUNCTION report_output(menu_title, x,y)
    DEFINE menu_title CHAR(15),
        x SMALLINT,
        y SMALLINT,
        rpt_out CHAR(1)

    OPEN WINDOW w_rpt AT x, y WITH 2 ROWS, 41 COLUMNS ATTRIBUTE (BORDER)
    
    MENU menu_title
    COMMAND "File" "Save report output in a file. "
        LET rpt_out = "F"
        EXIT MENU
    COMMAND "Printer" "Send report output to the printer. "
        LET rpt_out = "P"
        EXIT MENU
    COMMAND "Screen" "Send report output to the screen. "
        LET ga_dsplymsg[1] = "Output is not saved after it is sent to "
        LET ga_dsplymsg[2] = " the screen."
        LET x = x - 1
        LET y = y + 2
        IF prompt_window("Are you sure you want to use the screen?", x, y)
        THEN
            LET rpt_out = "S"
            EXIT MENU
        ELSE
            NEXT OPTION "File"
        END IF
    END MENU
    CLOSE WINDOW w_rpt
    RETURN rpt_out
END FUNCTION -- report_output --

REPORT invoice_rpt(pr_cust, pr_invoice, pr_charges, scr_flag)
    DEFINE pr_cust RECORD LIKE customer.*,
            pr_invoice RECORD
                    _orderNum LIKE orders._orderNum,
                    order_date LIKE orders.order_date,
                    ship_instruct LIKE orders.ship_instruct,
                    po_num LIKE orders.po_num,
                    ship_date LIKE orders.ship_date,
                    ship_weight LIKE orders.ship_weight,
                    ship_charge LIKE orders.ship_charge,
                    item_num LIKE items.item_num,
                    stock_num LIKE items.stock_num,
                    description LIKE stock.description,
                    manu_code LIKE items.manu_code,
                    manu_name LIKE manufact.manu_name,
                    quantity LIKE items.quantity,
                    total_price LIKE items.total_price,
                    unit LIKE stock.unit,
                    unit_price LIKE stock.unit_price
            END RECORD,
            pr_charges RECORD
                tax_rate DECIMAL(5,3),
                ship_charge LIKE orders.ship_charge,
                sales_tax MONEY(9),
                order_total MONEY(11)
            END RECORD,
            scr_flag SMALLINT,
            name_str CHAR(37),
            sub_total MONEY(10,2)
    OUTPUT
        LEFT MARGIN 0
        RIGHT MARGIN 0
        TOP MARGIN 1
        BOTTOM MARGIN 1
        PAGE LENGTH 48
    FORMAT
        BEFORE GROUP OF pr_invoice._orderNum
            LET sub_total = 0.00
            SKIP TO TOP OF PAGE
            SKIP 1 LINE
            PRINT 10 SPACES, " W E S T C O A S T W H O L E S A L E R S , I N C ."
            
            PRINT 30 SPACES, " 1400 Hanbonon Drive"
            PRINT 30 SPACES, "Menlo Park, CA 94025"
            PRINT 32 SPACES, TODAY USING "ddd. mmm dd, yyyy"
            SKIP 4 LINES
            
            PRINT COLUMN 2, "Invoice Number: ", pr_invoice._orderNum USING "&&&&&&&&&&&",
            COLUMN 46, "Bill To: Customer Number ", pr_cust.customer_num USING "<<<<<<<<<<&"
            
            PRINT COLUMN 2, "Invoice Date:",
            COLUMN 18, pr_invoice.order_date USING "ddd. mmm dd, yyyy",
            COLUMN 55, pr_cust.company
            
            PRINT COLUMN 2, "PO Number:",
            COLUMN 18, pr_invoice.po_num,
            COLUMN 55, pr_cust.address1
 
            IF (pr_cust.address2 IS NOT NULL) 
            THEN
                PRINT COLUMN 55, pr_cust.address2
            ELSE
                PRINT COLUMN 55, pr_cust.city CLIPPED, ", ", pr_cust.state CLIPPED, " ", pr_cust.zipcode CLIPPED
            END IF
            
            IF (pr_cust.address2 IS NOT NULL) 
            THEN
                PRINT COLUMN 55, pr_cust.city CLIPPED, ", ", pr_cust.state CLIPPED, " ", pr_cust.zipcode CLIPPED
            ELSE
                PRINT COLUMN 55, " "
            END IF

            IF (pr_cust.lname IS NOT NULL) 
            THEN
                LET name_str = "ATTN: ", pr_cust.fname CLIPPED, " ",
                pr_cust.lname CLIPPED
            ELSE
                LET name_str = " "
            END IF
            PRINT COLUMN 2, "Ship Date:";
            
            IF (pr_invoice.ship_date IS NULL) 
            THEN
                PRINT COLUMN 15, "Not Shipped";
            ELSE
                PRINT COLUMN 15, pr_invoice.ship_date USING "ddd. mmm dd, yyyy";
            END IF
            IF (pr_cust.address2 IS NOT NULL) 
            THEN
                PRINT COLUMN 55, " "
            ELSE
                PRINT COLUMN 49, name_str CLIPPED
            END IF
            
            PRINT COLUMN 2, "Ship Weight: ";
            IF (pr_invoice.ship_weight IS NULL) 
            THEN
                PRINT "N/A";
            ELSE
                PRINT pr_invoice.ship_weight USING "<<<<<<<&.&&", " lbs.";
            END IF

            IF (pr_cust.address2 IS NOT NULL) 
            THEN
                PRINT COLUMN 49, name_str CLIPPED
            ELSE
                PRINT COLUMN 55, " "
            END IF

            PRINT COLUMN 2, "Shipping Instructions:";
            IF (pr_invoice.ship_instruct IS NULL) 
            THEN
                PRINT COLUMN 25, "None"
            ELSE
                PRINT COLUMN 25, pr_invoice.ship_instruct
            END IF

            SKIP 1 LINE
            PRINT "----------------------------------------";
            PRINT "---------------------------------------"
            PRINT COLUMN 2, "Item",
            COLUMN 10, "Stock",
            COLUMN 18, "Manuf",
            COLUMN 56, "Unit"
            PRINT COLUMN 2, "Number",
            COLUMN 10, "Number",
            COLUMN 18, "Code",
            COLUMN 24, "Description",
            COLUMN 41, "Qty",
            COLUMN 49, "Unit",
            COLUMN 56, "Price",
            COLUMN 68, "Item Total"
            PRINT " ------ ------ ----- --------------- ------ ---- --------";

            PRINT " ----------"
            {
                Item Stock Manuf Unit
                Number Number Code Description Qty Unit Price Item Total
                ------ ------ ----- --------------- ------ ---- -------- -----------
                XXXXXX XXXXXX XXX XXXXXXXXXXXXXXX XXXXXX XXXX $X,XXX.XX $XXX,XXX.XX
            }

        ON EVERY ROW
            PRINT COLUMN 2, pr_invoice.item_num USING "#####&",
            COLUMN 10, pr_invoice.stock_num USING "&&&&&&",
            COLUMN 18, pr_invoice.manu_code,
            COLUMN 24, pr_invoice.description,
            COLUMN 41, pr_invoice.quantity USING "#####&",
            COLUMN 49, pr_invoice.unit,
            COLUMN 56, pr_invoice.unit_price USING "$,$$&.&&",
            COLUMN 68, pr_invoice.total_price USING "$$$,$$&.&&"
            LET sub_total = sub_total + pr_invoice.total_price

        AFTER GROUP OF pr_invoice._orderNum
            SKIP 1 LINE
            PRINT "----------------------------------------";
            PRINT "---------------------------------------"
            PRINT COLUMN 53, "Sub-total: ",
            COLUMN 65, sub_total USING "$$,$$$,$$&.&&"
            PRINT COLUMN 43, "Sales Tax (",
            pr_charges.tax_rate USING "#&.&&&", "%): ",
            COLUMN 66, pr_charges.sales_tax USING "$,$$$,$$&.&&"
            IF (pr_invoice.ship_charge IS NULL) 
            THEN
                LET pr_invoice.ship_charge = 0.00
            END IF
            PRINT COLUMN 47, "Shipping Charge: ",
            COLUMN 70, pr_invoice.ship_charge USING "$,$$&.&&"
            PRINT COLUMN 64, "--------------"
            PRINT COLUMN 57, "Total: ", pr_charges.order_total USING "$$$,$$$,$$&.&&"
            IF scr_flag 
            THEN
                PAUSE "Press RETURN to continue."
            END IF
END REPORT {invoice_rpt}

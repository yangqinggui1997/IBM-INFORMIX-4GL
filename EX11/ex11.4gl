DATABASE test4gl
GLOBALS
    DEFINE _grCustomer RECORD LIKE customer.*,
            _grOrders RECORD
                        order_num LIKE orders.order_num,
                        order_date LIKE orders.order_date,
                        po_num LIKE orders.po_num,
                        order_amount MONEY(8,2),
                        order_total MONEY(10,2)
                    END RECORD,
            _gaItems ARRAY[10] OF RECORD
                        item_num LIKE items.item_num,
                        stock_num LIKE items.stock_num,
                        manu_code LIKE items.manu_code,
                        description LIKE stock.description,
                        quantity LIKE items.quantity,
                        unit_price LIKE stock.unit_price,
                        total_price LIKE items.total_price
                    END RECORD,
            _grCharges RECORD
                        tax_rateDECIMAL(5,3),
                        ship_chargeLIKE orders.ship_charge,
                        sales_taxMONEY(9),
                        order_totalMONEY(11)
                    END RECORD,
            _grShip RECORD
                        ship_date LIKE orders.ship_date,
                        ship_instruct LIKE orders.ship_instruct,
                        ship_weight LIKE orders.ship_weight,
                        ship_charge LIKE orders.ship_charge
                    END RECORD
# used by init_msgs(), message_window(), and prompt_window() to allow
# user to display text in a message or prompt window.
    DEFINE _message ARRAY[5] OF CHAR(48)
END GLOBALS

MAIN
    OPTIONS
        FORM LINE 2,
        COMMENT LINE 1,
        MESSAGE LINE LAST
    DEFER INTERRUPT

    OPEN WINDOW _wMain AT 2, 3 WITH 18 ROWS, 76 COLUMNS ATTRIBUTE (BORDER)
    OPEN FORM _frmOrders FORM "f_orders"
    DISPLAY FORM _frmOrders

    CALL addOrder()
    CLOSE FORM _frmOrders
    CLOSE WINDOW _wMain
    CLEAR SCREEN
END MAIN

FUNCTION addOrder(parametros)
    INITIALIZE _grOrders.* TO NULL

    DISPLAY "ORDER ADD" AT 2, 34
    CALL clearLines(2, 16)
    DISPLAY "Press Cancel to exit without saving." AT 17, 1 ATTRIBUTE(REVERSE, YELLOW)

    IF inputCust()
    THEN
        IF inputOrders()
        THEN
            IF inputItems()
            THEN
                CALL dsplyTaxes()
                IF promptWindow("Do you want to ship this order now?", 8, 12)
                THEN
                    CALL shipOrder()
                ELSE
                    LET _grShip.ship_date = NULL
                END IF

                CALL clearLines(2, 16)
                LET _message[1] = "Order entry complete."
                IF promptWindow("Are you ready to save this order?", 8, 12)
                THEN
                    IF orderTx()
                    THEN
                        CALL clearLines(2, 16)
                        LET _message[1] = "Order Number: ", _grOrders.order_num USING "<<<<<<<<<<<"
                        LET _message[2] = " has been placed for Customer: ", _grCustomer.customer_num USING "<<<<<<<<<<<"
                        LET _message[3] = "Order date: ", _grOrders.order_date
                        CALL messageWindow(9, 13)
                        CLEAR FORM
                    END IF
                ELSE
                    CLEAR FORM
                    CALL msg("Order has been terminated.")
                END IF
            END IF
        END IF
    END IF
END FUNCTION

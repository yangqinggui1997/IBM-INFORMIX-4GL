DATABASE test4gl
GLOBALS
 DEFINE gr_custsum RECORD
 customer_num LIKE customer.customer_num,
 company LIKE customer.company,
 unpaid_ords SMALLINT,
 amount_due MONEY(11),
 open_calls SMALLINT
 END RECORD
 DEFINE ga_dsplymsg ARRAY[5] OF CHAR(100)
END GLOBALS

########################################
MAIN
########################################
 OPTIONS
 INPUT ATTRIBUTE (REVERSE, BLUE),
 PROMPT LINE 13,
 MESSAGE LINE LAST
 CALL cust_summary()
END MAIN

########################################
FUNCTION cust_summary()
########################################
 DEFINE search_again SMALLINT
 LET search_again = TRUE
 WHILE search_again
 CALL get_custnum() RETURNING gr_custsum.customer_num
 CALL dsply_summary() RETURNING search_again
 END WHILE
 CLEAR SCREEN
END FUNCTION

########################################
FUNCTION get_custnum()
########################################
 DEFINE cust_num INTEGER,
 cust_cnt SMALLINT
 OPEN FORM f_custkey FROM "f_custkey"
 DISPLAY FORM f_custkey
 DISPLAY " "
 AT 2, 30
 DISPLAY "CUSTOMER KEY LOOKUP"
 AT 2, 20
 DISPLAY " Enter customer number and press Accept."
 AT 4, 1 ATTRIBUTE (REVERSE, YELLOW)
 INPUT cust_num FROM customer_num
 AFTER FIELD customer_num
 IF cust_num IS NULL THEN
 ERROR "You must enter a customer number. Please try again."
 NEXT FIELD customer_num
 END IF
 SELECT COUNT(*)
 INTO cust_cnt
 FROM customer
 WHERE customer_num = cust_num
 IF (cust_cnt = 0) THEN
 ERROR "Unknown customer number. Please try again."
 LET cust_num = NULL
 NEXT FIELD customer_num
 END IF
 END INPUT
 CLOSE FORM f_custkey
RETURN (cust_num)
END FUNCTION -- get_custnum --

########################################
 FUNCTION get_summary()
########################################
 DEFINE cust_state LIKE state.code,
 item_total MONEY(12),
 ship_total MONEY(7),
 sales_tax MONEY(9),
 tax_rate DECIMAL(5,3)
--* Get customer's company name and state (for later tax evaluation)
 SELECT company, state
 INTO gr_custsum.company, cust_state
 FROM customer
 WHERE customer_num = gr_custsum.customer_num
--* Calculate number of unpaid orders for customer
 SELECT COUNT(*)
 INTO gr_custsum.unpaid_ords
 FROM orders
 WHERE customer_num = gr_custsum.customer_num
 AND paid_date IS NULL
--* If customer has unpaid orders, calculate total amount due
 IF (gr_custsum.unpaid_ords > 0) THEN
 SELECT SUM(total_price)
 INTO item_total
 FROM items, orders
 WHERE orders.order_num = items.order_num
 AND customer_num = gr_custsum.customer_num
 AND paid_date IS NULL
 SELECT SUM(ship_charge)
 INTO ship_total
 FROM orders
 WHERE customer_num = gr_custsum.customer_num
 AND paid_date IS NULL
 LET tax_rate = 0.00
 CALL tax_rates(cust_state) RETURNING tax_rate
 LET sales_tax = item_total * (tax_rate / 100)
 LET gr_custsum.amount_due = item_total + sales_tax + ship_total
--* If customer has no unpaid orders, total amount due = $0.00
 ELSE
 LET gr_custsum.amount_due = 0.00
 END IF
 --* Calculate number of open calls for this customer
 SELECT COUNT(*)
 INTO gr_custsum.open_calls
 FROM cust_calls
 WHERE customer_num = gr_custsum.customer_num
 AND res_dtime IS NULL
END FUNCTION -- get_summary --

########################################
FUNCTION dsply_summary()
########################################
 DEFINE get_more SMALLINT
 OPEN FORM f_custsum FROM "f_custsum"
 DISPLAY FORM f_custsum
 DISPLAY " "
 AT 2, 20
 CALL get_summary()
 DISPLAY BY NAME gr_custsum.*
 LET ga_dsplymsg[1] = "Customer summary for customer ",
 gr_custsum.customer_num USING "<<<<<<<<<<<"
 LET ga_dsplymsg[2] = " (", gr_custsum.company CLIPPED, ") complete."
 LET get_more = TRUE
 IF NOT prompt_window("Do you want to see another summary?",14,12)
 THEN
 LET get_more = FALSE
 END IF
 RETURN get_more
 CLOSE FORM f_custsum
END FUNCTION -- dsply_summary --

########################################
FUNCTION tax_rates(state_code)
########################################
 DEFINE state_code LIKE state.code,
 tax_rate DECIMAL(4,2)
 CASE state_code[1]
 WHEN "A"
 CASE state_code
 WHEN "AK"
 LET tax_rate = 0.0
 WHEN "AL"
 LET tax_rate = 0.0
 WHEN "AR"
 LET tax_rate = 0.0
 WHEN "AZ"
 LET tax_rate = 5.5
 END CASE
 WHEN "C"
 CASE state_code
 WHEN "CA"
 LET tax_rate = 6.5
 WHEN "CO"
 LET tax_rate = 3.7
 WHEN "CT"
 LET tax_rate = 8.0
 END CASE
 WHEN "D"
 LET tax_rate = 0.0 -- * tax rate for "DE"
 OTHERWISE
 LET tax_rate = 0.0
 END CASE
 RETURN (tax_rate)
END FUNCTION -- tax_rates --

#######################################
 FUNCTION prompt_window(question, x,y)
#######################################
 DEFINE question CHAR(48),
 x,y SMALLINT,
 numrows SMALLINT,
 rownum,i SMALLINT,
 answer CHAR(1),
 yes_ans SMALLINT,
 ny_added SMALLINT,
 invalid_resp SMALLINT,
 ques_lngth SMALLINT,
 unopen SMALLINT,
 array_sz SMALLINT,
 local_stat SMALLINT
 LET array_sz = 5
 LET numrows = 4 -- * numrows value:
 -- * 1 (for the window header)
 -- * 1 (for the window border)
 -- * 1 (for the empty line before
 -- * the first line of message)
 -- * 1 (for the empty line after
 -- * the last line of message)
 FOR i = 1 TO array_sz
 IF ga_dsplymsg[i] IS NOT NULL THEN
 LET numrows = numrows + 1
 END IF
 END FOR
 LET unopen = TRUE
 WHILE unopen
 WHENEVER ERROR CONTINUE
 OPEN WINDOW w_prompt AT x, y
 WITH numrows ROWS, 52 COLUMNS
 ATTRIBUTE (BORDER, PROMPT LINE LAST)
WHENEVER ERROR STOP
 LET local_stat = status
 IF (local_stat < 0) THEN
 IF (local_stat = -1138) OR (local_stat = -1144) THEN
 MESSAGE "prompt_window() error: changing coordinates to 3,3."
 SLEEP 2
 LET x = 3
 LET y = 3
 ELSE
 MESSAGE "prompt_window() error: ", local_stat USING "-<<<<<<<<<<<"
 SLEEP 2
 EXIT PROGRAM
 END IF
 ELSE
 LET unopen = FALSE
 END IF
 END WHILE
 DISPLAY " APPLICATION PROMPT" AT 1, 17
 ATTRIBUTE (REVERSE, BLUE)
 LET rownum = 3 -- * start text display at third line
 FOR i = 1 TO array_sz
 IF ga_dsplymsg[i] IS NOT NULL THEN
 DISPLAY ga_dsplymsg[i] CLIPPED AT rownum, 2
 LET rownum = rownum + 1
 END IF
 END FOR
 LET yes_ans = FALSE
 LET ques_lngth = LENGTH(question)
 IF ques_lngth <= 41 THEN -- * room enough to add "(n/y)" string
 LET question [ques_lngth + 2, ques_lngth + 7] = "(n/y):"
 END IF
 LET invalid_resp = TRUE
 WHILE invalid_resp
 PROMPT question CLIPPED, " " FOR answer
 IF answer MATCHES "[nNyY]" THEN
 LET invalid_resp = FALSE
 IF answer MATCHES "[yY]" THEN
 LET yes_ans = TRUE
 END IF
 END IF
 END WHILE
 CALL init_msgs()
 CLOSE WINDOW w_prompt
 RETURN (yes_ans)
END FUNCTION -- prompt_window --

########################################
FUNCTION init_msgs()
########################################
 DEFINE i SMALLINT
FOR i = 1 TO 5
 LET ga_dsplymsg[i] = NULL
 END FOR
END FUNCTION -- init_msgs --
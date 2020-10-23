CREATE TABLE customer
(
	customer_num SERIAL(101),
	fname CHAR(15),
	lname CHAR(15),
	company CHAR(20),
	address1 CHAR(20),
	address2 CHAR(20),
	city CHAR(15),
	state CHAR(2),
	zipcode CHAR(5),
	phone CHAR(18)
);

CREATE TABLE orders
(
	order_num SERIAL(1001),
	order_date DATE,
	customer_num INTEGER,
	ship_instruct CHAR(40),
	backlog CHAR(1),
	po_num CHAR(10),
	ship_date DATE,
	ship_weight DECIMAL(8,2),
	ship_charge MONEY(6),
	paid_date DATE
);

CREATE TABLE items
(
	item_num SMALLINT,
	order_num INTEGER,
	stock_num SMALLINT,
	manu_code CHAR(3),
	quantity SMALLINT,
	total_price MONEY(8,2)
);

CREATE TABLE stock
(
	stock_num SMALLINT,
	manu_code CHAR(3),
	description CHAR(15),
	unit_price MONEY(6,2),
	unit CHAR(4),
	unit_descr CHAR(15)
);

CREATE TABLE catalog
(
	catalog_num SERIAL(10001),
	stock_num SMALLINT,
	manu_code CHAR(3),
	cat_descr TEXT,
	cat_picture BYTE DEFAULT NULL,
	cat_advert VARCHAR(255, 65)
);

CREATE TABLE cust_calls
(
	customer_num INTEGER,
	call_dtime DATETIME YEAR TO MINUTE,
	user_id CHAR(18),
	call_code CHAR(1),
	call_descr CHAR(240),
	res_dtime DATETIME YEAR TO MINUTE,
	res_descr CHAR(240)
);

CREATE TABLE manufact
(
	manu_code CHAR(3),
	manu_name CHAR(15),
	lead_time INTERVAL DAY(3) TO DAY
);

CREATE TABLE state
(
	code CHAR(2),
	sname CHAR(15)
);

INSERT INTO customer VALUES(101, "Ludwig", "Pauli", "All Sports Supplies", "213 Erstwild Court", NULL, "Sunnyvale", "CA", "94086", "408-789-8075");
INSERT INTO customer VALUES(102, "Carole", "Sadler", "Sports Spot", "785 Geary St", NULL, "San Francisco", "CA", "94117", "415-822-1289");
INSERT INTO customer VALUES(103, "Philip", "Currie", "Phil's Sports", "654 Poplar", "P. O. Box 3498", "Palo Alto", "CA", "94303", "415-328-454");

INSERT INTO customer VALUES(104, "Anthony", "Higgins", "Play Ball!", "East Shopping Cntr", "422 Bay Road", "Redwood City", "CA", "94026", "415-368-1100");
INSERT INTO customer VALUES(105, "Raymond", "Vector", "Los Altos Sport", "1899 La Loma Drive", NULL, "Los Alto", "CA", "94022", "415-776-3249");
INSERT INTO customer VALUES(106, "George", "Watson", "Watson & Son", "1143 Carver Place", NULL, "Mountain View", "CA", "94063", "415-389-8789");

INSERT INTO customer VALUES(107, "Charles", "Ream", "Athletic Supplies", "41 Jordan Avenue", NULL, "Palo Alto", "CA", "94304", "415-356-9876");
INSERT INTO customer VALUES(108, "Donald", "Quinn", "Quinn's Sports", "587 Alvarado", NULL, "Redwood City", "CA", "94063", "415-544-8729");
INSERT INTO customer VALUES(109, "Jane", "Miller", "Sport Stuff", "Mayfair Mart", "7345 Ross Blvd", "Sunnyvale", "CA", "94086", "408-723-8789");

INSERT INTO customer VALUES(110, "Roy", "Jaeger", "AA Athletic", "520 Topaz Way", NULL, "Redwood City", "CA", "94062", " 415-743-3611");
INSERT INTO customer VALUES(111, "Frances", "Keyes", "Sports Center", "3199 Sterling Court", NULL, "Sunnyvale", "CA", "94085", "408-277-7245");
INSERT INTO customer VALUES(112, "Margaret", "Lawson", "Runners & Others", "234 Wyandotte Way", NULL, "Los Altos", "CA", "94022", "415-887-7235");

INSERT INTO customer VALUES(113, "Lana", "Beatty", "Sportstown", "654 Oak Grove", NULL, "Menlo Park", "CA", "94025", "415-356-9982");
INSERT INTO customer VALUES(114, "Frank", "Albertson", "Sporting Place", "947 Waverly Place", NULL, "Redwood City", "CA", "94062", "415-886-6677");
INSERT INTO customer VALUES(115, "Alfred", "Grant", "Gold Medal Sports", "776 Gary Avenue", NULL, "Menlo Park", "CA", "94025", "415-356-1123");

INSERT INTO customer VALUES(116, "Jean", "Parmelee", " Olympic City", " 1104 Spinosa Drive", NULL, "Mountain View", "CA", "94040", "415-534-8822");
INSERT INTO customer VALUES(117, "Arnold", "Sipes", " Kids Korner", "850 Lytton Court", NULL, "Redwood City", "CA", "94063", "415-245-4578");
INSERT INTO customer VALUES(118, "Dick", "Baxter", " Blue Ribbon Sports", "5427 College", NULL, "Oakland", "CA", "94609", "415-655-0011");

INSERT INTO customer VALUES(119, "Bob", "Shorter", "The Triathletes Club", "2405 Kings Highway", NULL, "Cherry Hill", "NJ", "08002", "609-663-6079");
INSERT INTO customer VALUES(120, "Fred", "Jewell", "Century Pro Shop", "6627 N. 17th Way", NULL, "Phoenix", "AZ", "85016", "602-265-8754");
INSERT INTO customer VALUES(121, "Jason", "Wallack", "City Sports", "Lake Biltmore Mall", "350 W. 23rd Street", "Wilmington", "DE", "19898", "302-366-7511");
INSERT INTO customer VALUES(122, "Cathy", "O'Brian", "The Sporting Life", "543 Nassau Street", NULL, "Princeton", "NJ", "08540", "609-342-0054");
INSERT INTO customer VALUES(123, "Marvin", "Hanlon", "Bay Sports", "10100 Bay Meadows Rd", "Suite 1020", "Jacksonviille", "FL", "32256", "904-823-4239");
INSERT INTO customer VALUES(124, "Chris", "Putnum", "Putnum's Putters", "4715 S.E. Adams Blvd", "Suite 909C", "Bartlesville", "OK", "74006", "918-355-2074");
INSERT INTO customer VALUES(125, "James", "Henry", "Total Fitness Sports", "1450 Commonwealth Av", NULL, "Brighton", "MA", "02135", "617-232-4159");
INSERT INTO customer VALUES(126, "Eileen", "Neelie", "Neelie's Discount Sp", "2539 South Utica Str", NULL, "Denver", "CO", "80219", "303-936-7731");
INSERT INTO customer VALUES(127, "Kim", "Satifer", "Big Blue Bike Shop", "Blue Island Square", "12222 Gregory Street", "Blue Island", "NY", "60406", "312-944-5691");
INSERT INTO customer VALUES(128, "Frank", "Lessor", "Phoenix University", "Athletic Department", "1817 N. Thomas Road", "Phoenix", "AZ", "85008", "602-533-1817");

INSERT INTO items VALUES(1, 1001, 1, "HRO", 1, 250.00);
INSERT INTO items VALUES(1, 1002, 4, "HSK", 1, 960.00);
INSERT INTO items VALUES(2, 1002, 3, "HSK", 1, 240.00);
INSERT INTO items VALUES(1, 1003, 9, "ANZ", 1, 20.00);
INSERT INTO items VALUES(2, 1003, 8, "ANZ", 1, 840.00);
INSERT INTO items VALUES(3, 1003, 5, "ANZ", 5, 99.00);
INSERT INTO items VALUES(1, 1004, 1, "HRO", 1, 250.00);
INSERT INTO items VALUES(2, 1004, 2, "HRO", 1, 126.00);
INSERT INTO items VALUES(3, 1004, 3, "HSK", 1, 240.00);
INSERT INTO items VALUES(4, 1004, 1, "HSK", 1, 800.00);
INSERT INTO items VALUES(1, 1005, 5, "NRG", 10, 280.00);
INSERT INTO items VALUES(2, 1005, 5, "ANZ", 10, 198.00);
INSERT INTO items VALUES(3, 1005, 6, "SMT", 1, 36.00);
INSERT INTO items VALUES(4, 1005, 6, "ANZ", 1, 48.00);
INSERT INTO items VALUES(1, 1006, 5, "SMT", 5, 125.00);
INSERT INTO items VALUES(2, 1006, 5, "NRG", 5, 140.00);
INSERT INTO items VALUES(3, 1006, 5, "ANZ", 5, 99.00);
INSERT INTO items VALUES(4, 1006, 6, "SMT", 1, 36.00);
INSERT INTO items VALUES(5, 1006, 6, "ANZ", 1, 48.00);
INSERT INTO items VALUES(1, 1007, 1, "HRO", 1, 250.00);
INSERT INTO items VALUES(2, 1007, 2, "HRO", 1, 126.00);
INSERT INTO items VALUES(3, 1007, 3, "HSK", 1, 240.00);
INSERT INTO items VALUES(4, 1007, 4, "HRO", 1, 480.00);
INSERT INTO items VALUES(5, 1007, 7, "HRO", 1, 600.00);
INSERT INTO items VALUES(1, 1008, 8, "ANZ", 1, 840.00);
INSERT INTO items VALUES(2, 1008, 9, "ANZ", 5, 100.00);
INSERT INTO items VALUES(1, 1009, 1, "SMT", 1, 450.00);
INSERT INTO items VALUES(1, 1010, 6, "SMT", 1, 36.00);
INSERT INTO items VALUES(2, 1010, 6, "ANZ", 1, 48.00);
INSERT INTO items VALUES(1, 1011, 5, "ANZ", 5, 99.00);
INSERT INTO items VALUES(1, 1012, 8, "ANZ", 1, 840.00);
INSERT INTO items VALUES(2, 1012, 9, "ANZ", 10, 200.00);
INSERT INTO items VALUES(1, 1013, 5, "ANZ", 1, 19.80);
INSERT INTO items VALUES(2, 1013, 6, "SMT", 1, 36.00);
INSERT INTO items VALUES(3, 1013, 6, "ANZ", 1, 48.00);
INSERT INTO items VALUES(4, 1013, 9, "ANZ", 2, 40.00);
INSERT INTO items VALUES(1, 1014, 4, "HSK", 1, 960.00);
INSERT INTO items VALUES(2, 1014, 4, "HRO", 1, 480.00);
INSERT INTO items VALUES(1, 1015, 1, "SMT", 1, 450.00);
INSERT INTO items VALUES(1, 1016, 101, "SHM", 2, 136.00);
INSERT INTO items VALUES(2, 1016, 109, "PRC", 3, 90.00);
INSERT INTO items VALUES(3, 1016, 110, "HSK", 1, 308.00);
INSERT INTO items VALUES(4, 1016, 114, "PRC", 1, 120.00);
INSERT INTO items VALUES(1, 1017, 201, "NKL", 4, 150.00);
INSERT INTO items VALUES(2, 1017, 202, "KAR", 1, 230.00);
INSERT INTO items VALUES(3, 1017, 301, "SHM", 2, 204.00);
INSERT INTO items VALUES(1, 1018, 307, "PRC", 2, 500.00);
INSERT INTO items VALUES(2, 1018, 302, "KAR", 3, 15.00);
INSERT INTO items VALUES(3, 1018, 110, "PRC", 1, 236.00);
INSERT INTO items VALUES(4, 1018, 5, "SMT", 4, 100.00);
INSERT INTO items VALUES(5, 1018, 304, "HRO", 1, 280.00);
INSERT INTO items VALUES(1, 1019, 111, "SHM", 3, 1499.97);
INSERT INTO items VALUES(1, 1020, 204, "KAR", 2, 90.00);
INSERT INTO items VALUES(2, 1020, 301, "KAR", 4, 348.00);
INSERT INTO items VALUES(1, 1021, 201, "NKL", 2, 75.00);
INSERT INTO items VALUES(2, 1021, 201, "ANZ", 3, 225.00);
INSERT INTO items VALUES(3, 1021, 202, "KAR", 3, 690.00);
INSERT INTO items VALUES(4, 1021, 205, "ANZ", 2, 624.00);
INSERT INTO items VALUES(1, 1022, 309, "HRO", 1, 40.00);
INSERT INTO items VALUES(2, 1022, 303, "PRC", 2, 96.00);
INSERT INTO items VALUES(3, 1022, 6, "ANZ", 2, 96.00);
INSERT INTO items VALUES(1, 1023, 103, "PRC", 2, 40.00);
INSERT INTO items VALUES(2, 1023, 104, "PRC", 2, 116.00);
INSERT INTO items VALUES(3, 1023, 105, "SHM", 1, 80.00);
INSERT INTO items VALUES(4, 1023, 110, "SHM", 1, 228.00);
INSERT INTO items VALUES(5, 1023, 304, "ANZ", 1, 170.00);
INSERT INTO items VALUES(6, 1023, 306, "SHM", 1, 190.00);

INSERT INTO orders VALUES(1001, "05/20/1994", 104, "express", "n", "B77836", "06/01/1994", 20.40, 10.00, "07/22/1994");
INSERT INTO orders VALUES(1002, "05/21/1994", 101, "PO on box; deliver back door only", "n", "9270", "05/26/1994", 50.60, 15.30, "06/03/1994");
INSERT INTO orders VALUES(1003, "05/22/1994", 104, "express", "n", "B77890", "05/23/1994", 35.60, 10.80, "06/14/1994");
INSERT INTO orders VALUES(1004, "05/22/1994", 106, "ring bell twice", "y", "8006", "05/30/1994", 95.80, 19.20, NULL);
INSERT INTO orders VALUES(1005, "05/24/1994", 116, "call before delivery", "n", "2865", "06/09/1994", 80.80, 16.20, "06/21/1994");
INSERT INTO orders VALUES(1006, "05/30/1994", 112, "after 10 am", "y", "Q13557", NULL, 70.80, 14.20, NULL);
INSERT INTO orders VALUES(1007, "05/31/1994", 117, NULL, "n", "278693", "06/05/1994", 125.90, 25.20, NULL);
INSERT INTO orders VALUES(1008, "06/07/1994", 110, "closed Monday", "y", "LZ230", "07/06/1994", 45.60, 13.80, "07/21/1994");
INSERT INTO orders VALUES(1009, "06/14/1994", 111, "next door to grocery", "n", "4745", "06/21/1994", 20.40, 10.00, "08/21/1994");
INSERT INTO orders VALUES(1010, "06/17/1994", 115, "deliver 776 King St. if no answer", "n", "429Q", "06/29/1994", 40.60, 12.30, "08/22/1994");
INSERT INTO orders VALUES(1011, "06/18/1994", 104, "express", "n", "B77897", "07/03/1994", 10.40, 5.00, "08/29/1994");
INSERT INTO orders VALUES(1012, "06/18/1994", 117, NULL, "n", "278701", "06/29/1994", 70.80, 14.20, NULL);
INSERT INTO orders VALUES(1013, "06/22/1994", 104, "express", "n", "B77930", "07/10/1994", 60.80, 12.20, "07/31/1994");
INSERT INTO orders VALUES(1014, "06/25/1994", 106, "ring bell, kick door loudly", "n", "8052", "07/03/1994", 40.60, 12.30, "07/10/1994");
INSERT INTO orders VALUES(1015, "06/27/1994", 110, "closed Mondays", "n", "MA003", "07/16/1994", 20.60, 6.30, "08/31/1994");
INSERT INTO orders VALUES(1016, "06/29/1994", 119, "delivery entrance off Camp St.", "n", "PC6782", "07/12/1994", 35.00, 11.80, NULL);
INSERT INTO orders VALUES(1017, "07/09/1994", 120, "North side of clubhouse", "n", "DM354331", "07/13/1994", 60.00, 18.00, NULL);
INSERT INTO orders VALUES(1018, "07/10/1994", 121, "SW corner of Biltmore Mall", "n", "S22942", "07/13/1994", 70.50, 20.00, "08/06/1994");
INSERT INTO orders VALUES(1019, "07/11/1994", 122, "closed til noon Mondays", "n", "Z55709", "07/16/1994", 90.00, 23.00, "08/06/1994");
INSERT INTO orders VALUES(1020, "07/11/1994", 123, "express", "n", "W2286", "07/16/1994", 14.00, 8.50, "09/20/1994");
INSERT INTO orders VALUES(1021, "07/23/1994", 124, "ask for Elaine", "n", "C3288", "07/25/1994", 40.00, 12.00, "08/22/1994");
INSERT INTO orders VALUES(1022, "07/24/1994", 126, "express", "n", "W9925", "07/30/1994", 15.00, 13.00, "09/02/1994");
INSERT INTO orders VALUES(1023, "07/24/1994", 127, "no deliveries after 3 p.m.", "n", "KF2961", "07/30/1994", 60.00, 18.00 ,"08/22/1994");

INSERT INTO stock VALUES(1, "HRO", "baseball gloves", 250.00, "case", "10 gloves/case");
INSERT INTO stock VALUES(1, "HSK", "baseball gloves", 800.00, "case", "10 gloves/case");
INSERT INTO stock VALUES(1, "SMT", "baseball gloves", 450.00, "case", "10 gloves/case");
INSERT INTO stock VALUES(2, "HRO", "baseball", 126.00, "case", "24/case");
INSERT INTO stock VALUES(3, "HSK", "baseball bat", 240.00, "case", "12/case");
INSERT INTO stock VALUES(4, "HSK", "football", 960.00, "case", "24/case");
INSERT INTO stock VALUES(4, "HRO", "football", 480.00, "case", "24/case");
INSERT INTO stock VALUES(5, "NRG", "tennis racquet", 28.00, "each", "each");
INSERT INTO stock VALUES(5, "SMT", "tennis racquet", 25.00, "each", "each");
INSERT INTO stock VALUES(5, "ANZ", "tennis racquet", 19.80, "each", "each");
INSERT INTO stock VALUES(6, "SMT", "tennis ball", 36.00, "case", "24 cans/case");
INSERT INTO stock VALUES(6, "ANZ", "tennis ball", 48.00, "case", "24 cans/case");
INSERT INTO stock VALUES(7, "HRO", "basketball", 600.00, "case", "24/case");
INSERT INTO stock VALUES(8, "ANZ", "volleyball", 840.00, "case", "24/case");
INSERT INTO stock VALUES(9, "ANZ", "volleyball net", 20.00, "each", "each");
INSERT INTO stock VALUES(101, "PRC", "bicycle tires", 88.00, "box", "4/box");
INSERT INTO stock VALUES(101, "SHM", "bicycle tires", 68.00, "box", "4/box");
INSERT INTO stock VALUES(102, "SHM", "bicycle brakes", 220.00, "case", "4 sets/case");
INSERT INTO stock VALUES(102, "PRC", "bicycle brakes", 480.00, "case", "4 sets/case");
INSERT INTO stock VALUES(103, "PRC", "front derailleur", 20.00, "each", "each");
INSERT INTO stock VALUES(104, "PRC", "rear derailleur", 58.00, "each", "each");
INSERT INTO stock VALUES(105, "PRC", "bicycle wheels", 53.00, "pair", "pair");
INSERT INTO stock VALUES(105, "SHM", "bicycle wheels", 80.00, "pair", "pair");
INSERT INTO stock VALUES(106, "PRC", "bicycle stem", 23.00, "each", "each");
INSERT INTO stock VALUES(107, "PRC", "bicycle saddle", 70.00, "pair", "pair");
INSERT INTO stock VALUES(108, "SHM", "crankset", 45.00, "each", "each");
INSERT INTO stock VALUES(109, "PRC", "pedal binding", 30.00, "case", "6 pairs/case");
INSERT INTO stock VALUES(109, "SHM", "pedal binding", 200.00, "case", "4 pairs/case");
INSERT INTO stock VALUES(110, "PRC", "helmet", 236.00, "case", "4/case");
INSERT INTO stock VALUES(110, "ANZ", "helmet", 244.00, "case", "4/case");
INSERT INTO stock VALUES(110, "SHM", "helmet", 228.00, "case", "4/case");
INSERT INTO stock VALUES(110, "HRO", "helmet", 260.00, "case", "4/case");
INSERT INTO stock VALUES(110, "HSK", "helmet", 308.00, "case", "4/case");
INSERT INTO stock VALUES(111, "SHM", "10-spd, assmbld", 499.99, "each", "each");
INSERT INTO stock VALUES(112, "SHM", "12-spd, assmbld", 549.00, "each", "each");
INSERT INTO stock VALUES(113, "SHM", "18-spd, assmbld", 685.90, "each", "each");
INSERT INTO stock VALUES(114, "PRC", "bicycle gloves", 120.00, "case", "10 pairs/case");
INSERT INTO stock VALUES(201, "NKL", "golf shoes", 37.50, "each", "each");
INSERT INTO stock VALUES(201, "ANZ", "golf shoes", 75.00, "each", "each");
INSERT INTO stock VALUES(201, "KAR", "golf shoes", 90.00, "each", "each");
INSERT INTO stock VALUES(202, "NKL", "metal woods", 174.00, "case", "2 sets/case");
INSERT INTO stock VALUES(202, "KAR", "std woods", 230.00, "case", "2 sets/case");
INSERT INTO stock VALUES(203, "NKL", "irons/wedges", 670.00, "case", "2 sets/case");
INSERT INTO stock VALUES(204, "KAR", "putter", 45.00, "each", "each");
INSERT INTO stock VALUES(205, "NKL", "3 golf balls", 312.00, "case", "24/case");
INSERT INTO stock VALUES(205, "ANZ", "3 golf balls", 312.00, "case", "24/case");
INSERT INTO stock VALUES(205, "HRO", "3 golf balls", 312.00, "case", "24/case");
INSERT INTO stock VALUES(301, "NKL", "running shoes", 97.00, "each", "each");
INSERT INTO stock VALUES(301, "HRO", "running shoes", 42.50, "each", "each");
INSERT INTO stock VALUES(301, "SHM", "running shoes", 102.00, "each", "each");
INSERT INTO stock VALUES(301, "PRC", "running shoes", 75.00, "each", "each");
INSERT INTO stock VALUES(301, "KAR", "running shoes", 87.00, "each", "each");
INSERT INTO stock VALUES(301, "ANZ", "running shoes", 95.00, "each", "each");
INSERT INTO stock VALUES(302, "HRO", "ice pack", 4.50, "each", "each");
INSERT INTO stock VALUES(302, "KAR", "ice pack", 5.00, "each", "each");
INSERT INTO stock VALUES(303, "PRC", "socks", 48.00, "box", "24 pairs/box");
INSERT INTO stock VALUES(303, "KAR", "socks", 36.00, "box", "24 pair/box");
INSERT INTO stock VALUES(304, "ANZ", "watch", 170.00, "box", "10/box");
INSERT INTO stock VALUES(304, "HRO", "watch", 280.00, "box", "10/box");
INSERT INTO stock VALUES(305, "HRO", "first-aid kit", 48.00, "case", "4/case");
INSERT INTO stock VALUES(306, "PRC", "tandem adapter", 160.00, "each", "each");
INSERT INTO stock VALUES(306, "SHM", "tandem adapter", 190.00, "each", "each");
INSERT INTO stock VALUES(307, "PRC", "infant jogger", 250.00, "each", "each");
INSERT INTO stock VALUES(308, "PRC", "twin jogger", 280.00, "each", "each");
INSERT INTO stock VALUES(309, "HRO", "ear drops", 40.00, "case", "20/case");
INSERT INTO stock VALUES(309, "SHM", "ear drops", 40.00, "case", "20/case");
INSERT INTO stock VALUES(310, "SHM", "kick board", 80.00, "case", "10/case");
INSERT INTO stock VALUES(310, "ANZ", "kick board", 89.00, "case", "12/case");
INSERT INTO stock VALUES(311, "SHM", "water gloves", 48.00, "box", "4 pairs/box");
INSERT INTO stock VALUES(312, "SHM", "racer goggles", 96.00, "box", "12/box");
INSERT INTO stock VALUES(312, "HRO", "racer goggles", 72.00, "box", "12/box");
INSERT INTO stock VALUES(313, "SHM", "swim cap", 72.00, "box", "12/box");
INSERT INTO stock VALUES(313, "ANZ", "swim cap", 60.00, "box", "12/box");

INSERT INTO cust_calls VALUES(106, "1994-06-12 8:20", "maryj", "D", "Order was received, but two of the cans of ANZ tennis balls within the case were empty", "1994-06-12 8:25", "Authorized credit for two cans to customer, issued apology. Called ANZ buyer to report the QA problem.");
INSERT INTO cust_calls VALUES(110, "1994-07-07 10:24", "richc", "L", "Order placed one month ago (6/7) not received.", "1994-07-07 10:30", "Checked with shipping (Ed Smith). Order sent yesterday- we were waiting for goods from ANZ. Next time will call with delay if necessary.");
INSERT INTO cust_calls VALUES(119, "1994-07-01 15:00", "richc", "B", "Bill does not reflect credit from previous order", "1994-07-02 8:21", "Spoke with Jane Akant in Finance. She found the error and is sending new bill to customer");
INSERT INTO cust_calls VALUES(121, "1994-07-10 14:05", "maryj", "O", "Customer likes our merchandise. Requests that we stock more types of infant joggers. Will call back to place order.", "1994-07-10 14:06", "Sent note to marketing group of interest in infant joggers");
INSERT INTO cust_calls VALUES(127, "1994-07-31 14:30", "maryj", "I", "Received Hero watches (item # 304) instead of ANZ watches", NULL, "Sent note to marketing group of interest in infant joggers Sent memo to shipping to send ANZ item 304 to customer and pickup HRO watches. Should be done tomorrow, 8/1");
INSERT INTO cust_calls VALUES(116, "1989-11-28 13:34", "mannyn", "I", "Received plain white swim caps (313 ANZ) instead of navy with team logo (313 SHM)", "1989-11-28 16:47", "Shipping found correct case in warehouse and express mailed it in time for swim meet.");
INSERT INTO cust_calls VALUES(116, "1989-12-21 11:24", "mannyn", "I", "Second complaint from this customer! Received two cases right-handed outfielder gloves (1 HRO) instead of one case lefties.", "1989-12-27 08:19", "Memo to shipping (Ava Brown) to send case of left-handed gloves, pick up wrong case; memo to billing requesting 5% discount to placate customer due to second offense and lateness of resolution because of holiday");

INSERT INTO manufact VALUES("ANZ", "Anza", "5");
INSERT INTO manufact VALUES("HSK", "Husky", "5");
INSERT INTO manufact VALUES("HRO", "Hero", "4");
INSERT INTO manufact VALUES("NRG", "Norge", "7");
INSERT INTO manufact VALUES("SMT", "Smith", "3");
INSERT INTO manufact VALUES("SHM", "Shimara", "30");
INSERT INTO manufact VALUES("KAR", "Karsten", "21");
INSERT INTO manufact VALUES("NKL", "Nikolus", "8");
INSERT INTO manufact VALUES("PRC", "ProCycle", "9");


INSERT INTO state VALUES("AK", "Alaska");
INSERT INTO state VALUES("MT", "Montana");
INSERT INTO state VALUES("AL", "Alabama");
INSERT INTO state VALUES("NE", "Nebraska");
INSERT INTO state VALUES("AR", "Arkansas");
INSERT INTO state VALUES("NC", "North Carolina");
INSERT INTO state VALUES("AZ", "Arizona");
INSERT INTO state VALUES("ND", "North Dakota");
INSERT INTO state VALUES("CA", "California");
INSERT INTO state VALUES("NH", "New Hampshire");
INSERT INTO state VALUES("CT", "Connecticut");
INSERT INTO state VALUES("NJ", "New Jersey");
INSERT INTO state VALUES("CO", "Colorado");
INSERT INTO state VALUES("NM", "New Mexico");
INSERT INTO state VALUES("D.C.", "DC");
INSERT INTO state VALUES("NV", "Nevada");
INSERT INTO state VALUES("DE", "Delaware");
INSERT INTO state VALUES("NY", "New York");
INSERT INTO state VALUES("FL", "Florida");
INSERT INTO state VALUES("OH", "Ohio");
INSERT INTO state VALUES("GA", "Georgia");
INSERT INTO state VALUES("OK", "Oklahoma");
INSERT INTO state VALUES("HI", "Hawaii");
INSERT INTO state VALUES("OR", "Oregon");
INSERT INTO state VALUES("IA", "Iowa");
INSERT INTO state VALUES("PA", "Pennsylvania");
INSERT INTO state VALUES("ID", "Idaho");
INSERT INTO state VALUES("PR", "Puerto Rico");
INSERT INTO state VALUES("IL", "Illinois");
INSERT INTO state VALUES("RI", "Rhode Island");
INSERT INTO state VALUES("IN", "Indiana");
INSERT INTO state VALUES("SC", "South Carolina");
INSERT INTO state VALUES("KS", "Kansas");
INSERT INTO state VALUES("SD", "South Dakota");
INSERT INTO state VALUES("KY", "Kentucky");
INSERT INTO state VALUES("TN", "Tennessee");
INSERT INTO state VALUES("LA", "Louisiana");
INSERT INTO state VALUES("TX", "Texas");
INSERT INTO state VALUES("MA", "Massachusetts");
INSERT INTO state VALUES("UT", "Utah");
INSERT INTO state VALUES("MD", "Maryland");
INSERT INTO state VALUES("VA", "Virginia");
INSERT INTO state VALUES("ME", "Maine");
INSERT INTO state VALUES("VT", "Vermont");
INSERT INTO state VALUES("MI", "Michigan");
INSERT INTO state VALUES("WA", "Washington");
INSERT INTO state VALUES("MN", "Minnesota");
INSERT INTO state VALUES("WI", "Wisconsin");
INSERT INTO state VALUES("MO", "Missouri");
INSERT INTO state VALUES("WV", "West Virginia");
INSERT INTO state VALUES("MS", "Mississippi");
INSERT INTO state VALUES("WY", "Wyoming");
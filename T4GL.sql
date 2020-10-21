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
--------------------------------------------------------------
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10001, 1, "HRO", "Brown leather. Specify first baseman's or infield/outfield style. Specify rightor left-handed.", "Your First Season's Baseball Glove");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10002, 1, "HSK", "Babe Ruth signature glove. Black leather. Infield/outfield style. Specify right- or
left-handed", "All-Leather, Hand-Stitched, DeepPockets, Sturdy Webbing that Won't Let Go");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10003, 1, "SMT", "Catcher's mitt. Brown leather. Specify right- or left-handed.", "A Sturdy Catcher's Mitt With the Perfect Pocke");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10004, 2, "HRO", "Jackie Robinson signature glove. Highest Professional quality, used by National League.", "Highest Quality Ball Available, from the Hand-Stitching to the Robinson Signatur");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10005, 3, "HSK", "Pro-style wood. Available in sizes: 31, 32, 33, 34, 35.", "High-Technology Design Expands the Sweet Spot");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10006, 3, "SHM", "Aluminum. Blue with black tape. 31\"", 20 oz or 22 oz; 32\"", 21 oz or 23 oz; 33\"",
22 oz or 24 oz;", "Durable Aluminum for High School and Collegiate Athletes");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10007, 4, "HSK", "Norm Van Brocklin signature style.", "Quality Pigskin with Norm Van Brocklin
Signature");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10008, 4, "HRO", "NFL-Style pigskin.", " Highest Quality Football for High School and Collegiate Competitions");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10009, 5, "NRG", "Graphite frame. Synthetic strings.", "Wide Body Amplifies Your Natural Abilities by Providing More Power Through Aerodynamic Design");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10010, 5, "SMT", "Aluminum frame. Synthetic strings", "Mid-Sized Racquet For the Improving Player");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10011, 5, "ANZ", "Wood frame, cat-gut strings.", "Antique Replica of Classic Wooden Racquet Built with Cat-Gut Strings");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10012, 6, "SMT", "Soft yellow color for easy visibility in sunlight or artificial light", "High-Visibility Tennis, Day or Night");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10013, 6, "ANZ", "Pro-core. Available in neon yellow, green, and pink.", "Durable Construction Coupled with the Brightest Colors Available");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10014, 7, "HRO", "Indoor. Classic NBA style. Brown leather.", "Long-Life Basketballs for Indoor Gymnasiums");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10015, 8, "ANZ", "Indoor. Finest leather. Professional quality.", "Professional Volleyballs for Indoor Competitions");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10016, 9, "ANZ", "Steel eyelets. Nylon cording. Doublestitched. Sanctioned by the National Athletic Congress", " Sanctioned Volleyball Netting for Indoor Professional and Collegiate Competition");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10017, 101, "PRC", "Reinforced, hand-finished tubular. Polyurethane belted. Effective against punctures. Mixed tread for super wear and road grip.", "Ultimate in Puncture Protection, Tires Designed for In-City Riding");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10018, 101, "SHM", "Durable nylon casing with butyl tube for superior air retention. Center-ribbed tread with herringbone side. Coated sidewalls resist abrasion.", "The Perfect Tire for Club Rides or Training");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10019, 102, "SHM", "Thrust bearing and coated pivot washer/spring sleeve for smooth action. Slotted levers with soft gum hoods. Two-tone paint treatment. Set includes calipers, levers, and cables.", "Thrust-Bearing and Spring-Sleeve Brake Set Guarantees Smooth Action");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10020, 102, "PRC", "Computer-aided design with low-profile pads. Cold-forged alloy calipers and beefy caliper bushing. Aero levers. Set includes calipers, levers, and cables", "Computer Design Delivers Rigid Yet Vibration-Free Brakes");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10021, 103, "PRC", "Compact leading-action design enhances shifting. Deep cage for super-small granny gears. Extra strong construction to resist off-road abuse.", "Climb Any Mountain: ProCycle’s Front Derailleur Adds Finesse to Your ATB");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10022, 104, "PRC", "Floating trapezoid geometry with extra thick parallelogram arms. 100-tooth capacity. Optimum alignment with any freewheel.", " Computer-Aided Design Engineers 100-Tooth Capacity Into ProCycle’s Rear Derailleur");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10023, 105, "PRC", "Front wheels laced with 15g spokes in a 3-cross pattern. Rear wheels laced with 14g spikes in a 3-cross pattern.", "Durable Training Wheels That Hold True Under Toughest Conditions");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10024, 105, "SHM", "Polished alloy. Sealed-bearing, quickrelease hubs. Double-butted. Front wheels are laced 15g/2-cross. Rear wheels are laced 15g/3-cross.", "Extra Lightweight Wheels for Training or High-Performance Touring");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10025, 106, "PRC", "Hard anodized alloy with pearl finish. 6mm hex bolt hardware. Available in lengths of 90-140mm in 10mm increments.", "ProCycle Stem with Pearl Finish");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10026, 107, "PRC", "Available in three styles: Mens racing; Mens touring; and Womens. Anatomical gel construction with lycra cover. Black or black/hot pink.", "The Ultimate In Riding Comfort, Lightweight With Anatomical Support");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10027, 108, "SHM", "Double or triple crankset with choice of chainrings. For double crankset, chainrings from 38-54 teeth. For triple crankset, chainrings from 24-48 teeth.", "Customize Your Mountain Bike With Extra-Durable Crankset");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10028, 109, "PRC", "Steel toe clips with nylon strap. Extra wide at buckle to reduce pressure.", "Classic Toeclip Improved To Prevent Soreness At Clip Buckle");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10029, 109, "SHM", "Ingenious new design combines button on sole of shoe with slot on a pedal plate to give riders new options in riding efficiency. Choose full or partial locking. Four plates mean both top and bottom of pedals are slotted—no fishing around when you want to engage full power. Fast unlocking ensures safety when maneuverability is paramount.", "Ingenious Pedal/Clip Design Delivers Maximum Power And Fast Unlocking");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10030, 110, "PRC", "Super-lightweight. Meets both ANZI and Snell standards for impact protection. 7.5 oz. Quick-release shadow buckle.", "Feather-Light, Quick-Release, Maximum Protection Helmet");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10031, 110, "ANZ", "No buckle so no plastic touches your chin. Meets both ANZI and Snell standards for impact protection. 7.5 oz. Lycra cover.", "Minimum Chin Contact, Feather-Light, Maximum Protection Helmet");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10032, 110, "SHM", "Dense outer layer combines with softer inner layer to eliminate the mesh cover, no snagging on brush. Meets both ANZI and Snell standards for impact protection. 8.0 oz.", " Mountain Bike Helmet: Smooth Cover Eliminates the Worry of Brush Snags But Delivers Maximum Protection");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10033, 110, "HRO", "Newest ultralight helmet uses plastic shell. Largest ventilation channels of any helmet on the market. 8.5 oz.", "Lightweight Plastic with Vents Assures Cool Comfort Without Sacrificing Protection");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10034, 110, "HSK", "Aerodynamic (teardrop) helmet covered with anti-drag fabric. Credited with shaving 2 seconds/mile from winner’s time in Tour de France time-trial. 7.5 oz.", " Teardrop Design Used by Yellow Jerseys, You Can Time the Difference");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10035, 111, "SHM", "Light-action shifting 10 speed. Designed for the city commuter with shock-absorbing front fork and drilled eyelets for carryall racks or bicycle trailers. Internal wiring for generator lights. 33 lbs.", "Fully Equipped Bicycle Designed for the Serious Commuter Who Mixes Business With Pleasure");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10036, 112, "SHM", "Created for the beginner enthusiast. Ideal for club rides and light touring. Sophisticated triple-butted frame construction. Precise index shifting. 28 lbs.", " We Selected the Ideal Combination of Touring Bike Equipment, Then Turned It Into This Package Deal: High-Perfor- mance on the Roads, Maximum Plea- sure Everywhere");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10037, 113, "SHM", "Ultra-lightweight. Racing frame geometry built for aerodynamic handlebars. Cantilever brakes. Index shifting. Highperformance gearing. Quick-release hubs. Disk wheels. Bladed spokes.", "Designed for the Serious Competitor, The Complete Racing Machine");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10038, 114, "PRC", "Padded leather palm and stretch mesh merged with terry back; Available in tan, black, and cream. Sizes S, M, L, XL.", " Riding Gloves For Comfort and Protection");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10039, 201, "NKL", " Designed for comfort and stability. Available in white & blue or white & brown. Specify size.", "Full-Comfort, Long-Wearing Golf Shoes for Men and Women");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10040, 201, "ANZ", "Guaranteed waterproof. Full leather upper. Available in white, bone, brown, green, and blue. Specify size."," Waterproof Protection Ensures Maximum Comfort and Durability In All Climates");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10041, 201, "KAR", "Leather and leather mesh for maximum ventilation. Waterproof lining to keep feet dry. Available in white & gray or white & ivory. Specify size.", "Karsten’s Top Quality Shoe Combines Leather and Leather Mesh");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10042, 202, "NKL", "Complete starter set utilizes gold shafts. Balanced for power.", "Starter Set of Woods, Ideal for High School and Collegiate Classes");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10043, 202, "KAR", "Full set of woods designed for precision control and power performance.", "High-Quality Woods Appropriate for High School Competitions or Serious Amateurs");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10044, 203, "NKL", "Set of eight irons includes 3 through 9 irons and pitching wedge. Originally priced at $489.00.", "Set of Irons Available From Factory at Tremendous Savings: Discontinued Line");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10045, 204, "KAR", "Ideally balanced for optimum control. Nylon-covered shaft.", "High-Quality Beginning Set of Irons Appropriate for High School Competitions");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10046, 205, "NKL", "Fluorescent yellow.", " Long Drive Golf Balls: Fluorescent Yellow");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10047, 205, "ANZ", "White only.", "Long Drive Golf Balls: White");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10048, 205, "HRO", "Combination fluorescent yellow and standard white.", "HiFlier Golf Balls: Case IncludesFluorescent Yellow and Standard White");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10049, 301, "NKL", "Super shock-absorbing gel pads dispersevertical energy into a horizontal plane for extraordinary cushioned comfort. Great motion control. Mens only. Specify size.", "Maximum Protection For High-Mileage Runners");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10050, 301, "HRO",  "Engineered for serious training with exceptional stability. Fabulous shock absorption. Great durability. Specify mens/womens, size.", "Pronators and Supinators Take Heart: A Serious Training Shoe For Runners Who Need Motion Control"); 
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10051, 301, "SHM",  "For runners who log heavy miles and need a durable, supportive, stable platform. Mesh/synthetic upper gives excellent moisture dissipation. Stability system uses rear antipronation platform and forefoot control plate for extended protection during high-intensity training. Specify mens/ womens, size.", "The Training Shoe Engineered for Marathoners and Ultra-Distance Runners");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10052, 301, "PRC", "Supportive, stable racing flat. Plenty of forefoot cushioning with added motion control. Womens only. D widths available. Specify size.", "A Woman’s Racing Flat That Combines Extra Forefoot Protection With a Slender Heel");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10053, 301, "KAR", "Anatomical last holds your foot firmly in place. Feather-weight cushioning delivers the responsiveness of a racing flat. Specify mens/womens, size.", "Durable Training Flat That Can Carry You Through Marathon Miles");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10054, 301, "ANZ", "Cantilever sole provides shock absorption and energy rebound. Positive traction shoe with ample toe box. Ideal for runners who need a wide shoe. Available in mens and womens. Specify size.", "Motion Control, Protection, and Extra Toebox Room");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10055, 302, "KAR", "Re-usable ice pack with velcro strap. For general use. Velcro strap allows easy application to arms or legs.", " Finally, An Ice Pack for Achilles Injuries and Shin Splints that You Can Take to the Office");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10056, 303, "PRC", "Neon nylon. Perfect for running or aerobics. Indicate color: Fluorescent pink, yellow, green, and orange.", "Knock Their Socks Off With YOUR Socks!");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10057, 303, "KAR", "100% nylon blend for optimal wicking and comfort. We’ve taken out the cotton to eliminate the risk of blisters and reduce the opportunity for infection. Specify mens or wome", "100% Nylon Blend Socks - No Cotton!");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10058, 304, "ANZ", "Provides time, date, dual display of lap/cumulative splits, 4-lap memory, 10hr count-down timer, event timer, alarm, hour chime, waterproof to 50m, velcro band.", "Athletic Watch w/4-Lap Memory");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10059, 304, "HRO", "Split timer, waterproof to 50m. Indicate color: Hot pink, mint green, space black.", "Waterproof Triathlete Watch In Competition Colors");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10060, 305, "HRO", "Contains ace bandage, anti-bacterial cream, alcohol cleansing pads, adhesive bandages of assorted sizes, and instantcold pack.", "Comprehensive First-Aid Kit Essential for Team Practices, Team Traveling");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10061, 306, "PRC", "Converts a standard tandem bike into an adult/child bike. User-tested Assembly Instructions", "Enjoy Bicycling With Your Child On a Tandem; Make Your Family Outing Safer");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10062, 306, "SHM", "Converts a standard tandem bike into an adult/child bike. Lightweight model.", "Consider a Touring Vacation For the Entire Family: A Lightweight, Touring Tandem for Parent and Child");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10063, 307, "PRC", "Allows mom or dad to take the baby out, too. Fits children up to 21 pounds. Navy blue with black trim.", "Infant Jogger Keeps A Running Family Together");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10064, 308, "PRC", "Allows mom or dad to take both children! Rated for children up to 18 pounds.", "As Your Family Grows, Infant Jogger Grows With You");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10065, 309, "HRO", "Prevents swimmer’s ear.", "Swimmers Can Prevent Ear Infection All Season Long");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10066, 309, "SHM", "Extra-gentle formula. Can be used every day for prevention or treatment of swimmer’s ear.", "Swimmer’s Ear Drops Specially Formulated for Children");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10067, 310, "SHM", "Blue heavy-duty foam board with Shimara or team logo.", "Exceptionally Durable, Compact Kickboard for Team Practice");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10068, 310, "ANZ", "White. Standard size.", "High-Quality Kickboard");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10069, 311, "SHM", "Swim gloves. Webbing between fingers promotes strengthening of arms. Cannot be used in competition.", "Hot Training Tool - Webbed Swim Gloves Build Arm Strength and Endurance");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10070, 312, "SHM", "Hydrodynamic egg-shaped lens. Ground-in anti-fog elements; Available in blue or smoke.", "Anti-Fog Swimmer’s Goggles: Quantity Discount.");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10071, 312, "HRO", "Durable competition-style goggles. Available in blue, grey, or white.", "Swim Goggles: Traditional Rounded Lens For Greater Comfort.");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10072, 313, "SHM", "Silicone swim cap. One size. Available in white, silver, or navy. Team Logo Imprinting Available", "Team Logo Silicone Swim Cap");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10073, 313, "ANZ", "Silicone swim cap. Squared-off top. One size. White.", "Durable Squared-off Silicone Swim Cap");
INSERT INTO catalog (catalog_num, stock_num, manu_code, cat_descr, cat_advert) VALUES(10074, 302, "HRO", "Re-usable ice pack. Store in the freezer for instant first-aid. Extra capacity to accommodate water and ice.", "Water Compartment Combines With Ice to Provide Optimal Orthopedic Treatment");

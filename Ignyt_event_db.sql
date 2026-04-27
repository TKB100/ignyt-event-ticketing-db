/* =========================================================
   IGNYT: Event Ticketing & Management Platform
   CS4354 - Database Systems
   This script includes:
   1) DDL (database + tables)
   2) Sample data / instances
   3) Views for different user types
   4) Basic DML examples
   5) Complex DML examples
   All queries are commented for readability per rubric.
   ========================================================= */
   
/* =========================================================
   SECTION 0: CREATE / SELECT DATABASE
   ========================================================= */

drop database if exists Ignyt;
create database Ignyt;
use Ignyt;

/* =========================================================
   SECTION 1: DROP TABLES IN SAFE ORDER
   ========================================================= */

DROP VIEW IF EXISTS guest_event_view;
DROP VIEW IF EXISTS attendee_ticket_history_view;
DROP VIEW IF EXISTS organizer_event_sales_view;
DROP VIEW IF EXISTS admin_user_overview_view;

DROP TABLE IF EXISTS Review;
DROP TABLE IF EXISTS Payment;
DROP TABLE IF EXISTS Ticket;
DROP TABLE IF EXISTS Ticket_order;
DROP TABLE IF EXISTS Ticket_tier;
DROP TABLE IF EXISTS Seat;
DROP TABLE IF EXISTS Section;
DROP TABLE IF EXISTS public_event;
DROP TABLE IF EXISTS campus_event;
DROP TABLE IF EXISTS sports_event;
DROP TABLE IF EXISTS concert_event;
DROP TABLE IF EXISTS Event;
DROP TABLE IF EXISTS Venue;
DROP TABLE IF EXISTS Admin;
DROP TABLE IF EXISTS Attendee;
DROP TABLE IF EXISTS Organizer;
DROP TABLE IF EXISTS User;

/* =========================================================
   SECTION 2: DDL IMPLEMENTATION
   ========================================================= */

/* Main user table for all platform users */   
create table User (
user_ID			INT 	PRIMARY KEY 	AUTO_INCREMENT,			
email			VARCHAR(255) 	NOT NULL 	UNIQUE,
fname			VARCHAR(100) 	NOT NULL,
lname			VARCHAR(100) 	NOT NULL,
phone			VARCHAR(100),
payment_method 	VARCHAR(50)
);

/* Attendee subtype: each attendee is a user */
create table Attendee (
user_ID		INT 	PRIMARY KEY,
FOREIGN KEY (user_ID) REFERENCES User(user_ID)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);

/* Organizer subtype: each organizer is a user */
create table Organizer (
user_ID 	INT 	NOT NULL UNIQUE,
creator_ID	INT 	PRIMARY KEY 	AUTO_INCREMENT,
FOREIGN KEY (user_ID) REFERENCES User(user_ID)
	ON DELETE CASCADE
    ON UPDATE CASCADE
);

/* Admin subtype: each admin is a user */
create table Admin (
user_ID 	INT 	PRIMARY KEY,
FOREIGN KEY (user_ID) REFERENCES User(user_ID)
	ON DELETE CASCADE
    ON UPDATE CASCADE
);

/* Venue table: stores venue information */
create table Venue (
venue_ID 	INT 	PRIMARY KEY 	AUTO_INCREMENT,
venue_name 	VARCHAR(255) 	NOT NULL,
addr 		VARCHAR(255) 	NOT NULL,
capacity 	INT 	NOT NULL CHECK (capacity >= 0)
);

/* Section table: a venue can have multiple sections */
create table Section (
section_ID INT 		PRIMARY KEY 	AUTO_INCREMENT,
venue_ID   INT 		NOT NULL,
section_name 		VARCHAR(50) 	NOT NULL,
FOREIGN KEY (venue_ID) REFERENCES Venue(venue_ID)
	ON DELETE CASCADE
    ON UPDATE CASCADE
);

/* Seat table: a section can have multiple seats */
create table Seat (
seat_ID 	INT 	PRIMARY KEY 	AUTO_INCREMENT,
section_ID 	INT 			NOT NULL,
row_no 		VARCHAR(10) 	NOT NULL,
seat_no 	INT 			NOT NULL,
FOREIGN KEY (section_ID) REFERENCES Section(section_ID)
	ON DELETE CASCADE
    ON UPDATE CASCADE
);

/* Event table: each event is created by exactly one organizer
   and occurs at exactly one venue */
create table Event(
event_ID	INT 			NOT NULL	PRIMARY KEY		AUTO_INCREMENT,
creator_ID 	INT 			NOT NULL,
venue_ID 	INT 			NOT NULL,
event_title VARCHAR(255) 	NOT NULL,
event_desc	TEXT,
event_date	DATE			NOT NULL,
event_time	TIME			NOT NULL,
event_type 	ENUM('concert', 'sports', 'campus', 'public')	NOT NULL,
FOREIGN KEY (creator_ID) REFERENCES Organizer(creator_ID)
	ON DELETE RESTRICT
    ON UPDATE CASCADE,
FOREIGN KEY (venue_id) REFERENCES Venue(venue_ID)
	ON DELETE RESTRICT
    ON UPDATE CASCADE
);

/* Event subtype: each concert is an event */
create table concert_event (
event_ID	INT 	PRIMARY KEY,
FOREIGN KEY (event_ID) REFERENCES Event(event_ID)
	ON DELETE CASCADE
    ON UPDATE CASCADE
);

/* Event subtype: each sport is an event */
create table sports_event (
event_ID	INT 	PRIMARY KEY,
FOREIGN KEY (event_ID) REFERENCES Event(event_ID)
	ON DELETE CASCADE
    ON UPDATE CASCADE
);

/* Event subtype: each campus is an event */
create table campus_event (
event_ID	INT 	PRIMARY KEY,
FOREIGN KEY (event_ID) REFERENCES Event(event_ID)
	ON DELETE CASCADE
    ON UPDATE CASCADE
);

/* Event subtype: each public is an event */
create table public_event (
event_ID	INT 	PRIMARY KEY,
FOREIGN KEY (event_ID) REFERENCES Event(event_ID)
	ON DELETE CASCADE
    ON UPDATE CASCADE
);

/* Ticket tier table: pricing categories for an event */
create table Ticket_tier (
tier_ID 	INT 			PRIMARY KEY 	AUTO_INCREMENT,
event_ID 	INT 			NOT NULL,
tier_name 	VARCHAR(100) 	NOT NULL,
price 		DECIMAL(10,2) 	NOT NULL CHECK (price >= 0),
check_status	BOOLEAN 		NOT NULL DEFAULT TRUE,
FOREIGN KEY (event_ID) REFERENCES Event(event_ID)
	ON DELETE CASCADE
    ON UPDATE CASCADE
);

/* Order table: one attendee places an order */
create table Ticket_order (
order_ID 	INT 	PRIMARY KEY 	AUTO_INCREMENT,
user_ID 	INT 	NOT NULL,
order_amount 	DECIMAL(10,2) 	NOT NULL CHECK (order_amount >= 0),
order_date 	DATETIME 	NOT NULL DEFAULT CURRENT_TIMESTAMP,
FOREIGN KEY (user_ID) REFERENCES attendee(user_ID)
	ON DELETE RESTRICT
    ON UPDATE CASCADE
);

/* Ticket table: tickets belong to an order and event.
   Seat can be NULL for general admission tickets. */
create table Ticket (
ticket_ID 	INT 	PRIMARY KEY 	AUTO_INCREMENT,
order_ID 	INT 	NOT NULL,
event_ID  	INT 	NOT NULL,
tier_ID 	INT 	NOT NULL,
seat_ID 	INT 	NULL,
issued_at 	DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
status ENUM('valid', 'used', 'cancelled') NOT NULL DEFAULT 'valid',
FOREIGN KEY (order_ID) REFERENCES Ticket_order(order_ID)
	ON DELETE CASCADE
    ON UPDATE CASCADE,
FOREIGN KEY (event_ID) REFERENCES Event(event_ID)
	ON DELETE RESTRICT
    ON UPDATE CASCADE,
FOREIGN KEY (tier_ID) REFERENCES Ticket_tier(tier_ID)
	ON DELETE RESTRICT
    ON UPDATE CASCADE,
FOREIGN KEY (seat_ID) REFERENCES Seat(seat_ID)
	ON DELETE SET NULL
    ON UPDATE CASCADE
);

/* Payment table: payments attached to orders */
create table Payment (
pay_ID 	INT 	PRIMARY KEY 	AUTO_INCREMENT,
order_ID 	INT 	NOT NULL,
pay_status ENUM('pending', 'paid', 'declined', 'refunded') NOT NULL,
pay_amount DECIMAL(10,2) NOT NULL CHECK (pay_amount >= 0),
paid_at DATETIME,
FOREIGN KEY (order_ID) REFERENCES Ticket_order(order_ID)
	ON DELETE CASCADE
    ON UPDATE CASCADE
);

/* Review table: reviews are tied to specific events */
create table Review (
review_ID 	INT 	PRIMARY KEY 	AUTO_INCREMENT,
user_ID 	INT 	NOT NULL,
event_ID 	INT 	NOT NULL,
rating 		INT 	NOT NULL CHECK (rating BETWEEN 0 AND 5),
comment TEXT,
FOREIGN KEY (user_ID) REFERENCES Attendee(user_ID)
	ON DELETE CASCADE
    ON UPDATE CASCADE,
FOREIGN KEY (event_ID) REFERENCES Event(event_ID)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);

/* =========================================================
   SECTION 3: SAMPLE INSTANCES
   ========================================================= */
   
/* Insert users */
INSERT INTO User (email, fname, lname, phone, payment_method) VALUES
('alice@example.com', 'Alice', 'Johnson', '8061111111', 'Visa'),
('bob@example.com', 'Bob', 'Smith', '8062222222', 'Mastercard'),
('carol@example.com', 'Carol', 'Davis', '8063333333', 'PayPal'),
('david@example.com', 'David', 'Lee', '8064444444', 'Visa'),
('eva@example.com', 'Eva', 'Martinez', '8065555555', 'Discover'),
('frank@example.com', 'Frank', 'Wilson', '8066666666', 'Visa'),
('grace@example.com', 'Grace', 'Hall', '8067777777', 'Visa'),
('henry@example.com', 'Henry', 'Young', '8068888888', 'Mastercard'),
('isabella@example.com', 'Isabella', 'King', '8069999999', 'PayPal');

/* Insert roles */
INSERT INTO Attendee (user_id) VALUES
(1), (2), (4), (5), (7), (8);

INSERT INTO Organizer (user_id) VALUES
(3), (6), (9);

INSERT INTO Admin (user_id) VALUES
(6);

/* Insert venues */
INSERT INTO Venue (venue_name, addr, capacity) VALUES
('United Supermarkets Arena', '1701 Indiana Ave, Lubbock, TX', 15000),
('Jones AT&T Stadium', '2526 Mac Davis Ln, Lubbock, TX', 60000),
('Student Union Ballroom', 'TTU Campus, Lubbock, TX', 500);

/* Insert sections */
INSERT INTO Section (venue_ID, section_name) VALUES
(1, '111'),
(1, '113'),
(1, '233'),
(1, '103'),
(2, '222'),
(2, '208'),
(2, '215'),
(3, 'N/A');

/* Insert seats */
INSERT INTO Seat (section_id, row_no, seat_no) VALUES
(1, '3', 1),
(1, '3', 2),
(1, '5', 3),
(2, '7', 1),
(2, '7', 2),
(3, '1', 1),
(4, '2', 1),
(6, '8', 4),
(6, '9', 4),
(7, '10', 1),
(7, '10', 2),
(8, 'N/A', 1);

/* Insert events */
/* Note: creator_id here refers to Organizer.creator_ID (auto-incremented PK),
   not user_ID. Organizer inserts above produce creator_ID 1 (Carol), 2 (Frank), 3 (Isabella). */
INSERT INTO Event (event_title, event_desc, event_date, event_time, event_type, creator_id, venue_id) VALUES
('Mens Basketball vs. TCU', 'Texas Tech mens basketball game', '2026-03-03', '20:00:00', 'sports', 1, 1),
('Strait to Texas Tech', 'George Strait concert featuring Miranda Lambert, Zach Top, and more', '2026-04-24', '17:45:00', 'concert', 2, 2),
('University Career Fair', 'Meet employers and recruiters', '2026-02-10', '10:00:00', 'campus', 1, 3),
('City Food Expo', 'Local restaurants and food vendors', '2026-06-15', '12:00:00', 'public', 2, 3);

/* Insert ticket tiers */
INSERT INTO Ticket_tier (tier_name, check_status, price, event_id) VALUES
('General Admission', TRUE, 35.00, 1),
('Courtside', TRUE, 250.00, 1),
('VIP', TRUE, 500.00, 2),
('Premium', TRUE, 300.00, 2),
('Free Entry', TRUE, 0.00, 3),
('General Admission', TRUE, 15.00, 4);

/* Insert orders */
INSERT INTO Ticket_order (user_id, order_amount, order_date) VALUES
(1, 285.00, '2025-09-01 12:30:00'), 
(2, 500.00,  '2025-09-02 13:15:00'),
(4, 0.00,   '2026-03-03 09:00:00'),
(5, 30.00,  '2026-01-05 18:45:00'),
(7, 600.00, '2026-02-01 14:00:00'),
(8, 15.00, '2026-02-02 15:30:00'),
(1, 500.00, '2026-02-10 11:00:00');


/* Insert payments */
INSERT INTO payment (order_id, pay_status, paid_at, pay_amount) VALUES
(1, 'paid', '2025-09-01 12:35:00', 285.00),
(2, 'paid', '2025-09-02 13:20:00', 500.00),
(3, 'paid', '2026-03-03 09:01:00', 0.00),
(4, 'pending', NULL, 30.00),
(5, 'paid', '2026-02-01 14:05:00', 600.00),
(6, 'paid', '2026-02-02 15:35:00', 15.00),
(7, 'pending', NULL, 500.00);

/* Insert tickets */
INSERT INTO Ticket (status, issued_at, event_id, order_id, tier_id, seat_id) VALUES
('valid', '2026-09-01 12:36:00', 1, 1, 2, 1),
('valid', '2026-09-01 12:36:00', 1, 1, 1, 2),
('used',  '2026-09-02 13:21:00', 2, 2, 3, 6),
('valid', '2026-03-03 09:02:00', 3, 3, 5, NULL),
('valid', '2026-01-05 18:50:00', 4, 4, 6, NULL),
('valid', '2026-01-05 18:50:00', 4, 4, 6, NULL),
('valid', '2026-02-01 14:06:00', 2, 5, 4, 8),
('valid', '2026-02-01 14:06:00', 2, 5, 4, 9),
('used',  '2026-02-02 15:36:00', 1, 6, 1, NULL),
('valid', '2026-02-10 11:05:00', 2, 7, 3, 6);

/* Insert reviews */
INSERT INTO review (user_id, event_id, rating, comment) VALUES
(1, 1, 4, 'Very exciting game and good seating.' ),
(2, 2, 5, 'Amazing concert and great atmosphere.'),
(4, 3, 3, 'Helpful event with many employers.'),
(5, 4, 4, 'Good food and nice setup.'),
(7, 2, 5, 'Good price and amazing performance'),
(8, 1, 3, 'Decent game but could be better.'),
(1, 2, 3, 'Seats were not as expected but still enjoyable' );

/* =========================================================
   SECTION 4: VIEWS FOR DIFFERENT USERS
   ========================================================= */
   
/* Guest/Public view:
   Shows only public event browsing information */
CREATE VIEW guest_event_view AS
SELECT 
    e.event_id,
    e.event_title,
    e.event_type,
    e.event_date,
    e.event_time,
    v.venue_name AS vname,
    v.addr AS vaddress
FROM event e
JOIN venue v ON e.venue_id = v.venue_id;

/* Attendee view:
   Shows ticket purchase history for attendees */
CREATE VIEW attendee_ticket_history_view AS
SELECT
    ua.user_id,
    ua.fname,
    ua.lname,
    o.order_id,
    o.order_date,
    e.event_title AS etitle,
    t.ticket_id,
    t.status AS tstatus,
    tt.tier_name,
    p.pay_status,
    p.pay_amount
FROM user ua
JOIN ticket_order o ON ua.user_id = o.user_id
JOIN ticket t ON o.order_id = t.order_id
JOIN event e ON t.event_id = e.event_id
JOIN ticket_tier tt ON t.tier_id = tt.tier_id
LEFT JOIN payment p ON o.order_id = p.order_id;

/* Organizer view:
   Shows organizer-owned events and basic sales summary */
CREATE VIEW organizer_event_sales_view AS
SELECT
    o.creator_id,
    ua.lname AS organizer_name,
    e.event_id,
    e.event_title,
    e.event_date,
    COUNT(t.ticket_id) AS tickets_sold,
    COALESCE(SUM(p.pay_amount), 0) AS revenue
FROM organizer o
JOIN user ua ON o.user_id = ua.user_id
JOIN event e ON o.creator_id = e.creator_id
LEFT JOIN ticket t ON e.event_id = t.event_id
LEFT JOIN ticket_order tor ON t.order_id = tor.order_id
LEFT JOIN payment p ON tor.order_id = p.order_id AND p.pay_status = 'paid'
GROUP BY o.creator_id, ua.fname, ua.lname, e.event_id, e.event_title, e.event_date;

/* Admin view:
   Gives a platform-wide overview of users and their roles */
CREATE VIEW admin_user_overview_view AS
SELECT
    ua.user_id,
    ua.fname,
    ua.lname,
    ua.email,
    CASE WHEN a.user_id IS NOT NULL THEN 'Attendee' ELSE 'No' END AS is_attendee,
    CASE WHEN o.user_id IS NOT NULL THEN 'Organizer' ELSE 'No' END AS is_organizer,
    CASE WHEN ad.user_id IS NOT NULL THEN 'Admin' ELSE 'No' END AS is_admin
FROM user ua
LEFT JOIN attendee a ON ua.user_id = a.user_id
LEFT JOIN organizer o ON ua.user_id = o.user_id
LEFT JOIN admin ad ON ua.user_id = ad.user_id;

/* =========================================================
   SECTION 5: BASIC DML IMPLEMENTATION
   ========================================================= */

/* Basic Retrieval 1:
   Show all events */
SELECT * FROM event;

/* Basic Retrieval 2:
   Show all venues */
SELECT * FROM venue;

/* Basic Retrieval 3:
   Show all attendees */
SELECT ua.user_id, ua.fname, lname, ua.email
FROM user ua
JOIN attendee a ON ua.user_id = a.user_id;

/* Basic Retrieval 4:
   Show all tickets for a specific event */
SELECT ticket_id, status, event_id, order_id
FROM ticket
WHERE event_id = 1;

/* Basic Retrieval 5:
   Show all reviews and ratings */
SELECT review_id, user_id, event_id, rating, comment
FROM review;

/* Basic Retrieval 6:
   Show orders placed after a certain date */
SELECT *
FROM ticket_order
WHERE order_date > '2025-12-31';

/* =========================================================
   SECTION 6: BASIC DML CHANGES
   ========================================================= */

/* Insert a new attendee order */
INSERT INTO ticket_order (user_id, order_amount, order_date)
VALUES (1, 500.00, '2026-04-20 14:00:00');

/* Update a payment status */
UPDATE payment
SET pay_status = 'paid', paid_at = '2026-01-05 19:00:00'
WHERE pay_id = 4;

/* Delete a review example */
DELETE FROM review
WHERE review_id = 4;

/* Reinsert deleted review so later queries still work */
INSERT INTO review (user_id, event_id, rating, comment)
VALUES (5, 4, 4, 'Good food and nice setup.');

/* =========================================================
   SECTION 7: COMPLEX DML IMPLEMENTATION
   ========================================================= */

/* Complex Query 1:
   Join events with venues and organizers */
SELECT
    e.event_id,
    e.event_title,
    e.event_type,
    e.event_date,
    v.venue_name AS vname,
    ua.fname AS organizerf_name,
    ua.lname AS organizerl_name
FROM event e
JOIN venue v ON e.venue_id = v.venue_id
JOIN organizer o ON e.creator_id = o.creator_id
JOIN user ua ON o.user_id = ua.user_id;

/* Complex Query 2:
   Count tickets sold per event */
SELECT
    e.event_id,
    e.event_title,
    COUNT(t.ticket_id) AS tickets_sold
FROM event e
LEFT JOIN ticket t ON e.event_id = t.event_id
GROUP BY e.event_id, e.event_title;

/* Complex Query 3:
   Total revenue per event using aggregation */
SELECT
    e.event_id,
    e.event_title,
    COALESCE(SUM(p.pay_amount), 0) AS total_revenue
FROM event e
LEFT JOIN ticket t ON e.event_id = t.event_id
LEFT JOIN ticket_order o ON t.order_id = o.order_id
LEFT JOIN payment p ON o.order_id = p.order_id AND p.pay_status = 'paid'
GROUP BY e.event_id, e.event_title;

/* Complex Query 4:
   Average review rating for each event */
SELECT
    e.event_id,
    e.event_title,
    AVG(r.rating) AS avg_rating
FROM event e
LEFT JOIN review r ON e.event_id = r.event_id
GROUP BY e.event_id, e.event_title;

/* Complex Query 5:
   Show attendees who bought at least one VIP ticket */
SELECT DISTINCT
    ua.user_id,
    ua.fname,
    ua.lname
FROM user ua
JOIN ticket_order o ON ua.user_id = o.user_id
JOIN ticket t ON o.order_id = t.order_id
JOIN ticket_tier tt ON t.tier_id = tt.tier_id
WHERE tt.tier_name = 'VIP';

/* Complex Query 6:
   Nested query: events with above-average ticket price */
SELECT
    e.event_id,
    e.event_title,
    tt.tier_name,
    tt.price
FROM event e
JOIN ticket_tier tt ON e.event_id = tt.event_id
WHERE tt.price > (
    SELECT AVG(price)
    FROM ticket_tier
);

/* Complex Query 7:
   Nested query: attendees who spent more than average order amount */
SELECT
    ua.user_id,
    ua.fname,
    ua.lname,
    o.order_amount
FROM user ua
JOIN ticket_order o ON ua.user_id = o.user_id
WHERE o.order_amount > (
    SELECT AVG(order_amount)
    FROM ticket_order
);

/* Complex Query 8:
   Multi-table join showing ticket, seat, section, and venue info */
SELECT
    t.ticket_id,
    e.event_title AS etitle,
    v.venue_name AS vname,
    s.section_name,
    se.row_no,
    se.seat_no
FROM ticket t
JOIN event e ON t.event_id = e.event_id
JOIN venue v ON e.venue_id = v.venue_id
LEFT JOIN seat se ON t.seat_id = se.seat_id
LEFT JOIN section s ON se.section_id = s.section_id;

/* Complex Query 9:
   Show organizers and how many events each organizer created */
SELECT
    ua.lname AS organizer_name,
    COUNT(e.event_id) AS event_count
FROM organizer o
JOIN user ua ON o.user_id = ua.user_id
LEFT JOIN event e ON o.creator_id = e.creator_id
GROUP BY ua.lname;

/* Complex Query 10:
   Show venue utilization based on number of tickets sold compared to capacity */
SELECT
    v.venue_id,
    v.venue_name,
    v.capacity,
    COUNT(t.ticket_id) AS tickets_sold,
    ROUND((COUNT(t.ticket_id) / v.capacity) * 100, 2) AS utilization_percent
FROM venue v
JOIN event e ON v.venue_id = e.venue_id
LEFT JOIN ticket t ON e.event_id = t.event_id
GROUP BY v.venue_id, v.venue_name, v.capacity;

/* Complex Query 11:
   Correlated subquery: highest-rated events) */
SELECT
    e.event_title,
    AVG(r.rating) AS avg_rating
FROM event e
JOIN review r ON e.event_id = r.event_id
GROUP BY e.event_id, e.event_title
HAVING AVG(r.rating) >= ALL (
    SELECT AVG(r2.rating)
    FROM review r2
    GROUP BY r2.event_id
);

/* Complex Query 12:
   Find attendees who attended a free event */
SELECT DISTINCT
    ua.user_id,
    ua.fname,
    ua.lname
FROM user ua
JOIN ticket_order o ON ua.user_id = o.user_id
JOIN ticket t ON o.order_id = t.order_id
JOIN ticket_tier tt ON t.tier_id = tt.tier_id
WHERE tt.price = 0.00;

/* Complex Query 13:
   Group revenue by event type */
SELECT
    e.event_type,
    COALESCE(SUM(p.pay_amount), 0) AS revenue_by_type
FROM event e
LEFT JOIN ticket t ON e.event_id = t.event_id
LEFT JOIN ticket_order o ON t.order_id = o.order_id
LEFT JOIN payment p ON o.order_id = p.order_id AND p.pay_status = 'paid'
GROUP BY e.event_type;

/* Complex Query 14:
   Show each attendee and how many reviews they left */
SELECT
    ua.fname,
    ua.lname,
    COUNT(r.review_id) AS review_count
FROM user ua
JOIN attendee a ON ua.user_id = a.user_id
LEFT JOIN review r ON ua.user_id = r.user_id
GROUP BY ua.lname, ua.fname;

/* Guest user browsing view */
SELECT * FROM guest_event_view;

/* Attendee order/ticket history view */
SELECT * FROM attendee_ticket_history_view;

/* Organizer sales view */
SELECT * FROM organizer_event_sales_view;

/* Admin platform overview view */
SELECT * FROM admin_user_overview_view;












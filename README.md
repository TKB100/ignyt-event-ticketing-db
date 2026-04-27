# ignyt-event-ticketing-db

A fully normalized relational database for **Ignyt**, a digital event ticketing and management platform. Built as the capstone project for CS4354 — Concepts of Database Systems at Texas Tech University (Spring 2026).

---

## Overview

Ignyt models the end-to-end lifecycle of event ticketing — from event creation and venue management to ticket purchasing, payment processing, and post-event reviews. The database is implemented in **MySQL** and demonstrates real-world relational design including weak entities, EER specialization hierarchies, role-based views, and complex analytical queries.

---

## Platform Features

- **4 event types** — Concerts, Sports, Campus, and Public events
- **4 user roles** — Guest, Attendee, Organizer, and Admin
- **Venue & seating management** — Venues contain Sections, Sections contain Seats
- **Ticket tiers** — Multiple pricing tiers per event (VIP, GA, etc.)
- **Order & payment tracking** — Full transaction lifecycle with status tracking
- **Reviews** — Verified attendees can rate and comment on events

---

## Database Schema

The schema consists of **11 tables** mapped from an EER diagram:

| Table | Description |
|-------|-------------|
| `User` | Base entity for all platform users |
| `Attendee` | Subclass of User — can purchase tickets and leave reviews |
| `Organizer` | Subclass of User — can create and manage events |
| `Admin` | Subclass of User — full platform access |
| `Event` | Core event entity with 4 specialization subtypes |
| `Venue` | Venue details including capacity and address |
| `Section` | Sections within a venue |
| `Seat` | Weak entity — individual seats within a section |
| `Ticket_Tier` | Pricing tiers associated with an event |
| `Ticket` | Individual tickets linked to orders and tiers |
| `Ticket_Order` | Orders placed by attendees |
| `Payment` | Weak entity — payment record per order |
| `Review` | Ratings and comments submitted by verified attendees |


---

## SQL File Structure

`Ignyt_event_db.sql` is organized into 7 sections:

```
Section 0-1  — Database setup, drop/recreate
Section 2    — DDL: CREATE TABLE statements (15 tables)
Section 3    — Sample data: INSERT statements
Section 4    — Views: 4 role-based views
Section 5    — Basic DML: SELECT, INSERT, UPDATE, DELETE
Section 6    — Basic queries
Section 7    — Complex queries (14 total)
```

---

## Views

| View | Access Level | Description |
|------|-------------|-------------|
| `guest_event_view` | Public | Event listings with venue info |
| `attendee_ticket_history_view` | Attendee | Order history with ticket and payment status |
| `organizer_event_sales_view` | Organizer | Tickets sold and revenue per event |
| `admin_user_overview_view` | Admin | All users with role flags |

---

## Complex Queries

14 analytical queries covering:

- Multi-table JOINs (up to 5 tables)
- Aggregation with `GROUP BY` / `HAVING`
- Correlated subqueries
- `ALL` / `ANY` subquery comparisons
- Revenue analysis with `COALESCE` + `LEFT JOIN`
- Venue utilization percentage calculations
- Attendee spending analysis

---

## How to Run

1. Make sure you have **MySQL 8.0+** installed
2. Clone the repo:
   ```bash
   git clone https://github.com/TKB100/ignyt-event-ticketing-db.git
   cd ignyt-event-ticketing-db
   ```
3. Import the SQL file:
   ```bash
   mysql -u root -p < Ignyt_event_db.sql
   ```
4. Connect and explore:
   ```bash
   mysql -u root -p Ignyt
   ```

---

## Tech Stack

- **MySQL 8.0** — Database engine
- **EER Modeling** — Entity-relationship design with specialization hierarchies
- **draw.io** — ER/EER diagram tool

---

## Team

| Name | Role |
|------|------|
| Triston Barrientos | Project Manager / Leader |
| Tyler Spoonts | Database Designer |
| Triston Schwab | Query Developer |
| Blaine Lichtenstein | Data & Documentation |

**Texas Tech University — CS4354 Database Systems — Spring 2026**

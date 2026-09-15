# Exercise — Normalizing a Flat Sales Report Table

## Setup

A junior dev at the construction-material store needed a quick sales report
and shipped this single table straight from a spreadsheet import. It works,
sort of — but nobody's touched the schema since.

```sql
CREATE TABLE sales_flat (
    invoice_no          VARCHAR(20),
    invoice_date        DATE,
    customer_name       VARCHAR(200),
    customer_phone      VARCHAR(20),
    customer_address    TEXT,
    product_code        VARCHAR(50),
    product_name        VARCHAR(200),
    product_category    VARCHAR(100),
    category_discount_pct NUMERIC(5,2),
    quantity             NUMERIC(12,2),
    unit_price           NUMERIC(12,2),
    salesperson_name     VARCHAR(200),
    salesperson_phone    VARCHAR(20)
);
```

Sample data (this is what's actually sitting in the table today):

| invoice_no | invoice_date | customer_name | customer_phone | customer_address | product_code | product_name | product_category | category_discount_pct | quantity | unit_price | salesperson_name | salesperson_phone |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| INV-001 | 2026-01-05 | Somchai Construction | 081-111-1111 | 12 Sukhumvit Rd | CEM-001 | Portland Cement 50kg | Cement | 5.00 | 20 | 150.00 | Nid | 089-999-1111 |
| INV-001 | 2026-01-05 | Somchai Construction | 081-111-1111 | 12 Sukhumvit Rd | REB-010 | Rebar 12mm 6m | Rebar | 3.00 | 50 | 220.00 | Nid | 089-999-1111 |
| INV-002 | 2026-01-06 | Apex Builders | 082-222-2222 | 8 Rama IV Rd | CEM-001 | Portland Cement 50kg | Cement | 5.00 | 100 | 150.00 | Boat | 089-999-2222 |
| INV-003 | 2026-01-07 | Somchai Construction | 081-111-1111 | 12 Sukhumvit Rd | TOL-005 | Hammer 16oz | Tools | 0.00 | 3 | 180.00 | Nid | 089-999-1111 |

## Problem 1 — find the anomalies

Before normalizing anything: using this exact table and sample data, describe
one concrete **update anomaly**, one **insert anomaly**, and one **delete
anomaly** that this design causes. Don't just name the anomaly type — show
the actual scenario (what UPDATE/INSERT/DELETE statement, what goes wrong).

## Problem 2 — normalize it

Take `sales_flat` through 1NF → 2NF → 3NF. For each step:

1. Say what rule was being violated and why (point at the specific columns).
2. Show the resulting table(s) (`CREATE TABLE`, or sketches if that's
   faster).

End state: a set of tables where no anomaly from Problem 1 can happen
anymore.

## Problem 3 — would you actually ship the fully normalized version?

Given what you know about how a sales report table like this actually gets
*read* (dashboards, monthly reports, "top products this month" queries) —
is there a column or two from `sales_flat` you'd deliberately keep
denormalized anyway, even after Problem 2? If yes, which, and what read
pattern justifies it. If no, defend that too.

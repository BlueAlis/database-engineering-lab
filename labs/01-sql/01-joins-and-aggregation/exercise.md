# Exercise — Joins and Aggregation

Schema: `customers`, `products`, `orders`, `order_items` (see
`setup/schema.sql`). `order_items.unit_price` is the price at the time of
the order — use that, not `products.unit_price`, when computing money
values. `orders.status` can be `completed` or `cancelled`.

Write one SQL query per problem. Run it against the loaded database and
record both the query and its actual output in `my-work.md` under
`## Attempt`.

## 1. Warm-up filter + join

List every completed order placed by `contractor` customers based in
`Bangkok`, showing the customer name, order id, and order date, most recent
first.

## 2. Revenue per customer

For every customer, compute their total amount spent, counting only
`completed` orders. Include customers with zero completed-order spend
(don't just drop them).

## 3. Products ordered by many distinct customers

Find every product that has been ordered (in a completed order) by more
than 2 distinct customers. Show the product name and the distinct customer
count.

Before you write the query: what's the difference between counting *rows*
in `order_items` for a product versus counting *distinct customers*? Which
one does the question actually ask for?

## 4. Customers with no orders at all

List every customer who has never placed a single order (not "no completed
orders" — no order row at all, of any status).

## 5. Top categories by revenue

Using only completed orders, find the top 3 product categories by total
revenue.

---

Optional stretch, only if you want it: redo problem 2 but also show, per
customer, how much of their spend was in the single largest category for
that customer. Not required to move on.

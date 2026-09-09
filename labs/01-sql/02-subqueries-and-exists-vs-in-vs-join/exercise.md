# Exercise — Subqueries and EXISTS vs IN vs JOIN

Same schema as lab 01: `customers`, `products`, `orders`, `order_items`.
`order_items.unit_price` is price-at-time-of-order. `orders.status` is
`completed` or `cancelled`. All columns referenced below (`customer_id`,
`product_id`, etc.) are `NOT NULL` in this schema — keep that in mind for
problem 2.

## 1. Warm-up — three ways to ask the same question

Find every customer who has placed at least one `completed` order. Show
just customer name and city.

Write **three** separate queries for this, one per technique:

- (a) using `JOIN` (with whatever dedup you need)
- (b) using `IN` with a subquery
- (c) using `EXISTS` with a correlated subquery

They should return the same rows. Before running them: do you expect (a)
to need `DISTINCT`? Why would (b) and (c) not have that problem in the
first place?

## 2. NOT EXISTS, and where NOT IN gets dangerous

Find every product that has never appeared in *any* `completed` order
(not just "never ordered" — specifically never in a completed one). Write
it using `NOT EXISTS`.

Then, a conceptual question — don't just try to make it fail, reason it
through, since nothing in this schema can actually trigger it
(`order_items.product_id` is `NOT NULL`): if the subquery inside a
`NOT IN (...)` can return so much as one `NULL` among its rows, what
happens to the whole `NOT IN` result? Would `NOT EXISTS` have the same
problem? Answer in `my-attempt.md` — this part is **theoretical / not
executed**, since you can't produce a NULL in a `NOT NULL` column to test
it against real data here.

## 3. Correlated subquery — priced above category average

List every product whose `unit_price` is above the average `unit_price` of
its own `category`. Show product name, category, its price, and the
category average.

This needs a subquery that references the outer query's current row (i.e.
depends on which product/category you're currently looking at) — that's
what makes it *correlated* rather than a one-shot scalar subquery.

## 4. Scalar subquery — above-average spenders

Using completed orders only, find every customer whose total spend is
above the average total spend *across all customers* — including
customers with $0 (zero-spend customers pull the average down; they still
count toward it, they just don't qualify for the result).

Think about the order of operations here: what has to be computed first,
before you can even write the comparison?

## 5. Subquery in FROM — top spender per city

For each city, find the customer with the highest total completed-order
spend in that city. Show city, customer name, and their spend.

Hint: build a derived table (subquery in `FROM`) of spend-per-customer
first, then work out how to pick the max per city from it — there's more
than one valid way to do the second part; whichever you pick, be ready to
explain why it gets exactly one row per city even if there's a tie.

---

Optional stretch, only if you want it: redo problem 1(b) and 1(c), but
this time for customers who have placed an order (**any** status) for a
product priced over 2000 baht. Does `IN`/`EXISTS` still behave identically
to the `JOIN` version once you're checking a condition on `order_items`
rather than on `orders` directly? Not required to move on.

# 01 — SQL

Baseline fluency with SQL as a language, on PostgreSQL specifically. The bar
isn't "can write a query that returns the right rows" — it's "can explain
why this query is correct and what it costs."

## Topics

- SELECT (projection, filtering, ordering)
- JOIN (inner, left/right, full, self, cross — and when each is wrong)
- GROUP BY / HAVING
- Subqueries (scalar, correlated, in `WHERE`/`FROM`)
- CTEs (including recursive)
- Window functions
- EXISTS vs IN vs JOIN
- UNION / UNION ALL
- Aggregation
- Pagination (`OFFSET/LIMIT` vs keyset pagination, and why one breaks at
  scale)
- INSERT / UPDATE / DELETE
- Upsert (`ON CONFLICT`)

## Signs of real understanding

- Can predict, before running it, roughly what a query will return on a
  given schema.
- Can explain the difference between `IN`, `EXISTS`, and a `JOIN` for the
  same intent, and when they stop being equivalent (NULLs, duplicates).
- Knows why `OFFSET 1000000` is a problem before being told.

Labs: [`../labs/01-sql/`](../labs/01-sql/)

# Mistake Log

Real mistakes only — never fabricated, never deleted once recorded. This is
evidence of learning, not a list of embarrassments to hide.

## Format

Each entry:

```
### YYYY-MM-DD — <short title>

**Topic:**
**Original assumption:**
**What I did:**
**What happened:**
**Why I was wrong:**
**Correct understanding:**
**Follow-up test:** (date + result, once re-tested)
```

Entries are appended, never edited to look better in hindsight. If a later
entry corrects an earlier one, link them instead of rewriting the original.

---

### 2026-09-08 — LEFT JOIN + WHERE on the joined table silently becomes INNER JOIN

**Topic:**
Joins — outer join semantics with `WHERE` filters

**Original assumption:**
`LEFT JOIN customers ON o.customer_id = c.id` would preserve orders with no matching customer, so it was the "safe" choice.

**What I did:**
Wrote `LEFT JOIN customers c ... WHERE c.city = 'Bangkok' AND c.customer_type = 'contractor'` (lab 01-sql/01-joins-and-aggregation, problem 1).

**What happened:**
Query gave correct output, but for the wrong structural reason — `orders.customer_id` is `NOT NULL REFERENCES customers(id)`, verified by trying to insert an order without a customer and getting rejected by the constraint. So there was never an unmatched row to preserve.

**Why I was wrong:**
Even setting the constraint aside, a `WHERE` clause filtering on the right-hand table's columns (`c.city = 'Bangkok'`) discards any row where those columns are NULL, because `NULL = 'Bangkok'` evaluates to NULL/unknown, not TRUE. So `LEFT JOIN + WHERE-on-right-table` behaves identically to `INNER JOIN` for any condition that can't be satisfied by NULL — the LEFT JOIN was misleading, not incorrect.

**Correct understanding:**
Choose `LEFT JOIN` vs `INNER JOIN` based on whether unmatched rows should survive to the final result. If a `WHERE` filter on the right table will remove NULLs anyway, use `INNER JOIN` so the query reads as what it actually does.

**Follow-up test:**
not yet re-tested.

### 2026-09-08 — GROUP BY grain mismatch + DISTINCT on a non-unique column

**Topic:**
Aggregation — GROUP BY grain, COUNT(DISTINCT ...) on the wrong column

**Original assumption:**
Grouping by both `p.name` and `c.name` together, then `COUNT(DISTINCT c.name)`, would count distinct customers per product.

**What I did:**
`GROUP BY p."name", c."name" ... HAVING COUNT(c."name") > 1` (lab 01-sql/01-joins-and-aggregation, problem 3).

**What happened:**
Would have returned one row per (product, customer) pair with count always 1, never satisfying "more than 2 distinct customers" — structurally incapable of answering the question, caught before running it.

**Why I was wrong:**
Grouping by `c.name` collapses each group down to a single customer, so `COUNT(DISTINCT c.name)` inside that group can never exceed 1. Also used a plain `COUNT` (not `DISTINCT`) against threshold 1 instead of 2. Separately, `customers.name` (and `products.name`) have no `UNIQUE` constraint in the schema, so `DISTINCT` on either is unsafe if two rows ever share a name.

**Correct understanding:**
`GROUP BY` only the column(s) that define "one output row per X" (here: `p.id`), and run `COUNT(DISTINCT ...)` over the column that should vary within that group (here: `c.id`, not `c.name`, since only the primary key is guaranteed unique).

**Follow-up test:**
not yet re-tested.

### 2026-09-08 — PARTITION BY on the wrong side of a window function

**Topic:**
Window functions — PARTITION BY choice inverts the question being asked

**Original assumption:**
`RANK() OVER (PARTITION BY p.category ORDER BY revenue DESC)` filtered to `rank = 1` would give, per customer, their single largest-spend category.

**What I did:**
Optional stretch of lab 01-sql/01-joins-and-aggregation (largest category per customer).

**What happened:**
Customer "Apex Builders" (id 9) appeared twice in the `rank = 1` output, once per category, instead of once per customer.

**Why I was wrong:**
`PARTITION BY p.category` groups the window by category and ranks *customers* within each category — it answers "who spends the most in this category," a different question from "which category does this customer spend the most in." Both queries produce a `rank = 1` filter, which made the bug easy to miss until the duplicate row surfaced.

**Correct understanding:**
To rank categories within each customer, partition by the customer (`PARTITION BY c.id`), not by the dimension you're trying to pick the best of.

**Follow-up test:**
not yet re-tested.

# AI Review — Joins and Aggregation

This review covers the attempt in `my-attempt.md`, based on the queries the
user wrote, ran for real, and revised through discussion. It does not
replace `my-attempt.md` — it documents what was right, what was wrong, and
how it got fixed.

## 1. Warm-up filter + join

Query was correct on the first try (verified against real output). The one
issue was `LEFT JOIN customers ON o.customer_id = c.id` combined with a
`WHERE c.city = ... AND c.customer_type = ...` filter — since a NULL
`c.city` can never satisfy `= 'Bangkok'` (SQL three-valued logic), the
`WHERE` clause silently discards any row the `LEFT JOIN` would have
preserved. The join was behaving like an `INNER JOIN` while reading like a
`LEFT JOIN`, which misleads a future reader into thinking NULL customers are
a real case being handled.

The user confirmed empirically (not just from the schema) that
`orders.customer_id` cannot be NULL — they tried inserting an order without
a customer and it was rejected by the `NOT NULL REFERENCES` constraint.
Corrected reasoning: use `INNER JOIN` (or plain `JOIN`) when the query does
not intend to keep unmatched rows.

**Status: correct, with join-type reasoning fixed via discussion.**

## 2. Revenue per customer

Correct on the first try, including the harder part of the exercise: the
`status = 'completed'` filter was placed in the `ON` clause of
`LEFT JOIN orders`, not in `WHERE`. This is exactly right — filtering the
right side of an outer join inside `WHERE` would have dropped customers with
zero completed orders, which the exercise explicitly required to be kept.
`COALESCE(SUM(...), 0)` correctly turns the "no matching rows" NULL into 0.

**Status: correct on first attempt.**

## 3. Products ordered by many distinct customers

First attempt had three separate problems, found through review:

- `GROUP BY p.name, c.name` grouped at the (product, customer) grain instead
  of per-product, making `COUNT(DISTINCT c.name)` inside each group always
  evaluate to 1 — the aggregation was structurally unable to answer the
  question.
- `HAVING COUNT(c.name) > 1` used a plain (non-distinct) count and the wrong
  threshold (question asks for more than 2, not more than 1).
- `COUNT(DISTINCT c.name)` counted on `customers.name`, which has no
  `UNIQUE` constraint in the schema — two differently-identified customers
  sharing a name would have been undercounted as one.

Final query fixed all three: `GROUP BY p.id` alone (relying on Postgres'
functional-dependency rule that lets you select `p.name` without adding it
to `GROUP BY` when grouping by the table's primary key — noted as
Postgres-specific, not standard SQL), `COUNT(DISTINCT c.id)` for a
guaranteed-unique count, `HAVING ... > 2`, and `INNER JOIN` throughout since
nothing needed to be preserved unmatched.

**Status: three real bugs found and fixed. Good final query.**

## 4. Customers with no orders at all

Correct on the first try: `LEFT JOIN orders` with no status filter (any
order counts, unlike problem 2), `COUNT(o.customer_id) = 0` in `HAVING` to
find customers with zero matching rows.

Worth flagging as a real observation, not a bug: in this dataset, the one
customer with zero orders (Green Roof Renovations) happens to be the same
customer with zero completed-order revenue in problem 2. The user correctly
identified this as coincidental to this dataset, not a property of the two
queries — problem 2 measures "no completed revenue" (could include
customers with orders that were all cancelled), problem 4 measures "no
order row at all." No customer with all-cancelled orders exists in this
seed data, which is why the two results overlap here but wouldn't
necessarily elsewhere.

**Status: correct, distinction between the two queries verified through
discussion rather than assumed.**

## 5. Top categories by revenue

Correct: `WHERE status = 'completed'` is fine here since every join is an
`INNER JOIN` (no NULL-preserving semantics to break), `GROUP BY p.category`,
`ORDER BY ... DESC LIMIT 3`.

One unresolved question raised but not required to fix: `LIMIT 3` with no
tie-breaker on `total_revenue` means a tie for 3rd place would be resolved
by unspecified physical row order (scan order, plan choice), not by any
column value — reproducible only by accident. Not fixed in the query since
this dataset has no tie at the 3rd/4th boundary, but understanding of *why*
it's unsafe was demonstrated correctly.

**Status: correct as written; tie-breaker fragility identified and
understood, left unfixed by choice (no tie in current data).**

## Optional stretch — largest category per customer

First attempt used `RANK() OVER (PARTITION BY p.category ORDER BY revenue
DESC)`, which ranks *customers within a category* (answers "who spends most
in this category") rather than *categories within a customer* (answers
"which category does this customer spend most in") — the two are different
questions that happen to both produce a `rank = 1` filter, which is why the
bug wasn't obvious from the shape of the query. It surfaced concretely as
one customer (Apex Builders) appearing twice, both times as `rank = 1` in a
different category.

Fixed by changing to `PARTITION BY c.id`, correctly re-ranking categories
within each customer instead. Final output has exactly one row per
customer, including the zero-order customer via the same
`LEFT JOIN + COALESCE` pattern from problem 2.

**Status: real bug (inverted PARTITION BY) found and fixed, mechanism
understood, not just pattern-matched.**

## Overall

All 5 required problems are correct in their final form, with three
problems (1, 3, optional stretch) having genuine first-attempt bugs that
were found and corrected through review rather than by rewriting on sight —
each correction is backed by the user's own explanation of *why* the
original was wrong, not just an accepted fix. Two recurring correctness
patterns to keep in mind going forward:

- **`ON` vs `WHERE` on an outer join**: a filter on the right-hand-side
  table in `WHERE` silently converts a `LEFT JOIN` into an `INNER JOIN` for
  any condition that can't be satisfied by NULL. Decide first whether
  unmatched rows should survive, then decide where the filter goes.
- **`DISTINCT`/`GROUP BY` on non-unique text columns** (`name`) instead of
  the primary key: caught twice in this lab (problem 3's customer count,
  problem 3's product grouping) — good sign this is becoming a reflex
  check, not a one-off catch.

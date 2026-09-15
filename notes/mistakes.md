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

### 2026-09-11 — CHECK constraint copy-pasted across tables without matching each table's own domain

**Topic:**
Database design — CHECK constraint values, keys and relationships lab

**Original assumption:**
Every `status` column in the schema could reuse the same enum values as `product`'s (`ACTIVE`, `INACTIVE`, `OUT`), since they're all columns named `status`.

**What I did:**
Added `CONSTRAINT chk_sale_status_match CHECK (status IN ('ACTIVE', 'INACTIVE', 'OUT'))` and the equivalent on `delivery`, copy-pasted from `product` (lab 02-database-design/01-core-schema-keys-and-relationships, first Revision draft).

**What happened:**
`sale` and `delivery` both default `status` to `'COMPLETED'`, a value that isn't in the copied enum list — so the first row ever inserted with default values would have violated its own table's CHECK constraint. Caught in review by comparing the CHECK list against the column's own DEFAULT, before running anything; fixed to `CHECK (status IN ('COMPLETED', 'INCOMPLETED'))` in the next revision and confirmed live in Postgres (`evidence/constraint_tests.txt`, test B — `sale.status = 'PENDING'` correctly rejected).

**Why I was wrong:**
`product`'s lifecycle (active/inactive/out of stock) and `sale`/`delivery`'s lifecycle (completed/not) are different domains that happen to share a column name — copying the literal allowed values assumed they shared a lifecycle when they don't.

**Correct understanding:**
Each CHECK-constrained enum column needs its valid values derived from that specific table's own business meaning (and cross-checked against that column's own DEFAULT), never copied from a same-named column on a different table.

**Follow-up test:**
confirmed live 2026-09-11, see `evidence/constraint_tests.txt` test B.

### 2026-09-15 — Repeatedly misplacing attributes relative to a composite key

**Topic:**
Database design — 2NF, functional dependencies on a composite key

**Original assumption:**
That a table's key was a single column (`invoice_no`), and later, once
corrected to the real composite key `(invoice_no, product_code)`, that
which attributes needed the *whole* key vs. just *part* of it could be
judged loosely rather than checked against actual data each time.

**What I did:**
Lab 02-database-design/02-normalization-1nf-2nf-3nf, Problem 2. Three
separate wrong placements in sequence: (1) claimed `invoice_no` alone was
the candidate key with no partial dependency to check; (2) after
correcting to the composite key, wrote `unit_price` as depending on
`invoice_no` alone; (3) after fixing that, wrote `quantity` as depending
on `invoice_no` alone too — the same mistake recurring on a different
column right after the first instance was fixed.

**What happened:**
Each version was written down as the "current" answer in `my-work.md`
before being caught. Caught each time by checking against the exercise's
own sample data: `INV-001` appears twice (once for `CEM-001`, once for
`REB-010`) with different `quantity` values, which is only possible if
`invoice_no` alone does not determine `quantity` — the same check that
first exposed `invoice_no` not being a valid single-column key at all.

**Why I was wrong:**
Treated "does this column need the composite key" as something to guess
per-attribute from intuition about what "feels like" it belongs to the
invoice header, rather than mechanically re-checking every attribute
against the same test each time: does this value repeat identically for
two rows that share only part of the key? `quantity` and `unit_price`
(historical) vary per `product_code` within the same `invoice_no`, so
they fail that test and require the full composite key — but this had to
be re-derived three times instead of applying the rule consistently after
the first correction.

**Correct understanding:**
When a table has a composite key, check *every* non-key attribute against
the same mechanical test — hold one part of the key fixed and vary the
other; if the attribute's value changes, it depends on the varying part
too. Don't reason attribute-by-attribute from what "seems like" it
belongs to one entity or another.

**Follow-up test:**
not yet re-tested.

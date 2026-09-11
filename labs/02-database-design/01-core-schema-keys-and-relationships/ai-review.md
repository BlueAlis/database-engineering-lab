# AI Review — core-schema-keys-and-relationships

Review of `my-work.md` (Attempt → Revision → Experiment). Schema was run for
real against `dbeng-lab-postgres` (schema `lab_02_01`); constraint behavior
verified with live inserts, not just read off the DDL. Raw output in
`evidence/constraint_tests.txt`.

## Attempt

Entity list and relationships were mostly right from the start: `category
1:N product`, `supplier 1:N delivery`, `delivery 1:N delivery_item`, `sale
1:N sale_item`. Correctly scoped out `customer` and `user` tables as out of
scope for this exercise, with a stated reason (no membership system assumed;
employee table deferred) rather than just omitting them silently.

Two gaps in the first draft, both caught in review before anything was run:

1. **No direct `product`↔`supplier` relationship.** The business notes said
   a product can have multiple suppliers, but the only path from `product`
   to `supplier` in the attempt was three hops through
   `delivery_item → delivery → supplier` — i.e. only inferable from past
   delivery history, not a queryable "which suppliers can supply this
   product" fact. Initial defense of this ("avoids duplication") had the
   normalization argument backwards — a direct M:N junction table *is* the
   non-redundant way to model this, not the redundant one. Once asked what
   happens for a brand-new product with zero deliveries yet, self-corrected
   to adding `product_supplier` as a real associative entity, with its own
   attributes (`supplier_price`, `lead_time_days`) rather than a bare link
   table.
2. **`status` on `sale_item`/`delivery_item` conflated two different
   problems.** The stated reason for having it (handle returns, handle
   "system says in stock but it isn't") is a real requirement, but a mutable
   status flag on the original line item can't represent *when* something
   was returned, *how much* of the original quantity, or *why* — and a
   partial return on one line of a multi-item sale can't be expressed by the
   sale header's status either. Self-corrected to dropping the column and
   noting `sale_return`/`delivery_return` as a deferred, separate concern —
   correctly scoped out rather than half-built.

Audit columns (`created_by`/`updated_by`) on every table, with no `user`
table to reference yet, were flagged as speculative design not asked for by
the exercise. Left in, acknowledged as a known tradeoff rather than an
oversight — reasonable to leave as a judgment call, but worth being able to
defend "why does this column exist with nothing to reference" if asked.

## Revision

Two real bugs surfaced in the revision pass, both the kind that only a
description-level read (not an actual run) would miss:

1. **`sale`/`delivery` status CHECK didn't include their own DEFAULT.**
   First revision draft copy-pasted `CHECK (status IN ('ACTIVE',
   'INACTIVE', 'OUT'))` from `product` onto `sale` and `delivery` without
   adjusting the allowed values — but both tables default `status` to
   `'COMPLETED'`, which isn't in that list. The very first row inserted with
   default values would have violated its own table's constraint. Fixed to
   `CHECK (status IN ('COMPLETED', 'INCOMPLETED'))`. Logged in
   `notes/mistakes.md` since it was actually written down as a "fixed"
   answer before being caught, not self-caught pre-write.
2. **Missing comma in `category`** between the `status` column and the
   `CONSTRAINT` clause that follows it — a plain syntax error that would
   have failed `CREATE TABLE` outright. Every other table had the comma;
   only `category` was missing it. Caught by comparison before running,
   fixed, then confirmed the table actually creates cleanly.

`product_supplier` in the revision has a `UNIQUE (supplier_id, product_id)`
constraint, correctly preventing the same pair from being recorded twice —
this wasn't explicitly asked for but is the right call for an associative
entity like this.

## Experiment

Ran the full revised schema against real Postgres (`lab_02_01` schema, 8
tables, 32 constraints — all present and matching the DDL exactly, zero
`CREATE TABLE` errors). Then ran a full happy-path insert (one row per
table, valid data) and 7 deliberately invalid inserts, one per constraint
category: enum CHECK on two different tables (`product`, `sale`), quantity
CHECK on two different tables (`product`, `sale_item`), a duplicate-pair
UNIQUE (`product_supplier`), an FK violation (`sale_item` → nonexistent
`product`), and a plain UNIQUE (`product.product_code`).

All 8 happy-path inserts succeeded; all 7 negative cases failed on exactly
the constraint they were meant to test, with no unexpected pass or wrong-
constraint failure. This is real, not assumed, confirmation that:

- the `status` CHECK values now actually match each table's own domain
  (the exact bug fixed in the Revision step, verified live in test B),
- `quantity > 0` on line items vs `quantity >= 0` on `product` are both
  enforced as separate, correctly-scoped rules (tests C and D),
- the FK from `sale_item` to `product` actually blocks an orphan reference
  rather than silently accepting it (test F).

Write-up in `my-work.md` for this step is thin (one line, no per-case
detail or reflection on what the results confirmed) — the raw evidence is
solid, but the "what did this confirm, what surprised you" part that turns
a passing test suite into understanding isn't there yet. Worth adding to if
this lab gets revisited.

## Overall

Core relationships, keys, and constraints are all correct and now verified
live, not just on paper. The strongest moments in this lab were both
self-corrections after a single pointed question rather than being told the
fix directly: recognizing the M:N junction table was missing once asked
about a product with no delivery history yet, and recognizing that a mutable
per-row status flag can't represent a return event's history once asked to
compare it against this repo's own "never overwrite, append corrections"
rule. Two real defects (the status/DEFAULT mismatch, the missing comma) were
things that reasoning on paper missed and an actual `CREATE TABLE` +
`INSERT` run caught immediately — good concrete case for why the "real
experiment" step in this repo's workflow isn't optional busywork.

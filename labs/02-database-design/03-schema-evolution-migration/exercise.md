# Exercise — Schema Evolution / Migration

Builds on the `invoice` table from
[`../02-normalization-1nf-2nf-3nf/`](../02-normalization-1nf-2nf-3nf/)
(`lab_02_02` schema).

## Problem 1 — adding a required column to a live table

Business wants a new required column on `invoice`: `payment_status`, values
`'pending' | 'paid' | 'refunded' | 'cancelled'`, and it must be `NOT NULL`
going forward.

Assume `invoice` is a **live production table with 10M+ rows**, under
constant concurrent reads and writes — not the small dev table from lab
02.2.

Write the migration you'd actually run, then answer:

1. What lock does your migration take on `invoice`, and for how long?
2. What happens to concurrent reads/writes on `invoice` while it runs?
3. Given the scale, would you change your approach at all — and if so, how?

## Problem 2 — a change your own app code can't survive in one step

The store's app currently reads/writes `invoice.customer_name` directly (a
plain text column, left over from before `customer` was normalized out in
lab 02.2 — assume it never got dropped). You now need `invoice` to
reference `customer(id)` via a proper `customer_id` foreign key instead,
and eventually drop `customer_name` entirely.

The catch: you can't take downtime, and you can't deploy new app code and
migrate the database in the same instant — old app code (still reading/
writing `customer_name`) and new app code (reading/writing `customer_id`)
will both be running against the *same* database for some period during
rollout.

1. Lay out the migration as a sequence of separate, deployable steps (not
   one big change) — say what each step does to the schema, and what
   app-code version must be live before that step is safe.
2. At which step(s) could a half-finished rollout (old app code still
   running, only some steps applied) leave you with silently wrong or
   missing data? What data, specifically?
3. When is it actually safe to drop `customer_name`?

## Problem 3 — retrofitting a constraint onto data that might violate it

Add a `CHECK` constraint to `invoice_item` enforcing `quantity > 0` — the
column has existed since lab 02.2 with no such constraint, and the table
already has rows.

1. What's the difference between adding this constraint the "obvious" way
   vs. using `NOT VALID` + a separate `VALIDATE CONSTRAINT`? What does each
   one lock, and for how long?
2. Suppose some existing rows actually do violate `quantity > 0` (bad data
   that slipped in before). What does each approach above do when it hits
   those rows — and which one tells you *which* rows are bad?
3. Once validated, does Postgres have to re-check this constraint on every
   future `INSERT`/`UPDATE` to `invoice_item`, or does validation "clear"
   existing rows permanently and only new writes get checked going
   forward?

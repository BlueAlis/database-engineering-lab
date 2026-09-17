# Lab 02.1 — Core Schema, Keys, and Relationships

Status: done — attempt, revision, and a real experiment against Postgres
all complete; reviewed and reflected on.

Curriculum: [`../../../curriculum/02-database-design.md`](../../../curriculum/02-database-design.md)

## What this lab is about

Designing the core schema for a construction-material store: products,
categories, sales/sale line items, suppliers, and deliveries. Focus is on
primary key choice (surrogate vs natural), foreign keys and the
relationship cardinality they express (1:N vs N:M), and constraints beyond
`NOT NULL`.

## Learning Objectives

- Choose surrogate vs natural primary keys for a given table, and defend
  the choice with a concrete reason (not "just in case").
- Model 1:N vs M:N relationships correctly — recognize when an M:N
  relationship needs a real associative entity, not just an inferred path
  through an unrelated event-history table.
- Write `CHECK`/`UNIQUE` constraints whose values actually match a
  table's own valid domain, rather than copied from a same-named column
  elsewhere.
- Explain why a DB-level constraint still matters even when the app
  already validates the same rule.
- Recognize when a mutable status flag can't represent a history-bearing
  event (e.g. a return), and needs a separate append-only record instead.

## Files

- `exercise.md` — the problem statement (AI-authored).
- `my-work.md` — attempt / revision / experiment (user-written, append-only
  sections). Ended up adding a `product_supplier` associative entity and
  dropping a mutable `status` column from the line-item tables during
  revision.
- `ai-review.md` — review of the attempt and revision (AI-authored).
- `evidence/constraint_tests.txt` — raw output from running the revised
  schema (8 tables, 32 constraints) against a real Postgres instance: 8
  valid inserts, 7 deliberately invalid inserts, each rejected by the
  intended constraint.
- `er-diagram.png` — ER diagram of the revised schema.
- `reflection.md` — concept/vocabulary summary written after the lab
  (user-written): associative entity vs pure junction table,
  candidate/alternate key, CHECK vs ENUM type vs lookup table.

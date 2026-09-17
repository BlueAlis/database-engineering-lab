# Lab 02.3 — Schema Evolution / Migration

Status: in progress — all 3 problems posted, attempt not started.

Curriculum: [`../../../curriculum/02-database-design.md`](../../../curriculum/02-database-design.md)

## What this lab is about

Changing a schema that's already live in production, without a maintenance
window: what locks a migration takes, how long it holds them, what breaks
for concurrent readers/writers, and how to reshape a "safe-looking" DDL
change into one that's actually safe at scale (10M+ rows). Builds on the
`invoice` table from
[`../02-normalization-1nf-2nf-3nf/`](../02-normalization-1nf-2nf-3nf/).

## Learning Objectives

- Identify what lock a given DDL statement takes on Postgres, and for how
  long, before running it on a live table.
- Reshape an "obvious" but unsafe migration into one that's actually safe
  on a 10M+ row table under constant concurrent reads/writes.
- Design a multi-step, backward-compatible rollout for a breaking schema
  change, where old and new app code must both work against the same
  database during deployment.
- Identify exactly where a half-finished rollout can silently produce
  wrong or missing data, not just "somewhere in the middle."
- Use `NOT VALID` + `VALIDATE CONSTRAINT` to retrofit a constraint onto a
  table that already has data, and explain what each step locks.

## Files

- `exercise.md` — the problem statement (AI-authored).
- `my-work.md` — attempt / revision / experiment (user-written, append-only
  sections) — not created yet.
- `ai-review.md` — review of the attempt (AI-authored) — not created yet.
- `evidence/` — raw `EXPLAIN ANALYZE` / lock/timing output from the real
  experiment — empty so far.
- `reflection.md` — user-written — not created yet.

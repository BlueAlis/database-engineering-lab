# Lab 02.2 — Normalization (1NF, 2NF, 3NF)

Status: done — attempt (Problems 1-3) complete, reviewed, and the resulting
schema verified against a real Postgres instance. No written `##
Experiment` section in `my-work.md` (deliberately skipped; the real-run
results are recorded in `ai-review.md` and `evidence/` instead).

Curriculum: [`../../../curriculum/02-database-design.md`](../../../curriculum/02-database-design.md)

## What this lab is about

Taking a deliberately bad, real-looking flat table (`sales_flat`) through
1NF → 2NF → 3NF, naming the specific rule each step fixes and the
insert/update/delete anomaly it removes — then, separately, judging when
staying denormalized is actually the right call for a given read pattern.

## Learning Objectives

- Identify concrete insert/update/delete anomalies caused by an
  unnormalized table, grounded in actual sample data (not just the
  anomaly's name).
- Derive a table's real key — including when it's composite — by
  checking it against sample data instead of assuming a single column.
- Walk a table through 1NF → 2NF → 3NF, correctly telling apart a partial
  dependency (2NF: depends on only part of a composite key) from a
  transitive dependency (3NF: a non-key attribute determines another
  non-key attribute).
- Recognize when the same column name in two tables represents two
  different facts (e.g. current price vs. price at time of sale) rather
  than a normalization violation.
- Justify a deliberate denormalization decision with a concrete read
  pattern, not a generic "for performance" claim.

## Files

- `exercise.md` — the problem statement (AI-authored).
- `my-work.md` — attempt (user-written, append-only sections): Problem 1
  (anomalies grounded in the exercise's sample data), Problem 2 (1NF/2NF/3NF
  walkthrough ending in a 6-table schema), Problem 3 (denormalization
  judgment call on `product_name`/`unit_price` snapshots).
- `ai-review.md` — review of the attempt (AI-authored), including the real
  Postgres run.
- `evidence/normalized_schema_test.txt` — raw output from building the
  normalized schema (`lab_02_02`) and re-testing all three Problem 1
  anomalies live: all three confirmed gone.
- `reflection.md` — concept/vocabulary summary (user-written): functional
  dependency, 1NF/2NF/3NF definitions, anomaly types, and a note on
  materialized views/reporting tables as an alternative to denormalizing
  the source schema.

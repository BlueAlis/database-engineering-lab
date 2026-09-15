# Progress

Last updated: 2026-09-15

This file is a status snapshot, not a score. No percentages unless there's a
concrete basis for the number (e.g. "9/12 exercises in this lab done").

## Topics studied

- SQL joins and aggregation — 5/5 required problems + optional stretch
  attempted, run against a real Postgres instance, and reviewed
  (`labs/01-sql/01-joins-and-aggregation/`). Started from: comfortable with
  single-table SQL, joins/aggregation previously handled by JPA/Hibernate
  rather than hand-written.
- Subqueries — scalar, correlated, subquery in `FROM`, and `EXISTS` vs `IN`
  vs `JOIN` semantics — 5/5 required problems attempted, run against the
  same seeded Postgres instance, and reviewed
  (`labs/01-sql/02-subqueries-and-exists-vs-in-vs-join/`). No incorrect
  final answers this lab; optional stretch (problem 1b/1c re-done against
  an `order_items` price condition) not attempted.
- Database design — core schema, keys, and relationships (surrogate vs
  natural PK, 1:N vs M:N via a junction table, CHECK/UNIQUE beyond `NOT
  NULL`) — problem 1 done end-to-end: attempt, revision, and a real
  experiment against Postgres (`labs/02-database-design/01-core-schema-keys-and-relationships/`).
  First lab in this repo where the schema was actually deployed and tested
  with live inserts rather than only read off the DDL.
- Database design — normalization (1NF, 2NF, 3NF), functional
  dependencies, partial vs. transitive dependency, and denormalization as
  a deliberate judgment call rather than an oversight — all 3 problems
  done, schema verified live against Postgres
  (`labs/02-database-design/02-normalization-1nf-2nf-3nf/`).

## Labs completed

`labs/01-sql/01-joins-and-aggregation/` — attempt done (`my-work.md` §
Attempt), reviewed (`ai-review.md`). Raw EXPLAIN ANALYZE for problems 1-2
captured in `evidence/`, no experiment write-up yet. Still open: revision,
experiment write-up, and user reflection (`reflection.md`) not yet written.

`labs/01-sql/02-subqueries-and-exists-vs-in-vs-join/` — attempt done
(`my-work.md` § Attempt, 5/5 problems), reviewed (`ai-review.md`, no
correctness issues found). A revision pass on problem 3 (redundant
category-average subquery) and problem 5 (`INNER JOIN` silently dropping an
all-zero-spend city) was started in chat and then deliberately deleted by
the user before saving — not carried into `my-work.md`. Real experiment run
on problem 1 (JOIN+DISTINCT vs IN vs EXISTS), both against the real seed
data and against an isolated 5,000-customer/150,000-order synthetic dataset
(`bench_02` schema, dropped after use) — raw plans in `evidence/`, showing
the planner uniquifies before joining for IN/EXISTS but after joining for
JOIN+DISTINCT at scale. Experiment write-up (§ Experiment in `my-work.md`)
and `reflection.md` not yet written.

`labs/02-database-design/01-core-schema-keys-and-relationships/` — attempt,
revision, and experiment all done (`my-work.md`), reviewed (`ai-review.md`).
Schema (8 tables, 32 constraints) deployed to a real Postgres schema
(`lab_02_01`) and verified with live inserts: 8 happy-path rows all
succeeded, 7 deliberately invalid inserts (bad enum values, bad quantities,
duplicate unique pairs, an orphan FK) all failed on exactly the intended
constraint — raw output in `evidence/constraint_tests.txt`. Experiment
write-up in `my-work.md` is thin (one line, no per-case reflection).
`reflection.md` written — concept/vocabulary summary (associative entity,
candidate/alternate key, CHECK vs ENUM vs lookup table); the
attempt/mistake/revision narrative itself already lives in `my-work.md`'s
own "สิ่งแก้ไข" notes under Revision, so this is the right split, not a
gap.

`labs/02-database-design/02-normalization-1nf-2nf-3nf/` — attempt done
(`my-work.md`, Problems 1-3), reviewed (`ai-review.md`). Took a flat
`sales_flat` table through 1NF/2NF/3NF to a 6-table schema (`customer`,
`product`, `category`, `salesperson`, `invoice`, `invoice_item`), then
deployed it for real to a Postgres schema (`lab_02_02`) and re-ran all
three Problem-1 anomaly scenarios live — all three confirmed resolved
(`evidence/normalized_schema_test.txt`). No `## Experiment` section
written in `my-work.md` — deliberately skipped by the user, who judged
`ai-review.md` + the evidence file sufficient; flagged as a process
deviation (no user-authored record of the real-run step for this lab) but
respected as their call. `reflection.md` written (concept/vocabulary
summary, plus a note connecting the Problem 3 denormalization question to
materialized views/reporting tables as an alternative).

Repo structure note: `my-attempt.md` / `my-revision.md` / `experiment.md`
were merged into a single `my-work.md` per lab (append-only sections) on
2026-09-09, at the user's request — see `CLAUDE.md`.

## Topics I understand (with evidence)

- **LEFT JOIN vs INNER JOIN choice, and `ON` vs `WHERE` placement on outer
  joins** — evidence: problems 1 and 2 of the joins lab, plus the mistake
  log entry on WHERE-silently-becomes-INNER-JOIN.
- **COUNT(DISTINCT ...) vs plain COUNT, and picking a guaranteed-unique
  column for DISTINCT** — evidence: problem 3, found and fixed the
  DISTINCT-on-`name` bug without being told, twice (customer count, product
  grouping).
- **GROUP BY grain (what defines "one row per X")** — evidence: problem 3's
  first attempt grouped at the wrong grain; corrected after review.
- **Basic window functions (`RANK() OVER (PARTITION BY ...)`)** — evidence:
  optional stretch; first attempt partitioned by the wrong column
  (inverted the question), self-corrected to `PARTITION BY c.id` once the
  duplicate-row symptom was explained.
- **`LEFT JOIN ... ON` vs `WHERE` for preserving unmatched rows through an
  aggregate** — evidence: lab 02 problem 4, placed the
  `status = 'completed'` filter inside the `LEFT JOIN`'s `ON` clause
  unprompted (first attempt), correctly keeping zero-spend customers in the
  average's input. This is the mirror image of the LEFT JOIN/WHERE mistake
  logged from lab 01 — same mechanism, applied correctly this time.
- **`IN` as a membership test / `EXISTS` as a per-row boolean, not a join**
  — evidence: lab 02 problem 1, correctly reasoned through why neither
  needs `DISTINCT`, and why removing the correlation predicate from
  `EXISTS` breaks it (subquery becomes constant across all outer rows).
- **`NOT IN` + `NULL` three-valued-logic trap, and why `NOT EXISTS` is
  immune** — evidence: lab 02 problem 2 (theoretical — schema's `NOT NULL`
  constraint prevented a real test). Correctly derived that one `NULL` in
  a `NOT IN` subquery's result poisons the comparison for every outer row,
  not just the row that happens to match it.
- **Nested aggregates require an intermediate step** — evidence: lab 02
  problem 4, correctly explained why `total_spend` had to be materialized
  in a CTE before `avg()` could run over it (`avg(sum(...))` in one pass
  isn't legal).
- **`RANK()` vs `ROW_NUMBER()` under ties** — evidence: lab 02 problem 5,
  first draft used `RANK()` (would return >1 row per city on a tie),
  self-corrected to `ROW_NUMBER()` with a deterministic tiebreaker
  (`ORDER BY total_spend DESC, c.id ASC`) once asked to reason through the
  tie scenario directly.
- **M:N relationships need a real associative entity, not an inferred
  path** — evidence: db-design lab 01, self-corrected to adding
  `product_supplier` as a junction table with its own attributes
  (`supplier_price`, `lead_time_days`) once asked what "which suppliers can
  supply this product" would return for a product with zero delivery
  history yet.
- **A mutable status flag can't represent a history-bearing event** —
  evidence: db-design lab 01, dropped `status` from `sale_item`/
  `delivery_item` in favor of a deferred separate `sale_return` concept
  once asked how a single-line partial return would be represented, and
  once the parallel to this repo's own "never overwrite, append
  corrections" rule was pointed out.
- **CHECK constraints are a DB-level safety net independent of app
  validation** — evidence: db-design lab 01, agreed from direct UAT
  experience that app-only validation isn't sufficient, and then verified
  live that `chk_product_status_match` / `chk_sale_status_match` /
  `chk_sale_item_quantity` all actually reject bad data at the DB level
  (`evidence/constraint_tests.txt`).
- **Normalization (1NF/2NF/3NF) via functional dependencies, checked
  against real data rather than recited from rules** — evidence:
  db-design lab 02, every correction (wrong 2NF key, missing line-item
  table, misplaced quantity/unit_price, 2NF/3NF conflation) was resolved
  by testing a specific attribute against the exercise's own sample rows,
  not by re-reading the definitions. End schema verified live in
  Postgres: all 3 anomalies from Problem 1 confirmed gone.
- **A column can appear in two tables without being a normalization
  violation, if it's two different facts sharing a name** — evidence:
  db-design lab 02, correctly reasoned that `product.unit_price`
  (current price) and `invoice_item.unit_price` (price at time of sale)
  are independent facts, by direct analogy to `order_items.unit_price` in
  lab 01-sql/01-joins-and-aggregation.
- **Denormalization decisions need a concrete read pattern, not just
  "performance"** — evidence: db-design lab 02 Problem 3, initially cited
  performance as a second justification for caching `product_name`,
  then honestly retracted it once asked to name the actual query that
  would benefit (none — `product_code` is a PK, the join is cheap),
  keeping only the historical-snapshot argument. Correction was appended
  as a parenthetical next to the original claim rather than deleted.

## Topics needing review

- **Query result ordering guarantees** — problem 5's tie-breaker question
  (LIMIT without a deterministic ORDER BY) was explained but not tested
  against a real tie. Worth a real experiment later: force a tie in seed
  data and observe whether output order actually changes across runs/plans.
- Window functions generally — RANK/ROW_NUMBER now both used once each,
  but only with a single partition/order column; hasn't been tested with
  multiple partition/order columns or `DISTINCT ON` as an alternative.
- Repeated/redundant subquery evaluation cost (lab 02 problem 3: category
  average computed twice per row) noted but not measured — no
  `EXPLAIN ANALYZE` done yet on any query in this repo.
- `INNER JOIN` vs `LEFT JOIN` when the "many" side could be entirely absent
  for a given group (lab 02 problem 5: an all-zero-spend city would
  silently disappear from output) — understood as a design question when
  pointed out, not yet caught unprompted.

## Important mistakes

Five logged, see [notes/mistakes.md](notes/mistakes.md): LEFT JOIN + WHERE
silently becoming INNER JOIN, GROUP BY grain mismatch + DISTINCT on a
non-unique column, PARTITION BY on the wrong side of a window function,
(2026-09-11) a CHECK constraint copy-pasted from `product` onto `sale`/
`delivery` without adjusting it to their own domain, and (2026-09-15)
repeatedly misplacing attributes relative to a composite key in
db-design lab 02 (the actual key claimed to be single-column at first,
then `unit_price` and separately `quantity` each wrongly assigned to only
part of the composite key after that) — same underlying gap (not
mechanically re-checking every attribute against the key) surfacing three
times in one session. No new formal log entry from lab 02-sql
(subqueries) — the one near-miss (RANK() not being tie-safe) was
self-caught before being written down, so it's in `ai-review.md` rather
than `mistakes.md`.

## Experiments performed

Real queries run against the seeded Postgres database for all 5 required
problems and the optional stretch in
`labs/01-sql/01-joins-and-aggregation/`, and for all 5 required problems in
`labs/01-sql/02-subqueries-and-exists-vs-in-vs-join/`; outputs captured in
`my-attempt.md` (and `evidence/` for lab 01), hand-verified against
manually recalculated expected values. No `EXPLAIN ANALYZE`/performance
experiments yet in either SQL lab — both were about correctness, not
performance.

`labs/02-database-design/01-core-schema-keys-and-relationships/`: full
revised schema (8 tables, 32 constraints) deployed to a real Postgres
schema and tested with 8 happy-path inserts (all succeeded) plus 7
deliberately invalid inserts, one per constraint category (all failed on
the intended constraint, none silently passed or failed on the wrong one).
First real DDL-execution + constraint-violation experiment in this repo, as
opposed to query-correctness testing.

`labs/02-database-design/02-normalization-1nf-2nf-3nf/`: the final
6-table normalized schema deployed to a real Postgres schema
(`lab_02_02`), seeded with the exercise's own sample data (join
reconstructs the original flat rows exactly), then each of the three
Problem 1 anomalies re-run live against it (one-row `UPDATE` fixing every
referencing row, an `INSERT` of a product with no sale needed, a `DELETE`
that no longer takes out unrelated master data) — all three confirmed
resolved.

## Current difficulty

Junior/mid backend level. SQL fundamentals solidifying (lab 01); now two
labs into database design. Correctly applied one lab-01 SQL lesson (LEFT
JOIN + ON-vs-WHERE) unprompted in lab 02-sql, self-corrected a
tie-safety window-function bug (RANK → ROW_NUMBER), and in the design labs
self-corrected repeatedly on pointed questions (missing M:N junction
table, mutable status flag standing in for a history-bearing event, wrong
composite key, missing line-item table) rather than needing fixes stated
directly — the normalization lab in particular needed the *same*
correction pattern (check this attribute against the composite key)
reapplied three times before it stuck, which is itself useful signal
about where understanding is still shallow. Still needs prompting toward
less obvious edge cases (e.g. initially reasoned that JOIN+DISTINCT scales
better than EXISTS, which is backwards; initially defended a missing
junction table with a normalization argument that was backwards) and
hasn't yet run a performance experiment (`EXPLAIN ANALYZE`) to back up
cost claims made in reviews.

## Recommended next step

Write `reflection.md` for `01-joins-and-aggregation` and
`02-subqueries-and-exists-vs-in-vs-join` (user's own words, not
AI-drafted) — neither has one yet. Both db-design labs already have one.

A quick, unprompted follow-up check on composite keys (2NF: does this
attribute need the whole key or just part of it) would be worth doing
before the next design lab, given it was the one thing that didn't stick
on the first, second, or even third correction in lab 02.2 — see the
2026-09-15 entry in `notes/mistakes.md`.

After that: remaining `01-sql` curriculum topics not yet covered by a lab
— CTEs (including recursive), window functions with multiple
partition/order columns, UNION/UNION ALL, pagination (OFFSET/LIMIT vs
keyset), INSERT/UPDATE/DELETE, and upsert (`ON CONFLICT`) — and for
`02-database-design`, the deferred items already surfaced in lab 01:
`product_supplier` price tiers, and `sale_return`/`delivery_return`, plus
schema evolution/migrations (the last uncovered topic in the
`02-database-design` curriculum). A pagination lab would also be the
natural place to finally run a real `EXPLAIN ANALYZE` experiment, since
"why OFFSET 1000000 is a problem" only actually convinces from a real
plan/timing, not an explanation.

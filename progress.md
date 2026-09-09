# Progress

Last updated: 2026-09-09

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

## Labs completed

`labs/01-sql/01-joins-and-aggregation/` — attempt done (`my-attempt.md`),
reviewed (`ai-review.md`). Still open: user reflection
(`reflection.md`) not yet written.

`labs/01-sql/02-subqueries-and-exists-vs-in-vs-join/` — attempt done
(`my-attempt.md`, 5/5 problems), reviewed (`ai-review.md`, no correctness
issues found). `my-revision.md` deliberately skipped — the two points
`ai-review.md` flagged (redundant category-average subquery evaluation in
problem 3, `INNER JOIN` silently dropping an all-zero-spend city in problem
5) are query-cost/edge-case notes, not bugs, and the user judged a revision
unnecessary rather than being told to skip it. `reflection.md` not yet
written.

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

Three logged this session, see [notes/mistakes.md](notes/mistakes.md):
LEFT JOIN + WHERE silently becoming INNER JOIN, GROUP BY grain mismatch +
DISTINCT on a non-unique column, and PARTITION BY on the wrong side of a
window function. No new formal log entries from lab 02 — the one near-miss
(RANK() not being tie-safe, lab 02 problem 5) was self-caught during the
attempt itself, before being written down as a wrong answer, so it's
recorded in `ai-review.md` rather than `mistakes.md`.

## Experiments performed

Real queries run against the seeded Postgres database for all 5 required
problems and the optional stretch in
`labs/01-sql/01-joins-and-aggregation/`, and for all 5 required problems in
`labs/01-sql/02-subqueries-and-exists-vs-in-vs-join/`; outputs captured in
`my-attempt.md` (and `evidence/` for lab 01), hand-verified against
manually recalculated expected values. No `EXPLAIN ANALYZE`/performance
experiments yet in either lab — both were about correctness, not
performance.

## Current difficulty

Junior/mid backend level, SQL fundamentals solidifying. Correctly applied
one lab-01 lesson (LEFT JOIN + ON-vs-WHERE) unprompted in lab 02, and
self-corrected a tie-safety window-function bug (RANK → ROW_NUMBER) once
asked to reason through a tie scenario rather than being told the fix
directly. Still needs prompting toward less obvious edge cases (e.g.
initially reasoned that JOIN+DISTINCT scales better with query complexity
than EXISTS, which is backwards) and hasn't yet run any performance
experiment (`EXPLAIN ANALYZE`) to back up cost claims made in reviews.

## Recommended next step

Write `reflection.md` for both `01-joins-and-aggregation` and
`02-subqueries-and-exists-vs-in-vs-join` (user's own words, not
AI-drafted) to close them out — neither has one yet. After that, remaining
`01-sql` curriculum topics not yet covered by a lab: CTEs (including
recursive), window functions with multiple partition/order columns,
UNION/UNION ALL, pagination (OFFSET/LIMIT vs keyset — "why one breaks at
scale" is an explicit curriculum target), INSERT/UPDATE/DELETE, and upsert
(`ON CONFLICT`). A pagination lab would also be the natural place to
finally run a real `EXPLAIN ANALYZE` experiment, since "why OFFSET
1000000 is a problem" only actually convinces from a real plan/timing, not
an explanation.

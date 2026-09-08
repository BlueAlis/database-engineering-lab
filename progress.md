# Progress

Last updated: 2026-09-08

This file is a status snapshot, not a score. No percentages unless there's a
concrete basis for the number (e.g. "9/12 exercises in this lab done").

## Topics studied

- SQL joins and aggregation — 5/5 required problems + optional stretch
  attempted, run against a real Postgres instance, and reviewed
  (`labs/01-sql/01-joins-and-aggregation/`). Started from: comfortable with
  single-table SQL, joins/aggregation previously handled by JPA/Hibernate
  rather than hand-written.

## Labs completed

`labs/01-sql/01-joins-and-aggregation/` — attempt done (`my-attempt.md`),
reviewed (`ai-review.md`). Still open: user reflection
(`reflection.md`) not yet written.

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

## Topics needing review

- **Query result ordering guarantees** — problem 5's tie-breaker question
  (LIMIT without a deterministic ORDER BY) was explained but not tested
  against a real tie. Worth a real experiment later: force a tie in seed
  data and observe whether output order actually changes across runs/plans.
- Window functions generally — only one example done (RANK with a single
  partition column); hasn't been tested with multiple partition/order
  columns or with `ROW_NUMBER`/`DISTINCT ON` alternatives.

## Important mistakes

Three logged this session, see [notes/mistakes.md](notes/mistakes.md):
LEFT JOIN + WHERE silently becoming INNER JOIN, GROUP BY grain mismatch +
DISTINCT on a non-unique column, and PARTITION BY on the wrong side of a
window function.

## Experiments performed

Real queries run against the seeded Postgres database for all 5 required
problems and the optional stretch in
`labs/01-sql/01-joins-and-aggregation/`; outputs captured in
`my-attempt.md` and `evidence/`. No `EXPLAIN ANALYZE`/performance
experiments yet — this lab was about correctness, not performance.

## Current difficulty

Junior/mid backend level, SQL fundamentals in progress. Handling
multi-table joins, aggregation, and basic window functions correctly, but
still needs to be walked toward edge cases (NULL semantics, uniqueness
assumptions, ordering guarantees) rather than catching them unprompted.

## Recommended next step

Write `reflection.md` for the joins-and-aggregation lab (user's own words,
not AI-drafted) to close it out. After that, move to the next curriculum
topic — check `curriculum/` for what comes after SQL joins/aggregation.

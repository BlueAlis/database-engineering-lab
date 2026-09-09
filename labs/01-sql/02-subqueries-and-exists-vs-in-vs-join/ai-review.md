# AI Review — subqueries-and-exists-vs-in-vs-join

Review of `my-attempt.md`. All 5 problems attempted and executed against the
real seed data; outputs were checked against manually recalculated expected
values and match.

## 1. Warm-up — JOIN vs IN vs EXISTS

All three queries correct, same 9 rows returned.

- (a) `JOIN` + `DISTINCT`: correct. Reasoning nailed the mechanism —
  1-to-many fan-out means a customer with N completed orders produces N
  identical `(name, city)` rows before `DISTINCT` collapses them.
- (b) `IN`: correct. Understood `IN` as a membership test evaluated once
  per outer row, not a join — duplicate ids in the subquery's result set
  don't affect the outer row count.
- (c) `EXISTS`: correct. Understood the outer query iterates `customers`,
  and the correlated subquery only decides keep/reject per row — it
  doesn't multiply rows. Also correctly reasoned through what breaks if the
  correlation predicate (`o.customer_id = c.id`) is removed: the subquery
  becomes constant across all outer rows, so `EXISTS` would return the same
  true/false for every customer regardless of whether that specific
  customer has any completed order.

No corrections needed here.

## 2. NOT EXISTS / NULL trap in NOT IN

Query correct: `NOT EXISTS` with a correlated join through `order_items`.
Output is 0 rows, which is correct — every one of the 12 products in this
seed dataset appears in at least one completed order (verified by hand
against `seed.sql`), so an empty result is the right answer, not a bug.

Theoretical answer on `NOT IN` + `NULL`: correct. Identified the mechanism
via three-valued logic — `x NOT IN (v1, v2, NULL)` is `x <> v1 AND x <> v2
AND x <> NULL`, and `x <> NULL` is `UNKNOWN`, so the whole `AND` chain can
never evaluate to `TRUE` once a `NULL` is anywhere in the subquery's result,
for every outer row (the subquery result is shared across all of them,
non-correlated). Correctly distinguished `NOT EXISTS`, which only checks
row presence/absence and never compares against the `NULL` value directly,
so it's immune. Labeled correctly as theoretical/not executed, consistent
with `order_items.product_id` being `NOT NULL` in this schema.

## 3. Correlated subquery — priced above category average

Correct. Output (5 products, one per category exceeding its own category's
average) matches hand-calculated expected values exactly. Correctly
explained the need for separate aliases (`p` vs `p2`) as different scopes —
outer row vs. the set being averaged over.

Noted in the attempt: the category-average subquery is evaluated twice
(once in `SELECT`, once in `WHERE`) — recomputing the same per-category
average redundantly for every row in that category. Flagged as something
to avoid via a CTE or a derived table (subquery in `FROM`, same shape as
problem 5). Not fixed in this file, correctly left as-is since the
exercise specifically asked for a correlated-subquery version — worth
revisiting as a variant if this lab gets a follow-up on query cost.

## 4. Scalar subquery — above-average spenders

Correct, and the join construction is the strongest part of this attempt:
the `status = 'completed'` filter is placed in the `LEFT JOIN ... ON`
clause rather than `WHERE`, which is exactly what's needed to keep
zero-spend customers (no completed orders at all) in the `total_spend` CTE
so they still pull the average down without themselves being filtered out
by the join. Confirmed in the actual output — `Green Roof Renovations`
shows up with `total_spend = 0` in the CTE, and the final average (11,205,
hand-verified) correctly seats it below the threshold rather than removing
it from the average's input entirely.

Final answer (Apex Builders, Thai Building Supply Partners, Delta
Infrastructure, Somchai Construction Co.) matches hand-calculated
expectation.

Correctly reasoned through why a CTE was necessary here: `avg(sum(...))`
in one pass is an illegal nested aggregate in Postgres, so per-customer
`total_spend` has to be materialized as an intermediate result before a
second aggregation (`avg`) can run over it.

## 5. Subquery in FROM — top spender per city

Final version correct. Output matches hand-calculated per-city max spend
for all four cities present in the data (Bangkok, Nonthaburi, Chiang Mai,
Chonburi).

Worth recording explicitly: the first draft used `RANK()`, which does
**not** guarantee one row per city — a tie for the top spot in a city
would produce two (or more) rows at `ranking = 1`, which the exercise's own
hint calls out as a requirement to satisfy. Correctly diagnosed this and
switched to `ROW_NUMBER()` with a deterministic tiebreaker
(`order by total_spend desc, c.id asc`), which guarantees exactly one row
per partition regardless of ties — at the cost of the tiebreak being
somewhat arbitrary (lowest `c.id` wins), which is an accepted, understood
tradeoff rather than an oversight.

Also worth noting for later (not a bug against this dataset, since every
city here has at least one customer with a completed order): this query
uses `INNER JOIN` all the way through, so a city where *every* customer has
zero completed orders would silently disappear from the output entirely,
rather than appearing with a zero-spend "top" customer. Whether that's
correct behavior depends on how the question is interpreted — flagging it
as a design edge case worth being aware of, not something that needs a fix
here.

## Overall

No incorrect final answers across the 5 problems. Reasoning in the notes
consistently identifies the actual mechanism (not just "it works") for
DISTINCT/fan-out, IN-as-membership-test, EXISTS-as-per-row-boolean, the
NULL/three-valued-logic trap in NOT IN, nested-aggregate restrictions, and
RANK() vs ROW_NUMBER() under ties. Strongest moment in this lab was
placing the status filter inside the LEFT JOIN's ON clause in problem 4
without being told to — that's a mistake most people make at least once
before it clicks.

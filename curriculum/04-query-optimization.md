# 04 — Query Optimization

Reading and reasoning about execution plans well enough to explain, not just
identify, what's slow.

## Topics

- `EXPLAIN` vs `EXPLAIN ANALYZE`
- Sequential scan
- Index scan / index-only scan
- Bitmap scan
- Nested loop join
- Hash join
- Merge join
- Sort (and why it sometimes spills to disk)
- Aggregate strategies
- The query planner (cost model, not just "the planner is smart")
- Statistics (`ANALYZE`, `pg_stats`, how stale stats mislead the planner)

## Signs of real understanding

- Can read an `EXPLAIN ANALYZE` output and point to where estimated vs.
  actual rows diverge, and explain why that matters.
- Can explain why the planner picked a nested loop over a hash join for a
  specific query and dataset shape.
- Can reproduce a case where `ANALYZE` (stats) changes the chosen plan.

Labs: [`../labs/04-query-optimization/`](../labs/04-query-optimization/)

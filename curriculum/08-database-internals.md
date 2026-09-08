# 08 — Database Internals

The layer beneath everything else in this curriculum. Introduced gradually,
and only once the topics above have real footing — internals explain *why*
the earlier behavior happens, so they land better second.

## Topics

- Pages
- Buffer/cache (`shared_buffers`, how Postgres decides what stays in memory)
- WAL (write-ahead log)
- MVCC internals (tuple versions, xmin/xmax, how this connects back to
  topic 05's isolation levels)
- B-Tree internals (what topic 03 treated as a black box)
- VACUUM
- Autovacuum (and what happens when it falls behind)
- Statistics (how `ANALYZE` actually builds `pg_stats`)
- Query planner internals (cost constants, `pg_stat_statements` in
  practice)
- Storage behavior (TOAST, tuple layout, alignment/padding)

## Signs of real understanding

- Can explain why an `UPDATE` in Postgres creates a new tuple instead of
  modifying in place, and connect that to bloat and autovacuum.
- Can read `pg_stat_user_tables` and identify a table that needs vacuum
  attention, with a reason.
- Can connect a topic-03/04 observation (e.g. planner ignoring an index) to
  an internals-level cause (stale statistics, bad selectivity estimate).

Labs: [`../labs/08-database-internals/`](../labs/08-database-internals/)

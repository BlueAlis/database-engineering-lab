# 03 — Indexing

Indexes are a trade-off, not free performance. This topic is about proving
that trade-off with real data, not reciting "add an index."

## Topics

- B-Tree indexes (structure and what makes them fast for what)
- Composite indexes (column order matters — prove it)
- Cardinality and selectivity
- Covering indexes
- Partial indexes
- Expression indexes
- Index-only scans
- Index maintenance cost (write amplification, bloat)
- Why PostgreSQL may choose *not* to use an index that exists

## Signs of real understanding

- Given a slow query, can form a hypothesis about why, check it against
  `EXPLAIN ANALYZE`, and only then propose an index — not the reverse.
- Can predict which column should lead a composite index and verify it.
- Can explain a case where adding an index made things worse.

Labs: [`../labs/03-indexing/`](../labs/03-indexing/)

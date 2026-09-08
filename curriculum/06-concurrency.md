# 06 — Concurrency

Making concurrent access correct under real, simultaneous load — not just
single-connection testing that happens to look fine.

## Topics

- Race conditions
- Lost updates
- Row locks
- `SELECT ... FOR UPDATE`
- Optimistic locking (version columns)
- Pessimistic locking
- Deadlocks (causing one on purpose, then reading the detection output)
- Lock ordering as a prevention strategy

## Signs of real understanding

- Can reproduce a lost update with two concurrent sessions before fixing it.
- Can explain the trade-off between optimistic and pessimistic locking for
  a specific scenario (e.g. concurrent stock decrement at checkout), not
  just in the abstract.
- Can deliberately cause and read a real Postgres deadlock, then fix it via
  lock ordering.

Labs: [`../labs/06-concurrency/`](../labs/06-concurrency/)

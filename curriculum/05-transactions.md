# 05 — Transactions

What a transaction actually guarantees, and where those guarantees end.

## Topics

- ACID (each letter defended with an example, not just defined)
- Transaction boundaries (where they should start/end and why)
- COMMIT / ROLLBACK
- Isolation levels
- READ COMMITTED
- REPEATABLE READ
- SERIALIZABLE
- MVCC (conceptual level here; internals in topic 08)

## Signs of real understanding

- Can construct a scenario where READ COMMITTED produces a surprising
  result that REPEATABLE READ wouldn't, and observe it actually happen.
- Can explain what "isolation" does *not* protect against (e.g. write
  skew under REPEATABLE READ).
- Can reason about what happens if a transaction fails halfway through a
  multi-step operation (e.g. a bank-transfer-style debit/credit).

Labs: [`../labs/05-transactions/`](../labs/05-transactions/)

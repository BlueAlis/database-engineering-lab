# 07 — JPA/Hibernate

Where the ORM's abstraction leaks, and what's actually happening on the wire
underneath it. Knowing Spring does not mean knowing this.

## Topics

- Persistence context
- Entity lifecycle (transient, managed, detached, removed)
- Dirty checking
- Flush (and flush timing surprises)
- Lazy loading
- Eager loading
- N+1 (reproduce it, see it in logs, then fix it)
- Fetch join
- `@EntityGraph`
- DTO projection
- Batch operations
- Transaction boundaries in a Spring-managed context (`@Transactional`
  semantics, propagation)

## Signs of real understanding

- Can spot an N+1 by reading generated SQL (with `log_min_duration_statement`
  or `pg_stat_statements`), not just by being told it exists.
- Can explain when a fetch join is the wrong fix (e.g. pagination + join
  fetch on a collection).
- Can trace a `LazyInitializationException` back to the actual persistence
  context boundary that caused it.

Labs: [`../labs/07-jpa-hibernate/`](../labs/07-jpa-hibernate/)

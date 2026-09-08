# 02 — Database Design

Designing schemas that hold up under real usage and real change, not just
schemas that pass a first review.

## Topics

- Primary keys
- Foreign keys
- Constraints (`NOT NULL`, `CHECK`, `UNIQUE`)
- Relationships (1:1, 1:N, N:M)
- Normalization (1NF–3NF, BCNF)
- Denormalization (when and why it's a legitimate trade-off, not a mistake)
- Composite keys
- Surrogate keys vs natural keys
- Data integrity (what the database enforces vs what the app must)
- Schema evolution (migrations, backward-compatible changes, the cost of
  getting it wrong in production)

## Signs of real understanding

- Can justify a normalization/denormalization decision with a concrete
  read/write pattern, not just "normalization is good practice."
- Can design a schema for a real scenario (e.g. inventory + orders for a
  construction-material store) and defend the key choices under
  questioning.
- Can describe what breaks if a "safe-looking" migration runs on a large,
  live table.

Labs: [`../labs/02-database-design/`](../labs/02-database-design/)

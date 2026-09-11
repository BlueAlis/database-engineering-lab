# Exercise — Core Schema for a Construction-Material Store

## Problem 1 — core schema for inventory + sales

Design tables for a construction-material store with these requirements:

- Products are organized into categories (e.g. "cement", "rebar", "tools").
- Each product has a current stock quantity and a unit price.
- The store records sales — a sale can include multiple products, each with
  its own quantity sold at the time of sale.
- A supplier delivers stock; each delivery is tied to one supplier and can
  restock multiple products.

Write the `CREATE TABLE` statements (or just table/column sketches if you
want to go faster first) covering:

1. Primary keys for each table — surrogate or natural, your call, but be
   ready to defend it.
2. Foreign keys and the relationships they express (1:N or N:M).
3. At least one `CHECK` or `UNIQUE` constraint that isn't just "not null."

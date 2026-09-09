# Lab 01-sql / 02-subqueries-and-exists-vs-in-vs-join

## Why this lab

Follow-up to `01-joins-and-aggregation`. That lab was about joins and
GROUP BY; this one is about subqueries — scalar, correlated, in `WHERE`,
in `FROM` — and specifically about `EXISTS` vs `IN` vs `JOIN`: when they're
interchangeable and when they quietly stop being equivalent (NULLs,
duplicate rows).

## Scenario

Same schema and data as lab 01 — the construction-material store
(`customers`, `products`, `orders`, `order_items`). `setup/schema.sql` and
`setup/seed.sql` here are a straight copy of lab 01's, kept local to this
lab folder so it's self-contained.

## Setup

If the lab 01 Postgres container/data is already running with the same
schema/data loaded, nothing to do — reuse it. Otherwise (e.g. a clean
instance, or you want this lab isolated from lab 01):

```bash
cd docker
docker compose up -d
docker exec -i dbeng-lab-postgres psql -U lab -d dbeng_lab < ../labs/01-sql/02-subqueries-and-exists-vs-in-vs-join/setup/schema.sql
docker exec -i dbeng-lab-postgres psql -U lab -d dbeng_lab < ../labs/01-sql/02-subqueries-and-exists-vs-in-vs-join/setup/seed.sql
```

Connect however you like: `docker exec -it dbeng-lab-postgres psql -U lab -d dbeng_lab`, Adminer at http://localhost:8080, or any SQL client pointed at `localhost:5432`.

## Workflow

Same as lab 01. See [exercise.md](exercise.md). For each problem:

1. Write your query in `my-attempt.md` (create it yourself). Include the
   query and, once you run it, what it actually returned.
2. Don't ask for the reference solution before attempting it.
3. When you've attempted all of them (or want a check-in), say so and I'll
   review `my-attempt.md`.

## Files

- `exercise.md` — AI-authored, the problems
- `my-attempt.md` — **yours**, not created yet
- `ai-review.md` — created after your attempt

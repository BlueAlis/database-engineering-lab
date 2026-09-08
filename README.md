# Database Engineering Lab

This is a personal, long-term learning record for database engineering:
SQL, PostgreSQL, database design, indexing, query optimization, execution
plans, transactions, concurrency, locking, deadlocks, MVCC, JPA/Hibernate,
and database internals.

## What this is

A real learning log — attempts, mistakes, corrections, and real experiments
against a real PostgreSQL instance. It is **not** a tutorial or reference
repo, and it is not meant to look polished. Wrong answers followed by
corrected understanding are the point, not something to hide.

## What this is not

- Not AI-generated "personal notes" pretending to be my own understanding.
- Not a source of fabricated benchmark numbers — every number here came from
  an actual `EXPLAIN ANALYZE` or timed run, or is explicitly marked
  theoretical.
- Not a place where mistakes get quietly deleted once I know better.

See [CLAUDE.md](CLAUDE.md) for the full rules this repo (and any AI helping
with it) operates under.

## Structure

```
database-engineering-lab/
├── CLAUDE.md          rules for how AI assistance works in this repo
├── progress.md        current status: what's done, what's next
├── curriculum/         topic-by-topic syllabus (01-08)
├── labs/               hands-on exercises, one folder per topic
├── notes/
│   ├── concepts.md     working notes on concepts as I learn them
│   └── mistakes.md     log of real mistakes and what corrected them
└── docker/
    └── docker-compose.yml   local PostgreSQL for experiments
```

Within a lab, files are split by who wrote them:

- **My work** (`my-attempt.md`, `my-revision.md`, `experiment.md`,
  `reflection.md`) — my own reasoning and observations, unedited by AI.
- **AI assistance** (`exercise.md`, `ai-review.md`, `hints.md`,
  `reference-solution.md`) — clearly labeled help, reviews, and hints.

## Curriculum

1. SQL
2. Database Design
3. Indexing
4. Query Optimization
5. Transactions
6. Concurrency
7. JPA/Hibernate
8. Database Internals

Difficulty starts around junior/mid backend level and increases gradually.
Details in [curriculum/](curriculum/).

## Running the database

```bash
cd docker
docker compose up -d
```

See [docker/docker-compose.yml](docker/docker-compose.yml) for connection
details.

## Status

See [progress.md](progress.md) for current progress, open mistakes, and the
recommended next step.

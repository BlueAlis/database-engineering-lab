# Local PostgreSQL

```bash
docker compose up -d
```

Connection details:

| | |
|---|---|
| host | localhost |
| port | 5432 |
| user | lab |
| password | lab |
| database | dbeng_lab |

Adminer (simple DB browser UI) is available at http://localhost:8080 once
the stack is up — connect with the same credentials, system "PostgreSQL".

`pg_stat_statements` is preloaded and tracking all statements, and
`log_min_duration_statement=0` logs every statement's duration — useful for
query optimization labs. This is deliberately verbose for a learning
environment; not a production configuration.

To reset the database completely (destroys all data in the containers):

```bash
docker compose down -v
```

Each lab's `setup/` folder contains the schema/seed scripts for that lab.
Nothing is seeded automatically at container start — run the relevant lab's
setup script yourself.

# dbincloudproject — MySQL → Kafka (Debezium CDC) → Postgres + Kafka UI

This project runs a local CDC (Change Data Capture) pipeline:

**MySQL (source of truth)** → **Debezium MySQL Connector (Kafka Connect)** → **Kafka topics** → **Debezium JDBC Sink (Kafka Connect)** → **PostgreSQL (replica)**  
Plus **Kafka UI** to inspect topics, messages, and Kafka Connect status.

---

## Architecture

- **MySQL**: holds the `tennis` database and tables
- **Debezium MySQL Source connector**: reads MySQL binlog and produces change events to Kafka
- **Kafka**: stores CDC events in topics like `mysql.tennis.players`
- **Debezium JDBC Sink connector**: consumes topics and writes/upserts into Postgres
- **PostgreSQL**: receives replicated tables in schema `tennis`
- **Kafka UI**: browse topics/messages and monitor Connect

## How the pipeline works (high-level)

This project sets up a **Change Data Capture (CDC)** pipeline where **MySQL is the source of truth** and **PostgreSQL is a replicated copy**. Instead of periodically copying tables, it streams every change (insert/update/delete) as an event through Kafka, and then applies those events to Postgres.

At a high level, the data flow is:

**MySQL → Debezium (source connector) → Kafka topics → Debezium JDBC sink connector → PostgreSQL**  
and **Kafka UI** sits on the side so you can *observe* what’s happening (topics, messages, connector state).

---

## MySQL: where changes originate

Your application writes to MySQL tables (`players`, `tournaments`, `matches`, etc.). MySQL is configured to produce a **row-based binlog** (binary log). That binlog is an append-only record of all row-level changes the database performs.

Debezium does not “poll tables”. It reads the binlog stream so it can emit changes in near real-time, with ordering and consistency properties that match the database’s commit order.

---

## Debezium MySQL Source Connector: turning binlog into Kafka events

The Debezium **MySQL source connector** runs inside Kafka Connect. It connects to MySQL using a replication-capable user, then:

- Performs an **initial snapshot** (optional, depending on config) to capture current table contents.
- Continues streaming new changes by reading the **binlog**.
- Converts each row change into a Kafka message.

Each table maps to a Kafka topic (by convention):

- `mysql.tennis.players`
- `mysql.tennis.tournaments`
- `mysql.tennis.matches`
- `mysql.tennis.match_results`
- `mysql.tennis.player_rankings`

So when you insert a player in MySQL, an event is written to `mysql.tennis.players`. When you update a match, an event goes to `mysql.tennis.matches`, and so on.

---

## What a Debezium message looks like (conceptually)

Debezium produces structured messages that describe *what changed*, not just “the current row”. A typical event includes:

- The operation type: **insert / update / delete**
- The row **before** the change (for updates/deletes)
- The row **after** the change (for inserts/updates)
- Metadata about where it came from (database, table, binlog position, timestamps)

This “envelope” makes it possible for downstream systems to reason about change history and apply it safely.

---

## Kafka: the durable event log in the middle

Kafka stores these change events in topics. Think of it as a distributed, durable commit log:

- Producers (Debezium source) append events.
- Consumers (sink connector, Kafka UI, or anything else) read events independently.
- Kafka retains events for some configured duration, so consumers can restart and continue.

Kafka is what decouples “capturing changes” from “applying changes.” You can add more consumers later (analytics, search indexing, auditing) without touching MySQL.

---

## Kafka Connect: the runtime for connectors

Kafka Connect is a framework process that runs connectors as managed tasks. In this setup:

- One connector task reads from MySQL and produces to Kafka.
- Another connector task reads from Kafka and writes to Postgres.

Connect keeps internal state (configs, offsets, statuses) so it can resume where it left off after restarts.

---

## Debezium JDBC Sink Connector: applying events to PostgreSQL

The **JDBC sink** consumes the topics and turns Debezium events into SQL operations on Postgres.

In “upsert” mode it typically does:

- **INSERT** for new rows
- **UPDATE** when a row already exists (based on primary key)
- **DELETE** when it receives delete events (if enabled)

This is why primary keys matter: the sink needs a stable key to identify which row in Postgres corresponds to the row that changed in MySQL.

When schema evolution is enabled (basic), the sink can create tables and add columns in Postgres as it learns about the source schema from the event stream.

---

## PostgreSQL: the replicated target

Postgres ends up containing tables that mirror MySQL’s data. The goal is that after the initial snapshot and once streaming is running:

- Inserts in MySQL appear in Postgres
- Updates in MySQL are reflected in Postgres
- Deletes in MySQL remove corresponding rows in Postgres (if configured)

This creates a near real-time replica that can be queried independently from the source.

---

## Kafka UI: how you “see everything”

Kafka UI connects to Kafka (and optionally Kafka Connect) and provides visibility into the pipeline:

- **Topics view**: lists topics like `mysql.tennis.players`
- **Message browser**: lets you inspect actual Debezium events (the “before/after” envelope)
- **Consumer groups**: shows who is reading what and how far behind they are
- **Kafka Connect view**: shows connector status (RUNNING/FAILED), tasks, and error messages

Kafka UI doesn’t change data; it’s an observability tool so you can verify that events exist, that the sink is consuming them, and that the system is healthy.

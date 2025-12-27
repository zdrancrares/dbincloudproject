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


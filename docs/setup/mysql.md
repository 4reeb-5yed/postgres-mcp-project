# MySQL Setup Guide

[← Back to main README](../../README.md)

## Architecture

**Phase 1b — Docker + Claude Desktop (MySQL)**
```
Claude Desktop  --MCP (stdio, via uvx)-->  mysql-mcp  --SQL-->  MySQL (Docker, port 3306)
```

## Setup

1. Start the MySQL container:
   ```powershell
   docker run -d --name local-mysql -e MYSQL_ROOT_PASSWORD=changeme -e MYSQL_DATABASE=testdb -p 3306:3306 mysql:8
   ```
   Give it ~30 seconds to finish initializing before connecting.

2. Seed the schema:
   ```powershell
   docker exec -i local-mysql mysql -uroot -pchangeme testdb < ../../sql/mysql/employees_schema.sql
   ```
   (Uses a different sample dataset from the Postgres version — Ethan Walker, Priya Sharma, Marcus Lee, Sofia Rossi, Noah Kim — deliberately, to keep the two databases visibly distinct when testing both at once.)

3. Add the contents of `../../config/mysql/claude_desktop_config.example.json` to the `mcpServers` key in Claude Desktop's config, alongside the existing `postgres-mcp` entry — don't remove it, both run independently.

4. Fully quit and reopen Claude Desktop, confirm `mysql-mcp` shows status **running** in Settings → Developer.

5. Since two databases are connected at once, be explicit about which one a prompt should hit, e.g. *"Using the MySQL connection, what columns does the employees table have?"*

## Gotchas

- `mysql-mcp-server` (installed via `uvx --from mysql-mcp-server mysql_mcp_server`) worked cleanly on the first attempt — no dependency pinning or version workaround needed, unlike `postgres-mcp`'s `mcp` 2.0.0 breaking-change issue documented above.
- On the code-generation validation prompt, Claude's execution sandbox couldn't reach the local MySQL instance directly over the network (it only has access to package registries). It generated a correct standalone Python script instead, along with a chart image rendered from the live-queried data pulled via the MCP connection itself — so the underlying data is still real and live, just the final plotting step ran outside the sandbox.

## Validation Screenshots

The same 4 prompts from the original guide, run live against MySQL:

[![Schema query](../screenshots/mysql/mysql_query_schema.png)](../screenshots/mysql/mysql_query_schema.png)
[![Aggregation query](../screenshots/mysql/mysql_query_aggregation.png)](../screenshots/mysql/mysql_query_aggregation.png)
[![Top salary query](../screenshots/mysql/mysql_query_topquery.png)](../screenshots/mysql/mysql_query_topquery.png)
[![Codegen query](../screenshots/mysql/mysql_query_codegen.png)](../screenshots/mysql/mysql_query_codegen.png)

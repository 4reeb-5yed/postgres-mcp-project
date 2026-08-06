# Local Postgres + MCP Integration

Connecting an AI assistant to a local PostgreSQL database via the Model Context Protocol (MCP) — two configurations: a cloud-model version (Claude Desktop) and a fully local, offline version (Ollama).

Built as part of an internship project. Full build log and design decisions: see [PLAN.md](./PLAN.md).

## Architecture

**Phase 1 — Docker + Claude Desktop**
```
Claude Desktop  --MCP-->  postgres-docker-mcp (Docker)  --SQL-->  Postgres (Docker, local)
```

**Phase 2 — Fully local with Ollama**
```
Ollama (local LLM)  --MCP-->  postgres-mcp (Docker)  --SQL-->  Postgres (Docker, local)
```

## Status

- [x] Plan written
- [ ] Phase 1: Docker + Claude Desktop — in progress
- [ ] Phase 2: Ollama, fully local — not started

## Quick Start (Phase 1, Windows)

1. Make sure Docker Desktop is running (`docker ps` should return without error).
2. Copy `.env.example` to `.env` and set a real password.
3. Start the database: `.\scripts\phase1_start_db.ps1`
4. Seed the schema: `Get-Content sql\phase1_employees_schema.sql | docker exec -i local-postgres psql -U postgres`
5. Copy `config/claude_desktop_config.phase1.example.json` into `%APPDATA%\Claude\claude_desktop_config.json`, filling in your real password.
6. Fully quit and reopen Claude Desktop.
7. Confirm the MCP tool indicator is active, then try: *"What columns does the employees table have?"*

## Security Notes

- `POSTGRES_READ_ONLY=true` is enforced at the MCP wrapper level, not by Postgres itself.
- No real credentials are committed — see `.env.example` and `.gitignore`.
- See [PLAN.md](./PLAN.md) Section 8 for the full security write-up.

## License

MIT (or update as preferred).

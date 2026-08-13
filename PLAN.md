# Local Postgres + MCP Integration — Project Plan

**Context:** Internship project. Goal is to connect an AI assistant to local relational databases using the Model Context Protocol (MCP), with Claude Desktop as the client. This document is the single source of truth for the build and doubles as the write-up for a portfolio/GitHub showcase.

---

## 1. Objective

Build, document, and demo a working example of an AI assistant querying a local relational database through MCP:

- **Phase 1 (Docker + Claude Desktop):** Cloud-hosted LLM (Claude Desktop) ↔ MCP server (Docker) ↔ local Postgres.

**Why this is a good portfolio piece:** it demonstrates containerization, database schema design, protocol-level AI tool integration, security-conscious configuration (read-only access, credential handling), and clear technical documentation — relevant to your cybersecurity + full-stack + applied-AI positioning.

---

## 2. Analysis of the Source Document

You gave me a PDF to work from. Here's a thorough read of it, including gaps that need to be filled in before it's actually followable by someone with zero prior setup.

### 2.1 `Docker_Postgres_MCP_Setup_Guide.pdf` (2 pages)

| Section | What it covers | Gaps / issues found |
|---|---|---|
| System Architecture Overview | Local AI client → MCP container (Docker) → Target local DB | Assumes you already know what MCP is; no mention of installing Docker itself |
| Step 1: Initialize DB & Mock Data | `docker run postgres:15`, then `psql` to create an `employees` table + 4 rows | Assumes Docker Desktop is installed and running; no verification step (`docker --version`, `docker ps`) |
| Step 2: Configure Client Routing | JSON block for `claude_desktop_config.json` / `.cursor/mcp.json`, using `openmcpserver/mcp-postgres:latest` with `DATABASE_URL` + `POSTGRES_READ_ONLY=true` | Doesn't say **where** that config file lives per OS; doesn't mention this image needs to be pulled/exists on Docker Hub the first time it runs (first run will be slower — image pull) |
| Step 3: Validation | Restart client, look for connection indicator, run test prompts | No troubleshooting section (what if the badge doesn't appear, what if the container exits immediately, port conflicts, etc.) |

**Security note:** `POSTGRES_READ_ONLY=true` here is enforced by the **MCP wrapper**, not by Postgres itself — the DB user (`postgres`, the superuser) can still write if something bypasses the wrapper. Worth calling out in the write-up as a "known limitation, mitigated by X" — good talking point in an interview.

---

## 3. Answering Your Setup Questions

- **Is there a database already?** No. The setup creates a **new, empty Postgres container from a public Docker image**. You build the schema and data from scratch as part of the exercise — this is intentional (it's a demo/sandbox, not connecting to a real system).
- **What's assumed but not stated?** Docker Desktop installed + running, and Claude Desktop installed. All covered in Phase 0 below.

---

## 4. Prerequisites (Phase 0 — before any guide steps)

| Tool | Needed for | Install check |
|---|---|---|
| Docker Desktop | All phases | `docker --version` and `docker ps` should run without error |
| Claude Desktop (or Cursor) | MCP client | App installed, signed in |
| A terminal (PowerShell/Terminal) | All | — |
| `psql` client (optional, for double-checking outside Docker) | Optional | — |

**Action item:** confirm which OS you're on (Windows / macOS / Linux) — config file paths and `host.docker.internal` behavior differ, especially on Linux where you need `--add-host=host.docker.internal:host-gateway` explicitly. I'll tailor the exact commands once confirmed.

---

## 5. Repository Structure (for GitHub / portfolio)

```
postgres-mcp-local-integration/
├── README.md                     # Main showcase doc: overview, architecture, demo GIF/screenshots
├── PLAN.md                       # This file — full project plan
├── docs/
│   ├── architecture-phase1.png   # Diagram: Claude Desktop -> MCP -> Postgres
│   └── screenshots/              # Connection badge, sample query results, etc.
├── sql/
│   └── phase1_employees_schema.sql
├── config/
│   └── claude_desktop_config.phase1.example.json
├── .env.example                  # Placeholder credentials, never the real ones
├── .gitignore                    # Ignore real .env, local docker volumes, etc.
└── scripts/
    └── phase1_start_db.sh
```

**Note on secrets:** none of the passwords from the PDFs (`mysecretpassword`, `SecurePassword123`) should go into the public repo verbatim — the repo will use placeholder values referencing `.env`, which is good practice to show in a portfolio anyway (demonstrates you know not to hardcode credentials).

---

## 6. Phase 1 — Docker + Claude Desktop (build this first)

### 6.1 Steps

1. **Verify Docker is running** — `docker --version`, `docker ps`.
2. **Start Postgres container** — named `local-postgres`, port 5432, password via env var.
3. **Create schema + seed data** — `employees` table, 4 rows, via `psql` inside the container.
4. **Locate and edit Claude Desktop's config file** (OS-specific path) — add the `postgres-docker-mcp` MCP server block, with `POSTGRES_READ_ONLY=true`.
5. **Restart Claude Desktop fully** (quit, not just close window).
6. **Verify connection** — look for the tool/plug icon in the chat input.
7. **Run validation prompts** — schema question, aggregation question, code-generation question (matches the 3 examples in the original PDF).
8. **Capture screenshots** for the portfolio at each key step (container running, config file, connection badge, query result).
9. **Document findings** — note actual behavior vs. the guide, any errors hit and how resolved (this becomes great README content).

### 6.2 Deliverables from this phase
- Working Phase 1 setup
- `sql/phase1_employees_schema.sql`
- `config/claude_desktop_config.phase1.example.json`
- Screenshots in `docs/screenshots/`
- README section: "Phase 1: Docker + Claude Desktop"

---

## 8. Security & Best Practices Section (for the writeup)

Things worth explicitly calling out — good for both correctness and for showing security awareness in a portfolio piece:

- Never commit real credentials — use `.env` + `.env.example`.
- `POSTGRES_READ_ONLY` is an MCP-wrapper-level control, not a Postgres-level one. For a more rigorous setup, mention (even if not implemented) creating a dedicated read-only Postgres role via `GRANT SELECT` instead of relying solely on the wrapper flag.
- `--rm` on the MCP container means credentials passed via `-e` don't persist on disk in the container layer, but they are visible in shell history / process list while running — worth a line in the "lessons learned" section.
- Note the Linux-specific `host.docker.internal` caveat if applicable.

---

## 9. Documentation / Portfolio Plan

- **README.md** — the front door. Should include: one-paragraph summary, architecture diagram, quick-start commands, screenshots/GIF of a live query, "what I learned" section, security notes.
- **Architecture diagrams** — a simple box diagram (Phase 1 flow). Can generate this as a clean SVG.
- **Screenshots/demo** — at minimum: container running (`docker ps`), config file diff, connected badge in Claude Desktop, one successful natural-language query + result.
- **GitHub repo** — public, with the structure in Section 5, proper `.gitignore`, MIT or similar license if you want it fully open.

---

## 10. Next Steps (in order)

1. Confirm your OS (Windows/macOS/Linux) so I can give exact config file paths and commands.
2. I generate the actual files: SQL scripts, `.env.example`, MCP config templates, `.gitignore`, starter `README.md` — each with real content, not placeholders, based on the corrected/hardened version of the guides above.
3. You run Phase 1 commands on your machine; we debug together as needed.
4. Once Phase 1 is verified, capture screenshots.
5. Finalize README + push to GitHub.

---

## 11. Open Questions for You

- OS you're building this on?
- Do you want the GitHub repo public (portfolio-facing) from the start, or private until it's polished?
- Any preference on repo name? (Placeholder used above: `postgres-mcp-local-integration`)

# Local Postgres + MCP Integration — Project Plan

**Context:** Internship project. Goal is to connect an AI assistant to a local PostgreSQL database using the Model Context Protocol (MCP), in two stages — first with Claude Desktop (cloud model, local DB), then with Ollama (fully local model + local DB). This document is the single source of truth for the build and doubles as the write-up for a portfolio/GitHub showcase.

---

## 1. Objective

Build, document, and demo a working example of an AI assistant querying a local relational database through MCP, in two configurations:

- **Phase 1 (Docker + Claude Desktop):** Cloud-hosted LLM (Claude Desktop) ↔ MCP server (Docker) ↔ local Postgres.
- **Phase 2 (Ollama, fully local):** Local LLM (Ollama) ↔ MCP server (Docker) ↔ local Postgres. Nothing leaves the machine.

**Why this is a good portfolio piece:** it demonstrates containerization, database schema design, protocol-level AI tool integration, security-conscious configuration (read-only access, credential handling), and clear technical documentation — relevant to your cybersecurity + full-stack + applied-AI positioning.

---

## 2. Analysis of the Source Documents

You gave me two PDFs to work from. Here's a thorough read of both, including gaps that need to be filled in before they're actually followable by someone with zero prior setup.

### 2.1 `Docker_Postgres_MCP_Setup_Guide.pdf` (2 pages)

| Section | What it covers | Gaps / issues found |
|---|---|---|
| System Architecture Overview | Local AI client → MCP container (Docker) → Target local DB | Assumes you already know what MCP is; no mention of installing Docker itself |
| Step 1: Initialize DB & Mock Data | `docker run postgres:15`, then `psql` to create an `employees` table + 4 rows | Assumes Docker Desktop is installed and running; no verification step (`docker --version`, `docker ps`) |
| Step 2: Configure Client Routing | JSON block for `claude_desktop_config.json` / `.cursor/mcp.json`, using `openmcpserver/mcp-postgres:latest` with `DATABASE_URL` + `POSTGRES_READ_ONLY=true` | Doesn't say **where** that config file lives per OS; doesn't mention this image needs to be pulled/exists on Docker Hub the first time it runs (first run will be slower — image pull) |
| Step 3: Validation | Restart client, look for connection indicator, run test prompts | No troubleshooting section (what if the badge doesn't appear, what if the container exits immediately, port conflicts, etc.) |

**Security note:** `POSTGRES_READ_ONLY=true` here is enforced by the **MCP wrapper**, not by Postgres itself — the DB user (`postgres`, the superuser) can still write if something bypasses the wrapper. Worth calling out in the write-up as a "known limitation, mitigated by X" — good talking point in an interview.

### 2.2 `Ollama_Postgres_MCP_Setup_Guide.pdf` (4 pages)

| Section | What it covers | Gaps / issues found |
|---|---|---|
| Architectural Overview | Ollama (local LLM) + MCP + containerized Postgres, fully private | — |
| Step 1: Spin up Postgres | `docker run postgres:16-alpine`, named `local-mcp-postgres`, DB `analytics_db` | Reuses port 5432 — **will conflict** if Phase 1's container is still running. Needs an explicit note to stop/rename Phase 1's container first. |
| Step 2: Schema & Data | Two related tables: `products`, `sales_orders` (FK relationship) + seed rows | Good — this is a more realistic relational example than Phase 1's single flat table. |
| Step 3: Pull & Serve Ollama Models | Install Ollama, `ollama pull qwen2.5:7b`, `ollama list` | Doesn't mention installing Ollama itself (link/download), or that `ollama serve` needs to be running in the background, or minimum RAM/disk needed for a 7B model (~5GB download, needs ~8GB RAM free) |
| Step 4: Configure AI Client | MCP JSON block, `DATABASE_URL` → `analytics_db` | **Missing `POSTGRES_READ_ONLY=true`** — present in Phase 1's config but dropped here. Should be added back in. Also doesn't explain how Claude Desktop/Cursor is supposed to route through Ollama specifically (MCP config itself doesn't change based on which LLM backend you use — that's a separate model-provider setting in the client, not shown here) |
| Step 5: Query Examples | Natural language test prompts | No troubleshooting for tool-calling failures, which are common with smaller local models |

**Key takeaway from the analysis:** the two guides are meant to be read as *sequential*, not independent — Phase 2 builds on Phase 1's pattern but changes the database name/container name and the LLM backend. Running them back-to-back without changes will hit a port collision. The plan below accounts for that.

---

## 3. Answering Your Setup Questions

- **Is there a database already?** No. Both phases create a **new, empty Postgres container from a public Docker image**. You build the schema and data from scratch as part of the exercise — this is intentional (it's a demo/sandbox, not connecting to a real system).
- **What's assumed but not stated?** Docker Desktop installed + running, and Claude Desktop installed, before Phase 1 starts. Ollama installed + running before Phase 2 starts. All covered in Phase 0 below.
- **Order:** Phase 1 (Docker/Claude) first, fully working and documented, then Phase 2 (Ollama) — as you asked.

---

## 4. Prerequisites (Phase 0 — before any guide steps)

| Tool | Needed for | Install check |
|---|---|---|
| Docker Desktop | Both phases | `docker --version` and `docker ps` should run without error |
| Claude Desktop (or Cursor) | Both phases (as the MCP client) | App installed, signed in |
| Ollama | Phase 2 only | `ollama --version`; ~8GB free RAM, ~5GB disk for the model |
| A terminal (PowerShell/Terminal) | Both | — |
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
│   ├── architecture-phase2.png   # Diagram: Ollama -> MCP -> Postgres
│   └── screenshots/              # Connection badge, sample query results, etc.
├── sql/
│   ├── phase1_employees_schema.sql
│   └── phase2_products_sales_schema.sql
├── config/
│   ├── claude_desktop_config.phase1.example.json
│   └── claude_desktop_config.phase2.example.json
├── .env.example                  # Placeholder credentials, never the real ones
├── .gitignore                    # Ignore real .env, local docker volumes, etc.
└── scripts/
    ├── phase1_start_db.sh
    └── phase2_start_db.sh
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

## 7. Phase 2 — Ollama (fully local, build after Phase 1 is verified working)

### 7.1 Steps

1. **Stop/rename Phase 1's container** (or change the port) to avoid the 5432 collision.
2. **Install Ollama**, confirm `ollama serve` is running.
3. **Pull a tool-calling-capable model** — `qwen2.5:7b`.
4. **Start the new Postgres container** — `local-mcp-postgres`, DB `analytics_db`.
5. **Create schema + seed data** — `products` + `sales_orders` (relational, with FK).
6. **Configure the MCP client** to use Ollama as the model backend + point MCP config at `analytics_db`. Add `POSTGRES_READ_ONLY=true` here too (the original guide omits it — worth fixing and noting as an intentional improvement in your write-up).
7. **Reload the client**, select the Ollama model.
8. **Run validation prompts** — schema discovery, aggregation across the FK relationship, join-based query.
9. **Note tool-calling reliability** — smaller local models sometimes fail to invoke MCP tools correctly; document any retries/failures honestly, it's a legitimate finding.
10. **Screenshots + documentation**, same as Phase 1.

### 7.2 Deliverables from this phase
- Working Phase 2 setup
- `sql/phase2_products_sales_schema.sql`
- `config/claude_desktop_config.phase2.example.json`
- Screenshots
- README section: "Phase 2: Fully Local with Ollama"

---

## 8. Security & Best Practices Section (for the writeup)

Things worth explicitly calling out — good for both correctness and for showing security awareness in a portfolio piece:

- Never commit real credentials — use `.env` + `.env.example`.
- `POSTGRES_READ_ONLY` is an MCP-wrapper-level control, not a Postgres-level one. For a more rigorous setup, mention (even if not implemented) creating a dedicated read-only Postgres role via `GRANT SELECT` instead of relying solely on the wrapper flag.
- `--rm` on the MCP container means credentials passed via `-e` don't persist on disk in the container layer, but they are visible in shell history / process list while running — worth a line in the "lessons learned" section.
- Note the Linux-specific `host.docker.internal` caveat if applicable.

---

## 9. Documentation / Portfolio Plan

- **README.md** — the front door. Should include: one-paragraph summary, architecture diagram (both phases), quick-start commands, screenshots/GIF of a live query, "what I learned" section, security notes.
- **Architecture diagrams** — two simple box diagrams (Phase 1 and Phase 2 flow). Can generate these as clean SVGs.
- **Screenshots/demo** — at minimum: container running (`docker ps`), config file diff, connected badge in Claude Desktop, one successful natural-language query + result.
- **GitHub repo** — public, with the structure in Section 5, proper `.gitignore`, MIT or similar license if you want it fully open.

---

## 10. Next Steps (in order)

1. Confirm your OS (Windows/macOS/Linux) so I can give exact config file paths and commands.
2. I generate the actual files: SQL scripts, `.env.example`, MCP config templates, `.gitignore`, starter `README.md` — each with real content, not placeholders, based on the corrected/hardened version of the guides above.
3. You run Phase 1 commands on your machine; we debug together as needed.
4. Once Phase 1 is verified, capture screenshots, then move to Phase 2.
5. Repeat for Phase 2.
6. Finalize README + push to GitHub.

---

## 11. Open Questions for You

- OS you're building this on?
- Do you want the GitHub repo public (portfolio-facing) from the start, or private until it's polished?
- Any preference on repo name? (Placeholder used above: `postgres-mcp-local-integration`)

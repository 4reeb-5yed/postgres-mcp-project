# Demo Day Guide — Postgres + MCP Project

## PART 1 — Morning Startup (do this BEFORE the demo, not during)

The Docker container does not auto-start after a laptop reboot. Do these steps
first, in order, before anyone is watching.

### 1. Start Docker Desktop
Open Docker Desktop from the Start menu. Wait until it says "Engine running"
(green) — this takes 30–60 seconds after opening.

### 2. Start the Postgres container
```powershell
docker start local-postgres
```
If this errors saying no such container, it means it got removed somehow —
recreate it with:
```powershell
docker run -d --name local-postgres -e POSTGRES_PASSWORD=changeme -p 5433:5432 postgres:15
Get-Content sql\phase1_employees_schema.sql | docker exec -i local-postgres psql -U postgres -d postgres
```

### 3. Verify it's actually up
```powershell
docker ps
```
You want to see `local-postgres`, status `Up`, ports `0.0.0.0:5433->5432/tcp`.

### 4. Verify the data is intact
```powershell
docker exec -it local-postgres psql -U postgres -d postgres -c "SELECT * FROM employees;"
```
You should see the 4 rows (Alice, Bob, Charlie, Diana). If the table is
missing, rerun the seed command from step 2.

### 5. Fully restart Claude Desktop
Even if it's already open — quit it via the **system tray icon → Quit** (not
just closing the window), then reopen it. This forces it to reconnect to the
MCP server fresh.

### 6. Confirm the MCP connection is live
Claude Desktop → **Settings → Developer**. You want to see `postgres-mcp`
with status **running**. If it shows failed, click **View Logs** to see why
(most likely cause: Docker wasn't fully started yet — go back to step 1).

### 7. Do one silent test query before anyone arrives
In a scratch Claude Desktop chat, ask: *"What columns does the employees
table have?"* Confirm you get a real answer with a visible tool-call panel.
Delete/ignore this test chat — it's just to confirm everything's warm before
the real demo.

Once all 7 steps check out, you're ready. Total time: ~3 minutes.

---

## PART 2 — The Demo Script

Audience already knows the project at a high level (connect an AI assistant
to local Postgres via MCP) — don't re-explain the concept from scratch. Focus
on **what you built, what broke, and how you fixed it.** That's the actual
value to show.

### Opening (30 seconds)
> "I connected Claude Desktop to a local Postgres database using MCP —
> Model Context Protocol. The AI can now query live data directly, not just
> talk about it. I'll show the working setup, then walk through what
> actually broke while building it, since that's most of the real work."

### Step 1 — Show the database is real (1 min)
Terminal:
```powershell
docker ps
docker exec -it local-postgres psql -U postgres -d postgres -c "SELECT * FROM employees;"
```
Say: *"This is a real Postgres instance running in Docker, seeded with
sample employee data — not a mock or a static file."*

### Step 2 — Show the live connection (30 sec)
Claude Desktop → Settings → Developer → point at `postgres-mcp`, status
**running**. Show the Arguments panel — the exact `uvx` command.

### Step 3 — Run the validation prompts live (3 min) — the core of the demo
Type these into Claude Desktop **live**, in front of them, one at a time.
Let the tool-call panel expand each time — that's the visible proof it's a
real query, not a scripted answer.

1. `What columns does the employees table have?`
2. `What's the average salary by department in the employees table?`
3. `Write and run a query to find the highest-paid employee in the employees table.`

Optionally, if there's time, run one more ad-hoc one live to show it's not
just memorized: `What tables exist in this database?`

### Step 4 — The debugging story (2–3 min) — spend real time here
This is the part that shows engineering judgment, not just following
instructions. Walk through it as a narrative, referencing the "Gotchas"
section of your README:

- The Docker image the original guide specified doesn't actually work for
  this use case — it runs an HTTP server instead of the stdio protocol
  Claude Desktop requires. Confirmed this with a manual test before
  abandoning it.
- The officially recommended MCP package for Postgres is deprecated.
- Found a working alternative package, but it crashed on startup — traced
  it to a genuine upstream breaking change: the `mcp` Python SDK released a
  breaking `2.0.0` version days before this project, renaming a core module.
  Fixed by pinning the dependency version at invocation time.
- Even after that was fixed, got persistent password errors — despite the
  password being provably correct. Diagnosed (via `netstat` and `tasklist`)
  that a **separate, native Windows Postgres service** was silently
  intercepting connections on the same port. Fixed by moving the Docker
  container to a different port.

Say something like: *"None of this was in the guide — the guide's exact
setup didn't work, and I had to actually debug each layer independently to
find out why."*

### Step 5 — Show the repo (1 min)
Open the GitHub repo in a browser:
- `README.md` — point at the Gotchas section
- `config/claude_desktop_config.phase1.example.json` — the actual working
  config
- `docs/screenshots/` — all 6 validation screenshots
- Commit history — shows the iterative fix process, not one clean commit

### Step 6 — Close (15 sec)
> "That's Phase 1 fully working and documented. Phase 2 — routing this
> through a fully local model with Ollama instead of the cloud — is the
> planned next step."

---

## PART 3 — Files to have open/ready before you start

Have these open in tabs/windows ahead of time so you're not fumbling:

| What | Where |
|---|---|
| Terminal (PowerShell) | ready in the project folder |
| Claude Desktop | open, Settings → Developer visible |
| GitHub repo | `https://github.com/4reeb-5yed/postgres-mcp-project` |
| README.md (rendered on GitHub) | scrolled to the Gotchas section |
| `config/claude_desktop_config.phase1.example.json` | open on GitHub |
| `docs/screenshots/` folder | open on GitHub, thumbnails visible |

---

## PART 4 — Anticipated questions and honest answers

**"Why isn't it using the exact image the guide specified?"**
Because that image runs an HTTP server, not the stdio protocol Claude
Desktop's local MCP servers require — confirmed via direct testing before
switching approaches. It's a genuine compatibility issue with the guide, not
a shortcut.

**"Is the read-only restriction from the guide actually enforced?"**
Worth being upfront: `POSTGRES_READ_ONLY` in the original guide is enforced
at the MCP wrapper level, not by Postgres itself — a real production setup
would want a dedicated read-only Postgres role instead. Noted this as a
known limitation in the README.

**"How big is the database?"**
Deliberately small — one table, four rows — because this phase is about
proving the plumbing works end-to-end, not handling volume. Phase 2 (Ollama)
uses a larger relational schema with two joined tables.

**"What happens if you restart your laptop — does it just keep working?"**
No — Docker containers don't auto-start on reboot by default, and Claude
Desktop needs a full restart to reconnect. That's a one-time ~3 minute
startup sequence (documented in Part 1 above), not persistent by itself.

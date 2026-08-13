# Demo Day Guide — Claude DB Connect

## PART 1 — Morning Startup (do this BEFORE the demo, not during)

None of these containers auto-start after a laptop reboot. Do these steps
first, in order, before anyone is watching. Full per-database troubleshooting
lives in each setup guide (linked below) if any step here doesn't match what
you see.

### 1. Start Docker Desktop
Open Docker Desktop from the Start menu. Wait until it says "Engine running"
(green) — this takes 30–60 seconds after opening.

### 2. Start the database containers
```powershell
docker start local-postgres
docker start local-mysql
docker start local-mssql
```
SQLite has no container to start — it's just a local `.db` file.

If any of these errors saying no such container, it means it got removed
somehow — see that database's setup guide ([PostgreSQL](docs/setup/postgres.md),
[MySQL](docs/setup/mysql.md), [MS SQL Server](docs/setup/mssql.md)) for the
exact recreate + reseed commands.

### 3. Verify they're actually up
```powershell
docker ps
```
You want to see `local-postgres`, `local-mysql`, and `local-mssql` all listed,
status `Up`, with ports `5433`, `3306`, and `1433` respectively.

### 4. Verify the data is intact
```powershell
docker exec -it local-postgres psql -U postgres -d postgres -c "SELECT * FROM employees;"
docker exec -it local-mysql mysql -uroot -pchangeme testdb -e "SELECT * FROM employees;"
```
Postgres should show 4 rows (Alice, Bob, Charlie, Diana); MySQL should show 5
different rows (Ethan, Priya, Marcus, Sofia, Noah) — deliberately different
sample data so the two are visibly distinct when both are queried live. If a
table's missing, rerun that database's seed command from its setup guide.

### 5. Fully restart Claude Desktop
Even if it's already open — quit it via the **system tray icon → Quit** (not
just closing the window), then reopen it. This forces it to reconnect to all
MCP servers fresh.

### 6. Confirm all four MCP connections are live
Claude Desktop → **Settings → Developer**. You want to see `postgres-mcp`,
`mysql-mcp`, `sql-assistant`, and `sqlite-mcp` all with status **running**. If
any shows failed, click **View Logs** to see why (most likely cause: Docker
wasn't fully started yet — go back to step 1).

### 7. Do one silent test query per database before anyone arrives
In a scratch Claude Desktop chat, ask each connection a schema question, e.g.
*"Using the MySQL connection, what columns does the employees table have?"*
Confirm you get a real answer with a visible tool-call panel for each of the
four. Delete/ignore this test chat — it's just to confirm everything's warm
before the real demo.

Once all 7 steps check out, you're ready. Total time: ~5 minutes.

---

## PART 2 — The Demo Script

Audience already knows the project at a high level (connect Claude Desktop to
local databases via MCP) — don't re-explain the concept from scratch. Focus on
**what you built, what broke, and how you fixed it.** That's the actual value
to show.

### Opening (30 seconds)
> "I connected Claude Desktop to four different local databases — Postgres,
> MySQL, SQL Server, and SQLite — using MCP, the Model Context Protocol. The
> AI can query live data directly across any of them, not just talk about it.
> I'll show the working setup, then walk through what actually broke while
> building it, since that's most of the real work."

### Step 1 — Show the databases are real (1 min)
Terminal:
```powershell
docker ps
docker exec -it local-postgres psql -U postgres -d postgres -c "SELECT * FROM employees;"
```
Say: *"This is a real Postgres instance running in Docker, seeded with sample
employee data — not a mock or a static file. Same story for MySQL, SQL
Server, and a plain SQLite file on disk."*

### Step 2 — Show the live connections (30 sec)
Claude Desktop → Settings → Developer → point at each of the four MCP
servers, all status **running**. Show the Arguments panel on one — the exact
command Claude Desktop is launching.

### Step 3 — Run the validation prompts live (3–4 min) — the core of the demo
Type these into Claude Desktop **live**, in front of them, one at a time.
Let the tool-call panel expand each time — that's the visible proof it's a
real query, not a scripted answer. Since multiple databases are connected at
once, be explicit about which one each prompt should hit.

1. `Using the Postgres connection, what columns does the employees table have?`
2. `Using the MySQL connection, what's the average salary by department?`
3. `Using the SQL Server connection, write and run a query to find the most expensive book.`
4. `Using the SQLite connection, what tables exist in this database?`

Optionally, if there's time, run one more ad-hoc one live to show it's not
just memorized: `Compare the employees table structure between Postgres and MySQL.`

### Step 4 — The debugging story (3–4 min) — spend real time here
This is the part that shows engineering judgment, not just following
instructions. Walk through it as a narrative, referencing the Gotchas section
in each database's setup guide:

- **Postgres** ([full story](docs/setup/postgres.md#gotchas-found-the-hard-way)):
  the Docker image the original guide specified doesn't actually work for
  this use case — it runs an HTTP server instead of the stdio protocol
  Claude Desktop requires. The officially recommended MCP package is also
  deprecated. Found a working alternative, but it crashed on startup —
  traced to a genuine upstream breaking change in the `mcp` Python SDK,
  fixed by pinning the dependency version. Then hit persistent password
  errors despite a provably correct password — diagnosed via `netstat` and
  `tasklist` that a separate native Windows Postgres service was silently
  intercepting the port. Fixed by moving the container to a different port.
- **MySQL** ([full story](docs/setup/mysql.md#gotchas)): the cleanest of the
  four — worked on the first attempt, no dependency pinning needed. Worth
  contrasting directly against the Postgres story above.
- **SQL Server** ([full story](docs/setup/mssql.md#gotchas)): needed the
  ODBC driver installed separately, and hit the same `mcp` SDK
  breaking-change issue as Postgres — same root cause, different package.
- **SQLite** ([full story](docs/setup/sqlite.md#gotchas)): no server, no
  container — just don't commit the real `.db` file if it ever holds real
  data.

Say something like: *"None of this was in the original guide — the exact
setup it described didn't work, and I had to debug each layer independently
to find out why. Four databases, four different failure modes, and one of
them just worked."*

### Step 5 — Show the repo (1 min)
Open the GitHub repo in a browser:
- `README.md` — the project overview and status checklist
- One database's setup guide, e.g. `docs/setup/postgres.md` — point at the
  Gotchas section
- `config/postgres/claude_desktop_config.example.json` — the actual working
  config
- `docs/screenshots/` — all validation screenshots across the four databases
- Commit history — shows the iterative fix process, not one clean commit

### Step 6 — Close (15 sec)
> "That's the full setup working and documented — an AI assistant querying
> four different local databases through MCP, plus the real debugging story
> behind each one."

---

## PART 3 — Files to have open/ready before you start

Have these open in tabs/windows ahead of time so you're not fumbling:

| What | Where |
|---|---|
| Terminal (PowerShell) | ready in the project folder |
| Claude Desktop | open, Settings → Developer visible |
| GitHub repo | `https://github.com/4reeb-5yed/claude-db-connect` |
| README.md (rendered on GitHub) | scrolled to the Status section |
| A setup guide, e.g. `docs/setup/postgres.md` | open on GitHub, scrolled to Gotchas |
| `config/postgres/claude_desktop_config.example.json` | open on GitHub |
| `docs/screenshots/` folder | open on GitHub, thumbnails visible |

---

## PART 4 — Anticipated questions and honest answers

**"Why isn't it using the exact image the original guide specified?"**
Because that image runs an HTTP server, not the stdio protocol Claude
Desktop's local MCP servers require — confirmed via direct testing before
switching approaches. It's a genuine compatibility issue with the guide, not
a shortcut. Full details in [`docs/setup/postgres.md`](docs/setup/postgres.md).

**"Is the read-only restriction actually enforced?"**
Worth being upfront: `POSTGRES_READ_ONLY` is enforced at the MCP wrapper
level, not by Postgres itself — a real production setup would want a
dedicated read-only Postgres role instead. Noted as a known limitation in the
README's Security Notes.

**"Why did some databases need more debugging than others?"**
MySQL worked cleanly on the first attempt. Postgres and SQL Server both hit
the same upstream `mcp` Python SDK breaking-change issue, plus Postgres had
an unrelated port-conflict problem specific to this machine. SQLite, having
no server process at all, had nothing to debug.

**"How big is the sample data?"**
Deliberately small across all four — a handful of rows each — because the
focus is on proving the plumbing works end-to-end, not handling volume.

**"What happens if you restart your laptop — does it just keep working?"**
No — Docker containers don't auto-start on reboot by default, and Claude
Desktop needs a full restart to reconnect. That's a one-time ~5 minute
startup sequence (documented in Part 1 above), not persistent by itself.

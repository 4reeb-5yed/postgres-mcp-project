# SQLite MCP Setup

## Config
Set --db-path to the full path of your local SQLite database file. This can be 
any .db file you want Claude to query — no server or Docker container required, 
since SQLite is file-based.

Note: never commit your actual .db file to version control — keep it local only.

# MS SQL Server MCP Setup

## Prerequisites
- Docker container running SQL Server 2022, e.g.:
  ```
  docker run -d --name local-mssql -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=<YOUR_PASSWORD>" -p 1433:1433 mcr.microsoft.com/mssql/server:2022-latest
  ```

- ODBC Driver 17 for SQL Server installed on the host machine:
  https://learn.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server

## Install the MCP server
Install directly via pip, NOT uvx — uvx resolves the wrong `mcp` package version
(2.0.0), which breaks the `mcp.server.fastmcp` import that sql-mcp-server depends on.

```
pip install sql-mcp-server
pip install "mcp<2.0.0" --force-reinstall
```

## Known issue
If you see `ModuleNotFoundError: No module named 'mcp.server.fastmcp'`, it means
`mcp` 2.0.0 got installed instead of the 1.x line sql-mcp-server expects. Fix with
the force-reinstall command above.

## Config
Use config/mssql/claude_desktop_config.example.json as a template. Copy the
mcpServers.sql-assistant block into your actual claude_desktop_config.json
(usually at %APPDATA%\Claude\claude_desktop_config.json on Windows), and replace
<YOUR_PASSWORD> with your actual SA password.

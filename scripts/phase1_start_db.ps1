# Phase 1: starts the local Postgres container for the Docker + Claude Desktop demo.
# Run from PowerShell: .\scripts\phase1_start_db.ps1
#
# NOTE: uses port 5433, not the Postgres default 5432. On this project's dev
# machine, a native Windows Postgres service was already bound to 5432,
# silently intercepting connections meant for the Docker container. 5433
# sidesteps that. If your machine doesn't have anything on 5432, you can
# change this back — just make sure config/claude_desktop_config.phase1.example.json
# and .env.example stay in sync with whatever port you pick.

$ContainerName = "local-postgres"
$Password = "changeme"   # replace, or better: load from .env before running

docker run -d `
  --name $ContainerName `
  -e POSTGRES_PASSWORD=$Password `
  -p 5433:5432 `
  postgres:15

Write-Host "Container '$ContainerName' starting. Check status with: docker ps"
Write-Host "Then seed data with: Get-Content sql\phase1_employees_schema.sql | docker exec -i $ContainerName psql -U postgres"

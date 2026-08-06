# Phase 1: starts the local Postgres container for the Docker + Claude Desktop demo.
# Run from PowerShell: .\scripts\phase1_start_db.ps1

$ContainerName = "local-postgres"
$Password = "changeme"   # replace, or better: load from .env before running

docker run -d `
  --name $ContainerName `
  -e POSTGRES_PASSWORD=$Password `
  -p 5432:5432 `
  postgres:15

Write-Host "Container '$ContainerName' starting. Check status with: docker ps"
Write-Host "Then seed data with: Get-Content sql\phase1_employees_schema.sql | docker exec -i $ContainerName psql -U postgres"

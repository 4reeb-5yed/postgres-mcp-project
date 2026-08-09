-- Phase 1b: MySQL implementation of the same Docker + MCP guide,
-- run alongside the Postgres version for comparison.
-- Uses a different sample dataset from the Postgres version (deliberately,
-- to keep the two databases visibly distinct during side-by-side testing).

CREATE TABLE employees (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100),
  department VARCHAR(50),
  salary INT
);

INSERT INTO employees (name, department, salary) VALUES
('Ethan Walker', 'Engineering', 98000),
('Priya Sharma', 'Sales', 71000),
('Marcus Lee', 'Engineering', 112000),
('Sofia Rossi', 'Finance', 84000),
('Noah Kim', 'HR', 65000);

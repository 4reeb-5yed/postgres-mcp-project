-- Phase 1: Docker + Claude Desktop MCP demo schema
-- Run this inside psql after exec-ing into the local-postgres container.

CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    department VARCHAR(50),
    salary INT
);

INSERT INTO employees (name, department, salary) VALUES
('Alice Smith', 'Engineering', 95000),
('Bob Jones', 'Marketing', 62000),
('Charlie Brown', 'Engineering', 105000),
('Diana Prince', 'HR', 70000);

-- Quick sanity check after running the above:
-- SELECT * FROM employees;

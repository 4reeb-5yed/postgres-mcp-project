-- Phase 1c: Docker + Claude Desktop MCP demo schema (MS SQL Server)
-- Run this against the local-mssql container after connecting via sqlcmd or another SQL client.

CREATE TABLE books (
  id INT IDENTITY(1,1) PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  author VARCHAR(100) NOT NULL,
  genre VARCHAR(50),
  price DECIMAL(6,2)
);

INSERT INTO books (title, author, genre, price) VALUES
  ('The Silent Orbit', 'Maya Ferreira', 'Sci-Fi', 14.99),
  ('Whispers of Kanto', 'Haruki Endo', 'Mystery', 12.50),
  ('Beneath the Ash', 'Daniel Okoro', 'Thriller', 16.25),
  ('Letters to Aria', 'Sophie Laurent', 'Romance', 11.99),
  ('The Last Cartographer', 'Marcus Webb', 'Adventure', 18.00);

-- Quick sanity check after running the above:
-- SELECT * FROM books;

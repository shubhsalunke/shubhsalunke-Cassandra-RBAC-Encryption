-- ==========================================================
-- Cassandra Keyspace & Schema Definitions
-- ==========================================================

-- Create keyspace for the application
CREATE KEYSPACE IF NOT EXISTS task9_demo
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

USE task9_demo;

-- Create employees table
CREATE TABLE IF NOT EXISTS employees (
  id int PRIMARY KEY,
  name text,
  department text,
  salary int
);

-- Insert initial bootstrap data using LWT for idempotency
INSERT INTO employees (id, name, department, salary)
VALUES (1, 'Shubh', 'DevOps', 50000) 
IF NOT EXISTS;

-- ==========================================================
-- Role-Based Access Control (RBAC) Setup
-- ==========================================================

-- Create Read-Only User Role
CREATE ROLE IF NOT EXISTS readonly_user 
WITH PASSWORD='Read@123' 
AND LOGIN=true;

-- Create Writer/Read-Write User Role
CREATE ROLE IF NOT EXISTS writer_user 
WITH PASSWORD='Write@123' 
AND LOGIN=true;

-- Grant Read-Only access (SELECT) on keyspace
GRANT SELECT ON KEYSPACE task9_demo TO readonly_user;

-- Grant Read-Write access (SELECT and MODIFY) on keyspace
GRANT SELECT ON KEYSPACE task9_demo TO writer_user;
GRANT MODIFY ON KEYSPACE task9_demo TO writer_user;

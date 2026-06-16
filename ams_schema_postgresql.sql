-- ============================================================
-- Asset Management System (AMS) - Database Schema
-- Target: PostgreSQL 12+
-- Converted from MySQL for Render deployment
-- ============================================================

-- Create database (uncomment if running this script directly)
-- CREATE DATABASE ams_db ENCODING 'UTF8';
-- \c ams_db;

-- Enable UUID extension (optional, for future use)
-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- Reference data
-- ============================================================

CREATE TABLE asset_categories (
    category_id     SERIAL PRIMARY KEY,
    category_name   VARCHAR(60)  NOT NULL UNIQUE,
    depreciation_rate DECIMAL(5,2) NOT NULL DEFAULT 10.00
);

CREATE TABLE vendors (
    vendor_id       SERIAL PRIMARY KEY,
    vendor_name     VARCHAR(120) NOT NULL,
    contact_person  VARCHAR(80),
    phone           VARCHAR(20),
    email           VARCHAR(100),
    address         VARCHAR(200),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- People
-- ============================================================

CREATE TABLE employees (
    employee_id     SERIAL PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    department      VARCHAR(60),
    designation     VARCHAR(60),
    phone           VARCHAR(20),
    email           VARCHAR(100),
    status          VARCHAR(20) NOT NULL DEFAULT 'Active' CHECK(status IN ('Active', 'Inactive')),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- System login accounts (role-based access)
CREATE TABLE users (
    user_id         SERIAL PRIMARY KEY,
    username        VARCHAR(50)  NOT NULL UNIQUE,
    password        VARCHAR(255) NOT NULL,
    full_name       VARCHAR(100) NOT NULL,
    role            VARCHAR(20) NOT NULL DEFAULT 'User' CHECK(role IN ('Admin', 'User')),
    employee_id     INT NULL,
    status          VARCHAR(20) NOT NULL DEFAULT 'Active' CHECK(status IN ('Active', 'Inactive')),
    last_login      TIMESTAMP NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_users_employee FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
        ON DELETE SET NULL
);

-- ============================================================
-- Assets
-- ============================================================

CREATE TABLE assets (
    asset_id        VARCHAR(20) PRIMARY KEY,
    asset_name      VARCHAR(120) NOT NULL,
    category_id     INT NOT NULL,
    serial_no       VARCHAR(100) UNIQUE,
    purchase_date   DATE,
    purchase_cost   DECIMAL(12,2) DEFAULT 0,
    vendor_id       INT NULL,
    warranty_expiry DATE NULL,
    location        VARCHAR(100),
    status          VARCHAR(30) NOT NULL DEFAULT 'Available' 
        CHECK(status IN ('Available', 'In Use', 'Under Repair', 'Disposed')),
    assigned_to     INT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_assets_category FOREIGN KEY (category_id) REFERENCES asset_categories(category_id),
    CONSTRAINT fk_assets_vendor   FOREIGN KEY (vendor_id)   REFERENCES vendors(vendor_id) ON DELETE SET NULL,
    CONSTRAINT fk_assets_employee FOREIGN KEY (assigned_to) REFERENCES employees(employee_id) ON DELETE SET NULL
);

-- Auto-update timestamp trigger for assets table
CREATE OR REPLACE FUNCTION update_assets_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_assets_update_timestamp
BEFORE UPDATE ON assets
FOR EACH ROW
EXECUTE FUNCTION update_assets_timestamp();

-- Issue / return history (employee-wise allocation tracking)
CREATE TABLE asset_allocations (
    allocation_id   SERIAL PRIMARY KEY,
    asset_id        VARCHAR(20) NOT NULL,
    employee_id     INT NOT NULL,
    issue_date      DATE NOT NULL,
    return_date     DATE NULL,
    issued_by       VARCHAR(100),
    remarks         VARCHAR(255),
    CONSTRAINT fk_alloc_asset    FOREIGN KEY (asset_id) REFERENCES assets(asset_id) ON DELETE CASCADE,
    CONSTRAINT fk_alloc_employee FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- Maintenance / service history
CREATE TABLE maintenance (
    maintenance_id  SERIAL PRIMARY KEY,
    asset_id        VARCHAR(20) NOT NULL,
    issue_reported  VARCHAR(255) NOT NULL,
    service_date    DATE NOT NULL,
    completed_date  DATE NULL,
    vendor_id       INT NULL,
    cost            DECIMAL(10,2) DEFAULT 0,
    status          VARCHAR(20) NOT NULL DEFAULT 'Open' 
        CHECK(status IN ('Open', 'In Progress', 'Completed')),
    remarks         VARCHAR(255),
    CONSTRAINT fk_maint_asset  FOREIGN KEY (asset_id) REFERENCES assets(asset_id) ON DELETE CASCADE,
    CONSTRAINT fk_maint_vendor FOREIGN KEY (vendor_id) REFERENCES vendors(vendor_id) ON DELETE SET NULL
);

-- Disposal history
CREATE TABLE asset_disposals (
    disposal_id     SERIAL PRIMARY KEY,
    asset_id        VARCHAR(20) NOT NULL,
    disposal_date   DATE NOT NULL,
    reason          VARCHAR(255),
    approved_by     VARCHAR(100),
    disposal_value  DECIMAL(10,2) DEFAULT 0,
    CONSTRAINT fk_disposal_asset FOREIGN KEY (asset_id) REFERENCES assets(asset_id) ON DELETE CASCADE
);

-- Audit trail (who did what, when)
CREATE TABLE audit_log (
    log_id          BIGSERIAL PRIMARY KEY,
    username        VARCHAR(50),
    action          VARCHAR(50)  NOT NULL,
    entity          VARCHAR(50)  NOT NULL,
    entity_id       VARCHAR(50),
    details         VARCHAR(500),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- Indexes for performance
-- ============================================================
CREATE INDEX idx_assets_status   ON assets(status);
CREATE INDEX idx_assets_category ON assets(category_id);
CREATE INDEX idx_alloc_asset     ON asset_allocations(asset_id);
CREATE INDEX idx_maint_asset     ON maintenance(asset_id);
CREATE INDEX idx_audit_created   ON audit_log(created_at);

-- ============================================================
-- Seed data
-- ============================================================

-- Add default asset categories
INSERT INTO asset_categories (category_name, depreciation_rate) VALUES
    ('Computers', 20.00),
    ('Laptops', 25.00),
    ('Printers', 15.00),
    ('Servers', 10.00),
    ('Networking', 15.00),
    ('Furniture', 10.00),
    ('AC Units', 8.00),
    ('Software Licenses', 33.33),
    ('Projectors', 12.00),
    ('Vehicles', 15.00);

-- Add default admin user (password: admin123 - change in production!)
INSERT INTO users (username, password, full_name, role, status) VALUES
    ('admin', '$2a$10$7JzBDd0jQJYKHrQJ5M0Z.OsQKyZkJ6EWzV9vZ8G.PQ4r7O8nxN0vS', 'Administrator', 'Admin', 'Active');

-- ============================================================
-- Notes for Developers
-- ============================================================
/*
1. ENUM columns in PostgreSQL:
   - Used VARCHAR(20/30) with CHECK constraints for compatibility
   - Can be changed to native ENUM type if preferred

2. AUTO_INCREMENT in PostgreSQL:
   - Replaced with SERIAL (which creates a sequence)
   - Or use GENERATED ALWAYS AS IDENTITY (PostgreSQL 10+)

3. Timestamp updates:
   - MySQL's ON UPDATE CURRENT_TIMESTAMP is not directly supported
   - Implemented using TRIGGER + function instead

4. Database connection:
   - PostgreSQL: jdbc:postgresql://host:5432/ams_db
   - Driver: org.postgresql.Driver

5. Password hashing:
   - Default admin password shown for demo purposes
   - In production: use bcrypt or similar hashing method
   - Example bcrypt hash above: admin123

6. Character encoding:
   - PostgreSQL defaults to UTF-8
   - No need to specify encoding explicitly
*/

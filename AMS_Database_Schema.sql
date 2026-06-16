
CREATE DATABASE IF NOT EXISTS ams_db;
USE ams_db;

CREATE TABLE Vendors (
    vendor_id INT AUTO_INCREMENT PRIMARY KEY,
    vendor_name VARCHAR(150) NOT NULL,
    contact_person VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    address TEXT,
    service_type VARCHAR(100)
);

CREATE TABLE Employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_code VARCHAR(20) UNIQUE,
    name VARCHAR(100) NOT NULL,
    department VARCHAR(100),
    designation VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    role VARCHAR(50),
    status ENUM('Active','Inactive') DEFAULT 'Active'
);

CREATE TABLE Assets (
    asset_id INT AUTO_INCREMENT PRIMARY KEY,
    asset_code VARCHAR(20) UNIQUE NOT NULL,
    asset_name VARCHAR(150) NOT NULL,
    category VARCHAR(100),
    serial_number VARCHAR(100),
    department VARCHAR(100),
    assigned_to INT NULL,
    purchase_date DATE,
    warranty_expiry DATE,
    purchase_value DECIMAL(12,2),
    status ENUM('Available','In Use','Repair','Disposed') DEFAULT 'Available',
    vendor_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (assigned_to) REFERENCES Employees(employee_id),
    FOREIGN KEY (vendor_id) REFERENCES Vendors(vendor_id)
);

CREATE TABLE Asset_Allocation (
    allocation_id INT AUTO_INCREMENT PRIMARY KEY,
    asset_id INT NOT NULL,
    employee_id INT NOT NULL,
    allocated_date DATE NOT NULL,
    returned_date DATE,
    remarks TEXT,
    status VARCHAR(50),
    FOREIGN KEY (asset_id) REFERENCES Assets(asset_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

CREATE TABLE Maintenance (
    maintenance_id INT AUTO_INCREMENT PRIMARY KEY,
    asset_id INT NOT NULL,
    vendor_id INT,
    issue_description TEXT,
    service_date DATE,
    cost DECIMAL(10,2),
    status VARCHAR(50),
    FOREIGN KEY (asset_id) REFERENCES Assets(asset_id),
    FOREIGN KEY (vendor_id) REFERENCES Vendors(vendor_id)
);

CREATE TABLE Depreciation (
    depreciation_id INT AUTO_INCREMENT PRIMARY KEY,
    asset_id INT NOT NULL,
    purchase_value DECIMAL(12,2),
    depreciated_value DECIMAL(12,2),
    depreciation_rate DECIMAL(5,2),
    calculation_date DATE,
    FOREIGN KEY (asset_id) REFERENCES Assets(asset_id)
);

CREATE TABLE Notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255),
    message TEXT,
    priority VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20)
);

CREATE TABLE Audit_Log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    action VARCHAR(255),
    module_name VARCHAR(100),
    action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    remarks TEXT
);

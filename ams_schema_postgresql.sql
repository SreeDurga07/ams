CREATE TABLE IF NOT EXISTS asset_categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(60) NOT NULL UNIQUE,
    depreciation_rate NUMERIC(5,2) NOT NULL DEFAULT 10.00
);

CREATE TABLE IF NOT EXISTS vendors (
    vendor_id SERIAL PRIMARY KEY,
    vendor_name VARCHAR(120) NOT NULL,
    contact_person VARCHAR(80),
    phone VARCHAR(20),
    email VARCHAR(100),
    address VARCHAR(200),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS employees (
    employee_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    department VARCHAR(60),
    designation VARCHAR(60),
    phone VARCHAR(20),
    email VARCHAR(100),
    status VARCHAR(20) NOT NULL DEFAULT 'Active' CHECK (status IN ('Active','Inactive')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'User' CHECK (role IN ('Admin','User')),
    employee_id INT NULL REFERENCES employees(employee_id) ON DELETE SET NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Active' CHECK (status IN ('Active','Inactive')),
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS assets (
    asset_id VARCHAR(20) PRIMARY KEY,
    asset_name VARCHAR(120) NOT NULL,
    category_id INT NOT NULL REFERENCES asset_categories(category_id),
    serial_no VARCHAR(100) UNIQUE,
    purchase_date DATE,
    purchase_cost NUMERIC(12,2) DEFAULT 0,
    vendor_id INT NULL REFERENCES vendors(vendor_id) ON DELETE SET NULL,
    warranty_expiry DATE NULL,
    location VARCHAR(100),
    status VARCHAR(20) NOT NULL DEFAULT 'Available' CHECK (status IN ('Available','In Use','Under Repair','Disposed')),
    assigned_to INT NULL REFERENCES employees(employee_id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS asset_allocations (
    allocation_id SERIAL PRIMARY KEY,
    asset_id VARCHAR(20) NOT NULL REFERENCES assets(asset_id) ON DELETE CASCADE,
    employee_id INT NOT NULL REFERENCES employees(employee_id),
    issue_date DATE NOT NULL,
    return_date DATE NULL,
    issued_by VARCHAR(100),
    remarks VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS maintenance (
    maintenance_id SERIAL PRIMARY KEY,
    asset_id VARCHAR(20) NOT NULL REFERENCES assets(asset_id) ON DELETE CASCADE,
    issue_reported VARCHAR(255) NOT NULL,
    service_date DATE NOT NULL,
    completed_date DATE NULL,
    vendor_id INT NULL REFERENCES vendors(vendor_id) ON DELETE SET NULL,
    cost NUMERIC(10,2) DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'Open' CHECK (status IN ('Open','In Progress','Completed')),
    remarks VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS asset_disposals (
    disposal_id SERIAL PRIMARY KEY,
    asset_id VARCHAR(20) NOT NULL REFERENCES assets(asset_id) ON DELETE CASCADE,
    disposal_date DATE NOT NULL,
    reason VARCHAR(255),
    approved_by VARCHAR(100),
    disposal_value NUMERIC(10,2) DEFAULT 0
);

CREATE TABLE IF NOT EXISTS audit_log (
    log_id BIGSERIAL PRIMARY KEY,
    username VARCHAR(50),
    action VARCHAR(50) NOT NULL,
    entity VARCHAR(50) NOT NULL,
    entity_id VARCHAR(50),
    details VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_assets_status ON assets(status);
CREATE INDEX IF NOT EXISTS idx_assets_category ON assets(category_id);
CREATE INDEX IF NOT EXISTS idx_alloc_asset ON asset_allocations(asset_id);
CREATE INDEX IF NOT EXISTS idx_maint_asset ON maintenance(asset_id);

INSERT INTO asset_categories (category_name, depreciation_rate) VALUES
 ('Computers', 20.00),
 ('Laptops', 25.00),
 ('Printers', 15.00),
 ('Servers', 12.50),
 ('Routers/Switches', 15.00),
 ('Furniture', 5.00),
 ('Air Conditioners', 10.00),
 ('Software Licenses', 33.33),
 ('Projectors', 15.00),
 ('Vehicles', 10.00)
ON CONFLICT (category_name) DO NOTHING;

INSERT INTO vendors (vendor_id, vendor_name, contact_person, phone, email, address) VALUES
 (1, 'Dell Technologies India', 'Rohit Sharma', '9810000001', 'sales@dell-partner.com', 'Plot 14, Okhla Industrial Area, New Delhi'),
 (2, 'HP Authorized Reseller', 'Priya Nair', '9810000002', 'support@hp-reseller.com', 'MG Road, Bengaluru'),
 (3, 'Cisco Networking Solutions', 'Arjun Mehta', '9810000003', 'arjun@cisconet.in', 'Cyber Towers, Hyderabad'),
 (4, 'Godrej Interio', 'Sunita Rao', '9810000004', 'orders@godrejinterio.com', 'Vikhroli, Mumbai'),
 (5, 'Voltas Service Center', 'Imran Khan', '9810000005', 'service@voltas.com', 'Sector 18, Gurugram')
ON CONFLICT (vendor_id) DO NOTHING;

INSERT INTO employees (employee_id, name, department, designation, phone, email) VALUES
 (1, 'Aarav Mehta', 'IT', 'System Administrator', '9876543210', 'aarav.mehta@company.com'),
 (2, 'Diya Kapoor', 'HR', 'HR Executive', '9876543211', 'diya.kapoor@company.com'),
 (3, 'Rohan Iyer', 'Finance', 'Accountant', '9876543212', 'rohan.iyer@company.com'),
 (4, 'Sneha Reddy', 'Marketing', 'Marketing Manager', '9876543213', 'sneha.reddy@company.com'),
 (5, 'Karan Verma', 'Operations', 'Operations Lead', '9876543214', 'karan.verma@company.com'),
 (6, 'Megha Joshi', 'IT', 'Network Engineer', '9876543215', 'megha.joshi@company.com')
ON CONFLICT (employee_id) DO NOTHING;

INSERT INTO users (user_id, username, password, full_name, role, employee_id, status) VALUES
 (1, 'admin', 'admin123', 'System Administrator', 'Admin', 1, 'Active'),
 (2, 'kverma', 'user123', 'Karan Verma', 'User', 5, 'Active')
ON CONFLICT (user_id) DO NOTHING;

INSERT INTO assets
 (asset_id, asset_name, category_id, serial_no, purchase_date, purchase_cost, vendor_id, warranty_expiry, location, status, assigned_to)
VALUES
 ('AST-1001', 'Dell Latitude 5440 Laptop', 2, 'DL5440-88231', '2024-02-15', 68500.00, 1, '2027-02-14', 'IT Department', 'In Use', 1),
 ('AST-1002', 'Dell Latitude 5440 Laptop', 2, 'DL5440-88232', '2024-02-15', 68500.00, 1, '2027-02-14', 'Marketing', 'In Use', 4),
 ('AST-1003', 'HP LaserJet Pro M404', 3, 'HP404-55102', '2023-08-10', 21500.00, 2, '2025-08-09', 'Finance Department', 'Under Repair', 3),
 ('AST-1004', 'Cisco Catalyst 2960 Switch', 5, 'CSC2960-9981', '2022-11-01', 45500.00, 3, '2025-10-31', 'Server Room', 'In Use', 1),
 ('AST-1005', 'Dell PowerEdge R740 Server', 4, 'PE740-30221', '2022-05-20', 410000.00, 1, '2027-05-19', 'Server Room', 'In Use', 1),
 ('AST-1006', 'Office Desk - Oak', 6, 'GDJ-DESK-1190', '2021-01-12', 12500.00, 4, NULL, 'Operations', 'In Use', 5),
 ('AST-1007', 'Voltas 1.5T Split AC', 7, 'VOL15T-7741', '2023-04-02', 38000.00, 5, '2025-04-01', 'HR Office', 'Available', NULL),
 ('AST-1008', 'MS Office 365 License', 8, 'MSO365-AX991', '2024-01-01', 9600.00, NULL, '2025-01-01', 'Software Pool', 'In Use', 2),
 ('AST-1009', 'Epson Projector EB-2055', 9, 'EPS2055-6620', '2023-09-18', 54000.00, 2, '2025-09-17', 'Conference Room A', 'Available', NULL),
 ('AST-1010', 'Lenovo ThinkPad E14', 2, 'LNV14-30041', '2021-06-30', 62000.00, 1, '2023-06-29', 'Store Room', 'Disposed', NULL)
ON CONFLICT (asset_id) DO NOTHING;

INSERT INTO asset_allocations (allocation_id, asset_id, employee_id, issue_date, return_date, issued_by, remarks) VALUES
 (1, 'AST-1001', 1, '2024-02-20', NULL, 'admin', 'Initial issue to IT admin'),
 (2, 'AST-1002', 4, '2024-02-22', NULL, 'admin', 'Issued to marketing team'),
 (3, 'AST-1004', 1, '2022-11-05', NULL, 'admin', 'Network switch for server room'),
 (4, 'AST-1005', 1, '2022-05-25', NULL, 'admin', 'Primary application server'),
 (5, 'AST-1006', 5, '2021-01-15', NULL, 'admin', 'Workstation desk'),
 (6, 'AST-1008', 2, '2024-01-05', NULL, 'admin', 'HR laptop license activation'),
 (7, 'AST-1010', 3, '2021-07-01', '2023-06-30', 'admin', 'Returned before disposal')
ON CONFLICT (allocation_id) DO NOTHING;

INSERT INTO maintenance (maintenance_id, asset_id, issue_reported, service_date, completed_date, vendor_id, cost, status, remarks) VALUES
 (1, 'AST-1003', 'Paper jam and faded print quality', '2025-06-10', NULL, 2, 1500.00, 'In Progress', 'Awaiting toner replacement from vendor'),
 (2, 'AST-1005', 'Routine quarterly server maintenance', '2025-03-01', '2025-03-02', 1, 3000.00, 'Completed', 'RAM and disk health check completed'),
 (3, 'AST-1007', 'AC gas refill', '2024-04-15', '2024-04-16', 5, 2200.00, 'Completed', 'Refilled refrigerant gas')
ON CONFLICT (maintenance_id) DO NOTHING;

INSERT INTO asset_disposals (disposal_id, asset_id, disposal_date, reason, approved_by, disposal_value) VALUES
 (1, 'AST-1010', '2023-07-15', 'End of life - hardware failure beyond repair', 'admin', 2500.00)
ON CONFLICT (disposal_id) DO NOTHING;

INSERT INTO audit_log (log_id, username, action, entity, entity_id, details) VALUES
 (1, 'admin', 'CREATE', 'ASSET', 'AST-1001', 'Registered new asset Dell Latitude 5440 Laptop'),
 (2, 'admin', 'ISSUE', 'ASSET', 'AST-1001', 'Issued to Aarav Mehta (IT)'),
 (3, 'admin', 'DISPOSE', 'ASSET', 'AST-1010', 'Asset disposed - hardware failure')
ON CONFLICT (log_id) DO NOTHING;

SELECT setval(pg_get_serial_sequence('vendors', 'vendor_id'), COALESCE((SELECT MAX(vendor_id) FROM vendors), 1), true);
SELECT setval(pg_get_serial_sequence('employees', 'employee_id'), COALESCE((SELECT MAX(employee_id) FROM employees), 1), true);
SELECT setval(pg_get_serial_sequence('users', 'user_id'), COALESCE((SELECT MAX(user_id) FROM users), 1), true);
SELECT setval(pg_get_serial_sequence('asset_allocations', 'allocation_id'), COALESCE((SELECT MAX(allocation_id) FROM asset_allocations), 1), true);
SELECT setval(pg_get_serial_sequence('maintenance', 'maintenance_id'), COALESCE((SELECT MAX(maintenance_id) FROM maintenance), 1), true);
SELECT setval(pg_get_serial_sequence('asset_disposals', 'disposal_id'), COALESCE((SELECT MAX(disposal_id) FROM asset_disposals), 1), true);
SELECT setval(pg_get_serial_sequence('audit_log', 'log_id'), COALESCE((SELECT MAX(log_id) FROM audit_log), 1), true);

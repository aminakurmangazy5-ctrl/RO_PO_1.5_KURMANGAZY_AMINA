--============PART 3: CREATE TABLES============
CREATE TABLE IF NOT EXISTS dentists (
    dentist_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    specialty VARCHAR(100),
    license_number VARCHAR(50) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE,
    email VARCHAR(150) UNIQUE
);

CREATE TABLE IF NOT EXISTS procedures (
    procedure_id SERIAL PRIMARY KEY,
    procedure_code VARCHAR(20) UNIQUE NOT NULL,
    procedure_name VARCHAR(150) NOT NULL,
    description TEXT,
    base_price DECIMAL(10,2) NOT NULL CHECK (base_price >= 0),
    category VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS patients (
    patient_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender CHAR(1) CHECK (gender IN ('M','F','O')),
    phone VARCHAR(20) UNIQUE,
    email VARCHAR(150) UNIQUE,
    address VARCHAR(255),
    city VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS appointments (
    appointment_id SERIAL PRIMARY KEY,
    patient_id INT NOT NULL REFERENCES patients(patient_id) ON DELETE CASCADE,
    dentist_id INT NOT NULL REFERENCES dentists(dentist_id) ON DELETE RESTRICT,
    appointment_date TIMESTAMP NOT NULL CHECK (appointment_date > '2026-01-01'),
    duration_minutes SMALLINT DEFAULT 30 CHECK (duration_minutes > 0),
    status VARCHAR(20) DEFAULT 'Scheduled' CHECK (status IN ('Scheduled','Completed','Cancelled','NoShow')),
    notes TEXT
);

CREATE TABLE IF NOT EXISTS appointment_procedures (
    appointment_id INT NOT NULL,
    procedure_id INT NOT NULL,
    price_at_time DECIMAL(10,2) NOT NULL CHECK (price_at_time >= 0),
    discount_amount DECIMAL(10,2) DEFAULT 0.00 CHECK (discount_amount >= 0),
    notes TEXT,
    PRIMARY KEY (appointment_id, procedure_id),
    FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id) ON DELETE CASCADE,
    FOREIGN KEY (procedure_id) REFERENCES procedures(procedure_id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS insurance_plans (
    insurance_plan_id SERIAL PRIMARY KEY,
    provider_name VARCHAR(100) NOT NULL,
    plan_name VARCHAR(100) NOT NULL,
    coverage_percent DECIMAL(5,2) DEFAULT 80.00,
    max_annual_limit DECIMAL(10,2) CHECK (max_annual_limit >= 0)
);

CREATE TABLE IF NOT EXISTS patient_insurance (
    patient_insurance_id SERIAL PRIMARY KEY,
    patient_id INT NOT NULL REFERENCES patients(patient_id) ON DELETE CASCADE,
    plan_id INT NOT NULL REFERENCES insurance_plans(insurance_plan_id) ON DELETE RESTRICT,
    policy_number VARCHAR(50) UNIQUE NOT NULL,
    start_date DATE NOT NULL CHECK (start_date > '2026-01-01'),
    end_date DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS medical_history (
    history_id SERIAL PRIMARY KEY,
    patient_id INT NOT NULL REFERENCES patients(patient_id) ON DELETE CASCADE,
    condition_name VARCHAR(150) NOT NULL,
    diagnosis_date DATE CHECK (diagnosis_date <= CURRENT_DATE),
    notes TEXT
);

CREATE TABLE IF NOT EXISTS allergies (
    allergy_id SERIAL PRIMARY KEY,
    patient_id INT NOT NULL REFERENCES patients(patient_id) ON DELETE CASCADE,
    allergen VARCHAR(50) NOT NULL,
    severity VARCHAR(30) CHECK (severity IN ('Mild','Moderate','Severe')),
    reaction TEXT
);

CREATE TABLE IF NOT EXISTS invoices (
    invoice_id SERIAL PRIMARY KEY,
    patient_id INT NOT NULL REFERENCES patients(patient_id) ON DELETE CASCADE,
    appointment_id INT REFERENCES appointments(appointment_id) ON DELETE SET NULL,
    invoice_date DATE NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0),
    insurance_covered DECIMAL(10,2) DEFAULT 0.00 CHECK (insurance_covered >= 0),
    patient_due DECIMAL(10,2) GENERATED ALWAYS AS (total_amount - insurance_covered) STORED,
    status VARCHAR(20) DEFAULT 'Pending' CHECK (status IN ('Pending','PartiallyPaid','Paid','Cancelled'))
);

CREATE TABLE IF NOT EXISTS payments (
    payment_id SERIAL PRIMARY KEY,
    invoice_id INT NOT NULL REFERENCES invoices(invoice_id) ON DELETE CASCADE,
    payment_date DATE NOT NULL,
    amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
    payment_method VARCHAR(30) CHECK (payment_method IN ('Cash','CreditCard','Insurance','BankTransfer')),
    transactionref VARCHAR(100)
);

TRUNCATE TABLE payments, invoices, appointment_procedures, appointments, 
              patient_insurance, medical_history, allergies, patients, 
              dentists, procedures, insurance_plans 
RESTART IDENTITY CASCADE;


--============PART 4: ALTER TABLE============

-- Add cancelled_reason column if it doesn't exist
ALTER TABLE appointments ADD COLUMN IF NOT EXISTS cancelled_reason TEXT;

-- Increase phone length to support international numbers
ALTER TABLE patients ALTER COLUMN phone TYPE VARCHAR(30);

-- Set default 'Scheduled' status for new appointments
ALTER TABLE appointments ALTER COLUMN status SET DEFAULT 'Scheduled';

-- Rename base_price to standard_price (if exists)
ALTER TABLE procedures RENAME COLUMN IF EXISTS base_price TO standard_price;

-- Add unique constraint if it doesn't exist
ALTER TABLE medical_history ADD CONSTRAINT IF NOT EXISTS uq_patient_condition 
UNIQUE (patient_id, condition_name);

--============PART 5: INSERT DATA============

TRUNCATE TABLE payments, invoices, appointment_procedures, appointments, patient_insurance,
              medical_history, allergies, patients, dentists, procedures, insurance_plans
              RESTART IDENTITY CASCADE;


INSERT INTO dentists (first_name, last_name, specialty, license_number, phone, email) VALUES
('Nikolay', 'Katykalov', 'Orthodontist', 'KZ-ORTH-001', '+77011234567', 'nikolay.katykalov@dental.kz'),
('Zhansaya', 'Orazakhai', 'Implantologist', 'KZ-IMPL-002', '+77019876543', 'zhansaya.atlas@dental.kz'),
('Rasul', 'Kaliyeva', 'Therapist', 'KZ-THER-003', '+77012345678', 'rasul.orazakhai@dental.kz'),
('Ilya', 'Kopytov', 'Surgeon', 'KZ-SURG-004', '+77015556677', 'ilya.kopytov@dental.kz'),
('Albina', 'Marat', 'Pediatric Dentist', 'KZ-PED-005', '+77017778899', 'albina.marat@dental.kz'),
('David', 'Basiev', 'Periodontist', 'KZ-PER-006', '+77019997766', 'david.basiev@dental.kz');


INSERT INTO procedures (procedure_code, procedure_name, description, standard_price, category) VALUES
('D1110', 'Prophylactic Cleaning', 'Professional teeth cleaning', 8500.00, 'Cleaning'),
('D2391', 'Composite Filling', 'Tooth restoration', 18500.00, 'Restoration'),
('D0120', 'Dental X-Ray', 'Diagnostic X-ray', 6500.00, 'Diagnostics'),
('D1110W', 'Teeth Whitening', 'Cosmetic whitening', 25000.00, 'Cosmetic'),
('D0140', 'Limited Oral Evaluation', 'Initial examination', 12000.00, 'Diagnostics'),
('D6750', 'Crown - Porcelain', 'Porcelain crown', 45000.00, 'Prosthetics'),
('D3310', 'Root Canal Treatment', 'Endodontic therapy', 32000.00, 'Endodontics');


INSERT INTO patients (first_name, last_name, date_of_birth, gender, phone, email, address, city) VALUES
('Elnazar', 'Amanzhan', '1995-03-15', 'F', '+77015551234', 'elnazar@gmail.com', 'Azattyk Avenue 45', 'Atyrau'),
('Amina', 'Kurmanqyzy', '1988-11-20', 'M', '+77017778899', 'amina.kurman@gmail.com', 'Satpaev Street 67', 'Atyrau'),
('Adelia', 'Umbetaliyeva', '2000-05-10', 'F', '+77019998877', 'adelia.umbet@gmail.com', 'Abai Street 112', 'Atyrau'),
('Alikhan', 'Salimov', '1992-07-22', 'M', '+77014445566', 'alikhan.salimov@gmail.com', 'Kulmanov Street 34', 'Atyrau'),
('Aziza', 'Erbolatkyzy', '1998-12-05', 'F', '+77018887766', 'aziza.erbolat@gmail.com', 'Pushkin Street 78', 'Atyrau'),
('Ansar', 'Abayev', '1990-04-18', 'M', '+77017776655', 'ansar.olkhagul@gmail.com', 'Auezov Street 56', 'Atyrau'),
('Karina', 'Sharonova', '2002-09-12', 'F', '+77012223344', 'karina.sharonova@gmail.com', 'Satybaldy Street 23', 'Atyrau'),
('Baitemir', 'Mishelov', '1997-06-25', 'M', '+77019997766', 'baitemir.mishelov@gmail.com', 'Baimukhanov Street 89', 'Atyrau');


INSERT INTO appointments (patient_id, dentist_id, appointment_date, status, notes) VALUES
((SELECT patient_id FROM patients WHERE email = 'elnazar@gmail.com'), 
 (SELECT dentist_id FROM dentists WHERE license_number = 'KZ-ORTH-001'), 
 '2026-06-15 10:00:00', 'Scheduled', 'Routine cleaning'),
((SELECT patient_id FROM patients WHERE email = 'amina.kurman@gmail.com'), 
 (SELECT dentist_id FROM dentists WHERE license_number = 'KZ-IMPL-002'), 
 '2026-06-16 14:30:00', 'Scheduled', 'Implant consultation'),
((SELECT patient_id FROM patients WHERE email = 'adelia.umbet@gmail.com'), 
 (SELECT dentist_id FROM dentists WHERE license_number = 'KZ-THER-003'), 
 '2026-06-17 09:00:00', 'Scheduled', 'Toothache'),
((SELECT patient_id FROM patients WHERE email = 'alikhan.salimov@gmail.com'), 
 (SELECT dentist_id FROM dentists WHERE license_number = 'KZ-SURG-004'), 
 '2026-06-18 11:00:00', 'Scheduled', 'Wisdom tooth removal'),
((SELECT patient_id FROM patients WHERE email = 'aziza.erbolat@gmail.com'), 
 (SELECT dentist_id FROM dentists WHERE license_number = 'KZ-ORTH-001'), 
 '2026-06-19 15:30:00', 'Scheduled', 'Braces adjustment');


INSERT INTO appointment_procedures (appointment_id, procedure_id, price_at_time, discount_amount, notes) VALUES
((SELECT appointment_id FROM appointments ORDER BY appointment_id LIMIT 1 OFFSET 0), 
 (SELECT procedure_id FROM procedures LIMIT 1 OFFSET 0), 8500.00, 0.00, 'Standard cleaning'),
((SELECT appointment_id FROM appointments ORDER BY appointment_id LIMIT 1 OFFSET 0), 
 (SELECT procedure_id FROM procedures LIMIT 1 OFFSET 1), 18500.00, 1000.00, 'Filling on tooth 24'),
((SELECT appointment_id FROM appointments ORDER BY appointment_id LIMIT 1 OFFSET 1), 
 (SELECT procedure_id FROM procedures LIMIT 1 OFFSET 2), 6500.00, 0.00, 'X-ray'),
((SELECT appointment_id FROM appointments ORDER BY appointment_id LIMIT 1 OFFSET 2), 
 (SELECT procedure_id FROM procedures LIMIT 1 OFFSET 0), 8500.00, 500.00, 'Deep cleaning'),
((SELECT appointment_id FROM appointments ORDER BY appointment_id LIMIT 1 OFFSET 3), 
 (SELECT procedure_id FROM procedures LIMIT 1 OFFSET 3), 25000.00, 2000.00, 'Whitening session');


INSERT INTO invoices (patient_id, appointment_id, invoice_date, total_amount, insurance_covered, status) VALUES
((SELECT patient_id FROM patients WHERE email = 'elnazar@gmail.com'), 
 (SELECT appointment_id FROM appointments ORDER BY appointment_id LIMIT 1 OFFSET 0), 
 '2026-06-15', 27000.00, 8000.00, 'Paid'),
((SELECT patient_id FROM patients WHERE email = 'amina.kurman@gmail.com'), 
 (SELECT appointment_id FROM appointments ORDER BY appointment_id LIMIT 1 OFFSET 1), 
 '2026-06-16', 25000.00, 0.00, 'Pending');

INSERT INTO payments (invoice_id, payment_date, amount, payment_method, transactionref) VALUES
((SELECT invoice_id FROM invoices ORDER BY invoice_id LIMIT 1 OFFSET 0), '2026-06-15', 19000.00, 'CreditCard', 'TXN-987654'),
((SELECT invoice_id FROM invoices ORDER BY invoice_id LIMIT 1 OFFSET 1), '2026-06-16', 10000.00, 'Cash', 'TXN-123456');



--============PART 6: UPDATE , DELETE============

--Apply 20% discount for loyal patients during summer promotion
UPDATE appointment_procedures
SET discount_amount = 0.2 * price_at_time
WHERE appointment_id IN (SELECT appointment_id FROM appointments WHERE status = 'Scheduled');

--Update procedure prices according to current inflation rate
UPDATE appointment_procedures ap
SET price_at_time = p.standard_price * 1.12
FROM procedures p
WHERE ap.procedure_id = p.procedure_id;

--Remove old cancelled appointments to maintain database performance
BEGIN;
DELETE FROM appointments
WHERE status = 'Cancelled' AND appointment_date < '2026-06-01'
RETURNING appointment_id;
ROLLBACK;

--============PART 7: GRANT , REVOKE============
--Drop roles if they exist (to make script re-runnable)
DROP ROLE IF EXISTS dental_readonly;
DROP ROLE IF EXISTS dental_writer;

--Create roles
CREATE ROLE dental_readonly;
CREATE ROLE dental_writer;


GRANT SELECT ON ALL TABLES IN SCHEMA public TO dental_readonly;


GRANT INSERT, UPDATE, DELETE ON 
    appointments, 
    appointment_procedures, 
    invoices, 
    payments 
TO dental_writer;

REVOKE UPDATE ON dentists FROM dental_writer;

-- Clean up any previous grants (helps with re-runnability)
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM dental_readonly, dental_writer;
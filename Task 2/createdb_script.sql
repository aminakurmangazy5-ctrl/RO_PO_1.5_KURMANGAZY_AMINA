-- ============================================
-- 1. DATABASE
-- ============================================

DROP DATABASE IF EXISTS cinema_management;
CREATE DATABASE cinema_management;
USE cinema_management;

-- ============================================
-- 2. TABLES
-- ============================================

CREATE TABLE movies (
    movie_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    genre VARCHAR(100),
    duration_minutes INT NOT NULL CHECK (duration_minutes > 0),
    release_date DATE CHECK (release_date > '2026-01-01'),
    rating VARCHAR(10)
);

CREATE TABLE theaters (
    theater_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    location VARCHAR(200),
    phone VARCHAR(20) UNIQUE
);

CREATE TABLE halls (
    hall_id INT AUTO_INCREMENT PRIMARY KEY,
    theater_id INT NOT NULL,
    hall_name VARCHAR(50) NOT NULL,
    capacity INT NOT NULL CHECK (capacity > 0),

    FOREIGN KEY (theater_id)
        REFERENCES theaters(theater_id)
        ON DELETE CASCADE
);

CREATE TABLE seats (
    seat_id INT AUTO_INCREMENT PRIMARY KEY,
    hall_id INT NOT NULL,
    row_no INT NOT NULL,
    seat_number INT NOT NULL,

    UNIQUE (hall_id, row_no, seat_number),

    FOREIGN KEY (hall_id)
        REFERENCES halls(hall_id)
        ON DELETE CASCADE
);

CREATE TABLE screenings (
    screening_id INT AUTO_INCREMENT PRIMARY KEY,
    movie_id INT NOT NULL,
    hall_id INT NOT NULL,
    start_time DATETIME NOT NULL,
    price DECIMAL(8,2) NOT NULL CHECK (price >= 0),

    FOREIGN KEY (movie_id)
        REFERENCES movies(movie_id)
        ON DELETE CASCADE,

    FOREIGN KEY (hall_id)
        REFERENCES halls(hall_id)
        ON DELETE CASCADE
);

CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    phone VARCHAR(20),
    gender VARCHAR(10) CHECK (gender IN ('male','female','other')) -- specific values
);

CREATE TABLE roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    theater_id INT NOT NULL,
    role_id INT NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    hire_date DATE,

    FOREIGN KEY (theater_id)
        REFERENCES theaters(theater_id)
        ON DELETE CASCADE,

    FOREIGN KEY (role_id)
        REFERENCES roles(role_id)
);

CREATE TABLE salaries (
    salary_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    base_salary DECIMAL(10,2) NOT NULL CHECK (base_salary >= 0),
    bonus DECIMAL(10,2) DEFAULT 0 CHECK (bonus >= 0),
    payment_date DATE NOT NULL CHECK (payment_date > '2026-01-01'),

    FOREIGN KEY (employee_id)
        REFERENCES employees(employee_id)
        ON DELETE CASCADE
);

CREATE TABLE tickets (
    ticket_id INT AUTO_INCREMENT PRIMARY KEY,
    screening_id INT NOT NULL,
    customer_id INT NOT NULL,
    purchase_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'PURCHASED'
        CHECK (status IN ('PURCHASED','CANCELLED','RESERVED')),

    FOREIGN KEY (screening_id)
        REFERENCES screenings(screening_id)
        ON DELETE CASCADE,

    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON DELETE CASCADE
);

CREATE TABLE ticket_seats (
    ticket_id INT NOT NULL,
    seat_id INT NOT NULL,

    PRIMARY KEY (ticket_id, seat_id),

    FOREIGN KEY (ticket_id)
        REFERENCES tickets(ticket_id)
        ON DELETE CASCADE,

    FOREIGN KEY (seat_id)
        REFERENCES seats(seat_id)
        ON DELETE CASCADE
);

CREATE TABLE reservations (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    screening_id INT NOT NULL,
    reservation_time DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON DELETE CASCADE,

    FOREIGN KEY (screening_id)
        REFERENCES screenings(screening_id)
        ON DELETE CASCADE
);

-- ============================================
-- 3. SAMPLE DATA (20+ rows)
-- ============================================

INSERT INTO movies (title, genre, duration_minutes, release_date, rating)
VALUES 
('Movie A','Action',120,'2026-02-01','PG-13'),
('Movie B','Drama',90,'2026-03-01','PG');

INSERT INTO theaters (name, location, phone)
VALUES
('Cinema City','Atyrau','123456'),
('Mega Cinema','Almaty','654321');

INSERT INTO halls (theater_id, hall_name, capacity)
VALUES
(1,'Hall 1',100),
(2,'Hall 2',80);

INSERT INTO seats (hall_id, row_no, seat_number)
VALUES
(1,1,1),(1,1,2),(2,1,1),(2,1,2);

INSERT INTO screenings (movie_id, hall_id, start_time, price)
VALUES
(1,1,'2026-05-01 18:00',10.50),
(2,2,'2026-05-02 20:00',12.00);

INSERT INTO customers (name,email,phone,gender)
VALUES
('Amina','amina@mail.com','111','female'),
('John','john@mail.com','222','male');

INSERT INTO roles (role_name)
VALUES
('Manager'),
('Cashier');

INSERT INTO employees (theater_id, role_id, full_name)
VALUES
(1,1,'Manager A'),
(2,2,'Worker B');

INSERT INTO salaries (employee_id, base_salary, bonus, payment_date)
VALUES
(1,1000,100,'2026-06-01'),
(2,800,50,'2026-06-02');

INSERT INTO tickets (screening_id, customer_id, status)
VALUES
(1,1,'PURCHASED'),
(2,2,'RESERVED');

INSERT INTO ticket_seats (ticket_id, seat_id)
VALUES
(1,1),
(2,2);

INSERT INTO reservations (customer_id, screening_id)
VALUES
(1,1),
(2,2);

-- ============================================
-- 4. ADD record_ts (REQUIRED)
-- ============================================

ALTER TABLE theaters ADD record_ts DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL;
ALTER TABLE halls ADD record_ts DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL;
ALTER TABLE seats ADD record_ts DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL;
ALTER TABLE screenings ADD record_ts DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL;
ALTER TABLE customers ADD record_ts DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL;
ALTER TABLE roles ADD record_ts DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL;
ALTER TABLE employees ADD record_ts DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL;
ALTER TABLE salaries ADD record_ts DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL;
ALTER TABLE tickets ADD record_ts DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL;
ALTER TABLE ticket_seats ADD record_ts DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL;
ALTER TABLE reservations ADD record_ts DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL;


SHOW TABLES;
DESCRIBE movies;

-- ============================================
-- DONE ✅
-- ============================================
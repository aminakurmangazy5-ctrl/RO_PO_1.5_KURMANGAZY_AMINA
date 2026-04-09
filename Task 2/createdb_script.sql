DROP SCHEMA IF EXISTS cinema_management CASCADE;
CREATE SCHEMA cinema_management;
SET search_path TO cinema_management;

CREATE TABLE movies (
    movie_id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    genre VARCHAR(50) NOT NULL CHECK (genre IN ('Action','Comedy','Drama','Horror','Sci-Fi')),
    duration_minutes INT NOT NULL CHECK (duration_minutes > 0),
    release_date DATE CHECK (release_date > '2026-01-01'),
    rating DECIMAL(2,1) DEFAULT 5.0 CHECK (rating >= 0)
);

CREATE TABLE cinema_management.theaters (
    theater_id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    location VARCHAR(200),
    phone VARCHAR(20) UNIQUE,
    record_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE halls (
    hall_id SERIAL PRIMARY KEY,
    theater_id INT NOT NULL,
    hall_name VARCHAR(50) NOT NULL,
    capacity INT NOT NULL CHECK (capacity > 0),
    record_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);
CREATE TABLE cinema_management.seats (
    seat_id SERIAL PRIMARY KEY,
    hall_id INT NOT NULL,
    row_no INT NOT NULL,
    seat_number INT NOT NULL,
    record_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    UNIQUE (hall_id, row_no, seat_number),
    FOREIGN KEY (hall_id) REFERENCES cinema_management.halls(hall_id) ON DELETE CASCADE
);

CREATE TABLE screenings (
    screening_id SERIAL PRIMARY KEY,
    movie_id INT NOT NULL,
    hall_id INT NOT NULL,
    start_time TIMESTAMP NOT NULL CHECK (start_time > '2026-01-01'),
    price DECIMAL(8,2) NOT NULL CHECK (price >= 0),
    record_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id) ON DELETE CASCADE,
    FOREIGN KEY (hall_id) REFERENCES halls(hall_id) ON DELETE CASCADE
);

CREATE TABLE cinema_management.customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    phone VARCHAR(20),
    gender VARCHAR(10) CHECK (gender IN ('male','female','other')),
    record_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE cinema_management.roles (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(100) NOT NULL UNIQUE,
    record_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE cinema_management.employees (
    employee_id SERIAL PRIMARY KEY,
    theater_id INT NOT NULL,
    role_id INT NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    hire_date DATE,
    record_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY (theater_id) REFERENCES cinema_management.theaters(theater_id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES cinema_management.roles(role_id)
);

CREATE TABLE cinema_management.salaries (
    salary_id SERIAL PRIMARY KEY,
    employee_id INT NOT NULL,
    base_salary DECIMAL(10,2) NOT NULL CHECK (base_salary >= 0),
    bonus DECIMAL(10,2) DEFAULT 0 CHECK (bonus >= 0),
    payment_date DATE NOT NULL CHECK (payment_date > '2026-01-01'),
    total_salary DECIMAL(10,2) GENERATED ALWAYS AS (base_salary + bonus) STORED,
    record_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY (employee_id) REFERENCES cinema_management.employees(employee_id) ON DELETE CASCADE
);

CREATE TABLE cinema_management.tickets (
    ticket_id SERIAL PRIMARY KEY,
    screening_id INT NOT NULL,
    customer_id INT NOT NULL,
    purchase_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'PURCHASED' CHECK (status IN ('PURCHASED','CANCELLED','RESERVED')),
    record_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY (screening_id) REFERENCES cinema_management.screenings(screening_id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES cinema_management.customers(customer_id) ON DELETE CASCADE
);

CREATE TABLE cinema_management.ticket_seats (
    ticket_id INT NOT NULL,
    seat_id INT NOT NULL,
    record_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    PRIMARY KEY (ticket_id, seat_id),
    FOREIGN KEY (ticket_id) REFERENCES cinema_management.tickets(ticket_id) ON DELETE CASCADE,
    FOREIGN KEY (seat_id) REFERENCES cinema_management.seats(seat_id) ON DELETE CASCADE
);

CREATE TABLE cinema_management.reservations (
    reservation_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    screening_id INT NOT NULL,
    reservation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    record_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES cinema_management.customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (screening_id) REFERENCES cinema_management.screenings(screening_id) ON DELETE CASCADE
);
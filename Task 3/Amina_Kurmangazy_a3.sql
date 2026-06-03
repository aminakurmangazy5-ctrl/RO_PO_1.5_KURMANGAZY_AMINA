DROP USER IF EXISTS db_admin_user;
DROP USER IF EXISTS db_reader_user;
DROP ROLE IF EXISTS cinema_management_admin;
DROP ROLE IF EXISTS cinema_management_readonly;



CREATE ROLE cinema_management_admin;
CREATE ROLE cinema_management_readonly;

GRANT USAGE ON SCHEMA cinema_management TO cinema_management_admin, cinema_management_readonly;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA cinema_management TO cinema_management_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA cinema_management TO cinema_management_readonly;
REVOKE INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA cinema_management FROM cinema_management_readonly;

CREATE USER db_admin_user WITH PASSWORD 'AdminCinema2026!';
CREATE USER db_reader_user WITH PASSWORD 'ReaderCinema2026!';

GRANT cinema_management_admin TO db_admin_user;
GRANT cinema_management_readonly TO db_reader_user;



SET search_path TO cinema_management;

TRUNCATE TABLE ticket_seats CASCADE;
TRUNCATE TABLE tickets CASCADE;
TRUNCATE TABLE reservations CASCADE;
TRUNCATE TABLE salaries CASCADE;
TRUNCATE TABLE employees CASCADE;
TRUNCATE TABLE seats CASCADE;
TRUNCATE TABLE screenings CASCADE;
TRUNCATE TABLE halls CASCADE;
TRUNCATE TABLE theaters CASCADE;
TRUNCATE TABLE customers CASCADE;
TRUNCATE TABLE roles CASCADE;
TRUNCATE TABLE movies CASCADE;


INSERT INTO movies (title, genre, duration_minutes, release_date, rating)
VALUES
    ('The Dune Prophecy', 'Sci-Fi', 148, '2026-03-15', 7.8),
    ('Kazakh Warriors', 'Action', 135, '2026-04-10', 8.1),
    ('Love in Almaty', 'Comedy', 112, '2026-02-20', 6.5),
    ('Midnight Horror', 'Horror', 98, '2026-05-05', 7.2),
    ('The Last Oilman', 'Drama', 165, '2026-06-01', 8.4),
    ('Space Nomads', 'Sci-Fi', 125, '2026-07-15', 7.9);



INSERT INTO theaters (name, location, phone)
VALUES
    ('Cinema Atyrau Central', 'Satpaev Ave 12, Atyrau', '+77123456789'),
    ('Silver Screen Mall', 'Abay St 45, Atyrau', '+77129876543'),
    ('Ocean Plaza Cinema', 'Azattyk Ave, Atyrau', '+77124567890'),
    ('Nomad Multiplex', 'Qurmangazy St 8, Atyrau', '+77126789012'),
    ('Cinema Kaspi', 'Abylkhair Khan Ave, Atyrau', '+77123456700');

INSERT INTO roles (role_name) VALUES
    ('Manager'), ('Cashier'), ('Cleaner'), ('Technician'), ('Projectionist'), ('Security');

INSERT INTO halls (theater_id, hall_name, capacity)
VALUES
    ((SELECT theater_id FROM theaters WHERE name = 'Cinema Atyrau Central'), 'Hall A', 120),
    ((SELECT theater_id FROM theaters WHERE name = 'Cinema Atyrau Central'), 'Hall B', 85),
    ((SELECT theater_id FROM theaters WHERE name = 'Silver Screen Mall'), 'Main Hall', 200),
    ((SELECT theater_id FROM theaters WHERE name = 'Ocean Plaza Cinema'), 'VIP Hall', 60),
    ((SELECT theater_id FROM theaters WHERE name = 'Nomad Multiplex'), 'Hall 1', 150);

INSERT INTO seats (hall_id, row_no, seat_number)
SELECT h.hall_id, r, s
FROM halls h
CROSS JOIN generate_series(1, 10) r
CROSS JOIN generate_series(1, 12) s
WHERE h.hall_name IN ('Hall A', 'Hall B', 'Main Hall')
LIMIT 200;

INSERT INTO screenings (movie_id, hall_id, start_time, price)
VALUES
    ((SELECT movie_id FROM movies WHERE title = 'The Dune Prophecy'), (SELECT hall_id FROM halls WHERE hall_name = 'Hall A'), '2026-06-10 18:30:00', 4500.00),
    ((SELECT movie_id FROM movies WHERE title = 'Kazakh Warriors'), (SELECT hall_id FROM halls WHERE hall_name = 'Main Hall'), '2026-06-11 20:00:00', 3800.00),
    ((SELECT movie_id FROM movies WHERE title = 'Love in Almaty'), (SELECT hall_id FROM halls WHERE hall_name = 'VIP Hall'), '2026-06-12 17:00:00', 5200.00),
    ((SELECT movie_id FROM movies WHERE title = 'Midnight Horror'), (SELECT hall_id FROM halls WHERE hall_name = 'Hall 1'), '2026-06-13 22:00:00', 4000.00),
    ((SELECT movie_id FROM movies WHERE title = 'The Last Oilman'), (SELECT hall_id FROM halls WHERE hall_name = 'Hall A'), '2026-06-14 19:00:00', 4700.00);

INSERT INTO customers (name, email, phone, gender)
VALUES
    ('Almas Nurlanov', 'almas.n@kzmail.kz', '+77471234567', 'male'),
    ('Aizhan Tolegenova', 'aizhan.t@gmail.com', '+77479876543', 'female'),
    ('Daulet Serikov', 'daulet.business@kz', '+77011234567', 'male'),
    ('Madina Kairatova', 'madina.k@mail.ru', '+77475678901', 'female'),
    ('Nursultan Bakytov', 'nursultan.b@oil.kz', '+77472345678', 'male'),
    ('Amina Serikova', 'amina.s@kz', '+77476543210', 'female');

INSERT INTO employees (theater_id, role_id, full_name, hire_date)
VALUES
    ((SELECT theater_id FROM theaters WHERE name = 'Cinema Atyrau Central'), (SELECT role_id FROM roles WHERE role_name = 'Manager'), 'Berik Talgatov', '2025-01-15'),
    ((SELECT theater_id FROM theaters WHERE name = 'Cinema Atyrau Central'), (SELECT role_id FROM roles WHERE role_name = 'Cashier'), 'Aigerim Sadykova', '2025-03-01'),
    ((SELECT theater_id FROM theaters WHERE name = 'Silver Screen Mall'), (SELECT role_id FROM roles WHERE role_name = 'Cleaner'), 'Arman Kudaibergen', '2025-02-10'),
    ((SELECT theater_id FROM theaters WHERE name = 'Ocean Plaza Cinema'), (SELECT role_id FROM roles WHERE role_name = 'Technician'), 'Daniyar Orazov', '2025-04-05'),
    ((SELECT theater_id FROM theaters WHERE name = 'Nomad Multiplex'), (SELECT role_id FROM roles WHERE role_name = 'Projectionist'), 'Laura Temirbekova', '2025-05-20');

INSERT INTO salaries (employee_id, base_salary, bonus, payment_date)
VALUES
    ((SELECT employee_id FROM employees WHERE full_name = 'Berik Talgatov'), 450000, 50000, '2026-05-01'),
    ((SELECT employee_id FROM employees WHERE full_name = 'Aigerim Sadykova'), 180000, 15000, '2026-05-01'),
    ((SELECT employee_id FROM employees WHERE full_name = 'Arman Kudaibergen'), 120000, 10000, '2026-05-01'),
    ((SELECT employee_id FROM employees WHERE full_name = 'Daniyar Orazov'), 250000, 20000, '2026-05-01'),
    ((SELECT employee_id FROM employees WHERE full_name = 'Laura Temirbekova'), 200000, 25000, '2026-05-01');

INSERT INTO tickets (screening_id, customer_id, status)
VALUES
    ((SELECT screening_id FROM screenings LIMIT 1), (SELECT customer_id FROM customers LIMIT 1), 'PURCHASED'),
    ((SELECT screening_id FROM screenings OFFSET 1 LIMIT 1), (SELECT customer_id FROM customers OFFSET 1 LIMIT 1), 'PURCHASED'),
    ((SELECT screening_id FROM screenings OFFSET 2 LIMIT 1), (SELECT customer_id FROM customers OFFSET 2 LIMIT 1), 'PURCHASED'),
    ((SELECT screening_id FROM screenings OFFSET 3 LIMIT 1), (SELECT customer_id FROM customers OFFSET 3 LIMIT 1), 'RESERVED'),
    ((SELECT screening_id FROM screenings OFFSET 4 LIMIT 1), (SELECT customer_id FROM customers OFFSET 4 LIMIT 1), 'PURCHASED');

-- Увеличено количество ticket_seats
INSERT INTO ticket_seats (ticket_id, seat_id)
VALUES
    ((SELECT ticket_id FROM tickets OFFSET 0 LIMIT 1), (SELECT seat_id FROM seats LIMIT 1)),
    ((SELECT ticket_id FROM tickets OFFSET 0 LIMIT 1), (SELECT seat_id FROM seats OFFSET 2 LIMIT 1)),
    ((SELECT ticket_id FROM tickets OFFSET 1 LIMIT 1), (SELECT seat_id FROM seats OFFSET 5 LIMIT 1)),
    ((SELECT ticket_id FROM tickets OFFSET 1 LIMIT 1), (SELECT seat_id FROM seats OFFSET 8 LIMIT 1)),
    ((SELECT ticket_id FROM tickets OFFSET 2 LIMIT 1), (SELECT seat_id FROM seats OFFSET 12 LIMIT 1));

INSERT INTO reservations (customer_id, screening_id)
VALUES
    ((SELECT customer_id FROM customers OFFSET 5 LIMIT 1), (SELECT screening_id FROM screenings LIMIT 1)),
    ((SELECT customer_id FROM customers OFFSET 1 LIMIT 1), (SELECT screening_id FROM screenings OFFSET 1 LIMIT 1)),
    ((SELECT customer_id FROM customers OFFSET 2 LIMIT 1), (SELECT screening_id FROM screenings OFFSET 2 LIMIT 1));



SELECT name, phone FROM customers WHERE email = 'almas.n@kzmail.kz';
UPDATE customers SET phone = '+77471112233' WHERE email = 'almas.n@kzmail.kz';

SELECT ticket_id, status FROM tickets WHERE customer_id = (SELECT customer_id FROM customers LIMIT 1);
UPDATE tickets SET status = 'CANCELLED' WHERE ticket_id = (SELECT ticket_id FROM tickets LIMIT 1);

SELECT s.screening_id, s.price, h.hall_name
FROM screenings s JOIN halls h ON s.hall_id = h.hall_id
WHERE h.hall_name = 'VIP Hall';
UPDATE screenings s SET price = price * 1.15
FROM halls h WHERE s.hall_id = h.hall_id AND h.hall_name = 'VIP Hall';




BEGIN;
DELETE FROM ticket_seats WHERE ticket_id IN (SELECT ticket_id FROM tickets WHERE status = 'CANCELLED' AND purchase_time < CURRENT_TIMESTAMP - INTERVAL '30 days');
DELETE FROM tickets WHERE status = 'CANCELLED' AND purchase_time < CURRENT_TIMESTAMP - INTERVAL '30 days';
SELECT COUNT(*) FROM tickets WHERE status = 'CANCELLED';
ROLLBACK;




SET ROLE db_admin_user;
SELECT current_user;
SELECT COUNT(*) FROM movies;
RESET ROLE;




SET ROLE db_reader_user;
SELECT current_user;
SELECT COUNT(*) FROM movies;

BEGIN; INSERT INTO customers (name, email) VALUES ('Fail', 'fail@kz'); ROLLBACK;
BEGIN; UPDATE movies SET rating = 10 WHERE movie_id = 1; ROLLBACK;
BEGIN; DELETE FROM customers WHERE customer_id = 1; ROLLBACK;
RESET ROLE;
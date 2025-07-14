CREATE DATABASE attendance_system;

USE attendance_system;

CREATE TABLE faculty (
    id INT AUTO_INCREMENT PRIMARY KEY,
    faculty_id VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    image LONGBLOB NOT NULL
);
CREATE TABLE attendance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    faculty_id VARCHAR(50) NOT NULL,
    status ENUM('Present', 'Absent') NOT NULL,
    login_time DATETIME NOT NULL,
    logout_time DATETIME DEFAULT NULL,
    date DATE NOT NULL,
    FOREIGN KEY (faculty_id) REFERENCES faculty(faculty_id)
);

ALTER TABLE attendance MODIFY COLUMN status VARCHAR(20);
CREATE TABLE IF NOT EXISTS employees (
    employee_id varchar(50) primary key,
    name varchar(50),
    password varchar(50) 
);

CREATE TABLE location (
    id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id VARCHAR(50),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

USE attendance_system;

select * from faculty;
select * from attendance;
select * from employees;
select * from location;

set sql_safe_updates=1;


-- ALTER TABLE attendance
-- CHANGE status status ENUM('Present', 'Absent') NOT NULL;
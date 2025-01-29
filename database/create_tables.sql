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

select * from faculty;
select * from attendance;


delete from attendance;
delete from faculty;

set sql_safe_updates=1;


ALTER TABLE attendance
CHANGE status status ENUM('Present', 'Absent') NOT NULL;
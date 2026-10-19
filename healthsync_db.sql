-- ========================================================
-- FILE: healthsync_db.sql
-- DỰ ÁN: HEALTHSYNC DATABASE OPTIMIZATION
-- ========================================================

CREATE DATABASE IF NOT EXISTS healthsync_db;
USE healthsync_db;

-- 1. BẢNG PATIENTS
CREATE TABLE IF NOT EXISTS Patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL
);

-- 2. BẢNG DOCTORS
CREATE TABLE IF NOT EXISTS Doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    specialty VARCHAR(50)
);

-- 3. BẢNG APPOINTMENTS (CẤU TRÚC ĐÃ ĐƯỢC TỐI ƯU)
CREATE TABLE IF NOT EXISTS Appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATETIME NOT NULL,
    status ENUM('PENDING', 'CONFIRMED', 'CHECKED_IN', 'COMPLETED', 'CANCELLED') DEFAULT 'PENDING',
    deposit_amount DECIMAL(10, 2) DEFAULT 0.00,
    penalty_fee DECIMAL(10, 2) DEFAULT 0.00,
    cancel_reason VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id) ON DELETE RESTRICT,
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id) ON DELETE RESTRICT
);

-- 4. BẢNG PRESCRIPTIONS (ĐƠN THUỐC)
CREATE TABLE IF NOT EXISTS Prescriptions (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT UNIQUE NOT NULL,
    medication_details TEXT NOT NULL,
    issued_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (appointment_id) REFERENCES Appointments(appointment_id) ON DELETE CASCADE
);

-- ========================================================
-- TRIGGER: Chặn kê đơn khi lịch hẹn chưa COMPLETED
-- ========================================================
DELIMITER //
CREATE TRIGGER chk_prescription_before_insert
BEFORE INSERT ON Prescriptions
FOR EACH ROW
BEGIN
    DECLARE app_status VARCHAR(20);
    SELECT status INTO app_status FROM Appointments WHERE appointment_id = NEW.appointment_id;
    
    IF app_status != 'COMPLETED' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi nghiệp vụ: Không thể kê đơn thuốc cho lịch hẹn chưa hoàn tất (COMPLETED)!';
    END IF;
END;
//
DELIMITER ;

-- ========================================================
-- KỊCH BẢN MÔ PHỎNG DỮ LIỆU (DML)
-- ========================================================

-- Dữ liệu mẫu ban đầu
INSERT INTO Patients (full_name, phone) VALUES 
('Nguyễn Văn A', '0901234567'),
('Trần Thị B', '0987654321');

INSERT INTO Doctors (full_name, specialty) VALUES 
('BS. Lê Văn C', 'Nội khoa'),
('BS. Phạm Thị D', 'Nhi khoa');

-- KỊCH BẢN 1: Luồng khám bệnh thành công
INSERT INTO Appointments (patient_id, doctor_id, appointment_date, status, deposit_amount) 
VALUES (1, 1, '2026-03-20 09:00:00', 'PENDING', 500000.00);

UPDATE Appointments SET status = 'CHECKED_IN' WHERE appointment_id = 1;
UPDATE Appointments SET status = 'COMPLETED' WHERE appointment_id = 1;

INSERT INTO Prescriptions (appointment_id, medication_details) 
VALUES (1, 'Paracetamol 500mg x 10 viên (Uống 2 lần/ngày), Vitamin C x 10 viên');

-- KỊCH BẢN 2: Luồng Hủy lịch và Phạt tiền cọc
INSERT INTO Appointments (patient_id, doctor_id, appointment_date, status, deposit_amount) 
VALUES (2, 2, '2026-03-21 14:00:00', 'CONFIRMED', 300000.00);

UPDATE Appointments 
SET status = 'CANCELLED', 
    cancel_reason = 'Bận việc đột xuất', 
    penalty_fee = 150000.00 
WHERE appointment_id = 2;

-- ========================================================
-- TRUY VẤN KIỂM TRA KẾT QUẢ (SELECT)
-- ========================================================
SELECT 
    a.appointment_id,
    p.full_name AS patient_name,
    d.full_name AS doctor_name,
    a.status,
    a.deposit_amount,
    pr.medication_details,
    pr.issued_date
FROM Appointments a
JOIN Patients p ON a.patient_id = p.patient_id
JOIN Doctors d ON a.doctor_id = d.doctor_id
JOIN Prescriptions pr ON a.appointment_id = pr.appointment_id
WHERE a.status = 'COMPLETED';
-- Create the database
CREATE DATABASE ClinicBookingSystem;
USE ClinicBookingSystem;
-- Patients table
CREATE TABLE Patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('Male', 'Female', 'Other') NOT NULL,
    phone_number VARCHAR(15) NOT NULL,
    email VARCHAR(100) UNIQUE,
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Doctors table
CREATE TABLE Doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    specialization VARCHAR(100) NOT NULL,
    phone_number VARCHAR(15) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    license_number VARCHAR(50) UNIQUE NOT NULL,
    hire_date DATE NOT NULL,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Clinics table
CREATE TABLE Clinics (
    clinic_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address TEXT NOT NULL,
    phone_number VARCHAR(15) NOT NULL,
    email VARCHAR(100) UNIQUE,
    opening_time TIME NOT NULL,
    closing_time TIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
-- Medical Records table
CREATE TABLE MedicalRecords (
    record_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_id INT,
    diagnosis TEXT,
    treatment TEXT,
    prescription TEXT,
    notes TEXT,
    record_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id),
    FOREIGN KEY (appointment_id) REFERENCES Appointments(appointment_id)
);

-- Prescriptions table
CREATE TABLE Prescriptions (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    record_id INT NOT NULL,
    medication_name VARCHAR(100) NOT NULL,
    dosage VARCHAR(50) NOT NULL,
    frequency VARCHAR(50) NOT NULL,
    duration VARCHAR(50) NOT NULL,
    instructions TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (record_id) REFERENCES MedicalRecords(record_id)
);
-- Services table
CREATE TABLE Services (
    service_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    duration INT NOT NULL COMMENT 'Duration in minutes',
    price DECIMAL(10, 2) NOT NULL,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Appointment Services (M-M relationship between Appointments and Services)
CREATE TABLE AppointmentServices (
    appointment_service_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT NOT NULL,
    service_id INT NOT NULL,
    quantity INT DEFAULT 1,
    unit_price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (appointment_id) REFERENCES Appointments(appointment_id),
    FOREIGN KEY (service_id) REFERENCES Services(service_id),
    CONSTRAINT unique_appointment_service UNIQUE (appointment_id, service_id)
);

-- Invoices table
CREATE TABLE Invoices (
    invoice_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT,
    patient_id INT NOT NULL,
    invoice_date DATE NOT NULL,
    due_date DATE NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    paid_amount DECIMAL(10, 2) DEFAULT 0,
    status ENUM('Pending', 'Paid', 'Cancelled', 'Overdue') DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (appointment_id) REFERENCES Appointments(appointment_id),
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id)
);

-- Payments table
CREATE TABLE Payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    invoice_id INT NOT NULL,
    payment_date DATETIME NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_method ENUM('Cash', 'Credit Card', 'Debit Card', 'Insurance', 'Bank Transfer') NOT NULL,
    transaction_reference VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (invoice_id) REFERENCES Invoices(invoice_id)
);
-- Users table (for system access)
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    role ENUM('Admin', 'Doctor', 'Receptionist', 'Nurse') NOT NULL,
    associated_id INT COMMENT 'ID from Doctors or other tables based on role',
    last_login DATETIME,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Audit Log table
CREATE TABLE AuditLog (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    action VARCHAR(50) NOT NULL,
    table_name VARCHAR(50) NOT NULL,
    record_id INT,
    old_values TEXT,
    new_values TEXT,
    ip_address VARCHAR(45),
    action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);
-- Create indexes for frequently queried columns
CREATE INDEX idx_patient_name ON Patients(last_name, first_name);
CREATE INDEX idx_doctor_name ON Doctors(last_name, first_name);
CREATE INDEX idx_appointment_date ON Appointments(appointment_date, status);
CREATE INDEX idx_medical_record_patient ON MedicalRecords(patient_id);
CREATE INDEX idx_invoice_status ON Invoices(status);
CREATE INDEX idx_payment_invoice ON Payments(invoice_id);
-- View for today's appointments
CREATE VIEW TodayAppointments AS
SELECT 
    a.appointment_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    CONCAT(d.first_name, ' ', d.last_name) AS doctor_name,
    c.name AS clinic_name,
    a.appointment_date,
    a.start_time,
    a.end_time,
    a.status
FROM 
    Appointments a
JOIN 
    Patients p ON a.patient_id = p.patient_id
JOIN 
    Doctors d ON a.doctor_id = d.doctor_id
JOIN 
    Clinics c ON a.clinic_id = c.clinic_id
WHERE 
    a.appointment_date = CURDATE()
ORDER BY 
    a.start_time;

-- View for patient medical history
CREATE VIEW PatientMedicalHistory AS
SELECT 
    mr.record_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    CONCAT(d.first_name, ' ', d.last_name) AS doctor_name,
    mr.record_date,
    mr.diagnosis,
    mr.treatment,
    GROUP_CONCAT(pr.medication_name SEPARATOR ', ') AS medications
FROM 
    MedicalRecords mr
JOIN 
    Patients p ON mr.patient_id = p.patient_id
JOIN 
    Doctors d ON mr.doctor_id = d.doctor_id
LEFT JOIN 
    Prescriptions pr ON mr.record_id = pr.record_id
GROUP BY 
    mr.record_id;
-- Procedure to book an appointment
DELIMITER //
CREATE PROCEDURE BookAppointment(
    IN p_patient_id INT,
    IN p_doctor_id INT,
    IN p_clinic_id INT,
    IN p_appointment_date DATE,
    IN p_start_time TIME,
    IN p_reason TEXT
)
BEGIN
    DECLARE duration_min INT DEFAULT 30; -- Default appointment duration
    DECLARE end_time TIME;
    
    -- Calculate end time based on service duration
    SELECT COALESCE(SUM(s.duration), 30) INTO duration_min
    FROM AppointmentServices aps
    JOIN Services s ON aps.service_id = s.service_id
    WHERE aps.appointment_id = p_appointment_id;
    
    SET end_time = ADDTIME(p_start_time, SEC_TO_TIME(duration_min * 60));
    
    -- Check if doctor is available
    IF EXISTS (
        SELECT 1 FROM DoctorSchedules 
        WHERE doctor_id = p_doctor_id 
        AND clinic_id = p_clinic_id
        AND day_of_week = DAYNAME(p_appointment_date)
        AND is_available = TRUE
        AND p_start_time BETWEEN start_time AND end_time
    ) AND NOT EXISTS (
        SELECT 1 FROM Appointments
        WHERE doctor_id = p_doctor_id
        AND appointment_date = p_appointment_date
        AND (
            (p_start_time BETWEEN start_time AND end_time)
            OR (end_time BETWEEN start_time AND end_time)
        )
        AND status != 'Cancelled'
    ) THEN
        -- Insert the appointment
        INSERT INTO Appointments (
            patient_id, doctor_id, clinic_id, 
            appointment_date, start_time, end_time, reason
        ) VALUES (
            p_patient_id, p_doctor_id, p_clinic_id,
            p_appointment_date, p_start_time, end_time, p_reason
        );
        
        SELECT LAST_INSERT_ID() AS appointment_id, 'Appointment booked successfully' AS message;
    ELSE
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Doctor is not available at the requested time';
    END IF;
END //
DELIMITER ;

-- Procedure to generate invoice
DELIMITER //
CREATE PROCEDURE GenerateInvoice(IN p_appointment_id INT)
BEGIN
    DECLARE v_total DECIMAL(10, 2);
    DECLARE v_patient_id INT;
    
    -- Get patient ID from appointment
    SELECT patient_id INTO v_patient_id FROM Appointments WHERE appointment_id = p_appointment_id;
    
    -- Calculate total from appointment services
    SELECT SUM(aps.quantity * aps.unit_price) INTO v_total
    FROM AppointmentServices aps
    WHERE aps.appointment_id = p_appointment_id;
    
    -- Insert invoice
    INSERT INTO Invoices (
        appointment_id, patient_id, invoice_date, due_date, total_amount
    ) VALUES (
        p_appointment_id, v_patient_id, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 14 DAY), v_total
    );
    
    SELECT LAST_INSERT_ID() AS invoice_id, v_total AS amount_due;
END //
DELIMITER ;

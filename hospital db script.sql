-- Hospital Management System
USE hospital;
-- SET FOREIGN_KEY_CHECKS=0;
-- SET SQL_SAFE_UPDATES = 0;

-- Create patients table
CREATE TABLE patients (
	id INTEGER PRIMARY KEY,
    name VARCHAR(10),
    age INTEGER,
    race VARCHAR(10),
    cond VARCHAR(200),
    status BOOLEAN,
    intake_date INTEGER, -- month in integer
    equipments_id INTEGER,
    doctor_id INTEGER,
	FOREIGN KEY (equipments_id) REFERENCES supplies(id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(id)
);

INSERT INTO patients (name, age, race, cond, status, intake_date, equipments_id, doctor_id) 
VALUES ("Patient #1", 19, "White", "Cancer", true, 1, 1, 1) ;
INSERT INTO patients (name, age, race, cond, status, intake_date, equipments_id, doctor_id) 
VALUES ("Patient #2", 29, "Asian", "Heart Disease", false, 7, 1, 1) ;
INSERT INTO patients (name, age, race, cond, status, intake_date, equipments_id, doctor_id) 
VALUES ("Patient #3", 11, "Hispanic", "Liver Failure", true, 1, 1, 1) ;
INSERT INTO patients (name, age, race, cond, status, intake_date, equipments_id, doctor_id) 
VALUES ("Patient #4", 11, "Hispanic", "Brain Damage", true, 1, 1, 1) ;
INSERT INTO patients (name, age, race, cond, status, intake_date, equipments_id, doctor_id) 
VALUES ("Patient #4", 11, "White", "Broken leg", false, 1, 2, 2) ;
INSERT INTO patients (name, age, race, cond, status, intake_date, equipments_id, doctor_id) 
VALUES ("Patient #5", 11, "Asian", "Vision issues", true, 1, 2, 3);
INSERT INTO patients (name, age, race, cond, status, intake_date, equipments_id, doctor_id) 
VALUES ("Patient #6", 11, "Black", "Kidney failure", false, 1, 2, 3) ;
INSERT INTO patients (name, age, race, cond, status, intake_date, equipments_id, doctor_id) 
VALUES ("Patient #7", 11, "Black", "Surgery", true, 1, 2, 2) ;
INSERT INTO patients (name, age, race, cond, status, intake_date, equipments_id, doctor_id) 
VALUES ("Patient #8", 11, "White", "Brain Damage", false, 1, 2, 3) ;

-- Update equipment ID to assign different medical equipments
UPDATE patients
SET equipments_id = 3
WHERE race = "Black";

UPDATE patients
SET equipments_id = 4
WHERE race = "White";

-- Doctor table
CREATE TABLE doctors (
	id INTEGER PRIMARY KEY,
    name VARCHAR(10) CHECK (name LIKE "Dr.%")
);

INSERT INTO doctors (id, name) VALUES (1, "Dr.Kang");
INSERT INTO doctors (id, name) VALUES (2, "Dr.Lim");
INSERT INTO doctors (id, name) VALUES (3, "Dr.Cheung");
INSERT INTO doctors (id, name) VALUES (4, "Dr.White");
INSERT INTO doctors (id, name) VALUES (5, "Dr.Carter");

-- Sub-doctor tables: residences/interns
CREATE TABLE subs (
	id INTEGER PRIMARY KEY,
    name VARCHAR(10),
    department VARCHAR(20),
    team_id INTEGER
);

INSERT INTO subs (id, name, department, team_id) VALUES (1, "Mort", "Heart", 1);
INSERT INTO subs (id, name, department, team_id) VALUES (2, "Rick", "Liver", 2);
INSERT INTO subs (id, name, department, team_id) VALUES (3, "David", "Kidney", 2);
INSERT INTO subs (id, name, department, team_id) VALUES (4, "Kim", "Brain", 2);
INSERT INTO subs (id, name, department, team_id) VALUES (5, "Jim", "Heart", 2);
INSERT INTO subs (id, name, department, team_id) VALUES (6, "John", "Skin", 3);

-- Table of medical supplies
CREATE TABLE supplies (
	id INTEGER PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50),
    status BOOLEAN -- check if available or unavailable
    -- add price
);

ALTER TABLE supplies
ADD s_id INTEGER;

INSERT INTO supplies (name, status, s_id) VALUES ("Chrome Mosquito Hemostat Forceps 5", true, 1);
INSERT INTO supplies (name, status, s_id) VALUES ("1400mL Nutrient Pack", true, 1);
INSERT INTO supplies (name, status, s_id) VALUES ("30cm Stainless Steel Silver Long Food Tweezer", false, 2);
INSERT INTO supplies (name, status, s_id) VALUES ("Ventilator", false, 2);
INSERT INTO supplies (name, status, s_id) VALUES ("Stethoscope", false, 2);

INSERT INTO supplies (name, status, s_id) VALUES ("Syringe", true, 3);
INSERT INTO supplies (name, status, s_id) VALUES ("Defibrillators", true, 3);
INSERT INTO supplies (name, status, s_id) VALUES ("Surgical Tables", true, 3);

INSERT INTO supplies (name, status, s_id) VALUES ("Surgical Lights", false, 4);
INSERT INTO supplies (name, status, s_id) VALUES ("Blanket and Fluid Warmers", false, 4);

-- Check info of patients and doctors at once
CALL hospital.p();
CALL hospital.all_docs();

-- Normalizing data
ALTER TABLE supplies
MODIFY COLUMN status VARCHAR(20);

UPDATE supplies
SET status = 
CASE WHEN status = true THEN "available"
ELSE "unavailable" END;

-- Patients with specific conditions
SELECT name, cond AS illness, intake_date, equipments_id, doctor_id
FROM patients
WHERE cond = "Cancer";

SELECT name, cond AS illness, intake_date, equipments_id, doctor_id
FROM patients
WHERE cond != "Liver Failure" AND cond != "Brain Damage";

-- Group by race & age and take count of illnesses
SELECT COUNT(name) AS COUNT, race
FROM patients
GROUP BY race;

-- Check the status of patients
SELECT name, age, race, cond, status
FROM patients
WHERE status = 1
UNION
SELECT name, age, race, cond, status
FROM patients
WHERE status = 0;

-- Group by condition and find the country wity the most condition
SELECT COUNT(name) AS COUNT, race AS country_with_most_patients
FROM patients
GROUP BY race
ORDER BY COUNT DESC 
LIMIT 1;

-- Finding each patient's doctor
WITH patient_doctor_CTE AS ( 
SELECT patients.name AS patient, patients.age, patients.race, patients.cond, patients.doctor_id, doctors.name AS doctor
FROM patients
INNER JOIN doctors ON doctors.id = patients.doctor_id
)
SELECT doctor, COUNT(patient) FROM patient_doctor_CTE
GROUP BY doctor;


-- Find the equipments needed for each patient
WITH supplies_CTE AS ( SELECT supplies.id as id, patients.name AS patient, patients.age, patients.race, patients.cond, patients.equipments_id, supplies.name AS supplies
FROM patients
CROSS JOIN supplies 
WHERE supplies.s_id = patients.equipments_id )
SELECT supplies, GROUP_CONCAT(patient) AS "patients" FROM supplies_CTE
GROUP BY supplies;

-- Find the months with the most patient intake (cross join)
SELECT * FROM all_months;

WITH month_cte as (select count(name) as count, m from patients
CROSS JOIN all_months
WHERE i = intake_date
GROUP BY m )
SELECT m as busiest_month from month_cte
WHERE COUNT = ( SELECT MAX(COUNT) FROM month_cte) ;

-- Doctor, sub-doctors (interns, residents), patient tree
SELECT doctors.name as head, GROUP_CONCAT(patients.name) as patients, GROUP_CONCAT(DISTINCT subs.name) as sub, subs.department from doctors
CROSS JOIN
patients
ON patients.doctor_id = doctors.id
CROSS JOIN
subs
WHERE subs.team_id = doctors.id
GROUP BY head, subs.department;

-- Find the most popular equipment
WITH popular_equipment_cte AS ( SELECT COUNT(patients.name) AS count, supplies.name FROM patients
INNER JOIN supplies
WHERE patients.equipments_id = supplies.s_id
AND supplies.status = "available"
GROUP BY supplies.name, supplies.s_id )
SELECT * from popular_equipment_cte
WHERE count = (select max(count) from popular_equipment_cte);

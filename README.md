# 🚗 GlobalCarHire Database Management System

<p align="center">
  🚘 Vehicle Rental Management | 🗄️ SQL Database System | ⚙️ Business Process Automation
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Database-SQL%20Server-blue">
  <img src="https://img.shields.io/badge/Language-T--SQL-green">
  <img src="https://img.shields.io/badge/Architecture-Relational%20Database-orange">
  <img src="https://img.shields.io/badge/Focus-Business%20Automation-red">
</p>

---

## 📊 Project Overview

GlobalCarHire is a relational database management system developed for a multi-branch vehicle rental company. The system streamlines customer management, vehicle reservations, booking operations, return processing, invoice generation, and service handling through a fully normalized SQL database architecture.

The project demonstrates end-to-end database development including conceptual modelling, relational schema design, SQL implementation, stored procedures, validation logic, and automated business workflows.

---

# 🎯 Business Objectives

- Centralize vehicle rental operations  
- Improve booking and return efficiency  
- Automate invoice generation  
- Prevent duplicate or overlapping bookings  
- Maintain data consistency across branches  
- Support scalable rental operations  

---

# 🏗️ System Architecture

The database system was designed using:

- EER Modelling  
- Relational Schema Design  
- BCNF Normalization  
- Foreign Key Relationships  
- Business Rule Enforcement  

---

# 🧠 Core Modules

| Module | Description |
|---|---|
| 👤 Customer Management | Customer profiles and loyalty tracking |
| 🏢 Branch Management | Multi-branch rental operations |
| 🚘 Vehicle Management | Vehicle inventory and category handling |
| 📅 Booking System | Reservation and scheduling management |
| 🛠️ Service Management | Extra services and maintenance tracking |
| 💳 Invoice Processing | Automated billing and payment calculation |
| 🔄 Return Processing | Return validation and penalty calculation |

---

# ⚙️ Technologies Used

- SQL Server  
- T-SQL  
- UML / EER Modelling  
- Relational Database Design  

---

# 🗄️ Database Design

<img width="963" height="662" alt="image" src="https://github.com/user-attachments/assets/5a1739a7-53c7-44ce-9cb1-07d01ac45e5d" />


## Main Entities

- Customer  
- LoyaltyTier  
- Branch  
- Employee  
- Vehicle  
- VehicleCategory  
- Service  
- Booking  
- Invoice  
- ReturnDetails  

---

# 🔄 System Workflow

## 🚘 Booking Workflow

1. Customer selects vehicle  
2. Booking dates validated  
3. Vehicle availability checked  
4. Extra services assigned  
5. Booking created successfully  

---

## 🔄 Return Workflow

1. Vehicle returned  
2. Damage and penalties calculated  
3. Discounts applied  
4. Invoice generated automatically  
5. Booking status updated  

---

# 🧪 SQL Features Implemented

## ✅ Constraints & Validation
- Primary & Foreign Keys  
- Unique Constraints  
- Check Constraints  
- Referential Integrity  

---

## ✅ Stored Procedures
- Vehicle Booking Procedure  
- Return Finalization Procedure  
- Automated Validation Logic  
- Error Handling & Transactions  

---

## ✅ Business Logic
- Prevent overlapping bookings  
- Validate customer eligibility  
- Apply loyalty discounts  
- Calculate late return penalties  
- Validate pricing periods  

---

# 📊 Key Functionalities

### 🚘 Vehicle Reservation
- Search available vehicles  
- Assign rental categories  
- Validate booking periods  

### 💳 Invoice Generation
- Base rental calculations  
- Additional service charges  
- Damage penalties  
- Loyalty discounts  

### 👥 Customer Management
- Loyalty tracking  
- Rental history  
- Customer validation  

---

# 📈 Business Impact

The system improves operational efficiency by:

- Reducing manual booking errors  
- Automating return and billing processes  
- Improving customer management  
- Enhancing data consistency  
- Supporting scalable branch operations  

---

# 🔒 Data Integrity & Reliability

The database was designed to ensure:

- Consistent booking operations  
- Transaction-safe processing  
- Reduced redundancy through normalization  
- Accurate invoice calculations  
- Reliable relational integrity  

---

# 🚀 Future Improvements

- Web-based booking platform  
- Real-time vehicle availability system  
- Cloud database deployment  
- Authentication & role-based access  
- Reporting and analytics dashboard  
- Mobile booking integration  

---

# 📌 Example SQL Capabilities

### Booking Validation
```sql
SELECT *
FROM Booking
WHERE VehicleID = @VehicleID
AND (
    @StartDate BETWEEN StartDate AND EndDate
    OR
    @EndDate BETWEEN StartDate AND EndDate
);
```

### Loyalty Discount Logic
```sql
CASE
    WHEN LoyaltyTier = 'Gold' THEN 15
    WHEN LoyaltyTier = 'Silver' THEN 10
    ELSE 0
END
```

---

# 💼 Skills Demonstrated

- Database Design  
- SQL Development  
- Stored Procedure Development  
- Business Rule Automation  
- Relational Modelling  
- Database Testing & Validation  

---

# ⭐ Conclusion

GlobalCarHire demonstrates a complete enterprise-style relational database solution for vehicle rental management. The project combines scalable database architecture, SQL automation, business process optimization, and transaction-safe operations to support real-world rental workflows efficiently.

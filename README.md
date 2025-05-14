Project Title
Clinic Booking System - MySQL Database Implementation

Description

This project provides a comprehensive relational database design for a Clinic Booking System using MySQL. The database supports all core operations of a medical clinic including:

Patient registration and management


Doctor scheduling and availability tracking


Appointment booking with conflict detection


Medical records and prescription management


Billing and payment processing


User access control and audit logging


The database is fully normalized with proper constraints (PK, FK, NOT NULL, UNIQUE) and implements various relationships (1-1, 1-M, M-M) to ensure data integrity.

Features

Patient information management


Doctor profiles with specialization tracking


Clinic location management


Appointment scheduling with status tracking


Medical record keeping with diagnosis and treatment notes


Prescription management


Billing and invoice generation


User authentication and authorization


Comprehensive audit logging


Setup Instructions

Prerequisites

MySQL Server (version 8.0 or higher recommended)


MySQL Workbench or similar database management tool

Installation
Clone or download this repository

Open MySQL client and create a new database:

CREATE DATABASE ClinicBookingSystem;
USE ClinicBookingSystem;

Execute the SQL script to create all tables, relationships, and sample data:


Copy the entire SQL script from the provided file


Execute it in your MySQL client.

Database Schema (ERD)

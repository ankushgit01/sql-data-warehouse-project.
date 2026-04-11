/*
============================================================
Create Database and Schemas
============================================================

Script Purpose:
    This script creates a new database named 'DataWarehouse' after checking if it already exists.
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas
    within the database: 'bronze', 'silver', and 'gold'.

WARNING:
    Running this script will drop the entire 'DataWarehouse' database if it exists.
    All data in the database will be permanently deleted. Proceed with caution
    and ensure you have proper backups before running this script.
*/

-- =============================================
-- 📊 Data Warehouse Database Setup
-- =============================================

-- Drop database if it exists
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    DROP DATABASE DataWarehouse;
END;
GO

-- Create Database
CREATE DATABASE DataWarehouse;
GO

-- Use Database
USE DataWarehouse;
GO

-- =============================================
-- 🏗️ Schema Architecture (Medallion Architecture)
-- =============================================

-- 🔸 Bronze Layer (Raw Data)
CREATE SCHEMA bronze;
GO

-- 🔹 Silver Layer (Cleaned & Transformed Data)
CREATE SCHEMA silver;
GO

-- 🟡 Gold Layer (Business-Level Data)
CREATE SCHEMA gold;
GO

-- =============================================
-- ✅ Setup Completed Successfully
-- =============================================

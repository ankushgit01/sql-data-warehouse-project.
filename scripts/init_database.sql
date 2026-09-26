/*
============================================================
Initialize Data Warehouse
============================================================
Target database: MySQL 8.0+
Architecture: Bronze -> Silver -> Gold

WARNING:
    This script is destructive. It drops and recreates the
    DataWarehouse database and all of its objects.
============================================================
*/

DROP DATABASE IF EXISTS DataWarehouse;

CREATE DATABASE DataWarehouse
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

USE DataWarehouse;

CREATE SCHEMA bronze;
CREATE SCHEMA silver;
CREATE SCHEMA gold;

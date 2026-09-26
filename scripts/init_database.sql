/*
============================================================
Initialize Data Warehouse Layers
============================================================
Target: MySQL 8.0+

MySQL does not support nested schemas inside a database.
This project therefore uses three databases as layer namespaces:
    bronze = raw ingestion
    silver = cleaned/transformed data
    gold   = analytics-ready views

WARNING:
    This script is destructive. It drops and recreates the three
    layer databases and all objects inside them.
============================================================
*/

DROP DATABASE IF EXISTS gold;
DROP DATABASE IF EXISTS silver;
DROP DATABASE IF EXISTS bronze;

CREATE DATABASE bronze
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

CREATE DATABASE silver
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

CREATE DATABASE gold
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'Datawarehouse' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas 
    within the database: 'bronze', 'silver', and 'gold'.
	
WARNING:
    Running this script will drop the entire 'Datawarehouse' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/



USE master;
go

-- Drop and recreate the 'Datawarehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'Datawarehouse')
BEGIN
    ALTER DATABASE Datawarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Datawarehouse;
END;
GO

--Create the 'Datawarehouse' database
CREATE DATABASE Datawarehouse;
go

USE Datawarehouse;
go

--Create Scheamas
CREATE SCHEMA bronze;
go
CREATE SCHEMA silver;
go
CREATE SCHEMA gold;
go

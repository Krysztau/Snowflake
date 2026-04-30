DEV Deployment
Important



-- ------------------------------------------------------------
-- Name: RBAC DEV - FitFlop Environment Grant Script
--
-- Purpose: Provides a script to create the necessary
--          privileges to manage an environment including a
--          database and some basic schemas.
--
-- ------------------------------------------------------------------------
-- To customise this script replace the following:
--
--      DEV - With the prefix for your environment
--      SOURCE - Name of source schema
--      CONFORMED - Name of conformed schema
--      DOMAIN - Name of domain schema (datamarts)
--      PRESENTATION - Name of presentation schema
--      The functional roles as needed.
--
-- ------------------------------------------------------------------------
--
-- Note: This script delivers a single DEV environment
-- Consisting of:
--
-- 1. Environment Management Roles:
--
-- DEV_ROLE_ADMIN - Role Admin for DEV
-- DEV_SYS_ADMIN  - System Admin for DEV
--
-- 2. Functional Roles (Example roles only):
--
-- DEV_data_analyst
-- DEV_devops
--
-- 3. DEVuction database and schemas
--
-- Database:   DEV_DWH
-- Schema: source, conformed, domain, presentation
--
-- 4. DEVuction Access Roles (Which control access to data)
--
-- DEV_<schema_name>_sr - Schema level Read access to all objects
-- DEV_<schema_name>_srw - Schema level Read Write access to all objects
-- DEV_<schema_name>_sfull - Schema level Read Write Control (full) access to all objects
--
--
-- Recommend:  Amend this script as follows:
--
-- a) Replace the Functional Roles with the actual roles needed
-- b) Create a set of Access Roles for each schemas as needed
-- c) Generate the grants from Schemas to Access Roles
-- d) Repeat the process replacing DEV with TEST and DEV as needed.
--
--
-- Copyright (c).  Snowflake 2023.  
-- ------------------------------------------------------------
-- Change History
-- Author        Date          Description
-- ------------------------------------------------------------
-- Alessandro Dallatomasina     09-Apr-2023   Initial Version (just DEV_DWH)
--
-- ------------------------------------------------------------


set env_manager_user=current_user();                -- User ID of the environment manager USER

-- ------------------------------------------------------------
-- Create environment Manager Roles
-- ------------------------------------------------------------
use role useradmin;
create or replace role DEV_role_admin;
create or replace role DEV_sys_admin;

-- ------------------------------------------------------------
-- Grant environment manager roles to current user
-- ------------------------------------------------------------
use role useradmin;
grant role DEV_role_admin to user identifier($env_manager_user);
grant role DEV_sys_admin  to user identifier($env_manager_user);

-- ------------------------------------------------------------
-- Grant Additional Privileges
-- ------------------------------------------------------------
use role sysadmin;
grant create database on account to role DEV_sys_admin;

use role useradmin;
grant create role on account to role DEV_role_admin;

-- ------------------------------------------------------------
-- Grant to SYSADMIN
-- ------------------------------------------------------------
use role useradmin;

grant role DEV_sys_admin to role SYSADMIN;

-- ------------------------------------------------------------
-- Create Functional Roles and set ownership
-- WARNING:  Need to create/replace role and THEN reassign ownership to ensure the script is rerunnable!!
-- DO NOT FIX THE NEXT FEW LINES ! You will regret it, when "create or replace role DEV_data_analyst"
-- fails because DEV_ROLE_ADMIN cannot drop a role it does not own!!
-- ------------------------------------------------------------
use role useradmin;

create or replace role DEV_data_analyst;
create or replace role DEV_devops;
CREATE or replace ROLE DEV_taskadmin;

grant ownership on role DEV_data_analyst       to role DEV_role_admin;
grant ownership on role DEV_devops             to role DEV_role_admin;
grant ownership on role DEV_taskadmin          to role DEV_role_admin;

-- ------------------------------------------------------------
-- Grant Functional Roles to <ENV_NAME>_SYS_ADMIN - to manage these
-- ------------------------------------------------------------
use role DEV_role_admin;

grant role DEV_data_analyst to role DEV_sys_admin;
grant role DEV_devops to role DEV_sys_admin;
GRANT ROLE DEV_taskadmin TO ROLE DEV_DevOps;


-- ------------------------------------------------------------
-- Create Database
-- ------------------------------------------------------------
use role DEV_sys_admin;
create database if not exists  DEV_DWH;


-- *********************************************************************************************
-- The following section should be repeated for each schema -> SOURCE
-- *********************************************************************************************

-- Warning: Schemas MUST be created with Managed Access to support future grants without using SECURITYADMIN
create schema if not exists    SOURCE    with managed access;

-- ------------------------------------------------------------
-- Create Access Roles and set ownership
-- ------------------------------------------------------------
use role useradmin;

create or replace role DEV_SOURCE_SR;
create or replace role DEV_SOURCE_SRW;
create or replace role DEV_SOURCE_SFULL;

grant ownership on role DEV_SOURCE_sr         to role DEV_role_admin;
grant ownership on role DEV_SOURCE_srw        to role DEV_role_admin;
grant ownership on role DEV_SOURCE_sfull      to role DEV_role_admin;

-- ------------------------------------------------------------
-- Grant Access Roles to <_NAME>_SYS_ADMIN - to manage these
-- ------------------------------------------------------------
use role DEV_role_admin;

grant role DEV_SOURCE_sr to role DEV_sys_admin;
grant role DEV_SOURCE_srw to role DEV_sys_admin;
grant role DEV_SOURCE_sfull to role DEV_sys_admin;




-- ------------------------------------------------------------
-- Grants from Schema/Database to Access Roles
-- ------------------------------------------------------------  
use role DEV_sys_admin;

-- Database usage
grant usage on database DEV_DWH to role DEV_SOURCE_SR;
grant usage on database DEV_DWH to role DEV_SOURCE_SRW;
grant usage on database DEV_DWH to role DEV_SOURCE_SFULL;

-- Schema usage
grant usage on schema SOURCE to role DEV_SOURCE_SR;
grant usage on schema SOURCE to role DEV_SOURCE_SRW;
grant all privileges on schema SOURCE to role DEV_SOURCE_SFULL;


-- Current Grants (If any objects exist, these will perform grants to existing objects)
-- Read
grant select on all tables in               schema SOURCE to role DEV_SOURCE_SR;
grant select on all views  in               schema SOURCE to role DEV_SOURCE_SR;
grant usage, read on all stages in          schema SOURCE to role DEV_SOURCE_SR;
grant usage on all file formats in          schema SOURCE to role DEV_SOURCE_SR;
grant select on all streams in              schema SOURCE to role DEV_SOURCE_SR;
grant usage on all functions in             schema SOURCE to role DEV_SOURCE_SR;

-- Read/Write
grant select, insert, update, delete, references
      on all tables in                      schema SOURCE to role DEV_SOURCE_SRW;
grant select on all views  in               schema SOURCE to role DEV_SOURCE_SRW;
grant usage, read, write on all stages in   schema SOURCE to role DEV_SOURCE_SRW;
grant usage on all file formats in          schema SOURCE to role DEV_SOURCE_SRW;

grant select on all streams in              schema SOURCE to role DEV_SOURCE_SRW;
grant usage on all procedures in            schema SOURCE to role DEV_SOURCE_SRW;
grant usage on all functions in             schema SOURCE to role DEV_SOURCE_SRW;
grant usage on all sequences in             schema SOURCE to role DEV_SOURCE_SRW;
grant monitor, operate on all tasks in      schema SOURCE to role DEV_SOURCE_SRW;

-- Full Access.
-- Note:  Need to shift ownership to SFULL so if a functional role creates a table SFULL owns it
-- This is needed to ensure different functional roles don't own the tables.
-- IE. Multiple functional roles can have full access to the table, but there must be a common owner

grant ownership on all tables in            schema SOURCE to role DEV_SOURCE_SFULL;
grant ownership on all views  in            schema SOURCE to role DEV_SOURCE_SFULL;
grant ownership on all stages in            schema SOURCE to role DEV_SOURCE_SFULL;
grant ownership on all file formats in      schema SOURCE to role DEV_SOURCE_SFULL;
grant ownership on all streams in           schema SOURCE to role DEV_SOURCE_SFULL;
grant ownership on all procedures in        schema SOURCE to role DEV_SOURCE_SFULL;
grant ownership on all functions in         schema SOURCE to role DEV_SOURCE_SFULL;
grant ownership on all sequences in         schema SOURCE to role DEV_SOURCE_SFULL;


-- Future Grants (A repeat of the above for FUTURE)
-- Read
grant select on future tables in schema SOURCE to role DEV_SOURCE_SR;
grant select on future views  in schema SOURCE to role DEV_SOURCE_SR;
grant usage, read on future stages in schema SOURCE to role DEV_SOURCE_SR;
grant usage on future file formats in schema SOURCE to role DEV_SOURCE_SR;
grant select on future streams in schema SOURCE to role DEV_SOURCE_SR;
grant usage on future procedures in schema SOURCE to role DEV_SOURCE_SR;
grant usage on future functions in schema SOURCE to role DEV_SOURCE_SR;

-- Read/Write
grant select, insert, update, delete, references
on future tables in schema SOURCE to role DEV_SOURCE_SRW;
grant select on future views  in schema SOURCE to role DEV_SOURCE_SRW;
grant usage, read, write on future stages in schema SOURCE to role DEV_SOURCE_SRW;
grant usage on future file formats in schema SOURCE to role DEV_SOURCE_SRW;
grant select on future streams in schema SOURCE to role DEV_SOURCE_SRW;
grant usage on future procedures in schema SOURCE to role DEV_SOURCE_SRW;
grant usage on future functions in schema SOURCE to role DEV_SOURCE_SRW;
grant usage on future sequences in schema SOURCE to role DEV_SOURCE_SRW;
grant monitor, operate on future tasks in schema SOURCE to role DEV_SOURCE_SRW;

-- Full
-- Note:  Need to shift ownership to SFULL so if a functional role creates a table SFULL owns it
-- This is needed to ensure different functional roles don't own the tables.
-- IE. Multiple functional roles can have full access to the table, but there must be a common owner
grant ownership on future tables in schema SOURCE to role DEV_SOURCE_SFULL;
grant ownership on future views  in schema SOURCE to role DEV_SOURCE_SFULL;
grant ownership on future stages in schema SOURCE to role DEV_SOURCE_SFULL;
grant ownership on future file formats in schema SOURCE to role DEV_SOURCE_SFULL;
grant ownership on future streams in schema SOURCE to role DEV_SOURCE_SFULL;
grant ownership on future procedures in schema SOURCE to role DEV_SOURCE_SFULL;
grant ownership on future functions in schema SOURCE to role DEV_SOURCE_SFULL;
grant ownership on future sequences in schema SOURCE to role DEV_SOURCE_SFULL;
grant ownership on future tasks in schema SOURCE to role DEV_DevOps;

-- *********************************************************************************************
-- The section above should be repeated for each schema -> SOURCE
-- *********************************************************************************************


-- *********************************************************************************************
-- The following section should be repeated for each schema -> CONFORMED
-- *********************************************************************************************

-- Warning: Schemas MUST be created with Managed Access to support future grants without using SECURITYADMIN
create schema if not exists    CONFORMED    with managed access;

-- ------------------------------------------------------------
-- Create Access Roles and set ownership
-- ------------------------------------------------------------
use role useradmin;

create or replace role DEV_CONFORMED_SR;
create or replace role DEV_CONFORMED_SRW;
create or replace role DEV_CONFORMED_SFULL;

grant ownership on role DEV_CONFORMED_sr         to role DEV_role_admin;
grant ownership on role DEV_CONFORMED_srw        to role DEV_role_admin;
grant ownership on role DEV_CONFORMED_sfull      to role DEV_role_admin;

-- ------------------------------------------------------------
-- Grant Access Roles to <ENV_NAME>_SYS_ADMIN - to manage these
-- ------------------------------------------------------------
use role DEV_role_admin;

grant role DEV_CONFORMED_sr to role DEV_sys_admin;
grant role DEV_CONFORMED_srw to role DEV_sys_admin;
grant role DEV_CONFORMED_sfull to role DEV_sys_admin;




-- ------------------------------------------------------------
-- Grants from Schema/Database to Access Roles
-- ------------------------------------------------------------  
use role DEV_sys_admin;

-- Database usage
grant usage on database DEV_DWH to role DEV_CONFORMED_SR;
grant usage on database DEV_DWH to role DEV_CONFORMED_SRW;
grant usage on database DEV_DWH to role DEV_CONFORMED_SFULL;

-- Schema usage
grant usage on schema CONFORMED to role DEV_CONFORMED_SR;
grant usage on schema CONFORMED to role DEV_CONFORMED_SRW;
grant all privileges on schema CONFORMED to role DEV_CONFORMED_SFULL;


-- Current Grants (If any objects exist, these will perform grants to existing objects)
-- Read
grant select on all tables in               schema CONFORMED to role DEV_CONFORMED_SR;
grant select on all views  in               schema CONFORMED to role DEV_CONFORMED_SR;
grant usage, read on all stages in          schema CONFORMED to role DEV_CONFORMED_SR;
grant usage on all file formats in          schema CONFORMED to role DEV_CONFORMED_SR;
grant select on all streams in              schema CONFORMED to role DEV_CONFORMED_SR;
grant usage on all functions in             schema CONFORMED to role DEV_CONFORMED_SR;

-- Read/Write
grant select, insert, update, delete, references
      on all tables in                      schema CONFORMED to role DEV_CONFORMED_SRW;
grant select on all views  in               schema CONFORMED to role DEV_CONFORMED_SRW;
grant usage, read, write on all stages in   schema CONFORMED to role DEV_CONFORMED_SRW;
grant usage on all file formats in          schema CONFORMED to role DEV_CONFORMED_SRW;

grant select on all streams in              schema CONFORMED to role DEV_CONFORMED_SRW;
grant usage on all procedures in            schema CONFORMED to role DEV_CONFORMED_SRW;
grant usage on all functions in             schema CONFORMED to role DEV_CONFORMED_SRW;
grant usage on all sequences in             schema CONFORMED to role DEV_CONFORMED_SRW;
grant monitor, operate on all tasks in      schema CONFORMED to role DEV_CONFORMED_SRW;

-- Full Access.
-- Note:  Need to shift ownership to SFULL so if a functional role creates a table SFULL owns it
-- This is needed to ensure different functional roles don't own the tables.
-- IE. Multiple functional roles can have full access to the table, but there must be a common owner

grant ownership on all tables in            schema CONFORMED to role DEV_CONFORMED_SFULL;
grant ownership on all views  in            schema CONFORMED to role DEV_CONFORMED_SFULL;
grant ownership on all stages in            schema CONFORMED to role DEV_CONFORMED_SFULL;
grant ownership on all file formats in      schema CONFORMED to role DEV_CONFORMED_SFULL;
grant ownership on all streams in           schema CONFORMED to role DEV_CONFORMED_SFULL;
grant ownership on all procedures in        schema CONFORMED to role DEV_CONFORMED_SFULL;
grant ownership on all functions in         schema CONFORMED to role DEV_CONFORMED_SFULL;
grant ownership on all sequences in         schema CONFORMED to role DEV_CONFORMED_SFULL;


-- Future Grants (A repeat of the above for FUTURE)
-- Read
grant select on future tables in schema CONFORMED to role DEV_CONFORMED_SR;
grant select on future views  in schema CONFORMED to role DEV_CONFORMED_SR;
grant usage, read on future stages in schema CONFORMED to role DEV_CONFORMED_SR;
grant usage on future file formats in schema CONFORMED to role DEV_CONFORMED_SR;
grant select on future streams in schema CONFORMED to role DEV_CONFORMED_SR;
grant usage on future procedures in schema CONFORMED to role DEV_CONFORMED_SR;
grant usage on future functions in schema CONFORMED to role DEV_CONFORMED_SR;

-- Read/Write
grant select, insert, update, delete, references
on future tables in schema CONFORMED to role DEV_CONFORMED_SRW;
grant select on future views  in schema CONFORMED to role DEV_CONFORMED_SRW;
grant usage, read, write on future stages in schema CONFORMED to role DEV_CONFORMED_SRW;
grant usage on future file formats in schema CONFORMED to role DEV_CONFORMED_SRW;
grant select on future streams in schema CONFORMED to role DEV_CONFORMED_SRW;
grant usage on future procedures in schema CONFORMED to role DEV_CONFORMED_SRW;
grant usage on future functions in schema CONFORMED to role DEV_CONFORMED_SRW;
grant usage on future sequences in schema CONFORMED to role DEV_CONFORMED_SRW;
grant monitor, operate on future tasks in schema CONFORMED to role DEV_CONFORMED_SRW;

-- Full
-- Note:  Need to shift ownership to SFULL so if a functional role creates a table SFULL owns it
-- This is needed to ensure different functional roles don't own the tables.
-- IE. Multiple functional roles can have full access to the table, but there must be a common owner
grant ownership on future tables in schema CONFORMED to role DEV_CONFORMED_SFULL;
grant ownership on future views  in schema CONFORMED to role DEV_CONFORMED_SFULL;
grant ownership on future stages in schema CONFORMED to role DEV_CONFORMED_SFULL;
grant ownership on future file formats in schema CONFORMED to role DEV_CONFORMED_SFULL;
grant ownership on future streams in schema CONFORMED to role DEV_CONFORMED_SFULL;
grant ownership on future procedures in schema CONFORMED to role DEV_CONFORMED_SFULL;
grant ownership on future functions in schema CONFORMED to role DEV_CONFORMED_SFULL;
grant ownership on future sequences in schema CONFORMED to role DEV_CONFORMED_SFULL;
grant ownership on future tasks in schema CONFORMED to role DEV_DevOps;

-- *********************************************************************************************
-- The section above should be repeated for each schema -> CONFORMED
-- *********************************************************************************************

-- *********************************************************************************************
-- The following section should be repeated for each schema -> DOMAIN
-- *********************************************************************************************

-- Warning: Schemas MUST be created with Managed Access to support future grants without using SECURITYADMIN
create schema if not exists    DOMAIN    with managed access;

-- ------------------------------------------------------------
-- Create Access Roles and set ownership
-- ------------------------------------------------------------
use role useradmin;

create or replace role DEV_DOMAIN_SR;
create or replace role DEV_DOMAIN_SRW;
create or replace role DEV_DOMAIN_SFULL;

grant ownership on role DEV_DOMAIN_sr         to role DEV_role_admin;
grant ownership on role DEV_DOMAIN_srw        to role DEV_role_admin;
grant ownership on role DEV_DOMAIN_sfull      to role DEV_role_admin;

-- ------------------------------------------------------------
-- Grant Access Roles to <ENV_NAME>_SYS_ADMIN - to manage these
-- ------------------------------------------------------------
use role DEV_role_admin;

grant role DEV_DOMAIN_sr to role DEV_sys_admin;
grant role DEV_DOMAIN_srw to role DEV_sys_admin;
grant role DEV_DOMAIN_sfull to role DEV_sys_admin;




-- ------------------------------------------------------------
-- Grants from Schema/Database to Access Roles
-- ------------------------------------------------------------  
use role DEV_sys_admin;

-- Database usage
grant usage on database DEV_DWH to role DEV_DOMAIN_SR;
grant usage on database DEV_DWH to role DEV_DOMAIN_SRW;
grant usage on database DEV_DWH to role DEV_DOMAIN_SFULL;

-- Schema usage
grant usage on schema DOMAIN to role DEV_DOMAIN_SR;
grant usage on schema DOMAIN to role DEV_DOMAIN_SRW;
grant all privileges on schema DOMAIN to role DEV_DOMAIN_SFULL;


-- Current Grants (If any objects exist, these will perform grants to existing objects)
-- Read
grant select on all tables in               schema DOMAIN to role DEV_DOMAIN_SR;
grant select on all views  in               schema DOMAIN to role DEV_DOMAIN_SR;
grant usage, read on all stages in          schema DOMAIN to role DEV_DOMAIN_SR;
grant usage on all file formats in          schema DOMAIN to role DEV_DOMAIN_SR;
grant select on all streams in              schema DOMAIN to role DEV_DOMAIN_SR;
grant usage on all functions in             schema DOMAIN to role DEV_DOMAIN_SR;

-- Read/Write
grant select, insert, update, delete, references
      on all tables in                      schema DOMAIN to role DEV_DOMAIN_SRW;
grant select on all views  in               schema DOMAIN to role DEV_DOMAIN_SRW;
grant usage, read, write on all stages in   schema DOMAIN to role DEV_DOMAIN_SRW;
grant usage on all file formats in          schema DOMAIN to role DEV_DOMAIN_SRW;

grant select on all streams in              schema DOMAIN to role DEV_DOMAIN_SRW;
grant usage on all procedures in            schema DOMAIN to role DEV_DOMAIN_SRW;
grant usage on all functions in             schema DOMAIN to role DEV_DOMAIN_SRW;
grant usage on all sequences in             schema DOMAIN to role DEV_DOMAIN_SRW;
grant monitor, operate on all tasks in      schema DOMAIN to role DEV_DOMAIN_SRW;

-- Full Access.
-- Note:  Need to shift ownership to SFULL so if a functional role creates a table SFULL owns it
-- This is needed to ensure different functional roles don't own the tables.
-- IE. Multiple functional roles can have full access to the table, but there must be a common owner

grant ownership on all tables in            schema DOMAIN to role DEV_DOMAIN_SFULL;
grant ownership on all views  in            schema DOMAIN to role DEV_DOMAIN_SFULL;
grant ownership on all stages in            schema DOMAIN to role DEV_DOMAIN_SFULL;
grant ownership on all file formats in      schema DOMAIN to role DEV_DOMAIN_SFULL;
grant ownership on all streams in           schema DOMAIN to role DEV_DOMAIN_SFULL;
grant ownership on all procedures in        schema DOMAIN to role DEV_DOMAIN_SFULL;
grant ownership on all functions in         schema DOMAIN to role DEV_DOMAIN_SFULL;
grant ownership on all sequences in         schema DOMAIN to role DEV_DOMAIN_SFULL;


-- Future Grants (A repeat of the above for FUTURE)
-- Read
grant select on future tables in schema DOMAIN to role DEV_DOMAIN_SR;
grant select on future views  in schema DOMAIN to role DEV_DOMAIN_SR;
grant usage, read on future stages in schema DOMAIN to role DEV_DOMAIN_SR;
grant usage on future file formats in schema DOMAIN to role DEV_DOMAIN_SR;
grant select on future streams in schema DOMAIN to role DEV_DOMAIN_SR;
grant usage on future procedures in schema DOMAIN to role DEV_DOMAIN_SR;
grant usage on future functions in schema DOMAIN to role DEV_DOMAIN_SR;

-- Read/Write
grant select, insert, update, delete, references
on future tables in schema DOMAIN to role DEV_DOMAIN_SRW;
grant select on future views  in schema DOMAIN to role DEV_DOMAIN_SRW;
grant usage, read, write on future stages in schema DOMAIN to role DEV_DOMAIN_SRW;
grant usage on future file formats in schema DOMAIN to role DEV_DOMAIN_SRW;
grant select on future streams in schema DOMAIN to role DEV_DOMAIN_SRW;
grant usage on future procedures in schema DOMAIN to role DEV_DOMAIN_SRW;
grant usage on future functions in schema DOMAIN to role DEV_DOMAIN_SRW;
grant usage on future sequences in schema DOMAIN to role DEV_DOMAIN_SRW;
grant monitor, operate on future tasks in schema DOMAIN to role DEV_DOMAIN_SRW;

-- Full
-- Note:  Need to shift ownership to SFULL so if a functional role creates a table SFULL owns it
-- This is needed to ensure different functional roles don't own the tables.
-- IE. Multiple functional roles can have full access to the table, but there must be a common owner
grant ownership on future tables in schema DOMAIN to role DEV_DOMAIN_SFULL;
grant ownership on future views  in schema DOMAIN to role DEV_DOMAIN_SFULL;
grant ownership on future stages in schema DOMAIN to role DEV_DOMAIN_SFULL;
grant ownership on future file formats in schema DOMAIN to role DEV_DOMAIN_SFULL;
grant ownership on future streams in schema DOMAIN to role DEV_DOMAIN_SFULL;
grant ownership on future procedures in schema DOMAIN to role DEV_DOMAIN_SFULL;
grant ownership on future functions in schema DOMAIN to role DEV_DOMAIN_SFULL;
grant ownership on future sequences in schema DOMAIN to role DEV_DOMAIN_SFULL;
grant ownership on future tasks in schema DOMAIN to role DEV_DevOps;

-- *********************************************************************************************
-- The section above should be repeated for each schema -> DOMAIN
-- *********************************************************************************************

-- *********************************************************************************************
-- The following section should be repeated for each schema -> PRESENTATION
-- *********************************************************************************************

-- Warning: Schemas MUST be created with Managed Access to support future grants without using SECURITYADMIN
create schema if not exists    PRESENTATION    with managed access;

-- ------------------------------------------------------------
-- Create Access Roles and set ownership
-- ------------------------------------------------------------
use role useradmin;

create or replace role DEV_PRESENTATION_SR;
create or replace role DEV_PRESENTATION_SRW;
create or replace role DEV_PRESENTATION_SFULL;

grant ownership on role DEV_PRESENTATION_sr         to role DEV_role_admin;
grant ownership on role DEV_PRESENTATION_srw        to role DEV_role_admin;
grant ownership on role DEV_PRESENTATION_sfull      to role DEV_role_admin;

-- ------------------------------------------------------------
-- Grant Access Roles to <ENV_NAME>_SYS_ADMIN - to manage these
-- ------------------------------------------------------------
use role DEV_role_admin;

grant role DEV_PRESENTATION_sr to role DEV_sys_admin;
grant role DEV_PRESENTATION_srw to role DEV_sys_admin;
grant role DEV_PRESENTATION_sfull to role DEV_sys_admin;




-- ------------------------------------------------------------
-- Grants from Schema/Database to Access Roles
-- ------------------------------------------------------------  
use role DEV_sys_admin;

-- Database usage
grant usage on database DEV_DWH to role DEV_PRESENTATION_SR;
grant usage on database DEV_DWH to role DEV_PRESENTATION_SRW;
grant usage on database DEV_DWH to role DEV_PRESENTATION_SFULL;

-- Schema usage
grant usage on schema PRESENTATION to role DEV_PRESENTATION_SR;
grant usage on schema PRESENTATION to role DEV_PRESENTATION_SRW;
grant all privileges on schema PRESENTATION to role DEV_PRESENTATION_SFULL;


-- Current Grants (If any objects exist, these will perform grants to existing objects)
-- Read
grant select on all tables in               schema PRESENTATION to role DEV_PRESENTATION_SR;
grant select on all views  in               schema PRESENTATION to role DEV_PRESENTATION_SR;
grant usage, read on all stages in          schema PRESENTATION to role DEV_PRESENTATION_SR;
grant usage on all file formats in          schema PRESENTATION to role DEV_PRESENTATION_SR;
grant select on all streams in              schema PRESENTATION to role DEV_PRESENTATION_SR;
grant usage on all functions in             schema PRESENTATION to role DEV_PRESENTATION_SR;

-- Read/Write
grant select, insert, update, delete, references
      on all tables in                      schema PRESENTATION to role DEV_PRESENTATION_SRW;
grant select on all views  in               schema PRESENTATION to role DEV_PRESENTATION_SRW;
grant usage, read, write on all stages in   schema PRESENTATION to role DEV_PRESENTATION_SRW;
grant usage on all file formats in          schema PRESENTATION to role DEV_PRESENTATION_SRW;

grant select on all streams in              schema PRESENTATION to role DEV_PRESENTATION_SRW;
grant usage on all procedures in            schema PRESENTATION to role DEV_PRESENTATION_SRW;
grant usage on all functions in             schema PRESENTATION to role DEV_PRESENTATION_SRW;
grant usage on all sequences in             schema PRESENTATION to role DEV_PRESENTATION_SRW;
grant monitor, operate on all tasks in      schema PRESENTATION to role DEV_PRESENTATION_SRW;

-- Full Access.
-- Note:  Need to shift ownership to SFULL so if a functional role creates a table SFULL owns it
-- This is needed to ensure different functional roles don't own the tables.
-- IE. Multiple functional roles can have full access to the table, but there must be a common owner

grant ownership on all tables in            schema PRESENTATION to role DEV_PRESENTATION_SFULL;
grant ownership on all views  in            schema PRESENTATION to role DEV_PRESENTATION_SFULL;
grant ownership on all stages in            schema PRESENTATION to role DEV_PRESENTATION_SFULL;
grant ownership on all file formats in      schema PRESENTATION to role DEV_PRESENTATION_SFULL;
grant ownership on all streams in           schema PRESENTATION to role DEV_PRESENTATION_SFULL;
grant ownership on all procedures in        schema PRESENTATION to role DEV_PRESENTATION_SFULL;
grant ownership on all functions in         schema PRESENTATION to role DEV_PRESENTATION_SFULL;
grant ownership on all sequences in         schema PRESENTATION to role DEV_PRESENTATION_SFULL;


-- Future Grants (A repeat of the above for FUTURE)
-- Read
grant select on future tables in schema PRESENTATION to role DEV_PRESENTATION_SR;
grant select on future views  in schema PRESENTATION to role DEV_PRESENTATION_SR;
grant usage, read on future stages in schema PRESENTATION to role DEV_PRESENTATION_SR;
grant usage on future file formats in schema PRESENTATION to role DEV_PRESENTATION_SR;
grant select on future streams in schema PRESENTATION to role DEV_PRESENTATION_SR;
grant usage on future procedures in schema PRESENTATION to role DEV_PRESENTATION_SR;
grant usage on future functions in schema PRESENTATION to role DEV_PRESENTATION_SR;

-- Read/Write
grant select, insert, update, delete, references
on future tables in schema PRESENTATION to role DEV_PRESENTATION_SRW;
grant select on future views  in schema PRESENTATION to role DEV_PRESENTATION_SRW;
grant usage, read, write on future stages in schema PRESENTATION to role DEV_PRESENTATION_SRW;
grant usage on future file formats in schema PRESENTATION to role DEV_PRESENTATION_SRW;
grant select on future streams in schema PRESENTATION to role DEV_PRESENTATION_SRW;
grant usage on future procedures in schema PRESENTATION to role DEV_PRESENTATION_SRW;
grant usage on future functions in schema PRESENTATION to role DEV_PRESENTATION_SRW;
grant usage on future sequences in schema PRESENTATION to role DEV_PRESENTATION_SRW;
grant monitor, operate on future tasks in schema PRESENTATION to role DEV_PRESENTATION_SRW;

-- Full
-- Note:  Need to shift ownership to SFULL so if a functional role creates a table SFULL owns it
-- This is needed to ensure different functional roles don't own the tables.
-- IE. Multiple functional roles can have full access to the table, but there must be a common owner
grant ownership on future tables in schema PRESENTATION to role DEV_PRESENTATION_SFULL;
grant ownership on future views  in schema PRESENTATION to role DEV_PRESENTATION_SFULL;
grant ownership on future stages in schema PRESENTATION to role DEV_PRESENTATION_SFULL;
grant ownership on future file formats in schema PRESENTATION to role DEV_PRESENTATION_SFULL;
grant ownership on future streams in schema PRESENTATION to role DEV_PRESENTATION_SFULL;
grant ownership on future procedures in schema PRESENTATION to role DEV_PRESENTATION_SFULL;
grant ownership on future functions in schema PRESENTATION to role DEV_PRESENTATION_SFULL;
grant ownership on future sequences in schema PRESENTATION to role DEV_PRESENTATION_SFULL;
grant ownership on future tasks in schema PRESENTATION to role DEV_DevOps;

-- *********************************************************************************************
-- The section above should be repeated for each schema -> PRESENTATION
-- *********************************************************************************************


-- ------------------------------------------------------------
-- Grant to Functional Roles
-- ------------------------------------------------------------  
use role DEV_role_admin;

grant role DEV_source_sfull to role DEV_DevOps;
grant role DEV_conformed_sfull to role DEV_DevOps;
grant role DEV_domain_sfull to role DEV_DevOps;
grant role DEV_presentation_sfull to role DEV_DevOps;

grant role DEV_domain_sr to role DEV_data_analyst;
grant role DEV_presentation_sr to role DEV_data_analyst;

-- ------------------------------------------------------------
-- Grant to Users (initially all roles granted to current user to test all OK)
-- ------------------------------------------------------------
use role DEV_role_admin;

grant role DEV_data_analyst to user identifier($env_manager_user);
grant role DEV_DevOps to user identifier($env_manager_user);


-- ------------------------------------------------------------
-- End of Script
-- ------------------------------------------------------------

USE ROLE ACCOUNTADMIN;
GRANT CREATE WAREHOUSE ON ACCOUNT TO ROLE DEV_SYS_ADMIN;

USE ROLE DEV_SYS_ADMIN;

CREATE OR REPLACE WAREHOUSE DEV_ETL_WH
warehouse_size = xsmall
warehouse_type = standard
auto_suspend = 60
auto_resume = true
initially_suspended = true;

/* We always need at least USAGE */
GRANT USAGE ON WAREHOUSE DEV_ETL_WH TO DEV_DevOps ;

/* Do we want this role to be able to change the size of a VW?.*/
GRANT OPERATE ON WAREHOUSE DEV_ETL_WH TO DEV_DevOps ;

CREATE OR REPLACE WAREHOUSE DEV_TABLEAU_WH
warehouse_size = xsmall
warehouse_type = standard
auto_suspend = 60
auto_resume = true
initially_suspended = true;

/* We always need at least USAGE */
GRANT USAGE ON WAREHOUSE DEV_TABLEAU_WH TO DEV_data_analyst ;

/* Do we want this role to be able to change the size of a VW?.*/
GRANT OPERATE ON WAREHOUSE DEV_TABLEAU_WH TO DEV_data_analyst ;


CREATE DATABASE IF NOT EXISTS BTS;
USE BTS;

DROP TABLE IF EXISTS TASK_DETAILS_UPDATE;
DROP TABLE IF EXISTS TASK_OWNERS;
DROP TABLE IF EXISTS REQUESTS;
DROP TABLE IF EXISTS TASKS;
DROP TABLE IF EXISTS CE_SKILLS;
DROP TABLE IF EXISTS QUEUES;
DROP TABLE IF EXISTS USERS;
DROP TABLE IF EXISTS ROLES;
DROP TABLE IF EXISTS STATUS_TYPES;
DROP TABLE IF EXISTS TASK_TYPES;
DROP TABLE IF EXISTS CUSTOMERS;
DROP TABLE IF EXISTS SKILL_MAPPINGS;
DROP TABLE IF EXISTS KNOWLEDGE_MAPPINGS;

CREATE TABLE ROLES (
    ROLE_ID INT AUTO_INCREMENT PRIMARY KEY,
    ROLE_NAME VARCHAR(32),
    INDEX (ROLE_ID)
);
CREATE TABLE STATUS_TYPES (
    STATUS_ID INT PRIMARY KEY,
    STATUS_NAME VARCHAR(20),
    INDEX (STATUS_ID)
);
CREATE TABLE TASK_TYPES (
    TASK_TYPE_ID INT AUTO_INCREMENT PRIMARY KEY,
    TASK_TYPE VARCHAR(32),
    INDEX (TASK_TYPE_ID)
);
CREATE TABLE SKILL_MAPPINGS(
    USERNAME VARCHAR(32),
    AREA VARCHAR(32),
    SUBAREA VARCHAR(32),
    SKILL_LEVEL INT
);
CREATE TABLE KNOWLEDGE_MAPPINGS(
    ENTRY_ID INT PRIMARY_KEY,
    TOPIC VARCHAR(52),
    TTYPE VARCHAR(32),
    USERNAME VARCHAR(32),
    LELVEL INT   
);
CREATE TABLE QUEUES(
    QUEUE_ID INT AUTO_INCREMENT PRIMARY KEY,
    QUEUE_NAME VARCHAR(255),
    INDEX(QUEUE_ID)
);
CREATE TABLE CUSTOMERS (
    CUSTOMER_ID INT PRIMARY KEY,
    CUSTOMER_DESCRIPTION VARCHAR(255)
 );
 CREATE TABLE USERS (
    USERNAME VARCHAR(32) PRIMARY KEY,
    FIRST_NAME VARCHAR(32),
    LAST_NAME VARCHAR(32),
    EMAIL VARCHAR(45),
    ROLE_ID INT,
    INDEX (USERNAME),
    INDEX (EMAIL),
    INDEX (ROLE_ID)
);
 
 CREATE TABLE REQUESTS(
    REQUEST_ID INT PRIMARY KEY,
    REQUEST_INFORMATION VARCHAR(512) NULL,
    REQUESTOR_ID VARCHAR(32),
    REQUEST_OWNER VARCHAR(32),
    STATUS_ID INT NULL,
    CUSTOMER_ID INT NULL,
    OPP_ID  VARCHAR(255) NULL,
    CREATED TIMESTAMP NULL,
    LAST_UPDATE TIMESTAMP NULL,
    DEAL_YEARS INT NULL,
    OPP_SIZE INT NULL
);

CREATE TABLE TASKS (
    TASK_ID INT,
    REQUEST_ID INT,
    UPDATE_NO INT,
    TASK_OWNER VARCHAR(32),
    TASK_TYPE_ID INT,
    INFORMATION VARCHAR(255),
    STATUS_ID INT,
    QUEUE_ID INT,
    UPDATE_DATE TIMESTAMP,
    ESTIMATED_EFFORT_HOURS INT,
    ACTUAL_EFFORT_HOURS INT
 );



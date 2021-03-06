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
CREATE TABLE CE_SKILLS(
    CE_SKILL_TYPE_ID INT AUTO_INCREMENT PRIMARY KEY,
    SKILL_DESCRIPION VARCHAR(255),
    INDEX(CE_SKILL_TYPE_ID)
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
    INDEX (ROLE_ID),
    FOREIGN KEY(ROLE_ID) REFERENCES ROLES(ROLE_ID)
);
 CREATE TABLE TASKS (
    TASK_ID INT AUTO_INCREMENT PRIMARY KEY,
    REQUEST_ID INT,
    INFORMATION VARCHAR(255),
    QUEUE_ID INT,
    TASK_TYPE_ID INT,
    CE_SKILL_TYPE_ID INT,
    TASK_OWNER_ID VARCHAR(32),
    INDEX(TASK_ID),
    INDEX(REQUEST_ID),
    INDEX(QUEUE_ID),
    INDEX(TASK_TYPE_ID),
    INDEX(CE_SKILL_TYPE_ID),
    INDEX(TASK_OWNER_ID),
    FOREIGN KEY(QUEUE_ID) REFERENCES QUEUES(QUEUE_ID),
    FOREIGN KEY(TASK_TYPE_ID) REFERENCES TASK_TYPES(TASK_TYPE_ID),
    FOREIGN KEY(CE_SKILL_TYPE_ID) REFERENCES CE_SKILLS(CE_SKILL_TYPE_ID),
    FOREIGN KEY(TASK_OWNER_ID) REFERENCES USERS(USERNAME)
);
CREATE TABLE TASK_OWNERS(
    OWNER_ID INT,
    TASK_ID INT,
    FOREIGN KEY (OWNER_ID) REFERENCES USERS(USERNAME),
    FOREIGN KEY (TASK_ID) REFERENCES TASKS(TASK_ID)
);
 CREATE TABLE REQUESTS(
    REQUEST_ID INT AUTO_INCREMENT PRIMARY KEY,
    REQUEST_INFORMATION VARCHAR(255),
    REQUESTOR_ID VARCHAR(32),
    REQUEST_OWNER VARCHAR(32),
    STATUS_ID INT,
    CUSTOMER_ID INT,
    OPP_ID INT,
    CREATED TIMESTAMP,
    LAST_UPDATE TIMESTAMP NULL,
    DEAL_YEARS INT,
    OPP_SIZE FLOAT,
    FOREIGN KEY (CUSTOMER_ID) REFERENCES CUSTOMERS(CUSTOMER_ID),
    FOREIGN KEY (STATUS_ID) REFERENCES STATUS_TYPES(STATUS_ID),
    FOREIGN KEY (REQUESTOR_ID) REFERENCES USERS(USERNAME),
    FOREIGN KEY (REQUEST_OWNER) REFERENCES USERS(USERNAME)
);
 CREATE TABLE TASK_DETAILS_UPDATE (
    UPDATE_NO INT AUTO_INCREMENT PRIMARY KEY,
    REQUEST_ID INT,
    TASK_ID INT,
    UPDATE_DESCRIPTION VARCHAR(255),
    STATUS_ID INT,
    UPDATE_DATE TIMESTAMP,
    EFFORT_ESTIMATION_HOURS INT,
    TASK_OWNER_ID INT,
    FOREIGN KEY (REQUEST_ID) REFERENCES REQUESTS(REQUEST_ID),
    FOREIGN KEY (TASK_ID) REFERENCES TASKS(TASK_ID),
    FOREIGN KEY (STATUS_ID) REFERENCES STATUS_TYPES(STATUS_ID),
    FOREIGN KEY (TASK_OWNER_ID) REFERENCES USERS(USERNAME)
 );



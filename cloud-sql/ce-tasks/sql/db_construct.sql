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
DROP TABLE IF EXISTS CUSTOMER_DETAILS;
CREATE TABLE ROLES (
    ROLE_ID INT AUTO_INCREMENT PRIMARY KEY,
    ROLE_NAME VARCHAR(32),
    INDEX (ROLE_ID)
);
CREATE TABLE STATUS_TYPES (
    STATUS_ID INT AUTO_INCREMENT PRIMARY KEY,
    STATUS_NAME VARCHAR(20),
    INDEX (STATUS_ID)
);
CREATE TABLE TASK_TYPES (
    TASK_TYPE_ID INT AUTO_INCREMENT PRIMARY KEY,
    TASK_TYPE VARCHAR(32),
    INDEX (TASK_TYPE_ID)
);
CREATE TABLE USERS (
    USER_ID INT AUTO_INCREMENT PRIMARY KEY,
    USERNAME VARCHAR(32),
    FIRST_NAME VARCHAR(32),
    LAST_NAME VARCHAR(32),
    EMAIL VARCHAR(45),
    ROLE_ID INT,
    FOREIGN KEY(ROLE_ID) REFERENCES ROLES(ROLE_ID),
    INDEX (USER_ID),
    INDEX (USERNAME),
    INDEX (EMAIL),
    INDEX (ROLE_ID)
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
CREATE TABLE TASKS (
    TASK_ID INT AUTO_INCREMENT PRIMARY KEY,
    REQUEST_ID INT,
    INFORMATION VARCHAR(255),
    QUEUE_ID INT,
    TASK_TYPE_ID INT,
    CE_SKILL_TYPE_ID INT,
    TASK_OWNER_ID INT,
    FOREIGN KEY(QUEUE_ID) REFERENCES QUEUES(QUEUE_ID),
    FOREIGN KEY(TASK_TYPE_ID) REFERENCES TASK_TYPES(TASK_TYPE_ID),
    FOREIGN KEY(CE_SKILL_TYPE_ID) REFERENCES CE_SKILLS(CE_SKILL_TYPE_ID),
    FOREIGN KEY(TASK_OWNER_ID) REFERENCES USERS(USER_ID),
    INDEX(TASK_ID),
    INDEX(REQUEST_ID),
    INDEX(QUEUE_ID),
    INDEX(TASK_TYPE_ID),
    INDEX(CE_SKILL_TYPE_ID),
    INDEX(TASK_OWNER_ID)
);
CREATE TABLE CUSTOMER_DETAILS (
    CUSTOMER_ID INT AUTO_INCREMENT PRIMARY KEY,
    OPP_ID VARCHAR(255),
    SF_LINK VARCHAR(255),
    OPP_SIZE_M FLOAT,
    DEAL_YEARS INT,
    CUSTOMER_DESCRIPTION VARCHAR(255)
 );
 CREATE TABLE REQUESTS(
    REQUEST_ID INT AUTO_INCREMENT PRIMARY KEY,
    REQUEST_INFORMATION VARCHAR(255),
    REQUESTOR_ID INT,
    REQUEST_OWNER INT,
    STATUS_ID INT,
    CUSTOMER_ID INT,
    OPP_ID INT,
    CREATED TIMESTAMP
    
);

CREATE TABLE TASK_OWNERS(
    OWNER_ID INT,
    TASK_ID INT
    
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
    FOREIGN KEY (TASK_OWNER_ID) REFERENCES USERS(USER_ID)
 );





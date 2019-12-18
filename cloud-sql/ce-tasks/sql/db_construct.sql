CREATE DATABASE IF NOT EXISTS BTS;
USE BTS;

DROP TABLE IF EXISTS USERS;

CREATE TABLE USERS (
    USER_ID INT AUTO_INCREMENT PRIMARY KEY,
    USERNAME VARCHAR(32),
    FIRST_NAME VARCHAR(32),
    LAST_NAME VARCHAR(32),
    EMAIL VARCHAR(45),
    ROLE_ID INT,
    FOREIGN KEY(ROLE_ID) 
    REFERENCES ROLES(ROLE_ID)
    INDEX (USER_ID)
    INDEX (USERNAME),
    INDEX (EMAIL),
    INDEX (ROLE_ID)
)

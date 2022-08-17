CREATE DATABASE gmmo;

create table Users
(
    UserID int,
    FullName varchar(255),
    Address varchar(255),
    City varchar(255),
    Password varchar(255)
);

INSERT INTO Users VALUES (1, "RootPlayer", "Shanghai", "Shanghai", "123");

-- 查看 port: 3306
show global variables like 'port'


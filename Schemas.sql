-- CREATE DATABASE
create database netflix_db ;
use netflix_db ;

-- CREATE TABLE
create table netflix
( show_id varchar(6), type varchar(10), title varchar(150), 
  director varchar(208), casts varchar(1000), country varchar(150), 
  date_added varchar(50), release_year int, rating varchar(10),
  duration varchar(15), listed_in varchar(100), 
  description varchar(250)) ;
  
SELECT * FROM netflix;

SELECT count(*) FROM netflix;

-- TO IMPORT THE LARGE CSV FILE  

SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/netflix_titles.csv'
INTO TABLE netflix
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SHOW VARIABLES LIKE 'autocommit';
SET autocommit = 1;

--  records = 8807, attributes = 12  

select distinct type from netflix ;    -- which type of shows present  


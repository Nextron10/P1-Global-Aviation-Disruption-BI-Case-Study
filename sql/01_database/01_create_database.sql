/*
Run this file once while connected to the postgres maintenance database.
PostgreSQL does not allow CREATE DATABASE inside a transaction block.
*/
CREATE DATABASE aviation_bi
    WITH ENCODING = 'UTF8'
         TEMPLATE = template0;

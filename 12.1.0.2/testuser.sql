/* Create a new user with sufficient prvileges to do development.

   Run with:
      sqlplus system/<password>@localhost:1521/TEST @testuser.cfg

   which will create a new user 'test' with password 'test' in
   the pluggable database named 'TEST'. */

-- Create user and grant prvileges

   CREATE USER test IDENTIFIED BY "test";

   GRANT 
      CREATE SESSION,
      CREATE TABLE,
      CREATE VIEW,
      CREATE TRIGGER,
      CREATE PROCEDURE,
      CREATE SEQUENCE,
      CREATE SYNONYM,
      GRANT ANY PRIVILEGE,
      UNLIMITED TABLESPACE
   TO
      test
   ;

   -- Leave
   
   EXIT;
#!/bin/bash
echo "Please enter your root password at the prompt."
mysql -u root -p -e "CREATE USER 'client_gen'@'localhost' IDENTIFIED BY 'password';"
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS vpn;"
mysql -u root -p -D vpn -e "CREATE TABLE clients(client_id INT NOT NULL, client_email VARCHAR(100) NOT NULL, client_key VARCHAR(50) NOT NULL, last_ip VARCHAR(50), config_file_name VARCHAR(20), date DATE NOT NULL, PRIMARY KEY (client_key));"
mysql -u root -p -D vpn -e "GRANT INSERT  ON clients TO 'client_gen'@'localhost';"
mysql -u root -p -D vpn -e "GRANT SELECT  ON clients TO 'client_gen'@'localhost';"

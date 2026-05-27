#!/bin/bash
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/16/main/postgresql.conf
echo 'host all all 0.0.0.0/0 md5' | sudo tee -a /etc/postgresql/16/main/pg_hba.conf
sudo service postgresql restart
sudo -u postgres createdb weightnest
echo "=== DONE ==="

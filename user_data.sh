#! /bin/bash
sudo yum update -y
sudo yum install -y httpd
sudo chkconfig httpd on
sudo service httpd start
echo "<h1>Hello Server ${server_id}</h1>" | sudo tee /var/www/html/index.html
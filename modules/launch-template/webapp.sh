#!/bin/bash
sudo yum update -y
sudo yum install -y amazon-linux-extras
sudo amazon-linux-extras enable httpd_modules
sudo yum install httpd -y
sudo systemctl enable httpd
sudo systemctl start httpd
echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html
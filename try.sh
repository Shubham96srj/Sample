#!/bin/bash

# List of the packages that should be present
list=("php" "mysql-server" "nginx")

# Check for the existence of the packages in the system and print to file.txt the packages to be installed
check_list=$(dpkg -s "${list[@]}" | grep -e "not installed" | awk 'BEGIN { FS = " " } ; { print $2}' > list.txt)

grep -q '[^[:space:]]' < /home/shubham/list.txt
EMPTY_FILE=$?
# If list.txt is empty there's nothing to do
if [[ $EMPTY_FILE -eq 1 ]]; then

echo "Nothing to do"

else

# If list.txt is not empty it installs the packages in list.txt

for PACKAGES in `cat /home/shubham/list.txt`; do

  sudo apt-get install -y $PACKAGES

done

fi

#hostname

echo "Hi Enter domain name $domainname computer!!"
read yourname
echo "192.168.43.245 $yourname" > /etc/hosts

#restarting service
service nginx enable
service mysqld enable
service nginx restart
service mysqld restart


# setting up the mysql installation
 
sudo mysql_secure_installation

#while proceeding with secure installation do yes to all settings. Enter the password for data base.

# Mysql database creation:

CREATE DATABASE wpdatabase;
CREATE USER 'example.com_db'@'localhost' IDENTIFIED BY 'reset@123';
GRANT ALL ON wpdatabase.* TO 'wpuser'@'localhost' IDENTIFIED BY 'reset@123' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EXIT;

#installation of wordpress on user account:

echo "Database Name: "
read -e dbname

echo "Database User: "
read -e dbuser

echo "Database Password: "
read -s dbpass

echo "run install? (y/n)"
read -e run

if [ "$run" == n ] ; 

then

exit

else

echo "wordpress installation"

mkdir -p /home/example && curl -O https://wordpress.org/latest.tar.gz

fi



#Extract it to nginx default file root

sudo tar -zxvf latest.tar.gz -C /var/www/html

sudo mv /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php

sudo chown -R root:root /var/www/html/

sudo chmod -R 755 /var/www/html/


#set database details with perl find and replace
perl -pi -e "s/database_name_here/$dbname/g" wp-config.php
perl -pi -e "s/username_here/$dbuser/g" wp-config.php
perl -pi -e "s/password_here/$dbpass/g" wp-config.php

# WP salts
perl -i -pe'
  BEGIN {
    @chars = ("a" .. "z", "A" .. "Z", 0 .. 9);
    push @chars, split //, "!@#$%^&*()-_ []{}<>~\`+=,.;:/?|";
    sub salt { join "", map $chars[ rand @chars ], 1 .. 64 }
  }
  s/put your unique phrase here/salt()/ge
' wp-config.php



#configuring Nginx

cat /home/nginx > /etc/nginx/sites-available/wordpress

sudo ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/

sudo service nginx restart


#browse example.com 	

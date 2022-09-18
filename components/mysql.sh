curl -s -L -o /etc/yum.repos.d/mysql.repo https://raw.githubusercontent.com/roboshop-devops-project/mysql/main/mysql.repo
yum install mysql-community-server -y
systemctl enable mysqld
systemctl start mysqld

MYSQL_DEFAULT_PASSWORD=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}')

echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';" >/tmp/mysql
mysql --connect-expired-password -uroot -p"${MYSQL_DEFAULT_PASSWORD}" </tmp/mysql
## mysql_secure_installation
#```
#
## mysql -uroot -pRoboShop@1
#```
#
#Once after login to MySQL prompt then run this SQL Command.
#
#```sql
#> uninstall plugin validate_password;
#```
#
### **Setup Needed for Application.**
#
#As per the architecture diagram, MySQL is needed by
#
#- Shipping Service
#
#
## curl -s -L -o /tmp/mysql.zip "https://github.com/roboshop-devops-project/mysql/archive/main.zip"
#```
#
## cd /tmp
## unzip mysql.zip
## cd mysql-main
## mysql -u root -pRoboShop@1 <shipping.sql

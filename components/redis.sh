source components/common.sh

CHECK_ROOT


PRINT "Configure the yum repos"
curl -L -o /etc/yum.repos.d/redis.repo https://raw.githubusercontent.com/roboshop-devops-project/redis/main/redis.repo &>>${LOG}
CHECK_STAT $?

PRINT "Install redis database"
yum install redis-6.2.7 -y &>>${LOG}
CHECK_STAT $?

PRINT "Update the redis listening address"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/redis.conf  /etc/redis/redis.conf &>>${LOG}
CHECK_STAT $?

PRINT "Start the redis service"
systemctl restart redis &>>${LOG} && systemctl enable redis &>>${LOG}
CHECK_STAT $?
                
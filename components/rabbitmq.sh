source components/common.sh

CHECK_ROOT

if [ -z "${RABBITMQ_USER_PASSWORD}" ]; then
  echo -e "\e[31mRABBITMQ_USER_PASSWORD variable needed\e[0m"
  exit 
fi

PRINT "Configure yum repos"
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash &>>${LOG}
CHECK_STAT $?

PRINT "Install ERLANG AND RABBITMQ"
yum install https://github.com/rabbitmq/erlang-rpm/releases/download/v23.2.6/erlang-23.2.6-1.el7.x86_64.rpm rabbitmq-server -y &>>${LOG}
CHECK_STAT $?

PRINT "Start the rabbitmq service"
systemctl start rabbitmq-server &>>${LOG} && systemctl enable rabbitmq-server &>>${LOG}
CHECK_STAT $?

PRINT "Create the app user"
rabbitmqctl add_user roboshop ${RABBITMQ_USER_PASSWORD} &>>${LOG}
CHECK_STAT $?

PRINT "Add tags and permissions"
rabbitmqctl set_user_tags roboshop administrator &>>${LOG} && rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"  &>>${LOG}
CHECK_STAT $?



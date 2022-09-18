CHECK_ROOT() {
  USER_ID=$(id -u) 
  if [ $USER_ID -ne 0 ]; then
    echo -e "\e[31m Needed to run the script as root user or add sudo\e[0m"
    exit 1
  fi
}

LOG=/tmp/roboshop.log
rm -f $LOG

CHECK_STAT() {
  echo "----------------------" >>${LOG}
  if [ $1 -ne 0 ]; then
    echo -e "\e[31m FAILURE \e[0m"
    echo -e "\n check log file - ${LOG} for errors\n"
    exit 2
  else
    echo -e "\e[32m SUCCESS \e[0m"
  fi
}

PRINT() {
  echo "-----$1-----" >>${LOG}
  echo "$1"
}

APP_COMMON_SETUP() {

    PRINT "Add application user"
    id roboshop &>>${LOG}
    if [ $? -ne 0 ]; then
      useradd roboshop &>>${LOG}
    fi
    CHECK_STAT $?

    PRINT "Download ${COMPONENT} content"
    curl -s -L -o /tmp/${COMPONENT}.zip "https://github.com/roboshop-devops-project/${COMPONENT}/archive/main.zip" &>>${LOG} && cd /home/roboshop
    CHECK_STAT $?

    PRINT "Remove old content"
    rm -rf ${COMPONENT} &>>${LOG}
    CHECK_STAT $?

    PRINT "Extract ${COMPONENT} content"
    unzip /tmp/${COMPONENT}.zip &>>${LOG} && mv ${COMPONENT}-main ${COMPONENT} && cd /home/roboshop/${COMPONENT}
    CHECK_STAT $?

}

SYSTEMD() {

  PRINT "Update systemd configuration"
  sed -i -e 's/REDIS_ENDPOINT/redis.roboshop.internal/' -e 's/CATALOGUE_ENDPOINT/catalogue.roboshop.internal/' -e 's/MONGO_DNSNAME/mongodb.roboshop.internal/' -e 's/REDIS_ENDPOINT/redis.roboshop.internal/' -e 's/MONGO_ENDPOINT/mongodb.roboshop.internal/' -e 's/CARTENDPOINT/cart.roboshop.internal/' -e 's/DBHOST/mysql.roboshop.internal/' -e 's/CARTHOST/cart.roboshop.internal/' -e 's/USERHOST/user.roboshop.internal/' -e 's/AMQPHOST/rabbitmq.roboshop.internal/' -e 's/RABBITMQ-IP/rabbitmq.roboshop.internal/' /home/roboshop/${COMPONENT}/systemd.service &>>${LOG}
  CHECK_STAT $?

  PRINT "Organise content"
  mv /home/roboshop/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service &>>${LOG} && systemctl daemon-reload &>>${LOG}
  CHECK_STAT $?

  PRINT "Start ${COMPONENT} service"
  systemctl restart ${COMPONENT} &>>${LOG} && systemctl enable ${COMPONENT} &>>${LOG}
  CHECK_STAT $?

}

NODEJS() {

  CHECK_ROOT

  PRINT "configure yum repos"
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${LOG}
  CHECK_STAT $?

  PRINT "Install nodejs"
  yum install nodejs -y &>>${LOG}
  CHECK_STAT $?

  APP_COMMON_SETUP

  PRINT "Install nodejs dependencies"
  npm install &>>${LOG}
  CHECK_STAT $?

  SYSTEMD

}

NGINX() {

  PRINT "Install nginx"
  yum install nginx -y &>>${LOG}
  CHECK_STAT $?

  PRINT "Configure ${COMPONENT} content"
  curl -s -L -o /tmp/frontend.zip "https://github.com/roboshop-devops-project/frontend/archive/main.zip" &>>${LOG} && cd /usr/share/nginx/html
  CHECK_STAT $?

  PRINT "Remove old content"
  rm -rf * &>>${LOG}
  CHECK_STAT $?

  PRINT "Extract the ${COMPONENT} content"
  unzip /tmp/frontend.zip &>>${LOG}
  CHECK_STAT $?

  PRINT "Organise content"
  mv frontend-main/static/* . &>>${LOG} && mv frontend-main/localhost.conf /etc/nginx/default.d/roboshop.conf  &>>${LOG}
  CHECK_STAT $?

  PRINT "Update the systemd service"
  sed -i -e "/catalogue/ s/localhost/catalogue.roboshop.internal/" -e "/user/ s/localhost/user.roboshop.internal/" -e "/cart/ s/localhost/cart.roboshop.internal/" -e "/shipping/ s/localhost/shipping.roboshop.internal/" -e "/payment/ s/localhost/payment.roboshop.internal/" /etc/nginx/default.d/roboshop.conf &>>${LOG}
  CHECK_STAT $?

  PRINT "Start the ${COMPONENT}" service
  systemctl restart nginx &>>${LOG} && systemctl enable nginx &>>${LOG}
  CHECK_STAT $?
}

MAVEN() {

  PRINT "Install maven"
  yum install maven -y &>>${LOG}
  CHECK_STAT $?

  APP_COMMON_SETUP

  PRINT "Install maven dependencies"
  mvn clean package &>>${LOG} && mv target/${COMPONENT}-1.0.jar ${COMPONENT}.jar &>>${LOG}
  CHECK_STAT $?

  SYSTEMD
}

PYTHON() {

  PRINT "Install python service"
  yum install python36 gcc python3-devel -y &>>${LOG}
  CHECK_STAT $?

  APP_COMMON_SETUP

  PRINT "Install the python dependencies"
  pip3 install -r requirements.txt  &>>${LOG}
  CHECK_STAT $?

  USER_ID=$(id -u roboshop)
  GROUP_ID=$(id -g roboshop)


  PRINT "Update the user and group id's"
  sed -i -e "/^uid/ c uid = ${USER_ID}" -e "/^gid/ c gid = ${GROUP_ID}" /home/roboshop/payment/payment.ini &>>${LOG}
  CHECK_STAT $?

  SYSTEMD

}

GOLANG() {

  PRINT "Install golang"
  yum install golang -y &>>${LOG}
  CHECK_STAT $?

  PRINT "Add application user"
  id roboshop &>>${LOG}
  if [ $? -ne 0 ]; then
    useradd roboshop &>>${LOG}
  fi
  CHECK_STAT $?

  PRINT "Download ${COMPONENT} content"
  curl -s -L -o /tmp/${COMPONENT}.zip "https://github.com/roboshop-devops-project/${COMPONENT}/archive/refs/heads/main.zip" &>>${LOG} && cd /home/roboshop
  CHECK_STAT $?

  PRINT "Remove old content"
  rm -rf ${COMPONENT} &>>${LOG}
  CHECK_STAT $?

  PRINT "Extract ${COMPONENT} content"
  unzip /tmp/${COMPONENT}.zip &>>${LOG} && mv ${COMPONENT}-main ${COMPONENT} && cd /home/roboshop/${COMPONENT}
  CHECK_STAT $?

  PRINT "Install golang dependencies"
  go mod init ${COMPONENT} &>>${LOG} && go get &>>${LOG} && go build &>>${LOG}
  CHECK_STAT $?

  SYSTEMD

}





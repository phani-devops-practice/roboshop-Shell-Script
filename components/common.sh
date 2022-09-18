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
      echo useradd roboshop &>>${LOG}
    fi
    CHECK_STAT $?

    PRINT "Download cart content"
    curl -s -L -o /tmp/${COMPONENT}.zip "https://github.com/roboshop-devops-project/${COMPONENT}/archive/main.zip" &>>${LOG}
    CHECK_STAT $?

    PRINT "Remove old content"
    cd /home/roboshop && rm -rf ${COMPONENT} &>>${LOG}
    CHECK_STAT $?

    PRINT "Extract ${COMPONENT} content"
    unzip /tmp/${COMPONENT}.zip &>>${LOG} && mv ${COMPONENT}-main ${COMPONENT} && cd /home/roboshop/${COMPONENT}
    CHECK_STAT $?

}

SYSTEMD() {

  PRINT "Update systemd configuration"
  sed -i -e 's/REDIS_ENDPOINT/redis.roboshop.internal/' -e 's/CATALOGUE_ENDPOINT/catalogue.roboshop.internal/' -e 's/MONGO_DNSNAME/mongodb.roboshop.internal/' -e 's/REDIS_ENDPOINT/redis.roboshop.internal/' -e 's/MONGO_ENDPOINT/mongodb.roboshop.internal/' /home/roboshop/${COMPONENT}/systemd.service &>>${LOG}
  CHECK_STAT $?

  PRINT "Organise content"
  mv /home/roboshop/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service &>>${LOG} && systemctl daemon-reload &>>${LOG}
  CHECK_STAT $?

  PRINT "Start cart service"
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






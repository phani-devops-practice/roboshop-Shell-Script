CHECK_ROOT() {
  USER_ID=$(id -u) >>${LOG}
  if [ ${USER_ID} -ne 0 ]; then
    echo -e "\e[31m Needed to run the script as root user or add sudo\e[0m"
    exit
  fi
}

LOG=/tmp/roboshop.log
rm -f $LOG

CHECK_STAT() {
  echo "----------------------------" >>${LOG}
  echo -e "\n check log file - ${LOG} for errors\n" 
  if [ $1 -ne 0 ]; then
    echo -e "\e[31m FAILURE \e[0m"
  else
    echo -e "\e[32m SUCCESS \e[0m"
  fi
}

PRINT() {
  if [ $1 -ne 0 ]; then
    echo "-----$1-----" >>${LOG}
    echo "$1" >>${LOG}
  fi
}



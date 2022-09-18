CHECK_ROOT() {
  USER_ID=$(id -u) 
  if [ ${USER_ID} -ne 0 ]; then
    echo -e "\e[31m Needed to run the script as root user or add sudo\e[0m"
    exit 1
  fi
}

LOG=/tmp/roboshop.log
rm -f $LOG

CHECK_STAT() {
  echo "----------------------" >>${LOG}
  if [ $? -ne 0 ]; then
    echo -e "\e[31m FAILURE \e[0m"
    echo -e "\n check log file - ${LOG} for errors\n"
    exit 2
  else
    echo -e "\e[32m SUCCESS \e[0m"
  fi
}

PRINT() {
  if [ $? -ne 0 ]; then
    echo "-----$1-----" >>${LOG}
    echo "$1"
  fi
}

9591851420      1320



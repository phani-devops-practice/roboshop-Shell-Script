CHECK_ROOT() {
  USER_ID=$(id -u)
  if [ ${USER_ID} -ne 0 ]; then
    echo -e "\e[31m Needed to run the script as root user or add sudo\e[0m"
    exit
  fi
}

LOG=/tmp/roboshop.log
rm -f $LOG

CHECK_STAT() {
  echo -e "\n check log file - ${LOG} for errors\n"
  if [ $? -ne 0 ]; then
    echo -e "\e[31m FAILURE \e[0m"
  else
    echo -e "\e[32m SUCCESS \e[0m"
  fi
}



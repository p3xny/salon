#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

arr=()
echo -e "\n~~~~~ List of Services ~~~~~\n"
DISPLAY_SERVICES() {
  #local services=$()#

  $PSQL "SELECT service_id, name FROM services;" | while read -r ID NAME
  do
    local service="${ID} ${NAME}"
    echo $service | sed -r 's/\|/) /g'
  done


}

SERVICE_SELECTION() {
  DISPLAY_SERVICES

  echo -e "\nSelect a service:"

  MAX_SERVICE_ID=$($PSQL "
    SELECT MAX(service_id) FROM services;
  ")
  #echo -e "\nMAX_SERVICE_ID: $MAX_SERVICE_ID"
  read SERVICE_ID_SELECTED

  SERVICE_EXISTS=$($PSQL "
    SELECT service_id FROM services
    WHERE service_id=$SERVICE_ID_SELECTED;")

  if [[ -z $SERVICE_EXISTS ]]; then
    SERVICE_SELECTION; fi
}

MAKE_APPOINTMENT() {
  SERVICE_SELECTION

  echo -e "\nEnter your phone number (xxx-xxxx):"
  read CUSTOMER_PHONE

  IS_CUSTOMER=$($PSQL "
    SELECT name FROM customers
    WHERE phone='$CUSTOMER_PHONE';")

  if [[ ! -z $IS_CUSTOMER ]];then
    CUSTOMER_NAME=$IS_CUSTOMER
  else
    echo -e "\nEnter your name:"
    read CUSTOMER_NAME
    $($PSQL "
      INSERT INTO customers (name, phone)
      VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE');"); fi


  CUSTOMER_ID=$($PSQL "
    SELECT customer_id FROM customers
    WHERE phone='$CUSTOMER_PHONE';")

  echo -e "\nEnter service time:"
  read SERVICE_TIME

  $($PSQL "
    INSERT INTO appointments (customer_id, service_id, time)
    VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')
  ;")

  SERVICE_NAME=$($PSQL "
    SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")

  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAKE_APPOINTMENT

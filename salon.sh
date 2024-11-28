#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

SERVICE_MENU() {
  # if a service entered doesn't exist
  if [[ $1 ]]
    then
      echo -e "\n$1"
  fi

  echo -e "1) cut\n2) color\n3) perm\n4) style\n5) trim"
  read SERVICE_ID_SELECTED

  SERVICE_ID_SELECTED_RESULT=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
  
  # if service id not found
  if [[ -z $SERVICE_ID_SELECTED_RESULT ]]
    then
      # send to service menu
      SERVICE_MENU "I could not find that service. What would you like today?"
    else
      # get customer phone number
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE

      CUSTOMER_NAME_RESULT=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")
      
      # if customer phone not found
      if [[ -z $CUSTOMER_NAME_RESULT ]]
        then
          # get customer name
          echo -e "\nI don't have a record for that phone number, what's your name?"
          read CUSTOMER_NAME

          # insert new customer
          NAME_RESULT=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
      fi

      # get customer name
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")
      
      # get service time
      echo -e "\nWhat time would you like your cut, $(echo $CUSTOMER_NAME | sed 's/  / /')?"
      read SERVICE_TIME

      # get customer id
      CUSTOMER_ID_RESULT=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")

      # insert new appointment
      TIME_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID_RESULT, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")

      # get service name
      SERVICE_NAME_RESULT=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")

      # print info
      echo -e "\nI have put you down for a $(echo $SERVICE_NAME_RESULT | sed 's/  / /') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed 's/  / /')."
  fi
}

SERVICE_MENU

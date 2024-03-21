#!/bin/bash

echo -e "\n ~~~~ MY SALON ~~~~"

SQL='psql --username=freecodecamp --dbname=salon --tuples-only -c'

# Ask customer to select a service
SERVICES=$($SQL "SELECT name FROM services")
askForService() {
  if [[ -z $1 ]] 
  then
    echo -e "\nWelcome to My Salon, how can I help you?\n"
  else
    echo -e "\nI could not find that service. What would you like today?\n"
  fi
  INDEX=1
  for SERVICE in $SERVICES
  do
    echo -e "$INDEX) $SERVICE"
    (( INDEX++ ))
  done
  read SERVICE_ID_SELECTED
}
askForService

SERVICE_ID_SELECTED=$($SQL "select service_id from services where service_id=$SERVICE_ID_SELECTED")
while [[ -z $SERVICE_ID_SELECTED ]]
do
  askForService again
  SERVICE_ID=$($SQL "select service_id from services where service_id=$SERVICE_ID_SELECTED")
done
SERVICE=$($SQL "select name from services where service_id=$SERVICE_ID_SELECTED")

# Ask client for the phone number and check if customer is already there with the same phone number
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE
CUSTOMER_NAME=$($SQL "select name from customers where phone='$CUSTOMER_PHONE'")

if [[ -z $CUSTOMER_NAME ]]
then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  INSERT_CUSTOMER=$($SQL "insert into customers(phone, name) values('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
fi

# Ask client for the time
echo -e "\nWhat time would you like your$SERVICE, $CUSTOMER_NAME?"
read SERVICE_TIME
CUSTOMER_ID=$($SQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")

INSERT_APPOINTMENT=$($SQL "insert into appointments (customer_id, service_id, time) values ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
echo -e "\nI have put you down for a$SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."

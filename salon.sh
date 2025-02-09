#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"


echo "Welcome to My Salon, how can I help you?"

SERVE_MENU() {
  # set up
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  # Display services
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME 
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  # Get user's choice
  read SERVICE_ID_SELECTED

  # Check if input is not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
    echo "I could not find that service. What would you like today?"
    # try again
    SERVE_MENU
    else
    # check if the CHOSEN_SERIVE number corresponds to service_id
    SERVICE_EXISTS=$($PSQL "SELECT COUNT(*) FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    if [[ $SERVICE_EXISTS -eq 0 ]] 
      then
      echo "I could not find that service. What would you like today?"
      # try again
      SERVE_MENU
      else
      # get customer phone number
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      # check if this person exist in database
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'" | tr -d '[:space:]')
      # if customer doesn't exist
      if [[ -z $CUSTOMER_NAME ]]
        then
        # get new customer name
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        # insert customer
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')") 
      fi
      CHOSEN_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED" | tr -d '[:space:]')
      echo What time would you like your $CHOSEN_SERVICE_NAME, $CUSTOMER_NAME?
      read SERVICE_TIME
      # prep for inserting
      GET_CORRESPONDING_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name = '$CUSTOMER_NAME'" | tr -d '[:space:]')
      GET_CORRESPONDING_SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE name = '$CHOSEN_SERVICE_NAME'" | tr -d '[:space:]')
      # to the database
      INSERT_INTO_APPOINTMENTS_TIME=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', $GET_CORRESPONDING_CUSTOMER_ID, $GET_CORRESPONDING_SERVICE_ID)") 
      echo I have put you down for a $CHOSEN_SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.
    fi
  fi
}

SERVE_MENU

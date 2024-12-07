#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

GENERATE_RANDOM_NUMBER() {
  NUMBER=$(($SRANDOM%1000+1))
}

INSERT_USERNAME() {
  echo "Enter your username:"
  read USERNAME
  GET_USER=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")
  
  if [[ -z $GET_USER ]]; then
    INSERT_NEW_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
    echo "Welcome, $USERNAME! It looks like this is your first time here."
  else
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME'")
    BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME'")
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi
}

GUESS_THE_NUMBER() {
  read USER_GUESS
}

CONFIRM_INTEGER() {
  if [[ $USER_GUESS =~ ^[0-9]+$ ]]; then
    return 0
  else
    echo "That is not an integer, guess again:"
    GUESS
  fi
}

COMPARE_NUMBERS() {
  ((NUMBER_OF_GUESSES++))
  if (( NUMBER > USER_GUESS )); then
    echo "It's higher than that, guess again:"
    GUESS
  elif (( NUMBER < USER_GUESS )); then
    echo "It's lower than that, guess again:"
    GUESS
  else
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $NUMBER. Nice job!"
    UPDATE_DB
    return 0
  fi
}

UPDATE_DB() {
  INCREMENT_PLAYED_GAMES=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username = '$USERNAME'")
  if (( BEST_GAME > NUMBER_OF_GUESSES || BEST_GAME == 0 )); then
    UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE username = '$USERNAME'")
  fi
}

### Everything above is very messy ###

INITIALIZE() {
  INSERT_USERNAME
  echo "Guess the secret number between 1 and 1000:"
}

GUESS() {
  GUESS_THE_NUMBER
  CONFIRM_INTEGER
  COMPARE_NUMBERS
}

# This is where the program starts
GENERATE_RANDOM_NUMBER
NUMBER_OF_GUESSES=0
INITIALIZE
GUESS

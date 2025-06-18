#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Generate a random number between 1 and 1000
SECRET_NUMBER=$(( (RANDOM % 1000) + 1 ))

echo "Enter your username:"
read USERNAME

# Get username from database
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = $USERNAME")

# Check if this is a new username
if [[ -z $USER_ID]]
then
# Add user to database
    INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 0, -1)")
    echo "Welcome, $USERNAME! It looks like this is your first time here."
else
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id = $USER_ID")
    BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id = $USER_ID")
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
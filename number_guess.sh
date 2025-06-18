#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Generate a random number between 1 and 1000
SECRET_NUMBER=$(( (RANDOM % 1000) + 1 ))
echo $SECRET_NUMBER

echo "Enter your username:"
read USERNAME

# Get username from database
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

# Check if this is a new username
if [[ -z $USER_ID ]]
then
# Add user to database
    INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 0, -1)")
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
    echo "Welcome, $USERNAME! It looks like this is your first time here."
else
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id = $USER_ID")
    BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id = $USER_ID")
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

NUMBER_OF_GUESSES=1

echo "Guess the secret number between 1 and 1000:"
read GUESS

# Guess and keep guessing until the secret number is found
while [[ $GUESS != $SECRET_NUMBER ]]
do
  # Check if guess is not an integer
  if [[ ! "$GUESS" =~ ^-?[0-9]+$ ]]; then
      echo "That is not an integer, guess again:"
      read GUESS
  # If guess is higher than the secret number
  elif (( GUESS > SECRET_NUMBER )); then
      echo "It's lower than that, guess again:"
      read GUESS
  # If guess is lower than the secret number
  else
      echo "It's higher than that, guess again:"
      read GUESS
  fi
    # Increment number of guesses
    ((NUMBER_OF_GUESSES++))
done

# Increase games played and update database
((GAMES_PLAYED++))
UPDATE_GAMES_PLAYED_RESULT=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED WHERE user_id = $USER_ID")

# If this was the best game, update database
if [[ -z $BEST_GAME || $BEST_GAME -eq -1 || $NUMBER_OF_GUESSES -lt $BEST_GAME ]]; then
  BEST_GAME=$NUMBER_OF_GUESSES
  UPDATE_BEST_GAME_RESULT=$($PSQL "UPDATE users SET best_game = $BEST_GAME WHERE user_id = $USER_ID")
fi

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
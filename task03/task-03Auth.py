## This is for Login / Access Control of the
## University Final Year Project Submission System.

# First of all, import important modules
import json
import os
import sys
from datetime import datetime



# Files used by the authentication system
# ----------------------------------------------------------

LOGIN_LOG_FILE = "login_log.txt"
ACCOUNTS_FILE = "accounts_status.json"


# ----------------------------------------------------------
# Demo list of valid student accounts
# This is only for simulation.
# In a real system, a database would normally be used.
# ----------------------------------------------------------

VALID_USERS = {
    "student1": "password123",
    "student2": "password456",
    "student3": "password789"
}

# Security settings
#------------------


MAX_FAILED_ATTEMPTS = 3

# If another login attempt happens within 60 seconds,
# it will be marked as suspicious.
SUSPICIOUS_WINDOW_SECONDS = 60



# LOAD ACCOUNT STATUS
#---------------------


def load_account_status():

    # Check whether the JSON file exists
    if not os.path.exists(ACCOUNTS_FILE):
        return {}

    try:

        with open(ACCOUNTS_FILE, "r") as file:
            return json.load(file)

    except (json.JSONDecodeError, ValueError):

        # If the file has a problem, start with empty data
        return {}

# SAVE ACCOUNT STATUS
# --------------------

def save_accounts_status(status_data):

    with open(ACCOUNTS_FILE, "w") as file:

        json.dump(status_data, file, indent=4)



# LOG LOGIN ATTEMPT
# -----------------

def log_attempt(username, result_message):

    # Get current date and time
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    # Add login information to the log file
    with open(LOGIN_LOG_FILE, "a") as file:

        file.write(
            f"[{timestamp}] Username: {username} -> "
            f"{result_message}\n"
        )

       
# SIMULATE LOGIN
# ===============

def simulate_login(username, password):

    # Load previous account information
    accounts_status = load_account_status()

    # Get current date and time
    now = datetime.now()


    
    # Create account record if this is the first attempt
    # ------------------------------------------------------

    if username not in accounts_status:
    accounts_status[username] = {
        "failed_attempts": 0,
        "locked": False,
        "last_attempt_time": None
    }

# Move this line outside the if block so it always executes
account = accounts_status[username] 



    # 1. CHECK WHETHER ACCOUNT IS LOCKED
    # -----------------------------------

    if account["locked"]:

        message = "ACCOUNT LOCKED!!!"

        log_attempt(username, message)

        save_accounts_status(accounts_status)

        return message

    # 2. CHECK SUSPICIOUS LOGIN ATTEMPTS
    # -----------------------------------

    suspicious = False

    if account["last_attempt_time"] is not None:

        last_time = datetime.strptime(
            account["last_attempt_time"],
            "%Y-%m-%d %H:%M:%S"
        )

        seconds_since_last_attempt = (
            now - last_time
        ).total_seconds()


        # Check if the previous attempt was
        # within the last 60 seconds
        if seconds_since_last_attempt < SUSPICIOUS_WINDOW_SECONDS:

            suspicious = True


    # Save current attempt time
    account["last_attempt_time"] = now.strftime(
        "%Y-%m-%d %H:%M:%S"
    )

    # 3. CHECK USERNAME AND PASSWORD
    # -------------------------------

    if username not in VALID_USERS or \
       VALID_USERS[username] != password:

        # Increase failed login count
        account["failed_attempts"] += 1



        # LOCK ACCOUNT AFTER 3 FAILED ATTEMPTS
        # ------------------------------------

        if account["failed_attempts"] >= MAX_FAILED_ATTEMPTS:

            account["locked"] = True

            message = (
                "LOGIN FAILED!!! "
                "Account is now locked after 3 failed attempts."
            )

        else:

            remaining = (
                MAX_FAILED_ATTEMPTS
                - account["failed_attempts"]
            )

            message = (
                "LOGIN FAILED!!! "
                "Incorrect username or password. "
                + str(remaining)
                + " attempt(s) left."
            )


        # Add suspicious warning
        if suspicious:

            message += (
                " [SUSPICIOUS: repeated attempt "
                "within 60 seconds]"
            )


        # Save login attempt
        log_attempt(username, message)

        # Save account information
        save_accounts_status(accounts_status)

        return message


    # 4. SUCCESSFUL LOGIN
    # --------------------

    # Reset failed attempts after successful login
    account["failed_attempts"] = 0

    message = (
        "LOGIN SUCCESSFUL!!! "
        "Welcome, " + username + "."
    )


    # Add suspicious warning if required
    if suspicious:

        message += (
            " [SUSPICIOUS: repeated attempt "
            "within 60 seconds]"
        )


    # Save login attempt
    log_attempt(username, message)

    # Save account information
    save_accounts_status(accounts_status)

    return message


# MAIN PROGRAM
# =============

if __name__ == "__main__":

    # The script expects:
    #
    # python3 task3_auth.py username password
    #
    # Example:
    #
    # python3 task3_auth.py student1 password123


    # Check whether username and password were entered
    if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 task-03Auth.py <username> <password>")
        sys.exit(1)

    entered_username = sys.argv[1]
    entered_password = sys.argv[2]

    result = simulate_login(entered_username, entered_password)

    # Display result
    print(result)

    # Set exit codes based on authentication result
    if "SUCCESSFUL" in result:
        sys.exit(0)  # Success
    elif "LOCKED" in result:
        sys.exit(2)  # Account locked
    else:
        sys.exit(1)  # Authentication failed


    # Display result
    print(result)








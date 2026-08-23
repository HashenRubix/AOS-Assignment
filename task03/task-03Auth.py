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






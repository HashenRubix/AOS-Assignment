## This is for Login / Access Control of the
## University Final Year Project Submission System.

# First of all, import important modules
import json
import os
import sys
from datetime import datetime


# ----------------------------------------------------------
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






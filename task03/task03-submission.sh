#! /bin/bash

# University Final Year Project Submission System
# ================================================

SUBMISSION_DIR="SubmittedAssignments"
SUBMISSION_LOG="submission_log.txt"
LOGIN_LOG="login_log.txt"


# LOGGING
# ========

log_action()
{
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$SUBMISSION_LOG"
}



# Create Required Files And Directories
# ======================================

if [ ! -d "$SUBMISSION_DIR" ]
then
    mkdir -p "$SUBMISSION_DIR"
fi

if [ ! -f "$SUBMISSION_LOG" ]
then
    touch "$SUBMISSION_LOG"
fi

if [ ! -f "$LOGIN_LOG" ]
then
    touch "$LOGIN_LOG"
fi



# Record Program
# ===============

log_action "Final Year Project Submission System started"



# MAIN MENU
# ==========================================================

while true
do

    echo "=============================================="
    echo " UNIVERSITY FINAL YEAR PROJECT SYSTEM"
    echo "=============================================="
    echo "1. Submit an Assignment"
    echo "2. Check if a File Has Already Been Submitted"
    echo "3. List All Submitted Assignments"
    echo "4. Simulate Login Attempt"
    echo "5. Exit"
    echo "=============================================="

    read -p "Enter your choice: " CHOICE


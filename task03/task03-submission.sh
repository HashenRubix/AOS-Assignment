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


    # CHOICE 1 - SUBMIT ASSIGNMENT
    # =============================

    if [ "$CHOICE" = "1" ]
    then

        echo "======================================"
        echo " SUBMIT ASSIGNMENT"
        echo "======================================"

        read -p "Enter Student ID: " STUDENT_ID
        read -p "Enter assignment file path: " FILE_PATH


        # CHECK FILE EXISTS
        # ------------------

        if [ ! -f "$FILE_PATH" ]
        then

            echo "ERROR: File does not exist."

            log_action "Submission failed - File does not exist: $FILE_PATH"

            continue

        fi

	 # GET FILE NAME
        # --------------

        FILE_NAME=$(basename "$FILE_PATH")



        # CHECK FILE EXTENSION
        # ---------------------

        EXTENSION="${FILE_NAME##*.}"
        EXTENSION=$(echo "$EXTENSION" | tr '[:upper:]' '[:lower:]')

        if [ "$EXTENSION" != "pdf" ] &&
           [ "$EXTENSION" != "docx" ]
        then

            echo "ERROR: Invalid file type."
            echo "Only .pdf and .docx files are accepted."

            log_action "Rejected invalid file type: $FILE_NAME"

            continue

        fi

	# CHECK FILE SIZE
        # Maximum allowed = 5MB
        # -----------------------

        FILE_SIZE=$(stat -c%s "$FILE_PATH")
        MAX_SIZE=5242880

        if [ "$FILE_SIZE" -gt "$MAX_SIZE" ]
        then

            echo "ERROR: File is larger than 5MB."

            FILE_SIZE_MB=$(awk "BEGIN {printf \"%.2f\", $FILE_SIZE/1048576}")

            echo "File size: ${FILE_SIZE_MB} MB"

            log_action "Rejected file larger than 5MB: $FILE_NAME"

            continue

        fi



        # CALCULATE SHA-256 HASH
        # ----------------------

        FILE_HASH=$(sha256sum "$FILE_PATH" | awk '{print $1}')



	# CHECK DUPLICATE SUBMISSION
        # ---------------------------

        DUPLICATE_FOUND="false"

        if [ -s "$SUBMISSION_LOG" ]
        then

            while IFS='|' read -r LOG_TIME LOG_STUDENT LOG_FILE LOG_HASH LOG_STATUS
            do

                if [ "$LOG_FILE" = "$FILE_NAME" ] &&
                   [ "$LOG_HASH" = "$FILE_HASH" ] &&
                   [ "$LOG_STATUS" = "SUBMITTED" ]
                then

                    DUPLICATE_FOUND="true"
                    break

                fi

            done < "$SUBMISSION_LOG"

        fi

	# REJECT DUPLICATE
        # -----------------

        if [ "$DUPLICATE_FOUND" = "true" ]
        then

            echo "======================================"
            echo " DUPLICATE SUBMISSION DETECTED"
            echo "======================================"

            echo "Filename and file content already exist."
            echo "Submission rejected."

            log_action "Duplicate submission rejected - Student: $STUDENT_ID - File: $FILE_NAME"

            continue

        fi

	# CREATE SAFE FILE NAME
        # ----------------------

        TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

        STORED_FILE="${STUDENT_ID}_${TIMESTAMP}_${FILE_NAME}"







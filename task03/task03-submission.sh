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


	# COPY FILE TO SUBMISSION DIRECTORY
        # ---------------------------------

        if cp "$FILE_PATH" "$SUBMISSION_DIR/$STORED_FILE"
        then


            echo " SUBMISSION SUCCESSFUL"
            echo "======================================"

            echo "Student ID : $STUDENT_ID"
            echo "File Name  : $FILE_NAME"
            echo "File Size  : $(du -h "$FILE_PATH" | cut -f1)"
            echo "Stored As  : $STORED_FILE"


            # WRITE SUBMISSION LOG
            # ---------------------

            echo "$(date '+%Y-%m-%d %H:%M:%S')|$STUDENT_ID|$FILE_NAME|$FILE_HASH|SUBMITTED" \
                >> "$SUBMISSION_LOG"

            log_action "Assignment submitted successfully - Student: $STUDENT_ID - File: $FILE_NAME"

        else

            echo "ERROR: Failed to copy submission."

            log_action "Submission failed while copying file: $FILE_NAME"

        fi

	# CHOICE 2 - CHECK DUPLICATE FILE
        # ===============================

    elif [ "$CHOICE" = "2" ]
    then


        echo " CHECK SUBMISSION"
        echo "======================================"

        read -p "Enter file path: " FILE_PATH

        if [ ! -f "$FILE_PATH" ]
        then

            echo "ERROR: File does not exist."

            log_action "Check submission failed - File does not exist: $FILE_PATH"

            continue

        fi

        FILE_NAME=$(basename "$FILE_PATH")

        FILE_HASH=$(sha256sum "$FILE_PATH" | awk '{print $1}')

        FOUND="false"


	# SEARCH SUBMISSION LOG
        # ----------------------

        if [ -s "$SUBMISSION_LOG" ]
        then

            while IFS='|' read -r LOG_TIME LOG_STUDENT LOG_FILE LOG_HASH LOG_STATUS
            do

                if [ "$LOG_FILE" = "$FILE_NAME" ] &&
                   [ "$LOG_HASH" = "$FILE_HASH" ] &&
                   [ "$LOG_STATUS" = "SUBMITTED" ]
                then

                    FOUND="true"

                    echo "======================================"
                    echo " FILE ALREADY SUBMITTED"
                    echo "======================================"

                    echo "Filename : $LOG_FILE"
                    echo "Student  : $LOG_STUDENT"
                    echo "Date     : $LOG_TIME"

                    break

                fi

            done < "$SUBMISSION_LOG"
	fi

	if [ "$FOUND" = "false" ]
        then

            echo "File has not been submitted before."

            log_action "Checked file - No duplicate found: $FILE_NAME"

        else

            log_action "Checked file - Existing submission found: $FILE_NAME"

        fi




	# CHOICE 3 - LIST ALL SUBMITTED ASSIGNMENTS
        # =========================================

    elif [ "$CHOICE" = "3" ]
    then


        echo " ALL SUBMITTED ASSIGNMENTS"
        echo "======================================"

        if [ ! -s "$SUBMISSION_LOG" ]
        then

            echo "No assignments have been submitted."

        else

            echo "Date and Time | Student ID | File Name"
            echo "--------------------------------------"

            while IFS='|' read -r LOG_TIME LOG_STUDENT LOG_FILE LOG_HASH LOG_STATUS
            do

                if [ "$LOG_STATUS" = "SUBMITTED" ]
                then

                    echo "$LOG_TIME | $LOG_STUDENT | $LOG_FILE"

                fi

            done < "$SUBMISSION_LOG"
	fi

	 echo "======================================"

        log_action "Listed all submitted assignments"



    # CHOICE 4 - SIMULATE LOGIN ATTEMPT
    # =================================

    elif [ "$CHOICE" = "4" ]
    then


        echo " LOGIN AUTHENTICATION"
        echo "======================================"

        
        # CALL PYTHON AUTHENTICATION SCRIPT
        # ---------------------------------
	
	if [ ! -f "task-03Auth.py" ]
        then

            echo "ERROR: task-03Auth.py was not found."

            echo "Please place task-03Auth.py in the same directory."

            log_action "Authentication failed - task-03Auth.py not found"

            continue

        fi


        python3 task-03Auth.py login

        AUTH_RESULT=$?



	 # CHECK AUTHENTICATION RESULT
         # ---------------------------

        if [ "$AUTH_RESULT" -eq 0 ]
        then

            echo "Authentication completed successfully."

            log_action "Successful authentication through Python authentication system"

        elif [ "$AUTH_RESULT" -eq 2 ]
        then

            echo "Authentication blocked - account is locked."

            log_action "Authentication blocked - locked account"

        else

            echo "Authentication failed."

            log_action "Authentication failed"

        fi

	# CHOICE 5 - EXIT
        # ================

    elif [ "$CHOICE" = "5" ]
    then

        read -p "Are you sure you want to exit? (y/n): " EXIT_CONFIRM


        if [ "$EXIT_CONFIRM" = "Y" ] || [ "$EXIT_CONFIRM" = "y" ]
        then

            echo "Bye! Thank you for using the Final Year Project Submission System."

            log_action "User exited from Final Year Project Submission System"

            break

        else

            echo "Exit cancelled."

            log_action "User cancelled exit"

        fi

	# INVALID CHOICE
        # ================

    else

        echo "Invalid choice."

        echo "Please select 1, 2, 3, 4, or 5."

        log_action "Invalid menu option selected: $CHOICE"

    fi

done










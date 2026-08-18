#! /bin/bash



# University Research Cluster Job Scheduler
# ==========================================

QUEUE_FILE="job_queue.txt"
COMPLETED_FILE="completed_jobs.txt"
LOG_FILE="scheduler_log.txt"

# Round Robin time quantum
TIME_QUANTUM=5



# LOGGING FUNCTION
# ==================

log_action()
{
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}



# CREATE REQUIRED FILES IF THEY DO NOT EXIST
# ==========================================

if [ ! -f "$QUEUE_FILE" ]
then
    touch "$QUEUE_FILE"
fi

if [ ! -f "$COMPLETED_FILE" ]
then
    touch "$COMPLETED_FILE"
fi

if [ ! -f "$LOG_FILE" ]
then
    touch "$LOG_FILE"
fi


# Record program start
log_action "University Research Cluster Job Scheduler started"

# MAIN MENU
# ==========================================================

while true
do


    echo "=============================================="
    echo "   UNIVERSITY RESEARCH CLUSTER JOB SCHEDULER"
    echo "=============================================="
    echo "1. View Pending Jobs"
    echo "2. Submit a Job Request"
    echo "3. Process Queue - Round Robin"
    echo "4. Process Queue - Priority Scheduling"
    echo "5. View Completed Jobs"
    echo "6. Exit System"
    echo "=============================================="

    read -p "Enter your choice: " CHOICE
	
 # CHOICE 1 - VIEW PENDING JOBS   

    if [ "$CHOICE" = "1" ]
    then

        
        
        echo "              PENDING JOBS"
        echo "=============================================="

        # Check whether queue is empty

        if [ ! -s "$QUEUE_FILE" ]
        then
            echo "No pending jobs."
        else

            printf "%-15s %-25s %-15s %-10s\n" \
            "Student ID" "Job Name" "Execution Time" "Priority"

            echo "---------------------------------------------------------------------"

            # Read jobs from queue

            while IFS='|' read -r STUDENT_ID JOB_NAME EXECUTION_TIME PRIORITY
            do

                printf "%-15s %-25s %-15s %-10s\n" \
                "$STUDENT_ID" "$JOB_NAME" "$EXECUTION_TIME" "$PRIORITY"

            done < "$QUEUE_FILE"

        fi

        echo

	 log_action "Viewed pending jobs"



    # CHOICE 2 - SUBMIT A JOB REQUEST


    elif [ "$CHOICE" = "2" ]
    then


        echo "             SUBMIT JOB REQUEST"
        echo "=============================================="

        # Get Student ID

        read -p "Enter Student ID: " STUDENT_ID

        if [ -z "$STUDENT_ID" ]
        then
            echo "Student ID cannot be empty."
            log_action "Job submission failed - empty Student ID"
            continue
        fi

	# Get Job Name

        read -p "Enter Job Name: " JOB_NAME

        if [ -z "$JOB_NAME" ]
        then
            echo "Job name cannot be empty."
            log_action "Job submission failed - empty Job Name"
            continue
        fi


        # Get Execution Time

        read -p "Enter Estimated Execution Time (seconds): " EXECUTION_TIME

        # Check execution time

        if ! [[ "$EXECUTION_TIME" =~ ^[0-9]+$ ]]
        then
            echo "Invalid execution time."
            echo "Please enter a positive number."

            log_action "Invalid execution time entered: $EXECUTION_TIME"

            continue
        fi

	if [ "$EXECUTION_TIME" -le 0 ]
        then
            echo "Execution time must be greater than 0."

            log_action "Invalid execution time entered: $EXECUTION_TIME"

            continue
        fi


        # Get Priority

        read -p "Enter Priority (1-10): " PRIORITY


        # Check priority

        if ! [[ "$PRIORITY" =~ ^[0-9]+$ ]]
        then
            echo "Invalid priority."
            echo "Priority must be between 1 and 10."

            log_action "Invalid priority entered: $PRIORITY"

            continue
        fi


	if [ "$EXECUTION_TIME" -le 0 ]
        then
            echo "Execution time must be greater than 0."

            log_action "Invalid execution time entered: $EXECUTION_TIME"

            continue
        fi


	# Store job in queue

        echo "$STUDENT_ID|$JOB_NAME|$EXECUTION_TIME|$PRIORITY" >> "$QUEUE_FILE"


        # Display submission

        
        echo "=============================================="
        echo "          JOB SUBMITTED SUCCESSFULLY"
        echo "=============================================="
        echo "Student ID      : $STUDENT_ID"
        echo "Job Name        : $JOB_NAME"
        echo "Execution Time  : $EXECUTION_TIME seconds"
        echo "Priority        : $PRIORITY"
        echo "=============================================="


        # Log job submission

        log_action "Job submitted - Student ID: $STUDENT_ID, Job: $JOB_NAME, Scheduling: Pending, Priority: $PRIORITY"


    # CHOICE 3 - ROUND ROBIN SCHEDULING
    # ======================================================

    elif [ "$CHOICE" = "3" ]
    then

       
        echo "=============================================="
        echo "          ROUND ROBIN SCHEDULING"
        echo "=============================================="
        echo "Time Quantum: 5 seconds"
        echo "=============================================="


        # Check whether jobs exist

        if [ ! -s "$QUEUE_FILE" ]
        then
            echo "No pending jobs to process."

            log_action "Round Robin scheduling requested but queue was empty"

            continue
        fi


        # Temporary file for Round Robin processing

        TEMP_FILE="round_robin_queue.txt"
	
	 cp "$QUEUE_FILE" "$TEMP_FILE"


        # Continue until temporary queue becomes empty

        while [ -s "$TEMP_FILE" ]
        do

            NEW_QUEUE="round_robin_new.txt"

            # Create empty new queue

            > "$NEW_QUEUE"


            # Read each job

            while IFS='|' read -r STUDENT_ID JOB_NAME EXECUTION_TIME PRIORITY
            do

               
                echo "----------------------------------------------"
                echo "Student ID     : $STUDENT_ID"
                echo "Job Name       : $JOB_NAME"
                echo "Remaining Time : $EXECUTION_TIME seconds"
                echo "Priority       : $PRIORITY"
                echo "----------------------------------------------"

		# If execution time is less than or equal to quantum

                if [ "$EXECUTION_TIME" -le "$TIME_QUANTUM" ]
                then

                    echo "Executing for $EXECUTION_TIME seconds..."

                    sleep "$EXECUTION_TIME"

                    echo "Job completed."


                    # Add completed job

                    echo "$(date '+%Y-%m-%d %H:%M:%S')|$STUDENT_ID|$JOB_NAME|$EXECUTION_TIME|$PRIORITY|Round Robin|Completed" >> "$COMPLETED_FILE"


                    # Log execution

                    log_action "Executed job - Student ID: $STUDENT_ID, Job: $JOB_NAME, Scheduling: Round Robin, Execution Time: $EXECUTION_TIME seconds"


                else
			 # Execute only for 5 seconds

                    echo "Executing for $TIME_QUANTUM seconds..."

                    sleep "$TIME_QUANTUM"


                    # Calculate remaining time

                    REMAINING_TIME=$((EXECUTION_TIME - TIME_QUANTUM))


                    echo "Time remaining: $REMAINING_TIME seconds"


                    # Put job back into queue

                    echo "$STUDENT_ID|$JOB_NAME|$REMAINING_TIME|$PRIORITY" >> "$NEW_QUEUE"


                    # Log execution

                    log_action "Executed 5-second time slice - Student ID: $STUDENT_ID, Job: $JOB_NAME, Scheduling: Round Robin, Remaining Time: $REMAINING_TIME seconds"

                fi

            done < "$TEMP_FILE"

	     # Replace old temporary queue

            mv "$NEW_QUEUE" "$TEMP_FILE"

        done


        # Remove temporary file

        rm -f "$TEMP_FILE"


        # Clear pending queue

        > "$QUEUE_FILE"



        echo "=============================================="
        echo "   ROUND ROBIN PROCESSING COMPLETED"
        echo "=============================================="


        log_action "Round Robin scheduling completed"


    # CHOICE 4 - PRIORITY SCHEDULING
    # ======================================================

    elif [ "$CHOICE" = "4" ]
    then


        echo "=============================================="
        echo "           PRIORITY SCHEDULING"
        echo "=============================================="
        echo "Priority 1 = Highest"
        echo "Priority 10 = Lowest"
        echo "=============================================="


        # Check whether jobs exist

        if [ ! -s "$QUEUE_FILE" ]
        then
            echo "No pending jobs to process."

            log_action "Priority scheduling requested but queue was empty"

            continue
        fi


        # Temporary sorted queue

        SORTED_FILE="priority_queue.txt"

	# Sort jobs by priority
        # Priority 1 will come before Priority 2, etc.

        sort -t'|' -k4,4n "$QUEUE_FILE" > "$SORTED_FILE"


        echo
        echo "Jobs will be processed according to priority."
        echo


        # Read sorted jobs

        while IFS='|' read -r STUDENT_ID JOB_NAME EXECUTION_TIME PRIORITY
        do

            echo "----------------------------------------------"
            echo "Student ID     : $STUDENT_ID"
            echo "Job Name       : $JOB_NAME"
            echo "Execution Time : $EXECUTION_TIME seconds"
            echo "Priority       : $PRIORITY"
            echo "----------------------------------------------"


            echo "Executing job..."

            sleep "$EXECUTION_TIME"


            echo "Job completed."

	    # Store completed job

            echo "$(date '+%Y-%m-%d %H:%M:%S')|$STUDENT_ID|$JOB_NAME|$EXECUTION_TIME|$PRIORITY|Priority|Completed" >> "$COMPLETED_FILE"


            # Log execution

            log_action "Executed job - Student ID: $STUDENT_ID, Job: $JOB_NAME, Scheduling: Priority, Priority: $PRIORITY, Execution Time: $EXECUTION_TIME seconds"


        done < "$SORTED_FILE"


        # Remove temporary sorted file

        rm -f "$SORTED_FILE"


        # Clear pending queue

        > "$QUEUE_FILE"



        echo "=============================================="
        echo "    PRIORITY PROCESSING COMPLETED"
        echo "=============================================="


        log_action "Priority scheduling completed"





       





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
#memo:- tempory end. start here
done


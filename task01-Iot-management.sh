#!/bin/bash

# Process Monitoring and Management Tool

LOG_FILE="system_monitor_log.txt"

# Record actions in log file
log_action()
{
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Create log file if it does not exist
if [ ! -f "$LOG_FILE" ]
then
    touch "$LOG_FILE"
fi

# Record program start
log_action "System monitoring program started"

# Main menu
while true
do
   
    echo "=============================================="
    echo "      PROCESS AND LOG MANAGEMENT SYSTEM"
    echo "=============================================="
    echo "1. Display CPU/Memory Usage and Top 10 Processes"
    echo "2. Terminate Process"
    echo "3. Check Disk Usage and Find Large Log Files"
    echo "4. Archive Large Log Files and Check Archive Size"
    echo "5. Exit"
    echo "=============================================="

    read -p "Enter your choice: " CHOICE

    # ==========================================================
    # CHOICE 1 - CPU AND MEMORY USAGE
    # ==========================================================

    if [ "$CHOICE" = "1" ]
    then
       
        echo "CPU and Memory Usage"
        echo "===================="

        
        echo "CPU Usage:"
        top -bn1 | grep "Cpu(s)"

        
        echo "Memory Usage:"
        free -h

       
        echo "Top 10 Memory Consuming Processes"
        echo "================================="

        ps -eo pid,user,%cpu,%mem,comm --sort=-%mem | head -n 11

        log_action "Checked CPU, memory usage and top 10 memory consuming processes."

    # ==========================================================
    # CHOICE 2 - TERMINATE PROCESS
    # ==========================================================

    elif [ "$CHOICE" = "2" ]
    then
        
        read -p "Enter the PID of the process: " PID

        # Check PID
        if ! [[ "$PID" =~ ^[0-9]+$ ]]
        then
            echo "Invalid PID. Please enter a valid number."
            log_action "Invalid PID entered: $PID"
            continue
        fi

        # Check whether process exists
        if ! ps -p "$PID" > /dev/null 2>&1
        then
            echo "Process with PID $PID does not exist."
            log_action "Attempted to terminate non-existent PID: $PID"
            continue
        fi

        # Prevent termination of PID 1
        if [ "$PID" = "1" ]
        then
            echo "Error! PID 1 is a critical system process."
            echo "Termination is not allowed."
            log_action "Attempted to terminate critical PID 1"
            continue
        fi

        # Get process name
        PROCESS_NAME=$(ps -p "$PID" -o comm=)

        # Prevent termination of critical processes
        if [ "$PROCESS_NAME" = "systemd" ] || [ "$PROCESS_NAME" = "init" ]
        then
            echo "Error! $PROCESS_NAME is a critical system process."
            echo "Termination is not allowed."
            log_action "Attempted to terminate critical process $PROCESS_NAME (PID $PID)"
            continue
        fi

        # Display process information
       
        echo "Process Information"
        echo "==================="
        ps -p "$PID" -o pid,user,%cpu,%mem,comm

        # Confirmation
        
        read -p "Are you sure you want to terminate this process? (y/n): " CONFIRM

        if [ "$CONFIRM" = "y" ] || [ "$CONFIRM" = "Y" ]
        then
            if kill "$PID" 2>/dev/null
            then
                echo "Process $PID has been terminated."
                log_action "Terminated process $PROCESS_NAME (PID $PID)"
            else
                echo "Failed to terminate process $PID."
                echo "You may need administrator privileges."
                log_action "Failed to terminate process $PROCESS_NAME (PID $PID)"
            fi
        else
            echo "Process termination cancelled."
            log_action "Cancelled termination of process $PROCESS_NAME (PID $PID)"
        fi

    # ==========================================================
    # CHOICE 3 - DISK USAGE AND LARGE LOG FILES
    # ==========================================================

    elif [ "$CHOICE" = "3" ]
    then

        
        echo "======================================"
        echo "          DISK USAGE"
        echo "======================================"

        
        echo "Directory:"
        echo "$LOG_DIR"

        
        echo "Total Directory Size:"
        du -sh "$LOG_DIR"

        
        echo "======================================"
        echo "     LOG FILES LARGER THAN 50MB"
        echo "======================================"

        # Check whether large log files exist
        LARGE_FILE_COUNT=$(find "$LOG_DIR" -type f -name "*.log" -size +50M -print | wc -l)

        if [ "$LARGE_FILE_COUNT" -eq 0 ]
        then
           
            echo "No .log files larger than 50MB were found."
        else
            
            echo "Found $LARGE_FILE_COUNT large log file(s):"
            echo

            find "$LOG_DIR" -type f -name "*.log" -size +50M -exec ls -lh {} \;
        fi

        log_action "Checked disk usage and large log files in $LOG_DIR"

    # ==========================================================
    # CHOICE 4 - ARCHIVE LARGE LOG FILES
    # ==========================================================

    elif [ "$CHOICE" = "4" ]
    then
        
        read -p "Enter the log directory path: " LOG_DIR

        # Remove accidental trailing slash
        LOG_DIR="${LOG_DIR%/}"

        # Check directory
        if [ ! -d "$LOG_DIR" ]
        then
            
            echo "ERROR: Directory does not exist."
            echo "Path entered: $LOG_DIR"

            log_action "Attempted to archive files from non-existent directory: $LOG_DIR"
            continue
        fi

        # Create ArchiveLogs directory
        ARCHIVE_DIR="ArchiveLogs"

        if [ ! -d "$ARCHIVE_DIR" ]
        then
            mkdir -p "$ARCHIVE_DIR"

            if [ $? -ne 0 ]
            then
                echo "ERROR: Could not create ArchiveLogs directory."
                log_action "Failed to create ArchiveLogs directory"
                continue
            fi

            echo "ArchiveLogs directory created."
            log_action "Created ArchiveLogs directory"
        fi

        
        echo "======================================"
        echo "       SEARCHING LARGE LOG FILES"
        echo "======================================"

        # Count large log files
        LARGE_FILE_COUNT=$(find "$LOG_DIR" -type f -name "*.log" -size +50M -print | wc -l)

        if [ "$LARGE_FILE_COUNT" -eq 0 ]
        then
            
            echo "No .log files larger than 50MB were found."

            log_action "No large log files found in $LOG_DIR"
        else
            
            echo "Found $LARGE_FILE_COUNT large log file(s)."

            
            echo "Files to be archived:"
            echo "---------------------"

            find "$LOG_DIR" -type f -name "*.log" -size +50M -exec ls -lh {} \;

            # Create timestamp
            TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

            # Create archive name
            ARCHIVE_NAME="$ARCHIVE_DIR/Logs_$TIMESTAMP.tar.gz"

           
            echo "Creating archive..."
            echo "Archive: $ARCHIVE_NAME"

            # Create archive safely
            find "$LOG_DIR" -type f -name "*.log" -size +50M -print0 | \
                tar --null -czf "$ARCHIVE_NAME" --files-from=-

            # Check whether tar was successful
            if [ $? -eq 0 ]
            then
               
                echo "======================================"
                echo "       ARCHIVE CREATED SUCCESSFULLY"
                echo "======================================"

                
                echo "Archive file:"
                echo "$ARCHIVE_NAME"

                
                echo "Archive size:"
                du -h "$ARCHIVE_NAME"

                log_action "Archived large log files from $LOG_DIR into $ARCHIVE_NAME"
            else
                
                echo "ERROR: Failed to create archive."

                # Remove incomplete archive
                rm -f "$ARCHIVE_NAME"

                log_action "Failed to archive large log files from $LOG_DIR"
            fi
        fi

        # ======================================================
        # CHECK ARCHIVE DIRECTORY SIZE
        # ======================================================

        
        echo "======================================"
        echo "       ARCHIVELOGS DIRECTORY SIZE"
        echo "======================================"

        du -sh "$ARCHIVE_DIR"

        # Get size in bytes
        SIZE=$(du -s -B1 "$ARCHIVE_DIR" | cut -f1)

        # Check whether size is greater than 1GB
        if [ "$SIZE" -gt 1073741824 ]
        then
            echo
            echo "WARNING!"
            echo "ArchiveLogs directory is larger than 1GB."

            log_action "WARNING: ArchiveLogs directory is larger than 1GB"
        else
            echo
            echo "ArchiveLogs directory is within the 1GB limit."
        fi

    # ==========================================================
    # CHOICE 5 - EXIT
    # ==========================================================

    elif [ "$CHOICE" = "5" ]
    then
       
        read -p "Are you sure you want to exit? (y/n): " EXIT_CONFIRM

        if [ "$EXIT_CONFIRM" = "Y" ] || [ "$EXIT_CONFIRM" = "y" ]
        then
           
            echo "Bye! Thank you for using the system."

            log_action "User exited from system"

            break
        else
            
            echo "Exit cancelled."

            log_action "User cancelled exit"
        fi

    # ==========================================================
    # INVALID CHOICE
    # ==========================================================

    else
       
        echo "Invalid choice."
        echo "Please select 1, 2, 3, 4, or 5."

        log_action "Invalid menu option selected: $CHOICE"
    fi

done






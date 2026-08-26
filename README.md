AOS-Assessment
│
├── task01-IoT-management.sh        
├── task02-Job_scheduler.sh      
│
├── Task_3/                                                            
│   ├── login_log.txt                  
│   ├── submission_log.txt             
│   ├── task-03Auth.py                  
│   └── task03-submission.sh             
│                
│
├── job_queue.txt                        
├── scheduler_log.txt           
└── system_monitor_log.txt  

How To run files (in Terminal) 
Task01
chmod +X task01-Iot-management.sh
./task01-Iot-managemen.sh

Task02
chmod +X task02-Job_scheduler.sh
./task02-Job_scheduler.sh

Task03
chmod +X task03-submission.sh
./task03-submission.sh

Task 01 is monitoring systems in IOT devises. It monitor and logs  CPU usage, memory consumption, disk utilisation, and running process states. All monitoring events are written to system_monitor_log.txt with timestamps. 

Task 02 is scheduling system's jobs and keep login, job queues log in job_queue.txt and completed tasks are log in completed_jobs.txt and the fully execution process maintained log in scheduler_log.txt.

Task 03 is combined with bash script and python script.  Python script doing user login, credential verification, and account state management,  Bash script that manages the submission workflow  validating, processing, and logging file submissions. submission_log.txt log submissions with timestamps, login_log.txt keep records of logins with timestamps.

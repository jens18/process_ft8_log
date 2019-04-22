# process_ft8_log

Upload FT8 QSO log data to AARL LoTW server.
                                                                                                                                                                                                                                                            
# SYNOPSIS                                                                                                                                   

$ bash ./process_wsjtx_log.sh                                                                                                                
                                                                                                                                           
# DESCRIPTION                                                                                                                                
Automated upload of new QSO records to LoTW (AARL Log book Of The World)                                                                   
and automated backup of full WSJTX QSO log. This program can be                                                                            
run any number of times. It will detect if there are no new QSOs                                                                           
and exit without starting the TQSL upload or updating the TIMESTAMP_FILE.                                                                  
The TIMESTAMP_FILE is only updated after a successful upload to LoTW.                                                                      
                                                                                                                                           
# REQUIREMENTS                                                                                                                               
- (password less) SSH enabled host                                                                                                         
- LoTW keyfiles, working TQSL client tool                                                                                                  
                                                                                                                                           
# ASSUMPTIONS                                                                                                                                
The WSJTX logfile is the master log file, contains all of the QSOs                                                                         
and is never reset.                                                                                                                        
                                                                                                                                            
# CONFIGURATION                                                                                                                              
See "configuration begin/end" section below.                                                                                               
                                                                                                                                           
# EXAMPLE OUTPUT                                                                                                                             
$ bash ~/process_wsjtx_log.sh                                                                                                              
0. current date_time: 040419_134420 previous date_time 040419_093426                                                                       
pi@192.168.29.134's password:                                                                                                              
wsjtx_log.adi                                                                             100%   43KB   8.2MB/s   00:00  #                 
1. transferred /home/jens/Projects/wsjtx_backup/wsjtx_log_040419_134420.adi: 165 QSOs                                                      
2. created /home/jens/Projects/wsjtx_backup/wsjtx_log_040419_134420_diff.adi: 4 QSOs                                                       
3. upload of /home/jens/Projects/wsjtx_backup/wsjtx_log_040419_134420_diff.adi to LoTW:                                                    
4. setting new timestamp to CURR_DATE 040419_134420                                                                                        
TQSL Version 2.4.3 [pkg-v2.4.3]                                                                                                            
Signing using Callsign KM6ZJV, DXCC Entity UNITED STATES OF AMERICA                                                                        
                                                                                                                                            
Attempting to upload 4 QSOs                                                                                                                
/home/jens/Projects/wsjtx_backup/wsjtx_log_040419_134420_diff.adi: Log uploaded successfully with result:                                  
                                                                              

# NAME
# process_ft8_log
#
# SYNOPSIS
# bash ./process_ft8_log.sh
#
# DESCRIPTION
# Automated upload of new QSO records to LoTW (AARL Log book Of The World)
# and automated backup of full WSJTX QSO log. This program can be
# run any number of times. It will detect if there are no new QSOs
# and exit without starting the TQSL upload or updating the TIMESTAMP_FILE.
# The TIMESTAMP_FILE is only updated after a successful upload to LoTW.
# 
# REQUIREMENTS
# - (password less) SSH enabled host
# - LoTW keyfiles, working TQSL client tool
#
# ASSUMPTIONS
# The WSJTX logfile is the master log file, contains all of the QSOs
# and is never reset.
#
# CONFIGURATION
# See "configuration begin/end" section below.
#
# EXAMPLE OUTPUT
# $ bash ~/process_ft8_log.sh
# 0. current date_time: 040419_134420 previous date_time 040419_093426
# pi@192.168.29.134's password: 
# wsjtx_log.adi                                                                             100%   43KB   8.2MB/s   00:00  #  
# 1. transferred /home/jens/Projects/wsjtx_backup/wsjtx_log_040419_134420.adi: 165 QSOs
# 2. created /home/jens/Projects/wsjtx_backup/wsjtx_log_040419_134420_diff.adi: 4 QSOs
# 3. upload of /home/jens/Projects/wsjtx_backup/wsjtx_log_040419_134420_diff.adi to LoTW:
# 4. setting new timestamp to CURR_DATE 040419_134420
# TQSL Version 2.4.3 [pkg-v2.4.3]
# Signing using Callsign KM6ZJV, DXCC Entity UNITED STATES OF AMERICA
# 
# Attempting to upload 4 QSOs
# /home/jens/Projects/wsjtx_backup/wsjtx_log_040419_134420_diff.adi: Log uploaded successfully with result:
# 
# File queued for processing
# After reading this message, you may close this program.
# Final Status: Success (0)
#
# EXAMPLE FILES
# BACKUP_DIR/.process_wsjtx_log                                                             
# BACKUP_DIR/tqsl_result_040419_134420.txt                                                  
# BACKUP_DIR/wsjtx_log_040419_134420.adi                                                    
# BACKUP_DIR/wsjtx_log_040419_134420_diff.adi                                               
#
# AUTHOR
# Jens Kaemmerer (jens@mesgtone.net)
#

#set -x

### configuration begin
BACKUP_DIR="${HOME}/Projects/wsjtx_backup"
TIMESTAMP_FILE=${BACKUP_DIR}/.process_wsjtx_log
TQSL_STATION_LOCATION="Mountain View"
TQSL_CERT_PWD="u5TWJnuC"
CURR_DATE=`date +%m%d%g_%H%M%S`
HOST="192.168.29.134"
LOGIN="pi"
REF_FILE=".local/share/WSJT-X/wsjtx_log.adi"
NC="/bin/nc" # nc to test if HOST is reachable
TQSL="/usr/local/bin/tqsl" # tsql to sign and upload ADI files to LoTW
### configuration end

# first time use: TIMESTAMP_FILE and PREV_FILE do not yet exist
if [ -f ${TIMESTAMP_FILE} ]; then
    PREV_DATE=`cat $TIMESTAMP_FILE`
else
    PREV_DATE=""
fi

echo "0. current date_time: ${CURR_DATE} previous date_time ${PREV_DATE}"

PREV_FILE="${BACKUP_DIR}/wsjtx_log_${PREV_DATE}.adi"
CURR_FILE="${BACKUP_DIR}/wsjtx_log_${CURR_DATE}.adi"
DIFF_FILE="${BACKUP_DIR}/wsjtx_log_${CURR_DATE}_diff.adi"
TQSL_RESULT_FILE="${BACKUP_DIR}/tqsl_result_${CURR_DATE}.txt"

${NC} -z ${HOST} 22
if [ $? -eq 0 ]; then
    scp ${LOGIN}@${HOST}:${REF_FILE} ${CURR_FILE}
    QSO_CNT=`grep call ${CURR_FILE} |wc -l`
    echo "1. transferred ${CURR_FILE}: ${QSO_CNT} QSOs"
else
    echo "1. host ${HOST} not reachable"
    exit 1
fi

# generate DIFF_FILE
if [ -f ${PREV_FILE} ]; then
    diff --changed-group-format='%>' --unchanged-group-format='' ${PREV_FILE} ${CURR_FILE} > ${DIFF_FILE}
else
    echo "2. PREV_FILE ${PREV_FILE} does not exist. Initialize DIFF_FILE ${DIFF_FILE} with CURR_FILE ${CURR_FILE}"
    cp ${CURR_FILE} ${DIFF_FILE}
fi

QSO_CNT=`grep call ${DIFF_FILE} |wc -l`
echo "2. created ${DIFF_FILE}: ${QSO_CNT} QSOs"

# if DIFF_FILE QSO_CNT > 0 -> upload to LoTW
if [ ${QSO_CNT} -gt 0 ]; then
    echo "3. upload of ${DIFF_FILE} to LoTW:"
    
    ${TQSL} -d -u -a abort -p "${TQSL_CERT_PWD}" -x -l "${TQSL_STATION_LOCATION}" "${DIFF_FILE}" 2>${TQSL_RESULT_FILE}

    # check TQSL error code and save new date (warning: this is not a transaction ...)
    if [ $? -eq 0 ]; then
	echo "4. setting new timestamp to CURR_DATE ${CURR_DATE}"
	echo $CURR_DATE > ${TIMESTAMP_FILE}
    fi

    cat ${TQSL_RESULT_FILE}
fi
  

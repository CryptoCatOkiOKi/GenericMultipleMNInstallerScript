#!/bin/bash

RED='\033[1;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
YELLOW='\033[1;33m'
BROWN='\033[0;34m'
NC='\033[0m' # No Color

TOTALMEM=0
TOTALCPU=0
COUNTER=0
COIN=$1
NUMBOFCPUCORES=$(cat /proc/cpuinfo | awk '/^processor/{print $3}' | wc -l)

if [ -z "$COIN" ]; then
   COIN="daemon"
fi

echo "COIN=${COIN}"

for PID in `ps -ef | grep -i ${COIN} | grep daemon | grep conf | grep -v grep | awk '{printf "%d\n", $2}'`; do
   echo "PID=${PID}"
   PIDMEM=$(cat /proc/${PID}/status |grep VmRSS | awk '{printf "%d\n", $2}')
   echo "PIDMEM=${PIDMEM}"
   # TOTALMEM=$[TOTALMEM + PIDMEM]
   TOTALMEM=$(expr ${TOTALMEM} + ${PIDMEM})

   PIDCPU=$(echo `ps -p ${PID} -o %cpu | grep -v CPU |awk '{printf "%0.2f\n", $1}'`)
   echo "PIDCPU=${PIDCPU}"
   # TOTALCPU=$(expr ${TOTALCPU} + ${PIDCPU})
   TOTALCPU=$(echo "${TOTALCPU} + ${PIDCPU}" | bc)

   COUNTER=$[COUNTER + 1]
done
echo "----------------------------------------"
echo "TOTALNODES=${COUNTER}"
echo "TOTALMEM=${TOTALMEM} Kb"
echo "TOTALMEM=${NUMBOFCPUCORES}"

TOTALCPU=$(echo "${TOTALCPU} / ${NUMBOFCPUCORES}" |bc)
echo "TOTALCPU=${TOTALCPU}%"

TOTALMEMMB=$(expr ${TOTALMEM} / 1024)
echo "TOTALMEMMB=${TOTALMEMMB} Mb"

AVERAGEMEMMB=$(expr ${TOTALMEMMB} / ${COUNTER})
echo "AVERAGEMEMMB=${AVERAGEMEMMB} Mb"

AVERAGECPU=$(echo "${TOTALCPU} / ${COUNTER}" |bc -l)
echo "AVERAGECPU=${AVERAGECPU}% per node"

TOTALMEMGB=$(expr ${TOTALMEMMB} / 1024)
echo "TOTALMEMGB=${TOTALMEMGB} Gb"

FREEMEMMB=$(free -m | grep Mem | awk '{printf "%d\n", $4}')
echo "FREEMEMMB=${FREEMEMMB} Mb"
NUMOFFREENODESMEM=$(expr ${FREEMEMMB} / ${AVERAGEMEMMB})
NUMOFFREENODESCPU=$(echo "100 / ${AVERAGECPU}" | bc)
echo -e "${YELLOW}Based on free memory, this server can host approx. ${RED}${NUMOFFREENODESMEM}${NC} additional nodes"
echo -e "${YELLOW}Based on free CPU, this server can host approx. ${RED}${NUMOFFREENODESCPU}${NC} additional nodes"
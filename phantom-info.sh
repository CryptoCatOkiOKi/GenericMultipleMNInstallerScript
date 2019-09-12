#!/bin/bash

PARAM1=$1
PARAM2=$2
PARAM2=${PARAM2,,} 
COUNTER_PHANTOM=0
COUNTER_STRIKE="OK"

strindex() { 
  x="${1%%$2*}"
  [[ "$x" = "$1" ]] && STRINDEX=-1 || STRINDEX="${#x}"
}

for PHANTOM in `ps -ef | grep -i phantom | grep masternode_conf | grep coin_conf | grep -v grep | awk '{printf "%d\n", $2}'`; do
   COUNTER_PHANTOM=$[COUNTER_PHANTOM + 1]
   for PHANTOM_INSTANCE in `ps -ef | grep -i phantom | grep ${PHANTOM} | grep masternode_conf | grep coin_conf | grep -v grep`; do
      echo ${PHANTOM_INSTANCE}
      strindex "${PHANTOM_INSTANCE}" "coin_conf"

      if [ "${STRINDEX}" -gt 0 ]; then
         # echo "Found it!"
         COIN_CONF_DIR=$(echo ${PHANTOM_INSTANCE} | cut -d"=" -f2)
         echo "COIN_CONF_DIR=${COIN_CONF_DIR}"
         COIN_NAME=$(cat ${COIN_CONF_DIR} | jq -r ".name")
         echo "COIN_NAME=${COIN_NAME}"
      fi

      echo ${PHANTOM_INSTANCE}
      strindex "${PHANTOM_INSTANCE}" "masternode_conf"

      if [ "${STRINDEX}" -gt 0 ]; then
         # echo "Found it!"
         MASTERNODE_CONF_DIR=$(echo ${PHANTOM_INSTANCE} | cut -d"=" -f2)
         echo "MASTERNODE_CONF_DIR=${MASTERNODE_CONF_DIR}"
      fi   
   done

   if [ "${PARAM1}" == "COIN_CONF" ]; then
      if [ "${COUNTER_PHANTOM}" == 1 ]; then
         COIN_CONF=$(cat ${COIN_CONF_DIR})
         OUTPUT="[ ${COIN_CONF}"
      else
         COIN_CONF=$(cat ${COIN_CONF_DIR})
         OUTPUT="${OUTPUT}, ${COIN_CONF}"
      fi
   fi

   if [ "${PARAM1}" == "MASTERNODE_CONF" ]; then
      #MASTERNODE_CONF_DIR="/root/test.txt" # just for testing !!! remove after!
      MASTERNODE_CONF=$(cat ${MASTERNODE_CONF_DIR})
      echo -e "[ ${MASTERNODE_CONF} ]"

      COUNTER=0
      COUNTER_LINE=0

      if [ -z "${PARAM2}" ] || [ "${PARAM2}" == "${COIN_NAME,,}" ]; then
         for MASTERNODE_CONF_LINE in `echo ${MASTERNODE_CONF}`; do
            echo -e "${MASTERNODE_CONF_LINE}"
            COUNTER=$[COUNTER + 1]
            if [ "${COUNTER}" == 1 ]; then
               if [ "${COUNTER_LINE}" == 0 ]; then
                  if [ "${COUNTER_PHANTOM}" == 1 ] || [ "${COUNTER_STRIKE}" == "OK" ]; then
                     OUTPUT="[ "
                     COUNTER_STRIKE="DONE"
                  else
                     OUTPUT="${OUTPUT} ,"
                  fi
               else
                  OUTPUT="${OUTPUT} ,"
               fi
               OUTPUT="${OUTPUT}{ \"NAME\": \"${COIN_NAME}\""
               OUTPUT="${OUTPUT}, \"ALIAS\": \"${MASTERNODE_CONF_LINE}\""
               COUNTER_LINE=$[COUNTER_LINE + 1]
            elif [ "${COUNTER}" == 2 ]; then
               OUTPUT="${OUTPUT}, \"IP\": \"${MASTERNODE_CONF_LINE}\""
            elif [ "${COUNTER}" == 3 ]; then
               OUTPUT="${OUTPUT}, \"MNPRIVKEY\": \"${MASTERNODE_CONF_LINE}\""
            elif [ "${COUNTER}" == 4 ]; then
               OUTPUT="${OUTPUT}, \"TX\": \"${MASTERNODE_CONF_LINE}\""
            elif [ "${COUNTER}" == 5 ]; then
               OUTPUT="${OUTPUT}, \"TXID\": ${MASTERNODE_CONF_LINE}"
            elif [ "${COUNTER}" == 6 ]; then
               OUTPUT="${OUTPUT}, \"TIMESTAMP\": ${MASTERNODE_CONF_LINE} }"
               COUNTER=0
            fi
         done
      fi
   fi
done

OUTPUT="${OUTPUT} ]"
echo -e "${OUTPUT}"
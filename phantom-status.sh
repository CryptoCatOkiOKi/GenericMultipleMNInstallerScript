#!/bin/bash

COUNTER_PHANTOM=0

for PHANTOM in `systemctl list-units -all --state=active | grep phantom | grep loaded | awk '{printf "%s\n", $1}'`; do
   COUNTER_PHANTOM=$[COUNTER_PHANTOM + 1]
   #echo $PHANTOM

   if [ "${COUNTER_PHANTOM}" == 1 ]; then
      OUTPUT="[ { \"name\": \"${PHANTOM}\" "
   else
      OUTPUT="${OUTPUT}, { \"name\": \"${PHANTOM}\" "
   fi

   OUTPUT="${OUTPUT}, \"active\": true "

   VERSION_005=$(systemctl status ${PHANTOM} | grep masternodes.txt | grep phantom-linux-amd64 | wc -l)

   if [ "${VERSION_005}" == 0 ]; then
      VERSION_010=$(systemctl status ${PHANTOM} | grep masternodes.txt | grep phantom1 | wc -l)

      if [ "${VERSION_010}" == 0 ]; then
         OUTPUT="${OUTPUT}, \"version\": \"n/a\" "
      else
         OUTPUT="${OUTPUT}, \"version\": \"phantom v0.1.0\" " 
      fi      
   else
      OUTPUT="${OUTPUT}, \"version\": \"phantom v0.0.5\" " 
   fi

   OUTPUT="${OUTPUT} }"

done

for PHANTOM in `systemctl list-units -all --state=inactive | grep phantom | grep loaded | awk '{printf "%s\n", $1}'`; do
   COUNTER_PHANTOM=$[COUNTER_PHANTOM + 1]
   #echo $PHANTOM

   if [ "${COUNTER_PHANTOM}" == 1 ]; then
      OUTPUT="[ { \"name\": \"${PHANTOM}\" "
   else
      OUTPUT="${OUTPUT}, { \"name\": \"${PHANTOM}\" "
   fi

   OUTPUT="${OUTPUT}, \"active\": false "

   OUTPUT="${OUTPUT} }"

done

OUTPUT="${OUTPUT} ]"
echo -e "${OUTPUT}"
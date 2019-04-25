#!/bin/bash

# NAME="bitcoingreen"
# NAMEALIAS="bitg"
# URL="https://github.com/bitcoingreen/bitcoingreen/releases/download/v1.3.0/bitcoingreen-1.3.0-x86_64-linux-gnu.tar.gz"
# WALLETDL="bitcoingreen-1.3.0-x86_64-linux-gnu.tar.gz"
# WALLETDLFOLDER="bitcoingreen-1.3.0"

RED='\033[1;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
YELLOW='\033[1;33m'
BROWN='\033[0;34m'
NC='\033[0m' # No Color

cd ~
echo "*****************************************************************************"
echo "* Ubuntu 16.04 is the recommended operating system for this install.        *"
echo "*                                                                           *"
echo "* This script will install and configure your ${NAME} Coin masternodes.     *"
echo "*****************************************************************************"
echo && echo && echo
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!                                                 !"
echo "! Make sure you double check before hitting enter !"
echo "!                                                 !"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo && echo && echo

if [[ $(lsb_release -d) != *16.04* ]]; then
  echo -e "${RED}The operating system is not Ubuntu 16.04. You must be running on Ubuntu 16.04.${NC}"
  exit 1
fi

## Setup conf
mkdir -p ~/bin
rm ~/bin/masternode_config.txt &>/dev/null &
IP=$(curl -s4 icanhazip.com)
COUNTER=1
CONF_DIR_ONE=""
CONF_DIR=""
MNCOUNT=""
REBOOTRESTART=""
STARTNUMBER=""
re='^[0-9]+$'

echo ""
echo -e "${YELLOW}Enter coin name:${NC}"
read NAME 

while ! [[ $MNCOUNT =~ $re ]] ; do
   echo ""
   echo -e "${YELLOW}How many nodes do you want to create on this server?, followed by [ENTER]:${NC}"
   read MNCOUNT 
done

while ! [[ $STARTNUMBER =~ $re ]] ; do
   echo ""
   echo -e "${YELLOW}Enter the starting number: (e.g. 1 -> nodes will start with alias mn1, mn2,...)${NC}"
   read STARTNUMBER  
done

while ! [[ $PORT =~ $re ]] ; do
   echo ""
   PORT=""
   echo -e "${YELLOW}Enter starting port:(e.g. 16100)${NC}"
   read PORT
done

while ! [[ $RPCPORT =~ $re ]] ; do
   echo ""
   RPCPORT=""
   echo -e "${YELLOW}Enter starting RPC port:(e.g. 17100)${NC}"
   read RPCPORT
done

if [ $PORT == "$RPCPORT" ]
then
   echo -e "${RED}PORT must be different then RPCPORT!${NC}"
   exit 1
fi

echo ""
ALIASONE=""
echo -e "${YELLOW}Enter blockchain wallet alias for copying chain to new wallets: (e.g. mn0 or mn1)${NC}"
read ALIASONE

# check ALIASONE
CONF_DIR_ONE=~/.${NAME}_$ALIASONE
echo "CONF_DIR_ONE=$CONF_DIR_ONE"
CONF_DIR_ONE_TMP=~/"${NAME}_${ALIASONE}_tmp"
echo "CONF_DIR_ONE_TMP=$CONF_DIR_ONE_TMP"

PID=`ps -ef | grep -i $ALIASONE | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`

if [ -z "$PID" ]; then
   echo ""
else
   # stop wallet
   sh ~/bin/${NAME}-cli_$ALIASONE.sh stop
   sleep 1
fi

# create temp folder for blockchain
rm -R $CONF_DIR_ONE_TMP
mkdir -p $CONF_DIR_ONE_TMP
cp -R $CONF_DIR_ONE/* $CONF_DIR_ONE_TMP/
rm -R $CONF_DIR_ONE_TMP/${NAME}.conf
rm -R $CONF_DIR_ONE_TMP/debug.log
rm -R $CONF_DIR_ONE_TMP/wallet.dat
rm -R $CONF_DIR_ONE_TMP/backups
rm -R $CONF_DIR_ONE_TMP/mnpayments.dat
rm -R $CONF_DIR_ONE_TMP/mncache.dat
rm -R $CONF_DIR_ONE_TMP/masternode.conf
rm -R $CONF_DIR_ONE_TMP/fee_estimates.dat
rm -R $CONF_DIR_ONE_TMP/db.log
rm -R $CONF_DIR_ONE_TMP/communityvote.dat
rm -R $CONF_DIR_ONE_TMP/budget.dat
rm -R $CONF_DIR_ONE_TMP/banlist.dat

# start wallet
sh ~/bin/${NAME}d_$ALIASONE.sh
sleep 1

BREAKNUMBER=$[MNCOUNT + 9]
echo "BREAKNUMBER=$BREAKNUMBER"

for (( ; ; ))
do 

   # read -n 1 -s -r -p "****Press any key to install ${STARTNUMBER}*****"
	if [[ "$COUNTER" -gt "$MNCOUNT" ]]; then
	  break
	fi	

   for (( ; ; ))
   do  
      echo "************************************************************"
      echo ""
      EXIT='NO'
      ALIAS="MN$STARTNUMBER"
      ALIAS=${ALIAS,,}  
      echo $ALIAS

      # check ALIAS
      if [[ "$ALIAS" =~ [^0-9A-Za-z]+ ]] ; then
         echo -e "${RED}$ALIAS has characters which are not alphanumeric. Please use only alphanumeric characters.${NC}"
         EXIT='YES'
	   elif [ -z "$ALIAS" ]; then
	      echo -e "${RED}$ALIAS in empty!${NC}"
         EXIT='YES'
      else
	      CONF_DIR=~/.${NAME}_$ALIAS
	  
         if [ -d "$CONF_DIR" ]; then
            echo -e "${RED}$ALIAS is already used. $CONF_DIR already exists!${NC}"
            EXIT='YES'
         else
            # OK !!!
            break
         fi	
      fi  
   done

   if [ $EXIT == 'YES' ]
   then
      exit 1
   fi

   PORT1=""
   for (( ; ; ))
   do
      PORT1=$(netstat -peanut | grep -i $PORT)

      if [ -z "$PORT1" ]; then
         break
      else
         PORT=$[PORT + 1]
      fi
   done  
   echo "PORT "$PORT 

   RPCPORT1=""
   for (( ; ; ))
   do
      RPCPORT1=$(netstat -peanut | grep -i $RPCPORT)

      if [ -z "$RPCPORT1" ]; then
         break
      else
         RPCPORT=$[RPCPORT + 1]
      fi
   done  
   echo "RPCPORT "$RPCPORT

   PRIVKEY=""
   echo ""

   CONF_FILE=${NAME}.conf
  
   # Create scripts
   echo '#!/bin/bash' > ~/bin/${NAME}d_$ALIAS.sh
   echo "${NAME}d -daemon -conf=$CONF_DIR/${NAME}.conf -datadir=$CONF_DIR "'$*' >> ~/bin/${NAME}d_$ALIAS.sh
   echo "${NAME}-cli -conf=$CONF_DIR/${NAME}.conf -datadir=$CONF_DIR "'$*' > ~/bin/${NAME}-cli_$ALIAS.sh
   chmod 755 ~/bin/${NAME}*.sh

   mkdir -p $CONF_DIR
   echo "rpcuser=user"`shuf -i 100000-10000000 -n 1` >> ${NAME}.conf_TEMP
   echo "rpcpassword=pass"`shuf -i 100000-10000000 -n 1` >> ${NAME}.conf_TEMP
   echo "rpcallowip=127.0.0.1" >> ${NAME}.conf_TEMP
   echo "rpcport=$RPCPORT" >> ${NAME}.conf_TEMP
   echo "listen=1" >> ${NAME}.conf_TEMP
   echo "server=1" >> ${NAME}.conf_TEMP
   echo "daemon=1" >> ${NAME}.conf_TEMP
   echo "logtimestamps=1" >> ${NAME}.conf_TEMP
   echo "maxconnections=256" >> ${NAME}.conf_TEMP

   #Extract addnode lines 
   grep "addnode" $CONF_DIR_ONE/${NAME}.conf >> ${NAME}.conf_TEMP

   echo "" >> ${NAME}.conf_TEMP
   echo "port=$PORT" >> ${NAME}.conf_TEMP
  
   if [ -z "$PRIVKEY" ]; then
      echo ""
   else
      echo "masternode=1" >> ${NAME}.conf_TEMP
      echo "masternodeprivkey=$PRIVKEY" >> ${NAME}.conf_TEMP
   fi

   sudo ufw allow $PORT/tcp
   mv ${NAME}.conf_TEMP $CONF_DIR/${NAME}.conf
 
   # generate private key for MN
   if [ -z "$PRIVKEY" ]; then
	   PID=`ps -ef | grep -i $ALIASONE | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
	
	   if [ -z "$PID" ]; then
         # start wallet
         sh ~/bin/${NAME}d_$ALIASONE.sh  
	      sleep 1
	   fi
  
	   for (( ; ; ))
	   do  
	      echo "Please wait ..."
         sleep 1 # wait second 
	      PRIVKEY=$(~/bin/${NAME}-cli_${ALIASONE}.sh masternode genkey)
	      echo "PRIVKEY=$PRIVKEY"
	      if [ -z "$PRIVKEY" ]; then
	         echo "PRIVKEY is null"
	      else
	         break
         fi
	   done
	
	   sleep 1
	
      # stop wallet and insert mastenode key
      for (( ; ; ))
      do
         PID=`ps -ef | grep -i $ALIAS | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
         if [ -z "$PID" ]; then
            echo ""
         else
            #STOP 
            ~/bin/${NAME}-cli_$ALIAS.sh stop
         fi

         echo "Please wait ..."
         sleep 1 # wait second 
         PID=`ps -ef | grep -i $ALIAS | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
         echo "PID="$PID	
         
         if [ -z "$PID" ]; then
            sleep 1 # wait a second
            echo "masternode=1" >> $CONF_DIR/${NAME}.conf
            echo "masternodeprivkey=$PRIVKEY" >> $CONF_DIR/${NAME}.conf
            break
         fi
      done
   fi
  
   sleep 1 # wait second 
   #check if wallet is running
   PID=`ps -ef | grep -i $ALIAS | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
   echo "PID="$PID
  
   # if running stop it
   for (( ; ; ))
   do   
      if [ -z "$PID" ]; then
         echo ""
      else
         ~/bin/${NAME}-cli_$ALIAS.sh stop
         sleep 1 # wait second 
         PID=`ps -ef | grep -i $ALIAS | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
         echo "PID="$PID           
      fi	 

      if [ -z "$PID" ]; then
         cd $CONF_DIR
         echo "Copy BLOCKCHAIN"
         cp -R $CONF_DIR_ONE_TMP/* $CONF_DIR/

         echo "Start wallet back"
         sh ~/bin/${NAME}d_$ALIAS.sh		
         sleep 1 # wait second
         break
      fi	       
   done 

   MNCONFIG=$(echo $ALIAS $IP:$PORT $PRIVKEY "txhash" "outputidx")
   echo $MNCONFIG >> ~/bin/masternode_config.txt
    
   COUNTER=$[COUNTER + 1]
   STARTNUMBER=$[STARTNUMBER + 1]
   PORT=$[PORT + 1]
   RPCPORT=$[RPCPORT + 1]     

	if [[ "$COUNTER" -gt "$BREAKNUMBER" ]]; then
	  break
	fi	

   sleep 1 # wait second
done

echo ""
echo -e "${YELLOW}****************************************************************"
echo -e "**Copy/Paste lines below in Hot wallet masternode.conf file**"
echo -e "**and replace txhash and outputidx with data from masternode outputs command**"
echo -e "**in hot wallet console**"
echo -e "****************************************************************${NC}"
echo -e "${RED}"
cat ~/bin/masternode_config.txt
echo -e "${NC}"
echo "****************************************************************"
echo ""
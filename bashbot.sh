#!/bin/bash

# bashbot, the Telegram bot written in bash.
# Written by @topkecleon and Juan Potato (@awkward_potato)
# http://github.com/topkecleon/bashbot

# Depends on JSON.sh (http://github.com/dominictarr/JSON.sh),
# which is MIT/Apache-licensed.

# This file is public domain in the USA and all free countries.
# If you're in Europe, and public domain does not exist, then haha.

echo "Telegram bot dir:"$(pwd)
. global
#MESSAGE="$@"
OFFSET=0

{
  res=$(curl "$URL/getMe")
  bot_username=$(echo $res | ./JSON.sh -s | egrep '\["result","username"\]' | cut -f 2 | cut -d '"' -f 2)
} &>/dev/null
echo "Bot username:$bot_username"

#buttons="{\"keyboard\":[[\"sensors\",\"raid_status\"]],\"one_time_keyboard\":true}"

#Starting in stand by mode
prevActiveTime=0

./sendNotify -l2 -t "Bot started"

while true; do {
  newMessage=0
  while [ $newMessage -eq 0 ]; do
    {
      res=$(curl $URL\/getUpdates\?offset=$OFFSET\&limit=1)
      if [ ! "$res" == '{"ok":true,"result":[]}' ]; then
        newMessage=1
        TARGET=$(echo $res | ./JSON.sh | egrep '\["result",0,"message","chat","id"\]' | cut -f 2)
        from=$(echo $res | ./JSON.sh | egrep '\["result",0,"message","from","username"\]' | cut -f 2)
        OFFSET=$(echo $res | ./JSON.sh | egrep '\["result",0,"update_id"\]' | cut -f 2)
        MESSAGE=$(echo $res | ./JSON.sh -s | egrep '\["result",0,"message","text"\]' | cut -f 2 | cut -d '"' -f 2)
        message_id=$(echo $res | ./JSON.sh | egrep '\["result",0,"message","message_id"\]' | cut -f 2 )
        echo "o:$OFFSET r:$res"
      fi
    } &>/dev/null
	done

  curTime=$((10#`date +%s`))
  OFFSET=$((OFFSET+1))
  #echo "$MESSAGE"

  if [ $OFFSET != 1 ]; then
    echo "$OFFSET">lastOffset
    #split MESSAGE by space to array
    msgWords=($MESSAGE)
    cmd=${msgWords[0]}
    #args=("${msgWords[@]:1}") #removed the 1st element
    drive=""
    msg=""
    echo "from:$from Message:$MESSAGE"

    #echo "cmd0:$cmd"
    #args=( $MESSAGE )
    #cmd=${args[0]}
    #args=("${args[@]:1}")
    #echo "cmd:$cmd"
    cmdAr=(${cmd//\@/ })
    cmd=${cmdAr[0]}
    toBot=${cmdAr[1]}
    #echo "cmd1:$cmd toBot:$toBot"

    #Replace _ to space
    cmdAr=(${cmd//_/ })
    cmd=${cmdAr[0]}
    args="${cmdAr[@]:1} ${msgWords[@]:1}" #removed the 1st element
    #remove double spaces, and trailing spaces
    args=$(echo -e "${args}" | sed -e 's/[[:space:]]\+/ /g' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

    #split by spaces
    args=( $args )
    echo "args:${args[@]}"
    OPTARG=${args[0]}

    #echo "c:$cmd t:$toBot"
    if [ ! "$toBot" == "" ] && [ ! "$toBot" == "$bot_username" ]; then
      echo "To other bot $toBot"
      cmd=""
    fi
    nlFile="$nlDir/$TARGET"
    processCommands=0
    if [ -f "$nlFile" ]; then
      processCommands=1
    elif [ ! -f "lockState" ]; then
      processCommands=1
    elif [ `cat lockState` == "unlocked" ]; then
      processCommands=1
    fi

    if [ $processCommands -eq 1 ]; then
      #include a case from file commands
      . commands
    else
      msg="Forbidden"
    fi

    if [ ! -z "$msg" ]; then
      prevActiveTime=$curTime
      send_message "$TARGET" "$msg"
    fi
  fi

  elapsed=$((curTime-prevActiveTime))

  if [ $elapsed -le $standByAfter ]; then
    if [ $cycleSleep -gt 0 ]; then
      sleep $cycleSleep
    fi
  else
    sleep $cycleSleepStandBy
  fi

} done

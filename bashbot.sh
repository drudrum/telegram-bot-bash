#!/bin/bash

# bashbot, the Telegram bot written in bash.
# Written by @topkecleon and Juan Potato (@awkward_potato)
# http://github.com/topkecleon/bashbot

# Depends on JSON.sh (http://github.com/dominictarr/JSON.sh),
# which is MIT/Apache-licensed.

# This file is public domain in the USA and all free countries.
# If you're in Europe, and public domain does not exist, then haha.
ROOTDIR=$(pwd)
echo "Telegram bot dir:"$ROOTDIR

. global
OFFSET=0

echo "Getting bot name"
res=""
result=100

while [ $result -ne 0 ]; do
  {
    res=$(curl -f "$URL/getMe")
    result=$?
  } &>/dev/null
  if [ $result -ne 0 ]; then
    echo "curl errcode: $result"
    echo "$res"
    sleep 15
  fi
done

{
  bot_username=$(echo $res | ./JSON.sh -s | egrep '\["result","username"\]' | cut -f 2 | cut -d '"' -f 2)
} &>/dev/null
echo "Bot username:$bot_username"

#Starting in stand by mode
prevActiveTime=0

if [ $botStartedNotify -eq 1 ]; then
  ./sendNotify -l2 -t "Bot started username:$bot_username"
fi

while true; do {
  newMessage=0
  while [ $newMessage -eq 0 ]; do
    {
      sleep 5
      res=$(curl $URL\/getUpdates\?offset=$OFFSET\&limit=1)
      res="${res//$/\\$}"
      if [ ! "$res" == '{"ok":true,"result":[]}' ]; then
        newMessage=1
        TARGET=$(echo $res | ./JSON.sh | egrep '\["result",0,"message","chat","id"\]' | cut -f 2)
        from=$(echo $res | ./JSON.sh | egrep '\["result",0,"message","from","username"\]' | cut -f 2)
        OFFSET=$(echo $res | ./JSON.sh | egrep '\["result",0,"update_id"\]' | cut -f 2)
        MESSAGE=$(echo $res | ./JSON.sh -s | egrep '\["result",0,"message","text"\]' | cut -f 2 | cut -d '"' -f 2)
        message_id=$(echo $res | ./JSON.sh | egrep '\["result",0,"message","message_id"\]' | cut -f 2 )
        file_id=$(echo $res | ./JSON.sh | egrep '\["result",0,"message","document","file_id"\]' | cut -f 2 )
        file_name=$(echo $res | ./JSON.sh | egrep '\["result",0,"message","document","file_name"\]' | cut -f 2 )
        echo "o:$OFFSET r:$res"
      else
        echo "has no messages  $res $OFFSET"
      fi
    }&>/dev/null
  done

  curTime=$((10#`date +%s`))
  OFFSET=$((OFFSET+1))
  echo "$MESSAGE"

  if [ $OFFSET != 1 ]; then
    echo "$OFFSET">lastOffset
    #split MESSAGE by space to array
    msgWords=($MESSAGE)
    cmd=${msgWords[0]}
    drive=""
    msg=""
    echo "from:$from Message:$MESSAGE"

    cmdAr=(${cmd//\@/ })
    cmd=${cmdAr[0]}
    toBot=${cmdAr[1]}

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
      echo "TARGET:$TARGET"
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

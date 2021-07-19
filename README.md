# bashbot
A Telegram bot written in bash.

# Requiment:
* curl
* bash

# Bot commands:
- `/s` sensors
- `/ss` smbstatus
- `/free` memory status
- `/md` raid status
- `/lvs` lvm status
- `/lvsd` Datailed lvm status
- `/df` disk space
- `/ifconfig` ifconfig output
- `/smart -d sda` smart status for sda drive
- `/lock` allow only chats from notifyLevels dir
- `/unlock` - allow any users to chat with bot
- `/notifyLevel` `/nl` View or Set notify level
<br />example `/notifyLevel 3` set notify level 3 for this chat
 - *0* - Nothing
 - *1* - Critical
 - *2* - Dangerous (password brutforce, etc)
 - *3* - Big success events
 - *4* - Success events
 - *...* - ...

# Send notify from server
You can send notify from your servers, using script sendNotify
examples:
- sendNotify -l1 -t "Critical error at service ABC"
- sendNotify -l3 -t "User vasya login at service samba"
Default notify level for new chat is 0. To change notify level use `/nl 3`.

# Setup telegram commands
- Say `/setcommands` to botfather
- Choose your bot
- Send following description
```
s - sensors
ss - smbstatus
free - memory status
md - raid status
lvs - lvm status
lvsd - Datailed lvm status
df - disk space
ifconfig - Network configuration
smart - smart status
nl - notify level
lock - lock from new chats
unlock - allow any users to chat with bot
```

# Telegram token
- Put your bot token to file "token". You can use install script.
- One bot(process) - One token

# Setup to initd 
```
git clone https://github.com/drudrum/telegram-bot-bash.git
cd telegram-bot-bash
./installInitd <YourBotToken>
```
- InstallInitd script creates */usr/lib/systemd/system/tBot.service*, */usr/bin/sendNotify*
- Logs placed at /var/log/tBot
- Manual start run `/etc/init.d/tBot start`

# Setup to systemd (recommeded)
```
git clone https://github.com/drudrum/telegram-bot-bash.git
cd telegram-bot-bash
./installSystemd <YourBotToken>
```
- installInitd creates */usr/lib/systemd/system/tBot.service*, */usr/bin/sendNotify*
- Manual start `systemctl start tBot`
- Enable to system boot `systemctl enable tBot`

# Custom commands
  You can place your commands to [cmds](cmds/) dir

Uses [json.sh](https://github.com/dominictarr/JSON.sh).

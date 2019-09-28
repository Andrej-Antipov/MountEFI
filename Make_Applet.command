#!/bin/sh



# Возвращает в переменной TTYcount 0 если наш терминал один
CHECK_TTY_COUNT(){
term=`ps`
AllTTYcount=`echo $term | grep -Eo ttys[0-9][0-9][0-9] | wc -l | tr - " \t\n"`
let "TTYcount=AllTTYcount-MyTTYcount"
}

EXIT_PROGRAM(){
################################## очистка на выходе #############################################################
cat  ~/.bash_history | sed -n '/Make_Applet/!p' >> ~/new_hist.txt; rm ~/.bash_history; mv ~/new_hist.txt ~/.bash_history

#####################################################################################################################
CHECK_TTY_COUNT	
if [[ ${TTYcount} = 0  ]]; then   osascript -e 'tell application "Terminal" to close first window' && osascript -e 'quit app "terminal.app"' & exit
	else
     osascript -e 'tell application "Terminal" to close first window' & exit
fi
}

#запоминаем на каком терминале и сколько процессов у нашего скрипта
#############################################################################################################################
MyTTY=`tty | tr -d " dev/\n"`

term=`ps`;  MyTTYcount=`echo $term | grep -Eo $MyTTY | wc -l | tr - " \t\n"`
##############################################################################################################################

cd "$(dirname "$0")"
sh appyfi/appify.command
EXIT_PROGRAM
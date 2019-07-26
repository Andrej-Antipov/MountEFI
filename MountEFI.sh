#!/bin/bash

############################################################################## Mount EFI #########################################################################################################################
prog_vers="1.8"
edit_vers="009"
##################################################################################################################################################################################################################

# функция отладки ##################################################################################################
demo1="0"
deb=0

DEBUG(){
if [[ ! $deb = 0 ]]; then
printf '\n\n Останов '"$stop"'  :\n\n' >> ~/temp.txt 
printf '............................................................\n' >> ~/temp.txt
echo "diff_list = ""${diff_list[@]}" >> ~/temp.txt
echo "usblist = ""${usblist[@]}" >> ~/temp.txt
echo "puid_list = ""${puid_list[@]}" >> ~/temp.txt
echo "old_puid_list = ""${old_puid_list[@]}" >> ~/temp.txt
#echo "sata_lines = "${sata_lines} >> ~/temp.txt
#echo "usb_lines = "${usb_lines} >> ~/temp.txt
#echo "screen_buffer = ""$screen_buffer" >> ~/temp.txt
#echo "usb_screen_buffer = ""$usb_screen_buffer" >> ~/temp.txt
echo "pos = "$pos >> ~/temp.txt
echo "match = "$match >> ~/temp.txt
#echo "n = "$n >> ~/temp.txt
#echo "i = "$i >> ~/temp.txt
#echo "lines = "$lines >> ~/temp.txt
echo "usb_string = "$usb_string >> ~/temp.txt
#echo "posi = "$posi >> ~/temp.txt
echo "dlist = *"${dlist[@]}"*" >> ~/temp.txt
#echo "ilist/n = *"${ilist[$n]}"*" >> ~/temp.txt
echo "ilist  = "${ilist[@]}"*" >> ~/temp.txt
echo "dfdstring = *"$dfdstring"*" >> ~/temp.txt
echo "string = *"$string"*" >> ~/temp.txt

printf '............................................................\n\n' >> ~/temp.txt
sleep 0.2
read -n 1 -s
fi
}
#########################################################################################################################################


############################ Mount EFI Master v.1.8 edit 009
# Разделение данных на SATA и USB для отдельного отображения
# Исправление показывать заголовок USB, если USB не входит в список отображаемых 
# Начало переделки функции сканирования разделов в GET_EFI_S
# Исправление - не показывает разделы на USB HDD
# Исправление - очистка string от DMG
# Устранение реакции на подключение/отключение DMG
# Исправление в начальном определении числа lines 
# Исправление ошибки списка string при занесении в него USB
# Исправление позиции курора при вводе по 2 байта, при выключенной функции A.
# Исправление в разделении буферов экрана для функции UPDATE_SCREEN_BUFFER




SHOW_VERSION(){
clear && printf "\e[3J" 
printf "\033[?25l"
GET_LOADERS
var=${lines} 
while [[ ! $var = 0 ]]; do
if [[ ! $CheckLoaders = 0 ]]; then printf '\e[40m %.0s\e[0m' {1..88}; vcorr=32; v2corr=24; v3corr=25; else printf '\e[40m %.0s\e[0m' {1..80}; vcorr=28; v2corr=20; v3corr=21; fi
let "var--"; done
printf "\033[H"

printf "\033[10;'$v3corr'f"
printf '\e[40m\e[1;33m________________________________________\e[0m''\n\033['$v2corr'C'
printf '\e[40m\e[1;33m[                                      ]\e[0m''\n\033['$v2corr'C'
printf '\e[40m\e[1;33m[                                      ]\e[0m''\n\033['$v2corr'C'
printf '\e[40m\e[1;33m[                                      ]\e[0m''\n\033['$v2corr'C'
printf '\e[40m\e[1;33m[                                      ]\e[0m''\n\033['$v2corr'C'
printf '\e[40m\e[1;33m[______________________________________]\e[0m''\n'
printf '\r\033[3A\033['$vcorr'C' ; printf '\e[40m\e[1;35m  MountEFI v. \e[1;33m'$prog_vers'.\e[1;32m '$edit_vers' \e[1;35m®\e[0m''\n'   
read -n 1 
clear && printf "\e[3J"
} 


clear  && printf '\e[3J'
printf "\033[?25l"

cd $(dirname $0)

if [ "$1" = "-d" ] || [ "$1" = "-D" ]  || [ "$1" = "-default" ]  || [ "$1" = "-DEFAULT" ]; then 
if [[ -f ${HOME}/.MountEFIconf.plist ]]; then rm ${HOME}/.MountEFIconf.plist; fi
fi

if [ "$1" = "-r" ] || [ "$1" = "-R" ]  || [ "$1" = "-reset" ]  || [ "$1" = "-RESET" ]; then 
if [[ -f ${HOME}/.MountEFIconf.plist ]]; then 
login=`cat ${HOME}/.MountEFIconf.plist | grep -Eo "LoginPassword"  | tr -d '\n'`
    if [[ $login = "LoginPassword" ]]; then
       plutil -remove LoginPassword ${HOME}/.MountEFIconf.plist
    fi 
  fi
fi


GET_BACKUPS_FROM_ICLOUD(){
hwuuid=$(ioreg -rd1 -c IOPlatformExpertDevice | awk '/IOPlatformUUID/' | cut -f2 -d"=" | tr -d '" \n')
if [[ -d ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs ]]; then
       if [[ -f ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIbackups/$hwuuid/.MountEFIconfBackups.zip ]]; then
            cp ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIbackups/$hwuuid/.MountEFIconfBackups.zip  ${HOME}
       else
                if [[ -f ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIbackups/Shared/.MountEFIconfBackups.zip ]]; then
                    cp ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIbackups/Shared/.MountEFIconfBackups.zip  ${HOME}
            fi
       fi 
fi  

}

FILL_CONFIG(){

echo '<?xml version="1.0" encoding="UTF-8"?>' >> ${HOME}/.MountEFIconf.plist
            echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' >> ${HOME}/.MountEFIconf.plist
            echo '<plist version="1.0">' >> ${HOME}/.MountEFIconf.plist
            echo '<dict>' >> ${HOME}/.MountEFIconf.plist
            echo '	<key>AutoMount</key>' >> ${HOME}/.MountEFIconf.plist
            echo '	<dict>' >> ${HOME}/.MountEFIconf.plist
            echo '  <key>Enabled</key>' >> ${HOME}/.MountEFIconf.plist
            echo '  <false/>' >> ${HOME}/.MountEFIconf.plist
            echo '  <key>Open</key>' >> ${HOME}/.MountEFIconf.plist
            echo '  <false/>' >> ${HOME}/.MountEFIconf.plist
            echo '  <key>PartUUIDs</key>' >> ${HOME}/.MountEFIconf.plist
            echo '  <string> </string>' >> ${HOME}/.MountEFIconf.plist
            echo '  <key>Timeout2Exit</key>' >> ${HOME}/.MountEFIconf.plist
            echo '  <integer>10</integer>' >> ${HOME}/.MountEFIconf.plist
            echo '	</dict>' >> ${HOME}/.MountEFIconf.plist
            echo '	<key>Backups</key>' >> ${HOME}/.MountEFIconf.plist
            echo '	<dict>' >> ${HOME}/.MountEFIconf.plist
            echo '  <key>Auto</key>' >> ${HOME}/.MountEFIconf.plist
            echo '  <true/>' >> ${HOME}/.MountEFIconf.plist
            echo '  <key>Maximum</key>' >> ${HOME}/.MountEFIconf.plist
            echo '  <integer>10</integer>' >> ${HOME}/.MountEFIconf.plist
            echo '	</dict>' >> ${HOME}/.MountEFIconf.plist
            echo '  <key>CheckLoaders</key>' >> ${HOME}/.MountEFIconf.plist
            echo '  <false/>' >> ${HOME}/.MountEFIconf.plist
            echo '  <key>CurrentPreset</key>' >> ${HOME}/.MountEFIconf.plist
            echo '  <string>BlueSky</string>' >> ${HOME}/.MountEFIconf.plist
            echo '  <key>Locale</key>' >> ${HOME}/.MountEFIconf.plist
            echo '  <string>auto</string>' >> ${HOME}/.MountEFIconf.plist
            echo '  <key>Menue</key>' >> ${HOME}/.MountEFIconf.plist
            echo '  <string>auto</string>' >> ${HOME}/.MountEFIconf.plist
            echo '  <key>OpenFinder</key>' >> ${HOME}/.MountEFIconf.plist
            echo '  <true/>' >> ${HOME}/.MountEFIconf.plist
            echo '  <key>Presets</key>' >> ${HOME}/.MountEFIconf.plist
            echo '  <dict>' >> ${HOME}/.MountEFIconf.plist
            echo '      <key>BlueSky</key>' >> ${HOME}/.MountEFIconf.plist
            echo '      <dict>' >> ${HOME}/.MountEFIconf.plist
            echo '          <key>BackgroundColor</key>' >> ${HOME}/.MountEFIconf.plist
            echo '          <string>{3341, 25186, 40092}</string>' >> ${HOME}/.MountEFIconf.plist
            echo '          <key>FontName</key>' >> ${HOME}/.MountEFIconf.plist
            echo '          <string>SF Mono Regular</string>' >> ${HOME}/.MountEFIconf.plist
            echo '          <key>FontSize</key>' >> ${HOME}/.MountEFIconf.plist
            echo '          <string>12</string>' >> ${HOME}/.MountEFIconf.plist
            echo '          <key>TextColor</key>' >> ${HOME}/.MountEFIconf.plist
            echo '          <string>{65535, 65535, 65535}</string>' >> ${HOME}/.MountEFIconf.plist
            echo '      </dict>' >> ${HOME}/.MountEFIconf.plist
            echo '      <key>DarkBlueSky</key>' >> ${HOME}/.MountEFIconf.plist
            echo '      <dict>' >> ${HOME}/.MountEFIconf.plist
            echo '          <key>BackgroundColor</key>' >> ${HOME}/.MountEFIconf.plist
            echo '          <string>{8481, 10537, 33667}</string>' >> ${HOME}/.MountEFIconf.plist
            echo '          <key>FontName</key>' >> ${HOME}/.MountEFIconf.plist
            echo '          <string>SF Mono</string>' >> ${HOME}/.MountEFIconf.plist
            echo '          <key>FontSize</key>' >> ${HOME}/.MountEFIconf.plist
            echo '          <string>12</string>' >> ${HOME}/.MountEFIconf.plist
            echo '          <key>TextColor</key>' >> ${HOME}/.MountEFIconf.plist
            echo '          <string>{65278, 64507, 0}</string>' >> ${HOME}/.MountEFIconf.plist
            echo '      </dict>' >> ${HOME}/.MountEFIconf.plist
            echo '      <key>GreenField</key>' >> ${HOME}/.MountEFIconf.plist
            echo '      <dict>' >> ${HOME}/.MountEFIconf.plist
            echo '          <key>BackgroundColor</key>' >> ${HOME}/.MountEFIconf.plist
            echo '          <string>{0, 29812, 0}</string>' >> ${HOME}/.MountEFIconf.plist
            echo '          <key>FontName</key>' >> ${HOME}/.MountEFIconf.plist
            echo '          <string>SF Mono</string>' >> ${HOME}/.MountEFIconf.plist
            echo '          <key>FontSize</key>' >> ${HOME}/.MountEFIconf.plist
            echo '          <string>12</string>' >> ${HOME}/.MountEFIconf.plist
            echo '          <key>TextColor</key>' >> ${HOME}/.MountEFIconf.plist
            echo '          <string>{61937, 60395, 47288}</string>' >> ${HOME}/.MountEFIconf.plist
            echo '      </dict>' >> ${HOME}/.MountEFIconf.plist
            echo '      <key>Ocean</key>' >> ${HOME}/.MountEFIconf.plist
            echo '      <dict>' >> ${HOME}/.MountEFIconf.plist
            echo '          <key>BackgroundColor</key>' >> ${HOME}/.MountEFIconf.plist
            echo '          <string>{1028, 12850, 65535}</string>' >> ${HOME}/.MountEFIconf.plist
            echo '          <key>FontName</key>' >> ${HOME}/.MountEFIconf.plist
            echo '          <string>SF Mono Regular</string>' >> ${HOME}/.MountEFIconf.plist
            echo '          <key>FontSize</key>' >> ${HOME}/.MountEFIconf.plist
            echo '          <string>12</string>' >> ${HOME}/.MountEFIconf.plist
            echo '          <key>TextColor</key>' >> ${HOME}/.MountEFIconf.plist
            echo '          <string>{65535, 65535, 65535}</string>' >> ${HOME}/.MountEFIconf.plist
            echo '      </dict>' >> ${HOME}/.MountEFIconf.plist
            echo '      <key>Tolerance</key>' >> ${HOME}/.MountEFIconf.plist
            echo '      <dict>' >> ${HOME}/.MountEFIconf.plist
            echo '          <key>BackgroundColor</key>' >> ${HOME}/.MountEFIconf.plist
            echo '          <string>{40092, 40092, 38293}</string>' >> ${HOME}/.MountEFIconf.plist
            echo '          <key>FontName</key>' >> ${HOME}/.MountEFIconf.plist
            echo '          <string>SF Mono</string>' >> ${HOME}/.MountEFIconf.plist
            echo '          <key>FontSize</key>' >> ${HOME}/.MountEFIconf.plist
            echo '          <string>12</string>' >> ${HOME}/.MountEFIconf.plist
            echo '          <key>TextColor</key>' >> ${HOME}/.MountEFIconf.plist
            echo '          <string>{40606, 4626, 0}</string>' >> ${HOME}/.MountEFIconf.plist
            echo '      </dict>' >> ${HOME}/.MountEFIconf.plist
            echo '  </dict>' >> ${HOME}/.MountEFIconf.plist
            echo '  <key>RenamedHD</key>' >> ${HOME}/.MountEFIconf.plist
            echo '  <string> </string>' >> ${HOME}/.MountEFIconf.plist
            echo '  <key>ShowKeys</key>' >> ${HOME}/.MountEFIconf.plist
            echo '  <true/>' >> ${HOME}/.MountEFIconf.plist
            echo '  <key>Theme</key>' >> ${HOME}/.MountEFIconf.plist
            echo '  <string>system</string>' >> ${HOME}/.MountEFIconf.plist
            echo '</dict>' >> ${HOME}/.MountEFIconf.plist
            echo '</plist>' >> ${HOME}/.MountEFIconf.plist


}

####################################### кэш конфига #####################################################################################

UPDATE_CACHE(){
if [[ -f ${HOME}/.MountEFIconf.plist ]]; then
MountEFIconf=$( cat ${HOME}/.MountEFIconf.plist )
cache=1
else
unset MountEFIconf; cache=0
fi
}
##########################################################################################################################################

UPDATE_CACHE

########################## Инициализация нового конфига ##################################################################################

deleted=0
if [[ $cache = 1 ]]; then
strng=`echo "$MountEFIconf" | grep  "<key>CurrentPreset</key>" | grep key | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\t\n'`
      if [[ ! $strng = "CurrentPreset" ]]; then
        mypassword="0"
        login=`echo "$MountEFIconf" | grep -Eo "LoginPassword"  | tr -d '\n'`
                if [[ $login = "LoginPassword" ]]; then
        mypassword=`echo "$MountEFIconf" | grep -A 1 "LoginPassword" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
                fi
        theme=`echo "$MountEFIconf" |  grep -A 1   "<key>Theme</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
        rm ${HOME}/.MountEFIconf.plist; unset MountEFIconf; cache=0; deleted=1
    fi
fi

if [[ ! $cache = 1 ]]; then
        if [[ -f DefaultConf.plist ]]; then
            cp DefaultConf.plist ${HOME}/.MountEFIconf.plist
        else
             FILL_CONFIG
        fi
fi

if [[ $deleted = 1 ]]; then
    if [[ ! $mypassword = 0 ]]; then 
    plutil -replace LoginPassword -string $mypassword ${HOME}/.MountEFIconf.plist
    fi
    plutil -replace Theme -string $theme ${HOME}/.MountEFIconf.plist 
fi

if [[ $cache = 0 ]]; then UPDATE_CACHE; fi
strng=`echo "$MountEFIconf"| grep -e "<key>ShowKeys</key>" | grep key | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\t\n'`
if [[ ! $strng = "ShowKeys" ]]; then plutil -replace ShowKeys -bool YES ${HOME}/.MountEFIconf.plist; cache=0; fi

strng=`echo "$MountEFIconf"| grep -e "<key>CheckLoaders</key>" | grep key | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\t\n'`
if [[ ! $strng = "CheckLoaders" ]]; then plutil -replace CheckLoaders -bool NO ${HOME}/.MountEFIconf.plist; cache=0; fi

strng=`echo "$MountEFIconf" | grep -e "<key>AutoMount</key>" | grep key | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\t\n'`
if [[ ! $strng = "AutoMount" ]]; then 
			plutil -insert AutoMount -xml  '<dict/>'   ${HOME}/.MountEFIconf.plist
			plutil -insert AutoMount.Enabled -bool NO ${HOME}/.MountEFIconf.plist
			plutil -insert AutoMount.ExitAfterMount -bool NO ${HOME}/.MountEFIconf.plist
			plutil -insert AutoMount.Open -bool NO ${HOME}/.MountEFIconf.plist
			plutil -insert AutoMount.PartUUIDs -string " " ${HOME}/.MountEFIconf.plist
            cache=0
fi

strng=`echo "$MountEFIconf" | grep AutoMount -A 11 | grep -o "Timeout2Exit" | tr -d '\n'`
if [[ ! $strng = "Timeout2Exit" ]]; then
            plutil -insert AutoMount.Timeout2Exit -integer 5 ${HOME}/.MountEFIconf.plist
            cache=0
fi

strng=`echo "$MountEFIconf" | grep -e "<key>RenamedHD</key>" |  sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\t\n'`
if [[ ! $strng = "RenamedHD" ]]; then
            plutil -insert RenamedHD -string " " ${HOME}/.MountEFIconf.plist
            cache=0
fi

strng=`echo "$MountEFIconf" | grep -e "<key>Backups</key>" | grep key | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\t\n'`
if [[ ! $strng = "Backups" ]]; then 
             plutil -insert Backups -xml  '<dict/>'   ${HOME}/.MountEFIconf.plist
             plutil -insert Backups.Maximum -integer 10 ${HOME}/.MountEFIconf.plist
             cache=0
fi

if [[ $cache = 0 ]]; then UPDATE_CACHE; fi

#############################################################################################################################################

if [[ -d ${HOME}/.MountEFIconfBackups ]]; then rm -R -f ${HOME}/.MountEFIconfBackups; fi
if [[ ! -f ${HOME}/.MountEFIconfBackups.zip ]]; then GET_BACKUPS_FROM_ICLOUD; fi
            if [[ ! -f ${HOME}/.MountEFIconfBackups.zip ]]; then
            mkdir ${HOME}/.MountEFIconfBackups
            mkdir ${HOME}/.MountEFIconfBackups/1
            cp ${HOME}/.MountEFIconf.plist ${HOME}/.MountEFIconfBackups/1
            zip -rX -qq ${HOME}/.MountEFIconfBackups.zip ${HOME}/.MountEFIconfBackups
            rm -R ${HOME}/.MountEFIconfBackups
fi

#Функция автомонтирования EFI по Volume UUID при запуске ####################################################################################

REM_ABSENT(){
strng1=`echo "$MountEFIconf" | grep AutoMount -A 9 | grep -A 1 -e "PartUUIDs</key>"  | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
alist=($strng1); apos=${#alist[@]}
if [[ ! $apos = 0 ]]
	then
		var8=$apos
		posb=0
		while [[ ! $var8 = 0 ]]
					do
                       check_uuid=`ioreg -c IOMedia -r | tr -d '"' | egrep "UUID" | grep -o ${alist[$posb]}`
                       if [[ $check_uuid = "" ]]; then 
						strng2=`echo ${strng1[@]}  |  sed 's/'${alist[$posb]}'//'`
						plutil -replace AutoMount.PartUUIDs -string "$strng2" ${HOME}/.MountEFIconf.plist
						strng1=$strng2
                        cache=0
						fi
					let "posb++"
					let "var8--"
					done
alist=($strng1); apos=${#alist[@]}
fi
if [[ $apos = 0 ]]; then plutil -replace AutoMount.Enabled -bool NO ${HOME}/.MountEFIconf.plist; am_enabled=0; cache=0; fi
}

am_enabled=0
strng3=`cat ${HOME}/.MountEFIconf.plist | grep AutoMount -A 3 | grep -A 1 -e "Enabled</key>" | grep true | tr -d "<>/"'\n\t'`
if [[ $strng3 = "true" ]]; then am_enabled=1

REM_ABSENT
if [[ $cache = 0 ]]; then UPDATE_CACHE; fi

fi

if [[ ! $am_enabled = 0 ]]; then 

if [[ ! $apos = 0 ]]; then

macos=`sw_vers -productVersion`
macos=`echo ${macos//[^0-9]/}`
macos=${macos:0:4}
if [[ "$macos" = "1015" ]] || [[ "$macos" = "1014" ]] || [[ "$macos" = "1013" ]]; then flag=1; else flag=0; fi


mypassword="0"
login=`echo "$MountEFIconf" | grep -Eo "LoginPassword"  | tr -d '\n'`
    if [[ $login = "LoginPassword" ]]; then
mypassword=`echo "$MountEFIconf" | grep -A 1 "LoginPassword" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
    fi


autom_open=0
strng3=`echo "$MountEFIconf" | grep AutoMount -A 7 | grep -A 1 -e "Open</key>" | grep true | tr -d "<>/"'\n\t'`
if [[ $strng3 = "true" ]]; then autom_open=1; fi

autom_exit=0
strng3=`echo "$MountEFIconf" | grep AutoMount -A 5 | grep -A 1 -e "ExitAfterMount</key>" | grep true | tr -d "<>/"'\n\t'`
if [[ $strng3 = "true" ]]; then autom_exit=1; fi

var9=$apos
posa=0
while [[ ! $var9 = 0 ]]
do
	if [[ $flag = 1 ]]; then
      
        if [[ ! $mypassword = "0" ]]; then
               echo $mypassword | sudo -S diskutil quiet mount  ${alist[$posa]} >&- 2>&-
	    
                    else
                       sudo printf ' '
                        sudo diskutil quiet mount  ${alist[$posa]} >&- 2>&-
		               
         fi
		else
			diskutil quiet mount  ${alist[$posa]} >&- 2>&-
fi

if  [[ $autom_open = 1 ]]; then 
#				vname=`diskutil info ${alist[$posa]} | grep "Mount Point:" | cut -d":" -f2 | rev | sed 's/[ \t]*$//' | rev`
                string=`ioreg -c IOMedia -r  | egrep -A12 -B12 ${alist[$posa]} | grep -m 1 "BSD Name" | cut -f2 -d "=" | tr -d '" \n\t'`
                vname=`df | egrep ${string} | sed 's#\(^/\)\(.*\)\(/Volumes.*\)#\1\3#' | cut -c 2-`
				open "$vname"
fi

let "posa++"
let "var9--"
done
	fi

fi
################################################ конец функции автомонтирования ########################################################## 

 ################################# обработка параметра Menue или аргумента -m  ############################################################
menue=0
HasMenue=`echo "$MountEFIconf" | grep -A 1 "Menue" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
if [[ $HasMenue = "always" ]]; then menue=1; fi
if [ "$1" = "-m" ] || [ "$1" = "-M" ]  || [ "$1" = "-menue" ]  || [ "$1" = "-MENUE" ]; then menue=1; fi 
###########################################################################################################################################

################################## параметр OpenFinder ####################################################################################
OpenFinder=1
strng=`echo "$MountEFIconf" | grep -A 1 -e "OpenFinder</key>" | grep false | tr -d "<>/"'\n\t'`
if [[ $strng = "false" ]]; then OpenFinder=0; fi
###########################################################################################################################################
# Определение функций кастомизации интерфейса #############################################
############################################################################################
# Colors for Apple Terminal
#

function grep_apple_color {
    grep "$*" colors.csv
}

function get_apple_color {
    egrep "(^|,)$*(,|\t)" colors.csv | cut -f 6
}

function set_foreground_color {
    color=$(get_apple_color $*)
    if [ "$color" != "" ] ; then
        osascript -e "tell application \"Terminal\" to set normal text color of window 1 to ${color}"
#        echo "Normal test color set to: $*: $color"
    fi
}    

function set_background_color {
    color=$(get_apple_color $*)
    if [ "$color" != "" ] ; then
        osascript -e "tell application \"Terminal\" to set background color of window 1 to ${color}"
#        echo "Background color set to: $*: $color"
    fi
}    
  

function set_font {
    osascript -e "tell application \"Terminal\" to set the font name of window 1 to \"$1\""
    osascript -e "tell application \"Terminal\" to set the font size of window 1 to $2"
}
##################################################################################################################################################

GET_PRESETS_COUNTS(){
pcount=0

pstring=`echo "$MountEFIconf"  | grep  -e "<key>BackgroundColor</key>" | sed -e 's/.*>\(.*\)<.*/\1/' | tr ' \n' ';'`
IFS=';'; slist=($pstring); unset IFS;
pcount=${#slist[@]}
unset slist
unset pstring
}

GET_PRESETS_NAMES(){
pstring=`echo "$MountEFIconf"  | grep  -B 2 -e "<key>BackgroundColor</key>" | grep key | sed -e 's/.*>\(.*\)<.*/\1/' | sed 's/BackgroundColor/;/g' | tr -d '\n'`
IFS=';'; plist=($pstring); unset IFS
unset pstring
}


#################################################################################################

GET_CURRENT_SET(){

current=`echo "$MountEFIconf"  | grep -A 1 -e "<key>CurrentPreset</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
current_background=`echo "$MountEFIconf"  | grep -A 10 -E "<key>$current</key>" | grep -A 1 "BackgroundColor" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
current_foreground=`echo "$MountEFIconf"  | grep -A 10 -E "<key>$current</key>" | grep -A 1 "TextColor" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
current_fontname=`echo "$MountEFIconf"  | grep -A 10 -E "<key>$current</key>" | grep -A 1 "FontName" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
current_fontsize=`echo "$MountEFIconf"  | grep -A 10 -E "<key>$current</key>" | grep -A 1 "FontSize" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`

}


CUSTOM_SET(){

GET_CURRENT_SET

if [[ ${current_background:0:1} = "{" ]]; then osascript -e "tell application \"Terminal\" to set background color of window 1 to $current_background"
		else set_background_color $current_background
fi
if [[ ${current_foreground:0:1} = "{" ]]; then osascript -e "tell application \"Terminal\" to set normal text color of window 1 to $current_foreground"
		else  set_foreground_color $current_foreground
fi
set_font "$current_fontname" $current_fontsize

}

GET_THEME(){

HasTheme=`echo "$MountEFIconf"  | grep -E "<key>Theme</key>" | grep -Eo Theme | tr -d '\n'`
    if [[ $HasTheme = "Theme" ]]; then
theme=`echo "$MountEFIconf"  |  grep -A 1 -e  "<key>Theme</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
    fi

}

GET_SKEYS(){
ShowKeys=1
strng=`echo "$MountEFIconf"  | grep -A 1 -e "ShowKeys</key>" | grep false | tr -d "<>/"'\n\t'`
if [[ $strng = "false" ]]; then ShowKeys=0; fi

}

#запоминаем на каком терминале и сколько процессов у нашего скрипта
#избавляемся от второго окна терминала по оценке времени с моментв запуска
#############################################################################################################################
MyTTY=`tty | tr -d " dev/\n"`
#Если мы на первой консоли - значит есть нулевая и её время жизни надо проверить
if [[ ${MyTTY} = "ttys001" ]]; then
# Получаем uid и pid первой консоли
MY_uid=`echo $UID`; PID_ttys001=`echo $$`
# получаем pid нулевой консоли
temp=`ps -ef | grep ttys000 | grep $MY_uid`; PID_ttys000=`echo $temp | awk  '{print $2}'`
# вычисляем время жизни нашей консоли в секундах
Time001=`ps -p $PID_ttys001 -oetime= | tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
# Вычисляем время жизни нулевой консоли в секундах
Time000=`ps -p $PID_ttys000 -oetime= | tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
	if [[ ${Time001} -le ${Time000} ]]; then 
let "TimeDiff=Time000-Time001"
# Здесь задаётся постоянная в секундах по которой можно считать что нулевая консоль запущена сразу перед первой и потому её надо закрыть
		if [[ ${TimeDiff} -le 4 ]]; then osascript -e 'tell application "Terminal" to close second  window'; fi
	fi	
fi
term=`ps`;  MyTTYcount=`echo $term | grep -Eo $MyTTY | wc -l | tr - " \t\n"`
##############################################################################################################################
GET_LOCALE(){
if [[ $cache = 1 ]] ; then
        locale=`echo "$MountEFIconf" | grep -A 1 "Locale" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
        if [[ ! $locale = "ru" ]] && [[ ! $locale = "en" ]]; then loc=`locale | grep LANG | sed -e 's/.*LANG="\(.*\)_.*/\1/'`
            else
                loc=`echo ${locale}`
        fi
    else   
        loc=`locale | grep LANG | sed -e 's/.*LANG="\(.*\)_.*/\1/'`
fi  
}

GET_LOCALE

parm="$1"


if [ "$parm" = "-help" ] || [ "$parm" = "-h" ]  || [ "$parm" = "-H" ]  || [ "$parm" = "-HELP" ]
then
    printf '\e[8;25;96t'
    clear && printf '\e[3J'
	if [ $loc = "ru" ]; then
    printf '\n\n************     Программа монтирует EFI разделы в Mac OS (X.11 - X.14)    *************\n'

    printf '\n\n Эта программа предназначена для быстрого обнаружения и подключения разделов EFI / ESP\n'
    printf ' Программа различает версию операционной системы, и если потребуется запрашивает пароль\n'
    printf ' Поскольку в High Sierra и Mojave для подключения разделов требуются права администратора\n'
    printf ' Если пароль не требуется он не будет запрошен. Алгоритм работы программы следующий:\n'
    printf ' Обнаружив один раздел EFI программа сразу подключает его. Если разделов два или более,\n'
    printf ' когда в систему установлены несколько дисков с разметкой GUID, программа выведет запрос\n'
    printf ' чтобы пользователь мог выбрать какой раздел он хочет подключить.\n'
    printf ' Программа может иметь один аргумент командной строки. Аргумент -h [ -help, -HELP, -H ]\n'
    printf ' выводит эту справочную инфрмацию. Программа поставляется как есть. Она может свободно копи-\n'
    printf ' роваться, передаваться другим лицам и изменяться без ограничений. Вы используете её без каких\n'
    printf ' либо гарантий, на своё усмотрение и под свою ответственность.\n'
    printf '\n Март 2019 год.\n\n\n\n\n\n\n'
    
			else

    printf '\n\n************     This program mounts EFI partitions on Mac OS (X.11 - X.14)    *************\n'

    printf '\n\n This program is designed to quickly detect and mount EFI / ESP partitions\n'
    printf ' The program checks the version of the operating system, and if necessary, requests a password\n'
    printf ' Because High Sierra and Mojave require administrator privileges to connect partitions\n'
    printf ' If a password is not required, it will not be requested. The algorithm of the program is as follows:\n'
    printf ' Having found one EFI partition, the program immediately connects it. If there are two or more partitions,\n'
    printf ' when multiple disks with GUIDs are installed in the system, the program will prompt\n'
    printf ' so that the user can choose which partition he wants to mount\n'
    printf ' The program can has one command line arguments. Argument -h [-help, -HELP, -H]\n'
    printf ' prints this help information. The program is delivered as is.It can be freely copied,\n'
    printf ' transferred to other persons and changed without restrictions. You use it without any\n'
    printf ' either warranties from the developer, at your discretion and under your responsibility.\n'
    printf '\n March 2019\n\n\n\n\n\n\n'
    
	fi
    exit 
fi


declare -a nlist 
declare -a dlist
lists_updated=0


# Блок определения функций ########################################################


#Получение пароля для sudo из конфига
GET_USER_PASSWORD(){
mypassword="0"
login=`echo "$MountEFIconf" | grep -Eo "LoginPassword"  | tr -d '\n'`
    if [[ $login = "LoginPassword" ]]; then
mypassword=`echo "$MountEFIconf" | grep -A 1 "LoginPassword" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
    fi
}

# Возвращает в переменной TTYcount 0 если наш терминал один
CHECK_TTY_COUNT(){
term=`ps`
AllTTYcount=`echo $term | grep -Eo ttys[0-9][0-9][0-9] | wc -l | tr - " \t\n"`
let "TTYcount=AllTTYcount-MyTTYcount"
}

################## Выход из программы с проверкой - выгружать терминал из трея или нет #####################################################
EXIT_PROGRAM(){
################################## очистка на выходе #############################################################
cat  ~/.bash_history | sed -n '/MountEFI/!p' >> ~/new_hist.txt; rm ~/.bash_history; mv ~/new_hist.txt ~/.bash_history
#rm -f   ~/.MountEFItemp.txt; rm -f ~/.MountEFItemp2.txt; rm -f ~/.SetupMountEFItemp.txt; rm -f ~/.SetupMountEFItemp2.txt
#rm -f ~/.SetupMountEFIAtemp.txt
#####################################################################################################################
CHECK_TTY_COUNT	
if [[ ${TTYcount} = 0  ]]; then   osascript -e 'quit app "terminal.app"' & exit
	else
     osascript -e 'tell application "Terminal" to close first window' & exit
fi
}
##########################################################################################################################
########################## обратный отсчёт для автомонтирования ##########################################################
COUNTDOWN(){ 
        printf '\n\n\n'
        local t=$1 remaining=$1;
        SECONDS=0; demo="±"
        while sleep .01; do
                if [[ $loc = "ru" ]]; then
            printf '\rНажмите любую клавишу для прерывания. Автовыход через: '"$remaining"' '
                    else
            printf '\rPress any key to brake the countdown. Exit timeout: '"$remaining"' '
                fi
            read -t 1 -n1 demo
                if [[ ! $demo = "±" ]]; then  break; fi
            if (( (remaining=t-SECONDS) <=0 )); then
                if [[ $loc = "ru" ]]; then
            printf '\rНажмите любую клавишу для прерывания. Автовыход через: '"$remaining"' '
                    else
            printf '\rPress any key to brake the countdown. Exit timeout: '"$remaining"' '
                fi
                break;
            fi;
        done
}
#############################################################################################################################
####### Выход по опции авто-монтирования c проверкой таймаута    ####################################################
if [[ $am_enabled = 1 ]] && [[  ! $apos = 0 ]] && [[ $autom_exit = 1 ]]; then 
        auto_timeout=0
        strng=`echo "$MountEFIconf" | grep AutoMount -A 11 | grep -A 1 -e "Timeout2Exit</key>"  | grep integer | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
        if [[ ! $strng = "" ]]; then auto_timeout=$strng; fi
    if [[ $auto_timeout = 0 ]]; then EXIT_PROGRAM
                else
              COUNTDOWN $auto_timeout
            if [[ $demo = "±" ]]; then  EXIT_PROGRAM
        fi
    fi
fi
######################################################################################################################

############################################ очистка истории bash при запуске ##################################################
cat  ~/.bash_history | sed -n '/MountEFI/!p' >> ~/new_hist.txt; rm ~/.bash_history; mv ~/new_hist.txt ~/.bash_history
################################################################################################################################

################################## функция автодетекта подключения ##############################################################################################
CHECK_HOTPLUG_PARTS(){
pstring=`df | cut -f1 -d " " | grep "/dev" | cut -f3 -d "/"` ; puid_list=($pstring);  puid_count=${#puid_list[@]}
        if [[ ! $old_puid_count = $puid_count ]]; then
                
               if [[  $old_puid_count -lt $puid_count ]]; then 
                       
                    ioreg_iomedia=`ioreg -c IOMedia -r | tr -d '"|+{}\t'`
                    disk_images=`echo "$ioreg_iomedia" | egrep -A 22 "Apple UDIF" | grep "BSD Name" | cut -f2 -d "="  | tr -d " " | tr '\n' ';'`
                    IFS=';'; ilist=($disk_images); unset IFS; posi=${#ilist[@]}
               fi
                    
                    diff_list=()
                    IFS=';'; diff_list=(`echo ${puid_list[@]} ${old_puid_list[@]} | tr ' ' '\n' | sort | uniq -u | tr '\n' ';'`); unset IFS; posdi=${#diff_list[@]}
                    if [[ ! $posi = 0 ]] && [[ ! $posdi = 0 ]]; then 
                            
                        for (( i=0; i<$posdi; i++ )); do
                            match=0
                            dfdstring=`echo ${diff_list[$i]} | rev | cut -f2-3 -d"s" | rev`
                                
                                for (( n=0; n<=$posi; n++ )); do
                                     if [[ "$dfdstring" = "${ilist[$n]}" ]]; then match=1;  break; fi
                                
                        done
                                     
                                     if [[ ! $match = 1 ]]; then  UPDATE_SCREEN_BUFFER; UPDATE_SCREEN; fi
                        done

                        else
                                    
                                     UPDATE_SCREEN_BUFFER; UPDATE_SCREEN

                    fi
            
           old_puid_count=$puid_count; old_puid_list=($pstring)
            
        fi
}

CHECK_HOTPLUG_DISKS(){
hotplug=0
ustring=`ioreg -c IOMedia -r  | tr -d '"|+{}\t'  | grep -A 10 -B 5  "Whole = Yes" | grep "BSD Name" | grep -oE '[^ ]+$' | xargs | tr ' ' ';'` ; IFS=";"; uuid_list=($ustring); unset IFS; uuid_count=${#uuid_list[@]};
        if [[ ! $old_uuid_count = $uuid_count ]]; then
            if [[  $old_uuid_count -lt $uuid_count ]]; then 
               ioreg_iomedia=`ioreg -c IOMedia -r | tr -d '"|+{}\t'`
                    disk_images=`echo "$ioreg_iomedia" | egrep -A 22 "Apple UDIF" | grep "BSD Name" | cut -f2 -d "="  | tr -d " " | tr '\n' ';'`
                    IFS=';'; ilist=($disk_images); unset IFS; posi=${#ilist[@]}
            fi
                diff_uuid=()
                IFS=';'; diff_uuid=(`echo ${uuid_list[@]} ${old_uuid_list[@]} | tr ' ' '\n' | sort | uniq -u | tr '\n' ';'`); unset IFS; posui=${#diff_uuid[@]}
                if [[ ! $posi = 0 ]] && [[ ! $posui = 0 ]]; then 
                    for (( i=0; i<$posui; i++ )); do
                        match=0
                    for (( n=0; n<=$posi; n++ )); do
                        if [[ "${diff_uuid[$i]}" = "${ilist[$n]}" ]]; then match=1;  break; fi
                    done
                        if [[ ! $match = 1 ]]; then  choice=0; hotplug=1; fi
                    done
                 else
                    
                    choice=0; hotplug=1
            fi
                            
          old_uuid_count=$uuid_count ; old_uuid_list=($ustring)
            
        fi
}
###################################################################################################################################################################

GET_LOADERS(){
CheckLoaders=1
strng=`echo "$MountEFIconf" | grep -A 1 -e "CheckLoaders</key>" | grep false | tr -d "<>/"'\n\t'`
if [[ $strng = "false" ]]; then CheckLoaders=0
fi
}

# Заполнение массивов dlist и nlist. Получаем списки EFI разделов - dlist
# И список указателей на валидные значения в нём - nlist

CHECK_USB(){

if [[ ! $posrm = 0 ]]; then
                usb=0
                for (( i=0; i<$posrm; i++ ))
                do
                if [[ "${dstring}" = "${rmlist[$i]}" ]]; then usb=1; break; fi
                done                
            fi
}

GET_EFI_S(){

ioreg_iomedia=`ioreg -c IOMedia -r | tr -d '"|+{}\t'`
usb_iomedia=`ioreg -c IOUSB | tr -d '"|+{}\t'`
#string=`diskutil list | grep EFI | grep -oE '[^ ]+$' | xargs | tr ' ' ';'`
efi_string=`echo "$ioreg_iomedia" | grep -v "Statistics = " |  grep -i -A 22 "EFI System Partition" | grep -A 10 -B 10 "Removable = No" | grep "BSD Name" | grep -oE '[^ ]+$' | xargs | tr ' ' ';'`
rem_string=`echo "$ioreg_iomedia" | grep -v "Statistics = " | grep -A 22 "<class IOMedia," | grep -A 10 -B 10 "Removable = Yes" | grep -A 5 -B 5  "Whole = No" | grep "BSD Name" | cut -f2 -d "="  | tr -d " " | tr '\n' ';'`
disk_images=`echo "$ioreg_iomedia" | egrep -A 22 "Apple UDIF" | grep "BSD Name" | cut -f2 -d "="  | tr -d " " | tr '\n' ';'`
drives_iomedia=`echo "$ioreg_iomedia" |  egrep -A 22 "<class IOMedia,"`
drives_string=`echo "$drives_iomedia" | grep -v "Statistics = "  | grep -A 10 -B 10 "Removable = No" | grep -A 5 -B 5  "Whole = Yes" | grep "BSD Name" | grep -oE '[^ ]+$' | xargs | tr ' ' ';'`
removables=`echo "$drives_iomedia" | grep -A 10 -B 10 "Removable = Yes" | grep -A 5 -B 5  "Whole = Yes" | grep "BSD Name" | cut -f2 -d "=" | tr -d " " | tr "\n" ";"`
IFS=';'; dmlist=($drives_string); ilist=($disk_images); remlist=($rem_string); unset IFS; posd=${#dmlist[@]}; posi=${#ilist[@]}; posrem=${#remlist[@]}
usblist=()
if [[ ! $posi = 0 ]]; then 
for (( i=0; i<$posrem; i++ )); do
    dmstring=`echo ${remlist[$i]} | rev | cut -f2-3 -d"s" | rev`
    match=0
        for (( n=0; n<=$posi; n++ )); do
                if [[ "$dmstring" = "${ilist[$n]}" ]]; then match=1; break; fi
        done
                if [[ ! $match = 1 ]]; then usblist+=( ${remlist[$i]} ); fi
    done
    else
      usblist=( ${remlist[@]} )
fi
usb_string=""
for (( i=0; i<$posd; i++ )); do
dmname=`echo "$drives_iomedia" | grep -B 10 ${dmlist[$i]} | grep -m 1 -w "IOMedia"  | cut -f1 -d "<" | sed -e s'/-o //'  | sed -e s'/Media//' | sed 's/ *$//' | tr -d "\n"`
#usbname=`echo "$usb_iomedia" | tr -d '"|+{}\t' | grep  "<class IOUSBHostDevice," | grep -m 1 -w "$dmname"  | cut -f1 -d "<" | sed -e s'/-o //' | cut -f1 -d "@"  | xargs | tr -d "\n"`
usbname=`echo "$usb_iomedia" | grep  "<class IOUSBHostDevice," | grep -m 1 -wo "$dmname"`
if [[ "$usbname" = "$dmname" ]]; then 
usb_string+=`echo "$ioreg_iomedia" | egrep -A 22 "<class IOMedia," | grep -A 5 -B 5  "Whole = No" | grep "${dmlist[$i]}" | grep "BSD Name" | grep -oE '[^ ]+$' | xargs | tr ' ' ';'`";"
removables+="${dmlist[$i]}"";"
fi
done 


usb=0
string="$efi_string"";"
if [[ ! "${#usblist[@]}" = 0 ]]; then 
    for (( i=0; i<${#usblist[@]}; i++ )); do
        string+="${usblist[$i]}"";"
    done
    usb=1
fi
if [[ ! "$usb_string" = "" ]]; then string+="$usb_string"; usb=1; fi
syspart=`df / | grep /dev | cut -f1 -d " " | sed s'/dev//' | tr -d '/ \n'`


IFS=';' 
dlist=($string)
tmlist=($removables)
unset IFS;
pos=${#dlist[@]}
posrm=${#tmlist[@]}
if [[ ! $posi = 0 ]]; then
        if [[ ! $posrm = 0 ]]; then
            unset rmlist
                for (( i=0; i<$posrm; i++ )); do
                    match=0
                        for (( n=0; n<=$posi; n++ )); do
                            if [[ "${ilist[$n]}" = "${tmlist[$i]}" ]]; then match=1;  break; fi
                        done
                        if [[ $match = 0 ]]; then rmlist+=( ${tmlist[$i]} );  fi
                done
            posrm=${#rmlist[@]}
        fi
    else
        if [[ $posrm != 0 ]]; then
            rmlist=( ${tmlist[@]} )
        fi
fi
#if [[ $posrm = 0 ]]; then usb=0
#fi
sizes_iomedia=`echo "$ioreg_iomedia" |  sed -e s'/Logical Block Size =//' | sed -e s'/Physical Block Size =//' | sed -e s'/Preferred Block Size =//' | sed -e s'/EncryptionBlockSize =//'`

ustring=`ioreg -c IOMedia -r  | tr -d '"|+{}\t'  | grep -A 10 -B 5  "Whole = Yes" | grep "BSD Name" | grep -oE '[^ ]+$' | xargs | tr ' ' ';'` ; IFS=";"; uuid_list=($ustring); unset IFS; uuid_count=${#uuid_list[@]}
        if [[ ! $old_uuid_count = $uuid_count ]]; then old_uuid_count=$uuid_count; fi

pstring=`df | cut -f1 -d " " | grep "/dev" | cut -f3 -d "/"` ; puid_list=($pstring);  puid_count=${#puid_list[@]}
        if [[ ! $old_puid_count = $puid_count ]]; then  old_puid_count=$puid_count; old_puid_list=($pstring); old_uuid_list=($ustring); fi

}

GETARR(){

GET_EFI_S

GET_SKEYS
if [[ $ShowKeys = 1 ]]; then lines=25; else lines=22; fi
let "lines=lines+pos"
if [[ ! $usb = 0 ]]; then let "lines=lines+3"; fi
lists_updated=1

if [[ ! $pos = 0 ]]; then 
		var0=$pos
		num=0
		dnum=0; 
        unset nlist
        unset rnlist
	while [[ ! $var0 = 0 ]] 
		do
		string=`echo ${dlist[$num]}`
if [[ $string = $syspart ]]; then unset dlist[$num]; let "pos--"
            else
		dstring=`echo $string | rev | cut -f2-3 -d"s" | rev `
		dlenth=`echo ${#dstring}`

		
		var10=$posi; numi=0; out=0
        while [[ ! $var10 = 0 ]] 
		do

		if [[ ${dstring} = ${ilist[$numi]} ]]; then
        unset dlist[$num]; let "pos--"; out=1
        fi 
        if [[ $out = 1 ]]; then break; fi
        let "var10--"; let "numi++"
        done
  
		if [[ $var10 = 0 ]]; then nlist+=( $num ); fi
            
	fi	
		let "var0--"
		let "num++"
	done
fi


#rnlist - указатель на USB в списе разделов

	if [[ $pos = 0 ]]; then
clear
		if [[ $loc = "ru" ]]; then
	printf '\nНеизвестная ошибка. Нет разделов EFI для монтирования\n'
	printf 'Конец программы...\n\n\n\n''\e[3J'
	printf 'Нажмите любую клавишу закрыть терминал  '
			else
	printf '\nUnknown error. No EFI partition found for mount\n'
	printf 'The end of the program...\n\n\n\n''\e[3J'
	printf 'Press any key to close the window  '
		fi
sleep 0.5
read  -n1 demo
EXIT_PROGRAM
	fi
}

DO_MOUNT(){

		if [[ $flag = 1 ]]; then
        if [[ ! $mypassword = "0" ]]; then
                echo $mypassword | sudo -S diskutil quiet mount  /dev/${string} 2>/dev/null
                    else
                        sudo printf ''
                        sudo diskutil quiet mount  /dev/${string}
         fi

       		 else

        	 	diskutil quiet mount  /dev/${string}

		fi

}




# Определение функции получения информаци о системном разделе EFI
GET_SYSTEM_EFI(){

if [[ ${lists_updated} = 1 ]]; then
sysdrive=`df /  | grep /dev | awk '{print $1;}' | cut -c 6- | sed 's/s[0-9].*//1' | tr -d "\n"`
edname=`diskutil info $sysdrive | grep "Device / Media Name:" | cut -d":" -f2 | rev | sed 's/[ \t]*$//' | rev | tr -d "\n"`
drives_iomedia=`ioreg -c IOMedia -r | tr -d '"|+{}\t'`

var2=$pos
num=0
while [ $var2 != 0 ] 
do 
pnum=${nlist[num]}
string=`echo ${dlist[$pnum]}`
dstring=`echo $string | rev | cut -f2-3 -d"s" | rev`
dname=`echo "$drives_iomedia" | grep -B 10 ${dstring} | grep -m 1 -w "IOMedia"  | cut -f1 -d "<" | sed -e s'/-o //'  | sed -e s'/Media//' | sed 's/ *$//' | tr -d "\n"`

if [[ "$edname" = "$dname" ]]; then  enum=$pnum;  var2=1
        else
checkit=$( echo "$dname" | grep -w "$edname")
        if [[ ! $checkit = "" ]]; then  enum=$pnum;  var2=1; fi
fi
let "num++"
let "var2--"
done
lists_updated=0
fi
}

MOUNTED_CHECK(){

 mcheck=`df | grep ${string}`; if [[ ! $mcheck = "" ]]; then mcheck="Yes"; fi
	if [[ ! $mcheck = "Yes" ]]; then

	clear
			if [[ $loc = "ru" ]]; then
	printf '\n\n  !!! Не удалось подключить раздел EFI. Неизвестная ошибка !!!\n\n'
	printf '\n\n  Выходим. Конец программы. \n\n\n\n''\e[3J'
	printf 'Нажмите любую клавишу закрыть терминал  '
			else
	printf '\n\n  !!! Failed to mount EFI partition. Unknown error. !!!\n\n'
	printf '\n\n  The end of the program. \n\n\n\n''\e[3J'
	printf 'Press any key to close the window  '
			fi

 	sleep 0.5
	read  -n1 demo
	EXIT_PROGRAM

	fi
}

UNMOUNTED_CHECK(){

 mcheck=`df | grep ${string}`; if [[ ! $mcheck = "" ]]; then mcheck="Yes"; fi
	if [[  $mcheck = "Yes" ]]; then
		
		sleep 1.5

		diskutil quiet umount force  /dev/${string}

 mcheck=`df | grep ${string}`; if [[ ! $mcheck = "" ]]; then mcheck="Yes"; fi

	if [[  $mcheck = "Yes" ]]; then

		sleep 1.5
            

                if [[ ! $mypassword = "0" ]]; then

                echo $mypassword | sudo -S diskutil quiet umount force  /dev/${string} 2>/dev/null
            
                    else
            
        	 	sudo diskutil quiet umount force  /dev/${string}

                    fi

	     fi
fi
}
##################################################################################################
SPIN_OC(){
printf '\r\n'
printf "\033[57C"
spin='-\|/'
i=0
while :;do let "i++"; i=$(( (i+1) %4 )) ; printf '\e[1m'"\b$1${spin:$i:1}"'\e[0m' ;sleep 0.2;done &
trap "kill $!" EXIT
FIND_OPENCORE 
kill $!
wait $! 2>/dev/null
trap " " EXIT
}

#####################################################################################################
SPIN_FCLOVER(){
printf '\r\n'
printf "\033[57C"
spin='-\|/'
i=0
while :;do let "i++"; i=$(( (i+1) %4 )) ; printf '\e[1m'"\b$1${spin:$i:1}"'\e[0m' ;sleep 0.2;done &
trap "kill $!" EXIT 
FIND_CLOVER
kill $!
wait $! 2>/dev/null
trap " " EXIT
}
#####################################################################################################

# Определение функции розыска Clover в виде проверки бинарика EFI/BOOT/bootx64.efi 
##############################################################################
FIND_CLOVER(){

printf '\r\n\n'
if [[ $loc = "ru" ]]; then
printf '  Подождите. Ищем загрузочные разделы с Clover ...  '
else
printf '  Wait. Looking for boot partitions with Clover loader...  '
fi

was_mounted=0
var1=$pos
num=0
spin='-\|/'
i=0
noefi=1
while [ $var1 != 0 ] 
do 

	pnum=${nlist[num]}
	string=`echo ${dlist[$pnum]}`
    mcheck=`df | grep ${string}`; if [[ ! $mcheck = "" ]]; then mcheck="Yes"; fi
	if [[ ! $mcheck = "Yes" ]]; then 

	was_mounted=0

       	
	DO_MOUNT	

	MOUNTED_CHECK

	else
		was_mounted=1

	fi

vname=`df | egrep ${string} | sed 's#\(^/\)\(.*\)\(/Volumes.*\)#\1\3#' | cut -c 2-`

	if [[ -d "$vname"/EFI/BOOT ]]; then
			if [[ -f "$vname"/EFI/BOOT/BOOTX64.efi ]] && [[ -f "$vname"/EFI/BOOT/bootx64.efi ]] && [[ -f "$vname"/EFI/BOOT/BOOTx64.efi ]]; then 

					check_loader=`xxd "$vname"/EFI/BOOT/BOOTX64.EFI | grep -Eo "Clover"` ; check_loader=`echo ${check_loader:0:6}`

                					if [[ ${check_loader} = "Clover" ]]; then

                       						 if [[ ! $OpenFinder = 0 ]]; then open "$vname/EFI"; fi
							 was_mounted=1

                 fi   
	   fi
	fi


		if [[ "$was_mounted" = 0 ]]; then

	diskutil quiet  umount  force /dev/${string}; mounted=0
		
		UNMOUNTED_CHECK		

		fi
		
let "num++"
let "var1--"

done

nogetlist=1


}


FIND_OPENCORE(){

printf '\r\n\n'
if [[ $loc = "ru" ]]; then
printf '  Подождите. Ищем загрузочные разделы с OpenCore ...  '
else
printf '  Wait. Looking for boot partitions with OpenCore loader...  '
fi

was_mounted=0
var1=$pos
num=0
spin='-\|/'
i=0
noefi=1

while [ $var1 != 0 ] 
do 

	pnum=${nlist[num]}
	string=`echo ${dlist[$pnum]}`

    mcheck=`df | grep ${string}`; if [[ ! $mcheck = "" ]]; then mcheck="Yes"; fi 

	if [[ ! $mcheck = "Yes" ]]; then 

	was_mounted=0

       	
	DO_MOUNT	

	MOUNTED_CHECK

	else
		was_mounted=1

	fi

    vname=`df | egrep ${string} | sed 's#\(^/\)\(.*\)\(/Volumes.*\)#\1\3#' | cut -c 2-`

	if [[ -d "$vname"/EFI/BOOT ]]; then
			if [[ -f "$vname"/EFI/BOOT/BOOTX64.efi ]] && [[ -f "$vname"/EFI/BOOT/bootx64.efi ]] && [[ -f "$vname"/EFI/BOOT/BOOTx64.efi ]]; then 

					check_loader=`xxd "$vname"/EFI/BOOT/BOOTX64.EFI | grep -Eo "OpenCore"` ; check_loader=`echo ${check_loader:0:8}`
                					if [[ ${check_loader} = "OpenCore" ]]; then
                       						 if [[ ! $OpenFinder = 0 ]]; then open "$vname/EFI"; fi
							 was_mounted=1
                 fi   
	   fi
	fi

		if [[ "$was_mounted" = 0 ]]; then
	diskutil quiet  umount  force /dev/${string}; mounted=0
		
		UNMOUNTED_CHECK		

		fi
		
let "num++"
let "var1--"

done

nogetlist=1


}

# Функция отключения EFI разделов

UNMOUNTS(){


		GETARR
var1=$pos
num=0
spin='-\|/'
i=0
noefi=1

cd ~

while [ $var1 != 0 ] 
do 

	pnum=${nlist[num]}
	string=`echo ${dlist[$pnum]}`

    mcheck=`df | grep ${string}`; if [[ ! $mcheck = "" ]]; then mcheck="Yes"; fi 


if [[ $mcheck = "Yes" ]]; then
	noefi=0
	diskutil quiet umount force  /dev/${string}

	UNMOUNTED_CHECK	

	order=1; let "chs=num+1"; UPDATELIST

	let "i++"
	i=$(( (i+1) %4 ))
	printf "\b$1${spin:$i:1}"
	fi

    let "num++"
	let "var1--"
done



printf '\r                                                          '
printf "\r\033[2A"
printf '\r                                                          '
printf '\n\n'


nogetlist=1
if [[ ${noefi} = 0 ]]; then order=2; printf "\r\033[2A"; fi


}

# У Эль Капитан другой термин для размера раздела
# Установка флага необходимости в SUDO - flag	
macos=`sw_vers -productVersion`
macos=`echo ${macos//[^0-9]/}`
macos=${macos:0:4}
if [[ "$macos" = "1015" ]] || [[ "$macos" = "1014" ]] || [[ "$macos" = "1013" ]] || [[ "$macos" = "1012" ]]; then
        vmacos="Disk Size:"
        if [[ "$macos" = "1015" ]] || [[ "$macos" = "1014" ]] || [[ "$macos" = "1013" ]]; then flag=1; else flag=0; fi
    else
        vmacos="Total Size:"
        flag=0
fi



GETARR

# Блок обработки ситуации если найден всего один раздел EFI ########################
###################################################################################

if [[ $pos = 1 ]]; then 

if [[ ! ${menue} = 1 ]]; then

GET_USER_PASSWORD

unset string
string=`echo ${dlist[0]}`

wasmounted=0

mcheck=`df | grep ${string}`; if [[ ! $mcheck = "" ]]; then mcheck="Yes"; fi 
if [[ ! $mcheck = "Yes" ]]; then

    if [[ $mypassword = "0" ]] && [[ $flag = 1 ]]; then


theme="system"
GET_THEME
if [[ $theme = "built-in" ]]; then CUSTOM_SET; fi


    if [[ $loc = "ru" ]]; then
        printf '\n******    Программа монтирует EFI разделы в Mac OS (X.11 - X.14)    *******\n\n'
			else
        printf '\n******    This program mounts EFI partitions on Mac OS (X.11 - X.14)    *******\n\n'
	                 fi
                    	dstring=`echo $string | rev | cut -f2-3 -d"s" | rev`
		
    	printf '\n     '
	     let "corr=0"

        dsize=`echo "$sizes_iomedia" | grep -A10 -B10 ${string} | grep -m 1 -w "Size =" | cut -f2 -d "=" | tr -d "\n \t"`
        if [[  $dsize -le 999999999 ]]; then dsize=$(echo "scale=1; $dsize/1000000" | bc)" Mb"
        else
            if [[  $dsize -le 999999999999 ]]; then dsize=$(echo "scale=1; $dsize/1000000000" | bc)" Gb"
                    else
                         dsize=$(echo "scale=1; $dsize/1000000000000" | bc)" Gb"
            fi
        fi	

        drive=`echo "$drives_iomedia" | grep -B 10 ${dstring} | grep  -m 1 -w "IOMedia"  | cut -f1 -d "<" | sed -e s'/-o //'  | sed -e s'/Media//' | sed 's/ *$//' | tr -d "\n"`
    	if [[ ${#drive} -gt 30 ]]; then drive=$( echo "$drive" | cut -f1-2 -d " " ); fi

    	   let "scorr=5"
           let "dcorr=5"

if [[ $loc = "ru" ]]; then
	printf '  Подключить (открыть) EFI раздел:  \n\n' 
	printf '     '
	printf '.%.0s' {1..68} 
	printf '\n' 
		else
	printf '   Mount (open folder) EFI partition:  \n\n' 
	printf '     '
	printf '.%.0s' {1..68} 
	printf '\n' 
        fi
            
	printf '\n              '"$drive""%"$dcorr"s"${string}"%"$corr"s"'  '"%"$scorr"s""$dsize"'\n' 
    printf '\n     '
	printf '.%.0s' {1..68}
    var98=3 
    while [[ ! $var98 = 0 ]]; 
    do
        if [[ $loc = "ru" ]]; then
    printf '\n\nвведите пароль для подключения EFI: '
         else
    printf '\n\nenter your password to mount EFI: '
        fi
    read -s mypassword
    if echo $mypassword | sudo -Sk printf '' 2>/dev/null; then
    printf '\n\n OK!'; break
        else
            if [[ ! $mypassword = "0" ]]; then
                        if [[ $loc = "ru" ]]; then
                printf '\n\nНе верный пароль \e[1m'$mypassword'\e[0m \n'
                                        else
                printf '\n\nWrong password \e[1m'$mypassword'\e[0m \n'
                        fi
            read -t 2 -n 1 -s
            mypassword="0"
            let "var98--"
            printf '\r\033[3A'
            printf ' %.0s' {1..68}; printf ' %.0s' {1..68}; printf ' %.0s' {1..68};
            printf '\r\033[4A'
            fi
     fi
    done
 fi        

if [[ $var98 = 0 ]]; then 
            printf '\r'
            printf ' %.0s' {1..68}; printf ' %.0s' {1..68}
            printf '\r\033[1A'
            if [[ $loc = "ru" ]]; then
            printf '\n\n Без правильного пароля EFI не подключить. Выходим.....\n\n\n'
            else
            printf '\n\n You have to input valid password to mount EFI. Exiting....\n\n\n'
            fi
            read -t 2 -n 1 -s
            EXIT_PROGRAM
fi

DO_MOUNT

MOUNTED_CHECK
else
wasmounted=1
	fi
vname=`df | egrep ${string} | sed 's#\(^/\)\(.*\)\(/Volumes.*\)#\1\3#' | cut -c 2-`

clear
		if [[ $loc = "ru" ]]; then
			printf '\nРаздел: '${string}' ''подключен.\n\n'
			printf 'Выходим.. \n\n\n\n''\e[3J'
			else
			printf '\nPartition: '${string}' ''mounted.\n\n'
			printf 'Exit the program. \n\n\n\n''\e[3J'
		fi

if [[ $OpenFinder = 0 ]] ; then 
        if [[ $wasmounted = 1 ]]; then open "$vname"; fi
    else 
        open "$vname"
fi


EXIT_PROGRAM

fi			
# Конец блока обработки если один  раздел EFI #################################################
###########################################################################################
fi

################### применение темы ##########################################################
theme="system"
GET_THEME
if [[ $theme = "built-in" ]]; then CUSTOM_SET; fi
############################################################################################

################################ получение имени диска для переименования #####################
GET_RENAMEHD(){
strng=`echo "$MountEFIconf" | grep -A 1 "RenamedHD" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
IFS=';'; rlist=($strng); unset IFS
rcount=${#rlist[@]}
if [[ ! $rcount = 0 ]]; then
        var=$rcount; posr=0
            while [[ ! $var = 0 ]]
         do
            rdrive=`echo "${rlist[$posr]}" | cut -f1 -d"="`
            if [[ "$rdrive" = "$drive" ]]; then drive=`echo "${rlist[posr]}" | rev | cut -f1 -d"=" | rev`; break; fi
            let "var--"
            let "posr++"
         done
fi
}
##############################################################################################

##################### проверка на загрузчик после монтирования ##################################################################################
FIND_LOADERS(){

GET_LOADERS
if [[ ! $CheckLoaders = 0 ]]; then 

    unset loader
    if [[ $mcheck = "Yes" ]]; then 


vname=`df | egrep ${string} | sed 's#\(^/\)\(.*\)\(/Volumes.*\)#\1\3#' | cut -c 2-`

        if [[ -d "$vname"/EFI/BOOT ]]; then
			if [[ -f "$vname"/EFI/BOOT/BOOTX64.efi ]] && [[ -f "$vname"/EFI/BOOT/bootx64.efi ]] && [[ -f "$vname"/EFI/BOOT/BOOTx64.efi ]]; then 
                check_loader=`xxd "$vname"/EFI/BOOT/BOOTX64.EFI | grep -Eo "Clover"` ; check_loader=`echo ${check_loader:0:6}`
                        if [[ ${check_loader} = "Clover" ]]; then loader="Clover"
                        else
                             check_loader=`xxd "$vname"/EFI/BOOT/BOOTX64.EFI | grep -Eo "OpenCore"` ; check_loader=`echo ${check_loader:0:8}`; fi
                					if [[ ${check_loader} = "OpenCore" ]]; then loader="OpenCore"; fi   
	         fi
        fi

    fi
fi

}
#######################################################################################################################################################

########################### вывод признаков наличия загрузчика #########################################
SHOW_LOADERS(){

if [[ $CheckLoaders = 1 ]]; then
printf "\033[H"
        posl=${#ldlist[@]}
            if [[ ! $posl = 0 ]]; then
            var99=$posl; pointer=0
                while [ $var99 != 0 ] 
                    do 
                        if [[ ${ldnlist[pointer]} -le $sata_lines ]]; then
                        let "line=ldnlist[pointer]+8" 
                        else
                        let "line=ldnlist[pointer]+11"
                        fi
                        if [[ ${ldlist[$pointer]} = "Clover" ]]; then printf "\r\033[$line;f\033[47C"; else printf "\r\033[$line;f\033[46C"; fi
                        printf '\e[37m'${ldlist[$pointer]}'\e[0m'
                        let "pointer++"
                        let "var99--"
                    done
    fi                       
fi
printf "\033[H"; let "correct=lines-7"; printf "\r\033[$correct;f\033[49C"
}
#################################################################################################
spinny(){
 let "i++"
	i=$(( (i+1) %4 ))
	printf "\b$1${spin:$i:1}"
}


# Определение  функции построения и вывода списка разделов 
GETLIST(){

GET_LOADERS
if [[ ! $CheckLoaders = 0 ]]; then col=88; ldcorr=8; else col=80; ldcorr=2;  fi 

printf '\e[8;'${lines}';'$col't' && printf '\e[3J'

unset ldlist; unset ldnlist
var0=$pos
num=0
ch=0
unset string
unset screen_buffer
unset usb_screen_buffer
sata_lines=0
usb_lines=0


			if [[ $loc = "ru" ]]; then
	printf '\n  Подключить (открыть) EFI разделы: (  +  уже подключенные) \n'

	printf '\n\n      0)  поиск разделов ..... '
		else
	printf '\n   Mount (open folder) EFI partitions:  (  +  already mounted) \n'

	printf '\n\n      0)  updating partitions list ..... '
        fi


spin='-\|/'
i=0
printf "$1${spin:$i:1}"

while [ $var0 != 0 ] 
do 
	let "ch++"

    spinny
	
	pnum=${nlist[num]}
	string=`echo ${dlist[$pnum]}`
	
	dstring=`echo $string | rev | cut -f2-3 -d"s" | rev`


		dlenth=`echo ${#dstring}`
		let "corr=9-dlenth"
    spinny
		
        drive=`echo "$drives_iomedia" | grep -B 10 ${dstring} | grep -m 1 -w "IOMedia"  | cut -f1 -d "<" | sed -e s'/-o //'  | sed -e s'/Media//' | sed 's/ *$//' | tr -d "\n"`
        if [[ ${#drive} -gt 30 ]]; then drive=$( echo "$drive" | cut -f1-2 -d " " ); fi
        GET_RENAMEHD
		dcorr=${#drive}
		if [[ ${dcorr} -gt 30 ]]; then dcorr=0; drive="${drive:0:30}"; else let "dcorr=30-dcorr"; fi


    dsize=`echo "$sizes_iomedia" | grep -A10 -B10 ${string} | grep -m 1 -w "Size =" | cut -f2 -d "=" | tr -d "\n \t"`
    if [[  $dsize -le 999999999 ]]; then dsize=$(echo "scale=1; $dsize/1000000" | bc)" Mb"
        else
            if [[  $dsize -le 999999999999 ]]; then dsize=$(echo "scale=1; $dsize/1000000000" | bc)" Gb"
                    else
                         dsize=$(echo "scale=1; $dsize/1000000000000" | bc)" Gb"
            fi
    fi

	
    		scorr=`echo ${#dsize}`
    		let "scorr=scorr-5"
    		let "scorr=6-scorr"

       
    mcheck=`df | grep ${string}`; if [[ ! $mcheck = "" ]]; then mcheck="Yes"; fi 


         if [[ $ch -gt 9 ]]; then ncorr=1; else ncorr=2; fi   

        
          CHECK_USB
          

        if [[ $usb = 1 ]]; then 
                    let "usb_lines++"
                    
                     if [[ ! $mcheck = "Yes" ]]; then
        usb_screen_buffer+=$(printf '\n    '"%"$ncorr"s"$ch') ...   '"$drive""%"$dcorr"s"' '"%"$ldcorr"s"' '${string}"%"$corr"s""%"$scorr"s"' '"$dsize"'     ')
                            else
        usb_screen_buffer+=$(printf '\n    '"%"$ncorr"s"$ch')   +   '"$drive""%"$dcorr"s"' '"%"$ldcorr"s"' '${string}"%"$corr"s""%"$scorr"s"' '"$dsize"'     ')
      
              fi

        else
                    let "sata_lines++"
        
                     if [[ ! $mcheck = "Yes" ]]; then
        screen_buffer+=$(printf '\n    '"%"$ncorr"s"$ch') ...   '"$drive""%"$dcorr"s"' '"%"$ldcorr"s"' '${string}"%"$corr"s""%"$scorr"s"' '"$dsize"'     ')
                            else
        screen_buffer+=$(printf '\n    '"%"$ncorr"s"$ch')   +   '"$drive""%"$dcorr"s"' '"%"$ldcorr"s"' '${string}"%"$corr"s""%"$scorr"s"' '"$dsize"'     ')
      
              fi
        fi

        spinny

        FIND_LOADERS        
        if [[ ! $loader = "" ]]; then ldlist+=($loader); ldnlist+=($ch); fi
      

    spinny
	let "num++"
	let "var0--"
done


printf "\r\033[3A"


		if [[ $loc = "ru" ]]; then
	printf '  Подключить (открыть) EFI разделы: (  +  уже подключенные) \n' 
	printf '     '
                if [[ $CheckLoaders = 0 ]]; then
	            printf '.%.0s' {1..32} 
                printf ' SATA '
                printf '.%.0s' {1..30}
                else
                printf '.%.0s' {1..36}
                printf ' SATA '
                printf '.%.0s' {1..34}
                fi
	printf '\n\n      0)  повторить поиск разделов\n' 
		else
	printf '   Mount (open folder) EFI partitions:  (  +  already mounted) \n' 
	printf '     '
                if [[ $CheckLoaders = 0 ]]; then
	            printf '.%.0s' {1..32} 
                printf ' SATA '
                printf '.%.0s' {1..30}
                else
                printf '.%.0s' {1..36}
                printf ' SATA '
                printf '.%.0s' {1..34}
                fi
	printf '\n\n      0)  update EFI partitions list             \n' 
        fi

echo "${screen_buffer}"
if [[ ! $usb_lines = 0 ]]; then

                printf '\n     '
                if [[ $CheckLoaders = 0 ]]; then
	            printf '.%.0s' {1..32} 
                printf ' USB '
                printf '.%.0s' {1..31}
                else
                printf '.%.0s' {1..36}
                printf ' USB '
                printf '.%.0s' {1..35}
                fi
                printf '\n     '

echo "${usb_screen_buffer}"
fi

	let "ch++"
	
	            printf '\n     '
                if [[ $CheckLoaders = 0 ]]; then
	            printf '.%.0s' {1..68} 
                else
                printf '.%.0s' {1..76}
                fi

if [[ $ShowKeys = 1 ]]; then

	if [[ $loc = "ru" ]]; then
	printf '\n      E  -   найти и подключить EFI системного диска \n'
	printf '      U  -   отключить ВСЕ подключенные разделы  EFI\n'
    printf '      I  -   дополнительное меню                     \n'
	printf '      Q  -   закрыть окно и выход из программы\n' 
    printf '                                                    \n'
			else
	printf '\n      E  -   find and mount this system drive EFI \n' 
	printf '      U  -   unmount ALL mounted  EFI partitions \n'
    printf '      I  -   extra menu                      \n'
	printf '      Q  -   close terminal and exit from the program\n'
    printf '                                                    \n' 
	     fi
else 
        printf '\n'
        if [[ $CheckLoaders = 0 ]]; then printf '\n\n'; fi
fi
	


	
printf '\n\n' 

SHOW_LOADERS


}
# Конец определения GETLIST ###########################################################

# Определение функции обновления информации  экрана при подключении и отключении разделов
UPDATELIST(){

dstring=`echo $string | rev | cut -f2-3 -d"s" | rev`

CHECK_USB



 clear && printf '\e[8;'${lines}';'$col't' && printf '\e[3J' && printf "\033[H"



if [[ ! $order = 3 ]] && [[ ! $order = 4 ]]; then
if [[ $order = 0 ]]; then
            if [[ $usb = 0 ]]; then
screen_buffer=$( echo  "$screen_buffer" | sed "s/$chs) ...  /$chs)   +  /" )
            else
usb_screen_buffer=$( echo  "$usb_screen_buffer" | sed "s/$chs) ...  /$chs)   +  /" )
            fi
    else
            if [[ $usb = 0 ]]; then
screen_buffer=$( echo  "$screen_buffer" | sed "s/$chs)   +  /$chs) ...  /" )
            else
usb_screen_buffer=$( echo  "$usb_screen_buffer" | sed "s/$chs)   +  /$chs) ...  /" )
            fi
    fi

fi


		if [[ $loc = "ru" ]]; then
        	printf '\n******    Программа монтирует EFI разделы в Mac OS (X.11 - X.14)    *******\n'
	printf '\n  Подключить (открыть) EFI разделы: (  +  уже подключенные) \n' 
	printf '     '
               if [[ $CheckLoaders = 0 ]]; then
	            printf '.%.0s' {1..32} 
                printf ' SATA '
                printf '.%.0s' {1..30}
                else
                printf '.%.0s' {1..36}
                printf ' SATA '
                printf '.%.0s' {1..34}
                fi
	printf '\n\n      0)  повторить поиск разделов\n' 
			else
        	printf '\n******    This program mounts EFI partitions on Mac OS (X.11 - X.14)    *******\n'
	printf '\n   Mount (open folder) EFI partitions:  (  +  already mounted) \n' 
	printf '     '
                if [[ $CheckLoaders = 0 ]]; then
	            printf '.%.0s' {1..32} 
                printf ' SATA '
                printf '.%.0s' {1..30}
                else
                printf '.%.0s' {1..36}
                printf ' SATA '
                printf '.%.0s' {1..34}
                fi
	printf '\n\n      0)  update EFI partitions list             \n' 
        fi


echo  "$screen_buffer"
if [[ ! $usb_lines = 0 ]]; then

                printf '\n     '
                if [[ $CheckLoaders = 0 ]]; then
	            printf '.%.0s' {1..32} 
                printf ' USB '
                printf '.%.0s' {1..31}
                else
                printf '.%.0s' {1..36}
                printf ' USB '
                printf '.%.0s' {1..35}
                fi
                printf '\n     '

echo "${usb_screen_buffer}"
fi


	if [[ ! $order = 1 ]] || [[ ! $order = 0 ]]; then printf "\r\033[1A"; fi
    
	printf '\n\n     '
                if [[ $CheckLoaders = 0 ]]; then
	            printf '.%.0s' {1..68} 
                else
                printf '.%.0s' {1..76}
                fi

if [[ $ShowKeys = 1 ]]; then

if [[ ! $order = 3 ]]; then
	     if [[ $loc = "ru" ]]; then
	printf '\n      E  -   найти и подключить EFI системного диска \n'
	printf '      U  -   отключить ВСЕ подключенные разделы  EFI\n'
    printf '      I  -   дополнительное меню                     \n'
	printf '      Q  -   закрыть окно и выход из программы\n\n'
    printf '                                                    \n' 
			else
	printf '\n      E  -   find and mount this system drive EFI \n' 
	printf '      U  -   unmount ALL mounted  EFI partitions \n'
    printf '      I  -   extra menu                      \n'
	printf '      Q  -   close terminal and exit from the program\n\n'
    printf '                                                    \n' 
	     fi
	else
        if [[ $loc = "ru" ]]; then
	printf '\n      C  -   найти и подключить EFI с загрузчиком Clover \n'
	printf '      O  -   найти и подключить EFI с загрузчиком Open Core\n'
	printf '      S  -   вызвать экран настройки MountEFI\n'
    printf '      I  -   главное меню                     \n'
    printf '      Q  -   закрыть окно и выход из программы\n\n' 
			else
	printf '\n      C  -   find and mount EFI with Clover boot loader \n' 
	printf '      O  -   find and mount EFI with Open Core boot loader \n' 
	printf '      S  -   call MountEFI setup screen\n'
    printf '      I  -   main menu                      \n'
    printf '      Q  -   close terminal and exit from the program\n\n' 
	     fi
fi
else printf '\n\n'
fi

if [[ ! $ShowKeys = 1 ]]; then printf '\n\n'; fi
#	printf '\n'
	
    if [[ $sym = 2 ]]; then printf '\n'; fi
	printf "\r\n\033[1A"
	


	if [ $loc = "ru" ]; then
let "schs=$ch-1"
printf '  Введите число от 0 до '$schs' (или  U, E, I, Q ):  '; printf '                               '
			else
printf '  Enter a number from 0 to '$schs' (or  U, E, I, Q ):  ';  printf '                              '
	fi
	if [[ $order = 1 ]]; then
		if [ $loc = "ru" ]; then
	printf '\n\n  Oтключаем EFI разделы ...  '
				else
	printf '\n\n  Unmounting EFI partitions ....  '
			fi
	fi

if [[ $CheckLoaders = 1 ]]; then
        if [[ $order = 0 ]] || [[ $order = 4 ]] || [[ $order = 3 ]]; then 
            unset old_puid_count; CHECK_HOTPLUG_PARTS
        fi
fi



}
# Конец определения функции UPDATELIST ######################################################

##################### обновление данных буфера экрана при детекте хотплага партиции ###########################
#UPDATE_SCREEN_BUFFER(){
#unset ldlist; unset ldnlist
#var0=$pos; num=0; ch1=0
#unset string
#while [ $var0 != 0 ] 
#do 
#pnum=${nlist[num]}
#string=`echo ${dlist[$pnum]}`
#	let "ch1++"
#mcheck=`df | grep ${string}`; if [[ ! $mcheck = "" ]]; then mcheck="Yes"; fi
#if [[ $mcheck = "Yes" ]]; then

#        FIND_LOADERS        
#        if [[ ! $loader = "" ]]; then ldlist+=($loader); ldnlist+=($ch1); fi
#            check=$( echo "${screen_buffer}" | grep "$ch1)   +" )
#            if [[ "${check}" = "" ]]; then
##        screen_buffer=$( echo  "$screen_buffer" | sed "s/$ch1) ...  /$ch1)   +  /" )
#     fi

#else
#            check=$( echo "${screen_buffer}" | grep "$ch1) ..." )
#           if [[ ! "${check}" = "" ]]; then 
#        screen_buffer=$( echo  "$screen_buffer" | sed "s/$ch1)   +  /$ch1) ...  /" )
#    fi
#fi
#let "num++"
#let "var0--"
#done



#}
############################ конец определения функции UPDATE PARTS ############################################

##################### обновление данных буфера экрана при детекте хотплага партиции ###########################
UPDATE_SCREEN_BUFFER(){
unset ldlist; unset ldnlist
var0=$pos; num=0; ch1=0
unset string
while [ $var0 != 0 ] 
do 
pnum=${nlist[num]}
string=`echo ${dlist[$pnum]}`
	let "ch1++"
mcheck=`df | grep ${string}`; if [[ ! $mcheck = "" ]]; then mcheck="Yes"; fi
if [[ $mcheck = "Yes" ]]; then

        FIND_LOADERS        
        if [[ ! $loader = "" ]]; then ldlist+=($loader); ldnlist+=($ch1); fi

    if [[ $ch1 -le $sata_lines ]]; then
            check=$( echo "${screen_buffer}" | grep "$ch1)   +" )
            if [[ "${check}" = "" ]]; then
        screen_buffer=$( echo  "$screen_buffer" | sed "s/$ch1) ...  /$ch1)   +  /" )
            fi
    
    else

        check=$( echo "${usb_screen_buffer}" | grep "$ch1)   +" )
            if [[ "${check}" = "" ]]; then
        usb_screen_buffer=$( echo  "$usb_screen_buffer" | sed "s/$ch1) ...  /$ch1)   +  /" )
            fi
    fi

else

     if [[ $ch1 -lt $sata_lines ]]; then   
            check=$( echo "${screen_buffer}" | grep "$ch1) ..." )
           if [[ ! "${check}" = "" ]]; then 
        screen_buffer=$( echo  "$screen_buffer" | sed "s/$ch1)   +  /$ch1) ...  /" )
            fi
     else

           check=$( echo "${usb_screen_buffer}" | grep "$ch1) ..." )
           if [[ ! "${check}" = "" ]]; then 
        usb_screen_buffer=$( echo  "$usb_screen_buffer" | sed "s/$ch1)   +  /$ch1) ...  /" )
            fi
     fi 
fi
let "num++"
let "var0--"
done



}


###################################### обновление на экране списка подключенных ###########################################
UPDATE_SCREEN(){
printf "\033[H"
printf "\r\033[8f"
echo  "$screen_buffer"
if [[ ! $usb_lines = 0 ]]; then

                printf '\n     '
                if [[ $CheckLoaders = 0 ]]; then
	            printf '.%.0s' {1..32} 
                printf ' USB '
                printf '.%.0s' {1..31}
                else
                printf '.%.0s' {1..36}
                printf ' USB '
                printf '.%.0s' {1..35}
                fi
                printf '\n     '

echo "${usb_screen_buffer}"
fi

if [[ $posrm = 0 ]]; then
    if [[ $ShowKeys = 1 ]]; then
                printf "\033[9B"
                printf "\r\033[49C"
    else
                printf "\033[4B"
                printf "\r\033[49C"
    fi
else
if [[ $ShowKeys = 1 ]]; then
                printf "\033[12B"
                printf "\r\033[49C"
    else
                printf "\033[7B"
                printf "\r\033[49C"
    fi
fi
  
SHOW_LOADERS

                      
}
################################### конец функции обновления списка подключенных  на экране ##################################

ADVANCED_MENUE(){

    order=3; UPDATELIST; GETKEYS
}
##################### Детект раскладки  и адаптация ввода для двухбайтовых UTF-8  ####################################################################################################
SET_INPUT(){

layout_name=`defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources | egrep -w 'KeyboardLayout Name' | sed -E 's/.+ = "?([^"]+)"?;/\1/' | tr -d "\n"`
xkbs=1

case ${layout_name} in
 "Russian"          ) xkbs=2 ;;
 "RussianWin"       ) xkbs=2 ;;
 "Russian-Phonetic" ) xkbs=2 ;;
 "Ukrainian"        ) xkbs=2 ;;
 "Ukrainian-PC"     ) xkbs=2 ;;
 "Byelorussian"     ) xkbs=2 ;;
 esac

if [[ $xkbs = 2 ]]; then 
cd $(dirname $0)
    if [[ -f "./xkbswitch" ]]; then 
declare -a layouts_names
layouts=`defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleInputSourceHistory | egrep -w 'KeyboardLayout Name' | sed -E 's/.+ = "?([^"]+)"?;/\1/' | tr  '\n' ';'`
IFS=";"; layouts_names=($layouts); unset IFS; num=${#layouts_names[@]}
keyboard="0"

while [ $num != 0 ]; do 
case ${layouts_names[$num]} in
 "ABC"                ) keyboard=${layouts_names[$num]} ;;
 "US Extended"        ) keyboard="USExtended" ;;
 "USInternational-PC" ) keyboard=${layouts_names[$num]} ;;
 "U.S."               ) keyboard="US" ;;
 "British"            ) keyboard=${layouts_names[$num]} ;;
 "British-PC"         ) keyboard=${layouts_names[$num]} ;;
esac

        if [[ ! $keyboard = "0" ]]; then num=1; fi
let "num--"
done

if [[ ! $keyboard = "0" ]]; then ./xkbswitch -se $keyboard; fi
   else
        if [[ $loc = "ru" ]]; then
printf '\n\n                         ! Смените раскладку на латиницу !'
            else
printf '\n\n                          ! Change layout to UTF-8 ABC, US or EN !'
        fi
read -t 2 -n 2 -s
printf '\r                                                                               \r'
 printf "\r\n\033[3A\033[46C" ; if [[ $order = 3 ]]; then printf "\033[3C"; fi   fi

fi
}


##################################################################################################################################################################

############## обновление даных после выхода из скрипта настроек #########################################################

REFRESH_SETUP(){
UPDATE_CACHE
GET_LOCALE
strng=`echo "$MountEFIconf" | grep -A 1 -e "OpenFinder</key>" | grep false | tr -d "<>/"'\n\t'`
if [[ $strng = "false" ]]; then OpenFinder=0; else OpenFinder=1; fi
GET_USER_PASSWORD
}
##########################################################################################################################

########################### определение функции ввода по 2 байта #########################
READ_TWO_SYMBOLS(){
if [[ ! $order = 3 ]]; then order=4; fi 
choice1="±"; choice="±";
printf "\033[?25h"
while [[ $choice1 = "±" ]]
do
printf '\n'
printf '                                                                                \n'
printf '                                                                                '
printf "\r\n\033[3A\033[49C"
IFS="±"; read   -n 1 -t 1  choice1 ; unset IFS 
if [[ $choice1 = "" ]]; then printf "\033[1A"; choice1="±"; fi
if [[ $choice1 = [0-9] ]]; then choice=${choice1}; break
            else
        if [[ ! $order = 3 ]]; then
            if [[ $choice1 = [uUqQeEiIvV] ]]; then choice=${choice1}; break; fi
                    else
             if [[ $choice1 = [qQcCoOsSiIvV] ]]; then choice=${choice1}; break; fi
        fi
 
fi
 choice1="±"


CHECK_HOTPLUG_DISKS
if [[ $hotplug = 1 ]]; then break; fi
CHECK_HOTPLUG_PARTS
done
if [[ ! $hotplug = 1 ]]; then 
    if [[ $choice1 = [0-9] ]]; then
choice1="±"
while [[ $choice1 = "±" ]]
do
printf '\n'
printf '                                                                                \n'
printf '                                                                                '
printf "\r\n\033[3A\033[49C"
CHECK_HOTPLUG_DISKS
if [[ $hotplug = 1 ]]; then break; fi
CHECK_HOTPLUG_PARTS
IFS="±"; read  -n 1 -t 1  choice1 ; unset IFS 
if [[ ! $choice1 = [0-9] ]]; then 
        if [[ $choice1 = "" ]]; then printf "\033[1A"; break
            else choice1="±"; fi
    else
        if [[ $choice = 0 ]]; then unset choice; fi
        choice+=${choice1}
        
fi
done
    fi
fi
printf "\033[?25l"

  }
########################################################################################


# Определение функции ожидания и фильтрации ввода с клавиатуры
GETKEYS(){
unset choice
while [[ ! ${choice} =~ ^[0-9uUqQ]+$ ]]; do
if [[ $order = 2 ]]; then                                               
order=0
fi
printf "\r\n\033[1A"
if [[ $order = 3 ]]; then 
    let "schs=$ch-1"
    if [[ $loc = "ru" ]]; then
printf '  Введите число от 0 до '$schs' (или  C, O, S, I, Q ):   ' ; printf '                             '
			else
printf '  Enter a number from 0 to '$schs' (or  C, O, S, I, Q ):   ' ; printf '                           '
    fi
        else
            let "schs=$ch-1"
            if [[ $loc = "ru" ]]; then
printf '  Введите число от 0 до '$schs' (или  U, E, I, Q ):      ' ; printf '                             '
			else
printf '  Enter a number from 0 to '$schs' (or  U, E, I, Q ):      ' ; printf '                           '
    fi
fi
printf '\n\n'
printf '                                                                                \n'
printf '                                                                                '
printf "\r\n\033[2A\033[49C"
printf "\033[3A"
if [[ ! $loc = "ru" ]]; then printf "\033[2C"; fi
if [[ ${ch} -le 10 ]]; then
printf "\033[?25h"
choice="±"
printf '\033[1B'
while [[ $choice = "±" ]]
do
IFS="±"; read -n 1 -t 1 choice ; unset IFS; sym=2
if [[ $choice = "" ]]; then printf "\033[?25l"'\033[1A'"\033[?25h"; fi
CHECK_HOTPLUG_DISKS
CHECK_HOTPLUG_PARTS
done
SET_INPUT
else
if [[ $CheckLoaders = 1 ]]; then printf '\033[1B' ; fi
READ_TWO_SYMBOLS; sym=2
fi
printf "\033[?25l\033[1D"
if [[ ! ${choice} =~ ^[0-9]+$ ]]; then
if [[ ! $order = 3 ]]; then
if [[ ! $choice =~ ^[0-9uUqQeEiIvV]$ ]]; then  unset choice; fi
if [[ ${choice} = [uU] ]]; then unset nlist; UNMOUNTS; choice="R"; order=4; fi
if [[ ${choice} = [qQ] ]]; then choice=$ch; fi
if [[ ${choice} = [eE] ]]; then GET_SYSTEM_EFI; let "choice=enum+1"; fi
if [[ ${choice} = [iI] ]]; then ADVANCED_MENUE; fi
if [[ ${choice} = [vV] ]]; then SHOW_VERSION; order=4; UPDATELIST; fi
else
if [[ ! $choice =~ ^[0-9qQcCoOsSiIvV]$ ]]; then unset choice; fi
if [[ ${choice} = [sS] ]]; then cd $(dirname $0); if [[ -f setup ]]; then ./setup -r; else bash ./setup.sh -r; fi;  REFRESH_SETUP; choice="0"; order=4; fi
if [[ ${choice} = [oO] ]]; then  SPIN_OC; choice="0"; order=4; fi
if [[ ${choice} = [cC] ]]; then  SPIN_FCLOVER; choice="0"; order=4; fi
if [[ ${choice} = [qQ] ]]; then choice=$ch; fi
if [[ ${choice} = [iI] ]]; then  order=4; UPDATELIST; fi
if [[ ${choice} = [vV] ]]; then SHOW_VERSION; order=4; UPDATELIST; fi
fi
else
! [[ ${choice} -ge 0 && ${choice} -le $ch  ]] && unset choice 
fi
done

chs=$choice
if [[ $chs = 0 ]]; then nogetlist=0; fi

}
# Конец определения GETKEYS #######################################



# Определение функции монтирования разделов EFI ##########################################
MOUNTS(){
#printf '\n'
let "num=chs-1"

pnum=${nlist[num]}
string=`echo ${dlist[$pnum]}`
strng0=${string}
mcheck=`df | grep ${string}`; if [[ ! $mcheck = "" ]]; then mcheck="Yes"; fi 

wasmounted=0
if [[ ! $mcheck = "Yes" ]]; then

    DO_MOUNT

    MOUNTED_CHECK


	order=0; UPDATELIST

else 
    wasmounted=1

fi
string=${strng0}
vname=`df | egrep ${string} | sed 's#\(^/\)\(.*\)\(/Volumes.*\)#\1\3#' | cut -c 2-`
if [[ $OpenFinder = 0 ]] ; then 
        if [[ $wasmounted = 1 ]]; then open "$vname"; fi
    else 
        open "$vname"
fi

nogetlist=1

}
# Конец определения MOUNTS #################################################################

# Начало основноо цикла программы ###########################################################
############################ MAIN MAIN MAIN ################################################
GET_USER_PASSWORD

chs=0

nogetlist=0

SET_INPUT
while [ $chs = 0 ]; do
if [[ ! $nogetlist = 1 ]]; then
        clear && printf '\e[3J'

	if [[ $loc = "ru" ]]; then
        printf '\n******    Программа монтирует EFI разделы в Mac OS (X.11 - X.14)    *******\n'
			else
        printf '\n******    This program mounts EFI partitions on Mac OS (X.11 - X.14)    *******\n'
	fi
fi
        unset nlist
        declare -a nlist
        GETARR


 if [[ ! $nogetlist = 1  ]]; then  GETLIST; fi

	GETKEYS	

# Если нажата клавиша выхода из программы
if  [[ $chs = $ch ]]; then
clear
	if [[ $loc = "ru" ]]; then
printf '\n\n  Выходим. Конец программы. \n\n\n\n''\e[3J'
			else
printf '\n\n  The end of the program. \n\n\n\n''\e[3J'
	fi

	rm -f ~/.MountEFItemp.txt

EXIT_PROGRAM
fi


# Монтировать раздел если он выбран (chs - номер в списке разделов)
if [[ ! ${chs} = 0 ]]; then MOUNTS;  chs=0; fi
	


done

# Конец основного цикла программы ####################################################################
########################################## END MAIN #################################################
exit

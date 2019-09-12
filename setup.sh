#!/bin/bash

################################################################################## MountEFI SETUP ##########################################################################################################
s_prog_vers="1.6"
s_edit_vers="024"

############################################################################################################################################################################################################
# MountEFI версия скрипта настроек 1.6. 024 master
# 001 - в выводе пункта меню 8 - добавлено слово MountEFI
# 002 - переименование пункта A в пункт L
# 003 - переименование пункта 9 в A
# 004 - добавление пункта 9 для функции автомонтирования при загрузке системы
# 005 - реализация управления из меню конфигом для функции 9 автомонтирования при загрузке системы
# 006 - проверка конфига и добавление пунктов для автозапуска при загрузке системы
# 007 - добавить запрос пароля в функции 9
# 008 - добавлены установка и запуск сервиса SETUP_SYS_AUTOMOUNT
# 009 - мелкие исправления форматирования
# 010 - перенос хранения пароля в связку ключей
# 011 - отображение пароля пользователя в списке звёздочками
# 012 - при вводе пароля показывать звёздочки
# 013 - правки для совместимости со старым конфигом
# 014 - правка функции заполнения sh для использования связки ключей
# 015 - исправление ошибок с путями при работе с облаком
# 016 - добавлена функция загрузки конфига из файла через GUI
# 017 - добавлена функция экспорта конфига через GUI
# 018 - различные исправления и доработки
# 019 - добавлена проверка сервиса авто-загрузки на соответствие настройкам 
# 020 - в сервис авто-монтирования функции 9 добавлены уведомления об ошибках
# 021 - обработка ситуации с разным максимальным количеством бэкапов в заменяемых конфигах
# 022 - функция запроса пароля через GUI с системными уведомлениями 
# 023 - добавлен запрос на ввод пароля в функции 8 если необходим
# 024 - добавление или редактирование псевдонимов через окно GUI
#############################################################################################################################################################################################################

# функция отладки ##################################################################################################

demo1="0"
deb=0

DEBUG(){
if [[ ! $deb = 0 ]]; then
printf '\n\n Останов '"$stop"'  :\n\n' >> ~/temp.txt 
printf '............................................................\n' >> ~/temp.txt
echo "Now = "$Now >> ~/temp.txt
echo "Maximum = "$Maximum >> ~/temp.txt
Config_Maximum=`echo "$MountEFIconf" | grep Backups -A 5 | grep -A 1 -e "Maximum</key>"  | grep integer | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
echo "Config_Maximum = "$Config_Maximum >> ~/temp.txt
#echo "folderpath = "$folderpath >> ~/temp.txt

#echo "filename = "$filename >> ~/temp.txt
#echo "extension = "$extension >> ~/temp.txt

#echo "filename_1 = ""${filename_1}" >> ~/temp.txt


printf '............................................................\n\n' >> ~/temp.txt
sleep 0.2
read -n 1 -s
fi
}
########################################################################################################################################

SHOW_VERSION(){
clear && printf "\e[3J" 
printf "\033[?25l"
var12=${lines}; while [[ ! $var12 = 0 ]]; do
printf '\e[40m %.0s\e[0m' {1..80}
let "var12--"; done
printf "\033[H"

printf "\033[10;21f"
printf '\e[40m\e[1;33m________________________________________\e[0m''\n\033[20C'
printf '\e[40m\e[1;33m[                                      ]\e[0m''\n\033[20C'
printf '\e[40m\e[1;33m[                                      ]\e[0m''\n\033[20C'
printf '\e[40m\e[1;33m[                                      ]\e[0m''\n\033[20C'
printf '\e[40m\e[1;33m[                                      ]\e[0m''\n\033[20C'
printf '\e[40m\e[1;33m[______________________________________]\e[0m''\n'
printf '\r\033[3A\033[28C' ; printf '\e[40m\e[1;35m  SETUP v. \e[1;33m'$s_prog_vers'.\e[1;32m '$s_edit_vers' \e[1;35m®\e[0m''\n'   
read -n 1 
clear && printf "\e[3J"
} 


par="$1"

MyTTY1=`tty | tr -d " dev/\n"`
term=`ps`;  MyTTYc=`echo $term | grep -Eo $MyTTY1 | wc -l | tr - " \t\n"`

# Возвращает в переменной TTYcount 0 если наш терминал один
CHECK_TTY_C(){
term=`ps`
AllTTYc=`echo $term | grep -Eo ttys[0-9][0-9][0-9] | wc -l | tr - " \t\n"`
let "TTYc=AllTTYc-MyTTYc"
}

# Выход из программы с проверкой - выгружать терминал из трея или нет
EXIT_PROG(){
cat  ~/.bash_history | sed -n '/MountEFI/!p' >> ~/new_hist.txt; rm ~/.bash_history; mv ~/new_hist.txt ~/.bash_history
CHECK_TTY_C	
if [[ ${TTYc} = 0  ]]; then   osascript -e 'quit app "terminal.app"' & exit
	else
     osascript -e 'tell application "Terminal" to close first window' & exit
fi
}

##########################################################################################################################################

cd $(dirname $0)

if [[ ! -d ~/Library/LaunchAgents ]]; then mkdir ~/Library/LaunchAgents; fi

SET_LOCALE(){

if [[ $cache = 1 ]] ; then
        locale=`echo "$MountEFIconf" | grep -A 1 "Locale" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
        if [[ ! $locale = "ru" ]] && [[ ! $locale = "en" ]]; then loc=`locale | grep LANG | sed -e 's/.*LANG="\(.*\)_.*/\1/'`
            else
                loc=`echo ${locale}`
        fi
    else   
        loc=`locale | grep LANG | sed -e 's/.*LANG="\(.*\)_.*/\1/'`
fi
            if [[ $loc = "ru" ]]; then
if [[ $locale = "ru" ]]; then loc_set="русский"; loc_corr=17; fi
if [[ $locale = "en" ]]; then loc_set="английский"; loc_corr=14; fi
if [[ $locale = "auto" ]]; then loc_set="автовыбор"; loc_corr=15; fi
            else
if [[ $locale = "ru" ]]; then loc_set="russian"; loc_corr=23; fi
if [[ $locale = "en" ]]; then loc_set="english"; loc_corr=23; fi
if [[ $locale = "auto" ]]; then loc_set="auto"; loc_corr=26; fi
            fi

}

GET_MENUE(){
menue=0
HasMenue=`echo "$MountEFIconf" | grep -A 1 "Menue" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
if [[ $HasMenue = "always" ]]
    then 
    menue=1
        if [[ $loc = "ru" ]]; then
    menue_set="всегда"; menue_corr=28
        else
    menue_set="always"; menue_corr=30
        fi
    else
            if [[ $loc = "ru" ]]; then
        menue_set="автовыбор"; menue_corr=25 
            else
        menue_set="auto"; menue_corr=32
            fi
fi

}

GET_OPENFINDER(){
OpenFinder=1
strng=`echo "$MountEFIconf" | grep -A 1 -e "OpenFinder</key>" | grep false | tr -d "<>/"'\n\t'`
if [[ $strng = "false" ]]; then OpenFinder=0
            if [[ $loc = "ru" ]]; then
        OpenFinder_set="Нет"; of_corr=18
            else
        OpenFinder_set="No"; of_corr=19
            fi
    else
            if [[ $loc = "ru" ]]; then
        OpenFinder_set="Да"; of_corr=19
            else
        OpenFinder_set="Yes"; of_corr=18
            fi
fi
}

GET_SHOWKEYS(){
ShowKeys=1
strng=`echo "$MountEFIconf" | grep -A 1 -e "ShowKeys</key>" | grep false | tr -d "<>/"'\n\t'`
if [[ $strng = "false" ]]; then ShowKeys=0
            if [[ $loc = "ru" ]]; then
        ShowKeys_set="Нет"; sk_corr=14
            else
        ShowKeys_set="No"; sk_corr=22
            fi
    else
            if [[ $loc = "ru" ]]; then
        ShowKeys_set="Да"; sk_corr=15
            else
        ShowKeys_set="Yes"; sk_corr=21
            fi
fi
}



GET_BACKUPS_FROM_ICLOUD(){
hwuuid=$(ioreg -rd1 -c IOPlatformExpertDevice | awk '/IOPlatformUUID/' | cut -f2 -d"=" | tr -d '" \n')
if [[ -d ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs ]]; then
            if [[ $get_shared = 1 ]]; then
                if [[ -f ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIbackups/Shared/.MountEFIconfBackups.zip ]]; then
                    cp ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIbackups/Shared/.MountEFIconfBackups.zip  ${HOME}
                        get_shared=0
                fi
            else
                    
       if [[ -f ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIbackups/$hwuuid/.MountEFIconfBackups.zip ]]; then
            cp ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIbackups/$hwuuid/.MountEFIconfBackups.zip  ${HOME}
       else
                if [[ -f ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIbackups/Shared/.MountEFIconfBackups.zip ]]; then
                    cp ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIbackups/Shared/.MountEFIconfBackups.zip  ${HOME}
                fi
            fi
      
      fi 
fi  

}



GET_PRESETS_COUNTS(){
pcount=0
pstring=`echo "$MountEFIconf" | grep  -e "<key>BackgroundColor</key>" | sed -e 's/.*>\(.*\)<.*/\1/' | tr ' \n' ';'`
IFS=';'; slist=($pstring); unset IFS;
pcount=${#slist[@]}
unset slist
unset pstring
}

GET_PRESETS_NAMES(){
pstring=`echo "$MountEFIconf" | grep  -B 2 -e "<key>BackgroundColor</key>" | grep key | sed -e 's/.*>\(.*\)<.*/\1/' | sed 's/BackgroundColor/;/g' | tr -d '\n'`
IFS=';'; plist=($pstring); unset IFS
unset pstring
}

GET_THEME(){
if [[ $cache = 1 ]]; then
HasTheme=`echo "$MountEFIconf" | grep -E "<key>Theme</key>" | grep -Eo Theme | tr -d '\n'`
    if [[ $HasTheme = "Theme" ]]; then
theme=`echo "$MountEFIconf" |  grep -A 1 -e  "<key>Theme</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
    fi
fi
if [[ $theme = "system" ]]; then 
                if [[ $loc = "ru" ]]; then
            theme_set="системная"; theme_corr=25
                else
            theme_set="system"; theme_corr=30
                fi
    else
                if [[ $loc = "ru" ]]; then
            theme_set="встроенная"; theme_corr=24
                else
            theme_set="built-in"; theme_corr=28
                fi
fi
        
itheme_set=`echo "$MountEFIconf" | grep -A 1 -e "<key>CurrentPreset</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
        
GET_PRESETS_COUNTS

tlenth=`echo ${#itheme_set}`
if [[ $loc = "ru" ]]; then
let "btheme_corr=29-tlenth"
btspc_corr=8
else
let "btheme_corr=23-tlenth"
fi

}


SET_THEMES(){

HasTheme=`echo "$MountEFIconf" | grep -Eo "Theme"  | tr -d '\n'`
if [[ ! $HasTheme = "Theme" ]]; then
plutil -replace Theme -string system ${HOME}/.MountEFIconf.plist; UPDATE_CACHE
else
 theme=`echo "$MountEFIconf" | grep -A 1 "Theme" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
   if [[ $theme = "system" ]]; then 
                GET_PRESETS_COUNTS
                CUSTOM_SET
                plutil -replace Theme -string built-in ${HOME}/.MountEFIconf.plist; UPDATE_CACHE
                GET_PRESETS_NAMES
                current=`echo "$MountEFIconf" | grep -A 1 -e "<key>CurrentPreset</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
 
                var3=$pcount
                num=0
                while [[ ! $var3 = 0 ]]; do 
                    if [[ "$current" = "${plist[$num]}" ]]; then 
                            let "var3=0"
                               else
                            let "num++" 
                            let "var3--"
                     fi

                done  
                var2=1 
                let "pik=pcount-1"            
                while [[  $var2 = 1  ]]; do
                current=`echo "$MountEFIconf" | grep -A 1 -e "<key>CurrentPreset</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
                    printf "\r\033[1A"
                    printf '                                                          \n'
                    if [[ $loc = "ru" ]]; then
                printf 'Встроенных тем: '$pcount'                                           \n'
                printf 'Текущий выбор - тема: '"${plist[$num]}"'                             \n'
                printf 'N - выбрать следующую тему и S для применения :  '
                        else
                printf 'There is '$pcount' themes.                                             \n'
                printf ' Current preset choose: '"${plist[$num]}"'                            \n'
                printf 'N for next theme and S to confirm :  '
                    fi
                demo="~"; unset demo
                if [[ ! $pcount = 1 ]]; then 
                read -sn1 demo
                if [[ ! $demo =~ ^[sSnN]$ ]]; then unset demo; fi
                else
                    printf '\r'
                    if [[ $loc = "ru" ]]; then
                printf 'Нажмите любую клавишу для продолжения ...             '
                        else
                printf 'Press any key to continue ....                        '
                    fi
                    read -sn1 
                    demo="s"
                fi
                if [[ $demo = [nN] ]]; then 
                    if [[ $num = $pik ]]; then let "num=0"; else let "num++"; fi
                    plutil -replace CurrentPreset -string "${plist[$num]}" ${HOME}/.MountEFIconf.plist ; UPDATE_CACHE
                    unset demo
                    CUSTOM_SET
                fi
                   printf "\r\033[2A"
               
                
if [[ $demo = [sS] ]]; then let "var2=0"; fi

                
                done
 
        else
            plutil -replace Theme -string system ${HOME}/.MountEFIconf.plist ; UPDATE_CACHE
                printf '\n\n'
                    if [[ $loc = "ru" ]]; then
                echo "включена системная тема. выполните перезапуск программы" 
                echo "нажмите любую клавишу для возврата в меню..."
                        else
                echo "set up system theme. restart required. "
                echo "press any key return to menu ...."
                    fi
                read -n 1 demo 
    fi
fi            

}

GET_CURRENT_SET(){

current=`echo "$MountEFIconf" | grep -A 1 -e "<key>CurrentPreset</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
current_background=`echo "$MountEFIconf" | grep -A 10 -E "<key>$current</key>" | grep -A 1 "BackgroundColor" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
current_foreground=`echo "$MountEFIconf" | grep -A 10 -E "<key>$current</key>" | grep -A 1 "TextColor" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
current_fontname=`echo "$MountEFIconf" | grep -A 10 -E "<key>$current</key>" | grep -A 1 "FontName" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
current_fontsize=`echo "$MountEFIconf" | grep -A 10 -E "<key>$current</key>" | grep -A 1 "FontSize" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`

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

GET_BACKUPS(){
Maximum=`echo "$MountEFIconf" | grep Backups -A 5 | grep -A 1 -e "Maximum</key>"  | grep integer | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
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
            echo '  <integer>5</integer>' >> ${HOME}/.MountEFIconf.plist
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
            echo '          <string>{1028, 12850, 10240}</string>' >> ${HOME}/.MountEFIconf.plist
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
            echo '	<key>SysLoadAM</key>' >> ${HOME}/.MountEFIconf.plist
	        echo '	<dict>' >> ${HOME}/.MountEFIconf.plist
	        echo '  <key>Enabled</key>' >> ${HOME}/.MountEFIconf.plist
	        echo '  <false/>' >> ${HOME}/.MountEFIconf.plist
	        echo '  <key>Open</key>' >> ${HOME}/.MountEFIconf.plist
	        echo '  <false/>' >> ${HOME}/.MountEFIconf.plist
	        echo '  <key>PartUUIDs</key>' >> ${HOME}/.MountEFIconf.plist
	        echo '  <string> </string>' >> ${HOME}/.MountEFIconf.plist
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
CHECK_CONFIG(){

login=`echo "$MountEFIconf" | grep -Eo "LoginPassword"  | tr -d '\n'`
if [[ $login = "LoginPassword" ]]; then
        mypassword=`echo "$MountEFIconf" | grep -A 1 "LoginPassword" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
        if [[ ! $mypassword = "" ]]; then
            if ! (security find-generic-password -a ${USER} -s efimounter -w) >/dev/null 2>&1; then
                security add-generic-password -a ${USER} -s efimounter -w ${mypassword} >/dev/null 2>&1
            fi
            plutil -remove LoginPassword ${HOME}/.MountEFIconf.plist; UPDATE_CACHE
        fi
fi

deleted=0
if [[ $cache = 1 ]]; then
strng=`echo "$MountEFIconf" | grep  "<key>CurrentPreset</key>" | grep key | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\t\n'`
      if [[ ! $strng = "CurrentPreset" ]]; then
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

strng=`echo "$MountEFIconf" | grep -e "<key>SysLoadAM</key>" | grep key | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\t\n'`
if [[ ! $strng = "SysLoadAM" ]]; then 
			plutil -insert SysLoadAM -xml  '<dict/>'   ${HOME}/.MountEFIconf.plist
			plutil -insert SysLoadAM.Enabled -bool NO ${HOME}/.MountEFIconf.plist
			plutil -insert SysLoadAM.Open -bool NO ${HOME}/.MountEFIconf.plist
            plutil -insert SysLoadAM.PartUUIDs -string " " ${HOME}/.MountEFIconf.plist
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

}

CHECK_CONFIG

################################## функция автодетекта подключения ##############################################################################################
CHECK_HOTPLUG(){
hotplug=0
ustring=`ioreg -c IOMedia -r  | grep "<class IOMedia," | cut -f1 -d"<" | sed 's/+-o/;/'` ; IFS=";"; uuid_list=($ustring); unset IFS; uuid_count=${#uuid_list[@]};
        if [[ ! $old_uuid_count = $uuid_count ]]; then inputs=0; hotplug=1; old_uuid_count=$uuid_count
            
        fi
}

CHECK_HOTPLUG_PARTS(){
#ustring=`ioreg -c IOMedia -r  | grep "<class IOMedia," | cut -f1 -d"<" | sed 's/+-o/;/'` ; IFS=";"; uuid_list=($ustring); unset IFS; uuid_count=${#uuid_list[@]};
pstring=`df | cut -f1 -d " " | grep "/dev"` ; puid_list=($pstring);  puid_count=${#puid_list[@]}
        if [[ ! $old_puid_count = $puid_count ]]; then  UPDATE_SCREEN_BUFFER; UPDATE_PARTS_SCREEN; old_puid_count=$puid_count
            
        fi
}

##################### обновление данных буфера экрана при детекте хотплага партиции ###########################
UPDATE_SCREEN_BUFFER(){

var0=$pos; num=0; ch1=0
unset string
while [ $var0 != 0 ] 
do 
pnum=${nslist[num]}
string=`echo ${slist[$pnum]}`
	let "ch1++"
mcheck=`df | grep ${string}`; if [[ ! $mcheck = "" ]]; then mcheck="Yes"; fi
if [[ $mcheck = "Yes" ]]; then
            check=$( echo "${screen_buffer1}" | grep "$ch1)   +" )
            if [[ "${check}" = "" ]]; then
        screen_buffer1=$( echo  "$screen_buffer1" | sed "s/$ch1) ...  /$ch1)   +  /" )
     fi

    else
            check=$( echo "${screen_buffer1}" | grep "$ch1) ..." )
           if [[ 

! "${check}" = "" ]]; then 
        screen_buffer1=$( echo  "$screen_buffer1" | sed "s/$ch1)   +  /$ch1) ...  /" )
    fi
fi
let "num++"
let "var0--"
done
}
############################ конец определения функции UPDATE PARTS ############################################

###################################### обновление на экране списка подключенных ###########################################
UPDATE_PARTS_SCREEN(){
printf "\033[H"
printf "\r\033[5f"
echo  "$screen_buffer1"
printf "\033[10B"

    if [[ $loc = "ru" ]]; then
    printf "\r\033[55C"
        else
    printf "\r\033[51C"
    fi                      
}
################################### конец функции обновления списка подключенных  на экране ##################################
###################################################################################################################################################################


GET_UUID_S(){
ioreg_iomedia=`ioreg -c IOMedia -r | tr -d '"|+{}\t'`
uuids_iomedia=`echo "$ioreg_iomedia" | sed '/Statistics =/d'  | egrep -A12 -B12 "UUID ="`

}


GET_EFI_S(){

ioreg_iomedia=`ioreg -c IOMedia -r | tr -d '"|+{}\t'`

strng=`diskutil list | grep EFI | grep -oE '[^ ]+$' | xargs | tr ' ' ';'`
disk_images=`echo "$ioreg_iomedia" | egrep -A 22 "Apple UDIF" | grep "BSD Name" | cut -f2 -d "="  | tr -d " " | tr '\n' ';'`
syspart=`df / | grep /dev | cut -f1 -d " " | sed s'/dev//' | tr -d '/ \n'`

IFS=';' 
slist=($strng)
ilist=($disk_images)
unset IFS;
pos=${#slist[@]}
posi=${#ilist[@]}

drives_iomedia=`echo "$ioreg_iomedia" |  egrep -A 22 "<class IOMedia,"`
sizes_iomedia=`echo "$ioreg_iomedia" |  sed -e s'/Logical Block Size =//' | sed -e s'/Physical Block Size =//' | sed -e s'/Preferred Block Size =//' | sed -e s'/EncryptionBlockSize =//'`

CHECK_HOTPLUG

pstring=`df | cut -f1 -d " " | grep "/dev"` ; puid_list=($pstring);  puid_count=${#puid_list[@]}
        if [[ ! $old_puid_count = $puid_count ]]; then  old_puid_count=$puid_count
            
        fi

}

GET_EFI_S

if [[ $par = "-r" ]]; then
ShowKeys=1
strng=`echo "$MountEFIconf" | grep -A 1 -e "ShowKeys</key>" | grep false | tr -d "<>/"'\n\t'`
if [[ $strng = "false" ]]; then ShowKeys=0; fi
if [[ $ShowKeys = 1 ]]; then lines=25; else lines=23; fi
else
lines=23 
fi
let "lines=lines+pos"
printf '\e[8;'${lines}';80t' && printf '\e[3J' && printf "\033[0;0H"
clear


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

ENTER_PASSWORD(){

unset PASSWORD
unset CHARCOUNT

if [[ $loc = "ru" ]]; then
echo -n "  Введите пароль: "
else
echo -n "  Enter password: "
fi

stty -echo
sleep 0.8

unset CHAR

CHARCOUNT=0
while IFS= read -p "$PROMPT" -r -s -n 1 CHAR
do
    # Enter - accept password
    if [[ $CHAR == $'\0' ]] ; then
        break
    fi
    # Backspace
    if [[ $CHAR == $'\177' ]] ; then
        if [ $CHARCOUNT -gt 0 ] ; then
            CHARCOUNT=$((CHARCOUNT-1))
            PROMPT=$'\b \b'
            PASSWORD="${PASSWORD%?}"
        else
            PROMPT=''
        fi
    else
        CHARCOUNT=$((CHARCOUNT+1))
        PROMPT='*'
        PASSWORD+="$CHAR"
    fi
done

stty echo

}

SET_TITLE(){
echo '#!/bin/bash'  >> ${HOME}/.MountEFInoty.sh
echo '' >> ${HOME}/.MountEFInoty.sh
echo 'TITLE="MountEFI"' >> ${HOME}/.MountEFInoty.sh
echo 'SOUND="Submarine"' >> ${HOME}/.MountEFInoty.sh
}

DISPLAY_NOTIFICATION(){
echo 'COMMAND="display notification \"${MESSAGE}\" with title \"${TITLE}\" subtitle \"${SUBTITLE}\" sound name \"${SOUND}\""; osascript -e "${COMMAND}"' >> ${HOME}/.MountEFInoty.sh
echo ' exit' >> ${HOME}/.MountEFInoty.sh
chmod u+x ${HOME}/.MountEFInoty.sh
sh ${HOME}/.MountEFInoty.sh
rm ${HOME}/.MountEFInoty.sh
}

ENTER_PASSWORD(){

TRY=3
        while [[ ! $TRY = 0 ]]; do
        if [[ $loc = "ru" ]]; then
        if PASSWORD=$(osascript -e 'Tell application "System Events" to display dialog "       Введите пароль: " with hidden answer  default answer ""' -e 'text returned of result'); then cansel=0; else cansel=1; fi 2>/dev/null
        else
        if PASSWORD=$(osascript -e 'Tell application "System Events" to display dialog "       Enter password: " with hidden answer  default answer ""' -e 'text returned of result'); then cansel=0; else cansel=1; fi 2>/dev/null
        fi      
                if [[ $cansel = 1 ]]; then break; fi  
                mypassword=$PASSWORD
                if [[ $mypassword = "" ]]; then mypassword="?"; fi

                if echo $mypassword | sudo -Sk printf '' 2>/dev/null; then
                    security add-generic-password -a ${USER} -s efimounter -w ${mypassword} >/dev/null 2>&1
                        SET_TITLE
                        if [[ $loc = "ru" ]]; then
                        echo 'SUBTITLE="ПАРОЛЬ СОХРАНЁН В СВЯЗКЕ КЛЮЧЕЙ !"; MESSAGE=""' >> ${HOME}/.MountEFInoty.sh
                        else
                        echo 'SUBTITLE="PASSWORD KEEPED IN KEYCHAIN !"; MESSAGE=""' >> ${HOME}/.MountEFInoty.sh
                        fi
                        DISPLAY_NOTIFICATION
                        break
                else
                        let "TRY--"
                        if [[ ! $TRY = 0 ]]; then 
                        SET_TITLE
                            if [[ $loc = "ru" ]]; then
                        if [[ $TRY = 2 ]]; then ATTEMPT="ПОПЫТКИ"; LAST="ОСТАЛОСЬ"; fi
                        if [[ $TRY = 1 ]]; then ATTEMPT="ПОПЫТКА"; LAST="ОСТАЛАСЬ"; fi
                        echo 'SUBTITLE="НЕВЕРНЫЙ ПАРОЛЬ. '$LAST' '$TRY' '$ATTEMPT' !"; MESSAGE=""' >> ${HOME}/.MountEFInoty.sh
                            else
                        if [[ $TRY = 2 ]]; then ATTEMPT="ATTEMPTS"; fi
                        if [[ $TRY = 1 ]]; then ATTEMPT="ATTEMPT"; fi
                        echo 'SUBTITLE="INCORRECT PASSWORD. LEFT '$TRY' '$ATTEMPT' !"; MESSAGE=""' >> ${HOME}/.MountEFInoty.sh
                            fi
                DISPLAY_NOTIFICATION
                fi
                fi
            done
            mypassword="0"
if (security find-generic-password -a ${USER} -s efimounter -w) >/dev/null 2>&1; then
                mypassword=$(security find-generic-password -a ${USER} -s efimounter -w); 
fi
            if [[ "$mypassword" = "0" ]]; then
                SET_TITLE
                    if [[ $loc = "ru" ]]; then
                echo 'SUBTITLE="ПАРОЛЬ НЕ ПОЛУЧЕН !"; MESSAGE=""' >> ${HOME}/.MountEFInoty.sh
                    else
                echo 'SUBTITLE="PASSWORD NOT KEEPED IN KEYCHAIN !"; MESSAGE=""' >> ${HOME}/.MountEFInoty.sh
                    fi
                DISPLAY_NOTIFICATION
                
        fi

}

# Установка/удаление пароля для sudo через связку ключей
SET_USER_PASSWORD(){
if (security find-generic-password -a ${USER} -s efimounter -w) >/dev/null 2>&1; then 
                printf '\r'; printf "%"80"s"
                printf '\r'
                if [[ $loc = "ru" ]]; then
                echo "  удалить сохранённый пароль из программы?"
                        else
                echo "  delete saved password from this programm?"
                    fi
                read -p "  (y/N) " -n 1 -r -s
                if [[ $REPLY =~ ^[yY]$ ]]; then
                security delete-generic-password -a ${USER} -s efimounter >/dev/null 2>&1
                if [[ $loc = "ru" ]]; then
                echo "  пароль удалён. "
                        else
                echo "  password removed. "
                    fi
                read -n 1 -s -t 1
                fi
        else
                
            ENTER_PASSWORD

        
    fi

osascript -e 'tell application "Terminal" to activate'

}

#Получение пароля для sudo из связки ключей
GET_USER_PASSWORD(){
mypassword="0"

if (security find-generic-password -a ${USER} -s efimounter -w) >/dev/null 2>&1; then
                mypassword=$(security find-generic-password -a ${USER} -s efimounter -w)
                passl=`echo ${#mypassword}`
                mypassword_set=$(echo $mypassword | tr -c '\n' "*")
                if [[ $loc = "ru" ]]; then
                let "pass_corr=30-passl"
                else
                let "pass_corr=33-passl"
                fi

else
                    if [[ $loc = "ru" ]]; then
               mypassword_set="нет пароля"; pass_corr=20
                    else
               mypassword_set="not saved"; pass_corr=24
                    fi
    
       
fi
}

CHECK_USER_PASSWORD(){
mypassword=""

if (security find-generic-password -a ${USER} -s efimounter -w) >/dev/null 2>&1; then
mypassword=$(security find-generic-password -a ${USER} -s efimounter -w)
fi

}

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

if [[ ! $keyboard = "0" ]]; then ./xkbswitch -se $keyboard; change_layout=1; fi
   else
        change_layout=0

	 fi
fi
}

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

REM_SYS_ABSENT(){
strng1=`echo "$MountEFIconf" | grep SysLoadAM -A 7 | grep -A 1 -e "PartUUIDs</key>"  | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
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
						plutil -replace SysLoadAM.PartUUIDs -string "$strng2" ${HOME}/.MountEFIconf.plist
						strng1=$strng2
                        cache=0
						fi
					let "posb++"
					let "var8--"
					done
alist=($strng1); apos=${#alist[@]}
fi
if [[ $apos = 0 ]]; then plutil -replace SysLoadAM.Enabled -bool NO ${HOME}/.MountEFIconf.plist; sys_am_enabled=0; cache=0; fi
}

GET_AUTOMOUNT(){
autom_enabled=0
strng=`echo "$MountEFIconf" | grep AutoMount -A 3 | grep -A 1 -e "Enabled</key>" | grep true | tr -d "<>/"'\n\t'`
if [[ $strng = "true" ]]; then autom_enabled=1
            if [[ $loc = "ru" ]]; then
        am_set="Да"; am_corr=20
            else
        am_set="Yes"; am_corr=14
            fi
    else
            if [[ $loc = "ru" ]]; then
        am_set="Нет"; am_corr=19
            else
        am_set="No"; am_corr=15
            fi
fi
}

GETAUTO_OPEN(){
autom_open=0
strng=`echo "$MountEFIconf" | grep AutoMount -A 7 | grep -A 1 -e "Open</key>" | grep true | tr -d "<>/"'\n\t'`
if [[ $strng = "true" ]]; then autom_open=1
            if [[ $loc = "ru" ]]; then
        amo_set="Да"; amo_corr=8
            else
        amo_set="Yes"; amo_corr=10
            fi
    else
            if [[ $loc = "ru" ]]; then
        amo_set="Нет"; amo_corr=7
            else
        amo_set="No"; amo_corr=11
            fi
fi
}

GETAUTO_EXIT(){
autom_exit=0
strng=`echo "$MountEFIconf" | grep AutoMount -A 5 | grep -A 1 -e "ExitAfterMount</key>" | grep true | tr -d "<>/"'\n\t'`
if [[ $strng = "true" ]]; then autom_exit=1
            if [[ $loc = "ru" ]]; then
        ame_set="Да"; ame_corr=9
            else
        ame_set="Yes"; ame_corr=12
            fi
    else
            if [[ $loc = "ru" ]]; then
        ame_set="Нет"; ame_corr=8
            else
        ame_set="No"; ame_corr=13
            fi
fi
}

GETAUTO_TIMEOUT(){
auto_timeout=0
strng=`echo "$MountEFIconf" | grep AutoMount -A 11 | grep -A 1 -e "Timeout2Exit</key>"  | grep integer | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
if [[ ! $strng = "" ]]; then auto_timeout=$strng; fi
ncorr=${#auto_timeout}
        if [[ $loc = "ru" ]]; then
         let "tmo_corr=5-ncorr" 
            else
         let "tmo_corr=11-ncorr"
            fi
}

GET_AUTOMOUNTED(){
apos=0
strng1=`echo "$MountEFIconf" | grep AutoMount -A 9 | grep -A 1 -e "PartUUIDs</key>"  | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
alist=($strng1); apos=${#alist[@]}
}


GET_SYS_AUTOMOUNT(){
sys_autom_enabled=0
strng=`echo "$MountEFIconf" | grep SysLoadAM -A 3 | grep -A 1 -e "Enabled</key>" | grep true | tr -d "<>/"'\n\t'`
if [[ $strng = "true" ]]; then sys_autom_enabled=1
            if [[ $loc = "ru" ]]; then
        sys_am_set="Да"; sys_am_corr=12
            else
        sys_am_set="Yes"; sys_am_corr=9
            fi
    else
            if [[ $loc = "ru" ]]; then
        sys_am_set="Нет"; sys_am_corr=11
            else
        sys_am_set="No"; sys_am_corr=10
            fi
fi
}

CHECK_SYS_AUTOMOUNT_SERVICE(){

if [[ $(launchctl list | grep "MountEFIa.job" | cut -f3 | grep -x "MountEFIa.job") ]]; then  sam_serv="работает"
        else
if [[ ! -f ~/Library/LaunchAgents/MountEFIa.plist ]]; then sam_serv="не установлен"
            else
                 sam_serv="остановлен"
        fi
fi
GET_SYS_AUTOMOUNT
if [[ "$sam_serv" = "работает" ]] && [[ $sys_autom_enabled = 0 ]]; then REMOVE_SYS_AUTOMOUNT_SERVICE; fi
if [[ "$sam_serv" = "не установлен" ]] && [[ $sys_autom_enabled = 1 ]]; then display=0; SETUP_SYS_AUTOMOUNT; fi
}

GET_SYS_AUTO_OPEN(){
sys_autom_open=0
strng=`echo "$MountEFIconf" | grep SysLoadAM -A 5 | grep -A 1 -e "Open</key>" | grep true | tr -d "<>/"'\n\t'`
if [[ $strng = "true" ]]; then sys_autom_open=1
            if [[ $loc = "ru" ]]; then
        sys_amo_set="Да"; sys_amo_corr=8
            else
        sys_amo_set="Yes"; sys_amo_corr=10
            fi
    else
            if [[ $loc = "ru" ]]; then
        sys_amo_set="Нет"; sys_amo_corr=7
            else
        sys_amo_set="No"; sys_amo_corr=11
            fi
fi
}

GET_SYS_AUTOMOUNTED(){
apos=0
strng1=`echo "$MountEFIconf" | grep SysLoadAM -A 7 | grep -A 1 -e "PartUUIDs</key>"  | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
alist=($strng1); apos=${#alist[@]}
}

###################################################### SHOW AUTOEFI ###########################################################
SHOW_AUTOEFI(){


printf '\e[8;'${lines}';80t' && printf '\e[3J' && printf "\033[0;0H" 
 if [[ $loc = "ru" ]]; then
  printf '\n      Выберите раздел и опции автомонтирования:                                '
			else
        printf '\n          Select a partition and automount options:                            '
	                 fi
var0=$pos; num1=0 ; ch=0; unset screen_buffer3

macos=`sw_vers -productVersion`
macos=`echo ${macos//[^0-9]/}`
macos=${macos:0:4}
if [[ "$macos" = "1014" ]] || [[ "$macos" = "1013" ]] || [[ "$macos" = "1012" ]] || [[ "$macos" = "1015" ]]; then
        vmacos="Disk Size:"
    else
        vmacos="Total Size:"
fi

if [[ $loc = "ru" ]]; then
    printf '\n\n\n      0)  поиск разделов .....    '
		else
	printf '\n\n\n      0)  updating partitions list .....      '
        fi

spin='-\|/'
i=0

GET_AUTOMOUNTED

while [ $var0 != 0 ] 
do 
	let "ch++"

    let "i++"
	i=$(( (i+1) %4 ))
	printf "\b$1${spin:$i:1}"
	
    pnum=${nslist[num1]}
	strng=`echo ${slist[$pnum]}`

    
	 dstrng=`echo $strng | rev | cut -f2-3 -d"s" | rev`

		dlnth=`echo ${#dstrng}`
		let "corr=9-dlnth"

        let "i++"
	    i=$(( (i+1) %4 ))
	    printf "\b$1${spin:$i:1}"

         
         dsze=`echo "$sizes_iomedia" | grep -A10 -B10 ${strng} | grep -m 1 -w "Size =" | cut -f2 -d "=" | tr -d "\n \t"`
          if [[  $dsze -le 999999999 ]]; then dsze=$(echo "scale=1; $dsze/1000000" | bc)" Mb"
        else
            if [[  $dsze -le 999999999999 ]]; then dsze=$(echo "scale=1; $dsze/1000000000" | bc)" Gb"
                    else
                         dsze=$(echo "scale=1; $dsze/1000000000000" | bc)" Gb"
            fi
        fi

    		scorr=`echo ${#dsze}`
    		let "scorr=scorr-5"
    		let "scorr=6-scorr"

             let "i++"
	         i=$(( (i+1) %4 ))
	         printf "\b$1${spin:$i:1}"

			automounted=0
            GET_UUID_S
 
    uuid=`echo "$uuids_iomedia" | grep -A12 -B12 $strng | grep -m 1 UUID | cut -f2 -d "=" | tr -d " \n"`
        if [[ $uuid = "" ]]; then unuv=1; else unuv=0; fi
	if [[ ! $apos = 0 ]]; then
	 let var4=$apos
	poi=0
            while [ $var4 != 0 ]
		do
		 if [[ ${alist[$poi]} = $uuid ]]; then automounted=1; var4=1; fi
	let "var4--"
            let "poi++"
	done
	fi

            drive=`echo "$drives_iomedia" | grep -B 10 ${dstrng} | grep -m 1 -w "IOMedia"  | cut -f1 -d "<" | sed -e s'/-o //'  | sed -e s'/Media//' | sed 's/ *$//' | tr -d "\n"`
             if [[ ${#drive} -gt 30 ]]; then drive=$( echo "$drive" | cut -f1-2 -d " " ); fi

            string1=$strng
            GET_RENAMEHD
            strng=$string1
            if [[ ! ${adrive} = "±" ]]; then drive="${adrive}"; fi
            dcorr=${#drive}
		    if [[ ${dcorr} -gt 30 ]]; then dcorr=0; drv="${drive:0:30}"; else let "dcorr=30-dcorr"; fi
            
            if [[ $ch -gt 9 ]]; then ncorr=1; else ncorr=2; fi

     if [[ $unuv = 1 ]]; then
            screen_buffer3+=$( printf '\n    '"%"$ncorr"s"$ch')   x    '"$drive""%"$dcorr"s"'    '${strng}"%"$corr"s""%"$scorr"s"' '"$dsze"'     ' )  
                else
	if [[ $automounted = 0 ]]; then
			screen_buffer3+=$( printf '\n    '"%"$ncorr"s"$ch') ....   '"$drive""%"$dcorr"s"'    '${strng}"%"$corr"s""%"$scorr"s"' '"$dsze"'     ' ) 
		else
			screen_buffer3+=$( printf '\n    '"%"$ncorr"s"$ch') auto   '"$drive""%"$dcorr"s"'    '${strng}"%"$corr"s""%"$scorr"s"' '"$dsze"'     ' )
		fi
    fi
            
            let "i++"
	         i=$(( (i+1) %4 ))
	         printf "\b$1${spin:$i:1}"    

	let "num1++"
	let "var0--"
done 


printf "\r\033[4A"

}
###################################################################################################################################################################

###################################################### SHOW SYSTEM AUTOEFI ###########################################################
SHOW_SYS_AUTOEFI(){


printf '\e[8;'${lines}';80t' && printf '\e[3J' && printf "\033[0;0H" 
 if [[ $loc = "ru" ]]; then
  printf '\n   Выберите раздел и опции монтирования EFI при входе в систему:                '
			else
        printf '\n Select EFI partitions and automount options:                                 '
	                 fi
var0=$pos; num1=0 ; ch=0; unset screen_buffer3

macos=`sw_vers -productVersion`
macos=`echo ${macos//[^0-9]/}`
macos=${macos:0:4}
if [[ "$macos" = "1014" ]] || [[ "$macos" = "1013" ]] || [[ "$macos" = "1012" ]] || [[ "$macos" = "1015" ]]; then
        vmacos="Disk Size:"
    else
        vmacos="Total Size:"
fi

if [[ $loc = "ru" ]]; then
    printf '\n\n\n      0)  поиск разделов .....    '
		else
	printf '\n\n\n      0)  updating partitions list .....      '
        fi

spin='-\|/'
i=0

GET_SYS_AUTOMOUNTED

while [ $var0 != 0 ] 
do 
	let "ch++"

    let "i++"
	i=$(( (i+1) %4 ))
	printf "\b$1${spin:$i:1}"
	
    pnum=${nslist[num1]}
	strng=`echo ${slist[$pnum]}`

    
	 dstrng=`echo $strng | rev | cut -f2-3 -d"s" | rev`

		dlnth=`echo ${#dstrng}`
		let "corr=9-dlnth"

        let "i++"
	    i=$(( (i+1) %4 ))
	    printf "\b$1${spin:$i:1}"

         
         dsze=`echo "$sizes_iomedia" | grep -A10 -B10 ${strng} | grep -m 1 -w "Size =" | cut -f2 -d "=" | tr -d "\n \t"`
          if [[  $dsze -le 999999999 ]]; then dsze=$(echo "scale=1; $dsze/1000000" | bc)" Mb"
        else
            if [[  $dsze -le 999999999999 ]]; then dsze=$(echo "scale=1; $dsze/1000000000" | bc)" Gb"
                    else
                         dsze=$(echo "scale=1; $dsze/1000000000000" | bc)" Gb"
            fi
        fi

    		scorr=`echo ${#dsze}`
    		let "scorr=scorr-5"
    		let "scorr=6-scorr"

             let "i++"
	         i=$(( (i+1) %4 ))
	         printf "\b$1${spin:$i:1}"

			sys_automounted=0
            GET_UUID_S
 
    uuid=`echo "$uuids_iomedia" | grep -A12 -B12 $strng | grep -m 1 UUID | cut -f2 -d "=" | tr -d " \n"`
        if [[ $uuid = "" ]]; then unuv=1; else unuv=0; fi
	if [[ ! $apos = 0 ]]; then
	 let var4=$apos
	poi=0
            while [ $var4 != 0 ]
		do
		 if [[ ${alist[$poi]} = $uuid ]]; then sys_automounted=1; var4=1; fi
	let "var4--"
            let "poi++"
	done
	fi

            drive=`echo "$drives_iomedia" | grep -B 10 ${dstrng} | grep -m 1 -w "IOMedia"  | cut -f1 -d "<" | sed -e s'/-o //'  | sed -e s'/Media//' | sed 's/ *$//' | tr -d "\n"`
             if [[ ${#drive} -gt 30 ]]; then drive=$( echo "$drive" | cut -f1-2 -d " " ); fi

            string1=$strng
            GET_RENAMEHD
            strng=$string1
            if [[ ! ${adrive} = "±" ]]; then drive="${adrive}"; fi
            dcorr=${#drive}
		    if [[ ${dcorr} -gt 30 ]]; then dcorr=0; drv="${drive:0:30}"; else let "dcorr=30-dcorr"; fi
            
            if [[ $ch -gt 9 ]]; then ncorr=1; else ncorr=2; fi

     if [[ $unuv = 1 ]]; then
            screen_buffer3+=$( printf '\n    '"%"$ncorr"s"$ch')   x    '"$drive""%"$dcorr"s"'    '${strng}"%"$corr"s""%"$scorr"s"' '"$dsze"'     ' )  
                else
	if [[ $sys_automounted = 0 ]]; then
			screen_buffer3+=$( printf '\n    '"%"$ncorr"s"$ch') ....   '"$drive""%"$dcorr"s"'    '${strng}"%"$corr"s""%"$scorr"s"' '"$dsze"'     ' ) 
		else
			screen_buffer3+=$( printf '\n    '"%"$ncorr"s"$ch') auto   '"$drive""%"$dcorr"s"'    '${strng}"%"$corr"s""%"$scorr"s"' '"$dsze"'     ' )
		fi
    fi
            
            let "i++"
	         i=$(( (i+1) %4 ))
	         printf "\b$1${spin:$i:1}"    

	let "num1++"
	let "var0--"
done 


printf "\r\033[4A"

}
###################################################################################################################################################################

UPDATE_KEYS_INFO(){

GETAUTO_OPEN
GETAUTO_EXIT
GETAUTO_TIMEOUT
 if [[ $loc = "ru" ]]; then

printf '      O) Открывать папку EFI после подключения = "'$amo_set'"'"%"$amo_corr"s"'(Да, Нет) \n'
printf '      C) Закрыть программу после подключения  = "'$ame_set'"'"%"$ame_corr"s"'(Да, Нет) \n'
printf '      T) Задержка в секундах для отмены закрытия программы:'"%"$tmo_corr"s"'{'$auto_timeout' сек}        \n\n'
printf '      D) Отменить выбранные и вернуться в меню                                  \n'
printf '      Q) Вернуться в меню. Настройки остаются                                   \n\n\n'
else
printf '      O) Open the EFI folder after mounting = "'$amo_set'"'"%"$amo_corr"s"'(Yes, No)\n'
printf '      C) Close the program after mounting = "'$ame_set'"'"%"$ame_corr"s"'(Yes, No)  \n'
printf '      T) Timeout in seconds to stop closing programm:'"%"$tmo_corr"s"'{'$auto_timeout' sec}         \n\n'
printf '      D) Cancel selected and return to menu                                     \n'
printf '      Q) Return to the menu saving settings                                     \n\n\n'
fi
}

UPDATE_SYS_KEYS_INFO(){

GET_SYS_AUTO_OPEN

 if [[ $loc = "ru" ]]; then

printf '      O) Открывать папку EFI после подключения = "'$sys_amo_set'"'"%"$sys_amo_corr"s"'(Да, Нет) \n\n'
printf '      D) Отменить выбранные и вернуться в меню                                  \n'
printf '      Q) Вернуться в меню. Настройки остаются                                   \n\n\n'
else
printf '      O) Open the EFI folder after mounting = "'$sys_amo_set'"'"%"$sys_amo_corr"s"'(Yes, No)\n\n'
printf '      D) Cancel selected and return to menu                                     \n'
printf '      Q) Return to the menu saving settings                                     \n\n\n'
fi
}


UPDATE_AUTOEFI(){
printf '\e[8;'${lines}';80t' && printf '\e[3J' && printf "\033[0;0H" 
 if [[ $loc = "ru" ]]; then
  printf '\n      Выберите раздел и опции автомонтирования:                                '
			else
        printf '\n          Select a partition and automount options:                            '
	                 fi
if [[ $loc = "ru" ]]; then
	
	printf '     '
	printf '.%.0s' {1..68} 
	printf '                                                                                       \n'
	printf '      0)  повторить поиск разделов\n' 	
		else
	printf '     '
	printf '.%.0s' {1..68} 
	printf '                                                                                       \n'
	printf '      0)  update EFI partitions list             \n' 
        fi


echo "$screen_buffer3"

printf '\n     '
	printf '.%.0s' {1..68}
printf '\n'

}

UPDATE_SYS_AUTOEFI(){
printf '\e[8;'${lines}';80t' && printf '\e[3J' && printf "\033[0;0H" 
 if [[ $loc = "ru" ]]; then
  printf '\n   Выберите раздел и опции монтирования EFI при входе в систему:                '
			else
        printf '\n Select EFI partitions and automount options:                                 '
            fi
if [[ $loc = "ru" ]]; then
	
	printf '     '
	printf '.%.0s' {1..68} 
	printf '                                                                                       \n'
	printf '      0)  повторить поиск разделов\n' 	
		else
	printf '     '
	printf '.%.0s' {1..68} 
	printf '                                                                                       \n'
	printf '      0)  update EFI partitions list             \n' 
        fi


echo "$screen_buffer3"

printf '\n     '
	printf '.%.0s' {1..68}
printf '\n'

}

SHOW_BACKUPS(){

Now=$(ls -l ${HOME}/.MountEFIconfBackups | grep ^d | wc -l | tr -d " \t\n")
if [[ $Now -lt 5 ]]; then lncorr=0; else let "lncorr=Now-4"; fi
let "lines2=lines+lncorr"
clear && printf '\e[8;'${lines2}';80t' && printf '\e[3J' && printf "\033[0;0H" 
                    if [[ $loc = "ru" ]]; then
        printf '                      Настройка бэкапов и восстановление                        '
			else
        printf '                         Backup and restore settings                            '
	                 fi
        printf '\n   '
	    printf '.%.0s' {1..74}
                                    if [[ $loc = "ru" ]]; then
                        printf '\n                                Имеются бэкапы:                            '
                        printf '\n     '
	                    printf '.%.0s' {1..34}
                        
                        printf '   '
	                    printf '.%.0s' {1..34}
                        printf '\n'
			               else
                        printf '\n                                Backups database                            '
                        printf '\n     '
	                    printf '.%.0s' {1..34}
                        
                        printf '   '
	                    printf '.%.0s' {1..34}
                        printf '\n'
	                         fi
                        printf '\r                                                                                '
GET_BACKUPS
if [[ ! $Now = 0 ]]; then
var6=$Maximum; chn=1
if [[ $Now -lt $Maximum ]]; then var6=$Now; fi
while [[ ! $var6 = 0 ]] 
do
if [[ -d ${HOME}/.MountEFIconfBackups/$chn ]]; then
        backtime=$(stat -f %m $F ${HOME}/.MountEFIconfBackups/$chn/.MountEFIconf.plist)
            if [[ $chn -le 9 ]]; then
            printf '               '$chn')    '
            else
            printf '              '$chn')    '
            fi
                date -r "$backtime" 
fi
let "chn++"; let "var6--"
done
let "chn--"
fi
                        printf '\n   '
	                    printf '.%.0s' {1..74}

                if [[ $loc = "ru" ]]; then

printf '\n\n                  S)  Сохранить текущие настройки в архив       '
printf '\n                  R)  Восстановить настройки из архива          '
printf '\n                  D)  Удалить сохранение из архива              '
printf '\n                  С)  Удалить все сохранения                    '
printf '\n                  M)  Максимальное количество резервных копий   <'$Maximum'>'
printf '\n                  P)  Поделиться настройками через iCloud       '
printf '\n                  Q)  Выйти в главное меню                      '
                    else
printf '\n\n                  S)  Save current settings to archive          '
printf '\n                  R)  Restore settings from archive             '
printf '\n                  D)  Delete backup from archive                '
printf '\n                  С)  Delete ALL backups                        '
printf '\n                  M)  Maximum number of backups                 <'$Maximum'>'
printf '\n                  P)  Share settings via iCloud                 '
printf '\n                  Q)  Exit to the main menu                     '
                   fi
}

#####################################################################################################################
ADD_BACKUP(){
Now=$(ls -l ${HOME}/.MountEFIconfBackups | grep ^d | wc -l | tr -d " \t\n")
GET_BACKUPS
if [[ $Now = 0 ]]; then Now=1; mkdir ${HOME}/.MountEFIconfBackups/$Now
    else
        if [[ "$Now" -lt "$Maximum" ]]; then
                let "Now++"
                else rm -f ${HOME}/.MountEFIconfBackups/$Now/.MountEFIconf.plist
                fi
             if [[ ! -d  ${HOME}/.MountEFIconfBackups/$Now ]]; then mkdir ${HOME}/.MountEFIconfBackups/$Now
                    if [[ -f ${HOME}/.MountEFIconfBackups/$Now/.MountEFIconf.plist ]]; then rm ${HOME}/.MountEFIconfBackups/$Now/.MountEFIconf.plist; fi
             fi
                let "fol=Now-1"
                for (( fon=$Now; fon>1; fon-- ))
             do

                mv ${HOME}/.MountEFIconfBackups/$fol/.MountEFIconf.plist ${HOME}/.MountEFIconfBackups/$fon/.MountEFIconf.plist
                let "fol--"
             done
fi
        cp ${HOME}/.MountEFIconf.plist ${HOME}/.MountEFIconfBackups/1/.MountEFIconf.plist
        
}

DELETE_BACKUP(){
        Now=$(ls -l ${HOME}/.MountEFIconfBackups | grep ^d | wc -l | tr -d " \t\n")
        if [[ ! $inputs = $Now ]]; then
        let "fll=inputs+1"
        rm -f ${HOME}/.MountEFIconfBackups/$inputs/.MountEFIconf.plist
        for (( fln=$inputs; fln<$Now; fln++ ))
        do
        mv ${HOME}/.MountEFIconfBackups/$fll/.MountEFIconf.plist ${HOME}/.MountEFIconfBackups/$fln/.MountEFIconf.plist
        let "fll++"
        done
        fi
        rm -R -f ${HOME}/.MountEFIconfBackups/$Now
           
}

RESTORE_BACKUP(){
rm ${HOME}/.MountEFIconf.plist
cp ${HOME}/.MountEFIconfBackups/$inputs/.MountEFIconf.plist ${HOME}
}

CHECK_BUNZIP(){
if [[ ! -d ${HOME}/.MountEFIconfBackups ]]; then 
unzip  -o -qq ${HOME}/.MountEFIconfBackups.zip -d ~/.temp
mv ~/.temp/*/*/.MountEFIconfBackups ~/.MountEFIconfBackups
rm -r ~/.temp
fi
}

UPDATE_ZIP(){
if [[ -d ${HOME}/.MountEFIconfBackups ]]; then
rm  ${HOME}/.MountEFIconfBackups.zip
zip -rX -qq ${HOME}/.MountEFIconfBackups.zip ${HOME}/.MountEFIconfBackups
fi
}

MATCHING_BACKUPS(){
CHECK_BUNZIP
Now=$(ls -l ${HOME}/.MountEFIconfBackups | grep ^d | wc -l | tr -d " \t\n")
matched=0
if [[ ! $Now = 0 ]]; then
currnt=$(md5 -qq ${HOME}/.MountEFIconf.plist)
for (( fln=1; fln<=$Now; fln++ ))
do
archv=$(md5 -qq ${HOME}/.MountEFIconfBackups/$fln/.MountEFIconf.plist)
if [[ $archv = $currnt ]]; then matched=1; break; fi
done
fi
}

PUT_BACKUPS_IN_ICLOUD(){
hwuuid=$(ioreg -rd1 -c IOPlatformExpertDevice | awk '/IOPlatformUUID/' | cut -f2 -d"=" | tr -d '" \n')
if [[ -d ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs ]]; then
        if [[ ! -d ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIBackups ]]; then 
                        mkdir ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIBackups; fi
        if [[ ! -d ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIBackups/$hwuuid ]]; then
                        mkdir ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIBackups/$hwuuid; fi
        if [[ -f ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIBackups/$hwuuid/.MountEFIconfBackups.zip ]]; then
                cloud_archv=$(md5 -qq /Users/$(whoami)/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIBackups/$hwuuid/.MountEFIconfBackups.zip)
                local_archv=$(md5 -qq ${HOME}/.MountEFIconfBackups.zip)
                    if [[ ! $cloud_archv = $local_archv ]]; then
                        rm -f ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIBackups/$hwuuid/.MountEFIconfBackups.zip
                        cp ${HOME}/.MountEFIconfBackups.zip ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIBackups/$hwuuid/
                    fi
         else
                        cp ${HOME}/.MountEFIconfBackups.zip ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIBackups/$hwuuid/
         fi
fi
}

CHECK_ICLOUD_BACKUPS(){
cloud_archive=0
shared_archive=0
hwuuid=$(ioreg -rd1 -c IOPlatformExpertDevice | awk '/IOPlatformUUID/' | cut -f2 -d"=" | tr -d '" \n')
        if [[ -d ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs ]]; then
            if [[ -f ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIbackups/$hwuuid/.MountEFIconfBackups.zip ]]; then cloud_archive=1; fi
            if [[ -f ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIbackups/Shared/.MountEFIconfBackups.zip ]]; then shared_archive=1; fi
        fi
}

PUT_SHARE_IN_ICLOUD(){
if [[ -d ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs ]]; then
        if [[ ! -d ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIbackups/Shared ]]; then
                mkdir ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIbackups/Shared ; fi
                        if [[ -f ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIbackups/Shared/.MountEFIconfBackups.zip ]]; then
                                cloud_archv=$(md5 -qq /Users/$(whoami)/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIBackups/Shared/.MountEFIconfBackups.zip)
                                local_archv=$(md5 -qq ${HOME}/.MountEFIconfBackups.zip)
                                        if [[ ! $cloud_archv = $local_archv ]]; then
                                rm -f ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIBackups/Shared/.MountEFIconfBackups.zip
                                cp ${HOME}/.MountEFIconfBackups.zip ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIBackups/Shared/.MountEFIconfBackups.zip
                                         fi
                         else
                                cp ${HOME}/.MountEFIconfBackups.zip ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIBackups/Shared/.MountEFIconfBackups.zip
                                        
                        fi
fi
}

CORRECT_BACKUPS_MAXIMUM(){
CHECK_BUNZIP
Now=$(ls -l ${HOME}/.MountEFIconfBackups | grep ^d | wc -l | tr -d " \t\n")
stop="1"; DEBUG
UPDATE_CACHE
GET_BACKUPS
stop="2"; DEBUG
if [[ $Now > $Maximum ]]; then
stop="3"; DEBUG
plutil -replace Backups.Maximum -integer ${Now} ${HOME}/.MountEFIconf.plist
UPDATE_CACHE
stop="4"; DEBUG
fi
stop="5"; DEBUG
if [[ -d ${HOME}/.MountEFIconfBackups ]]; then rm -R ${HOME}/.MountEFIconfBackups; fi
}

SET_BACKUPS(){
if [[ -d ${HOME}/.MountEFIconfBackups ]]; then rm -R ${HOME}/.MountEFIconfBackups; fi
unzip  -o -qq ${HOME}/.MountEFIconfBackups.zip -d ~/.temp
mv ~/.temp/*/*/.MountEFIconfBackups ~/.MountEFIconfBackups
rm -r ~/.temp

var5=0
while [[ $var5 = 0 ]]; do 
SHOW_BACKUPS

printf '\n\n'
unset inputs
while [[ ! ${inputs} =~ ^[sSdDcCmMqQrRpP]+$ ]]; do 

printf "\r"

                if [[ $loc = "ru" ]]; then
printf '  Выберите опцию S, R, D, C, M, P или Q :   ' ; printf '                             '
			else
printf '  Enter a letter S, R, D, C, M, P or Q :   ' ; printf '                           '
                fi
printf "%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"
printf "\033[4A"
printf "\r\033[42C"
printf "\033[?25h"

read -n 1 inputs 
if [[ $inputs = "" ]]; then printf "\033[1A"; fi
done

if [[ $inputs = [sS] ]]; then printf "\r\033"

                MATCHING_BACKUPS
                if [[ $matched = 1 ]]; then
                       if [[ $loc = "ru" ]]; then
                
                printf ' Текущие настройки совпадают с архивом номер < \e[1;5m'$fln'\e[0m >'
			else
                printf ' Match current settings with the archive number < \e[1;5m'$fln'\e[0m >'
                fi 
                printf "\033[?25l"
                read  -n 1 

                        else

                        if [[ $loc = "ru" ]]; then
                
                printf ' Подтвердите сохранение конфигурации (y/N) ? '
			else
                printf ' Confirm saving the current settings (y/N)? '
                
                fi
                printf "\033[?25h"
                read  -n 1 -r
                printf "\033[?25l"
                if [[  $REPLY =~ ^[yY]$ ]]; then
                CHECK_BUNZIP
                ADD_BACKUP
                UPDATE_ZIP
                fi
                fi
                inputs=0
                printf "\r\033"
                printf "%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"
                printf "\r\033[4A"
                
fi

if [[ ${inputs} = [dD] ]]; then
                            printf "\r"; printf "%"80"s"
                            if [[ $loc = "ru" ]]; then
                        printf '\r  Удаление бэкапа. (или просто "Enter" для отмены):\n\n'
                            else
                        printf '\r  Delete backup. (or just "Enter" to cancel):\n\n'
                        fi
                        while [[ ! ${inputs} =~ ^[0-9] ]]; do
                        printf "%"80"s"
                        printf "\033[1A"
                        if [[ $loc = "ru" ]]; then
                        printf '   Выберите номер бэкапа ( 1 - '$chn' ): ' 
                            else
                        printf '   Choose backup number  ( 1 - '$chn' ): '
                        fi
                        printf "\033[?25h" 
                        read  inputs
                        printf "\033[?25l" 
                        printf '\r';  printf "%"80"s"
                        if [[ $inputs = 0 ]]; then inputs="t"; fi &> /dev/null
                        if [[ $inputs -gt $chn ]]; then inputs="t"; fi &> /dev/null
                        if [[ ${inputs} = "" ]]; then inputs="p"; printf "\033[1A"; break; fi &> /dev/null
                        printf "\033[1A"
                        printf "\r"
                        done
                        if [[ ! ${inputs} = "p" ]]; then
                        CHECK_BUNZIP
                        DELETE_BACKUP
                        UPDATE_ZIP
                        fi
                        inputs=0
fi

if [[ ${inputs} = [rR] ]]; then
                            printf "\r\033"; printf "%"80"s"
                            if [[ $loc = "ru" ]]; then
                        printf '\r  Восстановление конфигурации из бэкапа. (или просто "Enter" для отмены):\n\n'
                            else
                        printf '\r  Restoring configuration from backup. (or just "Enter" to cancel):\n\n'
                        fi
                        while [[ ! ${inputs} =~ ^[0-9] ]]; do
                        printf "%"80"s"
                        printf "\033[1A"
                        if [[ $loc = "ru" ]]; then
                        printf '   Выберите номер бэкапа ( 1 - '$chn' ): ' 
                            else
                        printf '   Choose backup number  ( 1 - '$chn' ): '
                        fi
                        printf "\033[?25h" 
                        read  inputs
                        printf "\033[?25l" 
                        printf '\r';  printf "%"80"s"
                        if [[ $inputs = 0 ]]; then inputs="t"; fi &> /dev/null
                        if [[ $inputs -gt $chn ]]; then inputs="t"; fi &> /dev/null
                        if [[ ${inputs} = "" ]]; then inputs="p"; printf "\033[1A"; break; fi &> /dev/null
                        printf "\033[1A"
                        printf "\r"
                        done
                        if [[ ! ${inputs} = "p" ]]; then
                        CHECK_BUNZIP
                        RESTORE_BACKUP
                        UPDATE_CACHE
                        Now=$(ls -l ${HOME}/.MountEFIconfBackups | grep ^d | wc -l | tr -d " \t\n")
                        GET_BACKUPS
                        if [[ $Now > $Maximum ]]; then
                        plutil -replace Backups.Maximum -integer ${Now} ${HOME}/.MountEFIconf.plist
                        UPDATE_CACHE
                        fi
                        fi
                        inputs=0
fi

if [[ $inputs = [cC] ]]; then printf "\r\033"
                        if [[ $loc = "ru" ]]; then
                
                printf ' Подтвердите удаление ВСЕХ бэкапов (y/N) ? '
			else
                printf ' Confirm deletion of ALL backups (y/N)? '
                
                fi
                printf "\033[?25h"
                read  -n 1 -r
                printf "\033[?25l"
                if [[  $REPLY =~ ^[yY]$ ]]; then
                CHECK_BUNZIP
                rm -R -f ${HOME}/.MountEFIconfBackups/*
                UPDATE_ZIP
                inputs=0
                fi
                printf "\r\033"
                printf "%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"
                printf "\r\033[4A"
                
fi

if [[  ${inputs}  = [mM] ]]; then
        var7=0
        while [[ ! $var7 = 1 ]] 
            do
                    unset get_num
                    while [[ ! ${get_num} =~ ^[0-9]+$ ]]
                    do
                    printf "\r\033"; printf "%"79"s"
                    
                    printf '\n                                                         '
                    printf '\n                                                         '
                    printf "\r\033[3A"
                    if [[ $loc = "ru" ]]; then
                    printf '\n  Максимальное количество бэкапов конфига:  ' 
			           else
                    printf '\n  Maximum number of config backups:   ' 
                    fi
                    printf "\033[?25h"
                    read get_num
                    printf "\033[?25l"
                    printf "\r\033[1A"
                    if [[ ${get_num} = "" ]]; then  unset get_num; fi 
                    if [[ ${get_num} = 0 ]]; then  unset get_num; fi 2>&-
                    if [[ ${get_num} -gt 99 ]]; then unset get_num; fi 2>&-
                    
                    done
            plutil -replace Backups.Maximum -integer ${get_num} ${HOME}/.MountEFIconf.plist 
            UPDATE_CACHE
            CHECK_BUNZIP
            Now=$(ls -l ${HOME}/.MountEFIconfBackups | grep ^d | wc -l | tr -d " \t\n")
            if [[ $Now -gt get_num ]]; then
                for (( i=$Now; i>get_num; i-- ))
                do
                rm -R -f ${HOME}/.MountEFIconfBackups/$i
                done
            fi
            UPDATE_ZIP 
            var7=1
            done
            inputs=0
fi


if [[ $inputs = [pP] ]]; then printf "\r\033"
                        if [[ $loc = "ru" ]]; then
                
                printf '   Подтвердите публикацию настроек (y/N) ?  '
			else
                printf '   Confirm the publication of settings (y/N)?  '
                
                fi
                printf "\033[?25h"
                read  -n 1 -r                
                printf "\033[?25l"
                if [[  $REPLY =~ ^[yY]$ ]]; then
                PUT_SHARE_IN_ICLOUD
                fi
                printf "\r\033"
                printf "%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"
                printf "\r\033[4A"
fi
                

if [[  ${inputs}  = [qQ] ]]; then var5=1; fi
 

done
if [[ -d ${HOME}/.MountEFIconfBackups ]]; then rm -R ${HOME}/.MountEFIconfBackups; fi
clear
unset inputs
}

##################################################### SET AUTOMOUNT #######################################################################
SET_AUTOMOUNT(){
clear
REM_ABSENT
if [[ $cache = 0 ]]; then UPDATE_CACHE; fi
GET_FULL_EFI
SHOW_AUTOEFI
UPDATE_KEYS_INFO
var5=0
 
while [ $var5 != 1 ] 
do
clear && printf '\e[3J' && printf "\033[0;0H" 
UPDATE_AUTOEFI
printf '\n'
UPDATE_KEYS_INFO
unset inputs
while [[ ! ${inputs} =~ ^[0-9oOqQdDcCtT]+$ ]]; do 

                if [[ $loc = "ru" ]]; then
printf '  Введите число от 0 до '$ch' (или O, C, T, D, Q ):   ' ; printf '                          '
			else
printf '  Enter a number from 0 to '$ch' (or O, C, T, D, Q ):   ' ; printf '                        '
                fi
printf "%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"
printf "\033[4A"
printf "\r\033[48C"
printf "\033[?25h"
if [[ ${ch} -le 9 ]]; then
    inputs="±"
    while [[ $inputs = "±" ]]
    do
    IFS="±"; read -n 1 -t 1 inputs ; unset IFS  ; CHECK_HOTPLUG
    done
else
    calls=1; READ_TWO_SYMBOLS    
fi
#IFS="±"; read -n 1 inputs ; unset IFS 
if [[ ${inputs} = "" ]]; then printf "\033[1A"; fi
printf "\r"
done
printf "\033[?25l"

if [[  ${inputs}  = [dD] ]]; then
			plutil -replace AutoMount.Enabled -bool NO ${HOME}/.MountEFIconf.plist
			plutil -replace AutoMount.ExitAfterMount -bool NO ${HOME}/.MountEFIconf.plist
			plutil -replace AutoMount.Open -bool NO ${HOME}/.MountEFIconf.plist
			plutil -replace AutoMount.PartUUIDs -string " " ${HOME}/.MountEFIconf.plist
            plutil -replace AutoMount.Timeout2Exit -integer 5 ${HOME}/.MountEFIconf.plist
			var5=1
            UPDATE_CACHE
fi

if [[  ${inputs}  = [qQ] ]]; then
			GET_AUTOMOUNTED
			if [[ ! $apos = 0 ]]; then 
				plutil -replace AutoMount.Enabled -bool YES ${HOME}/.MountEFIconf.plist
                GET_SYSTEM_FLAG
                GET_USER_PASSWORD
                if [[ $mypassword = "0" ]]; then ENTER_PASSWORD; osascript -e 'tell application "Terminal" to activate'; fi
                GET_USER_PASSWORD
                if [[ $mypassword = "0" ]]; then plutil -replace AutoMount.Enabled -bool NO ${HOME}/.MountEFIconf.plist; fi
                    else
                plutil -replace AutoMount.Enabled -bool NO ${HOME}/.MountEFIconf.plist
            fi
                UPDATE_CACHE
	  var5=1
fi

if [[  ${inputs}  = [oO] ]]; then
	if [[ $autom_open = 0 ]]; then 	
				plutil -replace AutoMount.Open -bool YES ${HOME}/.MountEFIconf.plist; UPDATE_CACHE
					else
				plutil -replace AutoMount.Open -bool NO ${HOME}/.MountEFIconf.plist; UPDATE_CACHE
	fi
fi

if [[  ${inputs}  = [cC] ]]; then
	if [[ $autom_exit = 0 ]]; then 	
				plutil -replace AutoMount.ExitAfterMount -bool YES ${HOME}/.MountEFIconf.plist; UPDATE_CACHE	
					else
				plutil -replace AutoMount.ExitAfterMount -bool NO ${HOME}/.MountEFIconf.plist; UPDATE_CACHE
	fi
fi

if [[  ${inputs}  = [tT] ]]; then
        var7=0
        while [[ ! $var7 = 1 ]] 
            do
                    unset get_num
                    while [[ ! ${get_num} =~ ^[0-9]+$ ]]
                    do
                    printf "\r\033[1A"
                    printf '\n                                                      '
                    printf '\n                                                      '
                    printf "\r\033[2A"
                    if [[ $loc = "ru" ]]; then
                    printf '\n  Введите время задержки выхода в секундах:  ' 
			           else
                    printf '\n  Enter the timeout in seconds   ' 
                    fi
                    printf "\033[?25h"
                    read get_num
                    printf "\033[?25l"
                    printf "\r\033[1A"
                    if [[ ${get_num} -gt 999 ]]; then unset get_num; fi 2>&-
                    done
            plutil -replace AutoMount.Timeout2Exit -integer ${get_num} ${HOME}/.MountEFIconf.plist 
            UPDATE_CACHE   
            var7=1
            done
fi
if [[ ! ${inputs} =~ ^[0oOdDcCtTqQ]+$ ]]; then

GET_AUTOMOUNTED
	
	am_check=0
	let "pois=inputs-1"
    uuid=`echo "$uuids_iomedia" | grep -A12 -B12 ${slist[$pois]} | grep -m 1 UUID | cut -f2 -d "=" | tr -d " \n"`
    if [[ $uuid = "" ]]; then unuv=1; else unuv=0; fi
if [[ ! $apos = 0 ]]; then
	 let vari=$apos
	poi=0
            while [ $vari != 0 ]
		do
		 if [[ ${alist[$poi]} = $uuid ]]; then 
            if [[ $unuv = 0 ]]; then 
							strng2=`echo ${strng1[@]}  |  sed 's/'$uuid'//'`
							plutil -replace AutoMount.PartUUIDs -string "$strng2" ${HOME}/.MountEFIconf.plist	; UPDATE_CACHE						
 							vari=1
							am_check=1
                            screen_buffer3=$( echo "$screen_buffer3" | sed "s/$inputs) auto  /$inputs) ....  /" )
                            
            fi                
		fi

	let "vari--"
            let "poi++"
	done
fi
if [[ $am_check = 0 ]]; then 
        if [[ $unuv = 0 ]]; then 
			strng1+=" "
			strng1+=$uuid
			plutil -replace AutoMount.PartUUIDs -string "$strng1" ${HOME}/.MountEFIconf.plist ; UPDATE_CACHE
            screen_buffer3=$( echo "$screen_buffer3" | sed "s/$inputs) ....  /$inputs) auto  /" )
            
        fi
fi
	else
		if [[ $inputs = 0 ]]; then GET_FULL_EFI; SHOW_AUTOEFI
	fi				
fi
done
clear
unset inputs
}

#######################################################################################################################################################################

##################################################### SET SYSTEM AUTOMOUNT #######################################################################
SET_SYS_AUTOMOUNT(){
clear
REM_SYS_ABSENT
if [[ $cache = 0 ]]; then UPDATE_CACHE; fi
GET_FULL_EFI
let "lines=lines-2"
SHOW_SYS_AUTOEFI
UPDATE_SYS_KEYS_INFO
var5=0
 
while [ $var5 != 1 ] 
do
clear && printf '\e[3J' && printf "\033[0;0H" 
UPDATE_SYS_AUTOEFI
printf '\n'
UPDATE_SYS_KEYS_INFO
unset inputs
while [[ ! ${inputs} =~ ^[0-9oOqQdD]+$ ]]; do 

                if [[ $loc = "ru" ]]; then
printf '  Введите число от 0 до '$ch' (или O, D, Q ):    ' ; printf '                                  '
			else
printf ' Enter a number from 0 to '$ch' (or O, D, Q ):   ' ; printf '                                  '
                fi
printf "%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"
printf "\033[4A"
printf "\r\033[43C"
printf "\033[?25h"
if [[ ${ch} -le 9 ]]; then
    inputs="±"
    while [[ $inputs = "±" ]]
    do
    IFS="±"; read -n 1 -t 1 inputs ; unset IFS  ; CHECK_HOTPLUG
    done
else
    calls=1; READ_TWO_SYMBOLS    
fi
#IFS="±"; read -n 1 inputs ; unset IFS 
if [[ ${inputs} = "" ]]; then printf "\033[1A"; fi
printf "\r"
done
printf "\033[?25l"

if [[  ${inputs}  = [dD] ]]; then
			plutil -replace SysLoadAM.Enabled -bool NO ${HOME}/.MountEFIconf.plist
			plutil -replace SysLoadAM.Open -bool NO ${HOME}/.MountEFIconf.plist
			plutil -replace SysLoadAM.PartUUIDs -string " " ${HOME}/.MountEFIconf.plist
			var5=1
            UPDATE_CACHE
            inputs="q"
fi

if [[  ${inputs}  = [qQ] ]]; then
			GET_SYS_AUTOMOUNTED
			if [[ ! $apos = 0 ]]; then 
                plutil -replace SysLoadAM.Enabled -bool YES ${HOME}/.MountEFIconf.plist
                    else
                plutil -replace SysLoadAM.Enabled -bool NO ${HOME}/.MountEFIconf.plist
            fi
                UPDATE_CACHE
	  var5=1
fi

if [[  ${inputs}  = [oO] ]]; then
	if [[ $sys_autom_open = 0 ]]; then 	
				plutil -replace SysLoadAM.Open -bool YES ${HOME}/.MountEFIconf.plist; UPDATE_CACHE
					else
				plutil -replace SysLoadAM.Open -bool NO ${HOME}/.MountEFIconf.plist; UPDATE_CACHE
	fi
fi




if [[ ! ${inputs} =~ ^[0oOdDqQ]+$ ]]; then

GET_SYS_AUTOMOUNTED
	
	sys_am_check=0
	let "pois=inputs-1"
    uuid=`echo "$uuids_iomedia" | grep -A12 -B12 ${slist[$pois]} | grep -m 1 UUID | cut -f2 -d "=" | tr -d " \n"`
    if [[ $uuid = "" ]]; then unuv=1; else unuv=0; fi
if [[ ! $apos = 0 ]]; then
	 let vari=$apos
	poi=0
            while [ $vari != 0 ]
		do
		 if [[ ${alist[$poi]} = $uuid ]]; then 
            if [[ $unuv = 0 ]]; then 
							strng2=`echo ${strng1[@]}  |  sed 's/'$uuid'//'`
							plutil -replace SysLoadAM.PartUUIDs -string "$strng2" ${HOME}/.MountEFIconf.plist	; UPDATE_CACHE						
 							vari=1
							sys_am_check=1
                            screen_buffer3=$( echo "$screen_buffer3" | sed "s/$inputs) auto  /$inputs) ....  /" )
                            
            fi                
		fi

	let "vari--"
            let "poi++"
	done
fi
if [[ $sys_am_check = 0 ]]; then 
        if [[ $unuv = 0 ]]; then 
			strng1+=" "
			strng1+=$uuid
			plutil -replace SysLoadAM.PartUUIDs -string "$strng1" ${HOME}/.MountEFIconf.plist ; UPDATE_CACHE
            screen_buffer3=$( echo "$screen_buffer3" | sed "s/$inputs) ....  /$inputs) auto  /" )
            
        fi
fi
	else
		if [[ $inputs = 0 ]]; then GET_FULL_EFI; let "lines=lines-2"; SHOW_SYS_AUTOEFI
	fi				
fi
done

unset inputs
}

SET_PLIST(){
filename_1=$(echo $filename | tr -d '.')

if [[ "${filename_1}" = "MountEFIconfplist" ]]; then

mv -f "${filepath}" ${HOME}/.MountEFIconf.plist

UPDATE_CACHE
CHECK_CONFIG
CORRECT_BACKUPS_MAXIMUM
            else
                
                errorep=1
fi

}

SET_ZIP(){
unzip  -o -qq "${filepath}" -d ~/.temp2

filecounts=$(ls -la ~/.temp2/*/* | grep -o .MountEFIconf.plist | wc -l | tr -d " \t\n")
     
     if [[ ! $filecounts = 1 ]]; then
           
           errorep=2 
     else
            
           filename=$(ls -la ~/.temp2/*/* | grep -o .MountEFIconf.plist | tr -d ' \n\t')
            
           if [[ $filename = "" ]]; then 
            
           errorep=3
           else
               
                mv -f ~/.temp2/*/*/"${filename}" ${HOME}/.MountEFIconf.plist
                
                UPDATE_CACHE
                CHECK_CONFIG
                CORRECT_BACKUPS_MAXIMUM
                
                
            fi
         fi
rm -r ~/.temp2

}

#######################################################################################################################################################################

DOWNLOAD_CONFIG_FROM_FILE(){
errorep=0

if filepath=$(osascript -e 'tell application "Terminal" to return POSIX path of (choose file)'); then 
        
        filepath=$(echo -n "${filepath}" | sed "s/ /\\\ /g" | xargs )
        filename="${filepath##*/}"; extension="${filename##*.}"
        
     if [[ "${extension}" = "plist" ]]; then  SET_PLIST;
 
            else
                if [[ "${extension}" = "zip" ]]; then  SET_ZIP; 
                    else
                        
                        errorep=1
                 fi
       fi

else errorep=4
    
fi >/dev/null 2>&1

if [[ $loc = "ru" ]]; then
if [[ $errorep = 0 ]]; then printf '\n\n  Новый файл конфигурации установлен              '; sleep 2; fi
if [[ $errorep = 1 ]]; then printf '\n\n  Файл не является файлом конфигурации MountEFI   '; sleep 2; fi
if [[ $errorep = 2 ]]; then printf '\n\n  В архиве нет файла или больше одного файла. Такой импорт не поддерживается '; sleep 2; fi
if [[ $errorep = 4 ]]; then printf '\n\n  Импорт конфигурации отменён                     '; sleep 2; fi
else
if [[ $errorep = 0 ]]; then printf '\n\n  New configuration file installed                '; sleep 2; fi
if [[ $errorep = 1 ]]; then printf '\n\n  The file is not a MountEFI configuration file   '; sleep 2; fi
if [[ $errorep = 2 ]]; then printf '\n\n  There is no file in the archive or more than one file. This import is not supported. '; sleep 2; fi
if [[ $errorep = 4 ]]; then printf '\n\n  Configuration import canceled                   '; sleep 2; fi
fi


}

UPLOAD_CONFIG_TO_FILE(){
errorep=0
if folderpath=$(osascript -e 'tell application "Terminal" to return POSIX path of (choose folder)'); then 
        
        folderpath=$(echo -n "${folderpath}" | sed "s/ /\\\ /g" | xargs )
        
        if [[ -f ${HOME}/MountEFIconf.plist ]]; then rm ${HOME}/MountEFIconf.plist; fi
        cp ${HOME}/.MountEFIconf.plist ${HOME}/MountEFIconf.plist
        
        if [[ -f ${HOME}/.MountEFIconf.zip ]]; then rm ${HOME}/.MountEFIconf.zip; fi
        zip -X -qq ${HOME}/.MountEFIconf.zip ${HOME}/MountEFIconf.plist
        rm ${HOME}/MountEFIconf.plist
        
        mv -f ${HOME}/.MountEFIconf.zip "${folderpath}"/MountEFIconf.zip

else errorep=1
        
fi >/dev/null 2>&1

if [[ $loc = "ru" ]]; then
    if [[ $errorep = 1 ]]; then printf '\n\n  Экспорт конфигурации отменён   '; sleep 2 
        else
if [[ -f "${folderpath}"/MountEFIconf.zip ]]; then printf '\n\n  Конфигурация успешно экспортирована в архиве   '; sleep 2 
  else
        printf '\n\n  Ошибка. Экспорт конфигурации не удался   '; sleep 2
fi
fi
else
    if [[ $errorep = 1 ]]; then printf '\n\n  Configuration export canceled   '; sleep 2 
        else
if [[ -f "${folderpath}"/MountEFIconf.zip ]]; then printf '\n\n  Configuration exported to archive successfully   '; sleep 2 
  else
        printf '\n\n  Error. Export configuration failed   '; sleep 2
fi
fi
fi
        


}

GET_INPUT(){

unset inputs
while [[ ! ${inputs} =~ ^[0-9qQvVaAbBcCdDlLiIeE]+$ ]]; do

                if [[ $loc = "ru" ]]; then
printf '  Введите символ от 0 до '$Lit' (или Q - выход ):   ' ; printf '                             '
			else
printf '  Enter a letter from 0 to '$Lit' (or Q - exit ):   ' ; printf '                           '
                fi
printf "%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"
printf "\033[4A"
printf "\r\033[45C"
printf "\033[?25h"
IFS="±"; read -n 1 inputs ; unset IFS 
if [[ ${inputs} = "" ]]; then printf "\033[1A"; fi
printf "\r"
done
printf "\033[?25l"

}

GET_LOADERS(){
CheckLoaders=1
strng=`echo "$MountEFIconf" | grep -A 1 -e "CheckLoaders</key>" | grep false | tr -d "<>/"'\n\t'`
if [[ $strng = "false" ]]; then CheckLoaders=0
            if [[ $loc = "ru" ]]; then
        ld_set="Нет"; ld_corr=15
            else
        ld_set="No"; ld_corr=10
            fi
    else
            if [[ $loc = "ru" ]]; then
        ld_set="Да"; ld_corr=16
            else
        ld_set="Yes"; ld_corr=9
            fi
fi
}

GET_AUTOMOUNT(){
autom_enabled=0
strng=`echo "$MountEFIconf" | grep AutoMount -A 3 | grep -A 1 -e "Enabled</key>" | grep true | tr -d "<>/"'\n\t'`
if [[ $strng = "true" ]]; then autom_enabled=1
            if [[ $loc = "ru" ]]; then
        am_set="Да"; am_corr=12
            else
        am_set="Yes"; am_corr=9
            fi
    else
            if [[ $loc = "ru" ]]; then
        am_set="Нет"; am_corr=11
            else
        am_set="No"; am_corr=10
            fi
fi
}

GET_AUTOBACKUP(){
Autobackup=0
strng=`echo "$MountEFIconf" | grep Backups -A 3 | grep -A 1 -e "Auto</key>" | grep true | tr -d "<>/"'\n\t'`
if [[ $strng = "true" ]]; then Autobackup=1
  if [[ $loc = "ru" ]]; then
        bd_set="Да"; bd_corr=17
            else
        bd_set="Yes"; bd_corr=11
            fi
    else
            if [[ $loc = "ru" ]]; then
        bd_set="Нет"; bd_corr=16
            else
        bd_set="No"; bd_corr=12
            fi
fi  

}

SET_SCREEN(){
            if [[ $loc = "ru" ]]; then
printf ' 0) Установить все настройки по умолчанию                                      \n'
printf ' 1) Язык интерфейса программы = "'$loc_set'"'"%"$loc_corr"s"'(авто, англ, русский) \n'
printf ' 2) Показывать меню = "'"$menue_set"'"'"%"$menue_corr"s"'(авто, всегда)        \n'
printf ' 3) Пароль пользователя = "'"$mypassword_set"'"'"%"$pass_corr"s"'(пароль, нет пароля)  \n'
printf ' 4) Открывать папку EFI в Finder = "'$OpenFinder_set'"'"%"$of_corr"s"'(Да, Нет)             \n'
printf ' 5) Установки темы =  "'$theme_set'"'"%"$theme_corr"s"'(система, встроенная) \n'
printf ' 6) Пресет "'$itheme_set'" из '$pcount' встроенных'"%"$btheme_corr"s"'(имя пресета)'"%"$btspc_corr"s"' \n'
printf ' 7) Показывать подсказки по клавишам = "'$ShowKeys_set'"'"%"$sk_corr"s"'(Да, Нет)             \n'
printf ' 8) Подключить EFI при запуске MountEFI = "'$am_set'"'"%"$am_corr"s"'(Да, Нет)     \n'
printf ' 9) Подключить EFI при запуске Mac OS X = "'$sys_am_set'"'"%"$sys_am_corr"s"'(Да, Нет)     \n'
printf ' L) Искать загрузчики подключая EFI = "'$ld_set'"'"%"$ld_corr"s"'(Да, Нет)             \n'
printf ' C) Сохранение настроек при выходе = "'$bd_set'"'"%"$bd_corr"s"'(Да, Нет)             \n'
printf ' A) Создать или править псевдонимы физических носителей                       \n'
printf ' B) Резервное сохранение и восстановление настроек                              \n'
printf ' I) Загрузить конфиг из файла (zip или plist)                                   \n'
printf ' E) Сохранить конфиг в файл (zip)                                               \n'

            else
printf ' 0) Setup all parameters to defaults                                            \n'
printf ' 1) Program language = "'$loc_set'"'"%"$loc_corr"s"'(auto, rus, eng)         \n'
printf ' 2) Show menue = "'"$menue_set"'"'"%"$menue_corr"s"'(auto, always)           \n'
printf ' 3) Save password = "'"$mypassword_set"'"'"%"$pass_corr"s"'(password, not saved)    \n'
printf ' 4) Open EFI folder in Finder = "'$OpenFinder_set'"'"%"$of_corr"s"'(Yes, No)                \n'
printf ' 5) Set theme =  "'$theme_set'"'"%"$theme_corr"s"'(system, built-in)       \n'
printf ' 6) Theme preset "'$itheme_set'" of '$pcount' presets'"%"$btheme_corr"s"'(preset name)            \n'
printf ' 7) Show binding keys help = "'$ShowKeys_set'"'"%"$sk_corr"s"'(Yes, No)                \n'
printf ' 8) Mount EFI on run MountEFI. Enabled = "'$am_set'"'"%"$am_corr"s"'(Yes, No)            \n'
printf ' 9) Mount EFI on run Mac OS X. Enabled = "'$sys_am_set'"'"%"$sys_am_corr"s"'(Yes, No)            \n'
printf ' L) Look for boot loaders mounting EFI = "'$ld_set'"'"%"$ld_corr"s"'(Yes, No)                \n'
printf ' C) Auto save settings on exit setup = "'$bd_set'"'"%"$bd_corr"s"'(Yes, No)                \n'
printf ' A) Create or edit aliases physical device/media                              \n'
printf ' B) Backup and restore configuration settings                                   \n'
printf ' I) Import config from file (zip or plist)                                      \n'
printf ' E) Upload config to file (zip)                                                 \n'


            fi
                    Lit="C"
             if [[ $cloud_archive = 1 ]] || [[ $shared_archive = 1 ]]; then
                    Lit="D"
               if [[ $loc = "ru" ]]; then
printf ' D) Загрузить бэкапы настроек из iCloud                                         \n'
                else
printf ' D) Upload settings backups from iCloud                                         \n'
            fi
      fi
}

UPDATE_SCREEN(){
        GET_THEME
        if [[ $theme = "built-in" ]]; then CUSTOM_SET; fi

        SET_LOCALE

                    if [[ $loc = "ru" ]]; then
        printf '******                   Программа настройки MountEFI                    *******\n'
			else
        printf '******                This is setup program for MountEFI                 *******\n'
	                 fi
        printf '.%.0s' {1..80}
        printf ' %.0s' {1..80}
        

        GET_MENUE
        GET_USER_PASSWORD
        GET_OPENFINDER
        GET_THEME
        GET_SHOWKEYS
        GET_AUTOMOUNT
        CHECK_SYS_AUTOMOUNT_SERVICE
        GET_LOADERS
        GET_AUTOBACKUP
        CHECK_ICLOUD_BACKUPS
        SET_SCREEN

    

        printf ' %.0s' {1..80}
        printf ' %.0s' {1..80}
        printf '\r\033[2A'
        printf '\n'
        printf '.%.0s' {1..80}
        printf ' %.0s' {1..80}
        printf ' %.0s' {1..80}
}



SHOW_EFIs(){
printf '\e[8;'${lines}';80t' && printf '\e[3J' && printf "\033[0;0H" 


                        if [[ $loc = "ru" ]]; then
        printf '\n******    Программа монтирует EFI разделы в Mac OS (X.11 - X.14)    *******\n\n'
			else
        printf '\n******    This program mounts EFI partitions on Mac OS (X.11 - X.14)    *******\n\n'
	                 fi

SHOW_DISKs

}

SHOW_COLOR_TUNING(){
if [[ -f colors.csv ]]; then
GET_CURRENT_SET
printf ' 1) Текущий пресет темы = '$current'\n'
printf '      2) Цвет фона           = '$current_background'\n'
printf '      3) Цвет текста         = '$current_foreground'\n'
printf '      4) Набор шрифтов       = '$current_fontname
printf '\n      5) Размер шрифтов      = '$current_fontsize'\n'
fi

}



####################################### псевдонимы #############################################################################


GET_FULL_EFI(){

GET_EFI_S

if [[ $par = "-r" ]]; then
ShowKeys=1
strng=`echo "$MountEFIconf" | grep -A 1 -e "ShowKeys</key>" | grep false | tr -d "<>/"'\n\t'`
if [[ $strng = "false" ]]; then ShowKeys=0; fi
if [[ $ShowKeys = 1 ]]; then lines=25; else lines=23; fi
else
lines=23 
fi
let "lines=lines+pos"

if [[ ! $pos = 0 ]]; then 
		var0=$pos; num=0; dnum=0; unset nslist
	while [[ ! $var0 = 0 ]] 
		do
		strng=`echo ${slist[$num]}`
    if [[ $strng = $syspart ]]; then unset slist[$num]; let "pos--"
            else
		dstring=`echo $strng | rev | cut -f2-3 -d"s" | rev`
		dlenth=`echo ${#dstring}`

		
		var10=$posi; numi=0; out=0
        while [[ ! $var10 = 0 ]] 
		do

		if [[ ${dstring} = ${ilist[numi]} ]]; then
        unset slist[$num]; let "pos--"; out=1
        fi 
        if [[ $out = 1 ]]; then break; fi
        let "var10--"; let "numi++"
        done
  
		if [[ $var10 = 0 ]]; then nslist+=( $num ); fi
	fi	
		let "var0--"
		let "num++"
	done
fi
}

################################ получение имени диска для переименования ##########################################################
GET_RENAMEHD(){
adrive="±"
unset strng
strng=`echo "$MountEFIconf"| grep -A 1 "<key>RenamedHD</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
IFS=';'; rlist=($strng); unset IFS
rcount=${#rlist[@]}
if [[ ! $rcount = 0 ]]; then
        var=$rcount; posr=0
            while [[ ! $var = 0 ]]
         do
            rdrive=`echo "${rlist[$posr]}" | cut -f1 -d"="`
            if [[ "$rdrive" = "$drive" ]]; then adrive=`echo "${rlist[posr]}" | rev | cut -f1 -d"=" | rev`; renamed=1; break; fi
            let "var--"
            let "posr++"
         done
fi
}
######################################################################################################################################

SHOW_FULL_EFI(){

printf '\e[8;'${lines}';80t' && printf '\e[3J' && printf "\033[0;0H" 
                if [[ $loc = "ru" ]]; then
        printf '                             Настройкa псевдонимов                           '
			else
        printf '                                 Aliases setup                               '
	                 fi
var0=$pos; num=0 ; ch=0; unset screen_buffer1; unset screen_buffer2

macos=`sw_vers -productVersion`
macos=`echo ${macos//[^0-9]/}`
macos=${macos:0:4}
if [[ "$macos" = "1014" ]] || [[ "$macos" = "1013" ]] || [[ "$macos" = "1012" ]] || [[ "$macos" = "1015" ]]; then
        vmacos="Disk Size:"
    else
        vmacos="Total Size:"
fi

if [[ $loc = "ru" ]]; then
    printf '\n\n\n    0)  поиск разделов .....    '
		else
	printf '\n\n\n    0)  updating  list .....      '
        fi

spin='-\|/'
i=0
printf "$1${spin:$i:1}"

while [ $var0 != 0 ] 
do 
	let "ch++"

	let "i++"
	i=$(( (i+1) %4 ))
	printf "\b$1${spin:$i:1}"

	pnum=${nslist[num]}
	string=`echo ${slist[$pnum]}`
	
		
				
		dstring=`echo $string | rev | cut -f2-3 -d"s" | rev`
		dlenth=`echo ${#dstring}`
		let "corr=9-dlenth"

		drive=`echo "$drives_iomedia" | grep -B 10 ${dstring} | grep -m 1 -w "IOMedia"  | cut -f1 -d "<" | sed -e s'/-o //'  | sed -e s'/Media//' | sed 's/ *$//' | tr -d "\n"`
        if [[ ${#drive} -gt 30 ]]; then drive=$( echo "$drive" | cut -f1-2 -d " " ); fi
        GET_RENAMEHD
		dcorr=${#drive}
		if [[ ${dcorr} -gt 30 ]]; then dcorr=0; drive="${drive:0:30}"; else let "dcorr=30-dcorr"; fi
		
	

	let "i++"
	i=$(( (i+1) %4 ))
	printf "\b$1${spin:$i:1}"

        
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

        if [[ $adrive = "±" ]]; then 
            ddcorr=${#drive}
            ddrive="$drive"
		 else
            ddcorr=${#adrive}
            ddrive="${adrive}"
            fi
            
            if [[ ${ddcorr} -gt 30 ]]; then ddcorr=0; ddrive="${ddrive:0:30}"; else let "ddcorr=30-ddcorr"; fi

            
                if [[ $ch -gt 9 ]]; then ncorr=1; else ncorr=2; fi
		    

                       if [[ ! $mcheck = "Yes" ]]; then
             screen_buffer1+=$( printf '\n    '"%"$ncorr"s"$ch') ...   '"$ddrive""%"$ddcorr"s"'    '${string}"%"$corr"s""%"$scorr"s"' '"$dsize"'     ')  
		else
			 screen_buffer1+=$( printf '\n    '"%"$ncorr"s"$ch')   +   '"$ddrive""%"$ddcorr"s"'    '${string}"%"$corr"s""%"$scorr"s"' '"$dsize"'     ') 
		fi


                    if [[ ! $adrive = "±" ]]; then 
                    acorr=${#adrive}
		          if [[ ${acorr} -gt 30 ]]; then acorr=0; adrive="${adrive:0:30}"; else let "acorr=30-acorr"; fi

		      screen_buffer2+=$( printf '\n '"%"$ncorr"s"$ch') '"$drive""%"$dcorr"s""$adrive""%"$acorr"s""%"$corr"s"'  '${string:0:5} ) 
                    else
              screen_buffer2+=$( printf '\n '"%"$ncorr"s"$ch') '"$drive""%"$dcorr"s"'                              '"%"$corr"s"'  '${string:0:5} ) 
                   fi

    let "num++"
	let "var0--"
done
printf "\r\033[4A"


}

UPDATE_FULL_EFI(){
printf '\e[8;'${lines}';80t' && printf '\e[3J' && printf "\033[0;0H" 
                if [[ $loc = "ru" ]]; then
        printf '                             Настройка псевдонимов                              '
			else
        printf '                                 Aliases setup                                 '
	                 fi

if [[ $vid = 0 ]]; then

            if [[ $loc = "ru" ]]; then
	printf '\n   '
	printf '.%.0s' {1..74} 
	printf '                                                                               \n'
	printf '   0)  повторить поиск разделов     |<----------- 30 ----------->|*           \n' 	
		else
	printf '\n   '
	printf '.%.0s' {1..74} 
	printf '                                                                                \n'
	printf '   0)  update EFI partitions list   |<----------- 30 ----------->|*            \n' 
        fi


echo "$screen_buffer2"

printf '\n   '
	printf '.%.0s' {1..74}
printf '\n'
                    else

            if [[ $loc = "ru" ]]; then
	printf '\n     '
	printf '.%.0s' {1..68}
    printf ' ' 
    printf '                                                                               \n'
	printf '      0)  повторить поиск разделов                                     \n' 
		else
	printf '\n     '
	printf '.%.0s' {1..68} 
    printf '                                                                                \n'
	printf '      0)  update EFI partitions list                                           \n' 
        fi



echo "$screen_buffer1"

    printf '\n     '
	printf '.%.0s' {1..68}
    printf '    '
    printf '\n'

fi
                    if [[ $loc = "ru" ]]; then
        if [[ $vid = 0 ]]; then
        printf '            * Псевдоним не должен быть длиннее 30 символов                  \n\n'
                            else
        printf '                                                                            \n\n'
        fi
        printf '               С)    Сменить режим предпросмотра                               \n'
        printf '               V)    Посмотреть всю базу псевдонимов                           \n'
        printf '               D)    Удалить псевдоним                                         \n'
        printf '               R)    Удалить всю базу псевдонимов!                             \n'
        printf '               Q)    Вернуться в главное меню                                  \n\n' 

                    else
        if [[ $vid = 0 ]]; then
        printf '            *  Aliases should not be longer than 30 characters                  \n\n'
                    else
        printf '                                                                                \n\n'
        fi
        printf '               С)    Change the preview mode                                   \n'
        printf '               V)    View the entire alias database                            \n'
        printf '               D)    Delete an alias                                           \n'
        printf '               R)    Delete the entire alias database!                         \n'
        printf '               Q)    Quit to the main menu                                     \n\n' 

                    fi




}


GET_DRIVE(){ # inputs ->   nslist string slist dstring    drive ->

                        let "num=inputs-1"  
 
                        pnum=${nslist[num]}

	                    string=`echo ${slist[$pnum]}`
	                    dstring=`echo $string | rev | cut -f2-3 -d"s" | rev`
                        drive=`echo "$drives_iomedia" | grep -B 10 ${dstring} | grep  -m 1 -w "IOMedia"  | cut -f1 -d "<" | sed -e s'/-o //'  | sed -e s'/Media//' | sed 's/ *$//' | tr -d "\n"`
                        if [[ ${#drive} -gt 30 ]]; then drive=$( echo "$drive" | cut -f1-2 -d " " ); fi
}


DEL_RENAMEHD(){ # inputs slist ->
adrive="±"
strng=`echo "$MountEFIconf" | grep -A 1 "<key>RenamedHD</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
IFS=';'; rlist=($strng); unset IFS
rcount=${#rlist[@]}
if [[ ! $rcount = 0 ]]; then
         var=$rcount; posr=0; tlist=()
            while [[ ! $var = 0 ]]
         do
            rdrive=`echo "${rlist[$posr]}" | cut -f1 -d"="`
            if [[ ! "$rdrive" = "$drive" ]]; then tlist+=("${rlist[$posr]}"); fi
            let "var--"
            let "posr++"
         done
       rcount=${#tlist[@]} 
       var=$rcount; posr=0; unset strng
            while [[ ! $var = 0 ]]
         do
        strng+="${tlist[$posr]}"";"
        let "var--"
        let "posr++"
        done
        
        plutil -replace RenamedHD -string "$strng" ${HOME}/.MountEFIconf.plist; UPDATE_CACHE
        else
         plutil -replace RenamedHD -string "" ${HOME}/.MountEFIconf.plist; UPDATE_CACHE
fi  
}

ADD_RENAMEHD(){ # drive demo -> 
adrive="±"
strng=`echo "$MountEFIconf" | grep -A 1 "<key>RenamedHD</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
IFS=';'; rlist=($strng); unset IFS
rcount=${#rlist[@]}

if [[ ! $rcount = 0 ]]; then
        var=$rcount; posr=0; tlist=()
            while [[ ! $var = 0 ]]
         do
            rdrive=`echo "${rlist[$posr]}" | cut -f1 -d"="`
            if [[ ! "$rdrive" = "$drive" ]]; then tlist+=("${rlist[$posr]}"); fi
            let "var--"
            let "posr++"
         done

fi
        new_item="$drive""=""$demo"
        tlist+=("$new_item")
       rcount=${#tlist[@]} 
       var=$rcount; posr=0; unset strng
            while [[ ! $var = 0 ]]
         do
        strng+="${tlist[$posr]}"";"
        let "var--"
        let "posr++"
        done
 

        plutil -replace RenamedHD -string "$strng" ${HOME}/.MountEFIconf.plist; UPDATE_CACHE
}

EDIT_RENAMEHD(){ # adrive ->  |   demo ->
printf '\r  '"$drive"
if [[ ! $adrive = "±" ]]; then
if [[ $loc = "ru" ]]; then 
printf ':   псевдоним = '"$adrive"
else
printf ':   alias = '"$adrive"
fi
fi
if [[ $loc = "ru" ]]; then
if [[ $adrive = "±" ]]; then
printf '\n                     |------------------------------|' 
printf '\n  Введите псевдоним:  '
else
printf '\n                           |------------------------------|'
printf '\n  Введите новый псевдоним:  '
fi
else
if [[ $adrive = "±" ]]; then
printf '\n                     |------------------------------|' 
printf '\n  Enter alias:        '
else
printf '\n                           |------------------------------|'
printf '\n  Enter new alias:          '
fi
fi
printf "\033[?25h"
read -r demo  
printf "\033[?25l"
        if [[ ! $demo = "" ]]; then 
            if [[ ${#demo} -gt 30 ]]; then demo="${demo:0:30}"; fi
#Фильтр недопустимых символов ввода
demo=`echo "$demo" | tr -cd "[:print:]\n"`
demo=`echo "$demo" | tr -d "=;{}]><[&^$"`

         ADD_RENAMEHD

fi
}

########################### определение функции ввода по 2 байта #########################
READ_TWO_SYMBOLS(){

inputs1="±"; inputs="±";
while [[ $inputs1 = "±" ]]
do
printf '\n'
printf '                                                                                \n'
printf '                                                                                '
if [[ $loc = "ru" ]]; then
printf "\r\n\033[3A\033[55C"
else
printf "\r\n\033[3A\033[51C"
fi
IFS="±"; read   -n 1 -t 1  inputs1 ; unset IFS 
if [[ $inputs1 = "" ]]; then printf "\033[1A"; inputs1="±"; fi
if [[ $inputs1 = [0-9] ]]; then inputs=${inputs1}; break
            else
        if [[ ! $calls = 1 ]]; then
            if [[ $inputs1 = [rReEvVcCdDqQ] ]]; then inputs=${inputs1}; break; fi
                    else
             if [[ $inputs1 = [oOqQdDcCtT] ]]; then inputs=${inputs1}; break; fi
        fi
 
fi
 inputs1="±"


CHECK_HOTPLUG
if [[ $hotplug = 1 ]]; then break; fi
if [[ $calls = 0 ]]; then CHECK_HOTPLUG_PARTS; fi
done
if [[ ! $hotplug = 1 ]]; then 
    if [[ $inputs1 = [0-9] ]]; then
inputs1="±"
while [[ $inputs1 = "±" ]]
do
printf '\n'
printf '                                                                                \n'
printf '                                                                                '
if [[ $loc = "ru" ]]; then
printf "\r\n\033[3A\033[55C"
else
printf "\r\n\033[3A\033[51C"
fi
CHECK_HOTPLUG
if [[ $hotplug = 1 ]]; then break; fi
if [[ $calls = 0 ]]; then CHECK_HOTPLUG_PARTS; fi
IFS="±"; read  -n 1 -t 1  inputs1 ; unset IFS 
if [[ ! $inputs1 = [0-9] ]]; then 
        if [[ $inputs1 = "" ]]; then printf "\033[1A"; break
            else inputs1="±"; fi
    else
        if [[ $inputs = 0 ]]; then unset inputs; fi
        inputs+=${inputs1}
        
fi
done
    fi
fi
printf "\033[?25l"
if [[ $inputs = [0-9] ]]; then
let "chan=ch+1"
if [[ ${inputs} -ge ${chan} ]]; then inputs="0"; fi
fi
 
  }
########################################################################################


############################ функция псевдонимов ####################################################

SET_ALIASES(){
clear
GET_FULL_EFI
SHOW_FULL_EFI
vid=0
UPDATE_FULL_EFI
var8=0
while [ $var8 != 1 ] 
do

unset inputs
while [[ ! ${inputs} =~ ^[0-9rRvVcCdDqQ]+$ ]]; do 

SET_INPUT
                if [[ $loc = "ru" ]]; then
printf '  Выберите носитель от 1 до '$ch' (или 0, C, V, D, R, Q ):  '
			else
printf '  Select media from 1 to '$ch' (or 0, C, V, D, R, Q ):      '
                fi
printf "%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"
printf "\033[4A"
if [[ $loc = "ru" ]]; then
printf "\r\033[55C"
else
printf "\r\033[51C"
fi
printf "\033[?25h"

    inputs="±"
  if [[ ${ch} -le 9 ]]; then
    while [[ $inputs = "±" ]]
    do
    IFS="±"; read -n 1 -t 1 inputs ; unset IFS ; sym=1 ; CHECK_HOTPLUG ; CHECK_HOTPLUG_PARTS
    done
  else
    calls=0; READ_TWO_SYMBOLS
  fi  
    #IFS="±"; read -n 1 inputs ; unset IFS 
    if [[ ${inputs} = "" ]]; then inputs="p" ;printf "\033[1A"; fi
    printf "\r"
    done
 
    printf "\033[?25l"

if [[ $inputs = [cC] ]]; then 
    if [[ $vid = 0 ]]; then vid=1; else vid=0; fi
fi

if [[ $inputs = [qQ] ]]; then var8=1; fi


if [[ $inputs = [rR] ]]; then printf "\r\033[2A"
                        if [[ $loc = "ru" ]]; then
                
                printf '\n\n\033[33;5m Внимание !\033[0m'; printf '                                                          \n'
                printf ' Это удалит всю базу псевдонимов, не только видимые на экране \n'
                printf ' Отдельный псевдоним можно удалить выбрав диск с его номером \n'
                printf ' Подтвердите удаление всей базы (y/N) ? '
			else
                printf  '\n\n\033[33;5m Attention !\033[0m'; printf '                                                        \n'
                printf ' This action will remove the entire alias database. \n'
                printf ' Not just if the ones on the screen. \n'
                printf ' One alias can be deleted by selecting the disk with its number   \n'
                printf ' Confirm the deletion of the entire database (y/N)? '
                
                fi
                printf "\033[?25h"
                read  -n 1 -r
                printf "\033[?25l"
                if [[  $REPLY =~ ^[yY]$ ]]; then
                plutil -replace RenamedHD -string "" ${HOME}/.MountEFIconf.plist; UPDATE_CACHE
                inputs=0
                fi
                printf "\r\033[4A"
                if [[ $loc = "ru" ]]; then
                printf "%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"
                printf "\r\033[5A"
                else
                printf "%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"
                printf "\r\033[6A"
                fi
fi
                        

if [[ ${inputs} = [dD] ]]; then
                            printf "\r"; printf "%"80"s"
                            if [[ $loc = "ru" ]]; then
                        printf '\r  Удаление пседонима. (или просто "Enter" для отмены):\n\n'
                            else
                        printf '\r  Delete an alias. (or just "Enter" to cancel):\n\n'
                        fi
                        while [[ ! ${inputs} =~ ^[0-9] ]]; do
                        printf "%"80"s"
                        printf "\033[1A"
                        if [[ $loc = "ru" ]]; then
                        printf '   Выберите диск  ( 1 - '$ch' ): ' 
                            else
                        printf '   Choose media number  ( 1 - '$ch' ): '
                        fi
                        printf "\033[?25h" 
                        read  inputs
                        printf "\033[?25l" 
                        printf '\r';  printf "%"80"s"
                        if [[ $inputs = 0 ]]; then inputs="p"; fi &> /dev/null
                        if [[ $inputs -gt $ch ]]; then inputs="t"; fi &> /dev/null
                        if [[ ${inputs} = "" ]]; then inputs="p"; printf "\033[1A"; break; fi &> /dev/null
                        printf "\033[1A"
                        printf "\r"
                        done
                        if [[ ! ${inputs} = "p" ]]; then 
                        GET_DRIVE
                        DEL_RENAMEHD
                        fi
                        clear
    
                        inputs=0
fi

if [[ ${inputs} = [vV] ]]; then  
                        clear  && printf '\e[3J' && printf "\033[0;0H"
                        if [[ $loc = "ru" ]]; then
                        printf '                                База псевдонимов                            \n'
                        printf '\n   '
	                    printf '.%.0s' {1..74}
                        printf '\n                Носитель               |              Псевдоним           \n'
                        printf '   '
	                    printf '.%.0s' {1..74}
                        printf '\n'
			               else
                        printf '                                Aliases database                            \n'
                        printf '\n   '
	                    printf '.%.0s' {1..74}
                        printf '\n                  Media                |              Alias               \n'
                        printf '   '
	                    printf '.%.0s' {1..74}
                        printf '\n'
	                         fi

                        strng=`echo "$MountEFIconf" | grep -A 1 "<key>RenamedHD</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
                        IFS=';'; rlist=($strng); unset IFS
                        rcount=${#rlist[@]}
                        if [[ ! $rcount = 0 ]]; then
                        var11=$rcount; posr=0
                        while [[ ! $var11 = 0 ]]
                        do
                        echo
                        hdrive=`echo "${rlist[$posr]}" | cut -f1 -d"="`                       
                        sdrive=`echo "${rlist[$posr]}" | cut -f2 -d"="`
                        printf '\r\033[7C'"$hdrive"
                        printf '\r\033[44C'"$sdrive"
                        let "var11--"
                        let "posr++"
                        done
                        fi
read -n 1
clear
fi 

if [[ ! ${inputs} =~ ^[0vVdDrRqQcC]+$ ]]; then
                 if  [[ ${inputs} -le $ch ]]; then
                        printf "\r"; printf "%"80"s"
                            if [[ $loc = "ru" ]]; then
                        printf '\r  Редактирование псевдонима. (или просто "Enter" для отмены):\n\n'
                            else
                        printf '\r  Edit an alias. (or just "Enter" to cancel):\n\n'
                        fi
                        while [[ ! ${inputs} =~ ^[0-9] ]]; do
                        printf "%"80"s"
                        printf "\033[1A"
                        if [[ $loc = "ru" ]]; then
                        printf '   Выберите диск  ( 1 - '$ch' ): ' 
                            else
                        printf '   Choose media number  ( 1 - '$ch' ): '
                        fi
                        printf "\033[?25h" 
                        read  inputs
                        printf "\033[?25l" 
                        printf '\r';  printf "%"80"s"
                        if [[ $inputs = 0 ]]; then inputs="p"; fi &> /dev/null
                        if [[ $inputs -gt $ch ]]; then inputs="t"; fi &> /dev/null
                        if [[ ${inputs} = "" ]]; then inputs="p"; printf "\033[1A"; break; fi &> /dev/null
                        printf "\033[1A"
                        printf "\r"
                        done
                        if [[ ! ${inputs} = "p" ]]; then 
                        GET_DRIVE
                        GET_RENAMEHD
                        if [[ $adrive = "±" ]]; then  adrive="${drive}"; fi
                        if [[ $loc = "ru" ]]; then
                        if demo=$(osascript -e 'set T to text returned of (display dialog "< Редактировать псевдоним >|<- 30 знаков !" buttons {"Отменить", "OK"} default button "OK" default answer "'"${adrive}"'")'); then cancel=0; else cancel=1; fi 2>/dev/null
                        else
                        if demo=$(osascript -e 'set T to text returned of (display dialog "<-------- Edit aliases -------->|<- 30 characters !" buttons {"Отменить", "OK"} default button "OK" default answer "'"${adrive}"'")'); then cancel=0; else cancel=1; fi 2>/dev/null 
                        fi
                        if [[ $cancel = 0 ]]; then
                            if [[ ! "${demo}" = "${drive}" ]]; then
                        demo=$(echo "${demo}" | sed 's/^[ \t]*//')
                        if [[ ${#demo} -gt 30 ]]; then demo="${demo:0:30}"; fi
                        #Фильтр недопустимых символов ввода
                        demo=`echo "$demo" | tr -cd "[:print:]\n"`
                        demo=`echo "$demo" | tr -d "=;{}]><[&^$"`
                        if [[ ${#demo} = 0 ]]; then DEL_RENAMEHD
                        else
                        ADD_RENAMEHD
                        fi
                        fi
                        fi
                        fi
                        SHOW_FULL_EFI
                        unset inputs
                        
                fi

else

                        
                        
if [[ $inputs = 0 ]]; then GET_FULL_EFI; clear && printf '\e[3J' && printf "\033[0;0H"; SHOW_FULL_EFI
fi                
fi
UPDATE_FULL_EFI

done

unset slist
unset inputs

clear
}
############################## конец определения функции псевдонимов ##################################

############################## сервис автозапуска ##########################################################################

FILL_SYS_AUTOMOUNT_PLIST(){

echo '<?xml version="1.0" encoding="UTF-8"?>' >> ${HOME}/.MountEFIa.plist
echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' >> ${HOME}/.MountEFIa.plist
echo '<plist version="1.0">' >> ${HOME}/.MountEFIa.plist
echo '<dict>' >> ${HOME}/.MountEFIa.plist
echo '  <key>Label</key>' >> ${HOME}/.MountEFIa.plist
echo '  <string>MountEFIa.job</string>' >> ${HOME}/.MountEFIa.plist
echo '  <key>Nicer</key>' >> ${HOME}/.MountEFIa.plist
echo '  <integer>1</integer>' >> ${HOME}/.MountEFIa.plist
echo '  <key>ProgramArguments</key>' >> ${HOME}/.MountEFIa.plist
echo '  <array>' >> ${HOME}/.MountEFIa.plist
echo '      <string>/Users/user/.MountEFIa.sh</string>' >> ${HOME}/.MountEFIa.plist
echo '  </array>' >> ${HOME}/.MountEFIa.plist
echo '  <key>RunAtLoad</key>' >> ${HOME}/.MountEFIa.plist
echo '  <true/>' >> ${HOME}/.MountEFIa.plist
echo '</dict>' >> ${HOME}/.MountEFIa.plist
echo '</plist>' >> ${HOME}/.MountEFIa.plist
}

FILL_SYS_AUTOMOUNT_EXEC(){

echo '#!/bin/bash'  >> ${HOME}/.MountEFIa.sh
echo                >> ${HOME}/.MountEFIa.sh
echo 'DISPLAY_NOTIFICATION(){' >> ${HOME}/.MountEFIa.sh
echo 'COMMAND="display notification \"${MESSAGE}\" with title \"${TITLE}\" subtitle \"${SUBTITLE}\" sound name \"${SOUND}\""; osascript -e "${COMMAND}"' >> ${HOME}/.MountEFIa.sh
echo '}' >> ${HOME}/.MountEFIa.sh
echo                >> ${HOME}/.MountEFIa.sh
echo 'TITLE="MountEFI"' >> ${HOME}/.MountEFIa.sh
echo 'SOUND="Submarine"' >> ${HOME}/.MountEFIa.sh
echo 'if [[ ! -f ${HOME}/.MountEFIconf.plist ]]; then' >> ${HOME}/.MountEFIa.sh
echo 'loc=$(locale | grep LANG | sed -e '"'s/.*LANG="'"'"\(.*\)_.*/\1/'"')' >> ${HOME}/.MountEFIa.sh
echo 'if [[ $loc = "ru" ]]; then' >> ${HOME}/.MountEFIa.sh
echo 'SUBTITLE="ФАЙЛ КОНФИГУРАЦИИ НЕ НАЙДЕН !"; MESSAGE="Авто-монтирование EFI отменено"' >> ${HOME}/.MountEFIa.sh
echo 'else' >> ${HOME}/.MountEFIa.sh
echo 'SUBTITLE="CONFIGURATION FILE NOT FOUND"; MESSAGE="EFI auto-mount canceled"' >> ${HOME}/.MountEFIa.sh
echo 'fi' >> ${HOME}/.MountEFIa.sh
echo 'DISPLAY_NOTIFICATION' >> ${HOME}/.MountEFIa.sh
echo 'exit; fi' >> ${HOME}/.MountEFIa.sh
echo                >> ${HOME}/.MountEFIa.sh
echo 'UPDATE_CACHE(){' >> ${HOME}/.MountEFIa.sh
echo 'MountEFIconf=$( cat ${HOME}/.MountEFIconf.plist )' >> ${HOME}/.MountEFIa.sh
echo 'cache=1' >> ${HOME}/.MountEFIa.sh
echo '}' >> ${HOME}/.MountEFIa.sh
echo    >> ${HOME}/.MountEFIa.sh
echo 'UPDATE_CACHE' >> ${HOME}/.MountEFIa.sh
echo    >> ${HOME}/.MountEFIa.sh
echo 'SET_LOCALE(){' >> ${HOME}/.MountEFIa.sh
echo 'locale=`echo "$MountEFIconf" | grep -A 1 "Locale" | grep string | sed -e '"'s/.*>\(.*\)<.*/\1/'"' | tr -d '"'\n'"'`' >> ${HOME}/.MountEFIa.sh
echo 'if [[ $locale = "auto" ]]; then loc="ru"; else loc=$(echo ${locale}); fi' >> ${HOME}/.MountEFIa.sh
echo '}' >> ${HOME}/.MountEFIa.sh
echo   >> ${HOME}/.MountEFIa.sh
echo 'REM_ABSENT(){' >> ${HOME}/.MountEFIa.sh
echo
echo 'strng1=`echo "$MountEFIconf" | grep SysLoadAM -A 7 | grep -A 1 -e "PartUUIDs</key>"  | grep string | sed -e '"'s/.*>\(.*\)<.*/\1/'"' | tr -d '"'\\\n'"'`' >> ${HOME}/.MountEFIa.sh
echo '  alist=($strng1); apos=${#alist[@]}' >> ${HOME}/.MountEFIa.sh
echo '  if [[ ! $apos = 0 ]]' >> ${HOME}/.MountEFIa.sh
echo '	then' >> ${HOME}/.MountEFIa.sh
echo '		var8=$apos' >> ${HOME}/.MountEFIa.sh
echo '		posb=0' >> ${HOME}/.MountEFIa.sh
echo '		while [[ ! $var8 = 0 ]]' >> ${HOME}/.MountEFIa.sh
echo '					do' >> ${HOME}/.MountEFIa.sh
echo '                       check_uuid=`ioreg -c IOMedia -r | tr -d '"'"'"'"'"' | egrep "UUID" | grep -o ${alist[$posb]}`' >> ${HOME}/.MountEFIa.sh
echo '                       if [[ $check_uuid = "" ]]; then ' >> ${HOME}/.MountEFIa.sh
echo '                      strng2=`echo ${strng1[@]}  |  sed '"'s/'"'${alist[$posb]}'"'//'"'`' >> ${HOME}/.MountEFIa.sh
echo '						plutil -replace SysLoadAM.PartUUIDs -string "$strng2" ${HOME}/.MountEFIconf.plist' >> ${HOME}/.MountEFIa.sh
echo '						strng1=$strng2' >> ${HOME}/.MountEFIa.sh
echo '                        cache=0' >> ${HOME}/.MountEFIa.sh
echo '						fi' >> ${HOME}/.MountEFIa.sh
echo '					let "posb++"' >> ${HOME}/.MountEFIa.sh
echo '					let "var8--"' >> ${HOME}/.MountEFIa.sh
echo '					done' >> ${HOME}/.MountEFIa.sh
echo 'alist=($strng1); apos=${#alist[@]}' >> ${HOME}/.MountEFIa.sh
echo 'fi' >> ${HOME}/.MountEFIa.sh
echo 'if [[ $apos = 0 ]]; then plutil -replace SysLoadAM.Enabled -bool NO ${HOME}/.MountEFIconf.plist; am_enabled=0; cache=0; fi' >> ${HOME}/.MountEFIa.sh
echo '}' >> ${HOME}/.MountEFIa.sh
echo
echo 'am_enabled=0' >> ${HOME}/.MountEFIa.sh
echo 'strng3=`cat ${HOME}/.MountEFIconf.plist | grep SysLoadAM -A 3 | grep -A 1 -e "Enabled</key>" | grep true | tr -d "<>/"'"'\\\n\\\t'"'`' >> ${HOME}/.MountEFIa.sh
echo 'if [[ $strng3 = "true" ]]; then am_enabled=1' >> ${HOME}/.MountEFIa.sh
echo 'REM_ABSENT' >> ${HOME}/.MountEFIa.sh
echo 'if [[ $cache = 0 ]]; then UPDATE_CACHE; fi' >> ${HOME}/.MountEFIa.sh
echo 'fi' >> ${HOME}/.MountEFIa.sh
echo 'if [[ ! $am_enabled = 0 ]]; then' >> ${HOME}/.MountEFIa.sh
echo 'if [[ ! $apos = 0 ]]; then' >> ${HOME}/.MountEFIa.sh
echo 'macos=`sw_vers -productVersion`' >> ${HOME}/.MountEFIa.sh
echo 'macos=`echo ${macos//[^0-9]/}`' >> ${HOME}/.MountEFIa.sh
echo 'macos=${macos:0:4}' >> ${HOME}/.MountEFIa.sh
echo 'if [[ "$macos" = "1015" ]] || [[ "$macos" = "1014" ]] || [[ "$macos" = "1013" ]]; then flag=1; else flag=0; fi' >> ${HOME}/.MountEFIa.sh
echo >> ${HOME}/.MountEFIa.sh
echo 'mypassword="0"' >> ${HOME}/.MountEFIa.sh
echo 'if (security find-generic-password -a ${USER} -s efimounter -w) >/dev/null 2>&1; then' >> ${HOME}/.MountEFIa.sh
echo '                mypassword=$(security find-generic-password -a ${USER} -s efimounter -w)' >> ${HOME}/.MountEFIa.sh
echo '    fi' >> ${HOME}/.MountEFIa.sh
echo '' >> ${HOME}/.MountEFIa.sh
echo 'if [[ "$mypassword" = "0" ]]; then' >> ${HOME}/.MountEFIa.sh
echo '  if [[ $flag = 1 ]]; then ' >> ${HOME}/.MountEFIa.sh
echo '        SET_LOCALE' >> ${HOME}/.MountEFIa.sh
echo '        if [[ $loc = "ru" ]]; then' >> ${HOME}/.MountEFIa.sh
echo '        SUBTITLE="ПАРОЛЬ НЕ НАЙДЕН В СВЯЗКЕ КЛЮЧЕЙ !"; MESSAGE="Авто-монтирование EFI отменено"' >> ${HOME}/.MountEFIa.sh
echo '        else' >> ${HOME}/.MountEFIa.sh
echo '        SUBTITLE="PASSWORD NOT FOUND IN KEYCHAIN !"; MESSAGE="EFI auto-mount canceled"' >> ${HOME}/.MountEFIa.sh
echo '        fi' >> ${HOME}/.MountEFIa.sh
echo '        DISPLAY_NOTIFICATION' >> ${HOME}/.MountEFIa.sh
echo '        TRY=3' >> ${HOME}/.MountEFIa.sh
echo '        while [[ ! $TRY = 0 ]]; do' >> ${HOME}/.MountEFIa.sh
echo '        if [[ $loc = "ru" ]]; then' >> ${HOME}/.MountEFIa.sh
echo '        if PASSWORD=$(osascript -e '"'Tell application "'"System Events"'" to display dialog "'"       Введите пароль для подключения EFI разделов: "'" with hidden answer  default answer "'""'"'"' -e '"'text returned of result'"'); then cansel=0; else cansel=1; fi 2>/dev/null' >> ${HOME}/.MountEFIa.sh
echo '        else' >> ${HOME}/.MountEFIa.sh
echo '        if PASSWORD=$(osascript -e '"'Tell application "'"System Events"'" to display dialog "'"       Enter the password to mount the EFI partitions: "'" with hidden answer  default answer "'""'"'"' -e '"'text returned of result'"'); then cansel=0; else cansel=1; fi 2>/dev/null' >> ${HOME}/.MountEFIa.sh
echo '        fi' >> ${HOME}/.MountEFIa.sh
echo '                if [[ $cansel = 1 ]]; then break; fi ' >> ${HOME}/.MountEFIa.sh
echo '                mypassword=$PASSWORD' >> ${HOME}/.MountEFIa.sh
echo '                if [[ $mypassword = "" ]]; then mypassword="?"; fi' >> ${HOME}/.MountEFIa.sh
echo '                if echo $mypassword | sudo -Sk printf '"''"' 2>/dev/null; then' >> ${HOME}/.MountEFIa.sh
echo '                    security add-generic-password -a ${USER} -s efimounter -w ${mypassword} >/dev/null 2>&1' >> ${HOME}/.MountEFIa.sh
echo '                        if [[ $loc = "ru" ]]; then' >> ${HOME}/.MountEFIa.sh
echo '                        SUBTITLE="ПАРОЛЬ СОХРАНЁН В СВЯЗКЕ КЛЮЧЕЙ !"; MESSAGE="Авто-монтирование EFI работает"' >> ${HOME}/.MountEFIa.sh
echo '                        else' >> ${HOME}/.MountEFIa.sh
echo '                        SUBTITLE="PASSWORD KEEPED IN KEYCHAIN !"; MESSAGE="EFI auto-mount is now enabled"' >> ${HOME}/.MountEFIa.sh
echo '                        fi' >> ${HOME}/.MountEFIa.sh
echo '                        DISPLAY_NOTIFICATION' >> ${HOME}/.MountEFIa.sh
echo '                        break' >> ${HOME}/.MountEFIa.sh
echo '                else' >> ${HOME}/.MountEFIa.sh
echo '                        let "TRY--"' >> ${HOME}/.MountEFIa.sh
echo '                        if [[ ! $TRY = 0 ]]; then ' >> ${HOME}/.MountEFIa.sh
echo '                            if [[ $loc = "ru" ]]; then' >> ${HOME}/.MountEFIa.sh
echo '                        if [[ $TRY = 2 ]]; then ATTEMPT="ПОПЫТКИ"; LAST="ОСТАЛОСЬ"; fi' >> ${HOME}/.MountEFIa.sh
echo '                        if [[ $TRY = 1 ]]; then ATTEMPT="ПОПЫТКА"; LAST="ОСТАЛАСЬ"; fi' >> ${HOME}/.MountEFIa.sh
echo '                        SUBTITLE="НЕВЕРНЫЙ ПАРОЛЬ. ""$LAST"" ""$TRY"" ""$ATTEMPT"" !"; MESSAGE="Авто-монтирование EFI отменено"' >> ${HOME}/.MountEFIa.sh
echo '                            else' >> ${HOME}/.MountEFIa.sh
echo '                        if [[ $TRY = 2 ]]; then ATTEMPT="ATTEMPTS"; fi' >> ${HOME}/.MountEFIa.sh
echo '                        if [[ $TRY = 1 ]]; then ATTEMPT="ATTEMPT"; fi' >> ${HOME}/.MountEFIa.sh
echo '                        SUBTITLE="INCORRECT PASSWORD. LEFT ""$TRY"" ""$ATTEMPT"" !"; MESSAGE="EFI auto-mount canceled"' >> ${HOME}/.MountEFIa.sh
echo '                            fi' >> ${HOME}/.MountEFIa.sh
echo '                DISPLAY_NOTIFICATION' >> ${HOME}/.MountEFIa.sh
echo '                fi' >> ${HOME}/.MountEFIa.sh
echo '                fi' >> ${HOME}/.MountEFIa.sh
echo '            done' >> ${HOME}/.MountEFIa.sh
echo '            mypassword="0"' >> ${HOME}/.MountEFIa.sh
echo 'if (security find-generic-password -a ${USER} -s efimounter -w) >/dev/null 2>&1; then' >> ${HOME}/.MountEFIa.sh
echo '                mypassword=$(security find-generic-password -a ${USER} -s efimounter -w); ' >> ${HOME}/.MountEFIa.sh
echo 'fi' >> ${HOME}/.MountEFIa.sh
echo '            if [[ "$mypassword" = "0" ]]; then' >> ${HOME}/.MountEFIa.sh
echo '                    if [[ $loc = "ru" ]]; then' >> ${HOME}/.MountEFIa.sh
echo '                SUBTITLE="ПАРОЛЬ НЕ СОХРАНЁН !"; MESSAGE="Авто-монтирование EFI отменено"' >> ${HOME}/.MountEFIa.sh
echo '                    else' >> ${HOME}/.MountEFIa.sh
echo '                SUBTITLE="PASSWORD NOT KEEPED IN KEYCHAIN !"; MESSAGE="EFI auto-mount canceled"' >> ${HOME}/.MountEFIa.sh
echo '                    fi' >> ${HOME}/.MountEFIa.sh
echo '                DISPLAY_NOTIFICATION' >> ${HOME}/.MountEFIa.sh
echo '                strng=$(echo "$MountEFIconf" | grep -e "<key>SysLoadAM</key>" | grep key | sed -e '"'s/.*>\(.*\)<.*/\1/'"' | tr -d '"'\t\n'"')' >> ${HOME}/.MountEFIa.sh
echo '                if [[ $strng = "SysLoadAM" ]]; then' >> ${HOME}/.MountEFIa.sh
echo '                plutil -replace SysLoadAM.Enabled -bool NO ${HOME}/.MountEFIconf.plist' >> ${HOME}/.MountEFIa.sh
echo '                UPDATE_CACHE' >> ${HOME}/.MountEFIa.sh
echo '                fi' >> ${HOME}/.MountEFIa.sh
echo '            exit' >> ${HOME}/.MountEFIa.sh
echo '        fi' >> ${HOME}/.MountEFIa.sh
echo '    fi' >> ${HOME}/.MountEFIa.sh
echo 'fi' >> ${HOME}/.MountEFIa.sh
echo >> ${HOME}/.MountEFIa.sh
echo 'autom_open=0' >> ${HOME}/.MountEFIa.sh
echo 'strng3=`echo "$MountEFIconf" | grep SysLoadAM -A 5 | grep -A 1 -e "Open</key>" | grep true | tr -d "<>/"'"'\\\n\\\t'"'`' >> ${HOME}/.MountEFIa.sh
echo 'if [[ $strng3 = "true" ]]; then autom_open=1; fi' >> ${HOME}/.MountEFIa.sh
echo >> ${HOME}/.MountEFIa.sh
echo 'var9=$apos' >> ${HOME}/.MountEFIa.sh
echo 'posa=0' >> ${HOME}/.MountEFIa.sh
echo 'while [[ ! $var9 = 0 ]]' >> ${HOME}/.MountEFIa.sh
echo 'do' >> ${HOME}/.MountEFIa.sh
echo '	if [[ $flag = 1 ]]; then' >> ${HOME}/.MountEFIa.sh
echo '        if [[ ! $mypassword = "0" ]]; then' >> ${HOME}/.MountEFIa.sh
echo '               echo $mypassword | sudo -S diskutil quiet mount  ${alist[$posa]} >&- 2>&-' >> ${HOME}/.MountEFIa.sh
echo '                    else' >> ${HOME}/.MountEFIa.sh
echo '                       sudo printf '"' '"'' >> ${HOME}/.MountEFIa.sh
echo '                        sudo diskutil quiet mount  ${alist[$posa]} >&- 2>&-' >> ${HOME}/.MountEFIa.sh
echo '         fi' >> ${HOME}/.MountEFIa.sh
echo '		else' >> ${HOME}/.MountEFIa.sh
echo '			diskutil quiet mount  ${alist[$posa]} >&- 2>&-' >> ${HOME}/.MountEFIa.sh
echo 'fi' >> ${HOME}/.MountEFIa.sh
echo >> ${HOME}/.MountEFIa.sh
echo 'if  [[ $autom_open = 1 ]]; then ' >> ${HOME}/.MountEFIa.sh
echo '                string=`ioreg -c IOMedia -r  | egrep -A12 -B12 ${alist[$posa]} | grep -m 1 "BSD Name" | cut -f2 -d "=" | tr -d '"'"'"'" \\\n\\\t'"'`' >> ${HOME}/.MountEFIa.sh
echo '                vname=`df | egrep ${string} | sed '"'s#\(^/\)\(.*\)\(/Volumes.*\)#\1\3#'"' | cut -c 2-`' >> ${HOME}/.MountEFIa.sh
echo '				open "$vname"' >> ${HOME}/.MountEFIa.sh
echo 'fi' >> ${HOME}/.MountEFIa.sh
echo >> ${HOME}/.MountEFIa.sh
echo 'let "posa++"' >> ${HOME}/.MountEFIa.sh
echo 'let "var9--"' >> ${HOME}/.MountEFIa.sh
echo >> ${HOME}/.MountEFIa.sh
echo 'done' >> ${HOME}/.MountEFIa.sh
echo '	fi' >> ${HOME}/.MountEFIa.sh
echo 'fi' >> ${HOME}/.MountEFIa.sh
echo >> ${HOME}/.MountEFIa.sh
echo 'exit' >> ${HOME}/.MountEFIa.sh

chmod u+x ${HOME}/.MountEFIa.sh


}

REMOVE_SYS_AUTOMOUNT_SERVICE(){

if [[ $(launchctl list | grep "MountEFIa.job" | cut -f3 | grep -x "MountEFIa.job") ]]; then launchctl unload -w ~/Library/LaunchAgents/MountEFIa.plist; fi
if [[ -f ~/Library/LaunchAgents/MountEFIa.plist ]]; then rm ~/Library/LaunchAgents/MountEFIa.plist; fi
if [[ -f ~/.MountEFIa.sh ]]; then rm ~/.MountEFIa.sh; fi

}


SETUP_SYS_AUTOMOUNT(){
REMOVE_SYS_AUTOMOUNT_SERVICE
FILL_SYS_AUTOMOUNT_PLIST
FILL_SYS_AUTOMOUNT_EXEC
mv ${HOME}/.MountEFIa.plist ~/Library/LaunchAgents/MountEFIa.plist
plutil -remove ProgramArguments.0 ~/Library/LaunchAgents/MountEFIa.plist
plutil -insert ProgramArguments.0 -string "/Users/$(whoami)/.MountEFIa.sh" ~/Library/LaunchAgents/MountEFIa.plist
launchctl load -w ~/Library/LaunchAgents/MountEFIa.plist
if [[ $display = 1 ]]; then
    if [[ $loc = "ru" ]]; then
printf '\r  Сервис автоподключения EFI установлен ...'
    else
printf '\r  Serice automount EFI installed ... '
    fi
read -n 1 -s -t 2
fi
}


###############################################################################
################### MAIN ######################################################
###############################################################################
SET_INPUT
theme="system"
var4=0
while [ $var4 != 1 ] 
do
lines=29; col=80
printf '\e[8;'${lines}';'$col't' && printf '\e[3J' && printf "\033[H"
printf "\033[?25l"
UPDATE_SCREEN
GET_INPUT

# УСТАНОВКИ ПО УМОЛЧАНИЮ   #####################################################
if [[ $inputs = 0 ]]; then
                        if [[ $loc = "ru" ]]; then
                echo "Установить все значения по умолчанию?                    "
                        else
                echo "Set all default values?                                  "
                        fi
                read -p "(y/N) " -n 1 -r -s
                if [[ $REPLY =~ ^[yY]$ ]]; then
                MATCHING_BACKUPS
                if [[ $Now = 0 ]]; then CHECK_BUNZIP; ADD_BACKUP; UPDATE_ZIP
                    else
                        if [[ $matched = 0 ]]; then
                             GET_BACKUPS
                                if [[ $Maximum = 1 ]]; then 
                                        plutil -replace Backups.Maximum -integer 2 ${HOME}/.MountEFIconf.plist
                                        UPDATE_CACHE
                                 fi
                            CHECK_BUNZIP; ADD_BACKUP; UPDATE_ZIP
                        fi
                    
                   fi
if [[ -d ${HOME}/.MountEFIconfBackups ]]; then rm -R ${HOME}/.MountEFIconfBackups; fi
rm -f ${HOME}/.MountEFIconf.plist
 if [[ -f DefaultConf.plist ]]; then
            cp DefaultConf.plist ${HOME}/.MountEFIconf.plist
        else
             FILL_CONFIG
        fi
    fi
    UPDATE_CACHE
fi

# ВЫБОР ЛОКАЛИ ##################################################################
if [[ $inputs = 1 ]]; then 
    if [[ $locale = "ru" ]]; then locale="en"
        else
            if [[ $locale = "en" ]]; then locale="auto"
                else
                    if [[ $locale = "auto" ]]; then locale="ru"
                fi
        fi
    fi
  plutil -replace Locale -string $locale ${HOME}/.MountEFIconf.plist
  UPDATE_CACHE
fi
#############################################################################

# ПОКАЗ МЕНЮ ################################################################
if [[ $inputs = 2 ]]; then 
   if [[ $menue = 0 ]]; then menue="always"
        else
            menue="auto"
        fi
  plutil -replace Menue -string $menue ${HOME}/.MountEFIconf.plist
  UPDATE_CACHE
fi
##############################################################################

# ПАРОЛЬ ПОЛЬЗОВАТЕЛЯ #########################################################
if [[ $inputs = 3 ]]; then SET_USER_PASSWORD; fi
###############################################################################

# Открывать папку в Finder ###################################################
if [[ $inputs = 4 ]]; then 
   if [[ $OpenFinder = 1 ]]; then 
  plutil -replace OpenFinder -bool NO ${HOME}/.MountEFIconf.plist 
    UPDATE_CACHE
 else 
  plutil -replace OpenFinder -bool YES ${HOME}/.MountEFIconf.plist 
    UPDATE_CACHE
  fi
fi  
###############################################################################

# Установка темы ##############################################################
if [[ $inputs = 5 ]]; then 
    if [[ $theme = "built-in" ]]; then 
        plutil -replace Theme -string system ${HOME}/.MountEFIconf.plist
        UPDATE_CACHE
                printf '\n\n'
                    if [[ $loc = "ru" ]]; then
                echo "включена системная тема. выполните перезапуск программы" 
                printf 'нажмите любую клавишу для возврата в меню...'
                        else
                echo "set up system theme. restart required. "
                printf 'press any key return to menu ....'
                    fi
                read -n 1 demo
        else
          plutil -replace Theme -string built-in ${HOME}/.MountEFIconf.plist
          UPDATE_CACHE
    fi
fi 

#################################################################################
 if [[ $inputs = 6 ]]; then 
    if [[ $theme = "built-in" ]]; then plutil -replace Theme -string system ${HOME}/.MountEFIconf.plist; UPDATE_CACHE; fi
  SET_THEMES
fi
      

# Показывать подсказку по клавишам управления  ################################
if [[ $inputs = 7 ]]; then 
   if [[ $ShowKeys = 1 ]]; then 
  plutil -replace ShowKeys -bool NO ${HOME}/.MountEFIconf.plist
  UPDATE_CACHE
 else 
  plutil -replace ShowKeys -bool YES ${HOME}/.MountEFIconf.plist
  UPDATE_CACHE
  fi
fi  
###############################################################################

# Подключение разделов при запуске программы  ################################
if [[ $inputs = 8 ]]; then 
   if [[ $autom_enabled = 1 ]]; then 
  plutil -replace AutoMount.Enabled -bool NO ${HOME}/.MountEFIconf.plist
    UPDATE_CACHE
 else 
  SET_AUTOMOUNT
  fi
fi  
###############################################################################

GET_SYSTEM_FLAG(){
macos=`sw_vers -productVersion`
  macos=`echo ${macos//[^0-9]/}`
  macos=${macos:0:4}
  if [[ "$macos" = "1015" ]] || [[ "$macos" = "1014" ]] || [[ "$macos" = "1013" ]]; then flag=1; else flag=0; fi
}

# Подключение разделов при запуске системы  ################################
if [[ $inputs = 9 ]]; then 
   if [[ $sys_autom_enabled = 1 ]]; then 
  plutil -replace SysLoadAM.Enabled -bool NO ${HOME}/.MountEFIconf.plist
    UPDATE_CACHE
    REMOVE_SYS_AUTOMOUNT_SERVICE
    if [[ $loc = "ru" ]]; then
    printf '\n\n  Сервис автоподключения EFI остановлен ...'
    else
    printf '\n\n  Serice automount EFI stopped ... '
    fi
    read -n 1 -s -t 2

 else 
  display=1
  SET_SYS_AUTOMOUNT
  if [[ ! $apos = 0 ]]; then
  GET_SYSTEM_FLAG
  if [[ $flag = 0 ]]; then SETUP_SYS_AUTOMOUNT
    else
  CHECK_USER_PASSWORD
  if [[ "$mypassword" = "" ]]; then SET_USER_PASSWORD; fi
  CHECK_USER_PASSWORD
  if [[ "$mypassword" = "" ]]; then 
    plutil -replace SysLoadAM.Enabled -bool NO ${HOME}/.MountEFIconf.plist; 
    if [[ $loc = "ru" ]]; then
    printf '\n  Авто-подключение EFI отменено. Установите верный пароль '
    else
    printf '\n  EFI automounter disabled. You should enter a valid password  '
    fi
    read -n 1 -s -t 3
    else
        SETUP_SYS_AUTOMOUNT
  fi
  fi
  UPDATE_CACHE
  fi
  clear
  fi
fi  
###############################################################################



# создание псевдонимов имён дисков  ################################
if [[ $inputs = [aA] ]]; then 
  SET_ALIASES
fi
###############################################################################

# Искать загрузчики при подключении разделов  ################################
if [[ $inputs = [lL] ]]; then 
   if [[ $CheckLoaders = 1 ]]; then 
  plutil -replace CheckLoaders -bool NO ${HOME}/.MountEFIconf.plist
  UPDATE_CACHE
 else 
  plutil -replace CheckLoaders -bool YES ${HOME}/.MountEFIconf.plist
  UPDATE_CACHE
  fi
fi  
###############################################################################

if [[ $inputs = [cC] ]]; then 
if [[ $Autobackup = 1 ]]; then 
  plutil -replace Backups.Auto -bool NO ${HOME}/.MountEFIconf.plist 
 else 
  plutil -replace Backups.Auto -bool YES ${HOME}/.MountEFIconf.plist
  fi
 UPDATE_CACHE
fi

##############################################################################

if [[ $inputs = [vV] ]]; then SHOW_VERSION;  fi

########################################################################################################################
           
if [[ $inputs = [qQ] ]]; then 
    var4=1; printf '\n' 
            strng=`echo "$MountEFIconf" | grep Backups -A 3 | grep -A 1 -e "Auto</key>" | grep true | tr -d "<>/"'\n\t'`
     if [[ $strng = "true" ]]; then 
                     MATCHING_BACKUPS
                if [[ $Now = 0 ]]; then CHECK_BUNZIP; ADD_BACKUP; UPDATE_ZIP
                    else
                        if [[ $matched = 0 ]]; then
                             GET_BACKUPS
                                if [[ $Maximum = 1 ]]; then 
                                        plutil -replace Backups.Maximum -integer 2 ${HOME}/.MountEFIconf.plist
                                        UPDATE_CACHE
                                fi
                            CHECK_BUNZIP; ADD_BACKUP; UPDATE_ZIP
                        fi
                    
                  fi

          if [[ -d ${HOME}/.MountEFIconfBackups ]]; then rm -R ${HOME}/.MountEFIconfBackups; fi
       
        PUT_BACKUPS_IN_ICLOUD
    fi
fi
########################################################################################################################

if [[ $inputs = [dD] ]]; then
                    CHECK_ICLOUD_BACKUPS
         if [[ $cloud_archive = 1 ]] && [[ $shared_archive = 1 ]]; then
                        inputs="§"
                        if [[ $loc = "ru" ]]; then
                echo "Заместить локальный бэкап архивами из iCloud                       "
                echo "1) - Загрузить архив с этой машины. 2) -  Публичный архив          "
                        else
                echo "Replace the local backup with archives from iCloud?                "
                echo "1) - Download the archive from this machine. 2) - Public           "
                        fi
                printf "\033[?25h" 
                read -p "(1/2/N) " -n 1 -r
                printf "\033[?25l"  
                if [[ $REPLY = 1 ]] || [[ $REPLY = 2 ]]; then 
                if [[ $REPLY = 2 ]]; then get_shared=1; fi
                mv  ${HOME}/.MountEFIconfBackups.zip ${HOME}/.MountEFIconfBackups2.zip
                GET_BACKUPS_FROM_ICLOUD
                if [[ -f ${HOME}/.MountEFIconfBackups.zip ]]; then rm -f ${HOME}/.MountEFIconfBackups2.zip
                inputs="B"
                        else
                            mv  ${HOME}/.MountEFIconfBackups2.zip ${HOME}/.MountEFIconfBackups.zip
                printf "\r\033[1A"
                             if [[ $loc = "ru" ]]; then
                echo "Замещение не удалось. Локальный архив сохранён                     "
                printf '                    '
                        else
                echo "Replacement failed. Local archive saved                            "
                printf '                    '
                        fi
                read  -n 1 -s
                clear

                fi
            fi
       fi
 fi
                
########################################################################################################################

if [[ $inputs = [bB] ]]; then SET_BACKUPS; UPDATE_CACHE; fi

##############################################################################

########################################################################################################################

if [[ $inputs = [iI] ]]; then DOWNLOAD_CONFIG_FROM_FILE; 
    if [[ $errorep = 0 ]]; then UPDATE_CACHE; clear; fi
fi

##############################################################################

########################################################################################################################

if [[ $inputs = [eE] ]]; then UPLOAD_CONFIG_TO_FILE;  fi

##############################################################################

done

if [[ $par = "-r" ]]; then exit 1; else EXIT_PROG; fi

####################### END MAIN #################################################
###################################################################################
###################################################################################

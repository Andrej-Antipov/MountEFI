#!/bin/bash

#  Created by Андрей Антипов on 02.04.2020.#  Copyright © 2020 gosvamih. All rights reserved.

# https://github.com/Andrej-Antipov/MountEFI/releases
################################################################################## MountEFI SETUP ##########################################################################################################
s_prog_vers="1.7.0"
s_edit_vers="030"
############################################################################################################################################################################################################
# 004 - исправлены все определения пути для поддержки путей с пробелами
# 005 - добавлен быстрый доступ к настройкам авто-монтирования при входе в систему
# 006 - добавлено обновление версии программы с github через сеть
# 007 - в предпросмотр бэкапов архивов добавлены пункты меню
# 008 - пофиксены баги автозапуска 8 для старых ОС и баг обновления
# 009 - поддержка иконки в системных уведомлениях
# 010 - очистка истории zsh
# 011 - переделана функция SET_INPUT
# 012 - сохранение текущего конфига в iCloud
# 013 - пробелы в паролях
# 014 - несколько пробелов в середине пароля
# 015 - проверка последних версий Clover и OC
# 016 - работа с хэшами загрузчиков в конфиге
# 017 - фикс выхода из функции обновления в случае отмены обновления
# 018 - хэши других загрузчиков через конфиг
# 019 - загрузка хэшей других загрузчиков через список в файле
# 020 - сохранение базы хэшей в виде списка в файл
# 021 - список загрузчиков сохраняется после рестарта из программы
# 022 - проверка версии Clover и OpenCore не чаще раз в 10 минут
# 023 - новая функция авто-обновления
# 024 - изменён диалог пароля
# 025 - сделан деинсталлятор
# 026 - информация о времени след авто-обновления в окне контроля версии
# 027 - включение проверки авто-обновления сразу после выхода из настроек
# 028 - улучшенная версия информации о программе и загрузчика по клавише V
# 029 - исправлена ошибка в SET_INPUT: иногда не переключалась раскладка
# 030 - выбор папки документов при сохранении конфига в файл. 

clear

SHOW_VERSION(){
clear && printf "\e[3J" 
printf "\033[?25l"
var12=${lines}; while [[ ! $var12 = 0 ]]; do
printf '\e[40m %.0s\e[0m' {1..80}
let "var12--"; done
printf "\033[H"

show_mefi=0
if [[ -f ../../../MountEFI.app/Contents/Info.plist ]]; then 
edit_vers=$(cat MountEFI | grep -m1 "edit_vers=" | sed s'/edit_vers=//' | tr -d '" \n')
prog_vers=$(cat MountEFI | grep "prog_vers=" | sed s'/prog_vers=//' | tr -d '" \n')
show_mefi=1
fi

printf "\033[9;21f"
printf '\e[40m\e[1;33m________________________________________\e[0m''\n\033[20C'
printf '\e[40m\e[1;33m[                                      ]\e[0m''\n\033[20C'
printf '\e[40m\e[1;33m[                                      ]\e[0m''\n\033[20C'
printf '\e[40m\e[1;33m[                                      ]\e[0m''\n\033[20C'
printf '\e[40m\e[1;33m[                                      ]\e[0m''\n\033[20C'
if [[ $show_mefi = 1 ]]; then
printf '\e[40m\e[1;33m[                                      ]\e[0m''\n\033[20C'
printf '\e[40m\e[1;33m[                                      ]\e[0m''\n\033[20C'
fi
printf '\e[40m\e[1;33m[______________________________________]\e[0m''\n'
printf '\r\033[3A\033[29C' ; printf '\e[40m\e[1;35m  SETUP v. \e[1;33m'$s_prog_vers'.\e[1;32m '$s_edit_vers' \e[1;35m®\e[0m''\n'
if [[ $show_mefi = 1 ]]; then
printf '\r\033[3A\033[26C' ; printf '\e[40m\e[1;35m  MountEFI v. \e[1;33m'$prog_vers'.\e[1;32m '$edit_vers' \e[1;35m©\e[0m''\n' 
fi

v4corr=15

if [[ ${AutoUpdate} = 1 ]]; then
                    if [[ $loc = "ru" ]]; then
                        if [[ -f ~/Library/Application\ Support/MountEFI/AutoUpdateInfoTime.txt ]]; then
                        AutoUpdateCheckTime="$(date -r "$((86400+$(cat ~/Library/Application\ Support/MountEFI/AutoUpdateInfoTime.txt)))"  '+%d/%m/%Y %H:%M')"
                        else
                        AutoUpdateCheckTime="$(date '+%d/%m/%Y %H:%M')"
                        fi
                            printf "\033[26;'$v4corr'f"; printf '\e[40m\e[33m        Авто-обновление \e[35mMountEFI\e[33m включено! \e[0m'
                            printf "\033[27;'$v4corr'f"; printf '\e[40m\e[33m    Следующая проверка не ранее \e[32m'"${AutoUpdateCheckTime}"' \e[0m'
                    else
                        if [[ -f ~/Library/Application\ Support/MountEFI/AutoUpdateInfoTime.txt ]]; then
                        AutoUpdateCheckTime="$(date -r "$((86400+$(cat ~/Library/Application\ Support/MountEFI/AutoUpdateInfoTime.txt)))"  '+%m/%d/%Y %H:%M')"
                        else
                        AutoUpdateCheckTime="$(date '+%m/%d/%Y %H:%M')"
                        fi
                            printf "\033[26;'$v4corr'f"; printf '\e[40m\e[33m            Auto update \e[35mMountEFI\e[33m enabled! \e[0m'
                            printf "\033[27;'$v4corr'f"; printf '\e[40m\e[33m Next update check no earlier than \e[32m'"${AutoUpdateCheckTime}"' \e[0m'

                    fi
fi

GET_LOADERS
printf "\033[23;15f"; printf '\e[40m\e[33mhttps://github.com/Andrej-Antipov/MountEFI/releases \e[0m'
if [[ ! $CheckLoaders = 0 ]]; then 
    ppid=0
    while true; do 
            demo="~"; need_update=0
       if [[ $ppid = 0 ]] && [[ $(ps -xa -o pid,command | grep -v grep | grep curl | grep api.github.com | xargs | cut -f1 -d " " | wc -l | bc ) = 0 ]]; then   
            if [[ ! -f ~/Library/Application\ Support/MountEFI/updateLoadersVersionsNetTime.txt ]]; then
                need_update=1
            else 
                if [[ "$(($(date +%s)-$(head -1 ~/Library/Application\ Support/MountEFI/updateLoadersVersionsNetTime.txt)))" -lt "600" ]]; then
                clov_vrs=$(head -1 ~/Library/Application\ Support/MountEFI/latestClover.txt 2>/dev/null)
                oc_vrs=$(head -1 ~/Library/Application\ Support/MountEFI/latestOpenCore.txt 2>/dev/null)
                    if [[ ${#clov_vrs} -gt 4 ]]; then clov_vrs=""; fi
                    if [[ ${#oc_vrs} -gt 4 ]]; then oc_vrs=""; fi 
                    if [[ $clov_vrs = "" ]] && [[ $oc_vrs = "" ]]; then need_update=1
                            elif [[ $clov_vrs = "" ]]; then need_update=2
                                elif [[ $oc_vrs = "" ]]; then need_update=3
                    fi
                else 
                    need_update=1
                fi 2>/dev/null
            fi
        fi
        if [[ ! $need_update = 0 ]] && [[ $ppid = 0 ]]; then
                    case $need_update in
                        2)  NET_UPDATE_CLOVER &
                            ;;
                        3)  NET_UPDATE_OPENCORE &
                            ;;
                        *)  NET_UPDATE_LOADERS &
                            ;;
                    esac
                            ppid=$!
        fi        
    oc_vrs=$(head -1 ~/Library/Application\ Support/MountEFI/latestOpenCore.txt 2>/dev/null)
    if [[ ! ${oc_vrs} = "" ]]; then printf "\033[3;5f"'\e[40m\e[1;33m'"Latest OpenCore: "'\e[1;36m'${oc_vrs:0:1}"\e[1;32m.\e[1;36m"${oc_vrs:1:1}"\e[1;32m.\e[1;36m"${oc_vrs:2:1}'\e[0m'
                               else printf "\033[3;5f"'\e[40m                       \e[0m'
    fi
    clov_vrs=$(head -1 ~/Library/Application\ Support/MountEFI/latestClover.txt 2>/dev/null)
    if [[ ! ${clov_vrs} = "" ]]; then printf "\033[4;5f"'\e[40m\e[1;33m'"Latest Clover  :  "'\e[1;32m'${clov_vrs:0:4}'\e[0m'
                                 else printf "\033[4;5f"'\e[40m                       \e[0m'
    fi

    if [[ $(ps -xa -o pid,command | grep -v grep | grep curl | grep api.github.com | xargs | cut -f1 -d " " | wc -l | bc ) = 0 ]] && [[ $(ps -xa -o pid,command | grep -v grep | cut -f1 -d " " | grep -ow $ppid | xargs | cut -f1 -d " " | wc -l | bc ) = 0 ]]; then 
    ppid=0
    fi
    read -rsn1 -t2 demo; if [[ ! $demo = "~" ]]; then printf '\e[40m \e[0m'; KILL_CURL_UPDATER; if [[ ! $ppid = 0 ]]; then kill $ppid; wait $ppid ; fi; break; fi
   done 
fi       
clear && printf "\e[3J"
}

KILL_CURL_UPDATER(){
if [[ ! $(ps -xa -o pid,command | grep -v grep | grep curl | grep api.github.com | xargs | cut -f1 -d " " | wc -l | bc ) = 0 ]]; then 
    kill $(ps -xa -o pid,command | grep -v grep | grep curl | grep api.github.com | xargs | cut -f1 -d " "); fi
} 

NET_UPDATE_CLOVER(){
if ping -c 1 google.com >> /dev/null 2>&1; then
    clov_vrs=$( curl -s --max-time 9 https://api.github.com/repos/CloverHackyColor/CloverBootloader/releases/latest | grep browser_download_url | cut -d '"' -f 4 | rev | cut -d '/' -f1  | rev | grep pkg | grep -oE '[^_]+$' | sed 's/[^0-9]//g' | tr '\n' ' ' | cut -f1 -d ' ' )
    if [[ ! "${clov_vrs}" = "" ]] || [[ ${#clov_vrs} -le 4 ]]; then echo $clov_vrs > ~/Library/Application\ Support/MountEFI/latestClover.txt; fi
fi
}

NET_UPDATE_OPENCORE(){
if ping -c 1 google.com >> /dev/null 2>&1; then
    oc_vrs=$( curl -s --max-time 9 https://api.github.com/repos/acidanthera/OpenCorePkg/releases/latest | grep browser_download_url | cut -d '"' -f 4 | rev | cut -d '/' -f1  | rev | grep -m1 '[0-9]*' | egrep -o '[0-9]{1,4}' | tr -d '\n' )
    if [[ ! "${oc_vrs}" = "" ]] || [[ ${#oc_vrs} -le 4 ]]; then echo $oc_vrs > ~/Library/Application\ Support/MountEFI/latestOpenCore.txt; fi
fi
}

NET_UPDATE_LOADERS(){
 if ping -c 1 google.com >> /dev/null 2>&1; then
                if [[ -f ~/Library/Application\ Support/MountEFI/pdateLoadersVersionsNetTime.txt ]]; then rm -f ~/Library/Application\ Support/MountEFI/pdateLoadersVersionsNetTime.txt; fi
                if [[ -f ~/Library/Application\ Support/MountEFI/latestClover.txt ]]; then rm -f ~/Library/Application\ Support/MountEFI/latestClover.txt; fi
                if [[ -f ~/Library/Application\ Support/MountEFI/latestOpenCore.txt ]]; then rm -f ~/Library/Application\ Support/MountEFI/latestOpenCore.txt; fi
    clov_vrs=$( curl -s --max-time 9 https://api.github.com/repos/CloverHackyColor/CloverBootloader/releases/latest | grep browser_download_url | cut -d '"' -f 4 | rev | cut -d '/' -f1  | rev | grep pkg | grep -oE '[^_]+$' | sed 's/[^0-9]//g' | tr '\n' ' ' | cut -f1 -d ' ' )
    oc_vrs=$( curl -s --max-time 9 https://api.github.com/repos/acidanthera/OpenCorePkg/releases/latest | grep browser_download_url | cut -d '"' -f 4 | rev | cut -d '/' -f1  | rev | sed 's/[^0-9]//g' | grep -m1 '[0-9]*' )
    if [[ ! -d ~/Library/Application\ Support/MountEFI ]]; then mkdir -p ~/Library/Application\ Support/MountEFI; fi
        if [[ ! "${clov_vrs}" = "" ]] || [[ ! "${oc_vrs}" = "" ]]; then
            echo $clov_vrs > ~/Library/Application\ Support/MountEFI/latestClover.txt
            echo $oc_vrs > ~/Library/Application\ Support/MountEFI/latestOpenCore.txt
            date +%s > ~/Library/Application\ Support/MountEFI/updateLoadersVersionsNetTime.txt
        fi
fi
}

setup_count=$(ps -xa -o tty,pid,command|  grep "/bin/bash" | grep setup |  grep -v grep  | cut -f1 -d " " | sort -u | wc -l )

par="$1"
quick_am=0
if [[ "$par" = "-a" ]]; then par="-r"; quick_am=1; fi 

MyTTY1=`tty | tr -d " dev/\n"`
term=`ps`;  MyTTYc=`echo $term | grep -Eo $MyTTY1 | wc -l | tr - " \t\n"`

# Возвращает в переменной TTYcount 0 если наш терминал один
CHECK_TTY_C(){
term=`ps`
AllTTYc=`echo $term | grep -Eo ttys[0-9][0-9][0-9] | wc -l | tr - " \t\n"`
let "TTYc=AllTTYc-MyTTYc"
}

CLEAR_HISTORY(){
if [[ ! $par = "-r" ]]; then 
if [[ -f ~/.bash_history ]]; then cat  ~/.bash_history | sed -n '/MountEFI/!p' >> ~/new_hist.txt; rm -f ~/.bash_history; mv ~/new_hist.txt ~/.bash_history ; fi >/dev/null 2>/dev/null
if [[ -f ~/.zsh_history ]]; then cat  ~/.zsh_history | sed -n '/MountEFI/!p' >> ~/new_z_hist.txt; rm -f ~/.zsh_history; mv ~/new_z_hist.txt ~/.zsh_history ; fi >/dev/null 2>/dev/null
else
if [[ -f ~/.bash_history ]]; then cat  ~/.bash_history | sed -n '/setup/!p' >> ~/new_hist.txt; rm -f ~/.bash_history; mv ~/new_hist.txt ~/.bash_history ; fi >/dev/null 2>/dev/null
if [[ -f ~/.zsh_history ]]; then cat  ~/.zsh_history | sed -n '/setup/!p' >> ~/new_z_hist.txt; rm -f ~/.zsh_history; mv ~/new_z_hist.txt ~/.zsh_history ; fi >/dev/null 2>/dev/null
fi
}

# Выход из программы с проверкой - выгружать терминал из трея или нет
EXIT_PROG(){
CLEAR_HISTORY
CHECK_TTY_C	
if [[ ${TTYc} = 0  ]]; then osascript -e 'tell application "Terminal" to close first window' && osascript -e 'quit app "terminal.app"' & exit
	else
     osascript -e 'tell application "Terminal" to close first window' & exit
fi
}

if [ "${setup_count}" -gt "1" ]; then osascript -e 'tell application "Terminal" to activate'; EXIT_PROG; fi

##########################################################################################################################################

if [[ ! $par = "-r" ]]; then ROOT="$(dirname "$0")"; else ROOT="$2"; fi 
cd "${ROOT}"
if [[ ! -d ~/Library/LaunchAgents ]]; then mkdir ~/Library/LaunchAgents; fi

SET_LOCALE(){

if [[ $cache = 1 ]] ; then
        locale=`echo "$MountEFIconf" | grep -A 1 "Locale" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
        if [[ ! $locale = "ru" ]] && [[ ! $locale = "en" ]]; then loc=`defaults read -g AppleLocale | cut -d "_" -f1`
            else
                loc=`echo ${locale}`
        fi
    else   
        loc=`defaults read -g AppleLocale | cut -d "_" -f1`
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
pcount=$(echo "$MountEFIconf" | grep  -e "<key>BackgroundColor</key>" | wc -l | xargs)
}


GET_PRESETS_NAMES(){
pcount=$(echo "$MountEFIconf" | grep  -e "<key>BackgroundColor</key>" | wc -l | xargs)
N0=0; N1=2; N2=3; plist=()
for ((i=0; i<$pcount; i++)); do
plist+=( "$(echo "$MountEFIconf" | grep -A "$N1" Presets | awk '(NR == '$N2')' | sed -e 's/.*>\(.*\)<.*/\1/')" )
let "N1=N1+11"; let "N2=N2+11"; done
}

GET_THEME(){
theme=`echo "$MountEFIconf" |  grep -A 1 -e  "<key>Theme</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
theme_name=`echo "$MountEFIconf" |  grep -A 1 -e  "<key>ThemeProfile</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
if [[ "$theme_name" = "default" ]]; then theme_name=$(plutil -p /Users/$(whoami)/Library/Preferences/com.apple.Terminal.plist | grep "Default Window Settings" | tr -d '"' | cut -f2 -d '>' | xargs)
fi

nlenth=${#theme_name}
if [[ $loc = "ru" ]]; then
if [[ $theme = "built-in" ]]; then
let "theme_ncorr=37-nlenth"
else
let "theme_ncorr=34-nlenth"
fi
else
let "theme_ncorr=33-nlenth"
fi
        
itheme_set=`echo "$MountEFIconf" | grep -A 1 -e "<key>CurrentPreset</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
        
GET_PRESETS_COUNTS

tlenth=`echo ${#itheme_set}`
if [[ $loc = "ru" ]]; then
let "btheme_corr=26-tlenth"
btspc_corr=8
else
let "btheme_corr=25-tlenth"
fi
if [[ $pcount -lt 10 ]]; then let "btheme_corr++"; fi
}

DELETE_THEME_PRESET(){

plutil -remove Presets."$editing_preset" ${HOME}/.MountEFIconf.plist; UPDATE_CACHE
NN="B,"
current="$editing_preset"
strng=$(echo "$MountEFIconf"  | grep -A 1 -e "<key>ThemeLoadersLinks</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' )
IFS='{'; llist=($strng); unset IFS; lptr=${#llist[@]}
check=$(echo "${llist[@]}" | grep -ow "$NN""$current")
if [[ ! $check = "" ]]; then DEL_THEME_LOADERS; fi

}

ADD_THEME_PRESET(){

plutil -replace  Presets."$editing_preset" -xml  '<dict/>'   ${HOME}/.MountEFIconf.plist
plutil -replace  Presets."$editing_preset".BackgroundColor -string "$editing_BackgroundColor" ${HOME}/.MountEFIconf.plist
plutil -replace  Presets."$editing_preset".FontName -string "$editing_FontName" ${HOME}/.MountEFIconf.plist
plutil -replace  Presets."$editing_preset".FontSize -string "$editing_FontSize" ${HOME}/.MountEFIconf.plist
plutil -replace  Presets."$editing_preset".TextColor -string "$editing_TextColor" ${HOME}/.MountEFIconf.plist
UPDATE_CACHE

}

SET_THEMES(){
                theme=`echo "$MountEFIconf" |  grep -A 1 -e  "<key>Theme</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
          if [[ $theme = "built-in" ]]; then  
                GET_PRESETS_NAMES
                current=`echo "$MountEFIconf" | grep -A 1 -e "<key>CurrentPreset</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
                let "pmax=pcount-1"
                for ((i=0; i<$pcount; i++)) do if [[ "$current" = "${plist[$i]}" ]]; then break;  fi ; done           
         
                if [[ "${i}" -lt "${pmax}" ]]; then let "i++"; else i=0; fi
                plutil -replace CurrentPreset -string "${plist[$i]}" ${HOME}/.MountEFIconf.plist ; UPDATE_CACHE
           else
                osascript -e 'tell application "Terminal" to  set current settings of window 1 to settings set "Basic"'
                plutil -replace Theme -string built-in ${HOME}/.MountEFIconf.plist; UPDATE_CACHE
           fi
                #CUSTOM_SET &
 }



GET_DATA_OF_PRESET_NUMBER(){
i=$1
let "base=(i*11)+2"; let "N1=base+3"; let "N2=base+4"
current_background=$(echo "$MountEFIconf" | grep -A "$N1" Presets | awk '(NR == '$N2')' | sed -e 's/.*>\(.*\)<.*/\1/')
let "N1=N1+2"; let "N2=N2+2"
current_fontname=$(echo "$MountEFIconf" | grep -A "$N1" Presets | awk '(NR == '$N2')' | sed -e 's/.*>\(.*\)<.*/\1/')
let "N1=N1+2"; let "N2=N2+2"
current_fontsize=$(echo "$MountEFIconf" | grep -A "$N1" Presets | awk '(NR == '$N2')' | sed -e 's/.*>\(.*\)<.*/\1/')
let "N1=N1+2"; let "N2=N2+2"
current_foreground=$(echo "$MountEFIconf" | grep -A "$N1" Presets | awk '(NR == '$N2')' | sed -e 's/.*>\(.*\)<.*/\1/')

}

GET_CURRENT_SET(){

GET_PRESETS_NAMES
current=`echo "$MountEFIconf" | grep -A 1 -e "<key>CurrentPreset</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
for ((i=0; i<$pcount; i++)); do if [[ "${plist[i]}" = "$current" ]]; then break; fi; done
GET_DATA_OF_PRESET_NUMBER $i

}

CORRECT_CURRENT_PRESET(){
GET_PRESETS_NAMES
current=`echo "$MountEFIconf" | grep -A 1 -e "<key>CurrentPreset</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
pnow=$(echo "${plist[@]}" | grep -o "$current")
if [[ ! "$pnow" =  "$current" ]]; then
   plutil -replace CurrentPreset -string "${plist[0]}" ${HOME}/.MountEFIconf.plist ; UPDATE_CACHE
fi 
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
            echo '  <integer>10</integer>' >> ${HOME}/.MountEFIconf.plist
            echo '	</dict>' >> ${HOME}/.MountEFIconf.plist
            echo '	<key>Backups</key>' >> ${HOME}/.MountEFIconf.plist
            echo '	<dict>' >> ${HOME}/.MountEFIconf.plist
            echo '  <key>Auto</key>' >> ${HOME}/.MountEFIconf.plist
            echo '  <true/>' >> ${HOME}/.MountEFIconf.plist
            echo '  <key>Maximum</key>' >> ${HOME}/.MountEFIconf.plist
            echo '  <integer>20</integer>' >> ${HOME}/.MountEFIconf.plist
            echo '	</dict>' >> ${HOME}/.MountEFIconf.plist
            echo '          <key>CheckLoaders</key>' >> ${HOME}/.MountEFIconf.plist
            echo '          <true/>' >> ${HOME}/.MountEFIconf.plist
            echo '          <key>CurrentPreset</key>' >> ${HOME}/.MountEFIconf.plist
            echo '          <string>BlueSky</string>' >> ${HOME}/.MountEFIconf.plist
            echo '          <key>Locale</key>' >> ${HOME}/.MountEFIconf.plist
            echo '          <string>auto</string>' >> ${HOME}/.MountEFIconf.plist
            echo '          <key>always</key>' >> ${HOME}/.MountEFIconf.plist
            echo '          <string>auto</string>' >> ${HOME}/.MountEFIconf.plist
            echo '          <key>OpenFinder</key>' >> ${HOME}/.MountEFIconf.plist
            echo '          <true/>' >> ${HOME}/.MountEFIconf.plist
            echo '          <key>Presets</key>' >> ${HOME}/.MountEFIconf.plist
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
	        echo '           <key>Enabled</key>' >> ${HOME}/.MountEFIconf.plist
	        echo '           <false/>' >> ${HOME}/.MountEFIconf.plist
	        echo '           <key>Open</key>' >> ${HOME}/.MountEFIconf.plist
	        echo '           <false/>' >> ${HOME}/.MountEFIconf.plist
	        echo '           <key>PartUUIDs</key>' >> ${HOME}/.MountEFIconf.plist
	        echo '           <string> </string>' >> ${HOME}/.MountEFIconf.plist
            echo '  </dict>' >> ${HOME}/.MountEFIconf.plist
            echo '  <key>Theme</key>' >> ${HOME}/.MountEFIconf.plist
            echo '  <string>built-in</string>' >> ${HOME}/.MountEFIconf.plist
            echo '  <key>ThemeLoaders</key>' >> ${HOME}/.MountEFIconf.plist
            echo '  <string>37</string>' >> ${HOME}/.MountEFIconf.plist
            echo '  <key>ThemeLoadersLinks</key>' >> ${HOME}/.MountEFIconf.plist
            echo '  <string> </string>' >> ${HOME}/.MountEFIconf.plist
            echo '  <key>ThemeLoadersNames</key>' >> ${HOME}/.MountEFIconf.plist
            echo '  <string>Clover;OpenCore</string>' >> ${HOME}/.MountEFIconf.plist
            echo '  <key>ThemeProfile</key>' >> ${HOME}/.MountEFIconf.plist
            echo '  <string>default</string>' >> ${HOME}/.MountEFIconf.plist
            echo '  <key>UpdateSelfAuto</key>' >> ${HOME}/.MountEFIconf.plist
            echo '  <true/>' >> ${HOME}/.MountEFIconf.plist
            echo '	<key>XHashes</key>' >> ${HOME}/.MountEFIconf.plist
	        echo '	<dict>' >> ${HOME}/.MountEFIconf.plist
	        echo '           <key>CLOVER_HASHES</key>' >> ${HOME}/.MountEFIconf.plist
	        echo '           <string></string>' >> ${HOME}/.MountEFIconf.plist
	        echo '           <key>OC_DEV_HASHES</key>' >> ${HOME}/.MountEFIconf.plist
	        echo '           <string></string>' >> ${HOME}/.MountEFIconf.plist
	        echo '           <key>OC_REL_HASHES</key>' >> ${HOME}/.MountEFIconf.plist
	        echo '           <string></string>' >> ${HOME}/.MountEFIconf.plist
	        echo '           <key>OTHER_HASHES</key>' >> ${HOME}/.MountEFIconf.plist
	        echo '           <string></string>' >> ${HOME}/.MountEFIconf.plist
            echo '  </dict>' >> ${HOME}/.MountEFIconf.plist
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

reload_check=`echo "$MountEFIconf"| grep -o "Reload"`
if [[ $reload_check = "Reload" ]]; then
        if [[ $(launchctl list | grep "MountEFIr.job" | cut -f3 | grep -x "MountEFIr.job") ]]; then 
                launchctl unload -w ~/Library/LaunchAgents/MountEFIr.plist; fi
        if [[ -f ~/Library/LaunchAgents/MountEFIr.plist ]]; then rm ~/Library/LaunchAgents/MountEFIr.plist; fi
        if [[ -f ~/.MountEFIr.sh ]]; then rm ~/.MountEFIr.sh; fi
        plutil -remove Reload ${HOME}/.MountEFIconf.plist; UPDATE_CACHE
fi


login=`echo "$MountEFIconf" | grep -Eo "LoginPassword"  | tr -d '\n'`
if [[ $login = "LoginPassword" ]]; then
        mypassword="$( echo "$MountEFIconf" | grep -A 1 "LoginPassword" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n' )"
        if [[ ! $mypassword = "" ]]; then
            if ! (security find-generic-password -a ${USER} -s efimounter -w) >/dev/null 2>&1; then
                security add-generic-password -a ${USER} -s efimounter -w "${mypassword}" >/dev/null 2>&1
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

strng=`echo "$MountEFIconf" | grep -e "<key>ThemeLoaders</key>" |  sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\t\n'`
if [[ ! $strng = "ThemeLoaders" ]]; then
            plutil -insert ThemeLoaders -string "37" ${HOME}/.MountEFIconf.plist
            cache=0
fi

strng=`echo "$MountEFIconf" | grep -e "<key>ThemeLoadersLinks</key>" |  sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\t\n'`
if [[ ! $strng = "ThemeLoadersLinks" ]]; then
            plutil -insert ThemeLoadersLinks -string " " ${HOME}/.MountEFIconf.plist
            cache=0
fi

strng=`echo "$MountEFIconf" | grep -e "<key>ThemeLoadersNames</key>" |  sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\t\n'`
if [[ ! $strng = "ThemeLoadersNames" ]]; then
            plutil -insert ThemeLoadersNames -string "Clover;OpenCore" ${HOME}/.MountEFIconf.plist
            cache=0
fi

strng=`echo "$MountEFIconf" | grep -e "<key>ThemeProfile</key>" |  sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\t\n'`
if [[ ! $strng = "ThemeProfile" ]]; then
            plutil -insert ThemeProfile -string "default" ${HOME}/.MountEFIconf.plist
            cache=0
fi

strng=`echo "$MountEFIconf"| grep -e "<key>UpdateSelfAuto</key>" | grep key | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\t\n'`
if [[ ! $strng = "UpdateSelfAuto" ]]; then plutil -replace UpdateSelfAuto -bool YES ${HOME}/.MountEFIconf.plist; cache=0; fi

strng=`echo "$MountEFIconf" | grep -e "<key>XHashes</key>" | grep key | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\t\n'`
if [[ ! $strng = "XHashes" ]]; then 
			plutil -insert XHashes -xml  '<dict/>'   ${HOME}/.MountEFIconf.plist
			plutil -insert XHashes.CLOVER_HASHES -string "" ${HOME}/.MountEFIconf.plist
			plutil -insert XHashes.OC_DEV_HASHES -string "" ${HOME}/.MountEFIconf.plist
            plutil -insert XHashes.OC_REL_HASHES -string "" ${HOME}/.MountEFIconf.plist
            plutil -insert XHashes.OTHER_HASHES -string "" ${HOME}/.MountEFIconf.plist
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

CHECK_AUTOUPDATE(){
AutoUpdate=1
strng=`echo "$MountEFIconf"  | grep -A 1 -e "UpdateSelfAuto</key>" | grep false | tr -d "<>/"'\n\t'`
if [[ $strng = "false" ]]; then AutoUpdate=0; fi
}

DISABLE_AUTOUPDATE(){
if [[ ! $(ps -xa -o pid,command | grep -v grep | grep curl | grep MountEFI | xargs | cut -f1 -d " " | wc -l | bc ) = 0 ]]; then 
    kill $(ps -xa -o pid,command | grep -v grep | grep curl | grep MountEFI | xargs | cut -f1 -d " "); fi
if [[ -d ~/.MountEFIupdates ]]; then rm -Rf ~/.MountEFIupdates; fi
               if [[ $(launchctl list | grep "MountEFIu.job" | cut -f3 | grep -x "MountEFIu.job") ]]; then 
               launchctl unload -w ~/Library/LaunchAgents/MountEFIu.plist; fi
               if [[ -f ~/Library/LaunchAgents/MountEFIu.plist ]]; then rm ~/Library/LaunchAgents/MountEFIu.plist; fi
               if [[ -f ~/.MountEFIu.sh ]]; then rm ~/.MountEFIu.sh; fi
               plutil -replace UpdateSelfAuto -bool No ${HOME}/.MountEFIconf.plist
               plutil -remove Updating ${HOME}/.MountEFIconf.plist >>/dev/null 
               UPDATE_CACHE
               if [[ -f ~/Library/Application\ Support/MountEFI/AutoupdatesInfo.txt ]]; then
                    autoupdate_string=$( cat ~/Library/Application\ Support/MountEFI/AutoupdatesInfo.txt | tr '\n' ';' ); IFS=';' autoupdate_list=(${autoupdate_string}); unset IFS
                    rm -f ~/Library/Application\ Support/MountEFI/AutoUpdateInfoTime.txt; rm -f ~/Library/Application\ Support/MountEFI/AutoupdatesInfo.txt
                    rm -f ~/Library/Application\ Support/MountEFI/${autoupdate_list[1]}".zip"
               fi
}

GET_AUTOUPDATE(){
        CHECK_AUTOUPDATE
if [[ ${AutoUpdate} = 0 ]]; then    
            if [[ $loc = "ru" ]]; then
        AutoUpdate_set="Нет"; aus_corr=21
            else
        AutoUpdate_set="No"; aus_corr=20
            fi
    else
            if [[ $loc = "ru" ]]; then
        AutoUpdate_set="Да"; aus_corr=22
            else
        AutoUpdate_set="Yes"; aus_corr=19
            fi
fi
}

GET_APP_ICON(){
icon_string=""
if [[ -f AppIcon.icns ]]; then 
   icon_string=' with icon file "'"$(echo "$(diskutil info $(df / | tail -1 | cut -d' ' -f 1 ) |  grep "Volume Name:" | cut -d':'  -f 2 | xargs)")"''"$(echo "${ROOT}" | tr "/" ":" | xargs)"':AppIcon.icns"'
fi 
}

SET_TITLE(){
echo '#!/bin/bash'  >> ${HOME}/.MountEFInoty.sh
echo '' >> ${HOME}/.MountEFInoty.sh
echo 'TITLE="MountEFI"' >> ${HOME}/.MountEFInoty.sh
echo 'SOUND="Submarine"' >> ${HOME}/.MountEFInoty.sh
}

DISPLAY_NOTIFICATION(){
if [[ -d terminal-notifier.app ]]; then
echo ''"'$(echo "$ROOT")'"'/terminal-notifier.app/Contents/MacOS/terminal-notifier -title "MountEFI" -sound Submarine -subtitle "${SUBTITLE}" -message "${MESSAGE}"'  >> ${HOME}/.MountEFInoty.sh
sleep 1
else
echo 'COMMAND="display notification \"${MESSAGE}\" with title \"${TITLE}\" subtitle \"${SUBTITLE}\" sound name \"${SOUND}\""; osascript -e "${COMMAND}"' >> ${HOME}/.MountEFInoty.sh
fi
echo ' exit' >> ${HOME}/.MountEFInoty.sh
chmod u+x ${HOME}/.MountEFInoty.sh
sh ${HOME}/.MountEFInoty.sh
rm ${HOME}/.MountEFInoty.sh
}

ENTER_PASSWORD(){


TRY=3
        while [[ ! $TRY = 0 ]]; do
        GET_APP_ICON
        if [[ $loc = "ru" ]]; then
        if PASSWORD="$(osascript -e 'Tell application "System Events" to display dialog "Для подключения EFI разделов нужен пароль!\nОн будет храниться в вашей связке ключей\n\nПользователь:  '"$(id -F)"'\nВведите ваш пароль:" '"${icon_string}"' giving up after (110) with hidden answer  default answer ""' -e 'text returned of result')"; then cansel=0; else cansel=1; fi 2>/dev/null
        else
        if PASSWORD="$(osascript -e 'Tell application "System Events" to display dialog "Password is required to mount EFI partitions!\nIt will be keeped in your keychain\n\nUser Name:  '"$(id -F)"'\nEnter your password:" '"${icon_string}"' giving up after (110) with hidden answer  default answer ""' -e 'text returned of result')"; then cansel=0; else cansel=1; fi 2>/dev/null
        fi      
                if [[ $cansel = 1 ]] || [[ "${PASSWORD}" = "" ]]; then break; fi  
                mypassword="${PASSWORD}"
                if [[ $mypassword = "" ]]; then mypassword="?"; fi

                if echo "${mypassword}" | sudo -Sk printf '' 2>/dev/null; then
                    security add-generic-password -a ${USER} -s efimounter -w "${mypassword}" >/dev/null 2>&1
                        SET_TITLE
                        if [[ $loc = "ru" ]]; then
                        echo 'SUBTITLE="ПАРОЛЬ СОХРАНЁН В СВЯЗКЕ КЛЮЧЕЙ !"; MESSAGE=""' >> ${HOME}/.MountEFInoty.sh
                        else
                        echo 'SUBTITLE="PASSWORD KEEPED IN KEYCHAIN !"; MESSAGE=""' >> ${HOME}/.MountEFInoty.sh
                        fi
                        DISPLAY_NOTIFICATION
                        break
                else
                        printf "\r\033[1A                                                                      \r"
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
                                GET_APP_ICON
                                if [[ $loc = "ru" ]]; then
                                if answer=$(osascript -e 'display dialog "Удалить пароль из связки ключей?" '"${icon_string}"''); then cancel=0; else cancel=1; fi 2>/dev/null
                                else
                                if answer=$(osascript -e 'display dialog "Remove password from keychain?" '"${icon_string}"''); then cancel=0; else cancel=1; fi 2>/dev/null
                                fi
                               
                                if [[ $cancel = 0 ]]; then 
                security delete-generic-password -a ${USER} -s efimounter >/dev/null 2>&1
                SET_TITLE
                        if [[ $loc = "ru" ]]; then
                        echo 'SUBTITLE="ПАРОЛЬ УДАЛЁН ИЗ СВЯЗКИ КЛЮЧЕЙ !"; MESSAGE=""' >> ${HOME}/.MountEFInoty.sh
                        else
                        echo 'SUBTITLE="PASSWORD REMOVED FROM KEYCHAIN !"; MESSAGE=""' >> ${HOME}/.MountEFInoty.sh
                        fi
                        DISPLAY_NOTIFICATION
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
                passl=${#mypassword}
                mypassword_set=$( echo "${mypassword}" | tr -c '\n' "*")
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

SET_INPUT(){

if [[ -f ~/Library/Preferences/com.apple.HIToolbox.plist ]]; then
    declare -a layouts_names
    layouts=$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleInputSourceHistory | egrep -w 'KeyboardLayout Name' | sed -E 's/.+ = "?([^"]+)"?;/\1/' | tr  '\n' ';')
    IFS=";"; layouts_names=($layouts); unset IFS; num=${#layouts_names[@]}

    for i in ${!layouts_names[@]}; do
        case ${layouts_names[i]} in
    "ABC"                ) keyboard=${layouts_names[i]}; break ;;
    "US Extended"        ) keyboard="USExtended"; break ;;
    "USInternational-PC" ) keyboard=${layouts_names[i]}; break ;;
    "U.S."               ) keyboard="US"; break ;;
    "British"            ) keyboard=${layouts_names[i]}; break ;;
    "British-PC"         ) keyboard=${layouts_names[i]}; break ;;
                        *) keyboard="0";;
    esac 
    done

        if [[ ! $keyboard = "0" ]] && [[ -f "${ROOT}/xkbswitch" ]]; then "${ROOT}"/xkbswitch -se $keyboard; fi
            
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
printf q'\n'

}

SHOW_BACKUPS(){

Now=$(ls -l ${HOME}/.MountEFIconfBackups | grep ^d | wc -l | tr -d " \t\n")
if [[ $Now -lt 5 ]]; then lncorr=0; else let "lncorr=Now-9"; fi
let "lines2=lines+lncorr+2"
if [[ "$1" = "double" ]]; then GET_MAX_BACKUPS_LINES; if [[ "${b_lines}" -gt "${lines2}" ]]; then lines2=${b_lines}; fi; fi
if [[ "$1" = "double" ]]; then MM=160; else MM=80; fi
clear && printf '\e[8;'${lines2}';'$MM't' && printf '\e[3J' && printf "\033[0;0H" 
                            if [[ $loc = "ru" ]]; then
                         bbuf+=$(printf '\033[1;0f''                      Настройка бэкапов и восстановление                        ')
			                else
                         bbuf+=$(printf '\033[1;0f''                         Backup and restore settings                            ')
	                        fi
                        bbuf+=$(printf '\033[2;0f''   ')
	                    bbuf+=$(printf '.%.0s' {1..74})

                           if [[ $loc = "ru" ]]; then
                        bbuf+=$(printf '\033[3;0f''                                Имеются бэкапы:                                 ')
                        bbuf+=$(printf '\033[4;0f''     ')
	                    bbuf+=$(printf '.%.0s' {1..34})
                        
                        bbuf+=$(printf '\033[4;35f''   ')
	                    bbuf+=$(printf '.%.0s' {1..34})
			               else
                        bbuf+=$(printf '\033[3;0f''                                Backups database                            ')
                        bbuf+=$(printf '\033[4;0f''     ')
	                    bbuf+=$(printf '.%.0s' {1..34})
                        
                        bbuf+=$(printf '\033[4;35f''   ')
	                    bbuf+=$(printf '.%.0s' {1..34})
                            fi
                        
GET_BACKUPS
if [[ ! $Now = 0 ]]; then
var6=$Maximum; chn=1; bb=6
if [[ $Now -lt $Maximum ]]; then var6=$Now; fi
while [[ ! $var6 = 0 ]] 
do
if [[ -d ${HOME}/.MountEFIconfBackups/$chn ]]; then
        backtime=$(stat -f %m $F ${HOME}/.MountEFIconfBackups/$chn/.MountEFIconf.plist)
            if [[ $chn -le 9 ]]; then
            bbuf+=$(printf '\033['$bb';0f''               '$chn')    ')
            else
            bbuf+=$(printf '\033['$bb';0f''              '$chn')    ')
            fi
            bbuf+=$(date -r "$backtime")
            
fi
let "chn++"; let "bb++"; let "var6--"
done
let "chn--"
fi
let "bb++"

                       bbuf+=$(printf '\033['$bb';0f''   ')
	                   bbuf+=$(printf '.%.0s' {1..74})
let "bb++"
if [[ ! "$1" = "double" ]]; then
                if [[ $loc = "ru" ]]; then

let "bb++"; bbuf+=$(printf '\033['$bb';0f''                  S)  Сохранить текущие настройки в архив       ')
let "bb++"; bbuf+=$(printf '\033['$bb';0f''                  V)  Предпросмотр данных в архивах             ')
let "bb++"; bbuf+=$(printf '\033['$bb';0f''                  R)  Восстановить настройки из архива          ')
let "bb++"; bbuf+=$(printf '\033['$bb';0f''                  D)  Удалить сохранение из архива              ')
let "bb++"; bbuf+=$(printf '\033['$bb';0f''                  С)  Удалить все сохранения                    ')
let "bb++"; bbuf+=$(printf '\033['$bb';0f''                  M)  Максимальное количество резервных копий   <'$Maximum'>')
let "bb++"; bbuf+=$(printf '\033['$bb';0f''                  P)  Поделиться настройками через iCloud       ')
let "bb++"; bbuf+=$(printf '\033['$bb';0f''                  Q)  Вернуться в меню настроек                 ')
                    else
let "bb++"; bbuf+=$(printf '\033['$bb';0f''                  S)  Save current settings to archive          ')
let "bb++"; bbuf+=$(printf '\033['$bb';0f''                  S)  Preview data in archives                  ')
let "bb++"; bbuf+=$(printf '\033['$bb';0f''                  R)  Restore settings from archive             ')
let "bb++"; bbuf+=$(printf '\033['$bb';0f''                  D)  Delete backup from archive                ')
let "bb++"; bbuf+=$(printf '\033['$bb';0f''                  С)  Delete ALL backups                        ')
let "bb++"; bbuf+=$(printf '\033['$bb';0f''                  M)  Maximum number of backups                 <'$Maximum'>')
let "bb++"; bbuf+=$(printf '\033['$bb';0f''                  P)  Share settings via iCloud                 ')
let "bb++"; bbuf+=$(printf '\033['$bb';0f''                  Q)  Quit to the setup menu                    ')
                   fi
else
                  if [[ $loc = "ru" ]]; then
let "bb++"; bbuf+=$(printf '\033['$bb';0f'' Z/X - для выбора, Q/V - выход из просмотра :   ''                             ')
			else
let "bb++"; bbuf+=$(printf '\033['$bb';0f''  Z/X - for choice, Q/V - exit from preview :   ''                           ')
                fi
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
cloud_archive=0; shared_archive=0
hwuuid=$(ioreg -rd1 -c IOPlatformExpertDevice | awk '/IOPlatformUUID/' | cut -f2 -d"=" | tr -d '" \n')
        if [[ -d ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs ]]; then
            if [[ -f ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIbackups/$hwuuid/.MountEFIconfBackups.zip ]]; then cloud_archive=1; fi
            if [[ -f ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIbackups/Shared/.MountEFIconfBackups.zip ]]; then shared_archive=1; fi
        fi
}

PUT_INITCONF_IN_ICLOUD(){
hwuuid=$(ioreg -rd1 -c IOPlatformExpertDevice | awk '/IOPlatformUUID/' | cut -f2 -d"=" | tr -d '" \n')
        if [[ -d ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs ]]; then
            if [[ ! -d ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIbackups/$hwuuid/init_config_backup ]]; then 
                mkdir -p ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIbackups/$hwuuid/init_config_backup; fi
            if [[ ! -f ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIbackups/$hwuuid/init_config_backup/.MountEFIconf.plist ]]; then
                    cp ${HOME}/.MountEFIconf.plist ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIbackups/$hwuuid/init_config_backup
            else
                    old_init_v=$( md5 -qq ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIbackups/$hwuuid/init_config_backup/.MountEFIconf.plist )
                    new_init_v=$( md5 -qq ${HOME}/.MountEFIconf.plist )
                    if [[ ! ${old_init_v} = ${new_init_v} ]]; then 
                        cp ${HOME}/.MountEFIconf.plist ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIbackups/$hwuuid/init_config_backup
                    fi
            fi
            

        fi        
}

PUT_SHARE_IN_ICLOUD(){
success=0
if [[ -d ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs ]]; then
        if [[ ! -d ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIbackups/Shared ]]; then
                mkdir ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIbackups/Shared ; fi
                        if [[ -f ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIbackups/Shared/.MountEFIconfBackups.zip ]]; then
                                cloud_archv=$(md5 -qq /Users/$(whoami)/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIBackups/Shared/.MountEFIconfBackups.zip)
                                local_archv=$(md5 -qq ${HOME}/.MountEFIconfBackups.zip)
                                        if [[ ! $cloud_archv = $local_archv ]]; then
                                rm -f ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIBackups/Shared/.MountEFIconfBackups.zip
                                cp ${HOME}/.MountEFIconfBackups.zip ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIBackups/Shared/.MountEFIconfBackups.zip
                                success=1 
                                            else success=2
                                         fi
                         else
                                cp ${HOME}/.MountEFIconfBackups.zip ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIBackups/Shared/.MountEFIconfBackups.zip
                                 success=1       
                        fi

           else success=2

fi
}

CORRECT_BACKUPS_MAXIMUM(){
CHECK_BUNZIP
Now=$(ls -l ${HOME}/.MountEFIconfBackups | grep ^d | wc -l | tr -d " \t\n")
UPDATE_CACHE
GET_BACKUPS
if [[ $Now > $Maximum ]]; then
plutil -replace Backups.Maximum -integer ${Now} ${HOME}/.MountEFIconf.plist
UPDATE_CACHE
fi
if [[ -d ${HOME}/.MountEFIconfBackups ]]; then rm -R ${HOME}/.MountEFIconfBackups; fi
}

SHOW_BACKUP_ALIASES(){
                      
                        
                                            if [[ $loc = "ru" ]]; then
                        sbuf+=$(printf '\033['$lc';84f''                                База псевдонимов                            ')
                        let "lc++"
	                    sbuf+=$(printf '\033['$lc';84f')
                        sbuf+=$(printf '.%.0s' {1..74})
                        let 'lc++'
                        sbuf+=$(printf '\033['$lc';84f''                Носитель               |              Псевдоним           ')
                        let 'lc++'
	                    sbuf+=$(printf '\033['$lc';84f')
                        sbuf+=$(printf '.%.0s' {1..74}) 
                        let 'lc++'
			               else
                        sbuf+=$(printf '\033['$lc';84f''                               Aliases database                             ')
                        let "lc++"
                        sbuf+=$(printf '\033['$lc';84f')
	                    sbuf+=$(printf '.%.0s' {1..74})
                        let 'lc++'
                        sbuf+=$(printf '\033['$lc';84f''                  Media                |              Alias               ')
                        let 'lc++'
                        sbuf+=$(printf '\033['$lc';84f')
	                    sbuf+=$(printf '.%.0s' {1..74}) 
                        let 'lc++'
	                         fi
                                
                        strng=`echo "$MountEFIback" | grep -A 1 "<key>RenamedHD</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
                        IFS=';'; rlist=($strng); unset IFS
                        rcount=${#rlist[@]}
                        if [[ ! $rcount = 0 ]]; then
                        var11=$rcount; posr=0
                        while [[ ! $var11 = 0 ]]
                        do
                        hdrive=`echo "${rlist[$posr]}" | cut -f1 -d"="`                       
                        sdrive=`echo "${rlist[$posr]}" | cut -f2 -d"="`
                        sbuf+=$(printf '\033['$lc';84f'); sbuf+=$(printf ' %.0s' {1..74});
                        sbuf+=$(printf '\033['$lc';84f''\033[7C'"$hdrive")
                        sbuf+=$(printf '\033['$lc';84f''\033[44C'"$sdrive")
                        let "var11--"
                        let "posr++"
                        let "lc++"
                        done
                        fi
}

SHOW_BACKUP_PRESETS(){
GET_PRESETS_NAMES
                        if [[ $loc = "ru" ]]; then
                        sbuf+=$(printf '\033['$lc';84f''                               Список пресетов                             ')
                        let "lc++"
	                    sbuf+=$(printf '\033['$lc';84f')
                        sbuf+=$(printf '.%.0s' {1..74})
                        let 'lc++'
			               else
                        sbuf+=$(printf '\033['$lc';84f''                                Presets list                            ')
                        let "lc++"
                        sbuf+=$(printf '\033['$lc';84f')
	                    sbuf+=$(printf '.%.0s' {1..74})
                        let 'lc++'
	                         fi

for (( i=0; i<$pcount; i++ )); do
sbuf+=$(printf '\033['$lc';84f'); sbuf+=$(printf ' %.0s' {1..74}); sbuf+=$(printf '\033['$lc';94f'"${plist[i]}"); let "i++" ; sbuf+=$(printf '\033['$lc';124f'"${plist[i]}")
let "lc++"
done
sbuf+=$(printf '\033['$lc';84f')
sbuf+=$(printf '.%.0s' {1..74})
let 'lc++'
}

SET_BSCR(){

            if [[ $loc = "ru" ]]; then
sbuf+=$(printf '\033[1;84f''                               Параметры меню                             ')
sbuf+=$(printf '\033[2;84f')
sbuf+=$(printf '.%.0s' {1..74})
sbuf+=$(printf '\033[3;84f'' 1) Язык интерфейса программы = "'$loc_set'"'"%"$loc_corr"s"'(авто, англ, рус) \n')
sbuf+=$(printf '\033[4;84f'' 2) Показывать меню = "'"$menue_set"'"'"%"$menue_corr"s"'(авто, всегда)        \n')
sbuf+=$(printf '\033[5;84f'' 4) Открывать папку EFI в Finder = "'$OpenFinder_set'"'"%"$of_corr"s"'(Да, Нет)             \n')
if [[ ! $theme = "system" ]]; then
sbuf+=$(printf '\033[6;84f'' 5) Системная тема "'"$theme_name"'"'"%"$theme_ncorr"s"'(выключена)           \n')
sbuf+=$(printf '\033[7;84f'' 6) Пресет "'"$itheme_set"'" из '$pcount' встроенных'"%"$btheme_corr"s"'* (включен)'"%"$btspc_corr"s"'     \n')
else
sbuf+=$(printf '\033[6;84f'' 5) Системная тема "'"$theme_name"'"'"%"$theme_ncorr"s"' * (включена)            \n')
sbuf+=$(printf '\033[7;84f'' 6) Пресет "'"$itheme_set"'" из '$pcount' встроенных'"%"$btheme_corr"s"'  (выключен)'"%"$btspc_corr"s"'    \n')
fi
sbuf+=$(printf '\033[8;84f'' 7) Показывать подсказки по клавишам = "'$ShowKeys_set'"'"%"$sk_corr"s"'(Да, Нет)             \n')
sbuf+=$(printf '\033[9;84f'' 8) Подключить EFI при запуске MountEFI = "'$am_set'"'"%"$am_corr"s"'(Да, Нет)             \n')
sbuf+=$(printf '\033[10;84f'' 9) Подключить EFI при запуске Mac OS X = "'$sys_am_set'"'"%"$sys_am_corr"s"'(Да, Нет)             \n')
sbuf+=$(printf '\033[11;84f'' L) Искать загрузчики подключая EFI = "'$ld_set'"'"%"$ld_corr"s"'(Да, Нет)             \n')
sbuf+=$(printf '\033[12;84f'' C) Сохранение настроек при выходе = "'$bd_set'"'"%"$bd_corr"s"'(Да, Нет)             \n')
            else
sbuf+=$(printf '\033[1;84f''                                 Menu List                              ')
sbuf+=$(printf '\033[2;84f')
sbuf+=$(printf '.%.0s' {1..74})
sbuf+=$(printf '\033[3;84f'' 1) Program language = "'$loc_set'"'"%"$loc_corr"s"'(auto, rus, eng)         \n')
sbuf+=$(printf '\033[4;84f'' 2) Show menue = "'"$menue_set"'"'"%"$menue_corr"s"'(auto, always)           \n')
sbuf+=$(printf '\033[5;84f'' 4) Open EFI folder in Finder = "'$OpenFinder_set'"'"%"$of_corr"s"'(Yes, No)                \n')
if [[ ! $theme = "system" ]]; then
sbuf+=$(printf '\033[6;84f'' 5) System theme "'"$theme_name"'"'"%"$theme_ncorr"s"'   (disabled)               \n')
sbuf+=$(printf '\033[7;84f'' 6) Theme "'"$itheme_set"'" of '$pcount' presets'"%"$btheme_corr"s"'  * (enabled)                \n')
else
sbuf+=$(printf '\033[6;84f'' 5) System theme "'"$theme_name"'"'"%"$theme_ncorr"s"' * (enabled)                \n')
sbuf+=$(printf '\033[7;84f'' 6) Theme "'"$itheme_set"'" of '$pcount' presets'"%"$btheme_corr"s"'    (disabled)               \n')
fi
sbuf+=$(printf '\033[8;84f'' 7) Show binding keys help = "'$ShowKeys_set'"'"%"$sk_corr"s"'(Yes, No)                \n')
sbuf+=$(printf '\033[9;84f'' 8) Mount EFI on run MountEFI. Enabled = "'$am_set'"'"%"$am_corr"s"'(Yes, No)                \n')
sbuf+=$(printf '\033[10;84f'' 9) Mount EFI on run Mac OS X. Enabled = "'$sys_am_set'"'"%"$sys_am_corr"s"'(Yes, No)                \n')
sbuf+=$(printf '\033[11;84f'' L) Look for boot loaders mounting EFI = "'$ld_set'"'"%"$ld_corr"s"'(Yes, No)                \n')
sbuf+=$(printf '\033[12;84f'' C) Auto save settings on exit setup = "'$bd_set'"'"%"$bd_corr"s"'(Yes, No)                \n')
            fi
sbuf+=$(printf '\033[13;84f')
sbuf+=$(printf '.%.0s' {1..74})
sbuf+=$(printf '\033[14;84f''                  \e[1;33mMD5: '$b_md5'\e[0m                 ')
sbuf+=$(printf '\033[15;84f')
sbuf+=$(printf '.%.0s' {1..74})
}

SHOW_BACKUP_MENU(){
        b_loc=`echo "$MountEFIconf" | grep -A 1 "Locale" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
        if [[ ! $b_loc = "ru" ]] && [[ ! $b_loc = "en" ]]; then b_loc="auto"; fi
        if [[ $loc = "ru" ]]; then
        if [[ $b_loc = "ru" ]]; then loc_set="русский"; loc_corr=17; fi
        if [[ $b_loc = "en" ]]; then loc_set="английский"; loc_corr=14; fi
        if [[ $b_loc = "auto" ]]; then loc_set="автовыбор"; loc_corr=15; fi
            else
        if [[ $b_loc = "ru" ]]; then loc_set="russian"; loc_corr=23; fi
        if [[ $b_loc = "en" ]]; then loc_set="english"; loc_corr=23; fi
        if [[ $b_loc = "auto" ]]; then loc_set="auto"; loc_corr=26; fi
            fi
        GET_MENUE
        GET_USER_PASSWORD
        GET_OPENFINDER
        GET_THEME
        GET_SHOWKEYS
        GET_AUTOMOUNT
        CHECK_SYS_AUTOMOUNT_SERVICE
        GET_LOADERS
        GET_AUTOBACKUP
                
        SET_BSCR

}

CLEAR_SPACE(){
if [[ ${lc} -lt ${lines2} ]]; then 
for (( i=${lc}; i<${lines2}; i++ )); do
printf '\033['$i';83f'
printf ' %.0s' {1..78}
done
fi 
}


SHOW_BACKUP_DATA(){
MountEFIback=$( cat ~/.MountEFIconfBackups/$bptr/.MountEFIconf.plist )
b_md5=$(md5 -qq ~/.MountEFIconfBackups/$bptr/.MountEFIconf.plist)
if [[ ! $MountEFIback = "" ]]; then
lc=16; unset sbuf
MountEFIconf="$MountEFIback"
SHOW_BACKUP_MENU
SHOW_BACKUP_PRESETS
UPDATE_CACHE
SHOW_BACKUP_ALIASES
echo "${sbuf}"
CLEAR_SPACE
fi
}

GET_MAX_BACKUPS_LINES(){
b_lines=0; bn=0
for ((i=1;i<$((${Now}+1));i++)); do
MountEFIback=$( cat ~/.MountEFIconfBackups/$i/.MountEFIconf.plist )
strng=`echo "$MountEFIback" | grep -A 1 "<key>RenamedHD</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
                        IFS=';'; rlist=($strng); unset IFS
                        rcount=${#rlist[@]}
pcount=0
pcount=$(echo "$MountEFIback" | grep  -e "<key>BackgroundColor</key>" | wc -l | xargs)
let "bn=rcount+(pcount/2)+1"; if [[ "${bn}" -gt "${b_lines}" ]]; then b_lines=${bn}; fi
done
let "b_lines=b_lines+23"
}

##############################################################################################################

SET_BACKUPS(){
clear && printf '\e[3J' && printf "\033[0;0H"
if [[ -d ${HOME}/.MountEFIconfBackups ]]; then rm -R ${HOME}/.MountEFIconfBackups; fi
unzip  -o -qq ${HOME}/.MountEFIconfBackups.zip -d ~/.temp
mv ~/.temp/*/*/.MountEFIconfBackups ~/.MountEFIconfBackups
rm -r ~/.temp

var5=0
while [[ $var5 = 0 ]]; do
unset bbuf
SHOW_BACKUPS
clear && printf '\e[3J' && printf "\033[0;0H" ; echo "$bbuf"
printf "%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s""%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"
printf "\033[7A"
printf "\r\033[45C"
printf "\033[?25h"
printf '\n\n'
unset inputs
while [[ ! ${inputs} =~ ^[sSdDcCmMqQrRpPvV]+$ ]]; do 

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

if [[ ${inputs} = [vV] ]]; then
                unset bbuf; unset inputs
                printf "\033[?25l"
                SHOW_BACKUPS "double"
                clear && printf '\e[3J' && printf "\033[0;0H" ; echo "$bbuf"
                echo "$bbuf"
                vart=0; plines=6; bptr=1; let "ilines=Now+9"
                printf '\033['$plines';10f''*'
                SHOW_BACKUP_DATA
                while [[ $vart = 0 ]]; do
                while [[ ! ${inputs} =~ ^[zZxXqQvV]+$ ]]; do
                printf '\033['$ilines';47f'
                printf "\033[?25h"
                read -s -n 1 inputs
                printf "\033[?25l"
                done
                if [[ ${inputs} = "" ]]; then inputs="p"; printf "\033[1A";  fi 
                if [[ ${inputs} = [qQvV] ]]; then unset inputs; break;  fi
                if [[ ${inputs} = [zZ] ]]; then
                               printf '\033['$plines';10f''   '
                               if [[ "${bptr}" -gt "1" ]]; then let "bptr--"; else let "bptr=Now"; fi
                               let "plines=bptr+5"
                               #clear && printf '\e[3J' && printf "\033[0;0H" ; echo "$bbuf"
                               printf '\e[3J' && printf "\033[0;0H" ; echo "$bbuf"
                               printf '\033['$plines';10f''*  '
                               printf '\033['$ilines';46f'
                               SHOW_BACKUP_DATA &
                fi
                if [[ ${inputs} = [xX] ]]; then
                               printf '\033['$plines';10f''   '
                               if [[ "${bptr}" -lt "$Now" ]]; then let "bptr++"; else let "bptr=1"; fi
                               let "plines=bptr+5"
                               #clear && printf '\e[3J' && printf "\033[0;0H" ; echo "$bbuf"
                               printf '\033['$plines';10f''*  '
                               printf '\033['$ilines';46f'
                               SHOW_BACKUP_DATA &
                fi
                read -s -n 1 inputs
                done 
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
                        GET_THEME
                        old_theme=$theme
                        RESTORE_BACKUP
                        UPDATE_CACHE
                        GET_THEME
                        if [[ $theme = "system" ]]; then 
                            if [[ ! $old_theme = $theme ]]; then 
                                need_restart=1
                                    else
                                need_restart=0
                            fi
                        fi
                        Now=$(ls -l ${HOME}/.MountEFIconfBackups | grep ^d | wc -l | tr -d " \t\n")
                        GET_BACKUPS 
                        if [[ "${Now}" -ge "${Maximum}" ]]; then
                        if [[ "${Now}" -le 10 ]]; then Now=10

                                    elif [[ "${Now}" -le 20 ]]; then Now=20
                                    elif [[ "${Now}" -le 30 ]]; then Now=30
                                    elif [[ "${Now}" -le 40 ]]; then Now=40
                                    elif [[ "${Now}" -le 50 ]]; then Now=50

                        fi
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
                
                printf '   Подтвердите публикацию настроек (y/N) ? '
			else
                printf '   Confirm the publication of settings (y/N)? '
                
                fi
                printf "\033[?25h"
                read  -n 1 -r                
                printf "\033[?25l"
              if [[ ! $REPLY = "" ]]; then 
                if [[  $REPLY =~ ^[yY]$ ]]; then
                   
                PUT_SHARE_IN_ICLOUD
                fi
                if [[ $success = 1 ]]; then 
                         if [[ $loc = "ru" ]]; then
                         printf '\n\n  Настройки опубликованы.  '; sleep 1
			                   else
                         printf '\n\n  Settings published.  '; sleep 1
                         fi
                         elif [[ $success = 2 ]];then 
                         if [[ $loc = "ru" ]]; then
                         printf '\n\n  Настройки совпадают с ранее опубликованными.  '; read -s -n 1 -t 2
			                   else
                         printf '\n\n  The settings are the same as previously published.  '; read -s -n 1 -t 2
                         fi
                         elif [[ $success = 0 ]]; then 
                        if [[ $loc = "ru" ]]; then
                         printf '\n\n  Ошибка! Публикация не удалась.  '; read -s -n 1 -t 2
			                   else
                         printf '\n\n  Error! Publication failed.  '; read -s -n 1 -t 2
                         fi
                fi; fi    
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
    if [[ $loc = "ru" ]]; then
    READ_TWO_SYMBOLS 49
        else
    READ_TWO_SYMBOLS 49
        fi    
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
	if [[ $apos = 0 ]]; then plutil -replace AutoMount.Enabled -bool NO ${HOME}/.MountEFIconf.plist
                else
                plutil -replace AutoMount.Enabled -bool YES ${HOME}/.MountEFIconf.plist
                GET_SYSTEM_FLAG
                if [[ "$flag" = "1" ]]; then
                FORCE_CHECK_PASSWORD "automount"
                if [[ $mypassword = "" ]]; then ENTER_PASSWORD;  osascript -e 'tell application "Terminal" to activate'; fi
                FORCE_CHECK_PASSWORD "automount"
                if [[ $mypassword = "" ]]; then plutil -replace AutoMount.Enabled -bool NO ${HOME}/.MountEFIconf.plist; fi
    
                fi
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
    if [[ $loc = "ru" ]]; then
    READ_TWO_SYMBOLS 43
        else
    READ_TWO_SYMBOLS 43
        fi        
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

GET_THEME
old_theme=$theme
mv -f "${filepath}" ${HOME}/.MountEFIconf.plist

UPDATE_CACHE
CHECK_CONFIG
CORRECT_BACKUPS_MAXIMUM
GET_THEME
if [[ $theme = "system" ]]; then 
    if [[ ! $old_theme = $theme ]]; then 
          need_restart=1
               else
          need_restart=0
     fi
fi               
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
                GET_THEME
                old_theme=$theme
                mv -f ~/.temp2/*/*/"${filename}" ${HOME}/.MountEFIconf.plist
                UPDATE_CACHE
                CHECK_CONFIG
                CORRECT_BACKUPS_MAXIMUM
                CORRECT_CURRENT_PRESET
                CHECK_BUNZIP
                Now=$(ls -l ${HOME}/.MountEFIconfBackups | grep ^d | wc -l | tr -d " \t\n")
                        GET_BACKUPS 
                    if [[ "${Now}" -ge "${Maximum}" ]]; then
                        if [[ "${Now}" -le 10 ]]; then Now=10

                                    elif [[ "${Now}" -le 20 ]]; then Now=20
                                    elif [[ "${Now}" -le 30 ]]; then Now=30
                                    elif [[ "${Now}" -le 40 ]]; then Now=40
                                    elif [[ "${Now}" -le 50 ]]; then Now=50

                        fi
                        plutil -replace Backups.Maximum -integer ${Now} ${HOME}/.MountEFIconf.plist
                    fi
                if [[ -d ${HOME}/.MountEFIconfBackups ]]; then rm -R ${HOME}/.MountEFIconfBackups; fi
                GET_THEME
                if [[ $theme = "system" ]]; then 
                    if [[ ! $old_theme = $theme ]]; then 
                        need_restart=1
                            else
                        need_restart=0
                    fi
                fi                
                
            fi
         fi
rm -r ~/.temp2

}

#######################################################################################################################################################################

DOWNLOAD_CONFIG_FROM_FILE(){
errorep=0; if [[ $loc = "ru" ]]; then prompt='"ВЫБЕРИТЕ ФАЙЛ .ZIP ИЛИ .PLIST C КОНФИГУРАЦИЕЙ MountEFI:"'
                                 else prompt='"CHOOSE .ZIP OR .PLIST FILE WITH MountEFI CONFIGURATION:"'; fi
alias_string='"'"$(echo "$(diskutil info $(df / | tail -1 | cut -d' ' -f 1 ) |  grep "Volume Name:" | cut -d':'  -f 2 | xargs)")"':Users:'$(whoami)':Documents"'
if filepath="$(osascript -e 'tell application "Terminal" to return POSIX path of (choose file default location alias '"${alias_string}"' with prompt '"${prompt}"')')"; then 
        
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
errorep=0; if [[ $loc = "ru" ]]; then prompt='"ВЫБЕРИТЕ ПАПКУ ДЛЯ СОХРАНЕНИЯ КОНФИГУРАЦИИ MountEFI:"'
                                 else prompt='"CHOOSE A FOLDER TO SAVE MountEFI CONFIGURATION:"'; fi
alias_string='"'"$(echo "$(diskutil info $(df / | tail -1 | cut -d' ' -f 1 ) |  grep "Volume Name:" | cut -d':'  -f 2 | xargs)")"':Users:'$(whoami)':Documents"'
if folderpath="$(osascript -e 'tell application "Terminal" to return POSIX path of (choose folder default location alias '"${alias_string}"' with prompt '"${prompt}"')')"; then 
        
        folderpath=$(echo -n "${folderpath}" | sed "s/ /\\\ /g" | xargs )
        
        if [[ -f ${HOME}/MountEFIconf.plist ]]; then rm ${HOME}/MountEFIconf.plist; fi
        cp ${HOME}/.MountEFIconf.plist ${HOME}/MountEFIconf.plist
        
        if [[ -f ${HOME}/.MountEFIconf.zip ]]; then rm ${HOME}/.MountEFIconf.zip; fi
        zip -X -qq ${HOME}/.MountEFIconf.zip ${HOME}/MountEFIconf.plist
        rm ${HOME}/MountEFIconf.plist

        savename="MountEFIconf"; savenum=0
        while true; do
        if [[ ! -f "${folderpath}/${savename}.zip" ]]; then mv -f ${HOME}/.MountEFIconf.zip "${folderpath}/${savename}.zip"; break
        else 
        ((savenum++)); savename="${savename:0:12}-${savenum}"
        fi
        done

else errorep=1
        
fi >/dev/null 2>&1

if [[ $loc = "ru" ]]; then
    if [[ $errorep = 1 ]]; then printf '\n\n  Экспорт конфигурации отменён   '; sleep 2 
        else
if [[ -f "${folderpath}/${savename}.zip" ]]; then printf '\n\n  Конфигурация успешно экспортирована в архиве   '; sleep 2 
  else
        printf '\n\n  Ошибка. Экспорт конфигурации не удался   '; sleep 2
fi
fi
else
    if [[ $errorep = 1 ]]; then printf '\n\n  Configuration export canceled   '; sleep 2 
        else
if [[ -f "${folderpath}/${savename}.zip" ]]; then printf '\n\n  Configuration exported to archive successfully   '; sleep 2 
  else
        printf '\n\n  Error. Export configuration failed   '; sleep 2
fi
fi
fi
        
}

GET_INPUT(){

unset inputs
while [[ ! ${inputs} =~ ^[0-9qQvVaAbBcCdDlLiIeEpPRuUHhsSZ]+$ ]]; do

                if [[ $loc = "ru" ]]; then
printf '  Введите символ от 0 до '$Lit' (или Q - выход ):   ' ; printf '                             '
			else
printf '  Enter a letter from 0 to '$Lit' (or Q - exit ):   ' ; printf '                           '
                fi
printf "%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"
printf "\033[4A"
printf "\r\033[45C"
printf "\033[?25h"
SET_INPUT
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

unset sbuf
            if [[ $loc = "ru" ]]; then
sbuf=$(printf ' 0) Установить все настройки по умолчанию                                      \n')
sbuf+=$(printf '  1) Язык интерфейса программы = "'$loc_set'"'"%"$loc_corr"s"'(авто, англ, русский) \n')
sbuf+=$(printf ' 2) Показывать меню = "'"$menue_set"'"'"%"$menue_corr"s"'(авто, всегда)        \n')
sbuf+=$(printf ' 3) Пароль пользователя = "'"$mypassword_set"'"'"%"$pass_corr"s"'(пароль, нет пароля)  \n')
sbuf+=$(printf ' 4) Открывать папку EFI в Finder = "'$OpenFinder_set'"'"%"$of_corr"s"'(Да, Нет)             \n')
if [[ ! $theme = "system" ]]; then
sbuf+=$(printf ' 5) Системная тема "'"$theme_name"'"'"%"$theme_ncorr"s"'(выключена)           \n')
sbuf+=$(printf ' 6) Пресет "'"$itheme_set"'" из '$pcount' встроенных'"%"$btheme_corr"s"'* (включен)'"%"$btspc_corr"s"'     \n')
else
sbuf+=$(printf ' 5) Системная тема "'"$theme_name"'"'"%"$theme_ncorr"s"' * (включена)            \n')
sbuf+=$(printf ' 6) Пресет "'"$itheme_set"'" из '$pcount' встроенных'"%"$btheme_corr"s"'  (выключен)'"%"$btspc_corr"s"'    \n')
fi
sbuf+=$(printf ' 7) Показывать подсказки по клавишам = "'$ShowKeys_set'"'"%"$sk_corr"s"'(Да, Нет)             \n')
sbuf+=$(printf ' 8) Подключить EFI при запуске MountEFI = "'$am_set'"'"%"$am_corr"s"'(Да, Нет)             \n')
sbuf+=$(printf ' 9) Подключить EFI при запуске Mac OS X = "'$sys_am_set'"'"%"$sys_am_corr"s"'(Да, Нет)             \n')
sbuf+=$(printf ' L) Искать загрузчики подключая EFI = "'$ld_set'"'"%"$ld_corr"s"'(Да, Нет)             \n')
sbuf+=$(printf ' C) Сохранение настроек при выходе = "'$bd_set'"'"%"$bd_corr"s"'(Да, Нет)             \n')
sbuf+=$(printf ' A) Создать или править псевдонимы физических носителей                         \n')
sbuf+=$(printf ' B) Резервное сохранение и восстановление настроек                              \n')
sbuf+=$(printf ' I) Загрузить конфиг из файла (zip или plist)                                   \n')
sbuf+=$(printf ' E) Сохранить конфиг в файл (zip)                                               \n')
sbuf+=$(printf ' H) Редактор хэшей загрузчиков                                                  \n')
sbuf+=$(printf ' P) Редактировать встроенные пресеты тем                                        \n')
sbuf+=$(printf ' S) Авто-обновление программы = "'$AutoUpdate_set'"'"%"$aus_corr"s"'(Да, Нет)             \n')
if [[ "${par}" = "-r" ]] && [[ -f ../../../MountEFI.app/Contents/Info.plist ]]; then 
sbuf+=$(printf ' U) Обновление программы                                                        \n')
fi
            else
sbuf=$(printf ' 0) Setup all parameters to defaults                                            \n')
sbuf+=$(printf ' 1) Program language = "'$loc_set'"'"%"$loc_corr"s"'(auto, rus, eng)         \n')
sbuf+=$(printf ' 2) Show menue = "'"$menue_set"'"'"%"$menue_corr"s"'(auto, always)           \n')
sbuf+=$(printf ' 3) Save password = "'"$mypassword_set"'"'"%"$pass_corr"s"'(password, not saved)    \n')
sbuf+=$(printf ' 4) Open EFI folder in Finder = "'$OpenFinder_set'"'"%"$of_corr"s"'(Yes, No)                \n')
if [[ ! $theme = "system" ]]; then
sbuf+=$(printf ' 5) System theme "'"$theme_name"'"'"%"$theme_ncorr"s"'   (disabled)               \n')
sbuf+=$(printf ' 6) Theme "'"$itheme_set"'" of '$pcount' presets'"%"$btheme_corr"s"'  * (enabled)                \n')
else
sbuf+=$(printf ' 5) System theme "'"$theme_name"'"'"%"$theme_ncorr"s"' * (enabled)                \n')
sbuf+=$(printf ' 6) Theme "'"$itheme_set"'" of '$pcount' presets'"%"$btheme_corr"s"'    (disabled)               \n')
fi
sbuf+=$(printf ' 7) Show binding keys help = "'$ShowKeys_set'"'"%"$sk_corr"s"'(Yes, No)                \n')
sbuf+=$(printf ' 8) Mount EFI on run MountEFI. Enabled = "'$am_set'"'"%"$am_corr"s"'(Yes, No)                \n')
sbuf+=$(printf ' 9) Mount EFI on run Mac OS X. Enabled = "'$sys_am_set'"'"%"$sys_am_corr"s"'(Yes, No)                \n')
sbuf+=$(printf ' L) Look for boot loaders mounting EFI = "'$ld_set'"'"%"$ld_corr"s"'(Yes, No)                \n')
sbuf+=$(printf ' C) Auto save settings on exit setup = "'$bd_set'"'"%"$bd_corr"s"'(Yes, No)                \n')
sbuf+=$(printf ' A) Create or edit aliases physical device/media                                \n')
sbuf+=$(printf ' B) Backup and restore configuration settings                                   \n')
sbuf+=$(printf ' I) Import config from file (zip or plist)                                      \n')
sbuf+=$(printf ' E) Upload config to file (zip)                                                 \n')
sbuf+=$(printf ' H) Hashes of EFI loaders editor                                                \n')
sbuf+=$(printf ' P) Edit built-in theme presets                                                 \n')
sbuf+=$(printf ' S) Auto-update this program = "'$AutoUpdate_set'"'"%"$aus_corr"s"'(Yes, No)                \n')
if [[ "${par}" = "-r" ]] && [[ -f ../../../MountEFI.app/Contents/Info.plist ]]; then
sbuf+=$(printf ' U) Update program manually                                                     \n')
fi

            fi
                    Lit="R"
            if [[ $cloud_archive = 1 ]] || [[ $shared_archive = 1 ]]; then
               if [[ $loc = "ru" ]]; then
sbuf+=$(printf ' D) Загрузить бэкапы настроек из iCloud                                         \n')
                else
sbuf+=$(printf ' D) Upload settings backups from iCloud                                         \n')
            fi
      fi
 if [[ $loc = "ru" ]]; then
sbuf+=$(printf ' R) Быстро перезагрузить программу настройки              (SHIFT+R)             \n')
sbuf+=$(printf ' Z) Удаление программы MountEFI с компьютера              (SHIFT+Z)             \n')
else
sbuf+=$(printf ' R) Restart the setup program immediately              (SHIFT+R)                \n')
sbuf+=$(printf ' Z) Uninstall all MountEFI files and services          (SHIFT+Z)                \n')
fi 
echo "${sbuf}"
}

UPDATE_SCREEN(){
        GET_THEME
        if [[ $theme = "built-in" ]]; then CUSTOM_SET; else SET_SYSTEM_THEME; fi &

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
        GET_AUTOUPDATE
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
    printf '\n\n\n     0)  поиск разделов .....      '
		else
	printf '\n\n\n     0)  updating  list .....      '
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
        printf '               Z)    Откатить изменения (из истории)                           \n'
        printf '               X)    Возвратить изменения (из истории)                         \n'
        printf '               R)    Удалить всю базу псевдонимов!                             \n'
        printf '               Q)    Вернуться в меню настроек                                 \n\n' 

                    else
        if [[ $vid = 0 ]]; then
        printf '            *  Aliases should not be longer than 30 characters                  \n\n'
                    else
        printf '                                                                                \n\n'
        fi
        printf '               С)    Change the preview mode                                   \n'
        printf '               V)    View the entire alias database                            \n'
        printf '               D)    Delete an alias                                           \n'
        printf '               Z)    Roll back changes (from history)                          \n'
        printf '               X)    Revert changes (from history)                             \n'
        printf '               R)    Delete the entire alias database!                         \n'
        printf '               Q)    Quit to the setup menu                                    \n\n' 

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



########################### определение функции ввода по 2 байта #########################
READ_TWO_SYMBOLS(){
unset pos_corr; pos_corr=$1
if [[ $pos_corr = "" ]]; then pos_corr=38; fi
choice1="±"; choice="±";
printf "\033[?25h"
while [[ $choice1 = "±" ]]
do
printf '\n'
printf '                                                                                \n'
printf '                                                                                '
printf "\r\n\033[3A\033['$pos_corr'C"
if [[ ! $loc = "ru" ]]; then printf "\033[2C"; fi
IFS="±"; read   -n 1 -t 1  choice1 ; unset IFS 
if [[ $choice1 = "" ]]; then printf "\033[1A"; choice1="±"; fi
if [[ $choice1 = [0-9] ]]; then choice=${choice1}; break
            else
        
            if [[ $choice1 = [uUqQeEiIvVdDaAoOzZxXnNrRlLsS] ]]; then choice=${choice1}; break; fi
       
fi
 choice1="±"


CHECK_HOTPLUG
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
if [[ $loc = "ru" ]]; then
printf '  ! введите вторую цифру или <Enter>        '
else
printf '  ! Press the second digit or press <Enter> '
fi
printf "\r\n\033[4A\033['$pos_corr'C"$choice
if [[ ! $loc = "ru" ]]; then printf "\033[2C"; fi
CHECK_HOTPLUG
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
inputs=$choice
  }
########################################################################################


############################ функция псевдонимов ####################################################

SAVE_STRING(){
strng=`echo "$MountEFIconf" | grep -A 1 "<key>RenamedHD</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
if [[ ! $strng = "" ]]; then backstrings+=("$strng"); let "bmax++"; let "bpos=bmax-1"; fi
}

SET_ALIASES(){
clear && printf '\e[8;'${lines}';80t' && printf '\e[3J' && printf "\033[0;0H"
GET_FULL_EFI
SHOW_FULL_EFI
vid=0
UPDATE_FULL_EFI
var8=0
backstrings=(); bmax=0
SAVE_STRING
while [ $var8 != 1 ] 
do

unset inputs
while [[ ! ${inputs} =~ ^[0-9rRvVcCdDqQzZxX]+$ ]]; do 

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
        if [[ $loc = "ru" ]]; then
    READ_TWO_SYMBOLS 55
        else
    READ_TWO_SYMBOLS 49
        fi
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
                SAVE_STRING
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

if [[ ${inputs} = [zZ] ]]; then 
                         if [[ $bmax > 1 ]]; then 
                                    if [[ ! $bpos = 0 ]]; then 
                                       let "bpos--"; plutil -replace RenamedHD -string "${backstrings[bpos]}" ${HOME}/.MountEFIconf.plist; UPDATE_CACHE; 
                                    fi
                          
                          SHOW_FULL_EFI
                          #inputs=0
            fi
                        
fi
                         
if [[ ${inputs} = [xX] ]]; then 
                         if [[ ! $bmax = 0 ]]; then let "pmax=bmax-1"; fi
                         if [[ $pmax > $bpos ]]; then 
                                     let "bpos++"; plutil -replace RenamedHD -string "${backstrings[bpos]}" ${HOME}/.MountEFIconf.plist; UPDATE_CACHE; 
                          
                          SHOW_FULL_EFI
                          #inputs=0
        
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
                        DEL_RENAMEHD; SAVE_STRING
                        fi
                        clear
    
                        inputs=0
fi

if [[ ${inputs} = [vV] ]]; then
                        strng=`echo "$MountEFIconf" | grep -A 1 "<key>RenamedHD</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
                        IFS=';'; rlist=($strng); unset IFS
                        rcount=${#rlist[@]}
                        let "lcount=rcount+10"  
                        if [[ "${lcount}" -gt "${lines}" ]]; then new_lines=$lcount; else new_lines=$lines; fi
                        clear && printf '\e[8;'${new_lines}';80t' && printf '\e[3J' && printf "\033[0;0H"
                        #clear  && printf '\e[3J' && printf "\033[0;0H"
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
read -s -n 1
clear
fi 

if [[ ! ${inputs} =~ ^[0vVdDrRqQcCzZxX]+$ ]]; then
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
                        GET_APP_ICON
                        if [[ $loc = "ru" ]]; then
                        if demo=$(osascript -e 'set T to text returned of (display dialog "< Редактировать псевдоним >|<- 30 знаков !" '"${icon_string}"' buttons {"Отменить", "OK"} default button "OK" default answer "'"${adrive}"'")'); then cancel=0; else cancel=1; fi 2>/dev/null
                        else
                        if demo=$(osascript -e 'set T to text returned of (display dialog "<-------- Edit aliases -------->|<- 30 characters !" '"${icon_string}"' buttons {"Cancel", "OK"} default button "OK" default answer "'"${adrive}"'")'); then cancel=0; else cancel=1; fi 2>/dev/null 
                        fi
                        demo=`echo "$demo" | tr -d \"\'\;\+\-\(\)`
                        demo=`echo "$demo" | tr -cd "[:print:]\n"`
                        demo=`echo "$demo" | tr -d "={}]><[&^$"`
                        demo=$(echo "${demo}" | sed 's/^[ \t]*//')
                        if [[ $cancel = 0 ]]; then
                            if [[ ! "${demo}" = "${drive}" ]]; then
                        if [[ ${#demo} -gt 30 ]]; then demo="${demo:0:30}"; fi
                        if [[ ${#demo} = 0 ]]; then DEL_RENAMEHD; SAVE_STRING
                        else
                        ADD_RENAMEHD; SAVE_STRING
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

GET_COLOR_INPUT(){
            while [[ ! ${inputs} =~ ^[aAbBsSqQzZxXcCvVuU2-3]+$ ]]; do
            printf "\033[25;43f"; printf '                                    \r'
                if [[ $loc = "ru" ]]; then
            printf '\r  Ожидание ввода (или Q - возврат к меню):  \n\n'
            printf '        A/S - выбрать компонент цвета для редактирования     \n'
            printf '        Z/X - установка значения выбранного компонента       \n'
            printf '        С/V - изменение шага смены значения компонента       \n'
            printf '        B/B - отменить последнее изменение компонента        \n'
            printf '        U/U - отменить последние изменения цвета             \n'
            
			       else
            printf '\r    Waiting for input (Q - back to menu):   \n\n'
            printf '        A/S - select a color component to edit               \n'
            printf '        Z/X - control the value of the selected component    \n'
            printf '        С/V - control the step of changing the color value   \n'
            printf '        B/B - discard the last color component change        \n'
            printf '        U/U - discard recent color value changes             \n'
            
                fi 
            printf "\033[25;43f"; printf '                                    \r'
            #printf "%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"
            #printf "\033[4A"
            if [[ $loc = "ru" ]]; then
            printf "\r\033[43C"
            else
            printf "\r\033[42C"
            fi
            printf "\033[?25h"
           
 
        
        read -s -n 1  inputs 
        
        if [[ ! $inputs = [aAbBsSqQzZxXcCvVuU2-3] ]]; then 
                        if [[ ${inputs} = "" ]]; then  unset inputs; fi 
                        if [[ ${inputs} -gt 65535 ]]; then unset inputs; fi 2>&-
                        
                        printf '\r'
                        
        fi
        printf '\r'
        done
}

LEN(){
str="$1"
lenth=${#str}
let "ncr=6-lenth"
}

RET_BORDER(){
border=0
if [[ $inputs = [zZ] ]]; then
if [[ $c_ptr = 1 ]] && [[ $color1 = 0 ]]; then border=1; fi
if [[ $c_ptr = 2 ]] && [[ $color2 = 0 ]]; then border=1; fi
if [[ $c_ptr = 3 ]] && [[ $color3 = 0 ]]; then border=1; fi
fi
if [[ $inputs = [xX] ]]; then
if [[ $c_ptr = 1 ]] && [[ $color1 = 65535 ]]; then border=1; fi
if [[ $c_ptr = 2 ]] && [[ $color2 = 65535 ]]; then border=1; fi
if [[ $c_ptr = 3 ]] && [[ $color3 = 65535 ]]; then border=1; fi
fi  

}

function ProgressBar {
let _progress=(${1}*100/${2}*100)/100
let _done=(${_progress}*4)/10
let _left=40-$_done
_fill=$(printf "%${_done}s")
_empty=$(printf "%${_left}s")
printf "       ${_fill// /|}${_empty// / }| ${_progress}%% "
}

STEP_BAR_CORR(){
case "$step" in
                    4096 ) step2=65535;;
                    3072 ) step2=42000;;
                    2048 ) step2=33000;;
                    1560 ) step2=25000;;
                    1024 ) step2=17000;;
                    512 ) step2=9000;;
                    255 ) step2=6000;;
                    128 ) step2=4000;;
                    65 ) step2=2000;;
                    15 ) step2=1500;;
                    1 ) step2=1000;;

                    esac


}

GET_CPU_FAMILY(){
cpu_family=$(sysctl -n machdep.cpu.brand_string | grep -)
if [[ $cpu_family = "" ]]; then cpu_family=0
 else
    cpu_family=$(sysctl -n machdep.cpu.brand_string | cut -f2 -d"-" | cut -c1)
fi

}

EDIT_COLOR(){
printf "\033[?25l"
token=$1; if [[ $token = "" ]]; then token="background"; fi
if [[ $token = "background" ]]; then
                            old_color="$current_background"
                            if [[ $loc = "ru" ]]; then
                            words="Редакция цвета фона:"
                            else
                            words="Edit Background color:"
                            fi
    else
if [[ $token = "foreground" ]]; then
                            token="normal text"
                            old_color="$current_foreground"
                            if [[ $loc = "ru" ]]; then
                            words="Редакция цвета текста:"
                            else
                            words="Edit text color:"
                            fi
    fi
fi

                            printf "\033[14;0H"'                            '"$words"'                         \n\n'

color1=$(echo "$old_color" | tr -d ' {}' | cut -f1 -d ',')
color2=$(echo "$old_color" | tr -d ' {}' | cut -f2 -d ',')
color3=$(echo "$old_color" | tr -d ' {}' | cut -f3 -d ',')
ncolor1=$color1; ncolor2=$color2; ncolor3=$color3

GET_CPU_FAMILY; if [[ $cpu_family = 0 ]]; then step=4096; else step=2048; fi

c_ptr=1; l_ptr=16;  swap_one=0; swap_all=0; _start=0; _end=65535
printf "\033[?25l"
cvar=0

printf "\033[16;0H"
             if [[ $cpu_family = 0 ]]; then
                LEN $color1; printf '           R:''%'$ncr's'$color1'    \n\n'
                LEN $color2; printf '           G:''%'$ncr's'$color2'    \n\n'
                LEN $color3; printf '           B:''%'$ncr's'$color3'    \n\n'
                    if [[ $loc = "ru" ]]; then 
                LEN $step ;  printf '         ШАГ:''%'$ncr's'$step'      \n\n'
                    else
                LEN $step ;  printf '        STEP:''%'$ncr's'$step'      \n\n'
                    fi
             else
                LEN $color1; printf '           R:''%'$ncr's'$color1 ;  ProgressBar ${color1} ${_end}; printf '\n\n'
                LEN $color2; printf '           G:''%'$ncr's'$color2 ;  ProgressBar ${color2} ${_end}; printf '\n\n'
                LEN $color3; printf '           B:''%'$ncr's'$color3 ;  ProgressBar ${color3} ${_end}; printf '\n\n'
                    if [[ $loc = "ru" ]]; then 
                LEN $step ;  printf '         ШАГ:''%'$ncr's'$step   ;  STEP_BAR_CORR; ProgressBar ${step2} ${_end};  printf '\n\n'
                    else
                LEN $step ;  printf '        STEP:''%'$ncr's'$step   ;  STEP_BAR_CORR; ProgressBar ${step2} ${_end};  printf '\n\n'
                    fi
             fi
                printf "\033['$l_ptr';10H""*";  printf "\033[23;0H"  
                printf '\n\n'                                           
unset inputs
printf "\033[25;43f"; printf '                                    \r'
                if [[ $loc = "ru" ]]; then
            printf '\r  Ожидание ввода (или Q - возврат к меню):  \n\n'
            printf '        A/S - выбрать компонент цвета для редактирования     \n'
            printf '        Z/X - установка значения выбранного компонента       \n'
            printf '        С/V - изменение шага смены значения компонента       \n'
            printf '        B/B - отменить последнее изменение компонента        \n'
            printf '        U/U - отменить последние изменения цвета             \n'
			       else
            printf '\r    Waiting for input (Q - back to menu):   \n\n'
            printf '        A/S - select a color component to edit               \n'
            printf '        Z/X - control the value of the selected component    \n'
            printf '        С/V - control the step of changing the color value   \n'
            printf '        B/B - discard the last color component change        \n'
            printf '        U/U - discard recent color value changes             \n'
            
                fi
            printf "\033[25;43f"; printf '                                    \r'
   
            if [[ $loc = "ru" ]]; then
            printf "\r\033[43C"
            else
            printf "\r\033[42C"
            fi
           

osascript -e "tell application \"Terminal\" to set ""$token"" color of window 1 to {"$color1", "$color2", "$color3"}"
while [[ $cvar = 0 ]]; 
do
                
         GET_COLOR_INPUT

        printf "\033[?25l"
                
         if [[ $inputs = [sS] ]]; then
                
                printf "\033['$l_ptr';10f"" "
                if [[ $c_ptr > 1 ]]; then let "c_ptr--"; let "l_ptr=l_ptr-2"
                    else
                        c_ptr=3; l_ptr=20
                fi
                printf "\033['$l_ptr';10f""*"; printf "\033[25;43f"
               
         fi

         if [[ $inputs = [aA] ]]; then
                
                printf "\033['$l_ptr';10f"" "
                if [[ $c_ptr < 3 ]]; then let "c_ptr++"; let "l_ptr=l_ptr+2"
                    else
                        c_ptr=1; l_ptr=16
                fi
                printf "\033['$l_ptr';10f""*"; printf "\033[25;43f"

                
         fi
       
if [[ ! $cpu_family = 0 ]]; then

        if [[ $inputs = [zZ] ]]; then
                
                if [[ $c_ptr = 1 ]]; then if [[ $color1 -ge $step ]]; then let "color1=color1-step"; else color1=0; fi; ncolor1=$color1; LEN $color1; printf "\033[16;14f""%"$ncr"s""$color1"; ProgressBar ${color1} ${_end}; printf "\033[16;14f"; fi
                if [[ $c_ptr = 2 ]]; then if [[ $color2 -ge $step ]]; then let "color2=color2-step"; else color2=0; fi; ncolor2=$color2; LEN $color2; printf "\033[18;14f""%"$ncr"s""$color2"; ProgressBar ${color2} ${_end}; printf "\033[18;14f"; fi
                if [[ $c_ptr = 3 ]]; then if [[ $color3 -ge $step ]]; then let "color3=color3-step"; else color3=0; fi; ncolor3=$color3; LEN $color3; printf "\033[20;14f""%"$ncr"s""$color3"; ProgressBar ${color3} ${_end}; printf "\033[20;14f"; fi
               
                

                
        fi

        if [[ $inputs = [xX] ]]; then
                
                let "maxi=65535-step"
                if [[ $c_ptr = 1 ]]; then if [[ $color1 -le $maxi ]]; then let "color1=color1+step"; else color1=65535; fi; ncolor1=$color1; LEN $color1; printf "\033[16;14f""%"$ncr"s""$color1"; ProgressBar ${color1} ${_end}; printf "\033[16;14f"; fi
                if [[ $c_ptr = 2 ]]; then if [[ $color2 -le $maxi ]]; then let "color2=color2+step"; else color2=65535; fi; ncolor2=$color2; LEN $color2; printf "\033[18;14f""%"$ncr"s""$color2"; ProgressBar ${color2} ${_end}; printf "\033[18;14f"; fi
                if [[ $c_ptr = 3 ]]; then if [[ $color3 -le $maxi ]]; then let "color3=color3+step"; else color3=65535; fi; ncolor3=$color3; LEN $color3; printf "\033[20;14f""%"$ncr"s""$color3"; ProgressBar ${color3} ${_end}; printf "\033[20;14f"; fi
                
                
        fi
        
        if [[ $inputs = [cC] ]]; then 
                    case "$step" in
                    4096 ) step=3072;;
                    3072 ) step=2048;;
                    2048 ) step=1560;;
                    1560 ) step=1024;;
                    1024 ) step=512;;
                    512 ) step=255;;
                    255 ) step=128;;
                    128 ) step=65;;
                    65 ) step=15;;
                    15 ) step=1;;
                    esac
                     LEN $step ; printf "\033[22;14f"'%'$ncr's'$step; STEP_BAR_CORR; ProgressBar ${step2} ${_end}; printf "\033[22;17f" 
        fi

        if [[ $inputs = [vV] ]]; then 
                    case "$step" in
                    1 ) step=15;;
                    15 ) step=65;;
                    65 ) step=128;;
                    128 ) step=255;;
                    255 ) step=512;;
                    512 ) step=1024;;
                    1024 ) step=1560;;
                    1560 ) step=2048;;
                    2048 ) step=3072;;
                    3072) step=4096;;
                    
                    esac
                     LEN $step ; printf "\033[22;14f"'%'$ncr's'$step; STEP_BAR_CORR; ProgressBar ${step2} ${_end}; printf "\033[22;17f"
        fi

        if [[ $inputs = [qQ2-3] ]]; then  unset inputs; cvar=1; break;   fi




        if [[ $inputs = [bB] ]]; then inputs="s"
            if [[ $swap_one = 0 ]]; then 
            if [[ $c_ptr = 1 ]]; then color1=$(echo "$old_color" | tr -d ' {}' | cut -f1 -d ','); LEN $color1; printf "\033[16;14f""%"$ncr"s""$color1"; ProgressBar ${color1} ${_end}; printf "\033[16;14f"; fi
            if [[ $c_ptr = 2 ]]; then color2=$(echo "$old_color" | tr -d ' {}' | cut -f2 -d ','); LEN $color2; printf "\033[18;14f""%"$ncr"s""$color2"; ProgressBar ${color2} ${_end}; printf "\033[18;14f"; fi
            if [[ $c_ptr = 3 ]]; then color3=$(echo "$old_color" | tr -d ' {}' | cut -f3 -d ','); LEN $color3; printf "\033[20;14f""%"$ncr"s""$color3"; ProgressBar ${color3} ${_end}; printf "\033[20;14f"; fi
            swap_one=1
            else
            if [[ $c_ptr = 1 ]]; then color1=$ncolor1; LEN $color1; printf "\033[16;14f""%"$ncr"s""$color1";ProgressBar ${color1} ${_end};printf "\033[16;14f"; fi
            if [[ $c_ptr = 2 ]]; then color2=$ncolor2; LEN $color2; printf "\033[18;14f""%"$ncr"s""$color2";ProgressBar ${color2} ${_end};printf "\033[18;14f"; fi
            if [[ $c_ptr = 3 ]]; then color3=$ncolor3; LEN $color3; printf "\033[20;14f""%"$ncr"s""$color3";ProgressBar ${color3} ${_end};printf "\033[20;14f"; fi
            swap_one=0
            fi
        fi
         
        if [[ $inputs = [uU] ]]; then 
            inputs="s"
        if [[ $swap_all = 0 ]]; then
        color1=$(echo "$old_color" | tr -d ' {}' | cut -f1 -d ','); color2=$(echo "$old_color" | tr -d ' {}' | cut -f2 -d ','); color3=$(echo "$old_color" | tr -d ' {}' | cut -f3 -d ',')
        swap_all=1
        swap_one=1
        else
        color1=$ncolor1; color2=$ncolor2; color3=$ncolor3; swap_all=0; swap_one=0
        fi
        LEN $color1; printf "\033[16;14f""%"$ncr"s""$color1"; ProgressBar ${color1} ${_end}; printf "\033[16;14f"
        LEN $color2; printf "\033[18;14f""%"$ncr"s""$color2"; ProgressBar ${color2} ${_end}; printf "\033[18;14f"
        LEN $color3; printf "\033[20;14f""%"$ncr"s""$color3"; ProgressBar ${color3} ${_end}; printf "\033[20;14f"
        fi                  
 else
        if [[ $inputs = [zZ] ]]; then
                
                if [[ $c_ptr = 1 ]]; then if [[ $color1 -ge $step ]]; then let "color1=color1-step"; else color1=0; fi; ncolor1=$color1; LEN $color1; printf "\033[16;14f""%"$ncr"s""$color1"'                             '; printf "\033[16;14f"; fi
                if [[ $c_ptr = 2 ]]; then if [[ $color2 -ge $step ]]; then let "color2=color2-step"; else color2=0; fi; ncolor2=$color2; LEN $color2; printf "\033[18;14f""%"$ncr"s""$color2"'                             '; printf "\033[18;14f"; fi
                if [[ $c_ptr = 3 ]]; then if [[ $color3 -ge $step ]]; then let "color3=color3-step"; else color3=0; fi; ncolor3=$color3; LEN $color3; printf "\033[20;14f""%"$ncr"s""$color3"'                             '; printf "\033[20;14f"; fi
               
                

                
        fi

        if [[ $inputs = [xX] ]]; then
                
                let "maxi=65535-step"
                if [[ $c_ptr = 1 ]]; then if [[ $color1 -le $maxi ]]; then let "color1=color1+step"; else color1=65535; fi; ncolor1=$color1; LEN $color1; printf "\033[16;14f""%"$ncr"s""$color1"'                         '; printf "\033[16;14f"; fi
                if [[ $c_ptr = 2 ]]; then if [[ $color2 -le $maxi ]]; then let "color2=color2+step"; else color2=65535; fi; ncolor2=$color2; LEN $color2; printf "\033[18;14f""%"$ncr"s""$color2"'                         '; printf "\033[18;14f"; fi
                if [[ $c_ptr = 3 ]]; then if [[ $color3 -le $maxi ]]; then let "color3=color3+step"; else color3=65535; fi; ncolor3=$color3; LEN $color3; printf "\033[20;14f""%"$ncr"s""$color3"'                         '; printf "\033[20;14f"; fi
                
                
        fi
        
        if [[ $inputs = [cC] ]]; then 
                    case "$step" in
                    4096 ) step=2048;;
                    2048 ) step=1024;;
                    1024 ) step=512;;
                    512 ) step=255;;
                    255 ) step=128;;
                    128 ) step=65;;
                    65 ) step=15;;
                    15 ) step=1;;
                    esac
                     LEN $step ; printf "\033[22;14f"'%'$ncr's'$step'      '; printf "\033[22;17f" 
        fi

        if [[ $inputs = [vV] ]]; then 
                    case "$step" in
                    1 ) step=15;;
                    15 ) step=65;;
                    65 ) step=128;;
                    128 ) step=255;;
                    255 ) step=512;;
                    512 ) step=1024;;
                    1024 ) step=2048;;
                    2048 ) step=4096;;
                    esac
                     LEN $step ; printf "\033[22;14f"'%'$ncr's'$step'      '; printf "\033[22;17f"
        fi

        if [[ $inputs = [qQ2-3] ]]; then  unset inputs; cvar=1; break;   fi

        if [[ $inputs = [bB] ]]; then inputs="s"
            if [[ $swap_one = 0 ]]; then 
            if [[ $c_ptr = 1 ]]; then color1=$(echo "$old_color" | tr -d ' {}' | cut -f1 -d ','); LEN $color1; printf "\033[16;14f""%"$ncr"s""$color1"'                         '; printf "\033[16;14f"; fi
            if [[ $c_ptr = 2 ]]; then color2=$(echo "$old_color" | tr -d ' {}' | cut -f2 -d ','); LEN $color2; printf "\033[18;14f""%"$ncr"s""$color2"'                         '; printf "\033[18;14f"; fi
            if [[ $c_ptr = 3 ]]; then color3=$(echo "$old_color" | tr -d ' {}' | cut -f3 -d ','); LEN $color3; printf "\033[20;14f""%"$ncr"s""$color3"'                         '; printf "\033[20;14f"; fi
            swap_one=1
            else
            if [[ $c_ptr = 1 ]]; then color1=$ncolor1; LEN $color1; printf "\033[16;14f""%"$ncr"s""$color1"'                         '; printf "\033[16;14f"; fi
            if [[ $c_ptr = 2 ]]; then color2=$ncolor2; LEN $color2; printf "\033[18;14f""%"$ncr"s""$color2"'                         '; printf "\033[18;14f"; fi
            if [[ $c_ptr = 3 ]]; then color3=$ncolor3; LEN $color3; printf "\033[20;14f""%"$ncr"s""$color3"'                         '; printf "\033[20;14f"; fi
            swap_one=0
            fi
        fi
         
        if [[ $inputs = [uU] ]]; then 
            inputs="s"
        if [[ $swap_all = 0 ]]; then
        color1=$(echo "$old_color" | tr -d ' {}' | cut -f1 -d ','); color2=$(echo "$old_color" | tr -d ' {}' | cut -f2 -d ','); color3=$(echo "$old_color" | tr -d ' {}' | cut -f3 -d ',')
        swap_all=1
        swap_one=1
        else
        color1=$ncolor1; color2=$ncolor2; color3=$ncolor3; swap_all=0; swap_one=0
        fi
        LEN $color1; printf "\033[16;14f""%"$ncr"s""$color1"'                         '; printf "\033[16;14f"
        LEN $color2; printf "\033[18;14f""%"$ncr"s""$color2"'                         '; printf "\033[18;14f"
        LEN $color3; printf "\033[20;14f""%"$ncr"s""$color3"'                         '; printf "\033[20;14f"
        fi                  

fi
        
        if [[ $inputs = [zZxXsSaA] ]]; then  RET_BORDER; if [[ $border = 0 ]]; then osascript -e "tell application \"Terminal\" to set ""$token"" color of window 1 to {"$color1", "$color2", "$color3"}"; fi ; fi   & 

        if [[ $inputs = "" ]]; then printf "\033[2A"; break; fi
        
        read -s -n 1  inputs
        
done

if [[ $token = "background" ]]; then current_background="{"$color1", "$color2", "$color3"}"
            if [[ "$current_background" = "$old_background" ]]; then swap_preset=0; fi
        else
         current_foreground="{"$color1", "$color2", "$color3"}"
         if [[ "$current_foreground" = "$old_foreground" ]]; then swap_preset=0; fi
fi


}

SAVE_ORIGINAL_PRESET(){
                        let "preset_num=inputs-1"
                        GET_DATA_OF_PRESET_NUMBER $preset_num
                        current_preset="${plist[preset_num]}"
                        old_preset="$current_preset"
                        old_BackgroundColor="$current_background"
                        old_FontName="$current_fontname"
                        old_FontSize="$current_fontsize"
                        old_TextColor="$current_foreground"


}

SAVE_NEW_PRESET(){

                        new_preset="$current_preset"
                        new_background="$current_background"
                        new_fontname="$current_fontname"
                        new_fontsize="$current_fontsize"
                        new_foreground="$current_foreground"

}

RESTORE_NEW_PRESET(){

                        current_preset="$new_preset"
                        current_background="$new_background"
                        current_fontname="$new_fontname"
                        current_fontsize="$new_fontsize"
                        current_foreground="$new_foreground"

}

RESTORE_ORIGINAL_PRESET(){
                        
                        current_preset="$old_preset"
                        current_background="$old_BackgroundColor"
                        current_fontname="$old_FontName"
                        current_fontsize="$old_FontSize"
                        current_foreground="$old_TextColor"

}

CUSTOM_SET_EDITED_THEME(){
osascript -e "tell application \"Terminal\" to set background color of window 1 to $current_background"
osascript -e "tell application \"Terminal\" to set normal text color of window 1 to $current_foreground"
set_font "$current_fontname" $current_fontsize
}

EDIT_PRESET_UPDATE_SCREEN(){
                        printf "\033[0;0H"
                        if [[ $loc = "ru" ]]; then
                        printf '\n                              Редактирование  пресета:                        \n'
                        printf '\n   '
	                    printf '.%.0s' {1..74}
                        
                        
			               else
                        printf '\n                               Edit the preset                                \n'
                        printf '\n   '
	                    printf '.%.0s' {1..74}
                        fi
                        printf '\n\n'

name_lenth=${#current_preset}
let "ncorr=30-name_lenth"
font_name_lenth=${#current_fontname}
if [[ ${#current_fontname} -gt 30 ]]; then current_fontname_s="${current_fontname:0:28}"".."; else current_fontname_s="$current_fontname"; fi
let "fcorr=32-font_name_lenth"
                        if [[ $loc = "ru" ]]; then
printf '             1)   Имя пресета:      '"$current_preset""%"$ncorr"s"'\n'
printf '             2)   Цвет фона:        '"$current_background"'     \n'
printf '             3)   Цвет текста:      '"$current_foreground"'     \n'
printf '             4)   Название шрифта:  '"$current_fontname_s""%"$fcorr"s"'\n'
printf '             5)   Размер шрифта:    '"$current_fontsize"'       \n\n'
printf '   '
printf '.%.0s' {1..74}
printf '\n\n  '
                        else

printf '             1)   Preset Name:      '"$current_preset""%"$ncorr"s"'\n'
printf '             2)   Background color: '"$current_background"'      \n'
printf '             3)   Text color:       '"$current_foreground"'      \n'
printf '             4)   Font Name:        '"$current_fontname_s""%"$fcorr"s"'\n'
printf '             5)   Font size:        '"$current_fontsize"'      \n\n'
printf '   '
printf '.%.0s' {1..74}
printf '\n\n  '
                        fi

}

EDIT_PRESET_NAME(){

                        unset demo
                                GET_APP_ICON
                                if [[ $loc = "ru" ]]; then
                        if demo=$(osascript -e 'set T to text returned of (display dialog "Имя нового пресета:" '"${icon_string}"' buttons {"Отменить", "OK"} default button "OK" default answer "'"${editing_preset}"'")'); then cancel=0; else cancel=1; fi 2>/dev/null
                                else
                        if demo=$(osascript -e 'set T to text returned of (display dialog "New preset name:" '"${icon_string}"' buttons {"Cancel", "OK"} default button "OK" default answer "'"${editing_preset}"'")'); then cancel=0; else cancel=1; fi 2>/dev/null 
                                fi
                        demo=`echo "$demo" | tr -d \"\'\;\+\-\(\)`
                        demo=`echo "$demo" | tr -cd "[:print:]\n"`
                        demo=`echo "$demo" | tr -d "={}]><[&^$"`
                        demo=$(echo "${demo}" | sed 's/^[ \t0-9]*//')
                        editing_preset="$demo"

}

UPDATE_PRESETS_LIST(){
clear && printf '\e[8;'${lines}';80t' && printf '\e[3J' && printf "\033[0;0H"

 if [[ $loc = "ru" ]]; then
        printf '                     Редактор пресетов встроенных тем                           '
			else
        printf '                      Built-in Themes Preset Editor                             '
 fi

GET_PRESETS_NAMES
currents=`echo "$MountEFIconf" | grep -A 1 -e "<key>CurrentPreset</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`

                                    if [[ $loc = "ru" ]]; then
                        printf '\n                              Список пресетов:                                  '
                        printf '\n   '
	                    printf '.%.0s' {1..74}
                        
                        
			               else
                        printf '\n                               Preset List:                                     '
                        printf '\n   '
	                    printf '.%.0s' {1..74}
                        fi
                        printf '\n\n'
var6=0; chn=1
while [[ ! $var6 = $pcount ]] 
do
            if [[ $chn -le 9 ]]; then
            printf '                           '$chn')      '
            else
            printf '                          '$chn')      '
            fi
            echo "${plist[var6]}"
            if [[ "${plist[var6]}" = "$currents" ]]; then currents=$var6; let "currents=currents+5"; fi
let "chn++"; let "var6++"
done
             printf '\n  '; printf '.%.0s' {1..74}
                if [[ $loc = "ru" ]]; then
        
        printf '\n           * Звёздочкой отмечен пресет который используется по умолчанию       \n' 
        printf '              Выбор номера темы применяет её и запускает редактор темы       \n\n'
        printf '                     Z/X)    Выбрать дефолтный пресет                          \n'                  
        printf '                       R)    Удалить пресет темы                               \n'
        printf '                       N)    Добавить пресет темы                              \n'
        printf '                       L)    Указатели загрузчиков для встроенных тем          \n'
        printf '                       S)    Указатели загрузчиков для системных тем           \n'
        printf '                       D)    Удалить всю базу кастомных указателей             \n'
        printf '                       Q)    Выход из редактора                                \n' 

                else    
        
        printf '\n        selecting a theme number applies it and launches the theme editor      \n'
        printf '                * The asterisk marks the default preset.                       \n\n'
        printf '                     Z/X)    Select default preset                             \n'
        printf '                       N)    Add theme preset                                  \n'
        printf '                       R)    Delete theme preset                               \n'
        printf '                       L)    Edit bootloaders pointer for built-in themes      \n'
        printf '                       S)    Bootloader pointers for system themes             \n'
        printf '                       D)    Delete all database custom bootloader pointers    \n'
        printf '                       Q)    Quit to the setup menu                            \n' 

                    fi
let "chn--";

}

UPDATE_FONTS_LIST(){

macos=`sw_vers -productVersion`
macos=`echo ${macos//[^0-9]/}`
macos=${macos:0:4}
if [[ "$macos" = "1014" ]] || [[ "$macos" = "1013" ]] || [[ "$macos" = "1012" ]] || [[ "$macos" = "1015" ]]; then
       
fontlist="Andale Mono;Courier;Courier Oblique;Courier Bold;Courier New;Courier New Italic;Courier New Bold;Courier New Bold Italic;Menlo Regular;\
Menlo Bold;Menlo Italic;Menlo Bold Italic;Monaco;PT Mono;PT Mono Bold;SF Mono Light;SF Mono Light Italic;SF Mono Medium;SF Mono Medium Italic;SF Mono Regular;\
SF Mono Regular Italic;SF Mono Semibold;SF Mono Semibold Italic;SF Mono Bold;SF Mono Bold Italic;SF Mono Heavy;SF Mono Heavy Italic;"

else 

fontlist="Andale Mono;Courier;Courier Oblique;Courier Bold;Courier New;Courier New Italic;Courier New Bold;Courier New Bold Italic;Menlo Regular;\
Menlo Bold;Menlo Italic;Menlo Bold Italic;Monaco;PT Mono;PT Mono Bold;Osaka-Mono"
fi

IFS=';' 
fonts=($fontlist)
unset IFS;
font_counts=${#fonts[@]};
let "lines=17+font_counts"
printf '\e[8;'${lines}';80t' && printf '\e[3J' && printf "\033[0;0H"
printf "\033[14;0H"
printf "\033[?25l"
printf "%"80"s"'\n'"%"80"s"'\n'"%"80"s"
chn=1
printf "\033[14;0H"
for (( i=0; i<${#fonts[@]}; i++ )); 
            do printf '                                  '"${fonts[$i]}"'              \n'; let "chn++"; done
chn=1
printf '\n\n'
}


EDIT_FONTNAME(){
f_ptr=0; l_ptr=13 ; max=${#fonts[@]}; let "maxl=max+12"; let "max--"; let "c_pos=maxl+3"
for (( i=0; i<${#fonts[@]}; i++ )); do if [[ "$current_fontname" = "${fonts[$i]}" ]]; then break; else let "f_ptr++"; let "l_ptr++"; fi; done
if [[ $i = ${#fonts[@]} ]]; then f_ptr=0; l_ptr=13; fi
printf "\033['$l_ptr';32f""*"
 vc=0
                        unset inputs
 while [[ $vc = 0 ]]; do
                    while [[ ! ${inputs} =~ ^[aAsSqQ4]+$ ]]; do
                        read -s -n 1  inputs 
                        if [[ ! $inputs = [aAsSqQ4] ]]; then 
                        if [[ ${inputs} = "" ]]; then  unset inputs; fi 
                        fi
                        printf '\r'
                    done 
                        printf "\033[?25l"
         if [[ $inputs = [sS] ]]; then
                        printf "\033['$l_ptr';32f"" "
                        if [[ $f_ptr > 0 ]]; then let "f_ptr--"; let "l_ptr--"
                            else
                        let f_ptr=$max; l_ptr=$maxl
                        fi
                        printf "\033['$l_ptr';32f""*"
         fi

         if [[ $inputs = [aA] ]]; then
                printf "\033['$l_ptr';32f"" "
                if [[ "${f_ptr}" -lt "${max}" ]]; then let "f_ptr++"; let "l_ptr++"
                    else
                        f_ptr=0; l_ptr=13
                fi
                printf "\033['$l_ptr';32f""*"
         fi
                      
                        current_fontname="${fonts[$f_ptr]}"
                         if [[ $inputs = [aAsS] ]];  then set_font "$current_fontname" $current_fontsize; fi &
                         printf "\033[8;37f""$current_fontname"'                    '
                         if [[ $inputs = [qQ4] ]]; then  vc=1; break; fi
                        read -s -n 1  inputs 
done 
}

EDIT_LODERS_NAMES(){
                                unset demo
                        GET_APP_ICON
                                if [[ $loc = "ru" ]]; then
                        if demo=$(osascript -e 'set T to text returned of (display dialog "Псевдоним загрузчика (максимум 8 символов):" '"${icon_string}"' buttons {"Отменить", "OK"} default button "OK" default answer "'"${new_loader}"'")'); then cancel=0; else cancel=1; fi 2>/dev/null
                                else
                        if demo=$(osascript -e 'set T to text returned of (display dialog "BootLoader alias (max 8 characters):" '"${icon_string}"' buttons {"Cancel", "OK"} default button "OK" default answer "'"${new_loader}"'")'); then cancel=0; else cancel=1; fi 2>/dev/null 
                                fi
                        demo=`echo "$demo" | tr -d \"\'\;\+\-\(\)`
                        demo=`echo "$demo" | tr -cd "[:print:]\n"`
                        demo=`echo "$demo" | tr -d "={}]><[&^$"`
                        demo=$(echo "${demo}" | sed 's/^[ \t]*//')
                        
                        

}

function Progress {
let _progress=(${1}*100/${2}*100)/100
let _done=(${_progress}*3)/10
let _left=30-$_done
_fill=$(printf "%${_done}s")
_empty=$(printf "%${_left}s")
printf "   |${_fill// /|}${_empty// / }|  code: ${1}  "
}

COLOR_PARSER(){
IFS=';'; lcolor=($1); unset IFS; plcolor=${#lcolor[@]}; let "lpos=plcolor-1"

code=${lcolor[lpos]}
    cl_bold=0
    cl_dim=0
    cl_underl=0
    cl_blink=0
    cl_inv=0
    cl_bit=0
if [[ $lpos -ge 1 ]]; then
    cl_normal=0
for (( i=0; i<=(( $lpos-1 )); i++)) do
    case ${lcolor[i]} in
    1 ) cl_bold=1;;
    2 ) cl_dim=1;;
    4 ) cl_underl=1;;
    5 ) if [[ ! $cl_bit = 1 ]] && [[ ! $plcolor = 3 ]] && [[ ! $cl_normal = 1 ]]; then cl_blink=1 ; fi ;;
    7 ) cl_inv=1;;
    38 ) cl_bit=1;;              
    esac
    if [[ $cl_bit = 1 ]] && [[ $plcolor = 3 ]]; then cl_normal=1; fi
done
else 
    cl_normal=1
fi 
    
}

SHOW_TEXT_FLAGS(){
if [[ $cl_normal = 1 ]]; then printf '\033[13;25f''√' ;else printf '\033[13;25f'' '; fi
if [[ $cl_bold = 1 ]]; then printf '\033[14;25f''√' ;else printf '\033[14;25f'' '; fi
if [[ $cl_dim = 1 ]]; then printf '\033[15;25f''√' ;else printf '\033[15;25f'' '; fi
if [[ $cl_underl = 1 ]]; then printf '\033[16;25f''√'; else printf '\033[16;25f'' '; fi
if [[ $cl_blink = 1 ]]; then printf '\033[17;25f''√' ;else printf '\033[17;25f'' '; fi
if [[ $cl_inv = 1 ]]; then printf '\033[18;25f''√' ;else printf '\033[18;25f'' '; fi
if [[ $cl_bit = 1 ]]; then printf '\033[20;25f''√'; printf '\033[19;25f'' '; fi 
if [[ $cl_bit = 0 ]]; then printf '\033[19;25f''√'; printf '\033[20;25f'' '; fi
}

GET_POINTER_INPUT(){
            
                        
             while [[ ! ${inputs} =~ ^[0-7zZxXeEqQcCoOaAsS]+$ ]]; do
             read -s -n 1 inputs 
        
            if [[ ! $inputs = [0-7zZxXeEqQcCoOaAsS] ]]; then 
                        if [[ ${inputs} = "" ]]; then  unset inputs; fi 
                        
                        printf '\r'
                        
            fi
            printf '\r'
            done
}

SET_STRIP(){

posit=36; code2=40
for ((i=0;i<16;i++)) do 
if [[ ${cl_bit} = 0 ]]; then
printf '\033[14;'$posit'f\e['$code2'm''   ''\e[0m'
printf '\033[15;'$posit'f\e['$code2'm''   ''\e[0m'
printf '\033[16;'$posit'f\e['$code2'm''   ''\e[0m'
printf '\033[17;'$posit'f\e['$code2'm''   ''\e[0m'
if [[ $code2 = 47 ]]; then code2=99; fi
let "code2++"
else
printf '\033[14;'$posit'f\e['$rcol'm''   ''\e[0m'
printf '\033[15;'$posit'f\e['$rcol'm''   ''\e[0m'
printf '\033[16;'$posit'f\e['$rcol'm''   ''\e[0m'
printf '\033[17;'$posit'f\e['$rcol'm''   ''\e[0m'
fi
let "posit=posit+3"
done

}

SHOW_COLOR(){
printf "\r\033[5;f\033['$c_clov'C"'\e['$new_color'm'"${Clover}"'\e[0m'
printf "\033[7;f\033['$c_oc'C"'\e['$new_color'm'"${OpenCore}"'\e[0m'
printf '\033[24;42f''                    '
}

MAKE_COLOR(){
unset new_color
if [[ $cl_normal = 1 ]]; then  cl_bold=0; cl_dim=0; cl_underl=0; cl_blink=0; cl_inv=0; fi
if [[ $cl_normal = 0 ]]; then
if [[ $cl_bold = 1 ]]; then new_color+="1;" ;fi
if [[ $cl_dim = 1 ]]; then new_color+="2;" ;fi
if [[ $cl_underl = 1 ]]; then new_color+="4;" ;fi
if [[ $cl_blink = 1 ]]; then new_color+="5;" ;fi
if [[ $cl_inv = 1 ]]; then new_color+="7;" ;fi
fi
if [[ $cl_bit = 1 ]]; then new_color+="38;5;"; fi 
rcol=$(echo $new_color | sed s'/38;5;/48;5;/' | sed s'/4;//' | sed s'/7;//')
new_color+="$code"; rcol+="$code"
}
################################# редактор темы и псевдонима загрузчиков ##################################################################

EDIT_LOADER_POINTER(){
unset inputs
printf "\033[?25l"
old_clover="$Clover"; clover2="$Clover"
old_opencore="$OpenCore"; opencore2="$OpenCore"
old_themeldrs="$themeldrs"
if [[ $old_themeldrs = "" ]]; then old_themeldrs=37; fi
new_color=$old_themeldrs; new_color2=$new_color
if [[ $loc = "ru" ]]; then
        printf '                         Редактор вида указателя загрузчика                         '
			else
        printf '                             Loader Pointer View Editor                             '
 fi
printf ' %.0s' {1..88}
printf '\n   '
printf '.%.0s' {1..82}
printf ' %.0s' {1..88}
printf '   '
printf '      1)   +   SanDisk SD8SBAT128G1122                 disk0s1        209.7 Mb     \n'
printf '      2) ...   Hitachi HDS721010CLA330                 disk1s1        209.7 Mb     \n'
printf '      3)   +   ST9160301AS                             disk2s1        209.7 Mb     '
printf ' %.0s' {1..88}
printf '\n   '
printf '.%.0s' {1..82}
printf ' %.0s' {1..88}
                if [[ $loc = "ru" ]]; then
printf '                Текст                                       Цвет                           '
printf '                                                                                        '
printf '     0) Нормальный                   \n'  
printf '     1) Жирный/яркий                 \n'
printf '     2) Тусклый                      \n'
printf '     3) Подчёркнутый                 \n'
printf '     4) Мигающий                     \n'
printf '     5) Инверсный                    \n'
printf '     6) Цветов      16               \n'
printf '     7) Цветов     256               \n'
                    else
printf '                Text                                        Color                          '
printf '                                                                                        '
printf '     0) Normal                       \n'  
printf '     1) Bold/Bright                  \n'
printf '     2) Dim                          \n'
printf '     3) Underlined                   \n'
printf '     4) Blink                        \n'
printf '     5) Inverse                      \n'
printf '     6) Colors      16               \n'
printf '     7) Colors     256               \n'
                    fi
SHOW_COLOR
COLOR_PARSER ${old_themeldrs}
SHOW_TEXT_FLAGS
if [[ ${cl_bit} = 0 ]]; then  
if [[ ${code} -ge 30 ]] && [[ ${code} -le 37 ]]; then let "clptr=code-29"; fi
if [[ ${code} -ge 90 ]] && [[ ${code} -le 97 ]]; then let "clptr=code-89"; fi
if [[ ${code} -ge 30 ]] && [[ ${code} -le 37 ]]; then let "NN=(code-29)*3+34" ;fi 
if [[ ${code} -ge 90 ]] && [[ ${code} -le 97 ]]; then let "NN=3*(code-89)+58"; fi
printf '\033[13;'$NN'f''•'
printf '\033[18;'$NN'f''•'
else MAKE_COLOR; fi
SET_STRIP 
if [[ ! ${cl_bit} = 0 ]]; then
printf '\033[20;36f'; Progress ${code} 255
fi
printf '\033[22;5f'
printf '.%.0s' {1..82}
printf '\033[24;7f'
                                if [[ $loc = "ru" ]]; then
                        printf 'Выберите от 1 до 7 (или Z/X, Q, E):                                     \n\n'
                        printf '             Z/X - выбор цвета                                            \n'
                        printf '             A/S - выбор цвета.быстрая прокрутка (256 цветов)             \n'
                        printf '             C   - указать псевдоним для загрузчика Clover                \n'
                        printf '             O   - указать псевдоним для загрузчика Open Core             \n'
                        printf '             E/E - отменить/возвратить результаты редактирования          \n'
                        printf '             Q   - вернуться в меню сохранив новые настройки пресета      \n'
			                   else
                        printf 'Select from 1 to 7 (or Z/X, Q, E):                                      \n\n'
                        printf '             Z/X - select color                                           \n'
                        printf '             A/S - select color.fast forward list (256 colors)            \n'
                        printf '             C   - Specify an alias for the Clover bootloader             \n'
                        printf '             O   - Specify an alias for the Open Core bootloader          \n'
                        printf '             E/E - cancel/return the editing results                      \n'
                        printf '             Q   - return to the menu saving the new preset settings      \n'
                                fi
                    cvar=0
                    while [[ $cvar = 0 ]]; 
                    do
                    printf "\033[?25l"
                    
                    GET_POINTER_INPUT
                    

                    if [[ ${inputs} = [0-7] ]]; then
                               
                               case ${inputs} in  
                             1)   if [[ $cl_bold = 1 ]]; then cl_bold=0; elif [[ $cl_bold = 0 ]]; then cl_bold=1; cl_normal=0; fi;;
                             2)   if [[ $cl_dim = 1 ]]; then cl_dim=0; elif [[ $cl_dim = 0 ]]; then cl_dim=1; cl_normal=0; fi;;
                             3)   if [[ $cl_underl = 1 ]]; then cl_underl=0; elif [[ $cl_underl = 0 ]]; then cl_underl=1; cl_normal=0; fi ;;
                             4)   if [[ $cl_blink = 1 ]]; then cl_blink=0; elif [[ $cl_blink = 0 ]]; then cl_blink=1; cl_normal=0; fi ;;
                             5)   if [[ $cl_inv = 1 ]]; then cl_inv=0; elif [[ $cl_inv = 0 ]]; then cl_inv=1; cl_normal=0; fi ;;
                             6)   if [[ $cl_bit = 1 ]]; then cl_bit=0; fi ; MAKE_COLOR; SET_STRIP; SHOW_COLOR; printf '\033[20;36f'; printf ' %.0s' {1..48}; code=37; if [[ ${code} -ge 30 ]] && [[ ${code} -le 37 ]]; then let "NN=(code-29)*3+34" ;fi ;printf '\033[13;'$NN'f''•  '; printf '\033[18;'$NN'f''•  ';;  
                             7)   if [[ $cl_bit = 0 ]]; then cl_bit=1; fi ; printf '\033[13;'$NN'f''   '; printf '\033[18;'$NN'f''   '; printf '\033[20;36f'; code=127; Progress ${code} 255;;
                             0)   if [[ $cl_normal = 0 ]]; then cl_normal=1;  fi ;;
                               esac
                             if [[ $cl_bold = 0 ]] && [[ $cl_dim = 0 ]] && [[ $cl_underl = 0 ]] && [[ $cl_blink = 0 ]] && [[ $cl_inv = 0 ]]; then cl_normal=1; fi
                              
                             MAKE_COLOR
                             
                             SET_STRIP 
                             SHOW_COLOR 
                             
                             SHOW_TEXT_FLAGS
                            
                    fi
                
                if [[ $inputs = [xX] ]] && [[ $cl_bit = 0 ]]; then
            
                
                printf '\033[13;'$NN'f''   '
                printf '\033[18;'$NN'f''   '

                
                if [[ ${code} = 37 ]]; then code=90 ; elif [[ ${code} = 97 ]]; then code=30
                    else
                if [[ ${code} -ge 30 ]] && [[ ${code} -le 36 ]]; then let "code++"; fi
                if [[ ${code} -ge 90 ]] && [[ ${code} -le 96 ]]; then let "code++"; fi
                    fi
                if [[ ${code} -ge 30 ]] && [[ ${code} -le 37 ]]; then let "NN=(code-29)*3+34" ;fi 
                if [[ ${code} -ge 90 ]] && [[ ${code} -le 97 ]]; then let "NN=3*(code-89)+58"; fi
 
                printf '\033[13;'$NN'f''•  '
                printf '\033[18;'$NN'f''•  '
                
                MAKE_COLOR
                
                SHOW_COLOR &
               
         fi

         if [[ $inputs = [zZ] ]] && [[ $cl_bit = 0 ]]; then
                
                printf '\033[13;'$NN'f''   '
                printf '\033[18;'$NN'f''   '

                if [[ ${code} = 30 ]]; then code=97 ; elif [[ ${code} = 90 ]]; then code=37
                    else
                if [[ ${code} -ge 31 ]] && [[ ${code} -le 37 ]]; then let "code--"; fi
                if [[ ${code} -ge 91 ]] && [[ ${code} -le 97 ]]; then let "code--"; fi
                    fi
                if [[ ${code} -ge 30 ]] && [[ ${code} -le 37 ]]; then let "NN=(code-29)*3+34" ;fi 
                if [[ ${code} -ge 90 ]] && [[ ${code} -le 97 ]]; then let "NN=3*(code-89)+58"; fi
 
                printf '\033[13;'$NN'f''•  '
                printf '\033[18;'$NN'f''•  '
                
                MAKE_COLOR
                

                SHOW_COLOR &
                
         fi

                 if [[ $inputs = [zZ] ]] && [[ $cl_bit = 1 ]]; then
                    if [[ $code -gt 0 ]]; then let "code--"; else code=255; fi
                    printf '\033[20;36f'; Progress ${code} 255
                    MAKE_COLOR
                    
                    SHOW_COLOR 
                    SET_STRIP 
                fi

                if [[ $inputs = [xX] ]] && [[ $cl_bit = 1 ]]; then
                    if [[ $code -lt 255 ]]; then let "code++"; else code=0; fi
                    printf '\033[20;36f'; Progress ${code} 255
                    MAKE_COLOR
                    
                    SHOW_COLOR 
                    SET_STRIP 
                fi
                if [[ $inputs = [aA] ]] && [[ $cl_bit = 1 ]]; then
                    if [[ $code -gt 9 ]]; then let "code=code-10"; else code=255; fi
                    printf '\033[20;36f'; Progress ${code} 255
                    MAKE_COLOR
                    
                    SHOW_COLOR 
                    SET_STRIP 
                fi

                if [[ $inputs = [sS] ]] && [[ $cl_bit = 1 ]]; then
                    if [[ $code -lt 245 ]]; then let "code=code+10"; else code=0; fi
                    printf '\033[20;36f'; Progress ${code} 255
                    MAKE_COLOR
                    
                    SHOW_COLOR 
                    SET_STRIP 
                fi

                if [[ $inputs = [eE] ]]; then 
                                    if [[ $cl_bit = 0 ]]; then printf '\033[13;'$NN'f''   ';  printf '\033[18;'$NN'f''   '; fi
                                    if [[ ! $new_color = $old_themeldrs ]]; then new_color2=$new_color; new_color=$old_themeldrs; else new_color=$new_color2; fi
                                    if [[ ! "$Clover" = "$old_clover" ]]; then clover2="$Clover"; Clover="$old_clover"; else Clover="$clover2"; fi
                                    if [[ ! "$OpenCore" = "$old_opencore" ]]; then opencore2="$OpenCore"; OpenCore="$old_opencore"; else OpenCore="$opencore2"; fi
                                    pclov=${#Clover}; let "c_clov=(9-pclov)/2+46"; poc=${#OpenCore}; let "c_oc=(9-poc)/2+46"
                                    printf "\033[5;f\033[45C"'          '; printf "\033[7;f\033[45C"'          '
                                    COLOR_PARSER $new_color
                                    MAKE_COLOR
                                    SHOW_COLOR 
                                    SET_STRIP 
                                    if [[ $cl_bit = 0 ]]; then 
                                     printf '\033[20;36f'; printf ' %.0s' {1..48}
                                     printf '\033[13;'$NN'f''   '
                                     printf '\033[18;'$NN'f''   '
                                     if [[ ${code} -ge 30 ]] && [[ ${code} -le 37 ]]; then let "NN=(code-29)*3+34" ;fi 
                                     if [[ ${code} -ge 90 ]] && [[ ${code} -le 97 ]]; then let "NN=3*(code-89)+58"; fi
                                     printf '\033[13;'$NN'f''•  '
                                     printf '\033[18;'$NN'f''•  '
                                    else 
                                        printf '\033[20;36f'; Progress ${code} 255;
                                     fi
                                    SHOW_TEXT_FLAGS
                                    
                fi
                if [[ $inputs = [cC] ]]; then 
                new_loader=$Clover                     
                EDIT_LODERS_NAMES
                if [[ ! $demo = "" ]]; then
                if [[ ${#demo} -gt 8 ]]; then demo="${demo:0:8}"; fi
                Clover="$demo"; pclov=${#Clover}; let "c_clov=(9-pclov)/2+46"; 
                printf "\r\033[5;f\033[45C"'          '
                SHOW_COLOR
                fi
                fi
                if [[ $inputs = [oO] ]]; then 
                new_loader=$OpenCore                     
                EDIT_LODERS_NAMES
                if [[ ! $demo = "" ]]; then
                if [[ ${#demo} -gt 8 ]]; then demo="${demo:0:8}"; fi
                OpenCore="$demo"; poc=${#OpenCore}; let "c_oc=(9-poc)/2+46"
                printf "\033[7;f\033[45C"'          '
                SHOW_COLOR
                fi
                fi
            
            if [[ $inputs = [qQ] ]]; then  unset inputs; cvar=1; break;   fi
            if [[ $inputs = "" ]]; then printf "\033[2A"; break; fi
        
            read -s -n 1  inputs
            if [[ $cl_normal = 1 ]]; then printf '\033[13;25f''√' ;else printf '\033[13;25f'' '; fi
        
done
}

ASK_SYSTEM_THEME(){
if [[ $loc = "ru" ]]; then
osascript <<EOD
tell application "System Events"    activate
set ThemeList to {"Basic", "Grass", "Homebrew", "Man Page", "Novel", "Ocean", "Pro", "Red Sands", "Silver Aerogel", "Solid Colors"}set FavoriteThemeAnswer to choose from list ThemeList with title "Выбор темы" with prompt "Для какой темы редактировать указатели?" default items "Basic" set FavoriteThemeAnswer to FavoriteThemeAnswer's item 1 (* extract choice from list *)
end tell
EOD
else
osascript <<EOD
tell application "System Events"    activate
set ThemeList to {"Basic", "Grass", "Homebrew", "Man Page", "Novel", "Ocean", "Pro", "Red Sands", "Silver Aerogel", "Solid Colors"}set FavoriteThemeAnswer to choose from list ThemeList with title "Choose theme" with prompt "What system theme set to edit?" default items "Basic"set FavoriteThemeAnswer to FavoriteThemeAnswer's item 1 (* extract choice from list *)
end tell
EOD
fi
}

ASK_STORE_OPTIONS(){
if [[ $loc = "ru" ]]; then
osascript <<EOD
tell application "System Events"    activate
set ThemeAsk to {"Для темы с которой они редактировались", "Для всех тем как указатели по умолчанию"}set FavoriteThemeAnswer to choose from list ThemeAsk with title "Сохранение указателей" with prompt "Как сохранить изменения указателей?" default items "Сохранить редакцию указателей для темы с которой они редактировались"set FavoriteThemeAnswer to FavoriteThemeAnswer's item 1 (* extract choice from list *)
end tell
EOD
else
osascript <<EOD
tell application "System Events"    activate
set ThemeAsk to {"For the theme with which they were edited", "For all themes as default bootloaders pointers"}set FavoriteThemeAnswer to choose from list ThemeAsk with title "Saving pointers" with prompt "How to save edited pointers?" default items "Сохранить редакцию указателей для темы с которой они редактировались"set FavoriteThemeAnswer to FavoriteThemeAnswer's item 1 (* extract choice from list *)
end tell
EOD
fi

}

GET_THEME_LOADERS(){
strng=$(echo "$MountEFIconf"  | grep -A 1 -e "<key>ThemeLoadersLinks</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' )
theme="$1"
current="$2"
if [[ "$theme" = "built-in" ]]; then NN="B,"; else NN="S,"; fi
check=$(echo $strng | grep -ow "$NN""$current")
if [[ ! $check = "" ]]; then
IFS='{'; llist=($strng); unset IFS; lptr=${#llist[@]}
for (( i=0; i<$lptr; i++ )) do
tname=$(echo "${llist[i]}" | cut -f2 -d ',')
if [[ "$tname" = "$current" ]]; then Loaders=$(echo "${llist[i]}" | cut -f3 -d ','); themeldrs=$(echo "${llist[i]}" | cut -f4 -d ','); break; fi
done
else
themeldrs=$(echo "$MountEFIconf"  | grep -A 1 -e "<key>ThemeLoaders</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n')
Loaders=$(echo "$MountEFIconf"  | grep -A 1 -e "<key>ThemeLoadersNames</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n')
fi
Clover=$(echo $Loaders | cut -f1 -d ";"); OpenCore=$(echo $Loaders | cut -f2 -d ";")
if [[ $Clover = "" ]]; then Clover="Clover"; fi; if [[ $OpenCore = "" ]]; then OpenCore="OpenCore"; fi
pclov=${#Clover}; 
poc=${#OpenCore}; 
let "c_clov=(9-pclov)/2+46"; let "c_oc=(9-poc)/2+46"
}

DEL_THEME_LOADERS(){
tllist=()
for (( i=0; i<$lptr; i++ )) do
tname=$(echo "${llist[i]}" | cut -f2 -d ',')
tname2="$NN""$tname"; current2="$NN""$current"
if [[ ! "$tname2" = "$current2" ]]; then tllist+=("${llist[i]}"); fi
done
tlptr=${#tllist[@]}; 
unset strng
if [[ ! tlptr = 0 ]]; then 
for (( i=0; i<$((tlptr-1)); i++ )) do
strng+="${tllist[i]}"'{'
done
plutil -replace ThemeLoadersLinks -string "$strng" ${HOME}/.MountEFIconf.plist; UPDATE_CACHE
else
plutil -replace ThemeLoadersLinks -string "" ${HOME}/.MountEFIconf.plist; UPDATE_CACHE
fi
}

ADD_THEME_LOADERS(){
unset strng
for (( i=0; i<$lptr; i++ )) do
strng+="${llist[i]}"'{'
done 
strng+="$NN""$current"','"$Loaders"','"$new_color"'{'
plutil -replace ThemeLoadersLinks -string "$strng" ${HOME}/.MountEFIconf.plist; UPDATE_CACHE
}

SET_THEMES_LOADERS(){
NN=$1
current="$2"
strng=$(echo "$MountEFIconf"  | grep -A 1 -e "<key>ThemeLoadersLinks</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' )
IFS='{'; llist=($strng); unset IFS; lptr=${#llist[@]}
check=$(echo "${llist[@]}" | grep -ow "$NN""$current")
if [[ $check = "" ]]; then 
ADD_THEME_LOADERS 
else 
DEL_THEME_LOADERS
strng=$(echo "$MountEFIconf"  | grep -A 1 -e "<key>ThemeLoadersLinks</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' )
IFS='{'; llist=($strng); unset IFS; lptr=${#llist[@]}
ADD_THEME_LOADERS
fi
}
############################################# конец редактора загрузчиков #################################################

THEME_EDITOR(){
UPDATE_CACHE
oldlines=$lines
GET_PRESETS_COUNTS
let "lines=22+pcount"
UPDATE_CACHE
var5=0
UPDATE_PRESETS_LIST
printf "\033['$currents';34f""*"
while [[ $var5 = 0 ]]; do 
printf '\n'
unset inputs
while [[ ! ${inputs} =~ ^[0-9nNrRzZxXlLsSdDqQ]+$ ]]; do 

SET_INPUT
                if [[ $loc = "ru" ]]; then
let "poscur=pcount+18"
printf "\033['$poscur';0f"
printf '  Выберите от 1 до '$chn' (или N/R/Z/X/S/L/D/Q ):           '
			else
let "poscur=pcount+18"
printf "\033['$poscur';0f"
printf '  Select from 1 to '$chn' (or N/R/Z/X/S/L/D/Q ):            '
                fi
printf "\033['$poscur';46f"
printf "\033[?25h"

        inputs="±"
        if [[ ${chn} -le 9 ]]; then
        IFS="±"; read -n 1  inputs ; unset IFS ; sym=1 
        else
            if [[ $loc = "ru" ]]; then
        READ_TWO_SYMBOLS 46
            else
        READ_TWO_SYMBOLS 45
        fi 
        fi
        if [[ ! $inputs = [qQnNrRzZxXlLsSdD] ]]; then 
                        if [[ ${inputs} = "" ]]; then  unset inputs; printf "\033[1A";  fi 
                        if [[ ${inputs} = 0 ]]; then  unset inputs; fi 2>&-
                        if [[ ${inputs} -gt "$chn" ]]; then unset inputs; fi 2>&-
                        printf '\r'
        fi
        printf "\033[?25l"

        if [[ $inputs = [zZxX] ]]; then 
                            printf "\033[?25l"
                            printf "\033['$currents';34f"" "; if [[ $loc = "ru" ]]; then let "poscur=pcount+18"; else let "poscur=pcount+18"; fi ; printf "\033['$poscur';46f"
                            current=`echo "$MountEFIconf" | grep -A 1 -e "<key>CurrentPreset</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
                            for ((i=0; i<$pcount; i++)); do if [[ "${plist[i]}" = "$current" ]]; then cp_pos=$i; break; fi; done
                            let "max_pos=pcount-1"
                            if [[ $inputs = [zZ] ]] && [[ "${cp_pos}" -gt "0" ]]; then let "cp_pos--"; plutil -replace CurrentPreset -string "${plist[$cp_pos]}" ${HOME}/.MountEFIconf.plist ; UPDATE_CACHE; fi 
                            if [[ $inputs = [xX] ]] && [[ "${cp_pos}" -lt "$max_pos" ]]; then let "cp_pos++"; plutil -replace CurrentPreset -string "${plist[$cp_pos]}" ${HOME}/.MountEFIconf.plist ; UPDATE_CACHE; fi 
                            currents=$cp_pos; let "currents=currents+5"; printf "\033['$currents';34f""*"
                            if [[ $loc = "ru" ]]; then let "poscur=pcount+18"; else let "poscur=pcount+18"; fi; printf "\033['$poscur';46f"'        '
                            printf "%"80"s"'\n'"%"80"s"
                            printf "\033[3A"; printf "\033['$poscur';46f"'        '
                            inputs="A"
        fi
    
done
        if [[ $inputs = [dD] ]]; then
                                GET_APP_ICON
                                if [[ $loc = "ru" ]]; then
                                if answer=$(osascript -e 'display dialog "Удалить всю базу кастомных указателей загрузчиков?" '"${icon_string}"''); then cancel=0; else cancel=1; fi 2>/dev/null
                                else
                                if answer=$(osascript -e 'display dialog "Delete all database of custom bootloader pointers?" '"${icon_string}"''); then cancel=0; else cancel=1; fi 2>/dev/null
                                fi
                               
                                if [[ $cancel = 0 ]]; then 
                                        plutil -replace ThemeLoaders -string "37" ${HOME}/.MountEFIconf.plist
                                        plutil -replace ThemeLoadersLinks -string " " ${HOME}/.MountEFIconf.plist
                                        plutil -replace ThemeLoadersNames -string "Clover;OpenCore" ${HOME}/.MountEFIconf.plist
                                        UPDATE_CACHE
                        SET_TITLE
                                        if [[ $loc = "ru" ]]; then
                        echo 'SUBTITLE="БАЗА УКАЗАТЕЛЕЙ ОЧИЩЕНА !"' >> ${HOME}/.MountEFInoty.sh
                        else
                        echo 'SUBTITLE="THE DATABASE WAS REMOVED !"' >> ${HOME}/.MountEFInoty.sh
                        fi
                        echo 'MESSAGE=" "' >> ${HOME}/.MountEFInoty.sh
                        DISPLAY_NOTIFICATION
                                fi
                                unset inputs 
                                            
        fi

        if [[ $inputs = [lL] ]]; then
                        oldlines=$lines; lines=32
                        clear && printf '\e[8;'${lines}';88t' && printf '\e[3J' && printf "\033[0;0H"
                        GET_CURRENT_SET
                        CUSTOM_SET_EDITED_THEME &
                        UPDATE_CACHE
                        current=$(echo "$MountEFIconf" | grep -A 1 -e "<key>CurrentPreset</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n')
                        themename="$current"
                        GET_THEME_LOADERS "built-in" "$current"
                        old_loaders="$Loaders"
                        EDIT_LOADER_POINTER
                        Loaders="$Clover"";""$OpenCore"
                        if [[ ! "$old_loaders" = "$Loaders" ]] || [[ ! "$old_themeldrs" = "$new_color" ]]; then
                        if result=$(ASK_STORE_OPTIONS); then
                        if [[ $loc = "ru" ]]; then
                        if [[ "$result" = "Для всех тем как указатели по умолчанию" ]]; then result=1; fi
                        else
                        if [[ "$result" = "For all themes as default bootloaders pointers" ]]; then result=1; fi
                        fi
                        if [[ $result = 1 ]]; then
                        plutil -replace ThemeLoadersNames -string "$Loaders" ${HOME}/.MountEFIconf.plist
                        plutil -replace ThemeLoaders -string $new_color ${HOME}/.MountEFIconf.plist
                        else
                        SET_THEMES_LOADERS "B," "$themename"
                        fi
                        UPDATE_CACHE
                        fi 2>/dev/null
                        fi
                        lines=$oldlines
                        unset inputs
                        GET_THEME
                        if [[ $theme = "built-in" ]]; then CUSTOM_SET; else SET_SYSTEM_THEME; fi & 
                        lines=$oldlines
                        UPDATE_PRESETS_LIST
                        osascript -e 'tell application "Terminal" to activate' &
                          
        fi

        if [[ $inputs = [sS] ]]; then
                        if result=$(ASK_SYSTEM_THEME); then
                                            osascript -e 'tell application "Terminal" to  set current settings of window 1 to settings set "'"$result"'"'
                                            osascript -e 'tell application "Terminal" to activate' &
                        oldlines=$lines; lines=32
                        clear && printf '\e[8;'${lines}';88t' && printf '\e[3J' && printf "\033[0;0H"
                        UPDATE_CACHE
                        themename="$result"
                        GET_THEME_LOADERS "system" "$result"
                        old_loaders="$Loaders"
                        EDIT_LOADER_POINTER
                        Loaders="$Clover"";""$OpenCore"
                        if [[ ! "$old_loaders" = "$Loaders" ]] || [[ ! "$old_themeldrs" = "$new_color" ]]; then
                        if result=$(ASK_STORE_OPTIONS); then
                        if [[ $loc = "ru" ]]; then
                        if [[ "$result" = "Для всех тем как указатели по умолчанию" ]]; then result=1; fi
                        else
                        if [[ "$result" = "For all themes as default bootloaders pointers" ]]; then result=1; fi
                        fi
                        if [[ $result = 1 ]]; then
                        plutil -replace ThemeLoadersNames -string "$Loaders" ${HOME}/.MountEFIconf.plist
                        plutil -replace ThemeLoaders -string $new_color ${HOME}/.MountEFIconf.plist
                        osascript -e 'tell application "Terminal" to activate' &
                        else
                        SET_THEMES_LOADERS "S," "$themename"
                        fi
                        UPDATE_CACHE
                        lines=$oldlines
                        fi  2>/dev/null
                        fi
                        else
                        osascript -e 'tell application "Terminal" to activate' &
                        fi 2>/dev/null
                        unset inputs
                        GET_THEME
                        if [[ $theme = "built-in" ]]; then CUSTOM_SET; else SET_SYSTEM_THEME; fi &
                        lines=$oldlines
                        UPDATE_PRESETS_LIST
                        osascript -e 'tell application "Terminal" to activate' &
            fi  

        if [[ $inputs = "" ]]; then printf "\033[2A"; fi
        if [[ $inputs = [qQ] ]]; then  unset inputs;  break;  fi



if [[ $inputs = [rR] ]]; then 

                        printf "\r"; printf "%"80"s"
                            if [[ $loc = "ru" ]]; then
                        printf '\r  Удаление пресета. (или просто "Enter" для отмены):\n\n'
                            else
                        printf '\r  Delete a preset. (or just "Enter" to cancel):\n\n'
                        fi
                        while [[ ! ${inputs} =~ ^[0-9] ]]; do
                        printf "%"80"s"
                        printf "\033[1A"
                        if [[ $loc = "ru" ]]; then
                        printf '   Выберите номер пресета  ( 1 - '$pcount' ): ' 
                            else
                        printf '   Choose preset number  ( 1 - '$pcount' ): '
                        fi
                        printf "\033[?25h" 
                        read  inputs
                        printf "\033[?25l" 
                        printf '\r\033[1A'"%"80"s""%"80"s""%"80"s"'\r\033[3A'
                        if [[ $inputs = 0 ]]; then inputs="p"; fi &> /dev/null
                        if [[ $inputs -gt $chn ]]; then inputs="t"; fi &> /dev/null
                        if [[ ${inputs} = "" ]]; then inputs="p"; printf "\033[1A"; break; fi &> /dev/null
                        printf "\033[1A"
                        printf "\r"
                        done
                        if [[ ! ${inputs} = "p" ]]; then
                        if [[ $inputs = 1 ]] && [[ $pcount = 1 ]]; then 
                             if [[ $loc = "ru" ]]; then
                        printf '   Нельзя удалить последний пресет  ' 
                            else
                        printf '   Cannot delete last preset        '
                        sleep 2
                             fi
                            else
                        let "inputs--" 
                        editing_preset="${plist[inputs]}"
                        DELETE_THEME_PRESET
                        current=`echo "$MountEFIconf" | grep -A 1 -e "<key>CurrentPreset</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
                        if [[ "$editing_preset" = "$current" ]]; then  pnow=$(echo "$MountEFIconf" | grep -A 2 -e "<key>Presets</key>"  |  awk '(NR == 3)' | sed -e 's/.*>\(.*\)<.*/\1/');
                                        plutil -replace CurrentPreset -string "$pnow" ${HOME}/.MountEFIconf.plist;  fi 
                        UPDATE_CACHE
                        GET_PRESETS_COUNTS
                        let "lines=22+pcount"
                        fi
                        printf "\033[H"
                        printf "\r\033[2f"
                        UPDATE_PRESETS_LIST
                        fi
                        unset inputs
fi

if [[ $inputs = [nN] ]]; then
                        editing_preset=" "
                        EDIT_PRESET_NAME
                        if [[ ! $demo = "" ]]; then
                        if [[ ${#demo} -gt 28 ]]; then demo="${demo:0:28}"; fi
                        editing_BackgroundColor="{3341, 25186, 40092}"
                        editing_FontName="SF Mono Regular"
                        editing_FontSize="12"
                        editing_TextColor="{65535, 65535, 65535}"
                        ADD_THEME_PRESET
                        UPDATE_CACHE
                        GET_PRESETS_COUNTS
                        let "lines=22+pcount"
                        fi
                        printf "\033[H"
                        printf "\r\033[2f"
                        UPDATE_PRESETS_LIST
                        unset inputs
                       
fi

if [[ ! $inputs = [qQnNrRzZxXlLsS]+$ ]] &&  [[ ! $inputs = "" ]]; then
                        old2lines=$lines; lines=20; swap_preset=0
                        clear && printf '\e[8;'${lines}';80t' && printf '\e[3J' && printf "\033[0;0H"
                        SAVE_ORIGINAL_PRESET
                        CUSTOM_SET_EDITED_THEME
                        var9=0
                        while [ $var9 != 1 ] 
    do
                        EDIT_PRESET_UPDATE_SCREEN
                        unset inputs
                        while [[ ! ${inputs} =~ ^[1-5qQeE]+$ ]]; 
                    do 

                        SET_INPUT
                        if [[ $loc = "ru" ]]; then
                        printf '\r  Выберите от 1 до 5 (или Q, E):                                   \n\n'
                        printf '        Q   - вернуться в меню сохранив новые настройки пресета     \n'
                        printf '        E/E - отменить/возвратить результаты редактирования         \n'
			                   else
                            printf '\r  Select from 1 to 5 (or Q, E):                                    \n\n'
                            printf '        Q   - return to the menu saving the new preset settings     \n'
                            printf '        E/E - cancel/return the editing results                     \n'
                        fi
                         printf "\033[14;0H"   
                        if [[ $loc = "ru" ]]; then
                        printf "\r\033[33C"
                        else
                        printf "\r\033[33C"
                        fi
                        printf "\033[?25h"

                        
                        if [[ ${ch} -le 9 ]]; then
                        read -n 1  inputs 
                        fi  
                        printf "\033[?25l"
                        if [[ ${inputs} = "" ]]; then inputs="A" ;printf "\033[1A"; printf "\033[?25l"; fi
                        printf '\r'
                   done

if [[ $inputs = "" ]]; then inputs="A"; printf "\033[2A"; fi

                        if [[ $inputs = [qQ] ]]; then var9=1; unset inputs 

                            if [[ ! "$old_preset" = "$current_preset" ]]; then 
                        plutil -remove   Presets."$old_preset" ${HOME}/.MountEFIconf.plist
                        plutil -replace  Presets."$current_preset" -xml  '<dict/>'   ${HOME}/.MountEFIconf.plist  
                        plutil -replace  Presets."$current_preset".BackgroundColor -string "$current_background" ${HOME}/.MountEFIconf.plist
                        plutil -replace  Presets."$current_preset".FontName -string "$current_fontname" ${HOME}/.MountEFIconf.plist
                        plutil -replace  Presets."$current_preset".FontSize -string "$current_fontsize" ${HOME}/.MountEFIconf.plist
                        plutil -replace  Presets."$current_preset".TextColor -string "$current_foreground" ${HOME}/.MountEFIconf.plist
                        current=`echo "$MountEFIconf" | grep -A 1 -e "<key>CurrentPreset</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
                        if [[ "$old_preset" = "$current" ]]; then  plutil -replace CurrentPreset -string "$current_preset" ${HOME}/.MountEFIconf.plist;  fi 
                            else
                                if [[ ! "$old_BackgroundColor" = "$current_background" ]]; then plutil -replace  Presets."$current_preset".BackgroundColor -string "$current_background" ${HOME}/.MountEFIconf.plist; fi
                                if [[ ! "$old_FontName" = "$current_fontname" ]]; then plutil -replace  Presets."$current_preset".FontName -string "$current_fontname" ${HOME}/.MountEFIconf.plist; fi
                                if [[ ! "$old_FontSize" = "$current_fontsize" ]]; then plutil -replace  Presets."$current_preset".FontSize -string "$current_fontsize" ${HOME}/.MountEFIconf.plist; fi
                                if [[ ! "$old_TextColor" = "$current_foreground" ]]; then plutil -replace  Presets."$current_preset".TextColor -string "$current_foreground" ${HOME}/.MountEFIconf.plist; fi
                            fi
                        UPDATE_CACHE
                        fi

                        if [[ $inputs = [eE] ]]; then
    
                                if [[ $swap_preset = 0 ]]; then SAVE_NEW_PRESET; RESTORE_ORIGINAL_PRESET; swap_preset=1 ; else  RESTORE_NEW_PRESET; swap_preset=0; fi
                                 CUSTOM_SET_EDITED_THEME
                        fi

if [[ $inputs = 1 ]]; then 
                        unset demo
                        editing_preset="$current_preset"
                        EDIT_PRESET_NAME
                        if [[ ! $demo = "" ]]; then
                        if [[ ${#demo} -gt 28 ]]; then demo="${demo:0:28}"; fi
                        current_preset="$editing_preset"
                        if [[ "$current_preset" = "$old_preset" ]]; then swap_preset=0; fi
                        fi 
fi

if [[ $inputs = 2 ]]; then 
                         lines=32
                         printf "%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'
                         printf "%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'
                         printf "%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"
                         printf '\e[8;'${lines}';80t' && printf '\e[3J' && printf "\033[0;0H"
                         EDIT_PRESET_UPDATE_SCREEN
                         EDIT_COLOR
                         lines=20
                         clear && printf '\e[8;'${lines}';80t' && printf '\e[3J' && printf "\033[0;0H"
                         EDIT_PRESET_UPDATE_SCREEN
fi

if [[ $inputs = 3 ]]; then 
                         lines=32
                         printf "%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'
                         printf "%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'
                         printf "%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"
                         printf '\e[8;'${lines}';80t' && printf '\e[3J' && printf "\033[0;0H"
                         EDIT_PRESET_UPDATE_SCREEN
                         EDIT_COLOR foreground
                         lines=20
                         clear && printf '\e[8;'${lines}';80t' && printf '\e[3J' && printf "\033[0;0H"
                         EDIT_PRESET_UPDATE_SCREEN
fi

if [[ $inputs = 4 ]]; then
                          UPDATE_FONTS_LIST
                          
                         if [[ $loc = "ru" ]]; then
                        printf '\r   Выберите шрифт клавишами A-S:                            \n\n'
                       
			                   else
                            printf '\r   Select a font with the A-S keys:                          \n\n'
                         fi
                            EDIT_FONTNAME
                            unset inputs
                         lines=20
                         if [[ ! "$old_FontName" = "$current_fontname" ]]; then swap_preset=0; fi
                        
                         clear && printf '\e[8;'${lines}';80t' && printf '\e[3J' && printf "\033[0;0H"
                         EDIT_PRESET_UPDATE_SCREEN
fi

if [[ $inputs = 5 ]]; then 
                        
                         printf "\033[10;36f""["; printf "\033[10;39f""]"; printf "\033[14;0f"
                         if [[ $loc = "ru" ]]; then
                        printf '\r  Изменяйте размер шрифта клавишами C-V:                            \n\n'
                       
			                   else
                            printf '\r  Change the font size with the C-V keys:                          \n\n'
                            
                        fi
                        printf "\033[14;33f"
                        vc=0
                        unset inputs
                   while [[ $vc = 0 ]]; do

                        while [[ ! ${inputs} =~ ^[cCvVeEqQ5]+$ ]]; do
                        read -s -n 1  inputs 
        
                        if [[ ! $inputs = [cCvVeEqQ5] ]]; then 
                        if [[ ${inputs} = "" ]]; then  unset inputs; fi 
                        fi
                        printf '\r'
                done 
                    
                        printf "\033[10;39f""]"'                                       '
                        if [[ $inputs = [cC] ]] && [[ $current_fontsize -ge 2 ]]; then  
                        if [[ $inputs = [cC] ]]; then let "current_fontsize--";   printf "\033[10;36f""["$current_fontsize"]";  fi
                        fi
                        if [[ $inputs = [vV] ]] && [[ $current_fontsize -le 47 ]]; then 
                        if [[ $inputs = [vV] ]]; then let "current_fontsize++";    printf "\033[10;36f""["$current_fontsize"]";  fi
                        fi 

                        printf "\033[10;39f""]"'                                       '

                        if [[ $inputs = [cCvV] ]] && [[ $current_fontsize -lt 49 ]] && [[ $current_fontsize -gt 0 ]];  then set_font "$current_fontname" $current_fontsize; fi &
    
                        if [[ $inputs = [qQ5] ]]; then unset inputs; vc=1; break; fi

                        read -s -n 1  inputs 
                        
                        printf "\033[10;39f""]"'                                       '
                 done 
                        if [[ ! "$old_FontSize" = "$current_fontsize" ]]; then swap_preset=0; fi
                        clear && printf '\e[8;'${lines}';80t' && printf '\e[3J' && printf "\033[0;0H"
                        EDIT_PRESET_UPDATE_SCREEN
                                  
fi

    done
    clear
    lines=$old2lines
    UPDATE_PRESETS_LIST
fi

printf "\033['$currents';34f""*"
done
CORRECT_CURRENT_PRESET
lines=$oldlines
clear      
}

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
echo '      <string>/Users/'"$(whoami)"'/.MountEFIa.sh</string>' >> ${HOME}/.MountEFIa.plist
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
if [[ -d ${HOME}/.MountEFInotifyService/terminal-notifier.app ]]; then
echo '${HOME}/.MountEFInotifyService/terminal-notifier.app/Contents/MacOS/terminal-notifier -title "MountEFI" -sound Submarine -subtitle "${SUBTITLE}" -message "${MESSAGE}"'  >> ${HOME}/.MountEFIa.sh
else
echo 'COMMAND="display notification \"${MESSAGE}\" with title \"${TITLE}\" subtitle \"${SUBTITLE}\" sound name \"${SOUND}\""; osascript -e "${COMMAND}"' >> ${HOME}/.MountEFIa.sh
fi
echo '}' >> ${HOME}/.MountEFIa.sh
echo                >> ${HOME}/.MountEFIa.sh
echo 'GET_APP_ICON(){' >> ${HOME}/.MountEFIa.sh
echo 'icon_string=""' >> ${HOME}/.MountEFIa.sh
echo "if [[ -f ${HOME}/.MountEFInotifyService/AppIcon.icns ]]; then icon_string=' with icon file ((path to home folder as text) & "'".MountEFInotifyService:AppIcon.icns"'")'; fi" >> ${HOME}/.MountEFIa.sh
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
echo ''   >> ${HOME}/.MountEFIa.sh
echo 'SET_LOCALE(){' >> ${HOME}/.MountEFIa.sh 
echo 'if [[ $cache = 1 ]] ; then'   >> ${HOME}/.MountEFIa.sh
echo 'locale=`echo "$MountEFIconf" | grep -A 1 "Locale" | grep string | sed -e '"'s/.*>\(.*\)<.*/\1/'"' | tr -d '"'\n'"'`' >> ${HOME}/.MountEFIa.sh
echo '        if [[ ! $locale = "ru" ]] && [[ ! $locale = "en" ]]; then loc=`defaults read -g AppleLocale | cut -d "_" -f1`' >> ${HOME}/.MountEFIa.sh
echo '            else'   >> ${HOME}/.MountEFIa.sh
echo '                loc=`echo ${locale}`'   >> ${HOME}/.MountEFIa.sh
echo '        fi'   >> ${HOME}/.MountEFIa.sh
echo '    else '   >> ${HOME}/.MountEFIa.sh
echo '        loc=`defaults read -g AppleLocale | cut -d "_" -f1`'   >> ${HOME}/.MountEFIa.sh
echo 'fi'   >> ${HOME}/.MountEFIa.sh
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
echo 'if [[ "$macos" = "1011" ]] || [[ "$macos" = "1012" ]]; then flag=0; else flag=1; fi' >> ${HOME}/.MountEFIa.sh
echo >> ${HOME}/.MountEFIa.sh
echo 'mypassword="0"' >> ${HOME}/.MountEFIa.sh
echo 'if (security find-generic-password -a ${USER} -s efimounter -w) >/dev/null 2>&1; then' >> ${HOME}/.MountEFIa.sh
echo '                mypassword=$(security find-generic-password -a ${USER} -s efimounter -w)' >> ${HOME}/.MountEFIa.sh
echo '                if ! echo "${mypassword}" | sudo -Sk printf '"''"' 2>/dev/null; then ' >> ${HOME}/.MountEFIa.sh
echo '                    security delete-generic-password -a ${USER} -s efimounter >/dev/null 2>&1' >> ${HOME}/.MountEFIa.sh
echo '                    mypassword="0"' >> ${HOME}/.MountEFIa.sh
echo '                    SET_LOCALE' >> ${HOME}/.MountEFIa.sh
echo '                        if [[ $loc = "ru" ]]; then' >> ${HOME}/.MountEFIa.sh
echo '                        SUBTITLE="НЕВЕРНЫЙ ПАРОЛЬ УДАЛЁН ИЗ КЛЮЧЕЙ !"; MESSAGE="Подключение разделов EFI НЕ работает"' >> ${HOME}/.MountEFIa.sh
echo '                        else' >> ${HOME}/.MountEFIa.sh
echo '                        SUBTITLE="WRONG PASSWORD REMOVED FROM KEYCHAIN !"; MESSAGE="Mount EFI Partitions NOT Available"' >> ${HOME}/.MountEFIa.sh
echo '                        fi'  >> ${HOME}/.MountEFIa.sh
echo '                        DISPLAY_NOTIFICATION' >> ${HOME}/.MountEFIa.sh
echo '                        sleep 2' >> ${HOME}/.MountEFIa.sh
echo '             fi'  >> ${HOME}/.MountEFIa.sh
echo 'fi' >> ${HOME}/.MountEFIa.sh
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
echo '        TRY=3 ; GET_APP_ICON' >> ${HOME}/.MountEFIa.sh
echo '        while [[ ! $TRY = 0 ]]; do' >> ${HOME}/.MountEFIa.sh
echo '        if [[ $loc = "ru" ]]; then' >> ${HOME}/.MountEFIa.sh
echo '        if PASSWORD="$(osascript -e '"'Tell application "'"System Events"'" to display dialog "'"       Пароль для подключения EFI разделов: "'"'"'"${icon_string}"'"'"''" with hidden answer  default answer "'""'"'"' -e '"'text returned of result'"')"; then cansel=0; else cansel=1; fi 2>/dev/null' >> ${HOME}/.MountEFIa.sh
echo '        else' >> ${HOME}/.MountEFIa.sh
echo '        if PASSWORD="$(osascript -e '"'Tell application "'"System Events"'" to display dialog "'"       Enter the password to mount the EFI partitions: "'"'"'"${icon_string}"'"'"''" with hidden answer  default answer "'""'"'"' -e '"'text returned of result'"')"; then cansel=0; else cansel=1; fi 2>/dev/null' >> ${HOME}/.MountEFIa.sh
echo '        fi' >> ${HOME}/.MountEFIa.sh
echo '                if [[ $cansel = 1 ]]; then break; fi ' >> ${HOME}/.MountEFIa.sh
echo '                mypassword=$PASSWORD' >> ${HOME}/.MountEFIa.sh
echo '                if [[ $mypassword = "" ]]; then mypassword="?"; fi' >> ${HOME}/.MountEFIa.sh
echo '                if echo "${mypassword}" | sudo -Sk printf '"''"' 2>/dev/null; then' >> ${HOME}/.MountEFIa.sh
echo '                    security add-generic-password -a ${USER} -s efimounter -w "${mypassword}" >/dev/null 2>&1' >> ${HOME}/.MountEFIa.sh
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
echo '               echo "${mypassword}" | sudo -S diskutil quiet mount  ${alist[$posa]} >&- 2>&-' >> ${HOME}/.MountEFIa.sh
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
if [[ -d ~/.MountEFInotifyService ]]; then rm -R ~/.MountEFInotifyService; fi
}


SETUP_SYS_AUTOMOUNT(){
REMOVE_SYS_AUTOMOUNT_SERVICE
if [[ -d terminal-notifier.app ]]; then if [[ ! -d ~/.MountEFInotifyService ]]; then mkdir ~/.MountEFInotifyService; fi; cp -R terminal-notifier.app ~/.MountEFInotifyService; fi
if [[ -f AppIcon.icns ]]; then if [[ ! -d ~/.MountEFInotifyService ]]; then mkdir ~/.MountEFInotifyService; fi; cp AppIcon.icns ~/.MountEFInotifyService; fi
FILL_SYS_AUTOMOUNT_PLIST
FILL_SYS_AUTOMOUNT_EXEC
mv ${HOME}/.MountEFIa.plist ~/Library/LaunchAgents/MountEFIa.plist
launchctl load -w ~/Library/LaunchAgents/MountEFIa.plist
if [[ $display = 1 ]]; then
                        
                        SET_TITLE
                        if [[ $loc = "ru" ]]; then
                        echo 'SUBTITLE="СЕРВИС АВТО-ПОДКЛЮЧЕНИЯ EFI РАБОТАЕТ !"; MESSAGE="Разделы подключаются при входе в систему"' >> ${HOME}/.MountEFInoty.sh
                        else
                        echo 'SUBTITLE="EFI AUTO-MOUNT SERVICE STARTED !"; MESSAGE="Selected partitions are connected at login"' >> ${HOME}/.MountEFInoty.sh
                        fi
                        DISPLAY_NOTIFICATION
                        
        
               
fi
}

SET_SYSTEM_THEME(){
profile=`echo "$MountEFIconf" |  grep -A 1 -e  "<key>ThemeProfile</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
if [[ "$profile" = "default" ]]; then
system_default=$(plutil -p /Users/$(whoami)/Library/Preferences/com.apple.Terminal.plist | grep "Default Window Settings" | tr -d '"' | cut -f2 -d '>' | xargs)
osascript -e 'tell application "Terminal" to  set current settings of window 1 to settings set "'"$system_default"'"'
else osascript -e 'tell application "Terminal" to  set current settings of window 1 to settings set "'"$profile"'"'
fi
}

SET_PROFILE(){
profile=`echo "$MountEFIconf" |  grep -A 1 -e  "<key>ThemeProfile</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
profiles=( "Basic" "Grass" "Homebrew" "Man Page" "Novel" "Ocean" "Pro" "Red Sands" "Silver Aerogel" "Solid Colors" )
default_profile=$(plutil -p /Users/$(whoami)/Library/Preferences/com.apple.Terminal.plist | grep "Default Window Settings" | tr -d '"' | cut -f2 -d '>' | xargs)
if [[ "$profile" = "default" ]]; then profile="$default_profile"; fi
for ((i=0; i<9; i++)) do if [[ "$profile" = "${profiles[i]}" ]]; then break; fi; done
if [[ $i < 9 ]]; then let "i++"; else i=0; fi
profile="${profiles[i]}"; if  [[ "$profile" = "default_profile" ]]; then plutil -replace ThemeProfile -string "default" ${HOME}/.MountEFIconf.plist
else plutil -replace ThemeProfile -string "$profile" ${HOME}/.MountEFIconf.plist; fi
UPDATE_CACHE
}

START_RELOAD_SERVICE(){
if [[ ! $par = "-r" ]]; then 
MEFI_PATH="$(ps o command | grep -i "setup.sh" | grep -v grep |  sed -e 's/^[^ ]*\(.*\)$/\1/' |  sort -u | xargs)"
if [[ "$MEFI_PATH" = "" ]]; then
    MEFI_PATH="$(ps o command | grep -i "setup" | grep -v grep |  sed -e 's/^[^ ]*\(.*\)$/\1/' |  sort -u | xargs)"; fi
else
MEFI_PATH="${ROOT}""/MountEFI"
fi

echo '<?xml version="1.0" encoding="UTF-8"?>' >> ${HOME}/.MountEFIr.plist
echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' >> ${HOME}/.MountEFIr.plist
echo '<plist version="1.0">' >> ${HOME}/.MountEFIr.plist
echo '<dict>' >> ${HOME}/.MountEFIr.plist
echo '  <key>Label</key>' >> ${HOME}/.MountEFIr.plist
echo '  <string>MountEFIr.job</string>' >> ${HOME}/.MountEFIr.plist
echo '  <key>Nicer</key>' >> ${HOME}/.MountEFIr.plist
echo '  <integer>1</integer>' >> ${HOME}/.MountEFIr.plist
echo '  <key>ProgramArguments</key>' >> ${HOME}/.MountEFIr.plist
echo '  <array>' >> ${HOME}/.MountEFIr.plist
echo '      <string>/Users/'"$(whoami)"'/.MountEFIr.sh</string>' >> ${HOME}/.MountEFIr.plist
echo '  </array>' >> ${HOME}/.MountEFIr.plist
echo '  <key>RunAtLoad</key>' >> ${HOME}/.MountEFIr.plist
echo '  <true/>' >> ${HOME}/.MountEFIr.plist
echo '</dict>' >> ${HOME}/.MountEFIr.plist
echo '</plist>' >> ${HOME}/.MountEFIr.plist

echo '#!/bin/bash'  >> ${HOME}/.MountEFIr.sh
echo ''             >> ${HOME}/.MountEFIr.sh
echo 'sleep 1'             >> ${HOME}/.MountEFIr.sh
echo ''             >> ${HOME}/.MountEFIr.sh
echo 'arg=''"'$(echo $par)'"''' >> ${HOME}/.MountEFIr.sh
echo 'ProgPath=''"'$(echo "$MEFI_PATH")'"''' >> ${HOME}/.MountEFIr.sh
echo '            open "${ProgPath}"'             >> ${HOME}/.MountEFIr.sh
echo ''             >> ${HOME}/.MountEFIr.sh
echo 'exit'             >> ${HOME}/.MountEFIr.sh

chmod u+x ${HOME}/.MountEFIr.sh

if [[ -f ${HOME}/.MountEFIr.plist ]]; then mv -f ${HOME}/.MountEFIr.plist ~/Library/LaunchAgents/MountEFIr.plist; fi
if [[ ! $(launchctl list | grep "MountEFIr.job" | cut -f3 | grep -x "MountEFIr.job") ]]; then launchctl load -w ~/Library/LaunchAgents/MountEFIr.plist; fi

if [[ -f ~/.hashes_list.txt ]]; then cp -f ~/.hashes_list.txt ~/.hashes_list.txt.back; fi
if [[ -f ~/.other_loaders_list.txt ]]; then cp -f ~/.other_loaders_list.txt ~/.other_loaders_list.txt.back; fi
if [[ -f ~/.disk_list.txt ]]; then cp -f ~/.disk_list.txt ~/.disk_list.txt.back; fi
}

GET_SYSTEM_FLAG(){
macos=`sw_vers -productVersion`
  macos=`echo ${macos//[^0-9]/}`
  macos=${macos:0:4}
  if [[ "$macos" = "1011" ]] || [[ "$macos" = "1012" ]]; then flag=0; else flag=1; fi
}

FORCE_CHECK_PASSWORD(){
mypassword=""
if (security find-generic-password -a ${USER} -s efimounter -w) >/dev/null 2>&1; then
             mypassword=$(security find-generic-password -a ${USER} -s efimounter -w)
             if ! echo "${mypassword}" | sudo -Sk printf '' 2>/dev/null; then 
                    case $1 in
                            "automount" ) if [[ $loc = "ru" ]]; then printf '\033[1A\r''  Введите число от\r\033[48C'; else 
                                                                      printf '\033[1A\r'' Enter a number from\r\033[50C'; fi;;
                                      * ) printf "\r\033[1A                                                                          \r";;
                    esac
                    security delete-generic-password -a ${USER} -s efimounter >/dev/null 2>&1
                    mypassword=""
                    SET_TITLE
                        if [[ $loc = "ru" ]]; then
                        echo 'SUBTITLE="НЕВЕРНЫЙ ПАРОЛЬ УДАЛЁН ИЗ КЛЮЧЕЙ !"; MESSAGE="Подключение разделов EFI НЕ работает"' >> ${HOME}/.MountEFInoty.sh
                        else
                        echo 'SUBTITLE="WRONG PASSWORD REMOVED FROM KEYCHAIN !"; MESSAGE="Mount EFI Partitions NOT Available"' >> ${HOME}/.MountEFInoty.sh
                        fi
                        DISPLAY_NOTIFICATION 
             fi
fi
}

START_UPDATE_SERVICE(){
#MEFI_PATH="$(ps o command | grep -i "MountEFI" | grep -v grep |  sed -e 's/^[^ ]*\(.*\)$/\1/' |  sort -u | xargs)"
MEFI_PATH="${ROOT}""/MountEFI"

echo '<?xml version="1.0" encoding="UTF-8"?>' >> ${HOME}/.MountEFIu.plist
echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' >> ${HOME}/.MountEFIu.plist
echo '<plist version="1.0">' >> ${HOME}/.MountEFIu.plist
echo '<dict>' >> ${HOME}/.MountEFIu.plist
echo '  <key>Label</key>' >> ${HOME}/.MountEFIu.plist
echo '  <string>MountEFIu.job</string>' >> ${HOME}/.MountEFIu.plist
echo '  <key>Nicer</key>' >> ${HOME}/.MountEFIu.plist
echo '  <integer>1</integer>' >> ${HOME}/.MountEFIu.plist
echo '  <key>ProgramArguments</key>' >> ${HOME}/.MountEFIu.plist
echo '  <array>' >> ${HOME}/.MountEFIu.plist
echo '      <string>/Users/'"$(whoami)"'/.MountEFIu.sh</string>' >> ${HOME}/.MountEFIu.plist
echo '  </array>' >> ${HOME}/.MountEFIu.plist
echo '  <key>RunAtLoad</key>' >> ${HOME}/.MountEFIu.plist
echo '  <true/>' >> ${HOME}/.MountEFIu.plist
echo '</dict>' >> ${HOME}/.MountEFIu.plist
echo '</plist>' >> ${HOME}/.MountEFIu.plist

echo '#!/bin/bash'  >> ${HOME}/.MountEFIu.sh
echo ''             >> ${HOME}/.MountEFIu.sh
echo 'sleep 1'             >> ${HOME}/.MountEFIu.sh
echo ''             >> ${HOME}/.MountEFIu.sh
echo 'latest_release=''"'$(echo $latest_release)'"''' >> ${HOME}/.MountEFIu.sh
echo 'latest_edit=''"'$(echo $latest_edit)'"''' >> ${HOME}/.MountEFIu.sh
echo 'current_release=''"'$(echo ${prog_vers})'"''' >> ${HOME}/.MountEFIu.sh
echo 'current_edit=''"'$(echo ${edit_vers})'"''' >> ${HOME}/.MountEFIu.sh
echo 'vers="${latest_release:0:1}"".""${latest_release:1:1}"".""${latest_release:2:1}"".""${latest_edit}"' >> ${HOME}/.MountEFIu.sh
echo 'ProgPath=''"'$(echo "$MEFI_PATH")'"''' >> ${HOME}/.MountEFIu.sh
echo 'DirPath="$( echo "$ProgPath" | sed '"'s/[^/]*$//'"' | xargs)"'  >> ${HOME}/.MountEFIu.sh
echo 'rm -f "${DirPath}""version.txt"; echo ${current_release}";"${current_edit} >> "${DirPath}""version.txt"' >> ${HOME}/.MountEFIu.sh
echo 'mv -f ~/.MountEFIupdates/$latest_edit/MountEFI "${ProgPath}"' >> ${HOME}/.MountEFIu.sh
echo 'if [[ -f ~/.MountEFIupdates/$latest_edit/setup ]]; then'             >> ${HOME}/.MountEFIu.sh
echo '        mv -f ~/.MountEFIupdates/$latest_edit/setup "${DirPath}""setup"' >> ${HOME}/.MountEFIu.sh
echo '        mv -f ~/.MountEFIupdates/$latest_edit/document.wflow "${DirPath}""../document.wflow"' >> ${HOME}/.MountEFIu.sh
echo 'fi' >> ${HOME}/.MountEFIu.sh
echo 'if [[ -f "${DirPath}""/../Info.plist" ]]; then plutil -replace CFBundleShortVersionString -string "$vers" "${DirPath}""/../Info.plist"; fi' >> ${HOME}/.MountEFIu.sh
echo 'if [[ -d "${DirPath}""/../../../MountEFI.app" ]]; then touch "${DirPath}""/../../../MountEFI.app"; fi' >> ${HOME}/.MountEFIu.sh
echo 'sleep 1' >> ${HOME}/.MountEFIu.sh
echo '      open "$ProgPath"' >> ${HOME}/.MountEFIu.sh
echo ''  >> ${HOME}/.MountEFIu.sh
echo 'exit'             >> ${HOME}/.MountEFIu.sh
chmod u+x ${HOME}/.MountEFIu.sh

if [[ -f ${HOME}/.MountEFIu.plist ]]; then mv -f ${HOME}/.MountEFIu.plist ~/Library/LaunchAgents/MountEFIu.plist; fi
if [[ ! $(launchctl list | grep "MountEFIu.job" | cut -f3 | grep -x "MountEFIu.job") ]]; then launchctl load -w ~/Library/LaunchAgents/MountEFIu.plist; fi

if [[ -f ~/.hashes_list.txt ]]; then cp -f ~/.hashes_list.txt ~/.hashes_list.txt.back; fi
if [[ -f ~/.other_loaders_list.txt ]]; then cp -f ~/.other_loaders_list.txt ~/.other_loaders_list.txt.back; fi
if [[ -f ~/.disk_list.txt ]]; then cp -f ~/.disk_list.txt ~/.disk_list.txt.back; fi
}



ASK_UPDATE(){
if [[ $loc = "ru" ]]; then
printf '\e[40m\e[1;33m   Загрузить обновления и обновить программу? (y/N) \e[0m'
else
printf '\e[40m\e[1;33m   Download updates and update the program?   (y/N) \e[0m'
fi
success=2
read -s -n 1 
if [[ $REPLY =~ ^[yY]$ ]]; then
            printf '\r\e[40m\e[1;33m                                                   \e[0m'
            if [[ $loc = "ru" ]]; then
            printf '\r\e[40m\e[1;33m   Загрузка файлов: \e[0m'
            else
            printf '\r\e[40m\e[1;33m   Download files: \e[0m'
            fi

            CHECK_AUTOUPDATE
            if [[ ${AutoUpdate} = 1 ]]; then
               DISABLE_AUTOUPDATE
               SET_TITLE
                        if [[ $loc = "ru" ]]; then
                        echo 'SUBTITLE="Авто-обновление программы ВЫКЛЮЧЕНО !"; MESSAGE=""' >> ${HOME}/.MountEFInoty.sh
                        else
                        echo 'SUBTITLE="Auto-update DISABLED !"; MESSAGE=""' >> ${HOME}/.MountEFInoty.sh
                        fi
                        DISPLAY_NOTIFICATION
            fi
   
    if [[ ! -d ~/.MountEFIupdates ]]; then mkdir ~/.MountEFIupdates; fi
    success=0
    printf "\e[40m\e[1;33m\r\033[20C"
    if curl https://github.com/Andrej-Antipov/MountEFI/raw/master/Updates/${latest_release}/${latest_edit}".zip" -L -o ~/.MountEFIupdates/${latest_edit}".zip" --progress-bar 2>&1 | while IFS= read -d $'\r' -r p; do p=${p:(-6)}; p=${p%'%'*}; p=${p/,/}; p=$(expr $p / 10 2>/dev/null); let "s=p/3"; echo -ne "[ $p% ] [ $(eval 'printf =%.0s {1..'${s}'}')> ]\r\033[20C"; done ; printf '\e[0m'; then
        printf '\r\e[40m                                                                                 '
        unzip  -o -qq ~/.MountEFIupdates/${latest_edit}".zip" -d ~/.MountEFIupdates 2>/dev/null
        if [[ -f ~/.MountEFIupdates/${latest_edit}/MountEFI ]]; then 
            if [[ $loc = "ru" ]]; then
            printf '\r\033[1A\e[40m\e[1;33m   Файлы получены. Перезапуск программы для обновления ...        \e[0m'
            else
            printf '\r\033[1A\e[40m\e[1;33m   Files downloaded. Restarting the program to update it ...      \e[0m'
            fi
            sleep 2
            printf "\033[H"; for (( i=0; i<24; i++ )); do printf ' %.0s' {1..80}; done
            START_UPDATE_SERVICE
            plutil -replace Updating -bool Yes ${HOME}/.MountEFIconf.plist
            success=1
            
        fi
    fi
fi
}

UPDATE_PROGRAM(){
clear && printf '\e[8;24;80t' && printf '\e[3J' && printf "\033[H"
printf "\033[?25l"
printf "\033[H"
for (( i=0; i<24; i++ )); do printf '\e[40m %.0s\e[0m' {1..80}; done
printf "\033[H"
            edit_vers=$(cat MountEFI | grep -m1 "edit_vers=" | sed s'/edit_vers=//' | tr -d '" \n')
            prog_vers=$(cat MountEFI | grep "prog_vers=" | sed s'/prog_vers=//' | tr -d '" \n')
            vers="$prog_vers"".""$edit_vers"
printf '\033[0;25f''\e[40m\e[1;35m   '; printf '\e[40m\e[1;35mMountEFI v. \e[1;33m'$prog_vers'.\e[1;32m '$edit_vers' \e[1;35m© \e[0m''\n\n'
if ping -c 1 google.com >> /dev/null 2>&1; then
    if [[ $loc = "ru" ]]; then
    printf '\e[40m\e[1;33m   Проверяем доступную версию программы на github  \e[0m'
    else
    printf '\e[40m\e[1;33m   Checking the available version of the program on github  \e[0m'
    fi
    spin='-\|/'
    i=0
    while :;do let "i++"; i=$(( (i+1) %4 )) ; printf '\e[40m\e[1m'"\b$1${spin:$i:1}"'\e[0m' ;sleep 0.15;done &
    trap "kill $!" EXIT
    latest_release=""
    latest_release=$(curl -s --max-time 10 https://api.github.com/repos/Andrej-Antipov/MountEFI/releases/latest | grep browser_download_url | cut -d '"' -f 4 | rev | cut -d '/' -f1  | rev | sed s/[^0-9]//g | tr -d ' \n\t')
    if [[ "${latest_release}" = "" ]]; then latest_release="000"; fi
    if [[ ${#latest_release} = 2 ]]; then latest_release+="0"; fi
    if [[ $loc = "ru" ]]; then
    if [[ ! $latest_release = "" ]]; then printf '\r\e[40m\e[1;33m   Последний релиз: \e[1;36mMountEFI v. \e[1;32m'${latest_release:0:1}'.'${latest_release:1:1}'.'${latest_release:2:1}'                       \e[0m\n\n'; fi
    else
    if [[ ! $latest_release = "" ]]; then printf '\r\e[40m\e[1;33m   Latest Release: \e[1;36mMountEFI v. \e[1;32m'${latest_release:0:1}'.'${latest_release:1:1}'.'${latest_release:2:1}'                         \e[0m\n\n'; fi
    fi
    kill $!
    wait $! 2>/dev/null
    trap " " EXIT

    if [[ $loc = "ru" ]]; then
    printf '\e[40m\e[1;33m   Проверяем доступную редакцию программы на github  \e[0m'
    else
    printf '\e[40m\e[1;33m   Checking the available edition of the program on github  \e[0m'
    fi
    i=0
    while :;do let "i++"; i=$(( (i+1) %4 )) ; printf '\e[40m\e[1m'"\b$1${spin:$i:1}"'\e[0m' ;sleep 0.15;done &
    trap "kill $!" EXIT
    latest_edit=$(curl -s --max-time 10 https://github.com/Andrej-Antipov/MountEFI/tree/master/Updates/${latest_release} | grep -w 'href="/Andrej-Antipov/MountEFI/blob/master/Updates/'${latest_release}'' | awk 'END {print $NF}' | cut -f3 -d '"' | tr  '<>/' ' ' | xargs | cut -f1 -d " " | cut -f1 -d '.')
    kill $!
    wait $! 2>/dev/null
    trap " " EXIT
    if [[ "${latest_edit}" = "" ]]; then latest_edit="000"; fi
    if [[ $loc = "ru" ]]; then
    printf '\r\e[40m\e[1;33m   Последняя редакция: \e[1;32m'"${latest_edit}"'                                \e[0m\n\n'
    else
    printf '\r\e[40m\e[1;33m   Latest edition: \e[1;32m'"${latest_edit}"'                                        \e[0m\n\n'
    fi
    current_vers=$(echo "$prog_vers" | tr -d "." )
    if [[ "$latest_edit" = "0071" ]]; then last_e=8; else last_e=$(echo $latest_edit | bc); fi
    vers_e=$(echo $edit_vers | bc)
    if [[ "${current_vers}" -ge "${latest_release}" ]] && [[ "${last_e}" -le "${vers_e}" ]]; then
      if [[ "${latest_release}" = "000" ]] || [[ "$latest_edit" = "000" ]]; then
        if [[ $loc = "ru" ]]; then
        printf '\e[40m\e[1;33m   Возникли неполадки в получении информации о версииях. \e[0m'
        else
        printf '\e[40m\e[1;33m   There was a problem getting version information. \e[0m'
        fi
      else  
        if [[ $loc = "ru" ]]; then
        printf '\e[40m\e[1;33m   Версия и редакция программы новейшие. \e[0m'
        else
        printf '\e[40m\e[1;33m   The version of the program and its edition are the latest. \e[0m'
        fi
     fi
        else 
            ASK_UPDATE
            if [[ ! $success = 2 ]]; then
                if [[ $loc = "ru" ]]; then
                if [[ $success = 0 ]]; then printf '\e[40m\e[1;33m   Не удалось получить файлы обновления. \e[0m\n\n'; else break; fi
                else
                if [[ $success = 0 ]]; then printf '\e[40m\e[1;33m   Failed to get update files for the program. \e[0m\n\n'; else break; fi
                fi
            fi
    fi
else
   if [[ $loc = "ru" ]]; then
   printf '\e[40m\e[1;33m   Не удаётся получить доступ к сети  \e[0m'
   else
   printf '\e[40m\e[1;33m   Unable to connect to the network.  \e[0m'
   fi
fi
if [[ ! $success = 2 ]]; then read -s -n 1 -t 6; fi
printf "\033[H"; for (( i=0; i<24; i++ )); do printf ' %.0s' {1..80}; done
unset inputs
clear
}

WRONG_ANSWER(){
if [[ $loc = "ru" ]]; then
osascript -e 'display dialog "Введёно неверное значение для '"${loader}"':  \n'"${invalid_value}"'"  with icon caution buttons { "OK"}  giving up after 10' >>/dev/null 2>/dev/null
else
osascript -e 'display dialog "you entered the invalid value for '"${loader}"':  \n'"${invalid_value}"'"  with icon caution buttons { "OK"}  giving up after 10' >>/dev/null 2>/dev/null
fi
}

SHOW_HASHES_SCREEN(){
GET_HASHES
lines2=$(( ${#ocr_list[@]}+${#ocd_list[@]}+${#clv_list[@]}+${#oth_list[@]}+24 ))
if [[ ${lines2} -lt 34 ]]; then lines2=34; fi
clear && printf '\e[8;'${lines2}';80t' && printf '\e[3J' && printf "\033[0;0H"
unset bbuf; chn=1; bb=6
                            if [[ $loc = "ru" ]]; then
                         bbuf+=$(printf '\033[1;0f''                    Добавление или удаление хэшей загрузчиков                   ')
			                else
                         bbuf+=$(printf '\033[1;0f''                        Adding or removing loaders hashes                       ')
	                        fi
                        bbuf+=$(printf '\033[2;0f''   ')
	                    bbuf+=$(printf '.%.0s' {1..74})

                           if [[ $loc = "ru" ]]; then
                        bbuf+=$(printf '\033[3;0f''                           База хэшей в файле конфигурации:                      ')
                        bbuf+=$(printf '\033[4;0f''     ')
	                    bbuf+=$(printf '.%.0s' {1..34})
                        
                        bbuf+=$(printf '\033[4;35f''   ')
	                    bbuf+=$(printf '.%.0s' {1..34})
			               else
                        bbuf+=$(printf '\033[3;0f''                             Hashes database in config file                      ')
                        bbuf+=$(printf '\033[4;0f''     ')
	                    bbuf+=$(printf '.%.0s' {1..34})
                        
                        bbuf+=$(printf '\033[4;35f''   ')
	                    bbuf+=$(printf '.%.0s' {1..34})
                            fi
    
    if [[ ${ocr_list[0]} = " " ]]; then ocr_list=(); fi
        if [[ ! ${#ocr_list[@]} = 0 ]]; then
            for i in ${!ocr_list[@]}; do
            
            some_hash=$( echo "${ocr_list[$i]}" | cut -f1 -d"=" )
            revision=$( echo "${ocr_list[$i]}" | rev | cut -f1 -d"=" | rev )            

            if [[ $chn -le 9 ]]; then
            bbuf+=$(printf '\033['$bb';0f''               '$chn')    ')
            else
            bbuf+=$(printf '\033['$bb';0f''              '$chn')    ')
            fi
            bbuf+=$( echo ${some_hash}"   "${revision})
            let "bb++"
            let "chn++"
            done
    fi
    
        
   if [[ ${ocd_list[0]} = " " ]]; then ocr_list=(); fi
        if [[ ! ${#ocd_list[@]} = 0 ]]; then
            for i in ${!ocd_list[@]}; do
            
            some_hash=$( echo "${ocd_list[$i]}" | cut -f1 -d"=" )
            revision=$( echo "${ocd_list[$i]}" | rev | cut -f1 -d"=" | rev )            

            if [[ $chn -le 9 ]]; then
            bbuf+=$(printf '\033['$bb';0f''               '$chn')    ')
            else
            bbuf+=$(printf '\033['$bb';0f''              '$chn')    ')
            fi
            bbuf+=$( echo ${some_hash}"   "${revision})
            let "bb++"
            let "chn++"
            done
    fi

   if [[ ${clv_list[0]} = " " ]]; then clv_list=(); fi
        if [[ ! ${#clv_list[@]} = 0 ]]; then
            for i in ${!clv_list[@]}; do
            
            some_hash=$( echo "${clv_list[$i]}" | cut -f1 -d"=" )
            revision=$( echo "${clv_list[$i]}" | rev | cut -f1 -d"=" | rev )            

            if [[ $chn -le 9 ]]; then
            bbuf+=$(printf '\033['$bb';0f''               '$chn')    ')
            else
            bbuf+=$(printf '\033['$bb';0f''              '$chn')    ')
            fi
            bbuf+=$( echo ${some_hash}"   "${revision})
            let "bb++"
            let "chn++"
            done
    fi

    if [[ ${oth_list[0]} = " " ]]; then oth_list=(); fi
        if [[ ! ${#oth_list[@]} = 0 ]]; then
            for i in ${!oth_list[@]}; do
            
            some_hash=$( echo "${oth_list[$i]}" | cut -f1 -d"=" )
            revision=$( echo "${oth_list[$i]}" | rev | cut -f1 -d"=" | rev )            

            if [[ $chn -le 9 ]]; then
            bbuf+=$(printf '\033['$bb';0f''               '$chn')    ')
            else
            bbuf+=$(printf '\033['$bb';0f''              '$chn')    ')
            fi
            bbuf+=$( echo ${some_hash}"   ""${revision}")
            let "bb++"
            let "chn++"
            done
    fi

    let "bb++"

    bbuf+=$(printf '\033['$bb';0f''   ')
	bbuf+=$(printf '.%.0s' {1..74})

    let "bb++"

 if [[ $loc = "ru" ]]; then

let "bb++"; bbuf+=$(printf '\033['$bb';0f''                  A)  Добавить хэши для Clover                  ')
let "bb++"; bbuf+=$(printf '\033['$bb';0f''                  B)  Добавить хэши релизов Open Core           ')
let "bb++"; bbuf+=$(printf '\033['$bb';0f''                  С)  Добавить хэши разработки Open Core        ')
let "bb++"; bbuf+=$(printf '\033['$bb';0f''                  O)  Добавить хэши других загрузчиков          ')
let "bb++"; bbuf+=$(printf '\033['$bb';0f''                  L)  Добавить хэши из файла со списком         ')
let "bb++"; bbuf+=$(printf '\033['$bb';0f''                  S)  Сохранить хэши из конфига в файл          ')
let "bb++"; bbuf+=$(printf '\033['$bb';0f''                  D)  Удалить хэш из файла конфигурации         ')
let "bb++"; bbuf+=$(printf '\033['$bb';0f''                  R)  Очистить ВСЮ базу хэшей                   ')
let "bb++"; bbuf+=$(printf '\033['$bb';0f''                  U)  Отменить последние изменения хэшей        ')
let "bb++"; bbuf+=$(printf '\033['$bb';0f''                  Q)  Вернуться в меню настроек                 ')
                    else
let "bb++"; bbuf+=$(printf '\033['$bb';0f''                  A)  Add hashes for Clover                     ')
let "bb++"; bbuf+=$(printf '\033['$bb';0f''                  B)  Add Open Core relases hashes              ')
let "bb++"; bbuf+=$(printf '\033['$bb';0f''                  C)  Add Open Core develop hashes              ')
let "bb++"; bbuf+=$(printf '\033['$bb';0f''                  O)  Add another loaders hashes                ')
let "bb++"; bbuf+=$(printf '\033['$bb';0f''                  L)  Add hashes from file with list            ')
let "bb++"; bbuf+=$(printf '\033['$bb';0f''                  S)  Save config hashes to file                ')
let "bb++"; bbuf+=$(printf '\033['$bb';0f''                  D)  Delete hash from config file              ')
let "bb++"; bbuf+=$(printf '\033['$bb';0f''                  R)  Remove ALL hash database                  ')
let "bb++"; bbuf+=$(printf '\033['$bb';0f''                  U)  Undo last hashes changes                  ')
let "bb++"; bbuf+=$(printf '\033['$bb';0f''                  Q)  Quit to the setup menu                    ')
                   fi
clear && printf '\e[3J' && printf "\033[0;0H" ; echo "$bbuf"
printf "%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s""%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"
printf "\033[7A"
printf "\r\033[45C"
printf "\033[?25h"
printf '\n\n'

}

GET_HASHES(){
oth_list_string="$( echo "$MountEFIconf" | grep XHashes  -A 9 | grep -A 1 -e "OTHER_HASHES</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' )"
IFS=';'
oth_list=($oth_list_string)
ocr_list=( $( echo "$MountEFIconf" | grep XHashes  -A 7 | grep -A 1 -e "OC_REL_HASHES</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n' ) )
ocd_list=( $( echo "$MountEFIconf" | grep XHashes  -A 5 | grep -A 1 -e "OC_DEV_HASHES" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n' ) )
clv_list=( $( echo "$MountEFIconf" | grep XHashes  -A 3 | grep -A 1 -e "CLOVER_HASHES</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n' ) )
unset IFS

}

BACKUP_LAST_HASHES(){
oth_list_string="$( echo "$MountEFIconf" | grep XHashes  -A 9 | grep -A 1 -e "OTHER_HASHES</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' )"
IFS=';'
oth_list_back=($oth_list_string)
ocr_list_back=( $( echo "$MountEFIconf" | grep XHashes  -A 7 | grep -A 1 -e "OC_REL_HASHES</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n' ) )
ocd_list_back=( $( echo "$MountEFIconf" | grep XHashes  -A 5 | grep -A 1 -e "OC_DEV_HASHES" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n' ) )
clv_list_back=( $( echo "$MountEFIconf" | grep XHashes  -A 3 | grep -A 1 -e "CLOVER_HASHES</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n' ) )
unset IFS
}

ADD_HASH_IN_PLIST(){ 
IFS=';'; loader_list=( $( echo "$MountEFIconf" | grep XHashes  -A ${AA} | grep -A 1 -e "${LNAME}" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n' ) ); unset IFS
         
         tlist=(); unset strng

        for y in ${!loader_list[@]}; do
            if [[ "$( echo "${loader_list[y]}" | grep -o "${hash_string}" )" = "" ]]; then tlist+=("${loader_list[y]}"); fi
         done

        tlist+=("${hash_string}")
        for y in ${!tlist[@]}; do
        strng+="${tlist[y]}"";"
        done

        plutil -replace XHashes.${L2NAME} -string "$strng" ${HOME}/.MountEFIconf.plist; UPDATE_CACHE
}

DUPLICATE_FOUND(){
if [[ $loc = "ru" ]]; then
if answer=$( osascript -e 'display dialog "Хэш '"${hash_value}"' уже есть в списках хэшей ! "  with icon caution buttons { "Удалить из списков", "Отмена добавления" } default button "Отмена добавления" ' ); then cancel=0; else cancel=1; fi 2>/dev/null
else
if answer=$( osascript -e 'display dialog "Hash value: '"${hash_value}"' found in previously saved! "  with icon caution buttons { "Delete previously saved", "Cancel saving" }  default button "Cancel saving" ' ); then cancel=0; else cancel=1; fi 2>/dev/null
fi

answer=$(echo "${answer}"  | cut -f2 -d':' ); if [[ ${answer} = "Отмена добавления" ]] || [[ ${answer} = "Cancel saving" ]]; then cancel=1; fi 

}

CHECK_DUPLICATE_HASHES(){
GET_HASHES
hash_value=${hash_string}; if [[ ! $( echo "${hash_value}" | grep -o "=" ) = "" ]]; then hash_value=$( echo "${hash_value}" | cut -f1 -d= ); fi

match=0
for ((i=0;i<4;i++)); do
    case "${i}" in
        "0" ) loader_list=( ${ocr_list[@]} ); AAA=7; LNAME2="OC_REL_HASHES</key>"; L2NAME2="OC_REL_HASHES" ;;
        "1" ) loader_list=( ${ocd_list[@]} ); AAA=5; LNAME2="OC_DEV_HASHES</key>"; L2NAME2="OC_DEV_HASHES" ;;
        "2" ) loader_list=( ${clv_list[@]} ); AAA=3; LNAME2="CLOVER_HASHES</key>"; L2NAME2="CLOVER_HASHES" ;;
        "3" ) loader_list=( ${oth_list[@]} ); AAA=9; LNAME2="OTHER_HASHES</key>"; L2NAME2="OTHER_HASHES" ;;
    esac
    IFS=';'; loader_list=( $( echo "$MountEFIconf" | grep XHashes  -A ${AAA} | grep -A 1 -e "${LNAME2}" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n' ) ); unset IFS

if [[ ! ${#loader_list[@]} = 0 ]]; then

         for y in ${!loader_list[@]}; do
            if [[ ! "$( echo "${loader_list[y]}" | grep -o "${hash_value}" )" = "" ]]; then match=1; break; fi
         done
fi

if [[ ${match} = 1 ]]; then

DUPLICATE_FOUND

    if [[ $cancel = 1 ]]; then  break
        else

        BACKUP_LAST_HASHES
        
        if [[ ! ${#loader_list[@]} = 0 ]]; then
         tlist=(); unset strng

        for y in ${!loader_list[@]}; do
            if [[ "$( echo "${loader_list[y]}" | grep -o "${hash_value}" )" = "" ]]; then tlist+=("${loader_list[y]}"); fi
         done
      if [[ ! ${#tlist[@]} = 0 ]]; then 
        for y in ${!tlist[@]}; do
        strng+="${tlist[y]}"";"
        done
        plutil -replace XHashes.${L2NAME2} -string "$strng" ${HOME}/.MountEFIconf.plist; UPDATE_CACHE
        else
        plutil -replace XHashes.${L2NAME2} -string "" ${HOME}/.MountEFIconf.plist; UPDATE_CACHE
      fi
    fi
      
        match=0 

        SHOW_HASHES_SCREEN

        break
    fi
fi
 
done
}

ENTER_OTHER_NAME(){
             demo2=""
             if [[ $loc = "ru" ]]; then
             if demo2="$(osascript -e 'set T to text returned of (display dialog "Укажите обозначение загрузчика:  '"${pattern}"'" '"${icon_string}"' buttons {"Отменить", "OK"} default button "OK" default answer "'"${adrive}"'")')"; then cancel=0; else cancel=1; fi 2>/dev/null
             else
             if demo2="$(osascript -e 'set T to text returned of (display dialog "Enter bootloader id:  '"${pattern}"'" '"${icon_string}"' buttons {"Cancel", "OK"} default button "OK" default answer "'"${adrive}"'")')"; then cancel=0; else cancel=1; fi 2>/dev/null 
             fi
              invalid_value=$( echo "${demo2}" | tr -cd "[:print:]\n" )
                        demo2="$( echo "$demo2" | tr -d \"\'\;\+\-\(\)\\ )"
                        demo2=`echo "$demo2" | tr -cd "[:print:]\n"`
                        demo2=`echo "$demo2" | tr -d "={}]><[&^$"`
                        demo2=$(echo "${demo2}" | sed 's/^[ \t]*//')
                        if [[ ${#demo2} -gt 12 ]]; then demo2="${demo2::12}"; fi
            

}

ADD_HASHES(){
loader_type=$1

    case ${loader_type} in

"Clover" ) loader="Clover"; pattern="\n   5101    4998   2546"; AA=3; LNAME="CLOVER_HASHES</key>"; L2NAME="CLOVER_HASHES";;

   "OCR" ) loader="OpenCore Release"; pattern="\n   .54r   .53d   1.3r   13.d   001r"; AA=7; LNAME="OC_REL_HASHES</key>"; L2NAME="OC_REL_HASHES";;

   "OCD" ) loader="OpenCore Develop"; pattern="\n   .54®   .53ð   .55n   1.2∂   11.ð   011®"; AA=5; LNAME="OC_DEV_HASHES</key>"; L2NAME="OC_DEV_HASHES" ;;

 "Other" ) if [[ $loc = "ru" ]]; then loader="загрузчика определямого пользователем"; pattern="\n   12 букв или цифр максимум"
                else 
                    loader="user defined loader"; pattern="\n   12 letters or numbers maximum"
           fi
           AA=9; LNAME="OTHER_HASHES</key>"; L2NAME="OTHER_HASHES"
           ;;

   esac

while true; do

            GET_APP_ICON
            
######### диалог метода задания хэша ################################
                                if [[ $loc = "ru" ]]; then
             if answer=$(osascript -e 'display dialog "Как указать хэш файла для '"${loader}"'?" '"${icon_string}"' buttons {"Вручную", "Выбрать файл", "Отмена" } default button "Вручную" '); then cancel=0; else cancel=1; fi 2>/dev/null
                                else
             if answer=$(osascript -e 'display dialog "Choose the way to add a hash for '"${loader}"'?" '"${icon_string}"' buttons {"Manually", "File Path", "Cancel" } default button "Manually" '); then cancel=0; else cancel=1; fi 2>/dev/null
                                fi
             answer=$(echo "${answer}"  | cut -f2 -d':' )

             if [[ ${answer} = "Отмена" ]]; then cancel=1; fi 

             if [[ $cancel = 1 ]]; then break; fi
        
      if [[ "${answer}" = "Вручную" ]] || [[ "${answer}" = "Manually" ]]; then

######### диалог ввода хэша вручную ##################################
           while true; do
                while true; do
             demo=""
             if [[ $loc = "ru" ]]; then
             if demo=$(osascript -e 'set T to text returned of (display dialog "Укажите 32 байта значения хэша md5 для '"${loader}"':" '"${icon_string}"' buttons {"Отменить", "OK"} default button "OK" default answer "'"${adrive}"'")'); then cancel=0; else cancel=1; fi 2>/dev/null
             else
             if demo=$(osascript -e 'set T to text returned of (display dialog "Set 32 byles of the md5 hash for '"${loader}"':" '"${icon_string}"' buttons {"Cancel", "OK"} default button "OK" default answer "'"${adrive}"'")'); then cancel=0; else cancel=1; fi 2>/dev/null 
             fi
             demo=$( echo "${demo}" | xargs )
             invalid_value=$( echo "${demo}" | tr -cd "[:print:]\n" )
             demo=$( echo "${demo}" | egrep -o '^[0-9a-f]{32}\b' )
              if [[ $cancel = 1 ]]; then break; elif [[ ${#demo} = 0 ]]; then WRONG_ANSWER; else hash_string="${demo}"; CHECK_DUPLICATE_HASHES; break; fi
                done
             if [[ $cancel = 1 ]]; then break; else
######### диалог ввода идентификатора ##################################
                while true; do
             demo2=""
          if [[ ! ${loader_type} = "Other" ]]; then 
             if [[ $loc = "ru" ]]; then
             if demo2=$(osascript -e 'set T to text returned of (display dialog "Укажите 4 байта ревизии по примерам:  '"${pattern}"'" '"${icon_string}"' buttons {"Отменить", "OK"} default button "OK" default answer "'"${adrive}"'")'); then cancel=0; else cancel=1; fi 2>/dev/null
             else
             if demo2=$(osascript -e 'set T to text returned of (display dialog "Set 4 byles revision as example:  '"${pattern}"'" '"${icon_string}"' buttons {"Cancel", "OK"} default button "OK" default answer "'"${adrive}"'")'); then cancel=0; else cancel=1; fi 2>/dev/null 
             fi
             demo2=$( echo "${demo2}" | xargs )
             invalid_value=$( echo "${demo2}" | tr -cd "[:print:]\n" )
             if [[ "${loader_type}" = "Clover" ]]; then demo2=$( echo $demo2 | egrep -o '^[0-9]{4}\b' )
                elif [[ "${loader_type}" = "OCR" ]]; then demo2=$( echo $demo2 | egrep -o '^[.0-9]{3}[rd]\b' )
                    else demo2=$( echo $demo2 | egrep -o '^[.0-9]{3}[®ðn∂]\b' )
             fi
           else
                ENTER_OTHER_NAME
           fi
             if [[ $cancel = 1 ]]; then break; fi
             if [[ ${#demo2} = 0 ]]; then WRONG_ANSWER
                ########### запись хэша в конфиг #################################################
            else hash_string=""; hash_string="${demo}""=""${demo2}"; BACKUP_LAST_HASHES; ADD_HASH_IN_PLIST;  cancel=2; break
            fi
                   done

                if [[ $cancel = 2 ]]; then break; fi

             fi
        done

            elif 
                [[ "${answer}" = "Выбрать файл" ]] || [[ "${answer}" = "File Path" ]]; then
                                    
########### диалог выбора файла для получения хэша ###############################
                  while true; do
                
                  if [[ $loc = "ru" ]]; then prompt='"ВЫБЕРИТЕ ФАЙЛ ЗАГРУЗЧИКА ДЛЯ ЗАПОМИНАНИЯ ЕГО ХЭША MD5:"'; else prompt='"SELECT FILE TO STORE ITS MD5 HASH :"'; fi
                  alias_string='"'"$(echo "$(diskutil info $(df / | tail -1 | cut -d' ' -f 1 ) |  grep "Volume Name:" | cut -d':'  -f 2 | xargs)")"':Volumes"'
                  if answer="$(osascript -e 'tell application "Terminal" to return POSIX path of (choose file default location alias '"${alias_string}"' with prompt '"${prompt}"')')"; then cancel=0; else cancel=1; fi 2>/dev/null 
                  if [[ $answer = "" ]]; then cancel=1; break; else 
                            cancel=0;  hash_string=$( md5 -qq "${answer}" )
                            CHECK_DUPLICATE_HASHES
                            if [[ $cancel = 1 ]]; then break; fi
 ########### диалог ввода версии загрузчика ######################################
             demo2="" 
          if [[ ! ${loader_type} = "Other" ]]; then                           
             if [[ $loc = "ru" ]]; then
             if demo2=$(osascript -e 'set T to text returned of (display dialog "Укажите 4 байта ревизии по примерам:  '"${pattern}"'" '"${icon_string}"' buttons {"Отменить", "OK"} default button "OK" default answer "'"${adrive}"'")'); then cancel=0; else cancel=1; fi 2>/dev/null
             else
             if demo2=$(osascript -e 'set T to text returned of (display dialog "Set 4 byles revision as example:  '"${pattern}"'" '"${icon_string}"' buttons {"Cancel", "OK"} default button "OK" default answer "'"${adrive}"'")'); then cancel=0; else cancel=1; fi 2>/dev/null 
             fi
              demo2=$( echo "${demo2}" | xargs )
              invalid_value=$( echo "${demo2}" | tr -cd "[:print:]\n" )
              if [[ "${loader_type}" = "Clover" ]]; then demo2=$( echo $demo2 | egrep -o '^[0-9]{4}\b' )
                elif [[ "${loader_type}" = "OCR" ]]; then demo2=$( echo $demo2 | egrep -o '^[.0-9]{3}[rd]\b' )
                    else demo2=$( echo $demo2 | egrep -o '^[.0-9]{3}[®ðn∂]\b' )
             fi
           else
               ENTER_OTHER_NAME
           fi
             if [[ $cancel = 1 ]]; then break; fi
             if [[ ${#demo2} = 0 ]]; then WRONG_ANSWER;
########### запись хэша в конфиг #################################################
             else hash_string+="=""${demo2}"; BACKUP_LAST_HASHES; ADD_HASH_IN_PLIST; cancel=2; break
             fi
    
             fi  
            done
             

      fi

        if [[ $cancel = 2 ]]; then break; fi
done

}

ASK_HASHES_TO_DELETE(){
if [[ $loc = "ru" ]]; then
osascript <<EOD
tell application "System Events"    activate
set ThemeList to {$file_list}
set FavoriteThemeAnswer to choose from list ThemeList with title "Удалить хэши из файла конфигурации"  with prompt "Выберите один или несколько"  with multiple selections allowed 
end tell
EOD
else
osascript <<EOD
tell application "System Events"    activate
set ThemeList to {$file_list}
set FavoriteThemeAnswer to choose from list ThemeList with title "Delete installed files" with prompt "Select one or more files"  with multiple selections allowed
end tell
EOD
fi
}

ASK_HASHES_LIST_TO_ADD(){
if [[ $loc = "ru" ]]; then
osascript <<EOD
tell application "System Events"    activate
set ThemeList to {$file_list}
set FavoriteThemeAnswer to choose from list ThemeList with title "Сохранить хэши в файле конфигурации MountEFI"  with prompt "Выберите один или несколько"  with multiple selections allowed 
end tell
EOD
else
osascript <<EOD
tell application "System Events"    activate
set ThemeList to {$file_list}
set FavoriteThemeAnswer to choose from list ThemeList with title "Save Hashes in MountEFI Configuration File" with prompt "Select one or more files"  with multiple selections allowed
end tell
EOD
fi
}

DEL_HASHES_IN_PLIST(){

IFS=';'; loader_list=( $( echo "$MountEFIconf" | grep XHashes  -A ${AA} | grep -A 1 -e "${LNAME}" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n' ) ); unset IFS

if [[ ! ${#loader_list[@]} = 0 ]]; then
         tlist=(); unset strng
        for y in ${!loader_list[@]}; do
            if [[ "$( echo "${loader_list[y]}" | grep -o "${hash_string}" )" = "" ]]; then tlist+=("${loader_list[y]}"); fi
         done

      if [[ ! ${#tlist[@]} = 0 ]]; then 
        for y in ${!tlist[@]}; do
        strng+="${tlist[y]}"";"
        done
        plutil -replace XHashes.${L2NAME} -string "$strng" ${HOME}/.MountEFIconf.plist; UPDATE_CACHE
        else
        plutil -replace XHashes.${L2NAME} -string "" ${HOME}/.MountEFIconf.plist; UPDATE_CACHE
      fi
fi

}

DEL_HASHES(){

  GET_HASHES

    file_list=""

    if [[ ! ${#oth_list[@]} = 0 ]]; then
    for i in ${!oth_list[@]}; do file_list+='"'${oth_list[i]}'"'; file_list+=","; done 
    fi

    if [[ ! ${#ocr_list[@]} = 0 ]]; then
    
    for i in ${!ocr_list[@]}; do file_list+='"'${ocr_list[i]}'"'; file_list+=","; done 
    fi

    if [[ ! ${#ocd_list[@]} = 0 ]]; then
    for i in ${!ocd_list[@]}; do file_list+='"'${ocd_list[i]}'"'; file_list+=","; done 
    fi

    if [[ ! ${#clv_list[@]} = 0 ]]; then
    for i in ${!clv_list[@]}; do file_list+='"'${clv_list[i]}'"'; file_list+=","; done 
    fi
    
    if [[ ! ${#file_list} = 0 ]]; then 

            file_list="${file_list::${#file_list}-1}"
        
            IFS=','; result=( $( ASK_HASHES_TO_DELETE ) ); unset IFS

        if [[ ! ${result[0]} = "false" ]]; then

            for i in ${!result[@]}; do result[i]="$( echo "${result[i]}" | sed 's/^[ \t]*//' )"; done

            BACKUP_LAST_HASHES
    
            for hash_string in "${result[@]}"; do

            AA=3; LNAME="CLOVER_HASHES</key>"; L2NAME="CLOVER_HASHES"; DEL_HASHES_IN_PLIST

            AA=7; LNAME="OC_REL_HASHES</key>"; L2NAME="OC_REL_HASHES"; DEL_HASHES_IN_PLIST

            AA=5; LNAME="OC_DEV_HASHES</key>"; L2NAME="OC_DEV_HASHES"; DEL_HASHES_IN_PLIST

            AA=9; LNAME="OTHER_HASHES</key>"; L2NAME="OTHER_HASHES"; DEL_HASHES_IN_PLIST

            done                
        fi
    fi
}

WRONG_FILE_TYPE(){
if [[ $loc = "ru" ]]; then
osascript -e 'display dialog "Файл не является файлом списка хэшей !  \n'"${FilePath}"'"  with icon caution buttons { "OK"}  giving up after 10' >>/dev/null 2>/dev/null
else
osascript -e 'display dialog "The file is not a hash list file !  \n'"${FilePath}"'"  with icon caution buttons { "OK"}  giving up after 10' >>/dev/null 2>/dev/null
fi
}

WRONG_PERMISSIONS(){
if [[ $loc = "ru" ]]; then
osascript -e 'display dialog "Нет доступа на запись. \nНельзя создать (изменить) файл в указанном каталоге !  \n'"${FilePath}"'"  with icon caution buttons { "OK"}  giving up after 10' >>/dev/null 2>/dev/null
else
osascript -e 'display dialog "Permission denied. \nCannot create (change) file in selected folder !  \n'"${FilePath}"'"  with icon caution buttons { "OK"}  giving up after 10' >>/dev/null 2>/dev/null
fi
}

PLACE_HASHES_IN_FILE(){

if [[ $1 = "Replace" ]]; then 
    if [[ -f "${FilePath}"".back" ]]; then rm -f "${FilePath}"".back"; fi 2>/dev/null
    if ! mv -f "${FilePath}" "${FilePath}"".back"; then WRONG_PERMISSIONS; cancel=1; break; else mv -f "${FilePath}"".back" "${FilePath}"; fi 2>/dev/null
fi

if [[ $1 = "Create" ]]; then 
    if ! touch "${FilePath}"; then WRONG_PERMISSIONS; cancel=1; break; else echo "############## oc_hashes_strings 0 #################" >> "${FilePath}"; fi 2>/dev/null
fi

file_md5_ID=$( md5 -qq "${FilePath}")

file_header="$( head -n 1 "${FilePath}" | egrep  -o '[#]* oc_hashes_strings [0-9]{1,5} [#]*' )"
                            if [[ "${file_header}" = "" ]]; then WRONG_FILE_TYPE; cancel=1; break
                                else
                                        file_lines="$(echo "${file_header}" | egrep -o '[0-9]{1,5}')"
                                     if [[ ! "${file_lines}" = 0 ]]; then
                                        hashes_array=( $( cat "${FilePath}" | egrep -o '^[0-9a-f]{32}\b=[\.0-9][\.0-9][\.0-9][\.0-9rdn®ð∂]\b' ) )
                                        demo2="$( cat "${FilePath}" | tr -d \"\'\;\+\-\(\)\\ )"
                                        demo2=`echo "$demo2" | tr -cd "[:print:]\n"`
                                        demo2=`echo "$demo2" | tr -d "{}]><[&^$"`
                                        demo2=$(echo "${demo2}" | sed 's/^[ \t]*//')
                                        hashes_others_temp_string="$( echo  "${demo2}" | egrep -o '^[0-9a-f]{32}\b=.{1,12}' | tr '\n' ';' )"
                                        hashes_others_temp_string="$( echo  "${demo2}" | egrep -o '^[0-9a-f]{32}\b=.{1,12}' | tr '\n' ';' )"
                                        IFS=';'; hashes_others_temp_array=(${hashes_others_temp_string}); unset IFS
                                        hashes_others_array=(); hashes_others_temp_string=""
                                        for i in "${hashes_others_temp_array[@]}"; do
                                            match=0
                                            for y in ${hashes_array[@]}; do
                                                if [[ ${i:0:32} = ${y:0:32} ]]; then match=1; break; fi
                                            done
                                            if [[ ${match} = 0 ]]; then hashes_others_array+=("${i}"); hashes_array+=("${i}"); fi
                                        done
        
                                    else
                                        hashes_array=(); hashes_others_array=()
                                    fi
                                
                            fi
                            
                            if [[ -f "${FilePath}"".back" ]]; then rm -f "${FilePath}"".back"; fi 2>/dev/null
                            if ! mv -f "${FilePath}" "${FilePath}"".back"; then WRONG_PERMISSIONS; cancel=1; break; fi

                              hashes_array_new=()
                                            if [[ ! ${#oth_list[@]} = 0 ]]; then for y in ${!oth_list[@]}; do hashes_array_new+=("${oth_list[y]}"); done; fi
                                            if [[ ! ${#ocr_list[@]} = 0 ]]; then for y in ${!ocr_list[@]}; do hashes_array_new+=("${ocr_list[y]}"); done; fi
                                            if [[ ! ${#ocd_list[@]} = 0 ]]; then for y in ${!ocd_list[@]}; do hashes_array_new+=("${ocd_list[y]}"); done; fi
                                            if [[ ! ${#clv_list[@]} = 0 ]]; then for y in ${!clv_list[@]}; do hashes_array_new+=("${clv_list[y]}"); done; fi

                                            file_list=""
                                 for i in ${!hashes_array_new[@]}; do file_list+='"'${hashes_array_new[i]}'"'; if [[ ! $i = $(( ${#hashes_array_new[@]}-1 )) ]]; then file_list+=","; fi ; done

                                 IFS=','; result=( $( ASK_HASHES_LIST_TO_ADD ) ); unset IFS
                                  if [[ ${result[0]} = "false" ]]; then  
                                        if [[ "${file_lines}" = 0 ]]; then rm -f "${FilePath}"".back"; else mv -f "${FilePath}"".back" "${FilePath}"; fi
                                        cancel=1; break
                                  fi

                                    for i in ${!result[@]}; do result[i]="$( echo "${result[i]}" | sed 's/^[ \t]*//' )"; done
                
                                        hashes_array_sum=()

                                 if [[ ! ${#hashes_array[@]} = 0 ]]; then 
                                        for i in ${!hashes_array[@]}; do
                                            match=0
                                            for y in ${!result[@]}; do
                                            if [[ ${hashes_array[i]::32} = ${result[y]::32} ]]; then match=1; break; fi
                                            done
                                            if [[ ${match} = 0 ]]; then hashes_array_sum+=("${hashes_array[i]}"); fi
                                        done
                                 fi
                                        for i in ${!result[@]}; do hashes_array_sum+=("${result[i]}"); done 
                                                                               
                                        echo "############## oc_hashes_strings ${#hashes_array_sum[@]} #################" >> "${FilePath}"

                                        for i in "${hashes_array_sum[@]}"; do echo "${i}" >> "${FilePath}"; done
                                        
                                        if [[ "${file_lines}" = 0 ]] && [[ -f "${FilePath}"".back" ]]; then rm -f "${FilePath}"".back"; fi 2>/dev/null
                                        if [[ ${file_md5_ID} = $( md5 -qq "${FilePath}"".back") ]]; then rm -f "${FilePath}"".back"; fi 2>/dev/null

                                        cancel=2; break

}

SAVE_HASHES_IN_FILE(){

            GET_APP_ICON

            GET_HASHES

 if [[ ${#oth_list[@]} = 0 ]] && [[ ${#ocr_list[@]} = 0 ]] && [[ ${#ocd_list[@]} = 0 ]] && [[ ${#clv_list[@]} = 0 ]]; then 

             if [[ $loc = "ru" ]]; then
            osascript -e 'display dialog " Нет сохранённых хэшей в конфиге ! " with icon caution buttons { "OK"}  giving up after 4' >>/dev/null 2>/dev/null
            else
            osascript -e 'display dialog " There is nothing to save ! " with icon caution buttons { "OK"}  giving up after 4' >>/dev/null 2>/dev/null
            fi
else
 
    while true; do
    ######### диалог запроса файла ################################
                                if [[ $loc = "ru" ]]; then
             if answer=$(osascript -e 'display dialog "Создайте файл или выберите существующий: " '"${icon_string}"' buttons {"Создать файл", "Выбрать файл", "Отмена" } default button "Создать файл" '); then cancel=0; else cancel=1; fi 2>/dev/null
                                else
             if answer=$(osascript -e 'display dialog "Create new file or select an existing one" '"${icon_string}"' buttons {"Create a file", "Choose the file", "Cancel" } default button "Create a file" '); then cancel=0; else cancel=1; fi 2>/dev/null
                                fi
             answer=$(echo "${answer}"  | cut -f2 -d':' )

             if [[ ${answer} = "Отмена" ]]; then cancel=1; fi 

             if [[ $cancel = 1 ]]; then break; fi
        
      if [[ "${answer}" = "Создать файл" ]] || [[ "${answer}" = "Create a file" ]]; then
  ########## диалог создания имени файла ###########################
           while true; do
             demo=""; Filename_string="MountEFIhashData.txt"
             if [[ $loc = "ru" ]]; then
             loader="имени файла"
             if demo=$(osascript -e 'set T to text returned of (display dialog "Напишите имя файла :" '"${icon_string}"' buttons {"Отменить", "OK"} default button "OK" default answer "'"${Filename_string}"'")'); then cancel=0; else cancel=1; fi 2>/dev/null
             else
             loader="the filename"
             if demo=$(osascript -e 'set T to text returned of (display dialog "Write a filename :" '"${icon_string}"' buttons {"Cancel", "OK"} default button "OK" default answer "'"${Filename_string}"'")'); then cancel=0; else cancel=1; fi 2>/dev/null 
             fi
             demo=$( echo "${demo}" | xargs 2>/dev/null ) 
             invalid_value=$( echo "${demo}" | tr -cd "[:print:]\n" )
             check_demo=$( echo "$demo" | egrep -o '[:"'"'"']')
             demo=`echo "$demo" | tr -d \"\'\:\\`
             if [[ $cancel = 1 ]]; then break; 
                    elif [[ ${#demo} = 0 ]] || [[ ! ${#check_demo} = 0 ]]; then 
                            WRONG_ANSWER; break
                    else 
                        Filename_string="${demo}"
             fi

                 if [[ $loc = "ru" ]]; then prompt='"ВЫБЕРИТЕ КАТАЛОГ ДЛЯ СОХРАНЕНИЯ СПИСКА ХЭШЕЙ В ФАЙЛЕ:"'; else prompt='"CHOOSE THE FOLDER TO SAVE THE HASHLIST IN FILE :"'; fi
                 if answer="$(osascript -e 'tell application "Terminal" to return POSIX path of (choose folder default location alias ((path to home folder as text)) with prompt '"${prompt}"')')"; then cancel=0; else cancel=1; fi 2>/dev/null 
                 if [[ $cancel = 1 ]]; then break; fi
                 if [[ ! $answer = "" ]]; then 
                    cancel=0
        
                   FilePath="${answer}""${Filename_string}"
        ############## если такой файл существует в выбранном каталоге ##########################
                    if [[ -f "${FilePath}" ]]; then 
                    
                         if [[ $loc = "ru" ]]; then
             if answer=$(osascript -e 'display dialog "Файл с таким именем уже существует: " '"${icon_string}"' buttons {"Заменить файл", "Выбрать другой каталог", "Отмена" } default button "Выбрать другой каталог" '); then cancel=0; else cancel=1; fi 2>/dev/null
                                else
             if answer=$(osascript -e 'display dialog "Create new file or select an existing one" '"${icon_string}"' buttons {"Replace the file", "Choose another folder", "Cancel" } default button "Create a file" '); then cancel=0; else cancel=1; fi 2>/dev/null
                                fi
             answer=$(echo "${answer}"  | cut -f2 -d':' )

                        if [[ ${answer} = "Отмена" ]]; then cancel=1; break; fi
                        if [[ "${answer}" = "Заменить файл" ]] || [[ "${answer}" = "Replace the file" ]]; then PLACE_HASHES_IN_FILE "Replace"; break; fi

                    else
                        PLACE_HASHES_IN_FILE "Create"; break                                               
                    fi
                 fi
            done     
            
       elif 
                [[ "${answer}" = "Выбрать файл" ]] || [[ "${answer}" = "Choose the file" ]]; then                                    
########### диалог выбора файла для получения хэша ###############################
                  while true; do
                
                  if [[ $loc = "ru" ]]; then prompt='"ВЫБЕРИТЕ ФАЙЛ ДЛЯ СОХРАНЕНИЯ В НЁМ СПИСКА ХЭШЕЙ :"'; else prompt='"CHOOSE A FILE TO SAVE THE HASHLIST IN IT :"'; fi
                  alias_string='"'"$(echo "$(diskutil info $(df / | tail -1 | cut -d' ' -f 1 ) |  grep "Volume Name:" | cut -d':'  -f 2 | xargs)")"':Volumes"'
                  if answer="$(osascript -e 'tell application "Terminal" to return POSIX path of (choose file default location alias '"${alias_string}"' with prompt '"${prompt}"')')"; then cancel=0; else cancel=1; fi 2>/dev/null 
                  if [[ $answer = "" ]]; then cancel=1; break
                  else 
                            cancel=0
                            FilePath="${answer}"
                            PLACE_HASHES_IN_FILE "Insert"
                            
                  fi        
                            if [[ ! $cancel = 0 ]]; then break; fi
                  done
        
      fi

        if [[ $cancel = 2 ]]; then break; fi

  done
fi

}

ADD_HASHES_LIST(){
 
                  if [[ $loc = "ru" ]]; then prompt='"ВЫБЕРИТЕ ФАЙЛ ХЭШЕЙ MD5 ЗАГРУЗЧИКОВ ДЛЯ СОХРАНЕНИЯ СПИСКА В ФАЙЛЕ КОНФИГУРАЦИИ MountEFI:"'; else prompt='"SELECT THE LOADERS MD5 HASH FILE TO SAVE THE LIST IN THE MountEFI CONFIGURATION FILE :"'; fi
                  if answer="$(osascript -e 'tell application "Terminal" to return POSIX path of (choose file default location alias ((path to home folder as text)) with prompt '"${prompt}"')')"; then cancel=0; else cancel=1; fi 2>/dev/null 
                  if [[ ! $answer = "" ]]; then 
                            cancel=0
                            hashes_array=( $( cat "${answer}" | egrep -o '^[0-9a-f]{32}\b=[\.0-9][\.0-9][\.0-9][\.0-9rdn®ð∂]\b' ) )
                            demo2="$( cat  "${answer}" | tr -d \"\'\;\+\-\(\)\\ )"
                            demo2=`echo "$demo2" | tr -cd "[:print:]\n"`
                            demo2=`echo "$demo2" | tr -d "{}]><[&^$"`
                            demo2=$(echo "${demo2}" | sed 's/^[ \t]*//')
                            hashes_others_temp_string="$( echo  "${demo2}" | egrep -o '^[0-9a-f]{32}\b=.{1,12}' | tr '\n' ';' )"
                            IFS=';'; hashes_others_temp_array=(${hashes_others_temp_string}); unset IFS
                            hashes_others_array=(); hashes_others_temp_string=""
                            for i in "${hashes_others_temp_array[@]}"; do
                                 match=0
                                 for y in ${hashes_array[@]}; do
                                    if [[ ${i:0:32} = ${y:0:32} ]]; then match=1; break; fi
                                 done
                                    if [[ ${match} = 0 ]]; then hashes_others_array+=("${i}"); hashes_array+=("${i}"); fi
                            done

                            if [[ ${#hashes_array[@]} = 0 ]]; then 
                                       if [[ $loc = "ru" ]]; then
                                     osascript -e 'display dialog "В файле не обнаружено верных записей! "   with icon caution buttons { "OK"}  giving up after 10' >>/dev/null 2>/dev/null 
                                    else
                                    osascript -e 'display dialog "The File does not contain valid values! " with icon caution buttons { "OK"}  giving up after 10' >>/dev/null 2>/dev/null 
                                    fi
                             else
                                 file_list=""
                                 for i in ${!hashes_array[@]}; do file_list+='"'${hashes_array[i]}'"'; if [[ ! $i = $(( ${#hashes_array[@]}-1 )) ]]; then file_list+=","; fi ; done

                                 IFS=','; result=( $( ASK_HASHES_LIST_TO_ADD ) ); unset IFS
                                  if [[ ! ${result[0]} = "false" ]]; then

                                    for i in ${!result[@]}; do result[i]="$( echo "${result[i]}" | sed 's/^[ \t]*//' )"; done

                                        BACKUP_LAST_HASHES

                                       for hash_string in "${result[@]}"; do
                                                                   
                                       CHECK_DUPLICATE_HASHES

                                     if [[ ! $cancel = 1 ]]; then 
                                        match=0
                                        if [[ ! ${#hashes_others_array[@]} = 0 ]]; then
                                             for n in "${hashes_others_array[@]}"; do
                                                if [[ ${hash_string:0:32} = ${n:0:32} ]]; then match=1; AA=9; LNAME="OTHER_HASHES</key>"; L2NAME="OTHER_HASHES"; break; fi
                                             done
                                    
                                        fi
                                        
                                        if [[ ${match} = 0 ]]; then 
                                        case ${hash_string:36} in

                                            [nð®] ) AA=5; LNAME="OC_DEV_HASHES</key>"; L2NAME="OC_DEV_HASHES" ;;

                                             [rd] ) AA=7; LNAME="OC_REL_HASHES</key>"; L2NAME="OC_REL_HASHES" ;;

                                         [0-9a-f] ) AA=3; LNAME="CLOVER_HASHES</key>"; L2NAME="CLOVER_HASHES" ;;

                                         esac
                                        fi
                                  
                                         ADD_HASH_IN_PLIST
                                        
                                     else 
                                         cancel=0
                                     fi

                                        done

                                 fi
                             fi
                    fi

}

UNDO_LAST_HASHES_CHANGES(){
oth_list_string=$( echo "$MountEFIconf" | grep XHashes  -A 9 | grep -A 1 -e "OTHER_HASHES</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' )
IFS=';'
oth_list_back2=($oth_list_string)
ocr_list_back2=( $( echo "$MountEFIconf" | grep XHashes  -A 7 | grep -A 1 -e "OC_REL_HASHES</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n' ) )
ocd_list_back2=( $( echo "$MountEFIconf" | grep XHashes  -A 5 | grep -A 1 -e "OC_DEV_HASHES" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n' ) )
clv_list_back2=( $( echo "$MountEFIconf" | grep XHashes  -A 3 | grep -A 1 -e "CLOVER_HASHES</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n' ) )
unset IFS

hashes_string=""
for i in "${oth_list_back[@]}"; do hashes_string+="${i}"";"; done
AA=9; LNAME="OTHER_HASHES</key>"; L2NAME="OTHER_HASHES"

plutil -replace XHashes.${L2NAME} -string "$hashes_string" ${HOME}/.MountEFIconf.plist
hashes_string=""
for i in ${ocr_list_back[@]}; do hashes_string+="${i}"";"; done
AA=7; LNAME="OC_REL_HASHES</key>"; L2NAME="OC_REL_HASHES"
plutil -replace XHashes.${L2NAME} -string "$hashes_string" ${HOME}/.MountEFIconf.plist
hashes_string=""
for i in ${ocd_list_back[@]}; do hashes_string+="${i}"";"; done
AA=5; LNAME="OC_DEV_HASHES</key>"; L2NAME="OC_DEV_HASHES"
plutil -replace XHashes.${L2NAME} -string "$hashes_string" ${HOME}/.MountEFIconf.plist
hashes_string=""
for i in ${clv_list_back[@]}; do hashes_string+="${i}"";"; done
AA=3; LNAME="CLOVER_HASHES</key>"; L2NAME="CLOVER_HASHES"
plutil -replace XHashes.${L2NAME} -string "$hashes_string" ${HOME}/.MountEFIconf.plist

UPDATE_CACHE

ocr_list_back=( ${ocr_list_back2[@]} )
ocd_list_back=( ${ocd_list_back2[@]} )
clv_list_back=( ${clv_list_back2[@]} )
oth_list_back=("${oth_list_back2[@]}")

}

REM_HASHES(){

            GET_APP_ICON

            GET_HASHES

 if [[ ${#oth_list[@]} = 0 ]] && [[ ${#ocr_list[@]} = 0 ]] && [[ ${#ocd_list[@]} = 0 ]] && [[ ${#clv_list[@]} = 0 ]]; then 


             if [[ $loc = "ru" ]]; then
            osascript -e 'display dialog " Нечего удалять ! " with icon caution buttons { "OK"}  giving up after 4' >>/dev/null 2>/dev/null
            else
            osascript -e 'display dialog " There is nothing to remove ! " with icon caution buttons { "OK"}  giving up after 4' >>/dev/null 2>/dev/null
            fi

            else
                                if [[ $loc = "ru" ]]; then
             if answer=$(osascript -e 'display dialog "Удалить ВСЕ сохранённые в файле конфигурации хэши загрузчиков? " '"${icon_string}"' buttons {"Удалить немедленно", "Отмена" } default button "Отмена" '); then cancel=0; else cancel=1; fi 2>/dev/null
                                else
             if answer=$(osascript -e 'display dialog "Delete ALL bootloader hashes stored in the configuration file?" '"${icon_string}"' buttons {"Delete immediately", "Cancel" } default button "Cancel" '); then cancel=0; else cancel=1; fi 2>/dev/null
                                fi
             answer=$(echo "${answer}"  | cut -f2 -d':' )

             if [[ ${answer} = "Отмена" ]] || [[ ${answer} = "Cancel" ]]; then cancel=1; fi 

             if [[ ! $cancel = 1 ]]; then 

            BACKUP_LAST_HASHES

			 plutil -replace XHashes.CLOVER_HASHES -string "" ${HOME}/.MountEFIconf.plist
			 plutil -replace XHashes.OC_DEV_HASHES -string "" ${HOME}/.MountEFIconf.plist
             plutil -replace XHashes.OC_REL_HASHES -string "" ${HOME}/.MountEFIconf.plist
             plutil -replace XHashes.OTHER_HASHES -string "" ${HOME}/.MountEFIconf.plist

            UPDATE_CACHE

            fi
fi
}

HASHES_EDITOR(){

SHOW_HASHES_SCREEN

BACKUP_LAST_HASHES

while true; do

unset inputs
while [[ ! ${inputs} =~ ^[aAbBcCoOsSdDrRqQlLuU]+$ ]]; do 
printf "\r"

                if [[ $loc = "ru" ]]; then
printf '  Выберите A, B, C, O, L, S, D, R, U или Q :   ' ; printf '                             '
			else
printf '     Enter A, B, C, O, L, S, D, R, U or Q :   ' ; printf '                             '
                fi
printf "%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"
printf "\033[4A"
printf "\r\033[45C"
printf "\033[?25h"

read -n 1 inputs 
if [[ $inputs = "" ]]; then printf "\033[1A"; fi
done

                    case ${inputs} in

        [qQ] ) clear && printf '\e[3J' && printf "\033[0;0H"; break;;

        [aA] )  ADD_HASHES "Clover" ;;

        [bB] ) ADD_HASHES "OCR";;

        [cC] ) ADD_HASHES "OCD";;

        [oO] ) ADD_HASHES "Other";;

        [sS] ) SAVE_HASHES_IN_FILE;;

        [dD] ) DEL_HASHES;;

        [rR] ) REM_HASHES;;

        [lL] ) ADD_HASHES_LIST;;

        [uU] ) UNDO_LAST_HASHES_CHANGES;;

                   esac
   
unset inputs

SHOW_HASHES_SCREEN

osascript -e 'tell application "Terminal" to activate' &

done

}

END_UNINSTALLER(){
while true; do
if [[ ! $(ps -xa -o tty,pid,command|  grep "/bin/bash"  |  grep -v grep  | rev | cut -f1 -d / | rev | grep -ow "MountEFI" | wc -l | bc) = 0 ]]; then
sleep 1; else break; fi
done

                                    dloc=$(defaults read com.apple.dock persistent-apps | grep file-label | awk '/MountEFI/  {printf NR}')
                                    if [[ ! "${dloc}" = "" ]]; then 
                                        dloc=$[$dloc-1]
                                        sudo -u $USER /usr/libexec/PlistBuddy -c "Delete persistent-apps:$dloc" ~/Library/Preferences/com.apple.dock.plist
                                        osascript -e 'delay 1' -e 'tell Application "Dock"' -e 'quit' -e 'end tell'
                                    fi
                                    
                                    if [[ $loc = "ru" ]]; then
                                    if answer=$(osascript -e 'display dialog "Очистка завершена !\n\nДоброго дня :)" '"${icon_string}"' buttons {"OK"} default button "OK" giving up after (3)'); then cancel=0; else cancel=1; fi 2>/dev/null
                                    else
                                    if answer=$(osascript -e 'display dialog "Сleaning completed !\n\nHave a good day :)" '"${icon_string}"' buttons {"OK"} default button "OK" giving up after (3)'); then cancel=0; else cancel=1; fi 2>/dev/null
                                    fi
                                    if [[ -f ~/.MountEFIconf.plist ]]; then rm ~/.MountEFIconf.plist; fi
                                    if [[ -d "${MEFI_PATH}" ]]; then rm -Rf "${MEFI_PATH}"; fi
}

RUN_UNINSTALLER(){
        cleared=0
        GET_APP_ICON
        if [[ $loc = "ru" ]]; then
        if RESULT="$(osascript -e 'Tell application "System Events" to display dialog "Вы запустили программу удаления MountEFI !\nВыберите один из двух уровней очистки:\n\nУровень 1.Локальная очистка:\nУдаляются все файлы и сервисы с вашего\nпользовательского раздела. \n\nУровень 2.Полная очистка:\nПосле локальной очистки выполняется\nудаление архивов настроек из iCloud\n\nФайлы удаляются необратимо\nВведите 1 или 2 для желаемого уровня:" '"${icon_string}"' giving up after (110) default answer ""' -e 'text returned of result')"; then cansel=0; else cansel=1; fi 2>/dev/null
        else
        if RESULT="$(osascript -e 'Tell application "System Events" to display dialog "You have run the MountEFI uninstall program ! \nChoose one of two levels of cleaning:\n\nLevel 1: Local Cleaning:\nAll files and running services from your \nuser partition will be removed. \n\nLevel 2: Complete Cleaning:\nAfter local cleaning, backups of your settings\nfrom iCloud will be deleted\n\nFiles will be deleted permanently !!!\nEnter 1 or 2 for the desired level:" '"${icon_string}"' giving up after (110) default answer ""' -e 'text returned of result')"; then cansel=0; else cansel=1; fi 2>/dev/null
        fi

        if [[ ! $cansel = 1 ]] && [[ ! "${RESULT}" = "" ]]; then 
            if [[ "${RESULT}" = "1" ]] || [[ "${RESULT}" = "2" ]]; then
                                
                                if [[ $loc = "ru" ]]; then
                                if [[ "${RESULT}" = "1" ]]; then explaination="Локальная очистка"; else explaination="Полная очистка"; fi
                                if answer=$(osascript -e 'display dialog "Выбран уровень '"${RESULT}: ${explaination}"'.\nПродолжать?" '"${icon_string}"' giving up after (20)'); then cancel=0; else cancel=1; fi 2>/dev/null
                                else
                                if [[ "${RESULT}" = "1" ]]; then explaination="Local Cleaning"; else explaination="Complete Cleaning"; fi
                                if answer=$(osascript -e 'display dialog "Cleaning Level '"${RESULT}: ${explaination}"'.\nProceed?" '"${icon_string}"' giving up after (20)'); then cancel=0; else cancel=1; fi 2>/dev/null
                                fi
                               
                                if [[ $cancel = 0 ]] && [[ "$(echo $answer | grep -o "gave up:true")" = "" ]]; then 

                                    cleared=1
                                ########################## локальная очистка сервисы ################################
                                    REMOVE_SYS_AUTOMOUNT_SERVICE
                                    if [[ ! $(ps -xa -o pid,command | grep -v grep | grep curl | grep MountEFI | xargs | cut -f1 -d " " | wc -l | bc ) = 0 ]]; then 
                                    kill $(ps -xa -o pid,command | grep -v grep | grep curl | grep MountEFI | xargs | cut -f1 -d " "); fi                                    
                                    if [[ $(launchctl list | grep "MountEFIu.job" | cut -f3 | grep -x "MountEFIu.job") ]]; then 
                                    launchctl unload -w ~/Library/LaunchAgents/MountEFIu.plist; fi
                                    if [[ $(launchctl list | grep "MountEFIr.job" | cut -f3 | grep -x "MountEFIr.job") ]]; then 
                                        launchctl unload -w ~/Library/LaunchAgents/MountEFIr.plist; fi
                                    security delete-generic-password -a ${USER} -s efimounter >/dev/null 2>&1
                                ########################## локальная очистка файлы ################################
                                    if [[ -f ~/.MountEFIu.sh ]]; then rm ~/.MountEFIu.sh; fi
                                    if [[ -f ~/.MountEFIr.sh ]]; then rm ~/.MountEFIr.sh; fi
                                    if [[ -d ~/Library/Application\ Support/MountEFI ]]; then rm -Rf ~/Library/Application\ Support/MountEFI; fi 
                                    if [[ -d ~/.MountEFIupdates ]]; then rm -Rf ~/.MountEFIupdates; fi
                                    if [[ -f ~/Library/LaunchAgents/MountEFIu.plist ]]; then rm  ~/Library/LaunchAgents/MountEFIu.plist; fi                                  
                                    if [[ -f ~/Library/LaunchAgents/MountEFIr.plist ]]; then rm  ~/Library/LaunchAgents/MountEFIr.plist; fi
                                    if [[ -f ~/.MountEFIconfBackups.zip ]]; then rm ~/.MountEFIconfBackups.zip; fi
                                    if [[ -d ~/.MountEFIst ]]; then rm -Rf ~/.MountEFIst; fi
                                ########################## полная очистка iCloud ################################
                                    if [[ "${RESULT}" = "2" ]]; then  
                                    hwuuid=$(ioreg -rd1 -c IOPlatformExpertDevice | awk '/IOPlatformUUID/' | cut -f2 -d"=" | tr -d '" \n')
                                        if [[ -d ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIbackups/$hwuuid ]]; then
                                        rm -Rf ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIbackups/$hwuuid
                                        rm -Rf ${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIbackups/Shared; fi
                                    fi
                                ########################## запуск удаления апплета ##############################
                                    plutil -replace Reload -bool Yes ${HOME}/.MountEFIconf.plist
                                    MEFI_PATH="$( echo "${ROOT}" | sed 's/[^/]*$//' | sed 's/.$//' | sed 's/[^/]*$//' | sed 's/.$//' | xargs)"
                                    END_UNINSTALLER &                                    
                                fi
                                            
            fi
        fi
if [[ ${cleared} = 0 ]]; then
                                    if [[ $loc = "ru" ]]; then
                                    if answer=$(osascript -e 'display dialog "Очистка отменена !" '"${icon_string}"' buttons {"OK"} default button "OK" giving up after (3)'); then cancel=0; else cancel=1; fi 2>/dev/null
                                    else
                                    if answer=$(osascript -e 'display dialog "Сleaning canceled !" '"${icon_string}"' buttons {"OK"} default button "OK" giving up after (3)'); then cancel=0; else cancel=1; fi 2>/dev/null
                                    fi
fi
}


###############################################################################
################### MAIN ######################################################
###############################################################################

SET_INPUT
theme="system"
var4=0
cd "${ROOT}"
while [ $var4 != 1 ] 
do
lines=34; col=80
if [[ "${par}" = "-r" ]] && [[ -f MountEFI ]]; then let "lines++"; fi 
if [[ ! "$quick_am" = "1" ]]; then
printf '\e[8;'${lines}';'$col't' && printf '\e[3J' && printf "\033[H"
printf "\033[?25l"
UPDATE_SCREEN
GET_INPUT
else SET_LOCALE; inputs="9"; fi
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
        theme=`echo "$MountEFIconf" |  grep -A 1 -e  "<key>Theme</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
    if [[ ! $theme = "built-in" ]]; then 
        SET_PROFILE
    else
        plutil -replace Theme -string system ${HOME}/.MountEFIconf.plist
        UPDATE_CACHE
    fi
        #SET_SYSTEM_THEME
fi 

#################################################################################
 if [[ $inputs = 6 ]]; then 
  SET_THEMES
fi

# Показывать подсказку по клавишам управления  ################################
if [[ $inputs = 7 ]]; then 
   if [[ $ShowKeys = 1 ]]; then 
  plutil -replace ShowKeys -bool NO ${HOME}/.MountEFIconf.plist
 else 
  plutil -replace ShowKeys -bool YES ${HOME}/.MountEFIconf.plist
  fi
  UPDATE_CACHE
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

# Подключение разделов при запуске системы  ################################
if [[ $inputs = 9 ]] && [[ "$quick_am" = "1" ]]; then
    if [[ $sys_autom_enabled = 1 ]]; then 
        plutil -replace SysLoadAM.Enabled -bool NO ${HOME}/.MountEFIconf.plist
        UPDATE_CACHE
        REMOVE_SYS_AUTOMOUNT_SERVICE
    else
        display=1
        SET_SYS_AUTOMOUNT
        if [[ ! $apos = 0 ]]; then
                GET_SYSTEM_FLAG
                if [[ $flag = 0 ]]; then SETUP_SYS_AUTOMOUNT
                else
                    FORCE_CHECK_PASSWORD "automount"
                    if [[ "$mypassword" = "" ]]; then SET_USER_PASSWORD; fi
                    FORCE_CHECK_PASSWORD "automount"
                    if [[ "$mypassword" = "" ]]; then 
                    plutil -replace SysLoadAM.Enabled -bool NO ${HOME}/.MountEFIconf.plist; 

                             SET_TITLE
                        if [[ $loc = "ru" ]]; then
                        echo 'SUBTITLE="АВТО-ПОДКЛЮЧЕНИЕ EFI ОТМЕНЕНО."; MESSAGE="Необходимо ввести верный пароль!"' >> ${HOME}/.MountEFInoty.sh
                        else
                        echo 'SUBTITLE="EFI AUTO-MOUNT AT LOGIN SERVICE DISABLED."; MESSAGE="You should enter a valid password!"' >> ${HOME}/.MountEFInoty.sh
                        fi
                        DISPLAY_NOTIFICATION
                    else
                        SETUP_SYS_AUTOMOUNT
                    fi
                fi
                    UPDATE_CACHE
        fi
            clear
      fi

   exit 1
fi



if [[ $inputs = 9 ]]; then 
   if [[ $sys_autom_enabled = 1 ]]; then 
  plutil -replace SysLoadAM.Enabled -bool NO ${HOME}/.MountEFIconf.plist
    UPDATE_CACHE
    REMOVE_SYS_AUTOMOUNT_SERVICE
                        SET_TITLE
                        if [[ $loc = "ru" ]]; then
                        echo 'SUBTITLE="СЕРВИС АВТО-ПОДКЛЮЧЕНИЯ EFI УДАЛЁН !"; MESSAGE=""' >> ${HOME}/.MountEFInoty.sh
                        else
                        echo 'SUBTITLE="EFI AUTO-MOUNT AT LOGIN SERVICE REMOVED !"; MESSAGE=""' >> ${HOME}/.MountEFInoty.sh
                        fi
                        DISPLAY_NOTIFICATION
else 
  display=1
  SET_SYS_AUTOMOUNT
  if [[ ! $apos = 0 ]]; then
  GET_SYSTEM_FLAG
  if [[ $flag = 0 ]]; then SETUP_SYS_AUTOMOUNT
    else
  FORCE_CHECK_PASSWORD "automount"
  if [[ "$mypassword" = "" ]]; then SET_USER_PASSWORD; fi
  FORCE_CHECK_PASSWORD "automount"
  if [[ "$mypassword" = "" ]]; then 
    plutil -replace SysLoadAM.Enabled -bool NO ${HOME}/.MountEFIconf.plist; 
                        SET_TITLE
                        if [[ $loc = "ru" ]]; then
                        echo 'SUBTITLE="АВТО-ПОДКЛЮЧЕНИЕ EFI ОТМЕНЕНО."; MESSAGE="Необходимо ввести верный пароль!"' >> ${HOME}/.MountEFInoty.sh
                        else
                        echo 'SUBTITLE="EFI AUTO-MOUNT AT LOGIN SERVICE DISABLED."; MESSAGE="You should enter a valid password!"' >> ${HOME}/.MountEFInoty.sh
                        fi
                        DISPLAY_NOTIFICATION
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
    PUT_INITCONF_IN_ICLOUD
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
         if [[ $cloud_archive = 1 ]] || [[ $shared_archive = 1 ]]; then
                        inputs="§"
                        if [[ $loc = "ru" ]]; then
                echo "Заместить локальный бэкап архивами из iCloud                       "
                if [[ $cloud_archive = 1 ]] && [[ $shared_archive = 1 ]]; then  echo "1) - Загрузить архив с этой машины. 2) -  Публичный архив          "
                    elif [[ $cloud_archive = 0 ]] && [[ $shared_archive = 1 ]]; then echo "2) - Загрузить публичный архив                                     "
                        else echo "1) - Загрузить архив с этой машины.                                "
                fi
                
                        else
                echo "Replace the local backup with archives from iCloud?                "
                if [[ $cloud_archive = 1 ]] && [[ $shared_archive = 1 ]]; then  echo "1) - Download the archive from this machine. 2) - Public           "
                    elif [[ $cloud_archive = 0 ]] && [[ $shared_archive = 1 ]]; then echo "1) - Download the archive from this machine. 2) - Public           "
                        else echo "1) - Download the archive from this machine. 2) - Public           "
                fi
                        fi
                printf "\033[?25h" 
                read -p "(1/2/N) " -n 1 -r
                printf "\033[?25l"  
                if [[ $REPLY = 1 ]] || [[ $REPLY = 2 ]]; then 
                mv  ${HOME}/.MountEFIconfBackups.zip ${HOME}/.MountEFIconfBackups2.zip
                if [[ $REPLY = 2 ]] && [[ $shared_archive = 1 ]]; then get_shared=1; GET_BACKUPS_FROM_ICLOUD; fi
                if [[ $REPLY = 1 ]] && [[ $cloud_archive = 1 ]]; then get_shared=0; GET_BACKUPS_FROM_ICLOUD; fi
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

if [[ $inputs = [bB] ]]; then SET_BACKUPS; UPDATE_CACHE; CORRECT_CURRENT_PRESET
    if [[ $need_restart = 1 ]]; then 

    UPDATE_CACHE
    need_restart=0
    fi
fi

##############################################################################

########################################################################################################################

if [[ $inputs = [Hh] ]]; then HASHES_EDITOR; fi

##############################################################################


########################################################################################################################

if [[ $inputs = [iI] ]]; then DOWNLOAD_CONFIG_FROM_FILE; 
    if [[ $errorep = 0 ]]; then UPDATE_CACHE; clear; fi
    if [[ $need_restart = 1 ]]; then 
    
    UPDATE_CACHE
    need_restart=0
   
    fi
fi

##############################################################################

if [[ $inputs = [pP] ]]; then THEME_EDITOR;  fi

##############################################################################

if [[ $inputs = [eE] ]]; then UPLOAD_CONFIG_TO_FILE;  fi

##############################################################################
if [[ $inputs = [uU] ]] && [[ "${par}" = "-r" ]]  && [[ -f ../../../MountEFI.app/Contents/Info.plist ]]; then UPDATE_PROGRAM
    if [[ $success = 1 ]]; then exit; fi
fi

#############################################################################
if [[ $inputs = [sS] ]]; then 
   if [[ $AutoUpdate = 1 ]]; then 
  plutil -replace UpdateSelfAuto -bool No ${HOME}/.MountEFIconf.plist
  DISABLE_AUTOUPDATE
                        SET_TITLE
                        if [[ $loc = "ru" ]]; then
                        echo 'SUBTITLE="Авто-обновление программы ВЫКЛЮЧЕНО !"; MESSAGE=""' >> ${HOME}/.MountEFInoty.sh
                        else
                        echo 'SUBTITLE="Auto-update DISABLED !"; MESSAGE=""' >> ${HOME}/.MountEFInoty.sh
                        fi
                        DISPLAY_NOTIFICATION 
 else 
  plutil -replace UpdateSelfAuto -bool YES ${HOME}/.MountEFIconf.plist
                        SET_TITLE
                        if [[ $loc = "ru" ]]; then
                        echo 'SUBTITLE="Авто-обновление программы ВКЛЮЧЕНО !"; MESSAGE=""' >> ${HOME}/.MountEFInoty.sh
                        else
                        echo 'SUBTITLE="Auto-update ENABLED !"; MESSAGE=""' >> ${HOME}/.MountEFInoty.sh
                        fi
                        DISPLAY_NOTIFICATION 
  fi
  UPDATE_CACHE
fi  

##############################################################################

if [[ $inputs = R ]]; then 
        plutil -replace Reload -bool Yes ${HOME}/.MountEFIconf.plist
        UPDATE_CACHE
        START_RELOAD_SERVICE 
        if [[ $par = "-r" ]]; then exit 1; else  EXIT_PROG; fi
fi
##############################################################################

if [[ $inputs = Z ]]; then
   RUN_UNINSTALLER
   if [[ $par = "-r" ]] && [[ ${cleared} = 1 ]]; then exit 1; fi
fi
##############################################################################

done

if [[ $par = "-r" ]]; then exit 1; else EXIT_PROG; fi

####################### END MAIN #################################################
###################################################################################
###################################################################################

#!/bin/bash

#  Created by Андрей Антипов on 04.02.2021.#  Copyright © 2020 gosvamih. All rights reserved.

############################################################################## Mount EFI CM #########################################################################################################################
prog_vers="1.9.0"
edit_vers="005"
serv_vers="012"
##################################################################################################################################################################################################################
# https://github.com/Andrej-Antipov/MountEFI/releases


clear  && printf '\e[3J'
printf "\033[?25l"

logfile="${HOME}/Desktop/temp.txt"
TSP(){ printf "$(date '+%M:%S.'$(echo $(python -c 'import time; print repr(time.time())') | cut -f2 -d.))    "  >> "${logfile}" 2>/dev/null; }
DBG(){ if $DEBUG; then TSP; echo $1 >> "${logfile}" 2>/dev/null; fi;  }

cd "$(dirname "$0")"; ROOT="$(dirname "$0")"

CONFPATH="${HOME}/.MountEFIconf.plist"
SERVFOLD_PATH="${HOME}/Library/Application Support/MountEFI"

rm -f "${SERVFOLD_PATH}"/UpdateRestartLock.txt

DEBUG=$(cat "${CONFPATH}" | grep -A1 "DEBUG</key>" | egrep -o "false|true"); if [[ $DEBUG = "" ]]; then DEBUG="false"; fi

DBG "CLIENT started +++++++++++++++++++++++++++++++++++++++++++++++++"

if [[ -f "${SERVFOLD_PATH}"/MEFIScA/clientDown ]]; then rm -f "${SERVFOLD_PATH}"/MEFIScA/clientDown; fi

if [ "$1" = "-d" ] || [ "$1" = "-D" ]  || [ "$1" = "-default" ]  || [ "$1" = "-DEFAULT" ]; then 
if [[ -f "${HOME}"/.MountEFIconf.plist ]]; then rm "${CONFPATH}"; fi
fi

# подготовка данных для вычисления hotplug
DBG "CLIENT: hotplug data preparation"
ustring=$( ioreg -c IOMedia -r  | tr -d '"|+{}\t'  | grep -A 10 -B 5  "Whole = Yes" | grep "BSD Name" | grep -oE '[^ ]+$' | xargs | tr ' ' ';') ; IFS=";"; uuid_list=($ustring); unset IFS; uuid_count=${#uuid_list[@]}
        if [[ ! $old_uuid_count = $uuid_count ]]; then old_uuid_count=$uuid_count; fi

pstring=$( df | cut -f1 -d " " | grep "/dev" | cut -f3 -d "/") ; puid_list=($pstring);  puid_count=${#puid_list[@]}
        if [[ ! $old_puid_count = $puid_count ]]; then  old_puid_count=$puid_count; old_puid_list=($pstring); old_uuid_list=($ustring); fi

####################################### кэш конфига #####################################################################################

UPDATE_CACHE(){
if [[ -f "${CONFPATH}" ]]; then MountEFIconf=$( cat "${CONFPATH}" ); cache=1; else cache=0; fi
}

##########################################################################################################################################

GET_LOCALE(){
if [[ $cache = 1 ]] ; then 
    locale=`echo "$MountEFIconf" | grep -A 1 "Locale" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
    if [[ ! $locale = "ru" ]] && [[ ! $locale = "en" ]]; then loc=$(defaults read -g AppleLocale | cut -d "_" -f1); else loc="${locale}"; fi
else   
    loc=`defaults read -g AppleLocale | cut -d "_" -f1`
fi  
}

#GET_INIT_FROM_ICLOUD

if [[ ! -f "${CONFPATH}" ]]; then 

hwuuid=$(ioreg -rd1 -c IOPlatformExpertDevice | awk '/IOPlatformUUID/' | cut -f2 -d"=" | tr -d '" \n')
    if [[ -d "${HOME}"/Library/Mobile\ Documents/com\~apple\~CloudDocs ]]; then
        if [[ -f "${HOME}"/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIbackups/$hwuuid/init_config_backup/.MountEFIconf.plist ]]; then 
            cp "${HOME}"/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIbackups/$hwuuid/init_config_backup/.MountEFIconf.plist "${HOME}"/
        fi
    fi
fi

UPDATE_CACHE

GET_LOCALE
########################## check restart reload ####################################################################################

rst=0
if [[ $(echo "$MountEFIconf"| grep -o "Restart") = "Restart" ]]; then
        if [[ $(launchctl list | grep "MountEFIr.job" | cut -f3 | grep -x "MountEFIr.job") ]]; then 
                launchctl unload -w "${HOME}"/Library/LaunchAgents/MountEFIr.plist; fi
        if [[ -f "${HOME}"/Library/LaunchAgents/MountEFIr.plist ]]; then rm "${HOME}"/Library/LaunchAgents/MountEFIr.plist; fi
        if [[ -f "${HOME}"/.MountEFIr.sh ]]; then rm "${HOME}"/.MountEFIr.sh; fi
        plutil -remove Restart "${CONFPATH}"; UPDATE_CACHE
        if [[ $(echo "$MountEFIconf"| grep -e "<key>Updating</key>" | grep key | sed -e 's/.*>\(.*\)<.*/\1/') = "Updating" ]]; then rst=2; else rst=1; fi
fi

if [[ $(echo "$MountEFIconf"| grep -e "<key>NO_RETURN_EASYEFI</key>" | grep key | sed -e 's/.*>\(.*\)<.*/\1/') = "NO_RETURN_EASYEFI" ]]; then
        rst=1; no_ret=1; plutil -remove NO_RETURN_EASYEFI "${CONFPATH}"; UPDATE_CACHE; else no_ret=0; fi

reload_check=`echo "$MountEFIconf"| grep -o "Reload"`
if [[ $reload_check = "Reload" ]]; then par="-s"; fi

#################### CHECK UPDATE ###################################################################################
upd=0; mfupd=0
update_check=`echo "$MountEFIconf"| grep -o "Updating"`
if [[ $update_check = "Updating" ]] && [[ -f ../../../MountEFI.app/Contents/Info.plist ]]; then
        if [[ $(launchctl list | grep "MountEFIu.job" | cut -f3 | grep -x "MountEFIu.job") ]]; then 
                launchctl unload -w "${HOME}"/Library/LaunchAgents/MountEFIu.plist; fi
            if [[ -f "${HOME}"/Library/LaunchAgents/MountEFIu.plist ]]; then rm "${HOME}"/Library/LaunchAgents/MountEFIu.plist; fi
            if [[ -f "${HOME}"/.MountEFIu.sh ]]; then rm "${HOME}"/.MountEFIu.sh; fi
            plutil -remove Updating "${CONFPATH}"; UPDATE_CACHE
            if [[ ! -d "${ROOT}"/terminal-notifier.app  ]]; then 
                    if [[ $loc = "ru" ]]; then
                    printf '\n\r  Отсутствует иконка в уведомлениях. Пытаемся загрузить с github ....\n'
                    else
                    printf '\n\r  There is no icon in the notifications. Trying to download from github ...\n'
                    fi
                if [[ ! -d "${HOME}"/.MountEFIupdates ]]; then mkdir "${HOME}"/.MountEFIupdates; fi
                curl -s --max-time 25 https://github.com/Andrej-Antipov/MountEFI/raw/master/Updates/terminal-notifier.zip -L -o "${HOME}"/.MountEFIupdates/terminal-notifier.zip 2>/dev/null
                unzip  -o -qq "${HOME}"/.MountEFIupdates/terminal-notifier.zip -d "${HOME}"/.MountEFIupdates 2>/dev/null
                if [[ -d "${HOME}"/.MountEFIupdates/terminal-notifier.app ]]; then mv -f "${HOME}"/.MountEFIupdates/terminal-notifier.app "${ROOT}"
                        if [[ $loc = "ru" ]]; then
                    printf '\n\r  Успешно :)'
                        else
                    printf '\n\r  Successfully '
                        fi
                    else
                        if [[ $loc = "ru" ]]; then
                    printf '\n\r  Неудачно :('
                        else
                    printf '\n\r  Unsuccessfully :('
                        fi
                fi
            fi
            if [[ -f "${SOURCE}.zip" ]]; then rm -Rf "${SOURCE}"; unzip  -o -qq "${SOURCE}.zip" -d "${HOME}"/.MountEFIupdates 2>/dev/null
        fi
SOURCE="${HOME}/.MountEFIupdates/${edit_vers}"
if [[ -f "${SOURCE}/DefaultConf.plist" ]]; then mv -f "${SOURCE}/DefaultConf.plist" "${ROOT}"; fi
if [[ -f "${SOURCE}/MEFIScA.sh" ]]; then mv -f "${SOURCE}/MEFIScA.sh" "${ROOT}"; fi
if [[ -f "${SOURCE}/cm_edit" ]]; then mv -f "${SOURCE}/cm_edit" "${ROOT}"; fi
if [[ -f "${SOURCE}/OC_Hashes.txt" ]]; then
    ocHashes64List=($(cat "${SOURCE}"/OC_Hashes.txt | egrep -o '^[0-9a-f]{64}\b=[\.0-9][\.0-9][\.0-9][\.0-9rd]\b'))
    ocHashes32List=($(cat "${SOURCE}"/OC_Hashes.txt | egrep -o '^[0-9a-f]{32}\b=[\.0-9][\.0-9][\.0-9x][\.0-9rdx]\b'))
    ocHashes64string=""; ocHashes32string=""
    for i in ${!ocHashes64List[@]}; do ocHashes64string+="${ocHashes64List[i]};"; done
    for i in ${!ocHashes32List[@]}; do ocHashes32string+="${ocHashes32List[i]};"; done
    if [[ $(echo "${MountEFIconf}" | grep -o "YHashes</key>") = "" ]]; then plutil -insert YHashes -xml  '<dict/>' "${CONFPATH}"; fi
    plutil -replace YHashes.ocHashes64 -string "${ocHashes64string}" "${CONFPATH}" 2>>/dev/null
    plutil -replace YHashes.ocHashes32 -string "${ocHashes32string}" "${CONFPATH}" 2>>/dev/null
    UPDATE_CACHE
    if [[ -f "${ROOT}"/DefaultConf.plist ]]; then 
        if [[ $(cat "${ROOT}"/DefaultConf.plist | grep -o "YHashes</key>") = "" ]]; then plutil -insert YHashes -xml  '<dict/>' "${ROOT}"/DefaultConf.plist; fi
        plutil -replace YHashes.ocHashes64 -string "${ocHashes64string}" "${ROOT}"/DefaultConf.plist 2>>/dev/null
        plutil -replace YHashes.ocHashes32 -string "${ocHashes32string}" "${ROOT}"/DefaultConf.plist 2>>/dev/null
    fi
fi

#IF_NEW_APPLET
            TARGET="${ROOT}/../../../MountEFI.app/Contents"
            if [[ -d "${SOURCE}/Newapp" ]]; then
                SOURCE="${HOME}/.MountEFIupdates/${edit_vers}/Newapp"
                mv -f "${SOURCE}/script" "${ROOT}/script" 2>/dev/null
                if [[ ! -d "${ROOT}/MainMenu.nib" ]]; then mv -f "${SOURCE}/MainMenu.nib" "${ROOT}/" 2>/dev/null; fi 
                if [[ ! -f "${ROOT}/AppSettings.plist" ]]; then mv -f "${SOURCE}/AppSettings.plist" "${ROOT}/AppSettings.plist" 2>/dev/null; fi
                if [[ ! -f "$TARGET/MacOS/MountEFI" ]]; then mv -f "${SOURCE}/MountEFI" "$TARGET/MacOS/MountEFI" 2>/dev/null; fi
                mv -f "${SOURCE}/Info.plist" "$TARGET/Info.plist" 2>/dev/null
                rm -f "$TARGET/document.wflow" 2>/dev/null
                rm -f "$TARGET/MacOS/Automator"* 2>/dev/null
                rm -f "$TARGET/MacOS/Application"* 2>/dev/null
                chmod +x "$TARGET/MacOS/MountEFI" "${ROOT}/script" 2>/dev/null
                touch "${ROOT}/../../../MountEFI.app" 2>/dev/null
            elif [[ -f "$TARGET/MacOS/MountEFI" ]] && [[ -f "$TARGET/document.wflow" ]] && [[ -f "${SOURCE}/Info.plist" ]] && [[ -f "${SOURCE}/Application Stub" ]]; then 
                rm -f "$TARGET/MacOS/MountEFI" "${ROOT}/AppSettings.plist" "${ROOT}/script" 2>/dev/null
                rm -Rf "${ROOT}/MainMenu.nib" 2>/dev/null
                mv -f "${SOURCE}/Info.plist" "$TARGET/Info.plist" 2>/dev/null
                mv -f "${SOURCE}/Application Stub" "$TARGET/MacOS/Application Stub" 2>/dev/null
                touch "${ROOT}/../../../MountEFI.app" 2>/dev/null
            fi

if [[ -d "${HOME}"/.MountEFIupdates ]]; then rm -Rf "${HOME}"/.MountEFIupdates; fi
upd=1; mfupd=1
fi
DBG "CLENT Update detect = $upd"

zx=Mac-$(ioreg -rd1 -c IOPlatformExpertDevice | awk '/IOPlatformUUID/' | cut -f2 -d"=" | tr -d '" ' | cut -f2-4 -d '-' | tr -d - | rev)

efimounter=$(echo 0x7a 0x78 | xxd -r)

####################################### блок перезапуска поискового агента ########################################################################################################
GET_APP_ICON(){ icon_string=""; if [[ -f "${ROOT}"/AppIcon.icns ]]; then 
   icon_string=' with icon file "'"$(echo "$(diskutil info $(df / | tail -1 | cut -d' ' -f 1 ) |  grep "Volume Name:" | cut -d':'  -f 2 | xargs)")"''"$(echo "${ROOT}" | tr "/" ":" | xargs)"':AppIcon.icns"'; fi ; }
DISPLAY_MESSAGE1(){ osascript -e 'display dialog '"${MESSAGE}"' '"${icon_string}"' buttons { "OK"} giving up after 2' >>/dev/null 2>/dev/null; }
MSG_TIMEOUT(){ if [[ $loc = "ru" ]]; then MESSAGE='"Время ожидания вышло !"'; else MESSAGE='"The waiting time is up !"'; fi; DISPLAY_MESSAGE1 >>/dev/null 2>/dev/null; }
DISPLAY_MESSAGE(){ osascript -e 'display dialog '"${MESSAGE}"' '"${icon_string}"' buttons { "OK"}' >>/dev/null 2>/dev/null; }
MSG_WAIT(){ if [[ $loc = "ru" ]]; then MESSAGE='"Подготовка данных о загрузчиках .... !"' ; else MESSAGE='"Waiting for the end of data synchro .... !"' ; fi; DISPLAY_MESSAGE >>/dev/null 2>/dev/null; }
KILL_DIALOG(){ dial_pid=$(ps ax | grep -v grep | grep -w "display dialog" | grep -w '.... ' | awk '{print $NR}'); if [[ ! $dial_pid = "" ]]; then kill $dial_pid; fi; }

POSTCONTROL_RELAUNCH_MEFIScA(){
            launchctl unload -w "${HOME}"/Library/LaunchAgents/MEFIScA.plist 2>>/dev/null
            sleep 0.5
            launchctl load -w "${HOME}"/Library/LaunchAgents/MEFIScA.plist 2>>/dev/null
            DBG "CLIENT: MEFIScA was relounched for relevant client version"
            i=16; while [[ ! -f "${SERVFOLD_PATH}"/MEFIScA/WaitSynchro ]]; do sleep 0.125; let "i--"; if [[ $i = 0 ]]; then break; fi; done
            i=140; while [[ -f "${SERVFOLD_PATH}"/MEFIScA/WaitSynchro ]]; do sleep 0.125; let "i--"; if [[ $i = 128 ]]; then GET_APP_ICON; MSG_WAIT &
            fi; if [[ $i = 0 ]]; then break; fi; done; KILL_DIALOG ; if [[ $i = 0 ]]; then GET_APP_ICON; MSG_TIMEOUT; rm -f "${SERVFOLD_PATH}"/MEFIScA/WaitSynchro; fi
#            DBG "CLIENT ••• wait WaitSynchro OFF $((140-i)) cycles"
}
##################################### Инициализация нового конфига и правка старого ###################################################

MEFI_MD5=$(md5 -qq MountEFI)
if [[ ! -f "${HOME}"/Library/Application\ Support/MountEFI/validconf/${MEFI_MD5} ]]; then

    login=`echo "$MountEFIconf" | grep -Eo "LoginPassword"  | tr -d '\n'`
    if [[ $login = "LoginPassword" ]]; then
        mypassword="$(echo "$MountEFIconf" | grep -A 1 "LoginPassword" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n')"
        if [[ ! $mypassword = "" ]]; then
            if ! (security find-generic-password -a ${USER} -s ${!efimounter} -w) >/dev/null 2>&1; then
                security add-generic-password -a ${USER} -s ${!efimounter} -w "${mypassword}" >/dev/null 2>&1
            fi
            plutil -remove LoginPassword ""${HOME}""/.MountEFIconf.plist; UPDATE_CACHE
        fi
    fi


    deleted=0
    if [[ $cache = 1 ]]; then
    strng=`echo "$MountEFIconf" | grep  "<key>CurrentPreset</key>" | grep key | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\t\n'`
        if [[ ! $strng = "CurrentPreset" ]]; then
            theme=`echo "$MountEFIconf" |  grep -A 1   "<key>Theme</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
            rm "${CONFPATH}"; unset MountEFIconf; cache=0; deleted=1
        fi
    fi

    if [[ ! $cache = 1 ]]; then
        if [[ -f DefaultConf.plist ]]; then
            cp DefaultConf.plist "${CONFPATH}"
        else
    #FILL_CONFIG
    echo '<?xml version="1.0" encoding="UTF-8"?>' >> "${CONFPATH}"
            echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' >> "${CONFPATH}"
            echo '<plist version="1.0">' >> "${CONFPATH}"
            echo '<dict>' >> "${CONFPATH}"
            echo '	<key>AutoMount</key>' >> "${CONFPATH}"
            echo '	<dict>' >> "${CONFPATH}"
            echo '  <key>Enabled</key>' >> "${CONFPATH}"
            echo '  <false/>' >> "${CONFPATH}"
            echo '  <key>Open</key>' >> "${CONFPATH}"
            echo '  <false/>' >> "${CONFPATH}"
            echo '  <key>PartUUIDs</key>' >> "${CONFPATH}"
            echo '  <string> </string>' >> "${CONFPATH}"
            echo '  <key>Timeout2Exit</key>' >> "${CONFPATH}"
            echo '  <integer>10</integer>' >> "${CONFPATH}"
            echo '	</dict>' >> "${CONFPATH}"
            echo '	<key>Backups</key>' >> "${CONFPATH}"
            echo '	<dict>' >> "${CONFPATH}"
            echo '  <key>Auto</key>' >> "${CONFPATH}"
            echo '  <true/>' >> "${CONFPATH}"
            echo '  <key>Maximum</key>' >> "${CONFPATH}"
            echo '  <integer>20</integer>' >> "${CONFPATH}"
            echo '	</dict>' >> "${CONFPATH}"
            echo '          <key>CheckLoaders</key>' >> "${CONFPATH}"
            echo '          <true/>' >> "${CONFPATH}"
            echo '          <key>CurrentPreset</key>' >> "${CONFPATH}"
            echo '          <string>BlueSky</string>' >> "${CONFPATH}"
            echo '          <key>Locale</key>' >> "${CONFPATH}"
            echo '          <string>auto</string>' >> "${CONFPATH}"
            echo '          <key>Menue</key>' >> "${CONFPATH}"
            echo '          <string>always</string>' >> "${CONFPATH}"
            echo '          <key>OpenFinder</key>' >> "${CONFPATH}"
            echo '          <true/>' >> "${CONFPATH}"
            echo '          <key>Presets</key>' >> "${CONFPATH}"
            echo '  <dict>' >> "${CONFPATH}"
            echo '      <key>BlueSky</key>' >> "${CONFPATH}"
            echo '      <dict>' >> "${CONFPATH}"
            echo '          <key>BackgroundColor</key>' >> "${CONFPATH}"
            echo '          <string>{4096, 15458, 40092}</string>' >> "${CONFPATH}"
            echo '          <key>FontName</key>' >> "${CONFPATH}"
            echo '          <string>Menlo Regular</string>' >> "${CONFPATH}"
            echo '          <key>FontSize</key>' >> "${CONFPATH}"
            echo '          <string>12</string>' >> "${CONFPATH}"
            echo '          <key>TextColor</key>' >> "${CONFPATH}"
            echo '          <string>{56831, 61439, 53247}</string>' >> "${CONFPATH}"
            echo '      </dict>' >> "${CONFPATH}"
            echo '      <key>DarkBlueSky</key>' >> "${CONFPATH}"
            echo '      <dict>' >> "${CONFPATH}"
            echo '          <key>BackgroundColor</key>' >> "${CONFPATH}"
            echo '          <string>{8481, 10537, 33667}</string>' >> "${CONFPATH}"
            echo '          <key>FontName</key>' >> "${CONFPATH}"
            echo '          <string>SF Mono</string>' >> "${CONFPATH}"
            echo '          <key>FontSize</key>' >> "${CONFPATH}"
            echo '          <string>12</string>' >> "${CONFPATH}"
            echo '          <key>TextColor</key>' >> "${CONFPATH}"
            echo '          <string>{65278, 64507, 0}</string>' >> "${CONFPATH}"
            echo '      </dict>' >> "${CONFPATH}"
            echo '      <key>GreenField</key>' >> "${CONFPATH}"
            echo '      <dict>' >> "${CONFPATH}"
            echo '          <key>BackgroundColor</key>' >> "${CONFPATH}"
            echo '          <string>{1028, 12850, 10240}</string>' >> "${CONFPATH}"
            echo '          <key>FontName</key>' >> "${CONFPATH}"
            echo '          <string>SF Mono</string>' >> "${CONFPATH}"
            echo '          <key>FontSize</key>' >> "${CONFPATH}"
            echo '          <string>12</string>' >> "${CONFPATH}"
            echo '          <key>TextColor</key>' >> "${CONFPATH}"
            echo '          <string>{61937, 60395, 47288}</string>' >> "${CONFPATH}"
            echo '      </dict>' >> "${CONFPATH}"
            echo '      <key>Ocean</key>' >> "${CONFPATH}"
            echo '      <dict>' >> "${CONFPATH}"
            echo '          <key>BackgroundColor</key>' >> "${CONFPATH}"
            echo '          <string>{1028, 12850, 65535}</string>' >> "${CONFPATH}"
            echo '          <key>FontName</key>' >> "${CONFPATH}"
            echo '          <string>SF Mono Regular</string>' >> "${CONFPATH}"
            echo '          <key>FontSize</key>' >> "${CONFPATH}"
            echo '          <string>12</string>' >> "${CONFPATH}"
            echo '          <key>TextColor</key>' >> "${CONFPATH}"
            echo '          <string>{65535, 65535, 65535}</string>' >> "${CONFPATH}"
            echo '      </dict>' >> "${CONFPATH}"
            echo '      <key>Tolerance</key>' >> "${CONFPATH}"
            echo '      <dict>' >> "${CONFPATH}"
            echo '          <key>BackgroundColor</key>' >> "${CONFPATH}"
            echo '          <string>{40092, 40092, 38293}</string>' >> "${CONFPATH}"
            echo '          <key>FontName</key>' >> "${CONFPATH}"
            echo '          <string>SF Mono</string>' >> "${CONFPATH}"
            echo '          <key>FontSize</key>' >> "${CONFPATH}"
            echo '          <string>12</string>' >> "${CONFPATH}"
            echo '          <key>TextColor</key>' >> "${CONFPATH}"
            echo '          <string>{40606, 4626, 0}</string>' >> "${CONFPATH}"
            echo '      </dict>' >> "${CONFPATH}"
            echo '  </dict>' >> "${CONFPATH}"
            echo '  <key>RenamedHD</key>' >> "${CONFPATH}"
            echo '  <string> </string>' >> "${CONFPATH}"
            echo '  <key>ShowKeys</key>' >> "${CONFPATH}"
            echo '  <true/>' >> "${CONFPATH}"
            echo '	<key>SysLoadAM</key>' >> "${CONFPATH}"
	        echo '	<dict>' >> "${CONFPATH}"
	        echo '           <key>Enabled</key>' >> "${CONFPATH}"
	        echo '           <false/>' >> "${CONFPATH}"
	        echo '           <key>Open</key>' >> "${CONFPATH}"
	        echo '           <false/>' >> "${CONFPATH}"
	        echo '           <key>PartUUIDs</key>' >> "${CONFPATH}"
	        echo '           <string> </string>' >> "${CONFPATH}"
            echo '  </dict>' >> "${CONFPATH}"
            echo '  <key>Theme</key>' >> "${CONFPATH}"
            echo '  <string>built-in</string>' >> "${CONFPATH}"
            echo '  <key>ThemeLoaders</key>' >> "${CONFPATH}"
            echo '  <string>37</string>' >> "${CONFPATH}"
            echo '  <key>ThemeLoadersLinks</key>' >> "${CONFPATH}"
            echo '  <string> </string>' >> "${CONFPATH}"
            echo '  <key>ThemeLoadersNames</key>' >> "${CONFPATH}"
            echo '  <string>Clover;OpenCore</string>' >> "${CONFPATH}"
            echo '  <key>ThemeProfile</key>' >> "${CONFPATH}"
            echo '  <string>default</string>' >> "${CONFPATH}"
            echo '  <key>UpdateSelfAuto</key>' >> "${CONFPATH}"
            echo '  <true/>' >> "${CONFPATH}"
            echo '	<key>XHashes</key>' >> "${CONFPATH}"
	        echo '	<dict>' >> "${CONFPATH}"
	        echo '           <key>CLOVER_HASHES</key>' >> "${CONFPATH}"
	        echo '           <string></string>' >> "${CONFPATH}"
	        echo '           <key>OC_DEV_HASHES</key>' >> "${CONFPATH}"
	        echo '           <string></string>' >> "${CONFPATH}"
	        echo '           <key>OC_REL_HASHES</key>' >> "${CONFPATH}"
	        echo '           <string></string>' >> "${CONFPATH}"
	        echo '           <key>OTHER_HASHES</key>' >> "${CONFPATH}"
	        echo '           <string></string>' >> "${CONFPATH}"
            echo '  </dict>' >> "${CONFPATH}"
            echo '	<key>startupMount</key>' >> "${CONFPATH}"
	        echo '  <true/>' >> "${CONFPATH}"
            echo '</dict>' >> "${CONFPATH}"
            echo '</plist>' >> "${CONFPATH}"

        fi
    fi

    if [[ $deleted = 1 ]]; then
        plutil -replace Theme -string $theme "${CONFPATH}" 
    fi

    if [[ $cache = 0 ]]; then UPDATE_CACHE; fi
    strng=`echo "$MountEFIconf"| grep -e "<key>ShowKeys</key>" | grep key | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\t\n'`
    if [[ ! $strng = "ShowKeys" ]]; then plutil -replace ShowKeys -bool YES "${CONFPATH}"; cache=0; fi

    strng=`echo "$MountEFIconf"| grep -e "<key>CheckLoaders</key>" | grep key | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\t\n'`
    if [[ ! $strng = "CheckLoaders" ]]; then plutil -replace CheckLoaders -bool NO "${CONFPATH}"; cache=0; fi

    strng=`echo "$MountEFIconf" | grep -e "<key>AutoMount</key>" | grep key | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\t\n'`
    if [[ ! $strng = "AutoMount" ]]; then 
			plutil -insert AutoMount -xml  '<dict/>'   "${CONFPATH}"
			plutil -insert AutoMount.Enabled -bool NO "${CONFPATH}"
			plutil -insert AutoMount.ExitAfterMount -bool NO "${CONFPATH}"
			plutil -insert AutoMount.Open -bool NO "${CONFPATH}"
			plutil -insert AutoMount.PartUUIDs -string " " "${CONFPATH}"
            cache=0
    fi

    strng=`echo "$MountEFIconf" | grep -e "<key>SysLoadAM</key>" | grep key | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\t\n'`
    if [[ ! $strng = "SysLoadAM" ]]; then 
			plutil -insert SysLoadAM -xml  '<dict/>'   "${CONFPATH}"
			plutil -insert SysLoadAM.Enabled -bool NO "${CONFPATH}"
			plutil -insert SysLoadAM.Open -bool NO "${CONFPATH}"
            plutil -insert SysLoadAM.PartUUIDs -string " " "${CONFPATH}"
            cache=0
    fi

    strng=`echo "$MountEFIconf" | grep AutoMount -A 11 | grep -o "Timeout2Exit" | tr -d '\n'`
    if [[ ! $strng = "Timeout2Exit" ]]; then
            plutil -insert AutoMount.Timeout2Exit -integer 5 "${CONFPATH}"
            cache=0
    fi

    strng=`echo "$MountEFIconf" | grep -e "<key>RenamedHD</key>" |  sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\t\n'`
    if [[ ! $strng = "RenamedHD" ]]; then
            plutil -insert RenamedHD -string " " "${CONFPATH}"
            cache=0
    fi

    strng=`echo "$MountEFIconf" | grep -e "<key>Backups</key>" | grep key | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\t\n'`
    if [[ ! $strng = "Backups" ]]; then 
             plutil -insert Backups -xml  '<dict/>'   "${CONFPATH}"
             plutil -insert Backups.Maximum -integer 10 "${CONFPATH}"
             cache=0
    fi

    strng=`echo "$MountEFIconf" | grep -e "<key>ThemeLoaders</key>" |  sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\t\n'`
    if [[ ! $strng = "ThemeLoaders" ]]; then
            plutil -insert ThemeLoaders -string "37" "${CONFPATH}"
            cache=0
    fi

    strng=`echo "$MountEFIconf" | grep -e "<key>ThemeLoadersLinks</key>" |  sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\t\n'`
    if [[ ! $strng = "ThemeLoadersLinks" ]]; then
            plutil -insert ThemeLoadersLinks -string " " "${CONFPATH}"
            cache=0
    fi

    strng=`echo "$MountEFIconf" | grep -e "<key>ThemeLoadersNames</key>" |  sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\t\n'`
    if [[ ! $strng = "ThemeLoadersNames" ]]; then
            plutil -insert ThemeLoadersNames -string "Clover;OpenCore" "${CONFPATH}"
            cache=0
    fi

    strng=`echo "$MountEFIconf" | grep -e "<key>ThemeProfile</key>" |  sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\t\n'`
    if [[ ! $strng = "ThemeProfile" ]]; then
            plutil -insert ThemeProfile -string "default" "${CONFPATH}"
            cache=0
    fi

    strng=`echo "$MountEFIconf"| grep -e "<key>UpdateSelfAuto</key>" | grep key | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\t\n'`
    if [[ ! $strng = "UpdateSelfAuto" ]]; then plutil -replace UpdateSelfAuto -bool YES "${CONFPATH}"; cache=0; fi

    strng=`echo "$MountEFIconf" | grep -e "<key>XHashes</key>" | grep key | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\t\n'`
    if [[ ! $strng = "XHashes" ]]; then 
			plutil -insert XHashes -xml  '<dict/>'   "${CONFPATH}"
			plutil -insert XHashes.CLOVER_HASHES -string "" "${CONFPATH}"
			plutil -insert XHashes.OC_DEV_HASHES -string "" "${CONFPATH}"
            plutil -insert XHashes.OC_REL_HASHES -string "" "${CONFPATH}"
            plutil -insert XHashes.OTHER_HASHES -string "" "${CONFPATH}"
            cache=0
    fi

    strng=`echo "$MountEFIconf"| grep -e "<key>EasyEFImode</key>" | grep key | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\t\n'`
    if [[ ! $strng = "EasyEFImode" ]]; then plutil -replace EasyEFImode -bool NO "${CONFPATH}"; cache=0; fi
    strng=`echo "$MountEFIconf"| grep -e "<key>EasyEFIsimple</key>" | grep key | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\t\n'`
    if [[ ! $strng = "EasyEFIsimple" ]]; then plutil -replace EasyEFIsimple -bool Yes "${CONFPATH}"; cache=0; fi

    strng=`echo "$MountEFIconf"| grep -e "<key>startupMount</key>" | grep key | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\t\n'`
    if [[ ! $strng = "startupMount" ]]; then plutil -replace startupMount -bool NO "${CONFPATH}"; cache=0; fi

    if $(echo "$MountEFIconf" | grep -A 1 -e "startupMount</key>" | egrep -o "false|true"); then
        if [[ $(launchctl list | grep -o "MEFIScA.job") = "" ]]; then plutil -replace startupMount -bool NO "${CONFPATH}"; cache=0; fi
    fi

    if [[ $(echo "$MountEFIconf" | grep -ow "GUIcolorMode</key>") = "" ]]; then plutil -replace GUIcolorMode -bool Yes "${CONFPATH}"; cache=0; fi

    if [[ -f "${ROOT}"/DefaultConf.plist ]]; then
    ocHashes32string=$(cat "${ROOT}"/DefaultConf.plist | grep -A3  "<key>YHashes</key>" | grep -A1 -o "<key>ocHashes32</key>" | grep string |  sed -e 's/.*>\(.*\)<.*/\1/')
    ocHashes64string=$(cat "${ROOT}"/DefaultConf.plist | grep -A5  "<key>YHashes</key>" | grep -A1 -o "<key>ocHashes64</key>" | grep string |  sed -e 's/.*>\(.*\)<.*/\1/')
    if [[ $(echo "${MountEFIconf}" | grep -o "YHashes</key>") = "" ]]; then plutil -insert YHashes -xml  '<dict/>' "${CONFPATH}"; fi
    plutil -replace YHashes.ocHashes64 -string "${ocHashes64string}" "${CONFPATH}" 2>>/dev/null
    plutil -replace YHashes.ocHashes32 -string "${ocHashes32string}" "${CONFPATH}" 2>>/dev/null
    cache=0
    fi

    if [[ $cache = 0 ]]; then UPDATE_CACHE; fi
    
    if [[ ! -d "${HOME}"/Library/Application\ Support/MountEFI/validconf ]]; then mkdir -p "${HOME}"/Library/Application\ Support/MountEFI/validconf; fi
    rm -f "${HOME}"/Library/Application\ Support/MountEFI/validconf/*; touch "${HOME}"/Library/Application\ Support/MountEFI/validconf/${MEFI_MD5}

    if (security find-generic-password -a ${USER} -s efimounter -w) >/dev/null 2>&1; then
    mypassword=$(security find-generic-password -a ${USER} -s efimounter -w)
    security delete-generic-password -a ${USER} -s efimounter >/dev/null 2>&1
    security add-generic-password -a ${USER} -s ${!efimounter} -w "${mypassword}" >/dev/null 2>&1
    fi

    ####################################### IF_RELOAD_MEFIScA ############################################
        DBG "Проверям наличие поискового агента"
    if [[ ! $(launchctl list | grep -o "MEFIScA.job") = "" ]] && [[ -f "${SERVFOLD_PATH}"/MEFIScA/MEFIScA.sh ]]; then  
         if [[ $(launchctl list | grep "MEFIScA.job" | awk '{print $1}'| grep -o "[0-9]*") = "" ]] || [[ ! $(cat "${SERVFOLD_PATH}"/MEFIScA/MEFIScA.sh | grep 'serv_vers="[0-9]*"' | cut -f2 -d= | tr -d '"' ) = "$serv_vers" ]]; then
            cp -a "${ROOT}"/MEFIScA.sh "${SERVFOLD_PATH}"/MEFIScA/MEFIScA.sh; chmod +x "${SERVFOLD_PATH}"/MEFIScA/MEFIScA.sh
            touch "${SERVFOLD_PATH}"/MEFIScA/reloadFlag    
            POSTCONTROL_RELAUNCH_MEFIScA
         fi
      else
          DBG " CLIENT проверяет должен ли быть запущен MEFIScA"
          if $(echo "$MountEFIconf" | grep -A 1 -e "startupMount</key>" | egrep -o "false|true") && [[ -f "${ROOT}"/MEFIScA.sh ]]; then
            DBG "CLIENT агент должен быть запущен. Запуск."
            if [[ ! -d "${SERVFOLD_PATH}"/MEFIScA ]]; then mkdir -p "${SERVFOLD_PATH}"/MEFIScA; fi
            cp -a "${ROOT}"/MEFIScA.sh "${SERVFOLD_PATH}"/MEFIScA/MEFIScA.sh; chmod +x "${SERVFOLD_PATH}"/MEFIScA/MEFIScA.sh

            echo '<?xml version="1.0" encoding="UTF-8"?>' >> ${HOME}/.MEFIScA.plist
            echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' >> ${HOME}/.MEFIScA.plist
            echo '<plist version="1.0">' >> ${HOME}/.MEFIScA.plist
            echo '<dict>' >> ${HOME}/.MEFIScA.plist
            echo '  <key>Label</key>' >> ${HOME}/.MEFIScA.plist
            echo '  <string>MEFIScA.job</string>' >> ${HOME}/.MEFIScA.plist
            echo '  <key>Nicer</key>' >> ${HOME}/.MEFIScA.plist
            echo '  <integer>1</integer>' >> ${HOME}/.MEFIScA.plist
            echo '  <key>ProgramArguments</key>' >> ${HOME}/.MEFIScA.plist
            echo '  <array>' >> ${HOME}/.MEFIScA.plist
            echo '      <string>/Users/'"$(whoami)"'/Library/Application Support/MountEFI/MEFIScA/MEFIScA.sh</string>' >> ${HOME}/.MEFIScA.plist
            echo '  </array>' >> ${HOME}/.MEFIScA.plist
            echo '  <key>RunAtLoad</key>' >> ${HOME}/.MEFIScA.plist
            echo '  <true/>' >> ${HOME}/.MEFIScA.plist
            echo '</dict>' >> ${HOME}/.MEFIScA.plist
            echo '</plist>' >> ${HOME}/.MEFIScA.plist

            mv -f ${HOME}/.MEFIScA.plist ~/Library/LaunchAgents/MEFIScA.plist
            DBG "CLIENT поисковый агент запущен"
            POSTCONTROL_RELAUNCH_MEFIScA
          fi 
    fi
    ##########################################################################################################
fi
#############################################################################################################################################

GET_LOADERS(){ if $(echo "$MountEFIconf" | grep -A 1 -e "CheckLoaders</key>" | egrep -o "true|false"); then CheckLoaders=1; else CheckLoaders=0; fi; }

SET_TITLE(){ echo '#!/bin/bash'  >> "${HOME}"/.MountEFInoty.sh; echo '' >> "${HOME}"/.MountEFInoty.sh; echo 'TITLE="MountEFI"' >> "${HOME}"/.MountEFInoty.sh; echo 'SOUND="Submarine"' >> "${HOME}"/.MountEFInoty.sh; }

DISPLAY_NOTIFICATION(){

if [[ -d "${ROOT}"/terminal-notifier.app ]] && [[ ${macos} -lt "1016" ]]; then
echo ''"'$(echo "$ROOT")'"'/terminal-notifier.app/Contents/MacOS/terminal-notifier -title "MountEFI" -sound Submarine -subtitle "${SUBTITLE}" -message "${MESSAGE}"'  >> "${HOME}"/.MountEFInoty.sh
sleep 1.5
else
echo 'COMMAND="display notification \"${MESSAGE}\" with title \"${TITLE}\" subtitle \"${SUBTITLE}\" sound name \"${SOUND}\""; osascript -e "${COMMAND}"' >> "${HOME}"/.MountEFInoty.sh
fi
echo ' exit' >> "${HOME}"/.MountEFInoty.sh
chmod u+x "${HOME}"/.MountEFInoty.sh
sh "${HOME}"/.MountEFInoty.sh
rm "${HOME}"/.MountEFInoty.sh
}

WARNING_MSG(){
if [[ $loc = "ru" ]]; then
osascript -e 'display dialog '"${error_message}"'  with icon caution buttons { "Продолжить", "Прекратить" } default button "Прекратить" giving up after 110'  2>/dev/null
else
osascript -e 'display dialog '"${error_message}"'  with icon caution buttons { "Continue", "Abort" } default button "Abort" giving up after 110'  2>/dev/null
fi
}

CHECK_SANDBOX(){
if [[ -f "$ROOT"/version.txt ]]; then
    if ! touch "$ROOT"/version.txt 2>/dev/null; then 
        SET_TITLE
                    if [[ $loc = "ru" ]]; then
                echo 'SUBTITLE="MountEFI запущен в ПЕСОЧНИЦЕ !"; MESSAGE="Переместите апплет в другую папку !"' >> "${HOME}"/.MountEFInoty.sh
                    else
                echo 'SUBTITLE="MountEFI runs in SANDBOX !"; MESSAGE="Move the applet to another place !"' >> "${HOME}"/.MountEFInoty.sh
                    fi
                DISPLAY_NOTIFICATION
    fi
fi   
}

################################ reset password ############################################
if [ "$1" = "-r" ] || [ "$1" = "-R" ]  || [ "$1" = "-reset" ]  || [ "$1" = "-RESET" ]; then 
    if (security find-generic-password -a ${USER} -s ${!efimounter} -w) >/dev/null 2>&1; then
    security delete-generic-password -a ${USER} -s ${!efimounter} >/dev/null 2>&1
    fi
fi
#############################################################################################
SAVE_LOADERS_STACK(){
if [[ -d "${HOME}"/.MountEFIst ]]; then rm -Rf "${HOME}"/.MountEFIst; fi; mkdir "${HOME}"/.MountEFIst
if [[ ! ${#mounted_loaders_list[@]} = 0 ]]; then touch "${HOME}"/.MountEFIst/.mounted_loaders_list; max=0; for y in ${!mounted_loaders_list[@]}; do if [[ ${max} -lt ${y} ]]; then max=${y}; fi; done
    for ((h=0;h<=max;h++)); do echo ${mounted_loaders_list[h]} >> "${HOME}"/.MountEFIst/.mounted_loaders_list; done; fi
if [[ ! ${#ldlist[@]} = 0 ]]; then touch "${HOME}"/.MountEFIst/.ldlist; max=0; for y in ${!ldlist[@]}; do if [[ ${max} -lt ${y} ]]; then max=${y}; fi; done
    for ((h=0;h<=max;h++)); do echo "${ldlist[h]}" >> "${HOME}"/.MountEFIst/.ldlist; done; fi
if [[ ! ${#lddlist[@]} = 0 ]]; then touch "${HOME}"/.MountEFIst/.lddlist; max=0; for y in ${!lddlist[@]}; do if [[ ${max} -lt ${y} ]]; then max=${y}; fi; done
    for ((h=0;h<=max;h++)); do echo ${lddlist[h]} >> "${HOME}"/.MountEFIst/.lddlist; done; fi
if [[ ! ${#oc_list[@]} = 0 ]]; then touch "${HOME}"/.MountEFIst/.oc_list; max=0; for y in ${!oc_list[@]}; do if [[ ${max} -lt ${y} ]]; then max=${y}; fi; done
    for ((h=0;h<=max;h++)); do echo "${oc_list[h]}" >> "${HOME}"/.MountEFIst/.oc_list; done; fi
}

#запоминаем на каком терминале и сколько процессов у нашего скрипта
#############################################################################################################################
MyTTY=$(tty | tr -d " dev/\n")
MyPID=$(ps -x | grep -v grep  | grep  "MountEFI$" | xargs | cut -f1 -d' ')
MyZPID=$(ps | grep -v grep  | grep $MyTTY | grep zsh | xargs | cut -f1 -d' ')
term=$(ps);  MyTTYcount=$(echo "$term" | egrep -o $MyTTY | wc -l | bc)
##############################################################################################################################

CLEAR_HISTORY(){
if [[ -f "${HOME}"/.bash_history ]]; then cat  "${HOME}"/.bash_history | sed -n '/MountEFI/!p' >> "${HOME}"/new_hist.txt; rm -f "${HOME}"/.bash_history; mv "${HOME}"/new_hist.txt "${HOME}"/.bash_history ; fi >/dev/null 2>/dev/null
if [[ -f "${HOME}"/.zsh_history ]]; then cat  "${HOME}"/.zsh_history | sed -n '/MountEFI/!p' >> "${HOME}"/new_z_hist.txt; rm -f "${HOME}"/.zsh_history; mv "${HOME}"/new_z_hist.txt "${HOME}"/.zsh_history ; fi >/dev/null 2>/dev/null
}

################## Выход из программы с проверкой - выгружать терминал из трея или нет #####################################################
EXIT_PROGRAM(){

TERMINATE(){
kill $MyPID
if [[ ${zpid} = 1 ]] && [[ ! ${MyZPID} = "" ]]; then
   if [[ ! $(ps | grep -v grep | grep $MyZPID | grep $MyTTY) = "" ]]; then kill ${MyZPID}; fi
fi 
}

################################## очистка на выходе #############################################################
rm -f  "${HOME}"/.disk_list.txt
if [[ -f ../Info.plist ]]; then rm -f version.txt; echo ${prog_vers}";"${edit_vers} >> version.txt; fi
CLEAR_HISTORY
#####################################################################################################################
#CHECK_TTY_COUNT
term=$(ps); AllTTYcount=$( echo "$term" | egrep -o 'ttys[0-9]{1,3}' | wc -l |  bc )
TTYcount=$((AllTTYcount-MyTTYcount))
zpid=0
if [[ ${TTYcount} -ge 1 ]] && [[ ! ${MyZPID} = "" ]]; then
   if [[ ! $(ps | grep -v grep | grep $MyZPID | grep $MyTTY) = "" ]]; then ((--TTYcount)); zpid=1; fi
fi
	
osascript -e 'tell application "Terminal" to set visible of (every window whose name contains "MountEFI")  to false'
TERMINATE &
if [[ ${TTYcount} = 0  ]];then  osascript -e 'tell application "Terminal" to close (every window whose name contains "MountEFI")' && osascript -e 'quit app "terminal.app"' & exit
else
   osascript -e 'tell application "Terminal" to close (every window whose name contains "MountEFI")' & exit
 fi
}


# Установка флага необходимости в SUDO - flag
GET_FLAG(){
macos=$(sw_vers -productVersion | tr -d .); macos=${macos:0:5}; if [[ ${#macos} = 3 ]]; then macos+="00"; fi
if [[ "${macos:0:4}" -gt "1130" ]] || [[ "${macos}" -lt "1090" ]]; then 
    if [[ ! $(sw_vers -productVersion | tr -d .) = $(echo "$MountEFIconf" | grep -A1 "<key>UnsupportedExecution</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/') ]]; then
############## ERROR_OS_VERSION
        if [[ $loc = "ru" ]]; then 
        error_message='"Работа программы не проверялась с этой\nверсией Mac OS : '$(sw_vers -productVersion)' !\nПосле подтверждения работа программы\nбудет продолжена, но корректное исполнение функций не гарантируется.\n"'
        else error_message='"This program has not been tested\non Mac OS version: '$(sw_vers -productVersion)' !\nAfter confirmation, the execution will continue\nBut the correct execution is not guaranteed."'; fi
        warn_answer=$(echo $(WARNING_MSG) | egrep -o "button returned:Continue,|Abort,|Продолжить,|Прекратить," | tr -d ',' | cut -f2 -d:)
        if [[ "$warn_answer" = "Продолжить" || "$warn_answer" = "Continue" ]]; then plutil -replace UnsupportedExecution -string $(sw_vers -productVersion | tr -d .) "${CONFPATH}"; UPDATE_CACHE; else EXIT_PROGRAM; fi
##############################
    fi
fi
if [[ "$macos" -lt "10130" ]]; then flag=0; else flag=1; fi; macos=${macos:0:4}
}

##################### получение имени и версии загрузчика ######################################################################################

GET_LOADER_STRING(){                
               GET_OTHER_LOADERS_STRING               
               if [[ ! "${loader:0:5}" = "Other" ]]; then 
                    check_loader=$( xxd -l 40000 "$vname"/EFI/BOOT/BOOTX64.EFI | egrep -om1  "OpenCore" )
                    if [[ "${check_loader}" = "" ]]; then check_loader=$( xxd "$vname"/EFI/BOOT/BOOTX64.EFI | egrep -om1  "Clover|GNU/Linux|Microsoft C|Refind" ); fi
                    case "${check_loader}" in
                    "Clover"    ) loader="Clover"; GET_CONFIG_VERS "Clover"
                                revision=$( xxd "$vname"/EFI/BOOT/BOOTX64.efi | grep -a1 "Clover" | cut -c 50-68 | tr -d ' \n' | egrep -o  'revision:[0-9]{4}' | cut -f2 -d: )
                                if [[ ${revision} = "" ]]; then revision=$( xxd  "$vname"/EFI/BOOT/BOOTX64.efi | grep -a1 'revision:' | cut -c 50-68 | tr -d ' \n' | egrep -o  'revision:[0-9]{4}' | cut -f2 -d: ); fi
                                loader+="${revision:0:4}"
                                ;;
  
                    "OpenCore"  ) GET_OC_VERS; loader="OpenCore"; loader+="${oc_revision}"
                        ;;
                    "GNU/Linux" ) loader="GNU/Linux"                                       
                        ;;
                    "Refind"    ) loader="refind"                                          
                        ;;
                    "Microsoft C" ) loader="Windows"; loader+="®"                           
                        ;;
                               *) loader="unrecognized"                                    
                        ;;
                    esac    
                    if [[ ${loader} = "unrecognized" ]]; then GET_CONFIG_VERS "ALL"; fi
                fi
}

##################################################################################################################################################

# Oпределение функции обновления экрана в случае замены файла загрузчика ####################################################
RECHECK_LOADERS(){
if [[ ! $CheckLoaders = 0 ]]; then
    if [[ $pauser = "" ]] || [[ $pauser = 0 ]]; then
        let "pauser=3"; update_screen_flag=0
        for pnum in ${!dlist[@]}
        do
        mounted_check=$( df | grep ${dlist[$pnum]} )   
            if [[ ! $mounted_check = "" ]]; then 
            vname=`df | egrep ${dlist[$pnum]} | sed 's#\(^/\)\(.*\)\(/Volumes.*\)#\1\3#' | cut -c 2-`
                    if ! loader_sum=$( md5 -qq "$vname"/EFI/BOOT/BOOTx64.efi 2>/dev/null); then loader_sum=0; fi

                    if [[ ! ${loader_sum} = 0 ]] && [[ $( xxd -l 40000 "$vname"/EFI/BOOT/BOOTX64.EFI | egrep -om1 "OpenCore" ) = "OpenCore" ]]; then md5_loader=${loader_sum}; GET_OC_VERS
                       if [[ ! "${old_oc_revision[pnum]}" = "${oc_revision}" ]]; then old_oc_revision[pnum]="${oc_revision}"; update_screen_flag=1; else update_screen_flag=0; fi
                    fi

                    if [[ ! ${mounted_loaders_list[$pnum]} = ${loader_sum} ]] || [[ ${update_screen_flag} = 1 ]]; then 
                    mounted_loaders_list[$pnum]=${loader_sum}
                    if [[ ${loader_sum} = 0 ]]; then loader="empty"; else md5_loader=${loader_sum}; loader=""; oc_revision=""; revision="";  GET_LOADER_STRING; fi
                    ldlist[pnum]="$loader"; lddlist[pnum]=${dlist[$pnum]}
                    let "chs=pnum+1"; if [[ "${recheckLDs}" = "1" ]]; then recheckLDs=2; fi; UPDATE_SCREEN; break; fi
            fi
        done
    else
        let "pauser=pauser-1"
    fi
fi
}
#################################################################################################################################

SHOW_VERSION(){
clear && printf '\e[8;24;'$col't' && printf '\e[3J' && printf "\033[H"
printf "\033[?25l"
if [[ ! "$1" = "-u" ]]; then GET_LOADERS; else CheckLoaders=0; fi
var=24
while [[ ! $var = 0 ]]; do
if [[ ! $CheckLoaders = 0 ]]; then printf '\e[40m %.0s\e[0m' {1..94};  else printf '\e[40m %.0s\e[0m' {1..80}; fi
let "var--"; done
if [[ ! $CheckLoaders = 0 ]]; then vcorr=35; v2corr=27; v3corr=28; v4corr=23; v6corr=36; v7corr=17; v8corr=40; else vcorr=28; v2corr=20; v3corr=21; v4corr=15; v6corr=29; v7corr=10; v8corr=33; fi
printf "\033[H"

KILL_CURL_UPDATER(){
for i in $(ps -xa -o pid,command | grep -v grep | grep curl | grep api.github.com | xargs | cut -f1 -d " " | wc -l | bc ); do 
    kill $(ps -xa -o pid,command | grep -v grep | grep curl | grep api.github.com | xargs | cut -f1 -d " ") 2>/dev/null; done
} 

NET_UPDATE_CLOVER(){
if ping -c 1 google.com >> /dev/null 2>&1; then
    clov_vrs=$( curl -s  https://api.github.com/repos/CloverHackyColor/CloverBootloader/releases/latest | grep browser_download_url | cut -d '"' -f 4 | rev | cut -d '/' -f1  | rev | grep Clover | egrep -o '[0-9]{4}.zip' | sed s'/.zip//' )
    if [[ ! "${clov_vrs}" = "" ]] || [[ ${#clov_vrs} -le 4 ]]; then echo $clov_vrs > "${HOME}"/Library/Application\ Support/MountEFI/latestClover.txt; fi
fi
}

NET_UPDATE_OPENCORE(){
if ping -c 1 google.com >> /dev/null 2>&1; then
    oc_vrs=$( curl -s  https://api.github.com/repos/acidanthera/OpenCorePkg/releases/latest | grep browser_download_url | cut -d '"' -f 4 | rev | cut -d '/' -f1  | rev | sed s'/.zip//' | tr -d '.' | egrep -om1  '[0-9]{3,4}-' | tr -d '-' )
    if [[ ! "${oc_vrs}" = "" ]] || [[ ${#oc_vrs} -le 4 ]]; then echo $oc_vrs > "${HOME}"/Library/Application\ Support/MountEFI/latestOpenCore.txt; fi
fi
}

NET_UPDATE_LOADERS(){
 if ping -c 1 google.com >> /dev/null 2>&1; then
                if [[ -f "${HOME}"/Library/Application\ Support/MountEFI/pdateLoadersVersionsNetTime.txt ]]; then rm -f "${HOME}"/Library/Application\ Support/MountEFI/pdateLoadersVersionsNetTime.txt; fi
                if [[ -f "${HOME}"/Library/Application\ Support/MountEFI/latestClover.txt ]]; then rm -f "${HOME}"/Library/Application\ Support/MountEFI/latestClover.txt; fi
                if [[ -f "${HOME}"/Library/Application\ Support/MountEFI/latestOpenCore.txt ]]; then rm -f "${HOME}"/Library/Application\ Support/MountEFI/latestOpenCore.txt; fi
    clov_vrs=$( curl -s  https://api.github.com/repos/CloverHackyColor/CloverBootloader/releases/latest | grep browser_download_url | cut -d '"' -f 4 | rev | cut -d '/' -f1  | rev | grep Clover | egrep -o '[0-9]{4}.zip' | sed s'/.zip//' )
    oc_vrs=$(curl -s  https://api.github.com/repos/acidanthera/OpenCorePkg/releases/latest | grep browser_download_url | cut -d '"' -f 4 | rev | cut -d '/' -f1  | rev | sed s'/.zip//' | tr -d '.' | egrep -om1  '[0-9]{3,4}-' | tr -d '-' )
    if [[ ! -d "${HOME}"/Library/Application\ Support/MountEFI ]]; then mkdir -p "${HOME}"/Library/Application\ Support/MountEFI; fi
        if [[ ! "${clov_vrs}" = "" ]] || [[ ! "${oc_vrs}" = "" ]]; then
            echo $clov_vrs > "${HOME}"/Library/Application\ Support/MountEFI/latestClover.txt
            echo $oc_vrs > "${HOME}"/Library/Application\ Support/MountEFI/latestOpenCore.txt
            date +%s > "${HOME}"/Library/Application\ Support/MountEFI/updateLoadersVersionsNetTime.txt
        fi
fi
}

if [[ ${AutoUpdate} = 1 ]]; then
                    if [[ $loc = "ru" ]]; then
                        if [[ -f "${HOME}"/Library/Application\ Support/MountEFI/AutoUpdateInfoTime.txt ]]; then
                        AutoUpdateCheckTime="$(date -r "$((86400+$(cat "${HOME}"/Library/Application\ Support/MountEFI/AutoUpdateInfoTime.txt)))"  '+%d/%m/%Y %H:%M')"
                        else
                        AutoUpdateCheckTime="$(date '+%d/%m/%Y %H:%M')"
                        fi
                            printf "\033[4;'$v4corr'f"; printf '\e[40m\e[1;33m        Авто-обновление \e[1;35mMountEFI\e[1;33m включено! \e[0m'
                            printf "\033[5;'$v4corr'f"; printf '\e[40m\e[1;33m    Следующая проверка не ранее \e[1;32m'"${AutoUpdateCheckTime}"' \e[0m'
                    else
                        if [[ -f "${HOME}"/Library/Application\ Support/MountEFI/AutoUpdateInfoTime.txt ]]; then
                        AutoUpdateCheckTime="$(date -r "$((86400+$(cat "${HOME}"/Library/Application\ Support/MountEFI/AutoUpdateInfoTime.txt)))"  '+%m/%d/%Y %H:%M')"
                        else
                        AutoUpdateCheckTime="$(date '+%m/%d/%Y %H:%M')"
                        fi
                            printf "\033[4;'$v4corr'f"; printf '\e[40m\e[1;33m            Auto update \e[1;35mMountEFI\e[1;33m enabled! \e[0m'
                            printf "\033[5;'$v4corr'f"; printf '\e[40m\e[1;33m Next update check no earlier than \e[1;32m'"${AutoUpdateCheckTime}"' \e[0m'

                    fi
fi


printf "\033[8;'$v3corr'f"
printf '\e[40m\e[1;33m________________________________________\e[0m''\n\033['$v2corr'C'
printf '\e[40m\e[1;33m[                                      ]\e[0m''\n\033['$v2corr'C'
printf '\e[40m\e[1;33m[                                      ]\e[0m''\n\033['$v2corr'C'
printf '\e[40m\e[1;33m[                                      ]\e[0m''\n\033['$v2corr'C'
printf '\e[40m\e[1;33m[                                      ]\e[0m''\n\033['$v2corr'C'
printf '\e[40m\e[1;33m[______________________________________]\e[0m''\n'
printf '\r\033[3A\033['$vcorr'C' ; printf '\e[40m\e[1;35m  MountEFI v. \e[1;33m'$prog_vers'.\e[1;32m '$edit_vers' \e[1;35m©\e[0m''\n' 
if [[ ! "$1" = "-u" ]]; then printf "\033[23;'$v4corr'f"; printf '\e[40m\e[1;33mhttps://github.com/Andrej-Antipov/MountEFI/releases \e[0m'; fi
    if [[ "$1" = "-u" ]]; then 
                           if [[ $loc = "ru" ]]; then
                           let "v5corr=v4corr+16"
                           printf "\033[21;'$v5corr'f"; printf '\e[40m\e[33mОбновление выполнено! \e[0m'
                           else
                           let "v5corr=v4corr+17"
                           printf "\033[21;'$v5corr'f"; printf '\e[40m\e[33m  Update completed! \e[0m'
                           fi
                           read -s -n 1 -t 3
      else
#if [[ ! $CheckLoaders = 0 ]]; then 
    ppid=0
    while true; do 
            recheckLDs=1; demo="~"; need_update=0
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
    if [[ ! ${oc_vrs} = "" ]]; then printf "\033[17;'$v6corr'f"'\e[40m\e[1;33m'"  Latest \e[1;35mOpenCore: "'\e[1;36m'${oc_vrs:0:1}"\e[1;32m.\e[1;36m"${oc_vrs:1:1}"\e[1;32m.\e[1;36m"${oc_vrs:2:1}' \e[0m'
                                    printf "\033[18;'$v7corr'f"'\e[40m\e[36m     https://github.com/acidanthera/OpenCorePkg/releases  \e[0m'
                               else printf "\033[17;'$v6corr'f"'\e[40m                             \e[0m'
                                    printf "\033[18;'$v7corr'f"'\e[40m                                                          \e[0m'
    fi
    clov_vrs=$(head -1 ~/Library/Application\ Support/MountEFI/latestClover.txt 2>/dev/null)
    if [[ ! ${clov_vrs} = "" ]]; then printf "\033[19;'$v8corr'f"'\e[40m\e[1;33m'"    \e[1;35mClover:  "'\e[1;32m'${clov_vrs:0:4}'\e[0m' 
                                      printf "\033[20;'$v7corr'f"'\e[40m\e[36m  https://github.com/CloverHackyColor/CloverBootloader/releases   \e[0m'
                                 else printf "\033[19;'$v8corr'f"'\e[40m                 \e[0m' 
                                      printf "\033[20;'$v7corr'f"'\e[40m                                                                  \e[0m'
    fi
    
    if [[ $(ps -xa -o pid,command | grep -v grep | grep curl | grep api.github.com | xargs | cut -f1 -d " " | wc -l | bc ) = 0 ]] && [[ $(ps -xa -o pid,command | grep -v grep | cut -f1 -d " " | grep -ow $ppid | xargs | cut -f1 -d " " | wc -l | bc ) = 0 ]]; then 
    ppid=0
    fi
    CHECK_HOTPLUG_DISKS; read -rsn1 -t2 demo; if [[ ! $demo = "~" ]] || [[ $hotplug = 1 ]] || [[ "${recheckLDs}" = "2" ]]; then printf '\033[1D\e[40m \e[0m'; pauser=0; RECHECK_LOADERS; recheckLDs=0; KILL_CURL_UPDATER; if [[ ! $ppid = 0 ]]; then kill $ppid; wait $ppid ; fi; break; fi
   done 
#fi
fi
clear && printf "\e[3J"
}

EASYEFI_RESTART_APP(){
MEFI_PATH="$(echo "${ROOT}" | sed 's/[^/]*$//' | sed 's/.$//' | sed 's/[^/]*$//' | sed 's/.$//' |  xargs)"

echo '<?xml version="1.0" encoding="UTF-8"?>' >> "${HOME}"/.MountEFIr.plist
echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' >> "${HOME}"/.MountEFIr.plist
echo '<plist version="1.0">' >> "${HOME}"/.MountEFIr.plist
echo '<dict>' >> "${HOME}"/.MountEFIr.plist
echo '  <key>Label</key>' >> "${HOME}"/.MountEFIr.plist
echo '  <string>MountEFIr.job</string>' >> "${HOME}"/.MountEFIr.plist
echo '  <key>Nicer</key>' >> "${HOME}"/.MountEFIr.plist
echo '  <integer>1</integer>' >> "${HOME}"/.MountEFIr.plist
echo '  <key>ProgramArguments</key>' >> "${HOME}"/.MountEFIr.plist
echo '  <array>' >> "${HOME}"/.MountEFIr.plist
echo '      <string>/Users/'"$(whoami)"'/.MountEFIr.sh</string>' >> "${HOME}"/.MountEFIr.plist
echo '  </array>' >> "${HOME}"/.MountEFIr.plist
echo '  <key>RunAtLoad</key>' >> "${HOME}"/.MountEFIr.plist
echo '  <true/>' >> "${HOME}"/.MountEFIr.plist
echo '</dict>' >> "${HOME}"/.MountEFIr.plist
echo '</plist>' >> "${HOME}"/.MountEFIr.plist

echo '#!/bin/bash'  >> "${HOME}"/.MountEFIr.sh
echo ''             >> "${HOME}"/.MountEFIr.sh
echo 'sleep 1'             >> "${HOME}"/.MountEFIr.sh
echo ''             >> "${HOME}"/.MountEFIr.sh
echo 'i=60; while [[ ! $i = 0 ]]; do' >> "${HOME}"/.MountEFIr.sh
echo 'if [[ ! $(ps -xa -o pid,command |  grep -v grep | grep -ow "MountEFI.app" | wc -l | bc) = 0 ]] || [[ -f "${HOME}"/Library/Application\ Support/MountEFI/UpdateRestartLock.txt  ]]; then' >> "${HOME}"/.MountEFIr.sh
echo 'i=$((i-1)); sleep 0.25; else break; fi; done' >> "${HOME}"/.MountEFIr.sh
echo 'arg=''"'$(echo $par)'"''' >> "${HOME}"/.MountEFIr.sh
echo 'ProgPath=''"'$(echo "$MEFI_PATH")'"''' >> "${HOME}"/.MountEFIr.sh
echo '            open "${ProgPath}"'  >> "${HOME}"/.MountEFIr.sh
echo ''             >> "${HOME}"/.MountEFIr.sh
echo 'exit'             >> "${HOME}"/.MountEFIr.sh

chmod u+x "${HOME}"/.MountEFIr.sh

if [[ -f "${HOME}"/.MountEFIr.plist ]]; then mv -f "${HOME}"/.MountEFIr.plist "${HOME}"/Library/LaunchAgents/MountEFIr.plist; fi
if [[ ! $(launchctl list | grep "MountEFIr.job" | cut -f3 | grep -x "MountEFIr.job") ]]; then launchctl load -w "${HOME}"/Library/LaunchAgents/MountEFIr.plist; fi

plutil -replace EasyEFImode -bool Yes "${CONFPATH}"
plutil -replace Restart -bool Yes "${CONFPATH}"

if [[ $mefisca = 1 ]]; then touch "${SERVFOLD_PATH}"/MEFIScA/clientRestart; sleep 0.5; fi

SAVE_LOADERS_STACK

EXIT_PROGRAM
}

CHECK_AUTOUPDATE(){
AutoUpdate=1
strng=`echo "$MountEFIconf"  | grep -A 1 -e "UpdateSelfAuto</key>" | grep false | tr -d "<>/"'\n\t'`
if [[ $strng = "false" ]]; then AutoUpdate=0; fi
}

if [[ ! $upd = 0 ]]; then 
        check_version=(); if [[ -f version.txt ]]; then IFS=";"; check_version=( $(cat version.txt) ); unset IFS ; fi
        if [[ ! "${prog_vers}" = "${check_version[0]}" ]] || [[ ! "${edit_vers}" = "${check_version[1]}" ]]; then
        if [[ -f ../Info.plist ]]; then rm -f version.txt; echo ${prog_vers}";"${edit_vers} >> version.txt; fi
    CHECK_AUTOUPDATE
    if [[ ${AutoUpdate} = 1 ]] && [[ $(echo "$MountEFIconf"| grep -o "ReadyToAutoUpdate") = "ReadyToAutoUpdate" ]]; then
                        GET_FLAG
                        plutil -remove ReadyToAutoUpdate "${CONFPATH}"; UPDATE_CACHE 
                        SET_TITLE
                        if [[ $loc = "ru" ]]; then
                        echo 'SUBTITLE="Авто-обновление программы выполнено !"; MESSAGE="Версия программы '${prog_vers}' редакция '${edit_vers}'"' >> "${HOME}"/.MountEFInoty.sh
                        else
                        echo 'SUBTITLE="Update completed !"; MESSAGE="MountEFI v'${prog_vers}' edit v'${edit_vers}'"' >> "${HOME}"/.MountEFInoty.sh
                        fi
                        DISPLAY_NOTIFICATION
        if [[ $rst = 2 ]]; then if [[ -d "${SERVFOLD_PATH}"/MEFIScA ]]; then touch "${SERVFOLD_PATH}"/MEFIScA/clientUpdated; fi; EASYEFI_RESTART_APP; fi
    else
                        col=80; SHOW_VERSION -u
    fi
  fi
fi

if [[ -d "${HOME}"/.MountEFIconfBackups ]]; then rm -R -f "${HOME}"/.MountEFIconfBackups; fi
if [[ ! -f "${HOME}"/.MountEFIconfBackups.zip ]]; then 
#GET_BACKUPS_FROM_ICLOUD
hwuuid=$(ioreg -rd1 -c IOPlatformExpertDevice | awk '/IOPlatformUUID/' | cut -f2 -d"=" | tr -d '" \n')
    if [[ -d "${HOME}"/Library/Mobile\ Documents/com\~apple\~CloudDocs ]]; then
       if [[ -f "${HOME}"/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIbackups/$hwuuid/.MountEFIconfBackups.zip ]]; then
            cp "${HOME}"/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIbackups/$hwuuid/.MountEFIconfBackups.zip  "${HOME}"
       else
                if [[ -f "${HOME}"/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIbackups/Shared/.MountEFIconfBackups.zip ]]; then
                    cp "${HOME}"/Library/Mobile\ Documents/com\~apple\~CloudDocs/.MountEFIbackups/Shared/.MountEFIconfBackups.zip  "${HOME}"
            fi
       fi 
    fi  
 fi
            if [[ ! -f "${HOME}"/.MountEFIconfBackups.zip ]]; then
            mkdir "${HOME}"/.MountEFIconfBackups
            mkdir "${HOME}"/.MountEFIconfBackups/1
            cp "${CONFPATH}" "${HOME}"/.MountEFIconfBackups/1
            zip -rX -qq "${HOME}"/.MountEFIconfBackups.zip "${HOME}"/.MountEFIconfBackups
            rm -R "${HOME}"/.MountEFIconfBackups
fi

CHECK_RELOAD(){
restart_check=`echo "$MountEFIconf"| grep -e "<key>Restart</key>" | grep key | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\t\n'`
reload_check=`echo "$MountEFIconf"| grep -e "<key>Reload</key>" | grep key | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\t\n'`
update_check=`echo "$MountEFIconf"| grep -e "<key>Updating</key>" | grep key | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\t\n'`
if [[ $reload_check = "Reload" ]] || [[ $update_check = "Updating" ]] || [[ $restart_check = "Restart" ]]; then rel=1; else rel=0; fi
}
 
ENTER_PASSWORD(){

mypassword="0"; unset cancel; unset PASSWORD; braked=0
if (security find-generic-password -a ${USER} -s ${!efimounter} -w) >/dev/null 2>&1; then
                if [[ ! "$1" = "force" ]]; then
                mypassword=$(security find-generic-password -a ${USER} -s ${!efimounter} -w)
                else
                security delete-generic-password -a ${USER} -s ${!efimounter} >/dev/null 2>&1
                        SET_TITLE
                        if [[ $loc = "ru" ]]; then
                        echo 'SUBTITLE="СТАРЫЙ ПАРОЛЬ УДАЛЁН ИЗ СВЯЗКИ КЛЮЧЕЙ!"; MESSAGE="Подключение разделов EFI НЕ работает"' >> "${HOME}"/.MountEFInoty.sh
                        else
                        echo 'SUBTITLE="OLD PASSWORD REMOVED FROM KEYCHAIN !"; MESSAGE="Mount EFI Partitions NOT Available"' >> "${HOME}"/.MountEFInoty.sh
                        fi
                        DISPLAY_NOTIFICATION 
                fi
fi
if [[ "$mypassword" = "0" ]] || [[ "$1" = "force" ]]; then
  
  if [[ $flag = 1 ]] || ( [[ $flag = 0 ]] && [[ "$(sysctl -n kern.safeboot)" = "1" ]] ); then 
        
        if [[ $flag = 0 ]]  && [[ "$(sysctl -n kern.safeboot)" = "1" ]]; then
            if [[ $loc = "ru" ]]; then
                sudo_message='Для подключения EFI разделов в режиме безопасной загрузки нужен пароль!'
            else
                sudo_message='Password is required to mount EFI partitions in safe boot mode!'
        fi
  else
        if [[ $loc = "ru" ]]; then
                sudo_message='Для подключения EFI разделов нужен пароль!'
        else
                sudo_message='Password is required to mount EFI partitions!'
        fi
 fi

        TRY=3
        while [[ ! $TRY = 0 ]]; do
        while true; do
        if [[ $loc = "ru" ]]; then
        PASS_ANSWER="$(osascript -e 'Tell application "System Events" to display dialog "'"${sudo_message}"'\nВы можете выбрать его хранение в связке ключей\n\nПользователь:  '"$(if [[ ${macos:0:3} = "109" ]]; then id -P | cut -f8 -d: ; else id -F ; fi)"'\nВведите ваш пароль:" buttons {"OK", "Сохранить в связке", "Отмена"  } default button "OK" '"${icon_string}"' giving up after (110) with hidden answer  default answer ""')" 2>/dev/null
        else
        PASS_ANSWER="$(osascript -e 'Tell application "System Events" to display dialog "'"${sudo_message}"'\nYou can choose to store the password in the keychain\n\nUser Name:  '"$(if [[ ${macos:0:3} = "109" ]]; then id -P | cut -f8 -d: ; else id -F ; fi)"'\nEnter your password:" buttons {"OK", "Store in keychain", "Cancel"  } default button "OK" '"${icon_string}"' giving up after (110) with hidden answer  default answer ""')" 2>/dev/null
        fi 
        if [[ $(echo "${PASS_ANSWER}" | egrep -o "gave up:.*" | cut -f2 -d:) = "false" ]]; then break; fi
        done

                pressed_button=$(echo "${PASS_ANSWER}" | egrep -o "button returned:OK,|Cancel,|Store in keychain,|Отмена,|Сохранить в связке," | tr -d ',' | cut -f2 -d:)
                PASSWORD=$(echo "${PASS_ANSWER}" | egrep -o "text returned:.*," | tr -d ',' | cut -f2 -d:)
     
                if [[ "$pressed_button" = "Отмена" || "$pressed_button" = "Cancel" || "${PASSWORD}" = "" ]]; then mypassword="0"; cansel=1; braked=1; break; else cansel=0; fi  

                mypassword="${PASSWORD}" 
                if [[ $mypassword = "" ]]; then mypassword="?"; fi

                if echo "${mypassword}" | sudo -S printf '' 2>/dev/null; then
                  if [[ "$pressed_button" = "Store in keychain" || "$pressed_button" = "Сохранить в связке" ]]; then       
                    security add-generic-password -a ${USER} -s ${!efimounter} -w "${mypassword}" >/dev/null 2>&1
                        SET_TITLE
                        if [[ $loc = "ru" ]]; then
                        echo 'SUBTITLE="ПАРОЛЬ СОХРАНЁН В СВЯЗКЕ КЛЮЧЕЙ !"; MESSAGE="Управляйте паролем через настройки программы"' >> "${HOME}"/.MountEFInoty.sh
                        else
                        echo 'SUBTITLE="PASSWORD KEEPED IN KEYCHAIN !"; MESSAGE="Manage the password in the program settings"' >> "${HOME}"/.MountEFInoty.sh
                        fi
                        DISPLAY_NOTIFICATION
                   fi
                        break
                else
                        if [[ $loc = "ru" ]]; then printf '\033[1A\r\033[48C''                                \r\033[48C'; else 
                                                   printf '\033[1A\r\033[50C''                                \r\033[50C'; fi
                        let "TRY--"
                        if [[ ! $TRY = 0 ]]; then 
                        SET_TITLE
                            if [[ $loc = "ru" ]]; then
                        if [[ $TRY = 2 ]]; then ATTEMPT="ПОПЫТКИ"; LAST="ОСТАЛОСЬ"; fi
                        if [[ $TRY = 1 ]]; then ATTEMPT="ПОПЫТКА"; LAST="ОСТАЛАСЬ"; fi
                        echo 'SUBTITLE="НЕВЕРНЫЙ ПАРОЛЬ. '$LAST' '$TRY' '$ATTEMPT' !"; MESSAGE="Для подключения разделов EFI нужен пароль"' >> "${HOME}"/.MountEFInoty.sh
                            else
                        if [[ $TRY = 2 ]]; then ATTEMPT="ATTEMPTS"; fi
                        if [[ $TRY = 1 ]]; then ATTEMPT="ATTEMPT"; fi
                        echo 'SUBTITLE="INCORRECT PASSWORD. LEFT '$TRY' '$ATTEMPT' !"; MESSAGE="Password required to mount EFI partitions"' >> "${HOME}"/.MountEFInoty.sh
                            fi
                DISPLAY_NOTIFICATION
                fi
                fi
            done
    if [[ ! "$pressed_button" = "OK" ]]; then 
            mypassword="0"
        if (security find-generic-password -a ${USER} -s ${!efimounter} -w) >/dev/null 2>&1; then
                mypassword=$(security find-generic-password -a ${USER} -s ${!efimounter} -w); 
        fi
    fi
            if [[ "$mypassword" = "0" ]]; then
                SET_TITLE
                    if [[ $loc = "ru" ]]; then
                echo 'SUBTITLE="ПАРОЛЬ НЕ ПОЛУЧЕН !"; MESSAGE="Подключение разделов EFI недоступно"' >> "${HOME}"/.MountEFInoty.sh
                    else
                echo 'SUBTITLE="PASSWORD NOT KEEPED IN KEYCHAIN !"; MESSAGE="Mount EFI Partitions Unavailable"' >> "${HOME}"/.MountEFInoty.sh
                    fi
                DISPLAY_NOTIFICATION
                
        fi
    fi
fi
MOUNT_EFI_WINDOW_UP
}


MOUNT_EFI_WINDOW_UP(){ 
osascript -e 'tell application "Terminal" to set frontmost of (every window whose name contains "MountEFI")  to true'
osascript -e 'tell application "Terminal" to activate'
}

#Функция автомонтирования EFI по Volume UUID при запуске ####################################################################################

if $(echo "$MountEFIconf" | grep AutoMount -A 3 | grep -A 1 -e "Enabled</key>" | egrep -o "true|false"); then am_enabled=1

    ################ REM_ABSENT
    strng1=$(echo "$MountEFIconf" | grep AutoMount -A 9 | grep -A 1 -e "PartUUIDs</key>"  | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n')
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
						plutil -replace AutoMount.PartUUIDs -string "$strng2" "${CONFPATH}"
						strng1=$strng2
                        cache=0
						fi
					let "posb++"
					let "var8--"
					done
    alist=($strng1); apos=${#alist[@]}
    fi
    if [[ $apos = 0 ]]; then plutil -replace AutoMount.Enabled -bool NO "${CONFPATH}"; am_enabled=0; cache=0; fi
    ##############################################

    if [[ $cache = 0 ]]; then UPDATE_CACHE; fi

else am_enabled=0

fi

if [[ ! $am_enabled = 0 ]]; then 
    if [[ ! $apos = 0 ]]; then
        ENTER_PASSWORD

        if $(echo "$MountEFIconf" | grep AutoMount -A 7 | grep -A 1 -e "Open</key>" | egrep -o "true|false"); then autom_open=1; else autom_open=0; fi

        if $(echo "$MountEFIconf" | grep AutoMount -A 5 | grep -A 1 -e "ExitAfterMount</key>" | egrep -o "true|false"); then autom_exit=1; else autom_exit=0; fi

        var9=$apos
        posa=0
        while [[ ! $var9 = 0 ]]
        do
            if [[ "${flag}" = "0" ]]; then diskutil quiet mount ${alist[$posa]} >&- 2>&-

            else
      
                if [[ ! $mypassword = "0" ]]; then
                echo "${mypassword}" | sudo -S diskutil quiet mount ${alist[$posa]} >&- 2>&-
		               
                fi
	
            fi

            if  [[ $autom_open = 1 ]]; then 

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
if $(echo "$MountEFIconf" | grep -A 1 -e "OpenFinder</key>" | egrep -o "true|false"); then OpenFinder=1; else OpenFinder=0; fi
###########################################################################################################################################
# Определение функций кастомизации интерфейса #############################################
############################################################################################
# Colors for Apple Terminal
#
grep_apple_color(){ grep "$*" colors.csv ; }
get_apple_color(){ egrep "(^|,)$*(,|\t)" colors.csv | cut -f 6 ; }
set_foreground_color(){ color=$(get_apple_color $*); if [ "$color" != "" ] ; then osascript -e "tell application \"Terminal\" to set normal text color of window 1 to ${color}"; fi ; }    
set_background_color(){ color=$(get_apple_color $*); if [ "$color" != "" ] ; then osascript -e "tell application \"Terminal\" to set background color of window 1 to ${color}" ; fi ; }    
set_font(){ osascript -e "tell application \"Terminal\" to set the font name of window 1 to \"$1\"" ; osascript -e "tell application \"Terminal\" to set the font size of window 1 to $2" ; }
##################################################################################################################################################
######################################## получение принта загрузчиков из конфига #########################################################

GET_THEME_LOADERS(){
strng=$(echo "$MountEFIconf"  | grep -A 1 -e "<key>ThemeLoadersLinks</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' )
theme=`echo "$MountEFIconf"  |  grep -A 1 -e  "<key>Theme</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
if [[ "$theme" = "built-in" ]]; then current=$(echo "$MountEFIconf"  | grep -A 1 -e "<key>CurrentPreset</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'); NN="B,"
else
    current=$(echo "$MountEFIconf"  | grep -A 1 -e "<key>ThemeProfile</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'); NN="S,"; fi
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
pclov=${#Clover}; poc=${#OpenCore}; let "c_clov=(9-pclov)/2+46"; let "c_oc=(9-poc)/2+46"
}

SET_SYSTEM_THEME(){
profile=`echo "$MountEFIconf" |  grep -A 1 -e  "<key>ThemeProfile</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
if [[ "$profile" = "default" ]]; then
system_default=$(plutil -p /Users/$(whoami)/Library/Preferences/com.apple.Terminal.plist | grep "Default Window Settings" | tr -d '"' | cut -f2 -d '>' | xargs)
osascript -e 'tell application "Terminal" to  set current settings of window 1 to settings set "'"$system_default"'"'
else osascript -e 'tell application "Terminal" to  set current settings of window 1 to settings set "'"$profile"'"'
fi
}


CUSTOM_SET(){
######## GET_CURRENT_SET
current=`echo "$MountEFIconf"  | grep -A 1 -e "<key>CurrentPreset</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
current_background=`echo "$MountEFIconf"  | grep -A 10 -E "<key>$current</key>" | grep -A 1 "BackgroundColor" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
current_foreground=`echo "$MountEFIconf"  | grep -A 10 -E "<key>$current</key>" | grep -A 1 "TextColor" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
current_fontname=`echo "$MountEFIconf"  | grep -A 10 -E "<key>$current</key>" | grep -A 1 "FontName" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
current_fontsize=`echo "$MountEFIconf"  | grep -A 10 -E "<key>$current</key>" | grep -A 1 "FontSize" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
########################

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
if [[ $HasTheme = "Theme" ]]; then theme=`echo "$MountEFIconf"  |  grep -A 1 -e  "<key>Theme</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`; fi
}

parm="$1" ### параметр с которым вызывается MountEFI

GET_THEME_LOADERS

theme="system"
GET_THEME
if [[ $theme = "built-in" ]]; then CUSTOM_SET; else SET_SYSTEM_THEME; fi &

if [ "$parm" = "-help" ] || [ "$parm" = "-h" ]  || [ "$parm" = "-H" ]  || [ "$parm" = "-HELP" ]
then
    printf '\e[8;31;96t'
    clear && printf '\e[3J'
	if [ $loc = "ru" ]; then
    printf '\n\n************     Программа монтирует EFI разделы в Mac OS (X.11 - XI.2)     *************\n'

    printf '\n\n Эта программа предназначена для быстрого обнаружения и подключения разделов EFI / ESP\n'
    printf ' Программа различает версию операционной системы, и если потребуется запрашивает пароль\n'
    printf ' Поскольку в High Sierra и новее для подключения разделов требуются права администратора\n'
    printf ' Если пароль не требуется он не будет запрошен. Алгоритм работы программы следующий:\n'
    printf ' Обнаружив один раздел EFI программа сразу подключает его. Если разделов два или более,\n'
    printf ' когда в систему установлены несколько дисков с разметкой GUID, программа выведет запрос\n'
    printf ' чтобы пользователь мог выбрать какой раздел он хочет подключить.\n'
    printf ' Программа может иметь один аргумент командной строки.                                    \n\n'
    printf '    -h [ -help, -HELP, -H ]       выводит эту справочную информацию.                       \n'
    printf '    -m [ -M, -menue, -MENUE ]     форсирует показ меню даже для систем с одним разделом EFI.\n'
    printf '    -r [ -R, -reset, -RESET ]     удаляет пароль сохранённый в связке ключей.               \n'
    printf '    -d [ -D, -default, -DEFAULT ] программа стартует с файлом конфигурации по умолчанию.  \n\n'
    printf ' Программа поставляется как есть. Она может свободно копироваться, передаваться другим    \n'
    printf ' лицам и изменяться без ограничений. Вы используете её без каких либо гарантий, на своё   \n'
    printf ' усмотрение и под свою ответственность.                                                   \n\n'
    printf '\n Copyright © Андрей Антипов. (Gosvamih) Апрель 2020 г.\n\n\n\n'
    
			else

    printf '\n\n************     This program mounts EFI partitions on Mac OS (X.11 - XI.2)     *************\n'

    printf '\n\n This program is designed to quickly detect and mount EFI / ESP partitions\n'
    printf ' The program checks the version of the operating system, and if necessary, requests the password\n'
    printf ' Because High Sierra and newer require administrator privileges to mount partitions\n'
    printf ' If the password is not required, it will not be requested. \n'
    printf ' The algorithm of the program is as follows:\n'
    printf ' Having found one EFI partition, the program immediately connects it. If there are two or more\n'
    printf ' partitions, when multiple disks with GUIDs are installed in the system, the program will \n'
    printf ' prompt so that the user can choose which partition he wants to mount\n'
    printf ' The program can has one command line arguments.                                         \n\n'
    printf '    -h [ -help, -HELP, -H ]       Shows this help information.                              \n'
    printf '    -m [ -M, -menue, -MENUE ]     display the menu even for systems with one EFI partition. \n'
    printf '    -r [ -R, -reset, -RESET ]     removes the password stored in the keychain.              \n'
    printf '    -d [ -D, -default, -DEFAULT ] the program starts with the default configuration file. \n\n'
    printf ' prints this help information. The program is delivered as is.It can be freely copied,\n'
    printf ' transferred to other persons and changed without restrictions. You use it without any\n'
    printf ' either warranties from the developer, at your discretion and under your responsibility.\n\n'
    printf '\n Copyright © Andrew Antipov (Gosvamih) April 2020\n\n\n\n'
    
	fi
    exit 
fi

##### флаги и массивы #############################################################

declare -a nlist 
declare -a dlist
lists_updated=0
synchro=0
recheckLDs=0
old_oc_revision=()
GET_APP_ICON

GET_FLAG

ocHashes32string=$(echo "${MountEFIconf}" | grep -A3  "<key>YHashes</key>" | grep -A1 -o "<key>ocHashes32</key>" | grep string |  sed -e 's/.*>\(.*\)<.*/\1/' | tr ';' '\n')
ocHashes64string=$(echo "${MountEFIconf}" | grep -A5  "<key>YHashes</key>" | grep -A1 -o "<key>ocHashes64</key>" | grep string |  sed -e 's/.*>\(.*\)<.*/\1/' | tr ';' '\n')


# Блок определения функций ########################################################

#Получение пароля для sudo из связки ключей
GET_USER_PASSWORD(){
mypassword="0"
if (security find-generic-password -a ${USER} -s ${!efimounter} -w) >/dev/null 2>&1; then
                mypassword=$(security find-generic-password -a ${USER} -s ${!efimounter} -w)
fi
}

################################ получение имени диска для переименования #####################
GET_OC_VERS(){

oc_revision=""

GET_CONFIG_VERS "OpenCore"

oc_list[pnum]="${md5_loader}$( md5 -qq "$vname"/EFI/OC/OpenCore.efi 2>/dev/null )"

######  уточняем версию через хэши BOOTx64.efi + OpenCore.efi ######
if [[ ${oc_revision} = "" ]]; then
############################### уточняем версияю Open Core по OpenCore.efi ###################
############################### CORRECT_OC_VERS ##############################################
oc_revision=$(echo "${ocHashes64string}" | egrep -o "${oc_list[pnum]}=[\.0-9][\.0-9][\.0-9][\.0-9rd]\b" | cut -f2 -d=)
fi

if [[ ${oc_revision} = "" ]]; then
oc_revision=$(echo "${ocHashes32string}" | egrep -o "${md5_loader}=[\.0-9][\.0-9][\.0-9x][\.0-9rdx]\b" | cut -f2 -d=)
fi

}


GET_CONFIG_VERS(){
if [[ ! ${md5_loader} = "" ]]; then
    target=$1
    if [[ ${target} = "OpenCore" ]] || [[ ${target} = "ALL" ]]; then 

        if [[ ! ${#ocr_list[@]} = 0 ]]; then oc_revision=$( echo "${ocr_list[@]}" | egrep -o "${md5_loader}=[.0-9]{3}[rd]" | cut -f2 -d= ); fi
        if [[ ${oc_revision} = "" ]]; then 
        if [[ ! ${#ocd_list[@]} = 0 ]]; then oc_revision=$( echo "${ocd_list[@]}" | egrep -o "${md5_loader}=[.0-9]{3}[®ðn∂]" | cut -f2 -d= ); fi
        fi
    fi

    if [[ ${target} = "ALL" ]] && [[ ! ${oc_revision} = "" ]]; then loader="OpenCore"; loader+="${oc_revision}"

    else

        if [[ ${target} = "Clover" ]] || [[ ${target} = "ALL" ]]  ; then 

        revision=""
        if [[ ! ${#clv_list[@]} = 0 ]]; then revision=$( echo "${clv_list[@]}" | egrep -o "${md5_loader}=[0-9]{4}" | cut -f2 -d= ); fi


        if [[ ${target} = "ALL" ]] && [[ ! ${revision} = "" ]]; then loader="Clover"; loader+="${revision}"; fi

        fi
    fi
fi
}

GET_OTHER_LOADERS_STRING(){
if [[ ! ${#oth_list[@]} = 0 ]]; then for y in ${!oth_list[@]}; do if [[ "${oth_list[y]:0:32}" = "${md5_loader}" ]]; then loader="Other"; loader+="${oth_list[y]:33}"; break; fi ; done ; fi ; }

###############################################################################################

############################### получение хэшей из конфига ##########################################################

GET_CONFIG_HASHES(){
oth_list_string="$( echo "$MountEFIconf" | grep XHashes  -A 9 | grep -A 1 -e "OTHER_HASHES</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' )"
IFS=';'; oth_list=($oth_list_string)
         ocr_list=( $( echo "$MountEFIconf" | grep XHashes  -A 7 | grep -A 1 -e "OC_REL_HASHES</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n' ) )
         ocd_list=( $( echo "$MountEFIconf" | grep XHashes  -A 5 | grep -A 1 -e "OC_DEV_HASHES" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n' ) )   
         clv_list=( $( echo "$MountEFIconf" | grep XHashes  -A 3 | grep -A 1 -e "CLOVER_HASHES</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n' ) )
unset IFS
}

######################################################################################################################

PREMOUNT_DELETED(){ 
if [[ $mefisca = 1  && $(df | grep ${lddlist[i]}) = "" ]]; then 
    string=${lddlist[i]}; DO_MOUNT
    vname=$(df | egrep ${string} | sed 's#\(^/\)\(.*\)\(/Volumes.*\)#\1\3#' | cut -c 2-)
        if [[ ! "$vname" = "" ]]; then 
            md5_loader=$( md5 -qq "$vname"/EFI/BOOT/BOOTx64.efi )               
            if [[ ! ${md5_loader} = "" ]]; then loader=""; oc_revision=""; revision=""; GET_LOADER_STRING
                if [[ ! "${loader}" = "" ]]; then ldlist[i]="$loader"; fi
            fi
        fi
    diskutil quiet umount /dev/${string}
fi
}

CORRECT_LOADERS_HASH_LINKS(){
    GET_CONFIG_HASHES
    old_config_hashes=(); temp_lddlist=()

if [[ -f ~/.hashes_list.txt ]]; then old_config_hashes=( $( cat ~/.hashes_list.txt | tr '\n' ' ' ) ); fi
rm -f ~/.hashes_list.txt
if [[ ! ${#mounted_loaders_list[@]} = 0 ]]; then
    for i in ${!mounted_loaders_list[@]}; do
        if [[ ! ${mounted_loaders_list[i]} = 0 ]]; then
                loader=""; oc_revision=""; revision=""
                md5_loader=${mounted_loaders_list[i]}; GET_CONFIG_VERS "ALL"
                            if [[ ! "${loader}" = "" ]]; then ldlist[i]="$loader"
                                 elif [[ ! ${#old_config_hashes[@]} = 0 ]]; then
                                    for hh in ${old_config_hashes[@]}; do
                                        if [[ ${hh} = ${md5_loader} ]]; then
                                                PREMOUNT_DELETED
                                                if [[ "${loader}" = "" ]]; then
                                                unset mounted_loaders_list[i]; unset ldlist[i]; unset lddlist[i]; break
                                                fi
                                        fi
                                    done                  
                            fi
         fi
    done 
    old_other_loaders=(); deleted_other_loaders=()
    if [[ -f ~/.other_loaders_list.txt ]]; then old_other_loaders=( $( cat ~/.other_loaders_list.txt | tr '\n' ' ' ) ); fi; rm -f ~/.other_loaders_list.txt
     
        if [[ ! ${#old_other_loaders[@]} = 0 ]] ; then
                      for y in "${old_other_loaders[@]}"; do
                                match=0
                                    for z in "${oth_list[@]}"; do
                                        if [[ ${y:0:32} = ${z:0:32} ]]; then match=1; break; fi
                                    done
                                if [[ ${match} = 0 ]]; then deleted_other_loaders+=( ${y} ); fi
                      done
        fi

     if [[ ! ${#deleted_other_loaders[@]} = 0 ]] ; then
                for i in ${!mounted_loaders_list[@]}; do
                            md5_loader=${mounted_loaders_list[i]}
                            for y in ${!deleted_other_loaders[@]}; do
                               if [[ ${md5_loader} = ${deleted_other_loaders[y]:0:32} ]]; then 
                                    PREMOUNT_DELETED
                                    if [[ "${loader}" = "" ]]; then
                                    unset mounted_loaders_list[i]; unset ldlist[i]; unset lddlist[i]; break
                                    fi
                                fi
                            done
                done
    fi
     if [[ ! ${#oth_list[@]} = 0 ]] ; then 
        for i in ${!mounted_loaders_list[@]}; do
            if [[ ! ${mounted_loaders_list[i]} = 0 ]]; then
                md5_loader=${mounted_loaders_list[i]}
                for x in ${!oth_list[@]}; do
                    if [[ ${md5_loader} = ${oth_list[x]:0:32} ]]; then  
                                ldlist[i]="Other""${oth_list[x]:33}"; break
                    fi
                done
            fi
        done
    fi
fi
}

#### функция автообноления программы MountEFI
START_AUTOUPDATE(){
if [[ ! -f ~/Library/Application\ Support/MountEFI/AutoUpdateLock.txt ]]; then
 if ping -c 1 google.com >> /dev/null 2>&1; then
  if [[ ! -d ~/Library/Application\ Support/MountEFI ]]; then mkdir -p ~/Library/Application\ Support/MountEFI; fi
        echo $(date +%s) >> ~/Library/Application\ Support/MountEFI/AutoUpdateLock.txt
    if [[ -f ~/Library/Application\ Support/MountEFI/AutoUpdateInfoTime.txt ]]; then 
          if [[ "$(($(date +%s)-$(cat ~/Library/Application\ Support/MountEFI/AutoUpdateInfoTime.txt)))" -gt "86400" ]]; then
            autoupdate_string=$( cat ~/Library/Application\ Support/MountEFI/AutoupdatesInfo.txt | tr '\n' ';' ); IFS=';' autoupdate_list=(${autoupdate_string}); unset IFS
            rm -f ~/Library/Application\ Support/MountEFI/AutoUpdateInfoTime.txt; rm -f ~/Library/Application\ Support/MountEFI/AutoupdatesInfo.txt
            rm -f ~/Library/Application\ Support/MountEFI/${autoupdate_list[1]}".zip"
            if curl -s  https://github.com/Andrej-Antipov/MountEFI/raw/master/UpdatesLast/AutoupdatesInfo.txt -L -o ~/Library/Application\ Support/MountEFI/AutoupdatesInfo.txt ; then
                if [[ -f ~/Library/Application\ Support/MountEFI/AutoupdatesInfo.txt ]]; then date +%s >> ~/Library/Application\ Support/MountEFI/AutoUpdateInfoTime.txt; fi

            fi 2>/dev/null
          fi
    else
        if curl -s  https://github.com/Andrej-Antipov/MountEFI/raw/master/UpdatesLast/AutoupdatesInfo.txt -L -o ~/Library/Application\ Support/MountEFI/AutoupdatesInfo.txt ; then
                if [[ -f ~/Library/Application\ Support/MountEFI/AutoupdatesInfo.txt ]]; then date +%s >> ~/Library/Application\ Support/MountEFI/AutoUpdateInfoTime.txt; fi
        fi 2>/dev/null
    fi

  if [[ -f ~/Library/Application\ Support/MountEFI/AutoupdatesInfo.txt ]] && [[ -f ~/Library/Application\ Support/MountEFI/AutoUpdateInfoTime.txt ]]; then 
        current_vers=$(echo "$prog_vers" | tr -d "." ); vers_e=$(echo $edit_vers | bc)
        autoupdate_string=$( cat ~/Library/Application\ Support/MountEFI/AutoupdatesInfo.txt | tr '\n' ';' ); IFS=';' autoupdate_list=(${autoupdate_string}); unset IFS
        last_e=$(echo ${autoupdate_list[1]} | bc)
    if [[ $( echo "${autoupdate_list[0]}000+${last_e}" | bc) -gt $( echo "${current_vers}000+${vers_e}"  | bc) ]]; then
      if [[ ! -f ~/Library/Application\ Support/MountEFI/${autoupdate_list[1]}".zip" ]] || [[ ! $(md5 -qq ~/Library/Application\ Support/MountEFI/${autoupdate_list[1]}".zip") = ${autoupdate_list[2]} ]]; then
        if curl -s https://github.com/Andrej-Antipov/MountEFI/raw/master/UpdatesLast/${autoupdate_list[0]}/${autoupdate_list[1]}".zip" -L -o ~/Library/Application\ Support/MountEFI/${autoupdate_list[1]}".zip" ; then
           if [[ -f ~/Library/Application\ Support/MountEFI/${autoupdate_list[1]}".zip" ]]; then 
                if [[ $(md5 -qq ~/Library/Application\ Support/MountEFI/${autoupdate_list[1]}".zip") = ${autoupdate_list[2]} ]]; then 
                      if [[ ! -d ~/.MountEFIupdates ]]; then mkdir ~/.MountEFIupdates; else rm -Rf ~/.MountEFIupdates/*; fi 
                            unzip  -o -qq ~/Library/Application\ Support/MountEFI/${autoupdate_list[1]}".zip" -d ~/.MountEFIupdates 2>/dev/null
                            plutil -replace ReadyToAutoUpdate -bool Yes "${CONFPATH}"
                else
                    rm -f ~/Library/Application\ Support/MountEFI/${autoupdate_list[1]}".zip"
                fi
            fi
         fi 2>/dev/null
            else
               if [[ ! -d ~/.MountEFIupdates ]]; then mkdir ~/.MountEFIupdates; else rm -Rf ~/.MountEFIupdates/*; fi 
                   unzip  -o -qq ~/Library/Application\ Support/MountEFI/${autoupdate_list[1]}".zip" -d ~/.MountEFIupdates 2>/dev/null
                   plutil -replace ReadyToAutoUpdate -bool Yes "${CONFPATH}"
        fi
      fi
    fi

    MountEFIconf=$( cat "${CONFPATH}" )
    if [[ $(echo "$MountEFIconf"| grep -o "ReadyToAutoUpdate") = "ReadyToAutoUpdate" ]]; then
        if [[ -f ~/Library/Application\ Support/MountEFI/AutoupdatesInfo.txt ]]; then
            plutil -remove ReadyToAutoUpdate "${CONFPATH}"
            autoupdate_string=$( cat ~/Library/Application\ Support/MountEFI/AutoupdatesInfo.txt | tr '\n' ';' ); IFS=';' autoupdate_list=(${autoupdate_string}); unset IFS 
            
MEFI_PATH="${ROOT}""/MountEFI"

    echo '<?xml version="1.0" encoding="UTF-8"?>' >> "${HOME}"/.MountEFIu.plist
    echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' >> "${HOME}"/.MountEFIu.plist
    echo '<plist version="1.0">' >> "${HOME}"/.MountEFIu.plist
    echo '<dict>' >> "${HOME}"/.MountEFIu.plist
    echo '  <key>Label</key>' >> "${HOME}"/.MountEFIu.plist
    echo '  <string>MountEFIu.job</string>' >> "${HOME}"/.MountEFIu.plist
    echo '  <key>Nicer</key>' >> "${HOME}"/.MountEFIu.plist
    echo '  <integer>1</integer>' >> "${HOME}"/.MountEFIu.plist
    echo '  <key>ProgramArguments</key>' >> "${HOME}"/.MountEFIu.plist
    echo '  <array>' >> "${HOME}"/.MountEFIu.plist
    echo '      <string>/Users/'"$(whoami)"'/.MountEFIu.sh</string>' >> "${HOME}"/.MountEFIu.plist
    echo '  </array>' >> "${HOME}"/.MountEFIu.plist
    echo '  <key>RunAtLoad</key>' >> "${HOME}"/.MountEFIu.plist
    echo '  <true/>' >> "${HOME}"/.MountEFIu.plist
    echo '</dict>' >> "${HOME}"/.MountEFIu.plist
    echo '</plist>' >> "${HOME}"/.MountEFIu.plist

    echo '#!/bin/bash'  >> "${HOME}"/.MountEFIu.sh
    echo ''             >> "${HOME}"/.MountEFIu.sh
    echo 'sleep 1'             >> "${HOME}"/.MountEFIu.sh
    echo ''             >> "${HOME}"/.MountEFIu.sh
    echo 'touch ~/Library/Application\ Support/MountEFI/UpdateRestartLock.txt' >> "${HOME}"/.MountEFIu.sh
    echo 'latest_release=''"'$(echo ${autoupdate_list[0]})'"''' >> "${HOME}"/.MountEFIu.sh
    echo 'latest_edit=''"'$(echo ${autoupdate_list[1]})'"''' >> "${HOME}"/.MountEFIu.sh
    echo 'current_release=''"'$(echo ${prog_vers})'"''' >> "${HOME}"/.MountEFIu.sh
    echo 'current_edit=''"'$(echo ${edit_vers})'"''' >> "${HOME}"/.MountEFIu.sh
    echo 'vers="${latest_release:0:1}"".""${latest_release:1:1}"".""${latest_release:2:1}"".""${latest_edit}"' >> "${HOME}"/.MountEFIu.sh
    echo 'ProgPath=''"'$(echo "$MEFI_PATH")'"''' >> "${HOME}"/.MountEFIu.sh
    echo 'DirPath="$( echo "$ProgPath" | sed '"'s/[^/]*$//'"' | xargs)"'  >> "${HOME}"/.MountEFIu.sh
    echo 'if [[ -d "${DirPath}" ]]; then ' >> "${HOME}"/.MountEFIu.sh
    echo 'i=1200; while [[ ! $i = 0 ]]; do' >> "${HOME}"/.MountEFIu.sh
    echo 'if [[ ! $(ps -xa -o pid,command |  grep -v grep | grep -ow "MountEFI.app" | wc -l | bc) = 0 ]]; then' >> "${HOME}"/.MountEFIu.sh
    echo 'i=$((i-1)); sleep 0.25; else break; fi; done' >> "${HOME}"/.MountEFIu.sh
    echo 'rm -f "${DirPath}""version.txt"; echo ${current_release}";"${current_edit} >> "${DirPath}""version.txt"' >> "${HOME}"/.MountEFIu.sh
    echo 'mv -f ~/.MountEFIupdates/$latest_edit/MountEFI "${ProgPath}"' >> "${HOME}"/.MountEFIu.sh
    echo 'chmod +x "${ProgPath}"' >> "${HOME}"/.MountEFIu.sh
    echo 'if [[ -f ~/.MountEFIupdates/$latest_edit/setup ]]; then'             >> "${HOME}"/.MountEFIu.sh
    echo '        mv -f ~/.MountEFIupdates/$latest_edit/setup "${DirPath}setup"' >> "${HOME}"/.MountEFIu.sh
    echo '        chmod +x "${DirPath}setup"' >> "${HOME}"/.MountEFIu.sh
    echo '        mv -f ~/.MountEFIupdates/$latest_edit/document.wflow "${DirPath}""../document.wflow"' >> "${HOME}"/.MountEFIu.sh
    echo 'fi' >> "${HOME}"/.MountEFIu.sh
    echo 'if [[ -f "${DirPath}""/../Info.plist" ]]; then plutil -replace CFBundleShortVersionString -string "$vers" "${DirPath}""/../Info.plist"; fi' >> "${HOME}"/.MountEFIu.sh
    echo 'if [[ -d "${DirPath}""/../../../MountEFI.app" ]]; then touch "${DirPath}""/../../../MountEFI.app"; fi' >> "${HOME}"/.MountEFIu.sh
    echo 'sleep 1' >> "${HOME}"/.MountEFIu.sh
    echo ''  >> "${HOME}"/.MountEFIu.sh
    echo 'plutil -replace Updating -bool Yes ~/.MountEFIconf.plist' >> "${HOME}"/.MountEFIu.sh
    echo 'plutil -replace ReadyToAutoUpdate -bool Yes ~/.MountEFIconf.plist' >> "${HOME}"/.MountEFIu.sh
    echo 'fi' >> "${HOME}"/.MountEFIu.sh
    echo 'rm -f ~/Library/Application\ Support/MountEFI/UpdateRestartLock.txt' >> "${HOME}"/.MountEFIu.sh
    echo 'exit' >> "${HOME}"/.MountEFIu.sh
    chmod u+x "${HOME}"/.MountEFIu.sh

    if [[ -f "${HOME}"/.MountEFIu.plist ]]; then mv -f "${HOME}"/.MountEFIu.plist ~/Library/LaunchAgents/MountEFIu.plist; fi

if [[ ! $(launchctl list | grep "MountEFIu.job" | cut -f3 | grep -x "MountEFIu.job") ]]; then launchctl load -w ~/Library/LaunchAgents/MountEFIu.plist; fi
           
        fi     
    fi
  fi
    rm -f ~/Library/Application\ Support/MountEFI/AutoUpdateLock.txt
    TTYterm=$(ps); if [[ $( echo "$TTYterm" | egrep -o 'ttys[0-9]{1,3}' | wc -l |  bc ) = 0 ]]; then osascript -e 'quit app "terminal.app"'; fi 
fi
}

CHECK_MEFIScA(){
if [[ ! $(launchctl list | grep -o "MEFIScA.job") = "" ]] && [[ -f "${SERVFOLD_PATH}"/MEFIScA/MEFIScA.sh ]]; then
mefisca=1; old_dlist=(${dlist[@]}); old_mounted=(${mounted_loaders_list[@]}); old_ldlist=(${ldlist[@]}); old_lddlist=(${lddlist[@]})
else mefisca=0; fi
}

##################### Детект раскладки  и переключение на латиницу  ####################################################################################################

SET_INPUT(){

msg=$1

if [[ -f ~/Library/Preferences/com.apple.HIToolbox.plist ]]; then
    declare -a layouts_names
    layouts=$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleInputSourceHistory 2>/dev/null | egrep -w 'KeyboardLayout Name' | sed -E 's/.+ = "?([^"]+)"?;/\1/' | tr  '\n' ';') 
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

        if [[ ! $keyboard = "0" ]] && [[ -f "${ROOT}/xkbswitch" ]]; then "${ROOT}"/xkbswitch -se $keyboard
            elif [[ ! "${msg}" = "silent" ]]; then
            current_layout=$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources 2>/dev/null | egrep -w 'KeyboardLayout Name' | sed -E 's/.+ = "?([^"]+)"?;/\1/') 
            case "${current_layout}" in 
                 "ABC"                )  ;;
                 "US Extended"        )  ;;
                 "USInternational-PC" )  ;;
                 "U.S."               )  ;;
                 "British"            )  ;;
                 "British-PC"         )  ;;
                 "Russian"            )  ;;
                 "RussianWin"         )  ;;
                 "Russian - Phonetic" )  ;;
                 "Ukrainian-PC"       )  ;;
                 "Ukrainian"          )  ;;
                 "Byelorussian"       )  ;;
                 
                                     *) current_layout=""
                                         ;;
            esac 
            if [[ "${current_layout}" = "" ]]; then 
                
                if [[ $loc = "ru" ]]; then
                printf '\n\n                         ! Смените раскладку на латиницу !'
                else
                printf '\n\n                         ! Change layout to UTF-8 ABC, US or EN !'
                fi
                read -t 2 -n 2 -s
                printf '\r                                                                               \r'
                printf "\r\n\033[3A\033[46C" ; if [[ $order = 3 ]]; then printf "\033[3C"; fi
            fi
        fi
fi
}

##################################################################################################################################################################
######################################### Color Mode FUNC #####################################
GET_COLOR_MODE_PRESET(){
cm=()
if [[ ! $(echo "${MountEFIconf}" | grep -o "ColorModeData</key>") = "" ]]; then
    i=1
    while true; do if [[ $(echo "${MountEFIconf}" | grep -A$((i-1))  "ColorModeData</key>" | grep -ow "</dict>" ) = "" ]]; then let "i++"; else break; fi; done
    if [[ ! $(echo "${MountEFIconf}" | grep -A$((i-1)) -o "$presetName</key>") = "" ]]; then
        cm_string=$(echo "${MountEFIconf}" | grep -A$i "ColorModeData</key>" | grep -ow -A1 "$presetName</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/')
        IFS='+'; cm=($cm_string); unset IFS
    fi
fi
}

GET_COLOR_MODE_STRUCT(){ cm_ptr_string=$(echo "${MountEFIconf}" | grep -A1 "ColorModeStructure</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' 2>/dev/null); }

COLOR_MODE(){
#######################################################################################################################################################
################################################### блок установки модификации цветного вывода ######################################################
# cm        # список модификаторов цвета
# cm_ptr   # список указателей на элементы списка модификаторов cm
cm=(); cm_ptr=(); cm_string=""; cm_ptr_string=""

if [[ $theme = "built-in" ]]; then
current=`echo "$MountEFIconf"  | grep -A 1 -e "<key>CurrentPreset</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
else
current=$(echo "$MountEFIconf" |  grep -A 1 -e  "<key>ThemeProfile</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n')
fi

presetName="$current"; GET_COLOR_MODE_PRESET; if [[ "${cm_string}" = "" ]]; then presetName="Init180061Mode"; GET_COLOR_MODE_PRESET; fi

GET_COLOR_MODE_STRUCT

if [[ "${cm_ptr_string}" = "" ]]; then
cm_ptr_string="head_ast head_str head_os head_X head_sch head_upd_sch head_upd_sch_num head_upd_sch_br head_upd_sch_sp head_num_sch head_sch_br head_pls "\
"head_pls_str head_pls_qts head_sata head_usb dots_line1 dots_line2 dots_line3 num_sata num_sata_br num_usb num_usb_br mount_sata_pls mount_sata_dots "\
"mount_usb_pls mount_usb_dots dn_sata dn_usb dn_bsd_sata pn_size_sata pn_size_msata dn_bsd_usb pn_size_usb pn_size_musb sata_bsd sata_bsp usb_bsd usb_bsp "\
"rv0 kh_str curs_str curs_num_1 curs_num_2 ld_unrec ld_oc ld_cl ld_wn ld_rf ld_gb ld_oth cl_Q cl_P cl_U cl_E cl_A cl_S cl_I cl_V cl_C cl_O cl_L cl_W cl_M "\
"cl_E2 cl_ast cl_str cl_conf ld_srch ld_srch_sp ld_srch_bt rv1 rv2 rv3 clr dark"
plutil -replace ColorModeStructure -string "$cm_ptr_string" "${CONFPATH}"; UPDATE_CACHE
fi
cm_ptr=($cm_ptr_string); for i in ${!cm_ptr[@]}; do export ${cm_ptr[i]}=$i; done

if [[ "${cm[@]}" = "" ]]; then 
cm_string="\e[0m\e[2;38;5;15m+\e[0m\e[38;5;39m+\e[0m\e[32m+\e[0m\e[95m+\e[0m\e[37m+\e[0m\e[38;5;228m+\e[0m\e[38;5;39m+\e[0m\e[38;5;64m+"\
"\e[0m\e[38;5;228m+\e[0m\e[38;5;39m+\e[0m\e[37m+\e[0m+\e[0m\e[37m+\e[0m\e[2;36m+\e[0m\e[38;5;228m+\e[38;5;116m+\e[0m\e[37m+"\
"\e[0m\e[37m+\e[0m\e[37m+\e[0m\e[93m+\e[0m\e[93m+\e[0m\e[96m+\e[0m\e[96m+\e[0m\e[38;5;15m+\e[0m\e[33m+\e[0m\e[38;5;15m+"\
"\e[0m\e[38;5;8m+\e[0m\e[38;5;227m+\e[0m\e[38;5;44m+\e[0m\e[38;5;11m+\e[0m\e[38;5;227m+\e[0m\e[93m+\e[0m\e[38;5;14m+\e[0m\e[38;5;44m+"\
"\e[0m\e[96m+\e[0m\e[38;5;227m+\e[0m\e[38;5;227m+\e[0m\e[38;5;44m+\e[0m\e[38;5;44m+\e[0m+\e[0m\e[37m+\e[0m\e[37m+\e[0m\e[1;38;5;44m+"\
"\e[0m\e[1;93m+\e[0m\e[31m+\e[0m\e[38;5;159m+\e[0m\e[38;5;10m+\e[0m\e[1;38;5;31m+\e[0m\e[38;5;167m+\e[0m\e[1;38;5;184m+\e[0m\e[95m+"\
"\e[0m\e[95m+\e[0m\e[38;5;9m+\e[0m\e[1;36m+\e[0m\e[1;93m+\e[0m\e[1;31m+\e[0m\e[1;95m+\e[0m\e[1;92m+\e[0m\e[1;32m+\e[0m\e[1;92m+"\
"\e[0m\e[1;96m+\e[0m\e[1;33m+\e[0m\e[38;5;11m+\e[0m\e[1;92m+\e[0m\e[38;5;88m+\e[0m\e[33m+\e[0m\e[36m+\e[0m\e[95m+\e[0m\e[38;5;7m+"\
"\e[0m\e[38;5;7m+\e[0m\e[38;5;28m+\e[0m+\e[0m+\e[0m+\e[0m+0"
IFS='+'; cm=($cm_string); unset IFS
if [[ $(echo "${MountEFIconf}" | grep -o "ColorModeData</key>") = "" ]]; then plutil -replace ColorModeData -xml  '<dict/>'   "${CONFPATH}"; fi
plutil -replace ColorModeData."$presetName" -string "$cm_string" "${CONFPATH}"; UPDATE_CACHE
fi

if [[ "$presetName" = "Init180061Mode" ]]; then
current_background="{4064, 8941, 17101}"; current_foreground="{65535, 65535, 65535}"; current_fontname="SF Mono Regular"; current_fontsize="11"
osascript -e "tell application \"Terminal\" to set background color of window 1 to $current_background" \
-e "tell application \"Terminal\" to set normal text color of window 1 to $current_foreground" \
-e "tell application \"Terminal\" to set the font name of window 1 to \"$current_fontname\"" \
-e "tell application \"Terminal\" to set the font size of window 1 to $current_fontsize"
fi
###########################################################################################################################################################
}

CHECK_CM(){ if $(cat "${CONFPATH}" | grep -A1 "GUIcolorMode</key>" | egrep -o "false|true"); then cm_check=1; COLOR_MODE
else cm_check=0; fi }; 
############## обновление даных после выхода из скрипта настроек #########################################################

REFRESH_SETUP(){
DEBUG=$(cat "${CONFPATH}" | grep -A1 "DEBUG</key>" | egrep -o "false|true"); if [[ $DEBUG = "" ]]; then DEBUG="false"; fi
CHECK_MEFIScA
UPDATE_CACHE
ocHashes32string=$(echo "${MountEFIconf}" | grep -A3  "<key>YHashes</key>" | grep -A1 -o "<key>ocHashes32</key>" | grep string |  sed -e 's/.*>\(.*\)<.*/\1/' | tr ';' '\n')
ocHashes64string=$(echo "${MountEFIconf}" | grep -A5  "<key>YHashes</key>" | grep -A1 -o "<key>ocHashes64</key>" | grep string |  sed -e 's/.*>\(.*\)<.*/\1/' | tr ';' '\n')
GET_LOCALE
strng=`echo "$MountEFIconf" | grep -A 1 -e "OpenFinder</key>" | grep false | tr -d "<>/"'\n\t'`
if [[ $strng = "false" ]]; then OpenFinder=0; else OpenFinder=1; fi
GET_USER_PASSWORD
GET_THEME
CHECK_CM
GET_THEME_LOADERS
GET_LOADERS
if [[ ${CheckLoaders} = 0 ]]; then mounted_loaders_list=(); ldlist=(); lddlist=(); oc_list=(); elif [[ $(launchctl list | grep -o "MountEFIr.job") = "" ]]; then GET_MOUNTEFI_STACK; fi
rm -f ~/.other_loaders_list.txt
#if [[ $(echo "$MountEFIconf"| grep -o "Restart") = "Restart" ]]; then SAVE_LOADERS_STACK; fi
CHECK_AUTOUPDATE
if [[ ${AutoUpdate} = 1 ]] && [[ -f ../../../MountEFI.app/Contents/Info.plist ]] && [[ ! -f /Library/Application\ Support/MountEFI/AutoUpdateInfoTime.txt ]] && [[ ! -f ~/Library/Application\ Support/MountEFI/AutoUpdateLock.txt ]]; then 
                    START_AUTOUPDATE &
fi 
MOUNT_EFI_WINDOW_UP &
SET_INPUT
}
##########################################################################################################################

MountEFI_count=$(ps -xa -o tty,pid,command|  grep "/bin/bash"  |  grep -v grep  | rev | cut -f1 -d '/' | rev | grep MountEFI | wc -l)
setup_count=$(ps -o pid,command  |  grep  "/bin/bash" |  grep -v grep | rev | cut -f1 -d '/' | rev | grep setup | sort -u | wc -l | xargs)
# Возвращает в переменной TTYcount 0 если наш терминал один

if [ "${setup_count}" -gt "0" ]; then  spid=$(ps -o pid,command  |  grep  "/bin/bash" |  grep -v grep| grep setup | xargs | cut -f1 -d " "); kill ${spid}; fi
if [ ${MountEFI_count} -gt 3 ]; then  osascript -e 'tell application "Terminal" to activate';  EXIT_PROGRAM; fi

################ восстановить состояние после перезагрузки из схранения в файлах ##################################################

GET_MOUNTEFI_STACK(){
DBG "CLIENT: GET_MOUNT_EFI_STACK"
if [[ -d ~/.MountEFIst ]]; then
#DBG "CLIENT: FOLDER PRESENT"
IFS=';'; mounted_loaders_list=( $(cat "${HOME}"/.MountEFIst/.mounted_loaders_list 2>/dev/null | tr '\n' ';' ) )
ldlist=( $(cat "${HOME}"/.MountEFIst/.ldlist 2>/dev/null | tr '\n' ';' ) )
#DBG "CLIENT: ldlist = $(for i in ${ldlist[@]}; do printf "$i "; done)"
lddlist=( $(cat "${HOME}"/.MountEFIst/.lddlist 2>/dev/null | tr '\n' ';' ) )
#DBG "CLIENT: lddlist = $(for i in ${lddlist[@]}; do printf "$i "; done)"
oc_list=( $(cat "${HOME}"/.MountEFIst/.oc_list 2>/dev/null | tr '\n' ';' ) ); unset IFS
#DBG "CLIENT oc_list got .MountEFIst = $(for i in ${!oc_list[@]}; do printf "$i) ${oc_list[i]} "; done)"
#DBG "CLIENT: dlist = $(for i in ${dlist[@]}; do printf "$i "; done)"
CORRECT_LOADERS_HASH_LINKS
fi

rm -Rf ~/.MountEFIst

if [[ -f ~/.hashes_list.txt.back ]]; then mv -f ~/.hashes_list.txt.back ~/.hashes_list.txt; fi
if [[ -f ~/.other_loaders_list.txt.back ]]; then mv -f ~/.other_loaders_list.txt.back ~/.other_loaders_list.txt; fi
if [[ -f ~/.disk_list.txt.back ]]; then mv -f ~/.disk_list.txt.back ~/.disk_list.txt; fi

}
######################## сохранение данных для перезагрузки ###################################################################
############################################# сохранене данных для коррекции после setup ##########################################
SAVE_EFIes_STATE(){
OldAutoUpdate=${AutoUpdate}
if [[ ! $CheckLoaders = 0 ]]; then
    rm -f ~/.disk_list.txt; touch ~/.disk_list.txt; echo ${dlist[@]} >> ~/.disk_list.txt
    rm -f ~/.hashes_list.txt; touch ~/.hashes_list.txt
        if [[ ! ${#lddlist[@]} = 0 ]]; then
        for h in ${!lddlist[@]}; do 
            if [[ ! ${mounted_loaders_list[h]} = 0 ]]; then
                loader=""; oc_revision=""; revision=""
                md5_loader=${mounted_loaders_list[h]}; GET_CONFIG_VERS "ALL"                            
                            if [[ ! ${loader} = "" ]]; then
                            echo "${mounted_loaders_list[h]}" >> ~/.hashes_list.txt
                            fi
            fi
        done
        fi
    rm -f ~/.other_loaders_list.txt
    if [[ ! ${#oth_list[@]} = 0 ]]; then
        touch ~/.other_loaders_list.txt
        for h in "${oth_list[@]}"; do echo "${h}" >> ~/.other_loaders_list.txt; done
    fi

    SAVE_LOADERS_STACK
fi
}
###################################################################################################################################
GET_DATA_STACK(){
#i=8; while [[ -f "${SERVFOLD_PATH}"/MEFIScA/WaitSynchro ]]; do sleep 0.25; let "i--"; if [[ $i = 0 ]]; then break; fi; done
DBG "CLIENT START data get"#" waited $((8-i)) cycle of 8"
IFS=';'; mounted_loaders_list=( $(cat "${SERVFOLD_PATH}"/MEFIScA/MEFIscanAgentStack/mounted_loaders_list 2>/dev/null | tr '\n' ';' ) )
ldlist=( $(cat "${SERVFOLD_PATH}"/MEFIScA/MEFIscanAgentStack/ldlist 2>/dev/null | tr '\n' ';' ) )
lddlist=( $(cat "${SERVFOLD_PATH}"/MEFIScA/MEFIscanAgentStack/lddlist 2>/dev/null | tr '\n' ';' ) )
oc_list=( $(cat "${SERVFOLD_PATH}"/MEFIScA/MEFIscanAgentStack/oc_list 2>/dev/null | tr '\n' ';' ) )
#DBG "CLIENT oc_list got = $(for i in ${!oc_list[@]}; do printf "$i) ${oc_list[i]} "; done)"
if [[ -f "${SERVFOLD_PATH}"/MEFIScA/MEFIscanAgentStack/dlist ]]; then dlist=( $(cat "${SERVFOLD_PATH}"/MEFIScA/MEFIscanAgentStack/dlist 2>/dev/null | tr '\n' ';' ) ); fi;  unset IFS
DBG "Client STOP data get"
CORRECT_LOADERS_HASH_LINKS
rm -f "${SERVFOLD_PATH}"/MEFIScA/ServerGetReady "${SERVFOLD_PATH}"/MEFIScA/clientReady
#DBG " CLIENT Remove ServerGetReady" ; DBG " CLIENT Remove сlientReady"
}


MSG_SERV_READY_ERR(){
if [[ $loc = "ru" ]]; then
MESSAGE='"Поисковый агент не ответил. !\nПринудительный перезапуск .... !"'
else
MESSAGE='"Searching agent not answer. !\nRelaunching forced .... !"'
fi
DISPLAY_MESSAGE1 >>/dev/null 2>/dev/null
}

MSG_WARN_SERV_READY(){
if [[ $loc = "ru" ]]; then
MESSAGE='"Ожидаем ответ от поискового агента .... !"'
else
MESSAGE='"Wait for loader searching agent answer  .... !"'
fi
DISPLAY_MESSAGE >>/dev/null 2>/dev/null
}

GET_MEFIScA_DATA(){
     mfupd=0
     if [[ $mrel = 0 ]]; then
        i=96; while [[ ! -f "${SERVFOLD_PATH}"/MEFIScA/ServerGetReady ]]; do sleep 0.125; let "i--"; 
        if [[ $i = 80 ]]; then MSG_WARN_SERV_READY &
        fi
        if [[ $i -lt 1 ]]; then break; fi; done
        DBG "CLIENT waiting ServerGetReady was $((96-i)) cycles"
        if [[ $i = 0 ]]; then KILL_DIALOG; MSG_SERV_READY_ERR; touch "${SERVFOLD_PATH}"/MEFIScA/reloadFlag; POSTCONTROL_RELAUNCH_MEFIScA; fi
        i=240; while [[ -f "${SERVFOLD_PATH}"/MEFIScA/WaitSynchro ]]; do sleep 0.125; let "i--"; if [[ $i = 228 ]]; then MSG_WAIT &
        fi; if [[ $i = 0 ]]; then break; fi; done; KILL_DIALOG; if [[ $i = 0 ]]; then MSG_TIMEOUT; rm -f "${SERVFOLD_PATH}"/MEFIScA/WaitSynchro; fi
        DBG "CLIENT waiting WaitSychro gone off was $((240-i)) cycles"
     else
        mrel=0; i=""
     fi   
        if [[ ! $i = 0 ]]; then GET_DATA_STACK; fi
}

STARTUP_FIND_LOADERS(){
if $(echo "$MountEFIconf" | grep -A 1 -e "startupMount</key>" | egrep -o "false|true") && [[ ! $CheckLoaders = 0 ]]; then
  if [[ ! $mefisca = 1 ]]; then
    if [[ ! $flag = 0 ]]; then NEED_PASSWORD; fi
    if  [[ "$(sysctl -n kern.safeboot)" = "1" ]]; then ENTER_PASSWORD; IF_UNLOCK_SAFE_MODE; fi
    if [[ ! $mypassword = "0"  &&  ! $mypassword = "" ]] || [[ $flag = 0 ]]; then
    for i in ${!dlist[@]}; do 
    pnum=${nlist[i]}; 
        string=${dlist[$pnum]}

        if [[ $(df | grep ${string}) = "" ]]; then 
        
            if [[ $flag = 0 ]]; then diskutil quiet mount readOnly  /dev/${string} 2>/dev/null
            elif ! sudo diskutil quiet mount readOnly  /dev/${string} 2>/dev/null; then 
            sleep 0.5
            sudo diskutil quiet mount readOnly  /dev/${string} 2>/dev/null
            fi
            if [[ ! $(df | grep ${string}) = "" ]]; then mcheck="Yes"
            
            FIND_LOADERS

            if [[ ! ${loader} = "" ]];then ldlist[pnum]="${loader}"; lddlist[pnum]=${dlist[pnum]}; fi
            diskutil quiet  umount  force /dev/${string}
            fi
        fi   
    done
    fi
  else
#     DBG "CLIENT +++++ check if GET_DATA rst=$rst, upd=$upd, no_ret=$no_ret"
     if [[ $rst = 0 ]] || ([[ $rst = 1 && $mfupd = 1 && $no_ret = 1 ]]); then GET_MEFIScA_DATA; fi    
  fi
#DBG "CLIENT oc_list after start find loaders = $(for i in ${!oc_list[@]}; do printf "$i) ${oc_list[i]} "; done)"      
fi
MOUNT_EFI_WINDOW_UP &
}

MEFIScA_DATA(){
if [[ $mefisca = 1 ]]; then 
    if [[ ${old_dlist[@]} = ${dlist[@]} ]] && [[ ${old_mounted[@]} = ${mounted_loaders_list[@]} ]] && [[ ${old_ldlist[@]} = ${ldlist[@]} ]] && [[ ${old_lddlist[@]} = ${lddlist[@]} ]]; then
    true
    else
            if [[ ! -d "${SERVFOLD_PATH}"/MEFIScA/MEFIscanAgentStack ]]; then mkdir -p "${SERVFOLD_PATH}"/MEFIScA/MEFIscanAgentStack; else rm -Rf "${SERVFOLD_PATH}"/MEFIScA/MEFIscanAgentStack/*; fi
            pushd "${SERVFOLD_PATH}"/MEFIScA/MEFIscanAgentStack >/dev/null 2>/dev/null
            touch dlist
            if [[ ! ${#dlist[@]} = 0 ]]; then max=0; for y in ${!dlist[@]}; do if [[ ${max} -lt ${y} ]]; then max=${y}; fi; done; for ((h=0;h<=max;h++)); do echo "${dlist[h]}" >> dlist; done; fi
            touch mounted_loaders_list
            if [[ ! ${#mounted_loaders_list[@]} = 0 ]]; then max=0; for y in ${!mounted_loaders_list[@]}; do if [[ ${max} -lt ${y} ]]; then max=${y}; fi; done; for ((h=0;h<=max;h++)); do echo ${mounted_loaders_list[h]} >> mounted_loaders_list; done; fi
            touch ldlist
            if [[ ! ${#ldlist[@]} = 0 ]]; then max=0; for y in ${!ldlist[@]}; do if [[ ${max} -lt ${y} ]]; then max=${y}; fi; done; for ((h=0;h<=max;h++)); do echo "${ldlist[h]}" >> ldlist; done; fi
            touch lddlist
            if [[ ! ${#lddlist[@]} = 0 ]]; then max=0; for y in ${!lddlist[@]}; do if [[ ${max} -lt ${y} ]]; then max=${y}; fi; done; for ((h=0;h<=max;h++)); do echo ${lddlist[h]} >> lddlist; done; fi
            touch oc_list
            if [[ ! ${#oc_list[@]} = 0 ]]; then max=0; for y in ${!oc_list[@]}; do if [[ ${max} -lt ${y} ]]; then max=${y}; fi; done; for ((h=0;h<=max;h++)); do echo ${oc_list[h]} >> oc_list; done; fi
            popd >/dev/null 2>/dev/null
            old_dlist=(${dlist[@]}); old_mounted=(${mounted_loaders_list[@]}); old_ldlist=(${ldlist[@]}); old_lddlist=(${lddlist[@]})
    fi
fi
}
############################### обработка условия после перезагрузки ###############################################################
mrel=0
if [ "$par" = "-s" ]; then par=""; mrel=1; cd "$(dirname "$0")"; upd=1; if [[ -f setup ]]; then ./setup -r "${ROOT}"; else bash ./setup.sh -r "${ROOT}"; fi;  REFRESH_SETUP; order=4; fi; CHECK_RELOAD; if [[ $rel = 1 ]]; then EXIT_PROGRAM; fi
if [[ $mrel = 0 ]]; then 
########################## проверка и запуск цветного режима ################################
CHECK_CM
fi
##########################################################################################################################
#DBG "Quit from Setup upd = $upd, rel = $rel, par = $par; rst = $rst"
####### Выход по опции авто-монтирования c проверкой таймаута    ####################################################
if [[ $am_enabled = 1 ]] && [[  ! $apos = 0 ]] && [[ $autom_exit = 1 ]]; then 
        ########################## обратный отсчёт для автомонтирования ##########################################################
        COUNTDOWN(){ 
        printf '\n\n\n'
        local t=$1 remaining=$1;
        SECONDS=0; demo="±"
        while sleep .01; do
                if [[ $loc = "ru" ]]; then
            printf '\rНажмите любую клавишу для прерывания. Автовыход через: '"$remaining"' '
                    else
            printf '\rPress any key to stop the countdown. Exit timeout: '"$remaining"' '
                fi
            read -t 1 -n1 demo
                if [[ ! $demo = "±" ]]; then  break; fi
            if (( (remaining=t-SECONDS) <=0 )); then
                if [[ $loc = "ru" ]]; then
            printf '\rНажмите любую клавишу для прерывания. Автовыход через: '"$remaining"' '
                    else
            printf '\rPress any key to stop the countdown. Exit timeout: '"$remaining"' '
                fi
                break;
            fi;
        done
        }
        #############################################################################################################################

        auto_timeout=0
        strng=`echo "$MountEFIconf" | grep AutoMount -A 11 | grep -A 1 -e "Timeout2Exit</key>"  | grep integer | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
        if [[ ! $strng = "" ]]; then auto_timeout=$strng; fi
    if [[ $auto_timeout = 0 ]]; then EXIT_PROGRAM
                else
              MOUNT_EFI_WINDOW_UP
              COUNTDOWN $auto_timeout
            if [[ $demo = "±" ]]; then  EXIT_PROGRAM
        fi
    fi
fi

######################################################################################################################
SET_INPUT "silent"
############################################ очистка истории bash при запуске ##################################################
CLEAR_HISTORY &
################################################################################################################################

################################## функция автодетекта подключения ##############################################################################################
CHECK_HOTPLUG_PARTS(){
pstring=`df | cut -f1 -d " " | grep "/dev" | cut -f3 -d "/"` ; puid_list=($pstring);  puid_count=${#puid_list[@]}
        if [[ ! $old_puid_count = $puid_count ]]; then
                
               if [[  $old_puid_count -lt $puid_count ]]; then                        
                    ioreg_iomedia=`ioreg -c IOMedia -r | tr -d '"|+{}\t'`
                    disk_images=`echo "$ioreg_iomedia" | egrep -A 22 "Apple " | grep "BSD Name" | cut -f2 -d "="  | tr -d " " | tr '\n' ';'`
                    IFS=';'; ilist=($disk_images); unset IFS; posi=${#ilist[@]}
                    if [[ ${synchro} = 0 ]]; then synchro=2; fi
               fi
                    
                    diff_list=()
                    IFS=';'; diff_list=(`echo ${puid_list[@]} ${old_puid_list[@]} | tr ' ' '\n' | sort | uniq -u | tr '\n' ';'`); unset IFS; posdi=${#diff_list[@]}
                    if [[ ${synchro} = 2 ]]; then latest_hotplugs_parts=( ${diff_list[@]} ); fi
                    if [[ ! $posi = 0 ]] && [[ ! $posdi = 0 ]]; then 
                            
                        for (( i=0; i<$posdi; i++ )); do
                            match=0
                            dfdstring=`echo ${diff_list[$i]} | rev | cut -f2-3 -d"s" | rev`
                                
                                for (( n=0; n<=$posi; n++ )); do
                                     if [[ "$dfdstring" = "${ilist[$n]}" ]]; then match=1;  break; fi
                                
                        done
                                     
                                     if [[ ! $match = 1 ]]; then  UPDATE_SCREEN; fi
                        done

                        else
                                     UPDATE_SCREEN

                    fi
            
           old_puid_count=$puid_count; old_puid_list=($pstring)
            
        fi
}

CHECK_HOTPLUG_DISKS(){
 
                       RECHECK_LOADERS 

hotplug=0
ustring=`ioreg -c IOMedia -r  | tr -d '"|+{}\t'  | grep -A 10 -B 5  "Whole = Yes" | grep "BSD Name" | grep -oE '[^ ]+$' | xargs | tr ' ' ';'` ; IFS=";"; uuid_list=($ustring); unset IFS; uuid_count=${#uuid_list[@]};
        if [[ ! $old_uuid_count = $uuid_count ]]; then
            if [[  $old_uuid_count -lt $uuid_count ]]; then 
                synchro=1
               ioreg_iomedia=`ioreg -c IOMedia -r | tr -d '"|+{}\t'`
                    disk_images=`echo "$ioreg_iomedia" | egrep -A 22 "Apple " | grep "BSD Name" | cut -f2 -d "="  | tr -d " " | tr '\n' ';'`
                    IFS=';'; ilist=($disk_images); unset IFS; posi=${#ilist[@]}
                else
                    synchro=3
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
###################### движок детекта EFI разделов ####################################################
GET_EFI_S(){
ioreg_iomedia=$( ioreg -c IOMedia -r | tr -d '"|+{}\t' )
usb_iomedia=$( IOreg -c IOBlockStorageServices -r | grep "Device Characteristics" | tr -d '|{}"' | sed s'/Device Characteristics =//' | rev | cut -f2-3 -d, | rev | tr '\n' ';'  | xargs )
drives_iomedia=$( echo "$ioreg_iomedia" |  egrep -A 22 "<class IOMedia," )
string=$( diskutil list | grep EFI | grep -oE '[^ ]+$' | xargs | tr ' ' ';' )
disk_images=$( echo "$ioreg_iomedia" | egrep -A 22 "Apple " | grep "BSD Name" | cut -f2 -d "="  | tr -d " " | tr '\n' ';' )
syspart=$( df / | grep /dev | cut -f1 -d " " | sed s'/dev//' | tr -d '/ \n' )
IFS=';'; dlist=($string); ilist=($disk_images); usb_iolist=($usb_iomedia); unset IFS; pos=${#dlist[@]}; posi=${#ilist[@]}; pusb=${#usb_iolist[@]}

# exclude disk images
if [[ ! $posi = 0 ]]; then
tmlist=()
for ((i=0;i<$pos;i++)); do 
        match=0
        for ((n=0;n<$posi;n++)); do
             if [[ $( echo ${dlist[i]} | rev | cut -f2-3 -d"s" | rev ) = ${ilist[n]} ]]; then match=1; break; fi
        done
            if [[ $match = 0 ]]; then tmlist+=( ${dlist[i]} ); fi
done
if [[ ! ${#tmlist[@]} = 0 ]]; then dlist=( ${tmlist[@]} ); pos=${#dlist[@]}; fi
fi

# make list of disks
dmlist=(); for (( i=0; i<$pos; i++ )) do dmlist+=( $( echo ${dlist[i]} | rev | cut -f2-3 -d"s" | rev ) ); done
dmlist=( $(echo "${dmlist[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ') ); posd=${#dmlist[@]}

# get list of usb drives
past_rmlist=( ${rmlist[@]} ); rmlist=(); posrm=0
if [[ ! $pusb = 0 ]]; then

usbnames=(); for (( i=0; i<$pusb; i++ )); do usbname="$(echo ${usb_iolist[i]} | cut -f3 -d=)"; usbnames+=( "${usbname}" ); done

for (( i=0; i<$posd; i++ ))
 do
    dmname=$( echo "$drives_iomedia" | grep -B 10 ${dmlist[i]} | grep -m 1 -w "IOMedia"  | cut -f1 -d "<" | sed -e s'/-o //'  | sed -e s'/Media//' | sed 's/ *$//' | tr -d "\n")
    if [[ ${#dmname} -gt 30 ]]; then dmname=$( echo "$dmname" | cut -f1-2 -d " " ); fi
        for (( n=0; n<$pusb; n++ )); do if [[ ! $( echo "$dmname" | grep -oE "${usbnames[n]}" ) = ""  ]]; then rmlist+=( ${dmlist[i]} ); fi; done
 done                            
fi

posrm=${#rmlist[@]}

if [[ $posrm = 0 ]]; then usb=0; else usb=1; fi

# подготовка данных для вычисления размеров
sizes_iomedia=$( echo "$ioreg_iomedia" |  sed -e s'/Logical Block Size =//' | sed -e s'/Physical Block Size =//' | sed -e s'/Preferred Block Size =//' | sed -e s'/EncryptionBlockSize =//')

}
############################## USB ##############################
CHECK_USB(){ if [[ ! $posrm = 0 ]]; then usb=0; for (( i=0; i<=$posrm; i++ )); do if [[ "${dstring}" = "${rmlist[$i]}" ]]; then usb=1; break; fi; done ; fi ; }
##################################################################

GETARR(){

GET_EFI_S

if [[ ! $pos = 0 ]]; then 
		var0=$pos; num=0; dnum=0; unset nlist; unset rnlist
	while [[ ! $var0 = 0 ]] 
		do
		string=$( echo ${dlist[$num]} )
    if [[ $string = $syspart ]]; then unset dlist[$num]; let "pos--"
            else
		dstring=$( echo $string | rev | cut -f2-3 -d"s" | rev )
		dlenth=$( echo ${#dstring} )

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

######## GET_SKEYS
ShowKeys=1
strng=`echo "$MountEFIconf"  | grep -A 1 -e "ShowKeys</key>" | grep false | tr -d "<>/"'\n\t'`
if [[ $strng = "false" ]]; then ShowKeys=0; fi
##################

if [[ $ShowKeys = 1 ]]; then lines=25; else lines=22; fi
let "lines=lines+pos"
for (( n=0; n<$pos; n++ )); do
    pnum=${nlist[$n]}
	string=`echo ${dlist[$pnum]}`
	dstring=`echo $string | rev | cut -f2-3 -d"s" | rev`
    CHECK_USB
    if [[ $usb = 1 ]]; then break; fi
done
if [[ ! $usb = 0 ]]; then let "lines=lines+3"; fi
lists_updated=1
fi
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

############################################ конец движка детекта EFI ###############################################

MOUNTED_CHECK(){

 mcheck=`df | grep ${string}`; if [[ ! $mcheck = "" ]]; then mcheck="Yes"; fi
	if [[ ! $mcheck = "Yes" ]]; then

    SET_TITLE
    if [[ $loc = "ru" ]]; then
    echo 'SUBTITLE="НЕ УДАЛОСЬ ПОДКЛЮЧИТЬ РАЗДЕЛ EFI !"; MESSAGE="Ошибка подключения '${string}'"' >> "${HOME}"/.MountEFInoty.sh
    else
    echo 'SUBTITLE="FAILED TO MOUNT EFI PARTITION !"; MESSAGE="Error mounting '${string}'"' >> "${HOME}"/.MountEFInoty.sh
    fi
    DISPLAY_NOTIFICATION 

    fi
}

CHECK_PASSWORD(){
need_password=0
if ! echo "${mypassword}" | sudo -S printf "" 2>/dev/null; then
       printf '\033[1A\r\033[48C''                                \r\033[48C'          
       if [[ $password_was_entered = "0" ]]; then ENTER_PASSWORD "force"; password_was_entered=1;  fi
       if ! echo "${mypassword}" | sudo -S printf "" 2>/dev/null; then
            printf '\033[1A\r\033[48C''                                \r\033[48C'
            need_password=1
       fi
fi
}

############### разблокировать раздел EFI в Safe Mode ##########################################

IF_UNLOCK_SAFE_MODE(){
if [[ "$(sysctl -n kern.safeboot)" = "1" ]]; then 
    if [[ $(kextstat -l | grep -ow com.apple.filesystems.msdosfs) = "" ]]; then 
        if [[ ! "${mypassword}" = "" ]]; then
             if [[ ! -d ~/Library/Application\ Support/MountEFI ]]; then mkdir -p ~/Library/Application\ Support/MountEFI; fi
 	         rsync -avq  /S*/L*/E*/msdosfs.kext ~/Library/Application\ Support/MountEFI >/dev/null 2>&1
	         /usr/libexec/PlistBuddy -c "Add :OSBundleRequired string Safe Boot" ~/Library/Application\ Support/MountEFI/msdosfs.kext/Contents/Info.plist >/dev/null 2>&1
             echo "${mypassword}" | sudo -S chown -R root:wheel ~/Library/Application\ Support/MountEFI/msdosfs.kext >/dev/null 2>&1
             sudo chmod -R 755 ~/Library/Application\ Support/MountEFI/msdosfs.kext >/dev/null 2>&1
	         sudo kextutil ~/Library/Application\ Support/MountEFI/msdosfs.kext >/dev/null 2>&1; sudo kextutil ~/Library/Application\ Support/MountEFI/msdosfs.kext >/dev/null 2>&1
  	         echo "${mypassword}" | sudo -S rm -Rf ~/Library/Application\ Support/MountEFI/msdosfs.kext >/dev/null 2>&1
        fi
    fi
fi
}

DO_MOUNT(){
    	if [[ $flag = 0 ]] && [[ "$(sysctl -n kern.safeboot)" = "1" ]]; then ENTER_PASSWORD; password_was_entered=1; IF_UNLOCK_SAFE_MODE; fi
        if [[ $flag = 0 ]]; then
                    fsck_msdos -fy ${string} >>/dev/null 2>/dev/null
                    if ! diskutil quiet mount  /dev/${string} 2>/dev/null; then
                    sleep 1
                    diskutil quiet mount  /dev/${string} 2>/dev/null; fi  
        else
                    password_was_entered=0
                    if [[ $mypassword = "0" ]]; then ENTER_PASSWORD; password_was_entered=1; fi
                    if [[ ! $mypassword = "0" ]]; then
                        CHECK_PASSWORD
                        if [[ ${need_password} = 0 ]]; then
                            IF_UNLOCK_SAFE_MODE
                            sudo fsck_msdos -fy ${string} >>/dev/null 2>/dev/null
                            if ! sudo diskutil quiet mount  /dev/${string} 2>/dev/null; then 
                                sleep 1
                                sudo diskutil quiet mount  /dev/${string} 2>/dev/null
                            fi
                        fi
                    fi
        fi
MOUNTED_CHECK
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

                echo "${mypassword}" | sudo -S diskutil quiet umount force  /dev/${string} 2>/dev/null
            
                    else
            
        	 	sudo diskutil quiet umount force  /dev/${string}

                    fi

	     fi
fi
}

NEED_PASSWORD(){
need_password=0
if [[ ! $flag = 0 ]]; then 
              mypassword=$(security find-generic-password -a ${USER} -s ${!efimounter} -w 2>/dev/null)
                        if [[ "${mypassword}" = "" ]]; then mypassword=0; fi
                        if ! echo "${mypassword}" | sudo -S printf "" 2>/dev/null; then
                            if [[ $loc = "ru" ]]; then printf '\033[1A\r\033[48C''                                \r\033[48C'; else 
                                                   printf '\033[1A\r\033[50C''                                \r\033[50C'; fi
                            ENTER_PASSWORD "force"
                            if [[ $mypassword = "0" ]]; then need_password=1; fi
                        fi
fi
}
##################################################################################################
SPIN_OC(){

loader_found=0

FIND_OPENCORE(){

printf '\r\n\n'
if [[ $loc = "ru" ]]; then
printf ''${cm[ld_srch]}'  Подождите. Ищем загрузочные разделы с '${cm[ld_oc]}'OpenCore'${cm[ld_srch]}' ...  '${cm[clr]}''
else
printf ''${cm[ld_srch]}'  Wait. Looking for boot partitions with '${cm[ld_oc]}'OpenCore'${cm[ld_srch]}' loader...  '${cm[clr]}''
fi

was_mounted=0; var1=$pos; num=0; spin='-\|/'; i=0; noefi=1
while [ $var1 != 0 ] 
do 
    pnum=${nlist[num]}; string=`echo ${dlist[$pnum]}`
    mcheck=`df | grep ${string}`; if [[ ! $mcheck = "" ]]; then mcheck="Yes"; fi 
    if [[ ! $mcheck = "Yes" ]]; then was_mounted=0; DO_MOUNT ; if [[ ${braked} = 1 ]]; then braked=0; break; fi; else was_mounted=1; fi

    vname=`df | egrep ${string} | sed 's#\(^/\)\(.*\)\(/Volumes.*\)#\1\3#' | cut -c 2-`

	if [[ -d "$vname"/EFI/BOOT ]]; then
			if [[ -f "$vname"/EFI/BOOT/BOOTX64.efi ]] && [[ -f "$vname"/EFI/BOOT/bootx64.efi ]] && [[ -f "$vname"/EFI/BOOT/BOOTx64.efi ]]; then 
					check_loader=`xxd "$vname"/EFI/BOOT/BOOTX64.EFI | grep -Eo "OpenCore"` ; check_loader=`echo ${check_loader:0:8}`
                        if [[ ${check_loader} = "OpenCore" ]]; then loader_found=1; if [[ ! $OpenFinder = 0 ]]; then open "$vname/EFI"; fi; was_mounted=1
                        if [[ ! $ldrname = "" ]]; then break; fi
                        fi   
	         fi
	fi

		if [[ "$was_mounted" = 0 ]]; then diskutil quiet  umount /dev/${string}; mounted=0; UNMOUNTED_CHECK ; fi
		
    let "num++"
    let "var1--"
done
nogetlist=1
}

if [[ $loc = "ru" ]]; then printf '\r\033[48C'; else printf '\r\033[50C'; fi
    NEED_PASSWORD
if [[ ${need_password} = 0 ]]; then
    printf '\r\n'
    printf "\033[57C"
    spin='-\|/'
    i=0
    while :;do let "i++"; i=$(( (i+1) %4 )) ; printf "${cm[ld_srch_sp]}\b$1${spin:$i:1}${cm[clr]}" ;sleep 0.2;done &
    trap "kill $!" EXIT
    FIND_OPENCORE 
    kill $!
    wait $! 2>/dev/null
    trap " " EXIT
fi
if [[ $loader_found = 0 ]]; then 
MOUNT_EFI_WINDOW_UP &
fi
}

#####################################################################################################
SPIN_FCLOVER(){

# Определение функции розыска Clover в виде проверки бинарика EFI/BOOT/bootx64.efi 
##############################################################################
FIND_CLOVER(){

loader_found=0

printf '\r\n\n'
if [[ $loc = "ru" ]]; then
printf ''${cm[ld_srch]}'  Подождите. Ищем загрузочные разделы с '${cm[ld_cl]}'Clover'${cm[ld_srch]}' ...  '${cm[clr]}''
else
printf ''${cm[ld_srch]}'  Wait. Looking for boot partitions with '${cm[ld_cl]}'Clover'${cm[ld_srch]}' loader...  '${cm[clr]}''
fi

was_mounted=0; var1=$pos; num=0; spin='-\|/'; i=0; noefi=1
while [ $var1 != 0 ] 
do 
	pnum=${nlist[num]}; string=`echo ${dlist[$pnum]}`
    mcheck=`df | grep ${string}`; if [[ ! $mcheck = "" ]]; then mcheck="Yes"; fi
	if [[ ! $mcheck = "Yes" ]]; then  was_mounted=0; DO_MOUNT ; if [[ ${braked} = 1 ]]; then braked=0; break; fi
    else
		was_mounted=1
    fi

    vname=`df | egrep ${string} | sed 's#\(^/\)\(.*\)\(/Volumes.*\)#\1\3#' | cut -c 2-`

	if [[ -d "$vname"/EFI/BOOT ]]; then
			if [[ -f "$vname"/EFI/BOOT/BOOTX64.efi ]] && [[ -f "$vname"/EFI/BOOT/bootx64.efi ]] && [[ -f "$vname"/EFI/BOOT/BOOTx64.efi ]]; then 
                check_loader=`xxd "$vname"/EFI/BOOT/BOOTX64.EFI | grep -Eo "Clover"` ; check_loader=`echo ${check_loader:0:6}`
                    if [[ ${check_loader} = "Clover" ]]; then loader_found=1; if [[ ! $OpenFinder = 0 ]]; then open "$vname/EFI"; fi ; was_mounted=1
                    if [[ ! $ldrname = "" ]]; then break; fi
                    fi   
	        fi
	fi
    if [[ "$was_mounted" = 0 ]]; then diskutil quiet  umount /dev/${string}; mounted=0; UNMOUNTED_CHECK ; fi
		
    let "num++"
    let "var1--"
done
nogetlist=1
}

if [[ $loc = "ru" ]]; then printf '\r\033[48C'; else printf '\r\033[50C'; fi
    NEED_PASSWORD
if [[ ${need_password} = 0 ]]; then
    printf '\r\n'
    printf "\033[57C"
    spin='-\|/'
    i=0
    while :;do let "i++"; i=$(( (i+1) %4 )) ; printf "${cm[ld_srch_sp]}\b$1${spin:$i:1}${cm[clr]}" ;sleep 0.2;done &
    trap "kill $!" EXIT
    FIND_CLOVER
    kill $!
    wait $! 2>/dev/null
    trap " " EXIT
fi
if [[ $loader_found = 0 ]]; then 
MOUNT_EFI_WINDOW_UP &
fi
}
#####################################################################################################

SPIN_FLOADERS(){

################################### поиск всех загрузчиков #########################################
FIND_ALL_LOADERS(){

    printf '\r\n\n'
    if [[ $loc = "ru" ]]; then
    printf ''${cm[ld_srch]}'  Подождите. Ищем загрузочные разделы с '${cm[ld_srch_bt]}'BOOTx64.efi'${cm[ld_srch]}' ...  '${cm[clr]}''
    else
    printf ''${cm[ld_srch]}'  Wait. Looking for partitions with '${cm[ld_srch_bt]}'BOOTx64.efi'${cm[ld_srch]}' loaders ... '${cm[clr]}''
    fi

was_mounted=0; var1=$pos; num=0; spin='-\|/'; i=0; noefi=1
while [ $var1 != 0 ] 
do 
	pnum=${nlist[num]}; string=`echo ${dlist[$pnum]}`
    mcheck=`df | grep ${string}`; if [[ ! $mcheck = "" ]]; then mcheck="Yes"; fi
	if [[ ! $mcheck = "Yes" ]]; then was_mounted=0; DO_MOUNT ; if [[ ${braked} = 1 ]]; then braked=0; break; fi; else was_mounted=1; fi
    FIND_LOADERS   
    if [[ ! ${loader} = "" ]];then
       if [[ ! ${lddlist[pnum]} = "" ]]; then max=0; for y in ${!lddlist[@]}; do if [[ ${max} -lt ${y} ]]; then max=${y}; fi; done
          for ((y=$((max+1));y>pnum;y--)); do lddlist[y]=${lddlist[((y-1))]}; ldlist[y]=${ldlist[((y-1))]}; done
       fi
    ldlist[pnum]="${loader}"; lddlist[pnum]=${dlist[pnum]}
    fi   
    if [[ "$was_mounted" = 0 ]]; then diskutil quiet  umount /dev/${string}; mounted=0; UNMOUNTED_CHECK; fi
		
    let "num++"
    let "var1--"
done
nogetlist=1
}
    NEED_PASSWORD
if [[ ${need_password} = 0 ]]; then
    printf '\r\n'
    printf "\033[57C"
    spin='-\|/'
    i=0
    while :;do let "i++"; i=$(( (i+1) %4 )) ; printf "${cm[ld_srch_sp]}\b$1${spin:$i:1}${cm[clr]}" ;sleep 0.2;done &
    trap "kill $!" EXIT 
    FIND_ALL_LOADERS
    kill $!
    wait $! 2>/dev/null
    trap " " EXIT
fi
MOUNT_EFI_WINDOW_UP &
}

###################################################################################################
# Функция отключения EFI разделов

UNMOUNTS(){

GETARR

var1=$pos; num=0; spin='-\|/'; i=0; noefi=1

cd "${ROOT}"; if [[ ! $flag = 0 ]]; then CHECK_PASSWORD; fi

while [ $var1 != 0 ] 
do 

	pnum=${nlist[num]}
	string=`echo ${dlist[$pnum]}`

    mcheck=`df | grep ${string}`; if [[ ! $mcheck = "" ]]; then mcheck="Yes"; fi 

if [[ $mcheck = "Yes" ]]; then
	noefi=0
    if osascript -e 'tell application "Finder" to get window "EFI"' >>/dev/null 2>/dev/null 
        then osascript -e 'tell application "Finder" to close  window "EFI"' >>/dev/null 2>/dev/null; fi
	diskutil quiet umount /dev/${string}
    if [[ ! $flag = 0 ]] && [[ ${need_password} = 0 ]]; then sudo fsck_msdos -fy "/dev/${string}" >>/dev/null 2>/dev/null; else fsck_msdos -fy "/dev/${string}" >>/dev/null 2>/dev/null; fi

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

CHECK_SANDBOX

# У Эль Капитан другой термин для размера раздела
	
if [[ "$macos" = "1011" ]]; then vmacos="Total Size:"; else vmacos="Disk Size:"; fi

MOUNT_EFI_WINDOW_UP &

rmlist=(); posrm=0

GETARR

if [[ ! $upd = 0 ]] || [[ ! $rst = 0 ]]; then GET_MOUNTEFI_STACK; upd=0; else mounted_loaders_list=(); ldlist=(); lddlist=(); oc_list=(); fi

# Блок обработки ситуации если найден всего один раздел EFI ########################
###################################################################################
if [[ $pos = 1 ]]; then 

if [[ ! ${menue} = 1 ]]; then

GET_USER_PASSWORD

string=`echo ${dlist[0]}`

wasmounted=0

mcheck=`df | grep ${string}`; if [[ ! $mcheck = "" ]]; then mcheck="Yes"; fi 
if [[ ! $mcheck = "Yes" ]]; then

    if [[ $mypassword = "0" ]] && [[ $flag = 1 ]]; then

    clear && printf '\e[8;24;80t' && printf '\e[3J' && printf "\033[H"
            
            if [[ $loc = "ru" ]]; then
        printf '\n'${cm[head_ast]}'*******'${cm[head_str]}'      Программа монтирует EFI разделы в Mac OS ('${cm[head_X]}'X'${cm[head_str]}'.'${cm[head_os]}'11'${cm[head_str]}' - '${cm[head_X]}'XI'${cm[head_str]}'.'${cm[head_os]}'2)     '${cm[head_ast]}'*******'${cm[clr]}'\n\n'
			else
        printf '\n'${cm[head_ast]}'*******'${cm[head_str]}'    This program mounts EFI partitions on Mac OS ('${cm[head_X]}'X'${cm[head_str]}'.'${cm[head_os]}'11'${cm[head_str]}' - '${cm[head_X]}'XI'${cm[head_str]}'.'${cm[head_os]}'2)   '${cm[head_ast]}'*******'${cm[clr]}'\n\n'
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
    
    if [[ $loc = "ru" ]]; then printf '\n\n\r\033[48C''                                \r\033[48C'; else 
                                                   printf '\n\n\r\033[50C''                                \r\033[50C'; fi

    NEED_PASSWORD
    
 fi        

if [[ $mypassword = "0" ]]; then 
            printf '\r'
            printf ' %.0s' {1..68}; printf ' %.0s' {1..68}
            printf '\r\033[1A'
            GET_APP_ICON
            if [[ $loc = "ru" ]]; then
            osascript -e 'display dialog "Без правильного пароля EFI раздел не подключить. \nВыходим....." '"${icon_string}"' buttons {"OK"} default button "OK"'
            else
            osascript -e 'display dialog "You should enter the correct password \nto mount EFI partition. Exiting...." '"${icon_string}"' buttons {"OK"} default button "OK"'
            fi
            EXIT_PROGRAM
fi

DO_MOUNT

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
if [[ $cm_check = 0 ]]; then
theme="system"
GET_THEME
if [[ $theme = "built-in" ]]; then CUSTOM_SET; else SET_SYSTEM_THEME; fi &
fi
############################################################################################
##################### проверка на загрузчик после монтирования ##################################################################################
FIND_LOADERS(){

GET_LOADERS
if [[ ! $CheckLoaders = 0 ]]; then 

    unset loader; lflag=0
    if [[ $mcheck = "Yes" ]]; then 

vname=$(df | egrep ${string} | sed 's#\(^/\)\(.*\)\(/Volumes.*\)#\1\3#' | cut -c 2-)

			if  [[ -f "$vname"/EFI/BOOT/BOOTX64.efi ]] && [[ -f "$vname"/EFI/BOOT/bootx64.efi ]] && [[ -f "$vname"/EFI/BOOT/BOOTx64.efi ]]; then 
                md5_loader=$( md5 -qq "$vname"/EFI/BOOT/BOOTx64.efi )               
                if [[ ${md5_loader} = "" ]]; then loader=""; else
                   if [[ ${mounted_loaders_list[$pnum]} = ${md5_loader} ]]; then loader=""; else
                    mounted_loaders_list[$pnum]="${md5_loader}"; lflag=1
                    GET_LOADER_STRING
                  fi
                fi
            else
                   if [[ ${mounted_loaders_list[pnum]} = "" ]] || [[ ! ${mounted_loaders_list[pnum]} = 0 ]]; then  loader="empty"; mounted_loaders_list[pnum]=0; lflag=1; fi
            fi
    fi
fi

}

########################### вывод признаков наличия загрузчика #########################################
SHOW_LOADERS(){
if [[ $CheckLoaders = 1 ]]; then
printf "\033[H"
        ldnlist=(); for zz in ${!dlist[@]}; do for xx in ${!lddlist[@]}; do if [[ ${dlist[zz]} = ${lddlist[xx]} ]]; then ldnlist[zz]=$((zz+1)); break; fi; done; done
        posl=${#ldnlist[@]}
            if [[ ! $posl = 0 ]]; then
            var99=$posl; pointer=0
                for pointer in ${!ldnlist[@]}
                    do 
                        if [[ ${ldnlist[pointer]} -le $sata_lines ]]; then
                        let "line=ldnlist[pointer]+8" 
                        else
                        let "line=ldnlist[pointer]+11"
                        fi
                        if [[ "${ldlist[$pointer]:0:6}" = "Clover" ]]; then printf "\r\033[$line;f\033['$c_clov'C"'\e['$themeldrs'm'"${cm[ld_cl]}${Clover}"" "; if [[ ! "${ldlist[$pointer]:6:10}" = "" ]]; then printf "\r\033[55C${ldlist[$pointer]:6:10}"" "; fi; printf '\e[0m'
                                elif [[ "${ldlist[$pointer]:0:12}" = "unrecognized" ]]; then
                                     c_unr=47
                                     if [[ $loc = "ru" ]]; then Unrec="Не распознан"; else Unrec="Unrecognized"; fi
                                     printf "\033[$line;f\033['$c_unr'C"'\e['$themeldrs'm'"${cm[ld_unrec]}${Unrec}"" "; printf '\e[0m'
                                elif [[ "${ldlist[$pointer]:0:5}" = "Other" ]]; then
                                     Other="${ldlist[$pointer]:5}"; ooc=${#Other}; let "c_oth=(13-ooc)/2+46"; printf "\033[$line;f\033[47C""             "
                                     printf "\033[$line;f\033['$c_oth'C"'\e['$themeldrs'm'"${cm[ld_oth]}${Other}"" "; printf '\e[0m'
                                elif [[ "${ldlist[$pointer]:0:9}" = "GNU/Linux" ]]; then
                                     Linux="GNU/Linux"; c_lin=49
                                     printf "\033[$line;f\033['$c_lin'C"'\e['$themeldrs'm'"${cm[ld_gb]}${Linux}"" "; printf '\e[0m'
                                elif [[ "${ldlist[$pointer]:0:6}" = "refind" ]]; then
                                     Refind="rEFInd"; c_ref=51
                                     printf "\033[$line;f\033['$c_ref'C"'\e['$themeldrs'm'"${cm[ld_rf]}${Refind}"" "; printf '\e[0m'
                                elif [[ "${ldlist[$pointer]:0:7}" = "Windows" ]]; then
                                     Windows="Windows"; c_win=47
                                     printf "\033[$line;f\033['$c_win'C"'\e['$themeldrs'm'"${cm[ld_wn]}${Windows}"" ";  printf "\r\033[54C${ldlist[$pointer]:7:9}""  MS ";  printf '\e[0m'
                                elif [[ "${ldlist[$pointer]:0:8}" = "OpenCore" ]]; then
                                     printf "\033[$line;f\033['$c_oc'C"'\e['$themeldrs'm'"${cm[ld_oc]}${OpenCore}"" "; if [[ ! "${ldlist[$pointer]:8:13}" = "" ]]; then printf "\r\033[55C${ldlist[$pointer]:8:13}"" "; fi; printf '\e[0m'
                        fi 
                    done
    fi                       
fi
printf "\033[H"; let "correct=lines-7"; if [[ $loc = "ru" ]]; then printf "\r\033[$correct;f\033[49C"; else printf "\r\033[$correct;f\033[51C"; fi
}
#################################################################################################

spinny(){ let "i++"; i=$(( (i+1) %4 )); printf "${cm[head_upd_sch_sp]}\b$1${spin:$i:1}${cm[clr]}"; }

COLOR_HEAD(){
for i in ${!mlist[@]}; do 
   if [[ "$1" = "sata" ]]; then 
     if [[ ${mlist[i]:0:3} = "sat" ]] && [[ ${mlist[i]:4} = "true" ]]; then printf '\033['$((i+8))';8;f'${cm[num_sata_br]}')'${cm[mount_sata_pls]}'   +  '${cm[clr]}''
                elif [[ ${mlist[i]:0:3} = "sat" ]] && [[ ${mlist[i]:4} = "false" ]]; then  printf '\033['$((i+8))';8;f'${cm[num_sata_br]}')'${cm[mount_sata_dots]}' ...  '${cm[clr]}''; fi
        elif [[ "$1" = "usb" ]]; then
            if [[ ${mlist[i]:0:3} = "usb" ]] && [[ ${mlist[i]:4} = "true" ]]; then printf '\033['$((sata_lines+11+(i-sata_lines)))';8;f'${cm[num_usb_br]}')'${cm[mount_usb_pls]}'   +  '${cm[clr]}''
                elif [[ ${mlist[i]:0:3} = "usb" ]] && [[ ${mlist[i]:4} = "false" ]]; then printf '\033['$((sata_lines+11+(i-sata_lines)))';8;f'${cm[num_usb_br]}')'${cm[mount_usb_dots]}' ...  '${cm[clr]}''; fi
        fi           
done
if [[ "$1" = "sata" ]]; then printf '\033['$((sata_lines+9))';1f'; else printf '\033['$((sata_lines+usb_lines+12))';1f'; fi
}

# Определение  функции построения и вывода списка разделов 
GETLIST(){

GET_LOADERS
if [[ ! $CheckLoaders = 0 ]]; then col=94; ldcorr=14; else col=80; ldcorr=2; fi 
printf '\e[8;'${lines}';'$col't' && printf '\e[3J'; mlist=()
var0=$pos
num=0
ch=0
unset string
unset screen_buffer
unset usb_screen_buffer
sata_lines=0
usb_lines=0

		if [[ $loc = "ru" ]]; then
    printf '\n\n      '${cm[head_upd_sch_num]}'0'${cm[head_upd_sch_br]}')'${cm[head_upd_sch]}'  поиск разделов ..... '${cm[clr]}''
        else
    printf '\n\n      '${cm[head_upd_sch_num]}'0'${cm[head_upd_sch_br]}')'${cm[head_upd_sch]}'  updating partitions list ..... '${cm[clr]}''
        fi


spin='-\|/'
i=0
printf "${cm[head_upd_sch_sp]}$1${spin:$i:1}${cm[clr]}"

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
        ################################ получение имени диска для переименования #####################
        ########GET_RENAMEHD
        IFS=';'; rlist=( $(echo "$MountEFIconf" | grep -A 1 "RenamedHD" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n') ); unset IFS
        rcount=${#rlist[@]}
        if [[ ! $rcount = 0 ]]; then
         for posr in ${!rlist[@]}; do
            rdrive=$( echo "${rlist[$posr]}" | cut -f1 -d"=" )
            if [[ "$rdrive" = "$drive" ]]; then drive=$( echo "${rlist[posr]}" | rev | cut -f1 -d"=" | rev ); break; fi
         done
        fi
        ###################
		dcorr=${#drive}
		if [[ ${dcorr} -gt 30 ]]; then dcorr=0; drive="${drive:0:30}"; else let "dcorr=30-dcorr"; fi


    dsize=`echo "$sizes_iomedia" | grep -A10 -B10 ${string} | grep -m 1 -w "Size =" | cut -f2 -d "=" | tr -d "\n \t"`
    if [[  $dsize -le 999999999 ]]; then dsize=$(echo "scale=1; $dsize/1000000" | bc); dmsize=" Mb"
        else
            if [[  $dsize -le 999999999999 ]]; then dsize=$(echo "scale=1; $dsize/1000000000" | bc); dmsize=" Gb"
                    else
                         dsize=$(echo "scale=1; $dsize/1000000000000" | bc); dmsize=" Gb"
            fi
    fi

	
    		scorr=`echo ${#dsize}`
    		let "scorr=scorr-5"
    		let "scorr=6-scorr"

       
    mcheck=`df | grep ${string}`; if [[ ! $mcheck = "" ]]; then mcheck="Yes"; fi 


         if [[ $ch -gt 9 ]]; then ncorr=1; else ncorr=2; fi   

        
          CHECK_USB


        bsd=$(echo $string | cut -f2 -dk | cut -f1 -ds) ; bsp=$(echo $string | cut -f3 -ds)

        if [[ $usb = 1 ]]; then 
                    let "usb_lines++"
                    
                     if [[ ! $mcheck = "Yes" ]]; then
        usb_screen_buffer+=$(printf '\n    '${cm[num_usb]}"%"$ncorr"s"$ch') ...   '${cm[dn_usb]}''"$drive""%"$dcorr"s"' '"%"$ldcorr"s"' '${cm[dn_bsd_usb]}disk${cm[usb_bsd]}${bsd}${cm[dn_bsd_usb]}s${cm[usb_bsp]}${bsp}"%"$corr"s""%"$scorr"s"' '${cm[pn_size_usb]}''"$dsize${cm[pn_size_musb]}$dmsize"'     '${cm[clr]}'')
        mlist[$((ch))]="usb:false"
                            else
        usb_screen_buffer+=$(printf '\n    '${cm[num_usb]}"%"$ncorr"s"$ch')   +   '${cm[dn_usb]}''"$drive""%"$dcorr"s"' '"%"$ldcorr"s"' '${cm[dn_bsd_usb]}disk${cm[usb_bsd]}${bsd}${cm[dn_bsd_usb]}s${cm[usb_bsp]}${bsp}"%"$corr"s""%"$scorr"s"' '${cm[pn_size_usb]}''"$dsize${cm[pn_size_musb]}$dmsize"'     '${cm[clr]}'')
        mlist[$((ch))]="usb:true"
              fi

        else
                    let "sata_lines++"
        
                     if [[ ! $mcheck = "Yes" ]]; then
        screen_buffer+=$(printf '\n    '${cm[num_sata]}"%"$ncorr"s"$ch') ...   '${cm[dn_sata]}''"$drive""%"$dcorr"s"' '"%"$ldcorr"s"' '${cm[dn_bsd_sata]}disk${cm[sata_bsd]}${bsd}${cm[dn_bsd_sata]}s${cm[sata_bsp]}${bsp}"%"$corr"s""%"$scorr"s"' '${cm[pn_size_sata]}''"$dsize${cm[pn_size_msata]}$dmsize"'     '${cm[clr]}'')
        mlist[$((ch))]="sat:false"
                            else
        screen_buffer+=$(printf '\n    '${cm[num_sata]}"%"$ncorr"s"$ch')   +   '${cm[dn_sata]}''"$drive""%"$dcorr"s"' '"%"$ldcorr"s"' '${cm[dn_bsd_sata]}disk${cm[sata_bsd]}${bsd}${cm[dn_bsd_sata]}s${cm[sata_bsp]}${bsp}"%"$corr"s""%"$scorr"s"' '${cm[pn_size_sata]}''"$dsize${cm[pn_size_msata]}$dmsize"'     '${cm[clr]}'')
        mlist[$((ch))]="sat:true"
              fi
        fi

        spinny

        if [[ ! $CheckLoaders = 0 ]]; then FIND_LOADERS 
            if [[ ! ${loader} = "" ]];then
             ldlist[pnum]="$loader"; lddlist[pnum]=${dlist[pnum]}
            fi
        fi
                
    spinny
	let "num++"
	let "var0--"
done


printf "\r\033[3A"


		if [[ $loc = "ru" ]]; then
            if [[ $CheckLoaders = 0 ]]; then
                printf '\n\n\n      '${cm[head_num_sch]}'0'${cm[head_sch_br]}')  '${cm[head_sch]}'повторить поиск разделов                     '${cm[head_pls_qts]}'"'${cm[head_pls]}'+'${cm[head_pls_qts]}'"'${cm[head_pls_str]}' - подключенные  '${cm[clr]}'\n\n'
	            printf '     '${cm[dots_line1]}''
	            printf '.%.0s' {1..31} 
                printf ''${cm[head_sata]}' SATA '${cm[dots_line1]}''
                printf '.%.0s' {1..31}
                printf ''${cm[clr]}'\n'
                else
                printf '\n\n\n      '${cm[head_num_sch]}'0'${cm[head_sch_br]}')  '${cm[head_sch]}'повторить поиск разделов                            '${cm[head_pls_qts]}'"'${cm[head_pls]}'+'${cm[head_pls_qts]}'"'${cm[head_pls_str]}' - подключенные  '${cm[clr]}'\n\n'
	            printf '     '${cm[dots_line1]}''
                printf '.%.0s' {1..38}
                printf ''${cm[head_sata]}' SATA '${cm[dots_line1]}''
                printf '.%.0s' {1..38}
                printf ''${cm[clr]}'\n'
                fi 
		else
	         if [[ $CheckLoaders = 0 ]]; then
                printf '\n\n\n      '${cm[head_num_sch]}'0'${cm[head_sch_br]}')  '${cm[head_sch]}'update EFI partitions list                        '${cm[head_pls_qts]}'"'${cm[head_pls]}'+'${cm[head_pls_qts]}'" - mounted '${cm[clr]}'\n\n' 
	            printf '     '${cm[dots_line1]}''
	            printf '.%.0s' {1..32} 
                printf ''${cm[head_sata]}' SATA '${cm[dots_line1]}''
                printf '.%.0s' {1..30}
                printf '\n'
                else
                printf '\n\n\n      '${cm[head_num_sch]}'0'${cm[head_sch_br]}')  '${cm[head_sch]}'update EFI partitions list                              '${cm[head_pls_qts]}'"'${cm[head_pls]}'+'${cm[head_pls_qts]}'" - mounted '${cm[clr]}'\n\n' 
	            printf '     '${cm[dots_line1]}''
                printf '.%.0s' {1..38}
                printf ''${cm[head_sata]}' SATA '${cm[dots_line1]}''
                printf '.%.0s' {1..38}
                printf ''${cm[clr]}'\n'
                fi
        fi

echo "${screen_buffer}"
COLOR_HEAD sata
    
if [[ ! $usb_lines = 0 ]]; then

                printf '\n     '${cm[dots_line2]}''  
                if [[ $CheckLoaders = 0 ]]; then
	            printf '.%.0s' {1..32} 
                printf ''${cm[head_usb]}' USB '${cm[dots_line2]}''
                printf '.%.0s' {1..31}
                else
                printf '.%.0s' {1..39}
                printf ''${cm[head_usb]}' USB '${cm[dots_line2]}''
                printf '.%.0s' {1..38}
                fi
                printf ''${cm[clr]}'\n     '

echo "${usb_screen_buffer}"
COLOR_HEAD usb
fi

	let "ch++"
	
	            printf '\n     '${cm[dots_line3]}''
                if [[ $CheckLoaders = 0 ]]; then
	            printf '.%.0s' {1..68} 
                else
                printf '.%.0s' {1..82}
                printf ''${cm[clr]}''
                fi

if [[ $ShowKeys = 1 ]]; then

	 if [[ $loc = "ru" ]]; then
	printf '\n'${cm[cl_E]}'      E  '${cm[kh_str]}'-   подключить EFI диска этой системы     '${cm[clr]}'\n'
	printf ''${cm[cl_U]}'      U  '${cm[kh_str]}'-   отключить ВСЕ подключенные разделы EFI  '${cm[clr]}'\n'
    printf ''${cm[cl_A]}'      A  '${cm[kh_str]}'-   настроить авто-подключение EFI          '${cm[clr]}'\n'
    printf ''${cm[cl_I]}'      I  '${cm[kh_str]}'-   дополнительное меню                     '${cm[clr]}'\n'
	printf ''${cm[cl_Q]}'      Q  '${cm[kh_str]}'-   закрыть окно и выход из программы     '${cm[clr]}'\n\n'
    #printf '                                                    \n' 
			else
	printf '\n'${cm[cl_E]}'      E  '${cm[kh_str]}'-   mount the EFI of current system drive '${cm[clr]}'\n' 
	printf ''${cm[cl_U]}'      U  '${cm[kh_str]}'-   unmount ALL mounted  EFI partitions     '${cm[clr]}'\n'
    printf ''${cm[cl_A]}'      A  '${cm[kh_str]}'-   set up EFI'"'"'s auto-mount             '${cm[clr]}'\n'
    printf ''${cm[cl_I]}'      I  '${cm[kh_str]}'-   extra menu                              '${cm[clr]}'\n'
	printf ''${cm[cl_Q]}'      Q  '${cm[kh_str]}'-   close terminal and exit from the program'${cm[clr]}'\n\n'
    #printf '                                                    \n' 
	     fi
else 
        printf '\n'
        if [[ $CheckLoaders = 0 ]]; then printf '\n\n'; fi
fi
	


	
printf '\n\n' 

SHOW_LOADERS
#DBG "CLIENT oc_list after GETLIST = $(for i in ${!oc_list[@]}; do printf "$i) ${oc_list[i]} "; done)"
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
mlist[$((chs))]="sat:true"
            else
usb_screen_buffer=$( echo  "$usb_screen_buffer" | sed "s/$chs) ...  /$chs)   +  /" )
mlist[$((chs))]="usb:true"
            fi
    else
            if [[ $usb = 0 ]]; then
screen_buffer=$( echo  "$screen_buffer" | sed "s/$chs)   +  /$chs) ...  /" )
mlist[$((chs))]="sat:false"
            else
usb_screen_buffer=$( echo  "$usb_screen_buffer" | sed "s/$chs)   +  /$chs) ...  /" )
mlist[$((chs))]="usb:false"
            fi
    fi

fi

		if [[ $loc = "ru" ]]; then
             if [[ $CheckLoaders = 0 ]]; then
        	    printf '\n'${cm[head_ast]}'*******      '${cm[head_str]}'Программа монтирует EFI разделы в Mac OS ('${cm[head_X]}'X'${cm[head_str]}'.'${cm[head_os]}'11 '${cm[head_str]}'- '${cm[head_X]}'XI'${cm[head_str]}'.'${cm[head_os]}'2'${cm[head_str]}')      '${cm[head_ast]}'*******'${cm[clr]}'\n'
                printf '\n\n'${cm[head_num_sch]}'      0'${cm[head_sch_br]}')'${cm[head_sch]}'  повторить поиск разделов                     '${cm[head_pls_qts]}'"'${cm[head_pls]}'+'${cm[head_pls_qts]}'" '${cm[head_pls_str]}'- подключенные  '${cm[clr]}'\n\n' 
	            printf '     '${cm[dots_line1]}''
	            printf '.%.0s' {1..31} 
                printf ''${cm[head_sata]}' SATA '${cm[dots_line1]}''
                printf '.%.0s' {1..31}
                printf ''${cm[clr]}'\n'
                else
                printf '\n'${cm[head_ast]}'*********           '${cm[head_str]}'Программа монтирует EFI разделы в Mac OS ('${cm[head_X]}'X'${cm[head_str]}'.'${cm[head_os]}'11 '${cm[head_str]}'- '${cm[head_X]}'XI'${cm[head_str]}'.'${cm[head_os]}'2'${cm[head_str]}')           '${cm[head_ast]}'*********'${cm[clr]}'\n'
                printf '\n\n'${cm[head_num_sch]}'      0'${cm[head_sch_br]}')'${cm[head_sch]}'  повторить поиск разделов                            '${cm[head_pls_qts]}'"'${cm[head_pls]}'+'${cm[head_pls_qts]}'" '${cm[head_pls_str]}'- подключенные  '${cm[clr]}'\n\n' 
	            printf '     '${cm[dots_line1]}''
                printf '.%.0s' {1..38}
                printf ' '${cm[head_sata]}'SATA '${cm[dots_line1]}''
                printf '.%.0s' {1..38}
                printf ''${cm[clr]}'\n'
                fi

			else

             if [[ $CheckLoaders = 0 ]]; then
                printf '\n'${cm[head_ast]}'*******    '${cm[head_str]}'This program mounts EFI partitions on Mac OS ('${cm[head_X]}'X'${cm[head_str]}'.'${cm[head_os]}'11 '${cm[head_str]}'- '${cm[head_X]}'XI'${cm[head_str]}'.'${cm[head_os]}'2'${cm[head_str]}')    '${cm[head_ast]}'*******'${cm[clr]}'\n'
                printf '\n\n'${cm[head_num_sch]}'      0'${cm[head_sch_br]}')'${cm[head_sch]}'  update EFI partitions list                        '${cm[head_pls_qts]}'"'${cm[head_pls]}'+'${cm[head_pls_qts]}'" '${cm[head_pls_str]}'- mounted '${cm[clr]}'\n\n'  
	            printf '     '${cm[dots_line1]}''
	            printf '.%.0s' {1..31} 
                printf ''${cm[head_sata]}' SATA '${cm[dots_line1]}''
                printf '.%.0s' {1..31}
                printf ''${cm[clr]}'\n'
                else
                printf '\n'${cm[head_ast]}'*********         '${cm[head_str]}'This program mounts EFI partitions on Mac OS ('${cm[head_X]}'X'${cm[head_str]}'.'${cm[head_os]}'11 '${cm[head_str]}'- '${cm[head_X]}'XI'${cm[head_str]}'.'${cm[head_os]}'2'${cm[head_str]}')         '${cm[head_ast]}'*********'${cm[clr]}'\n'
                printf '\n\n'${cm[head_num_sch]}'      0'${cm[head_sch_br]}')'${cm[head_sch]}'  update EFI partitions list                              '${cm[head_pls_qts]}'"'${cm[head_pls]}'+'${cm[head_pls_qts]}'" '${cm[head_pls_str]}'- mounted '${cm[clr]}'\n\n'  
	            printf '     '${cm[dots_line1]}''
                printf '.%.0s' {1..38}
                printf ''${cm[head_sata]}' SATA '${cm[dots_line1]}''
                printf '.%.0s' {1..38}
                printf ''${cm[clr]}'\n'
                fi
        fi


echo  "$screen_buffer"
COLOR_HEAD sata
if [[ ! $usb_lines = 0 ]]; then

                printf '\n     '${cm[dots_line2]}''
                if [[ $CheckLoaders = 0 ]]; then
	            printf '.%.0s' {1..32} 
                printf ''${cm[head_usb]}' USB '${cm[dots_line2]}''
                printf '.%.0s' {1..31}
                else
                printf '.%.0s' {1..39}
                printf ''${cm[head_usb]}' USB '${cm[dots_line2]}''
                printf '.%.0s' {1..38}
                fi
                printf ''${cm[clr]}'\n     '

echo "${usb_screen_buffer}"
COLOR_HEAD usb
fi


	if [[ ! $order = 1 ]] || [[ ! $order = 0 ]]; then printf "\r\033[1A"; fi
    
	printf '\n\n     '${cm[dots_line3]}''
                if [[ $CheckLoaders = 0 ]]; then
	            printf '.%.0s' {1..68} 
                else
                printf '.%.0s' {1..82}
                printf ''${cm[clr]}''
                fi

if [[ $ShowKeys = 1 ]]; then

if [[ ! $order = 3 ]]; then
	     if [[ $loc = "ru" ]]; then
	printf '\n'${cm[cl_E]}'      E  '${cm[kh_str]}'-   подключить EFI диска этой системы     '${cm[clr]}'\n'
	printf ''${cm[cl_U]}'      U  '${cm[kh_str]}'-   отключить ВСЕ подключенные разделы EFI  '${cm[clr]}'\n'
    printf ''${cm[cl_A]}'      A  '${cm[kh_str]}'-   настроить авто-подключение EFI          '${cm[clr]}'\n'
    printf ''${cm[cl_I]}'      I  '${cm[kh_str]}'-   дополнительное меню                     '${cm[clr]}'\n'
	printf ''${cm[cl_Q]}'      Q  '${cm[kh_str]}'-   закрыть окно и выход из программы'${cm[clr]}'\n\n'
    #printf '                                                    \n' 
			else
	printf '\n'${cm[cl_E]}'      E  '${cm[kh_str]}'-   mount the EFI of current system drive '${cm[clr]}'\n' 
	printf ''${cm[cl_U]}'      U  '${cm[kh_str]}'-   unmount ALL mounted  EFI partitions     '${cm[clr]}'\n'
    printf ''${cm[cl_A]}'      A  '${cm[kh_str]}'-   set up EFI'"'"'s auto-mount                '${cm[clr]}'\n'
    printf ''${cm[cl_I]}'      I  '${cm[kh_str]}'-   extra menu                              '${cm[clr]}'\n'
	printf ''${cm[cl_Q]}'      Q  '${cm[kh_str]}'-   close terminal and exit from the program'${cm[clr]}'\n\n'
    #printf '                                                    \n' 
	     fi
	else
        if [[ $loc = "ru" ]]; then
	printf '\n'${cm[cl_C]}'      C  '${cm[kh_str]}'-   подключить EFI с загрузчиком Clover       '${cm[cl_W]}'W'${cm[kh_str]}' - Режим EasyEFI '${cm[clr]}'\n'
	printf ''${cm[cl_O]}'      O  '${cm[kh_str]}'-   подключить EFI с загрузчиком Open Core    '${cm[cl_E2]}'E'${cm[kh_str]}' - Редактор цвета'${cm[clr]}'\n'
	printf ''${cm[cl_S]}'      S  '${cm[kh_str]}'-   вызвать экран настройки MountEFI          '${cm[cl_M]}'M'${cm[kh_str]}' - Цветной мод   '${cm[clr]}'\n'
    printf ''${cm[cl_P]}'      P  '${cm[kh_str]}'-   открыть config.plist с EFI раздела        '${cm[clr]}'\n'
    printf ''${cm[cl_V]}'      V  '${cm[kh_str]}'-   посмотреть версию программы               '${cm[clr]}'\n\n' 
			else
	printf '\n'${cm[cl_C]}'      C  '${cm[kh_str]}'-   mount EFI with Clover boot loader        '${cm[cl_W]}'W'${cm[kh_str]}' - EasyEFI Mode'${cm[clr]}'\n' 
	printf ''${cm[cl_O]}'      O  '${cm[kh_str]}'-   mount EFI with Open Core boot loader     '${cm[cl_E2]}'E'${cm[kh_str]}' - Color Editor'${cm[clr]}'\n' 
	printf ''${cm[cl_S]}'      S  '${cm[kh_str]}'-   call MountEFI setup screen               '${cm[cl_M]}'M'${cm[kh_str]}' - Color Mode  '${cm[clr]}'\n'
    printf ''${cm[cl_P]}'      P  '${cm[kh_str]}'-   open config.plist from EFI partition      '${cm[clr]}'\n'
    printf ''${cm[cl_V]}'      V  '${cm[kh_str]}'-   view the program version                  '${cm[clr]}'\n\n' 
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
printf ''${cm[curs_str]}'  Введите число от '${cm[curs_num_1]}'0'${cm[curs_str]}' до '${cm[curs_num_2]}''$((schs+1))''${cm[curs_str]}' ( '${cm[cl_P]}'P'${cm[curs_str]}','${cm[cl_U]}'U'${cm[curs_str]}','${cm[cl_E]}'E'${cm[curs_str]}','${cm[cl_A]}'A'${cm[curs_str]}','${cm[cl_S]}'S'${cm[curs_str]}','${cm[cl_I]}'I'${cm[curs_str]}' или '${cm[cl_Q]}'Q'${cm[curs_str]}' ):  '${cm[clr]}''; printf '                            '
			else
printf ''${cm[curs_str]}'   Enter a num from '${cm[curs_num_1]}'0'${cm[curs_str]}' to '${cm[curs_num_2]}''$((schs+1))''${cm[curs_str]}' ( '${cm[cl_P]}'P'${cm[curs_str]}','${cm[cl_U]}'U'${cm[curs_str]}','${cm[cl_E]}'E'${cm[curs_str]}','${cm[cl_A]}'A'${cm[curs_str]}','${cm[cl_S]}'S'${cm[curs_str]}','${cm[cl_I]}'I'${cm[curs_str]}' or '${cm[cl_Q]}'Q'${cm[curs_str]}' ):  '${cm[clr]}'';  printf '                         '
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

#DBG "CLIENT oc_list after UPDATELIST = $(for i in ${!oc_list[@]}; do printf "$i) ${oc_list[i]} "; done)"

}
# Конец определения функции UPDATELIST ######################################################

###################################### обновление на экране списка подключенных ###########################################
UPDATE_SCREEN(){

##################### обновление данных буфера экрана при детекте хотплага партиции ###########################
#UPDATE_SCREEN_BUFFER

var0=$pos; num=0; ch1=0; unset string
while [ $var0 != 0 ]; do 
    pnum=${nlist[num]}
    string=`echo ${dlist[$pnum]}`
	let "ch1++"
  mcheck=`df | grep ${string}`; if [[ ! $mcheck = "" ]]; then mcheck="Yes"; fi
  if [[ $mcheck = "Yes" ]]; then

        if [[ ${synchro} = 2 ]]; then for x in ${!dlist[@]}; do if [[ ${dlist[x]} = ${latest_hotplugs_parts[0]} ]]; then  let "chs=x+1"; fi; done; synchro=0; fi

        FIND_LOADERS

        if [[ ! ${lflag} = 0 ]]; then 
             ldlist[$((chs-1))]="$loader"; lddlist[$((chs-1))]=${dlist[$((chs-1))]}
        fi

    if [[ $ch1 -le $sata_lines ]]; then
            check=$( echo "${screen_buffer}" | grep "$ch1)   +" )
            if [[ "${check}" = "" ]]; then
        screen_buffer=$( echo  "$screen_buffer" | sed "s/$ch1) ...  /$ch1)   +  /" )
        mlist[$((ch1))]="sat:true"
            fi
    
    else

        check=$( echo "${usb_screen_buffer}" | grep "$ch1)   +" )
            if [[ "${check}" = "" ]]; then
        usb_screen_buffer=$( echo  "$usb_screen_buffer" | sed "s/$ch1) ...  /$ch1)   +  /" )
        mlist[$((ch1))]="usb:true"
            fi
    fi

  else

     if [[ $ch1 -le $sata_lines ]]; then   
            check=$( echo "${screen_buffer}" | grep "$ch1) ..." )
           if [[ ! "${check}" = "" ]]; then 
        screen_buffer=$( echo  "$screen_buffer" | sed "s/$ch1)   +  /$ch1) ...  /" )
        mlist[$((ch1))]="sat:false"
            fi
     else

           check=$( echo "${usb_screen_buffer}" | grep "$ch1) ..." )
           if [[ ! "${check}" = "" ]]; then 
        usb_screen_buffer=$( echo  "$usb_screen_buffer" | sed "s/$ch1)   +  /$ch1) ...  /" )
        mlist[$((ch1))]="usb:false"
            fi
     fi 
  fi
let "num++"
let "var0--"
done
#############################

printf "\033[H"
printf "\r\033[8f"
echo  "$screen_buffer"
COLOR_HEAD sata
if [[ ! $usb_lines = 0 ]]; then

                printf '\n     '${cm[dots_line2]}''
                if [[ $CheckLoaders = 0 ]]; then
	            printf '.%.0s' {1..32} 
                printf ''${cm[head_usb]}' USB '${cm[dots_line2]}''
                printf '.%.0s' {1..31}
                else
                printf '.%.0s' {1..39}
                printf ''${cm[head_usb]}' USB '${cm[dots_line2]}''
                printf '.%.0s' {1..38}
                fi
                printf ''${cm[clr]}'\n     '

echo "${usb_screen_buffer}"
COLOR_HEAD usb
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
MEFIScA_DATA
}
################################### конец функции обновления списка подключенных  на экране ##################################

ADVANCED_MENUE(){ order=3; UPDATELIST; GETKEYS; }

########################### определение функции ввода по 2 байта #########################
READ_TWO_SYMBOLS(){
unset pos_corr; pos_corr=$1; if [[ $pos_corr = "" ]]; then pos_corr=50; fi
if [[ ! $order = 3 ]]; then order=4; fi 
choice1="±"; choice="±";
printf "\033[?25h"
while [[ $choice1 = "±" ]]
do
printf '\n'
printf '                                                                                \n'
printf '                                                                                '
printf "\r\n\033[3A\033['$pos_corr'C"
IFS="±"; read   -n 1 -t 1  choice1 ; unset IFS 
if [[ $choice1 = "" ]]; then printf "\033[1A"; choice1="±"; else choice=$choice1; TRANS_READ; choice1=$choice; fi
if [[ $choice1 = [0-9] ]]; then choice=${choice1}; break
            else
        if [[ ! $order = 3 ]]; then
            if [[ $choice1 = [uUqQeEiIvVsSoOaApPlL] ]]; then choice=${choice1}; break; fi
                    else
             if [[ $choice1 = [qQcCoOsSiIvVWpPlLDmMeE] ]]; then choice=${choice1}; break; fi
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
if [[ $loc = "ru" ]]; then
printf '\n'${cm[curs_str]}'  ! введите вторую цифру или нажмите <Enter> '${cm[clr]}''
else
printf '\n'${cm[curs_str]}'  ! Press the second digit or press <Enter>  '${cm[clr]}''
fi
printf "\r\n\033[4A\033['$pos_corr'C"$choice


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
######### транслция двойных кодов в управляющие символы для русского украинского и белорусского #########################################

SET_CODE_BASE(){
current_language=$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources | egrep -w 'KeyboardLayout Name' | sed -E 's/.+ = "?([^"]+)"?;/\1/')
if [[ "${current_language}" = "Russian - Phonetic" ]]; then
    code_base=( d18f d0af d0b5 d095 d183 d0a3 d0b8 d098 d0be d09e d0b0 d090 d181 d0a1 d186 d0a6 d0b2 d092 d0a8 d0bf d09f d0bb d09b d0bc d09c)
    sym_base=( q Q e E u U i I o O a A s S c C v V W p P l L m M)
elif [[ "${current_language}" = "RussianWin" ]] || [[ "${current_language}" = "Russian" ]] || [[ "${current_language}" = "Ukrainian-PC" ]] || [[ "${current_language}" = "Ukrainian" ]] || [[ "${current_language}" = "Byelorussian" ]]; then
    code_base=( d0b9 d099 d0bc d09c d0b3 d093 d188 d0a8 d189 d0a9 d184 d0a4 d18b d0ab d183 d0a3 d181 d0a1 d0b8 d098 d196 d086 d19e d08e d0a6 d0b7 d097 d0b4 d094 d18c d0ac) 
    sym_base=( q Q v V u U i I o O a A s S e E c C s S s S o O W p P l L m M)
else
    code_base=()
    sym_base=()
fi

}

TRANS_READ(){
   codes=$(echo $choice | hexdump | head -n1 | cut -f2 -d ' ')
   for i in d0 d1
   do
   if [[ $codes = $i ]]; then
        read -rsn1 symsym; 
        codes+=$(echo $symsym | hexdump | head -n1 | cut -f2 -d ' ')
        SET_CODE_BASE
        for i in ${!code_base[@]}; do if [[ $codes = ${code_base[i]} ]]; then choice=${sym_base[i]}; break; fi; done
        break
   fi
   done
}
################ информация об EFI с этой устаноленной системой ############################
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
#############################################################################################################################################
STORE_CONFIG_PATH(){
volIDstring=$(diskutil info $1 | grep "Volume UUID" | awk '{print $NF}')
if [[ ! $volIDstring = "" ]]; then plutil -replace OpenedPlistPartUUID -string "${volIDstring}" "${CONFPATH}" ; UPDATE_CACHE; fi
}

REM_STORED_PATH(){ lopUUID=""; plutil -remove OpenedPlistPartUUID "${CONFPATH}" >>/dev/null 2>/dev/null; UPDATE_CACHE; }

SHOW_MSG(){
osascript -e 'display dialog '"${error_message}"' '"${icon_string}"' buttons { "OK"} default button "OK" giving up after 3' >/dev/null 2>/dev/null
}

WARNING_NO_PARTS(){
if [[ $loc = "ru" ]]; then
error_message='"Диск с запрошенным config.plist\nСкорее всего был отключен от Mac"'        
else
error_message='"The disk with the requested config.plist\nmost likely was disconnected from this Mac"'        
fi
SHOW_MSG &
}



OPEN_PLIST(){
sl=5; choice="±"; ldrname=""; line_pointer=$((10+${#dlist[@]}+$(if [[ ! ${#usb_lines} = 0 &&  ! ${usb_lines} = 0 ]]; then echo 3; else echo 0 ; fi)))
if [[ $ShowKeys = 1 ]]; then
    printf '\r\033['$line_pointer'f'
    	     if [[ $loc = "ru" ]]; then
	printf '\n'${cm[cl_O]}'      O  '${cm[kh_str]}'-  открыть первый по списку config.plist OpenCore                '${cm[clr]}'\n'
	printf ''${cm[cl_C]}'      C  '${cm[kh_str]}'-  открыть первый по списку config.plist Сlover                  '${cm[clr]}'\n'
    printf ''${cm[curs_num_1]}'      0'${cm[kh_str]}'-'${cm[curs_num_2]}''$schs''${cm[kh_str]}' - открыть config.plist на разделе (томе) номер...               '${cm[clr]}'\n'
    printf ''${cm[cl_L]}'      L  '${cm[kh_str]}'-  открыть config.plist который был открыт ранее.                '${cm[clr]}'\n'
    if [[ ${ch} -le 9 ]]; then
	printf ''${cm[cl_ast]}'      ** '${cm[cl_str]}'возврат в главное меню через 5 сек или любой клавишей.           '${cm[clr]}'\n\n\n'
    else
    printf '                                                                 \n\n\n'
    fi 
			else
	printf '\n'${cm[cl_O]}'      O  '${cm[kh_str]}'-  open the first on the list OpenCore config.plist            '${cm[clr]}'\n' 
	printf ''${cm[cl_C]}'      С  '${cm[kh_str]}'-  open the first on the list Clover config.plist              '${cm[clr]}'\n'
    printf ''${cm[curs_num_1]}'      0'${cm[kh_str]}'-'${cm[curs_num_2]}''$schs''${cm[kh_str]}' - open config.plist on partition (volume) number...           '${cm[clr]}'\n'
    printf ''${cm[cl_L]}'      L  '${cm[kh_str]}'- open the config.plist that was last opened                   '${cm[clr]}'\n'
    if [[ ${ch} -le 9 ]]; then
	printf ''${cm[cl_ast]}'      ** '${cm[cl_str]}'return to the main menu after 5 seconds or by any key.         '${cm[clr]}'\n\n\n'
    else
    printf '                                                                 \n\n\n'
    fi 
	     fi
    line_pointer=$((line_pointer+3))
fi
line_pointer=$((line_pointer+3))
if [[ ${ch} -le 9 ]]; then cur_pos=57; else cur_pos=48; fi
printf '\r\033['$line_pointer'f'
for i in 1 2; do printf '                                                                                \n'; done
    if [[ $loc = "ru" ]]; then
        if [[ ${ch} -le 9 ]]; then
printf '\r  '${cm[curs_str]}'Открыть '${cm[cl_conf]}'config.plist'${cm[curs_str]}' ( номер EFI, '${cm[cl_O]}'O'${cm[curs_str]}', '${cm[cl_C]}'C'${cm[curs_str]}', '${cm[cl_L]}'L'${cm[curs_str]}' или Enter ):   '${cm[clr]}'' ; printf '                     \n'
        else
printf '\r  '${cm[curs_str]}'Открыть '${cm[cl_conf]}'config.plist'${cm[curs_str]}' ( номер EFI, '${cm[cl_O]}'O'${cm[curs_str]}', '${cm[cl_C]}'C'${cm[curs_str]}', '${cm[cl_L]}'L'${cm[curs_str]}' ):   '${cm[clr]}'' ; printf '                               \n'
        fi
	else
         if [[ ${ch} -le 9 ]]; then
printf '\r  '${cm[curs_str]}'Edit '${cm[cl_conf]}'config.plist'${cm[curs_str]}' - ( EFI number, '${cm[cl_O]}'O'${cm[curs_str]}', '${cm[cl_C]}'C'${cm[curs_str]}', '${cm[cl_L]}'L'${cm[curs_str]}' или Enter ):   '${cm[clr]}'' ; printf '                     \n'
         else cur_pos=50
printf '\r    '${cm[curs_str]}'Edit '${cm[cl_conf]}'config.plist'${cm[curs_str]}' - ( EFI number, '${cm[cl_O]}'O'${cm[curs_str]}', '${cm[cl_C]}'C'${cm[curs_str]}', '${cm[cl_L]}'L'${cm[curs_str]}' ):   '${cm[clr]}'' ; printf '                             \n'
        fi
    fi
for i in 1 2 3; do printf '                                                                                \n'; done
printf "\033[4A\r\033['$cur_pos'C"
while true; do
    if [[ ${ch} -le 9 ]]; then
    IFS="±"; read -rn1 -t1 choice; unset IFS; sym=2; let "sl--"; TRANS_READ
    else READ_TWO_SYMBOLS $cur_pos; fi; onekey=$choice; if [[ ! $choice = "±" ]]; then choice="P"; fi
    if [[ $onekey = 0 ]]; then break; fi; if [[ ! $(echo $onekey | egrep -o "[0-9]{1,3}") = "" ]]; then keynum=$(echo $onekey | egrep -o "[0-9]{1,3}"); onekey="number"; fi
    case $onekey in 
     number)  onekey=$keynum
              if [[ ${onekey} -ge 0 && ${onekey} -lt $ch ]]; then chs=$onekey; MOUNTS 
              if [[ $mcheck = "Yes" ]]; then sleep 0.5; if open "$vname"/EFI/*/config.plist >/dev/null 2>/dev/null; then STORE_CONFIG_PATH ${string} ; fi; fi; fi; break ;;
     [cCoO])  if [[ $onekey = [cC] ]]; then ldrname="Clover"; else ldrname="OpenCo"; fi
              if [[ $mefisca = 1 ]]; then 
                    for ii in ${!dlist[@]}; do if [[ "${ldlist[$ii]::6}" = "$ldrname" ]]; then chs=$((ii+1)); MOUNTS              
                    if [[ $mcheck = "Yes" ]]; then sleep 0.8; if open "$vname"/EFI/*/config.plist >/dev/null 2>/dev/null; then STORE_CONFIG_PATH ${dlist[ii]} ; fi; break; fi; fi; done
              else
                  printf '                               '; if [[ $ldrname = "Clover" ]]; then SPIN_FCLOVER; else SPIN_OC; fi
                  if [[ $loader_found = 1 ]]; then sleep 0.8; if open "$vname"/EFI/*/config.plist >/dev/null 2>/dev/null; then STORE_CONFIG_PATH ${string} ; fi; fi
              fi
              ldrname=""; break ;;
       [lL])  lopUUID=$(echo "$MountEFIconf"| grep -A1 "OpenedPlistPartUUID</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/')
              if [[ ! ${lopUUID} = "" ]]; then
                BSDname=$(diskutil info ${lopUUID} | grep "Device Identifier:" | awk '{print $NF}')
                    if [[ $BSDname = "" ]]; then WARNING_NO_PARTS; REM_STORED_PATH; else
                        for ii in ${!dlist[@]}; do if [[ ${dlist[ii]} = $BSDname ]]; then chs=$((ii+1)); MOUNTS
                        if [[ $mcheck = "Yes" ]]; then sleep 0.8; open "$vname"/EFI/*/config.plist >/dev/null 2>/dev/null; break; fi; fi; done
                    fi
                fi ; break ;;
    esac
    if [[ $sl -lt 1 ]] || [[ ! $choice = "±" ]]; then break; fi
done
}
###########################################################################################################################################
SHOW_DEBUG(){ 
if $DEBUG; then
ret_line=$((18+${#dlist[@]}+$(if [[ ! ${#usb_lines} = 0 &&  ! ${usb_lines} = 0 ]]; then echo 3; else echo 0 ; fi)))
if [[ $ShowKeys = 0 ]]; then let "ret_line=ret_line-3"; fi
posit_corr=$(((col-22-${#logfile})/2)); if [[ $posit_corr -lt 0 ]]; then posit_corr=0; fi
printf '\r\033['$lines'f\e['$posit_corr'C\e[38;5;220mDEBUG is ON • log: >> '"${logfile::$((col-1))}"'\e[0m'
printf '\r\033['$ret_line'f\033[48C '
fi
}
############################## таймер возврата из вспомогательного в главное меню ########################################################## 
ARMM_TIMER(){ if [[ $order = 3 ]]; then armm=$((armm-1)); if [[ $armm -lt 1 ]]; then choice="I"; fi; fi; }
#############################################################################################################################################
# Определение функции ожидания и фильтрации ввода с клавиатуры
GETKEYS(){
unset choice
while [[ ! ${choice} =~ ^[0-9uUqQ]+$ ]]; do
if [[ $order = 2 ]]; then                                               
order=0
fi
printf "\r\n\033[1A"
if [[ $order = 3 ]]; then armm=5 #############  значение задержки для таймера автовозврата в главное меню в секундах ########################
    let "schs=$ch-1"
    if [[ $loc = "ru" ]]; then
printf ''${cm[curs_str]}'  Введите число от '${cm[curs_num_1]}'0'${cm[curs_str]}' до '${cm[curs_num_2]}''$((schs+1))' '${cm[curs_str]}'( '${cm[cl_P]}'P'${cm[curs_str]}','${cm[cl_O]}'O'${cm[curs_str]}','${cm[cl_C]}'C'${cm[curs_str]}','${cm[cl_S]}'S'${cm[curs_str]}','${cm[cl_I]}'I'${cm[curs_str]}'  или  '${cm[cl_Q]}'Q'${cm[curs_str]}' ):   '${cm[clr]}'' ; printf '                           '
			else
printf ''${cm[curs_str]}'   Enter a num from '${cm[curs_num_1]}'0'${cm[curs_str]}' to '${cm[curs_num_2]}''$((schs+1))' '${cm[curs_str]}'( '${cm[cl_P]}'P'${cm[curs_str]}','${cm[cl_O]}'O'${cm[curs_str]}','${cm[cl_C]}'C'${cm[curs_str]}','${cm[cl_S]}'S'${cm[curs_str]}','${cm[cl_I]}'I'${cm[curs_str]}'  or  '${cm[cl_Q]}'Q'${cm[curs_str]}' ):   '${cm[clr]}'' ; printf '                          '
    fi
        else
            let "schs=$ch-1"
	if [ $loc = "ru" ]; then
let "schs=$ch-1"
printf ''${cm[curs_str]}'  Введите число от '${cm[curs_num_1]}'0'${cm[curs_str]}' до '${cm[curs_num_2]}''$((schs+1))''${cm[curs_str]}' ( '${cm[cl_P]}'P'${cm[curs_str]}','${cm[cl_U]}'U'${cm[curs_str]}','${cm[cl_E]}'E'${cm[curs_str]}','${cm[cl_A]}'A'${cm[curs_str]}','${cm[cl_S]}'S'${cm[curs_str]}','${cm[cl_I]}'I'${cm[curs_str]}' или '${cm[cl_Q]}'Q'${cm[curs_str]}' ):  '${cm[clr]}''; printf '                            '
			else
printf ''${cm[curs_str]}'   Enter a num from '${cm[curs_num_1]}'0'${cm[curs_str]}' to '${cm[curs_num_2]}''$((schs+1))''${cm[curs_str]}' ( '${cm[cl_P]}'P'${cm[curs_str]}','${cm[cl_U]}'U'${cm[curs_str]}','${cm[cl_E]}'E'${cm[curs_str]}','${cm[cl_A]}'A'${cm[curs_str]}','${cm[cl_S]}'S'${cm[curs_str]}','${cm[cl_I]}'I'${cm[curs_str]}' or '${cm[cl_Q]}'Q'${cm[curs_str]}' ):  '${cm[clr]}'';  printf '                         '
	fi
fi
printf '\n\n'
printf '                                                                                \n'
printf '                                                                                '
printf "\r\n\033[2A\033[49C"
printf "\033[3A"
if [[ ${ch} -le 9 ]]; then
printf "\033[?25h"
choice="±"
printf '\033[1B'
SHOW_DEBUG
while [[ $choice = "±" ]]
do
IFS="±"; read -rn1 -t 1 choice ; unset IFS; sym=2; ARMM_TIMER
if [[ $choice = "" ]]; then printf "\033[?25l"'\033[1A'"\033[?25h"; else TRANS_READ; fi
CHECK_HOTPLUG_DISKS
CHECK_HOTPLUG_PARTS
done
SET_INPUT "message"
else
printf '\033[1B'
SHOW_DEBUG
READ_TWO_SYMBOLS; sym=2
fi
printf "\033[?25l\033[1D "
if [[ ${choice} = $ch ]]; then if [[ $CheckLoaders = 1 ]]; then SPIN_FLOADERS; UPDATELIST; choice=0; else choice="V"; fi; fi
if [[ ! ${choice} =~ ^[0-9]+$ ]]; then
if [[ ! $order = 3 ]]; then
if [[ ! $choice =~ ^[0-9uUqQeEiIvVsSaApP]$ ]]; then  unset choice; fi
if [[ ${choice} = [sS] ]]; then cd "$(dirname "$0")"; if [[ -f setup ]] || [[ -f setup.sh ]]; then SAVE_EFIes_STATE; fi; if [[ -f setup ]]; then ./setup -r "${ROOT}"; else bash ./setup.sh -r "${ROOT}" 2>/dev/null; fi;  REFRESH_SETUP; choice="0"; order=4; fi; CHECK_RELOAD; if [[ $rel = 1 ]]; then  EXIT_PROGRAM; fi
if [[ ${choice} = [uU] ]]; then unset nlist; UNMOUNTS; choice="R"; order=4; fi
if [[ ${choice} = [qQ] ]]; then choice=$ch; if [[ $mefisca = 1 ]]; then touch "${SERVFOLD_PATH}"/MEFIScA/clientDown; DBG "CLIENT DONE"; fi; fi
if [[ ${choice} = [eE] ]]; then GET_SYSTEM_EFI; let "choice=enum+1"; fi
if [[ ${choice} = [iI] ]]; then ADVANCED_MENUE; fi
if [[ ${choice} = [aA] ]]; then cd "$(dirname "$0")"; if [[ -f setup ]]; then ./setup -a "${ROOT}"; else bash ./setup.sh -a "${ROOT}" 2>/dev/null; fi;  REFRESH_SETUP; choice="0"; order=4; fi
if [[ ${choice} = [vV] ]]; then SHOW_VERSION ; order=4; UPDATELIST; fi
if [[ ${choice} = [pP] ]]; then OPEN_PLIST; order=4; UPDATELIST; if [[ ${ch} -gt 9 && $hotplug = 1 ]]; then choice=0; break; fi; fi
else
if [[ ! $choice =~ ^[0-9qQcCoOsSiIvVWpPDmMeE]$ ]]; then unset choice; fi
if [[ ${choice} = [sS] ]]; then cd "$(dirname "$0")"; if [[ -f setup ]] || [[ -f setup.sh ]]; then SAVE_EFIes_STATE; fi; if [[ -f setup ]]; then ./setup -r "${ROOT}"; else bash ./setup.sh -r "${ROOT}"; fi;  REFRESH_SETUP; choice="0"; order=4; fi; CHECK_RELOAD; if [[ $rel = 1 ]]; then  EXIT_PROGRAM; fi
if [[ ${choice} = [oO] ]]; then  printf '                               '; SPIN_OC; choice="0"; order=4; fi
if [[ ${choice} = [cC] ]]; then  printf '                               '; SPIN_FCLOVER; choice="0"; order=4; fi
if [[ ${choice} = [qQ] ]]; then choice=$ch; if [[ $mefisca = 1 ]]; then touch "${SERVFOLD_PATH}"/MEFIScA/clientDown; DBG "CLIENT DONE"; fi; fi
if [[ ${choice} = [iI] ]]; then  order=4; UPDATELIST; fi
if [[ ${choice} = [vV] ]]; then SHOW_VERSION ; order=4; UPDATELIST; fi
if [[ ${choice} = [wW] ]]; then MEFIScA_DATA; EASYEFI_RESTART_APP; fi
if [[ ${choice} = [mM] ]]; then CHECK_CM; if [[ $cm_check = 0 ]]; then COLOR_MODE; mean="Yes"; else mean="No"; unset cm; if [[ $theme = "built-in" ]]; then CUSTOM_SET; else SET_SYSTEM_THEME; fi; fi; plutil -replace GUIcolorMode -bool $mean "${CONFPATH}"; order=4; choice=0; fi
if [[ ${choice} = [eE] ]]; then if [[ -f "${ROOT}"/cm_edit ]]; then printf "\e[0m\033[?25l"; if [[ $cm_check = 0 ]]; then presetName="$current"; fi; echo "$presetName" > "${SERVFOLD_PATH}"/presetName; "${ROOT}"/cm_edit; UPDATE_CACHE; CHECK_CM; choice="0"; order=4; fi; fi
if [[ ${choice} = [D] ]];  then if $DEBUG; then mean="No"; DBG "CLIENT: DEBUG DISABLED"; DEBUG="false"; else mean="Yes"; DEBUG=true; DBG "CLIENT: DEBUG ENABLED"; fi;  plutil -replace DEBUG -bool $mean "${CONFPATH}"; UPDATE_CACHE; order=4; UPDATELIST; fi
if [[ ${choice} = [pP] ]]; then OPEN_PLIST; order=4;  UPDATELIST; if [[ ${ch} -gt 9 && $hotplug = 1 ]]; then choice=0; break; fi; fi
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

let "num=chs-1"
pnum=${nlist[num]}
string=`echo ${dlist[$pnum]}`
strng0=${string}
mcheck=`df | grep ${string}`; if [[ ! $mcheck = "" ]]; then mcheck="Yes"; fi 

if [[ ! $mcheck = "Yes" ]]; then wasmounted=0; DO_MOUNT; if [[ $mcheck = "Yes" ]]; then order=0; UPDATELIST; fi; else wasmounted=1; fi

string=${strng0}; mcheck=`df | grep ${string}`; if [[ ! $mcheck = "" ]]; then mcheck="Yes"; fi
vname=`df | egrep ${string} | sed 's#\(^/\)\(.*\)\(/Volumes.*\)#\1\3#' | cut -c 2-`
if [[ $mcheck = "Yes" ]]; then
    if [[ "${OpenFinder}" = "1" ]] || [[ "${wasmounted}" = "1" ]]; then 
        if [[ $ldrname = "" ]];then open "$vname"; else open "$vname/EFI"; fi
    fi
fi
 nogetlist=1

}
# Конец определения MOUNTS #################################################################

############################# корректировка списка разделов с загрузчиками ######################################### 
CORRECT_LOADERS_LIST(){

           temp_lddlist=(); temp_ldlist=(); temp_mllist=(); temp_oc_list=()

    for k in ${!dlist[@]}; do
        for y in ${!lddlist[@]}; do
        if [[ ${dlist[k]} = ${lddlist[y]} ]]; then
                temp_ldlist[k]=${ldlist[y]}
                temp_lddlist[k]=${lddlist[y]}
                temp_mllist[k]=${mounted_loaders_list[y]}
                temp_oc_list[k]=${oc_list[y]}
                break
        fi
        done
    done
    
    ldlist=(); lddlist=(); mounted_loaders_list=(); oc_list=()
    for k in ${!temp_lddlist[@]}; do lddlist[k]=${temp_lddlist[k]}; done
    for k in ${!temp_ldlist[@]}; do ldlist[k]=${temp_ldlist[k]}; done
    for k in ${!temp_mllist[@]}; do mounted_loaders_list[k]=${temp_mllist[k]}; done
    for k in ${!temp_oc_list[@]}; do oc_list[k]=${temp_oc_list[k]}; done

synchro=0
}

GET_LOADERS_FROM_NEW_PARTS(){
if [[ $mefisca = 1 ]] && [[ ! ${#new_remlist[@]} = 0 ]]; then
    for i in ${!dlist[@]}; do pnum=${nlist[i]}; string=${dlist[$pnum]}
        for z in ${new_remlist[@]}; do 
        if [[ $string = $z ]] && [[ $(df | grep ${string}) = "" ]]; then
            DO_MOUNT
            if [[ ! $(df | grep ${string}) = "" ]]; then mcheck="Yes"
            FIND_LOADERS
            if [[ ! ${loader} = "" ]];then ldlist[pnum]="$loader"; lddlist[pnum]=${dlist[pnum]}; fi
            diskutil quiet  umount force /dev/${string}
            fi
        fi
        done
    done
fi
}
#   mrel - флаг перезапуска из функции setup (reload), mfupd - флаг выполненного обновления, rst - флаг перезагрузки (restart), no_ret - флаг не возвращаться в EasyEFI mode
CLIENT_READY(){ if [[ $mefisca = 1 && $mrel = 0 ]]; then if [[ $rst = 0  || $mfupd = 1 ]]; then touch "${SERVFOLD_PATH}"/MEFIScA/clientReady; DBG "CLIENT Ready"; else rm -f "${SERVFOLD_PATH}"/MEFIScA/clientRestart; DBG "CLIENT does not want to be Ready"; fi; fi; }

################### ожидание завершения монтирования разделов при хотплаге #################
#############################################################################################
# Начало основноо цикла программы ###########################################################
############################ MAIN MAIN MAIN ################################################
GET_USER_PASSWORD
GET_CONFIG_HASHES
CHECK_MEFIScA
CLIENT_READY
STARTUP_FIND_LOADERS

chs=0; nogetlist=0; ldrname=""

CHECK_AUTOUPDATE
if [[ ${AutoUpdate} = 1 ]] && [[ -f ../../../MountEFI.app/Contents/Info.plist ]]; then 
                    if [[ -f ~/Library/Application\ Support/MountEFI/AutoUpdateLock.txt ]] && [[ "$(($(date +%s)-$(cat ~/Library/Application\ Support/MountEFI/AutoUpdateLock.txt)))" -gt "60" ]]; then
                    rm -f ~/Library/Application\ Support/MountEFI/AutoUpdateLock.txt
                    fi
                    START_AUTOUPDATE &
fi

while [ $chs = 0 ]; do
if [[ ! $nogetlist = 1 ]]; then
        clear && printf '\e[3J'
        GET_LOADERS
        if [[ ! $CheckLoaders = 0 ]]; then col=94; ldcorr=14; else col=80; ldcorr=2;  fi 
        clear && printf '\e[8;'${lines}';'$col't' && printf '\e[3J' && printf "\033[H"

	    ######PRINT_HEADER
    if [[ $loc = "ru" ]]; then
        if [[ $CheckLoaders = 0 ]]; then
            printf '\n'${cm[head_ast]}'*******      '${cm[head_str]}'Программа монтирует EFI разделы в Mac OS ('${cm[head_X]}'X'${cm[head_str]}'.'${cm[head_os]}'11 '${cm[head_str]}'- '${cm[head_X]}'XI'${cm[head_str]}'.'${cm[head_os]}'2'${cm[head_str]}')      '${cm[head_ast]}'*******'${cm[clr]}'\n'
        else
            printf '\n'${cm[head_ast]}'*********           '${cm[head_str]}'Программа монтирует EFI разделы в Mac OS ('${cm[head_X]}'X'${cm[head_str]}'.'${cm[head_os]}'11 '${cm[head_str]}'- '${cm[head_X]}'XI'${cm[head_str]}'.'${cm[head_os]}'2'${cm[head_str]}')           '${cm[head_ast]}'*********'${cm[clr]}'\n'
        fi
    else
        if [[ $CheckLoaders = 0 ]]; then
            printf '\n'${cm[head_ast]}'*******    '${cm[head_str]}'This program mounts EFI partitions on Mac OS ('${cm[head_X]}'X'${cm[head_str]}'.'${cm[head_os]}'11 '${cm[head_str]}'- '${cm[head_X]}'XI'${cm[head_str]}'.'${cm[head_os]}'2'${cm[head_str]}')    '${cm[head_ast]}'*******'${cm[clr]}'\n'
        else
            printf '\n'${cm[head_ast]}'*********         '${cm[head_str]}'This program mounts EFI partitions on Mac OS ('${cm[head_X]}'X'${cm[head_str]}'.'${cm[head_os]}'11 '${cm[head_str]}'- '${cm[head_X]}'XI'${cm[head_str]}'.'${cm[head_os]}'2'${cm[head_str]}')         '${cm[head_ast]}'*********'${cm[clr]}'\n'
        fi
	fi
        ####################

fi
        unset nlist
        declare -a nlist
        GETARR

 if [[ -f ~/.disk_list.txt ]]; then temp_dlist=( $( cat ~/.disk_list.txt ) ); rm -f  ~/.disk_list.txt; if [[ ! ${dlist[@]} = ${temp_dlist[@]} ]]; then CORRECT_LOADERS_LIST; fi; fi

 if [[ ! $nogetlist = 1  ]]; then if [[ ${synchro} = 1 ]] || [[ ${synchro} = 3 ]]; then 

    ######## WAIT_SYNCHRO
new_remlist=()
if [[ ${synchro} = 3 ]]; then new_rmlist=( ${rmlist[@]} ); sleep 0.25; else
new_rmlist=( $( echo ${rmlist[@]} ${past_rmlist[@]} | tr ' ' '\n' | sort | uniq -u | tr '\n' ' ' ) )
if [[ ! ${#new_rmlist[@]} = 0 ]]; then
    init_time="$(date +%s)"; usblist=(); warning_sent=0
    for z in ${dlist[@]}; do for y in ${new_rmlist[@]}; do if [[ "$y" = "$( echo $z | rev | cut -f2-3 -d"s" | rev )" ]]; then usblist+=( $z ); break; fi; done; done
    new_remlist=(${usblist[@]})
    if [[ ! ${#usblist[@]} = 0 ]]; then
        sleep 0.1
        realEFI_list=($(ioreg -c IOMedia -r | tr -d '"|+{}\t' | egrep -A 22 "<class IOMedia," | grep -ib22  "EFI system partition" | grep "BSD Name" | egrep -o "disk[0-9]{1,3}s[0-9]{1,3}" | tr '\n' ' '))
        if [[ ! ${#realEFI_list[@]} = 0 ]]; then
        temp_usblist=()
        for z in ${usblist[@]}; do for y in ${!realEFI_list[@]}; do match=0; if [[ ${z} = ${realEFI_list[y]} ]]; then match=1; break; fi; done; if [[ ${match} = 0 ]]; then temp_usblist+=(${z}); fi; done
        usblist=(${temp_usblist[@]})

        fi
    fi
    if [[ ! ${#usblist[@]} = 0 ]]; then
        while true; do
            mounted_list=( $( df | cut -f1 -d" " | grep disk | cut -f3 -d/ | tr '\n' ' ') )
            usb_mounted_list=()
            for z in ${mounted_list[@]}; do for y in ${usblist[@]}; do if [[ ${z} = ${y} ]]; then usb_mounted_list+=( ${z} ); break; fi; done; done
            diff_usb=( $( echo ${usblist[@]} ${usb_mounted_list[@]} | tr ' ' '\n' | sort | uniq -u | tr '\n' ' ' ) )
            if [[ ${#diff_usb[@]} = 0 ]]; then break; fi
            exec_time="$(($(date +%s)-init_time))"
            if [[ ${exec_time} -ge 3 ]] && [[ ${warning_sent} = 0 ]]; then 
            #### WARNING_SYNCHRO
                        SET_TITLE
                        if [[ $loc = "ru" ]]; then
                        echo 'SUBTITLE="ОЖИДАНИЕ ГОТОВНОСТИ РАЗДЕЛОВ ! ..."; MESSAGE=""' >> "${HOME}"/.MountEFInoty.sh
                        else
                        echo 'SUBTITLE="WAITING FOR COMPLETE MOUNTING !..."; MESSAGE=""' >> "${HOME}"/.MountEFInoty.sh
                        fi
                        DISPLAY_NOTIFICATION
            #################### 
            warning_sent=1; fi
            if [[ ${exec_time} -ge 36 ]]; then break; fi
            sleep 0.25
        done        
    fi
fi
fi
CORRECT_LOADERS_LIST
GET_LOADERS_FROM_NEW_PARTS
synchro=0
MOUNT_EFI_WINDOW_UP &
#######################

 fi; GETLIST; fi

    MEFIScA_DATA
	GETKEYS	

# Если нажата клавиша выхода из программы
if  [[ $chs = $ch ]]; then
clear

EXIT_PROGRAM
fi


# Монтировать раздел если он выбран (chs - номер в списке разделов)
if [[ ! ${chs} = 0 ]]; then 
MOUNTS;  chs=0
fi
done

# Конец основного цикла программы ####################################################################
########################################## END MAIN #################################################
exit

#!/bin/bash

#  Created by Андрей Антипов on 18.05.2022.#  Copyright © 2020 gosvamih. All rights reserved.

############################################################################## Mount EFI Color Mode Editor #######################################################################################################
prog_vers="1.9.0"
edit_vers="018"
serv_vers="026"
##################################################################################################################################################################################################################
# https://github.com/Andrej-Antipov/MountEFI/releases

#clear && printf '\e[8;45;94t' && printf '\e[3J' && printf "\033[H"

COLOR_MODE_EDITOR(){

CONFPATH="${HOME}/.MountEFIconf.plist"
SERVFOLD_PATH="${HOME}/Library/Application Support/MountEFI"

GET_LOCALE(){ 
    locale=`echo "$MountEFIconf" | grep -A 1 "Locale" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
    if [[ ! $locale = "ru" ]] && [[ ! $locale = "en" ]]; then loc=$(defaults read -g AppleLocale | cut -d "_" -f1); else loc="${locale}"; fi
if [[ $loc = "" ]]; then loc=`defaults read -g AppleLocale | cut -d "_" -f1`; fi  
}

SAVE_COLOR_MODE_PRESET(){
 if [[ $(echo "${MountEFIconf}" | grep -o "ColorModeData</key>") = "" ]]; then plutil -insert ColorModeData -xml  '<dict/>'   "${CONFPATH}"; fi
 cm_string=""; for i in ${!cm_ptr[@]}; do cm_string+="${cm[i]}+"; done; cm_string="${cm_string%?}"
 plutil -replace ColorModeData."$presetName" -string "$cm_string" "${CONFPATH}"
}

GET_COLOR_STRUCTURE(){
cm_ptr=( head_ast head_str head_os head_X head_sch head_upd_sch head_upd_sch_num head_upd_sch_br head_upd_sch_sp head_num_sch head_sch_br head_pls \
head_pls_str head_pls_qts head_sata head_usb dots_line1 dots_line2 dots_line3 num_sata num_sata_br num_usb num_usb_br mount_sata_pls mount_sata_dots \
mount_usb_pls mount_usb_dots dn_sata dn_usb dn_bsd_sata pn_size_sata pn_size_msata dn_bsd_usb pn_size_usb pn_size_musb sata_bsd sata_bsp usb_bsd usb_bsp \
rv0 kh_str curs_str curs_num_1 curs_num_2 ld_unrec ld_oc ld_cl ld_wn ld_rf ld_gb ld_oth cl_Q cl_P cl_U cl_E cl_A cl_S cl_I cl_V cl_C cl_O cl_L cl_W cl_M \
cl_E2 cl_ast cl_str cl_conf ld_srch ld_srch_sp ld_srch_bt rv1 rv2 rv3 clr dark)
for i in ${!cm_ptr[@]}; do export ${cm_ptr[i]}=$i; done
}

GET_COLOR_MODE_PRESET(){
cm=()
if [[ ! $(echo "${MountEFIconf}" | grep -o "ColorModeData</key>") = "" ]]; then
    i=1
    while true; do if [[ $(echo "${MountEFIconf}" | grep -A$((i-1))  "ColorModeData</key>" | grep -ow "</dict>" ) = "" ]]; then let "i++"; else break; fi; done
    if [[ ! $(echo "${MountEFIconf}" | grep -A$((i-1)) -o "$presetName</key>") = "" ]]; then
        cm_string=$(echo "${MountEFIconf}" | grep -A$i "ColorModeData</key>" | grep -ow -A1 "$presetName</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/')
        IFS='+'; cm=($cm_string); unset IFS
        GET_COLOR_STRUCTURE
    fi
fi
if [[ "${cm[@]}" = "" ]]; then INIT_COLOR_STRUCT; fi
}

INIT_COLOR_STRUCT(){ 
InterfaceStyle=$(defaults read -g AppleInterfaceStyle 2>/dev/null)
InitValue="\e[0m\e[97m"
if [[ "${presetName}" = "Basic" ]]; then if [[ $InterfaceStyle = "Dark" ]]; then InitValue="\e[0m\e[97m"; else InitValue="\e[0m\e[30m"; fi; fi
if [[ "${presetName}" = "Novel" ]]; then InitValue="\e[0m\e[38;5;237m"; fi
for i in ${!cm_ptr[@]}; do cm[i]="$InitValue"; done; cm[clr]="\e[0m"
}

SET_SYSTEM_THEME(){
profile=`echo "$MountEFIconf" |  grep -A 1 -e  "<key>ThemeProfile</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
if [[ "$profile" = "default" ]]; then
system_default=$(plutil -p /Users/$(whoami)/Library/Preferences/com.apple.Terminal.plist | grep "Default Window Settings" | tr -d '"' | cut -f2 -d '>' | xargs)
osascript -e 'tell application "Terminal" to  set current settings of window 1 to settings set "'"$system_default"'"'
else osascript -e 'tell application "Terminal" to  set current settings of window 1 to settings set "'"$profile"'"'
fi
}

GET_THEME(){
HasTheme=`echo "$MountEFIconf"  | grep -E "<key>Theme</key>" | grep -Eo Theme | tr -d '\n'`
if [[ $HasTheme = "Theme" ]]; then theme=`echo "$MountEFIconf"  |  grep -A 1 -e  "<key>Theme</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`; fi
}

set_font(){ osascript -e "tell application \"Terminal\" to set the font name of window 1 to \"$1\"" ; osascript -e "tell application \"Terminal\" to set the font size of window 1 to $2" ; }

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

GET_THEME_NAMES(){
plist=()
pcount=$(echo "$MountEFIconf" | grep  -e "<key>BackgroundColor</key>" | wc -l | xargs)
N0=0; N1=2; N2=3
for ((i=0; i<$pcount; i++)); do
plist+=( "$(echo "$MountEFIconf" | grep -A "$N1" Presets | awk '(NR == '$N2')' | sed -e 's/.*>\(.*\)<.*/\1/')" )
let "N1=N1+11"; let "N2=N2+11"; done
plist+=(Basic Grass Homebrew "Man Page" Novel Ocean Pro "Red Sands"  "Silver Aerogel"  "Solid Colors")
plcount=${#plist[@]}; file_list=""
for ((i=0;i<$plcount;i++)) do pl_string="${plist[i]}"; file_list+='"'${pl_string}'"' ; if [[ ! $i = $(($plcount-1)) ]]; then file_list+=","; fi ; done
}

WINDOW_UP(){
osascript -e 'tell application "Terminal" to set frontmost of (every window whose name contains "cm_edit")  to true' 2>/dev/null
osascript -e 'tell application "Terminal" to activate' 2>/dev/null
}

ASK_COLOR_MODE_PRESET(){
if [[ $loc = "ru" ]]; then
osascript <<EOD
tell application "System Events"    activate
set ThemeList to {$file_list}
set FavoriteThemeAnswer to choose from list ThemeList with title "Пресеты встроенных и системных тем."  with prompt "Выберите один:" OK button name {"Выбрать"} cancel button name {"Выход"}
end tell
EOD
else
osascript <<EOD
tell application "System Events"    activate
set ThemeList to {$file_list}
set FavoriteThemeAnswer to choose from list ThemeList with title "Presets for built-in and system themes." with prompt "Select one:" OK button name {"Select"} cancel button name {"Exit"}
end tell
EOD
fi
WINDOW_UP
}

REM_MODE(){ plutil -remove ColorModeData."$presetName" "${CONFPATH}" >> /dev/null 2>/dev/null; init=2; }

DELETE_OR_TAKE_NEW_PRESET(){
if [[ $loc = "ru" ]]; then
answer=$(osascript -e 'display dialog "Выберите что сделать? " '"${icon_string}"' buttons {"Удалить мод", "Сохранить и выбрать", "Отмена" } default button "Отмена" ' 2>/dev/null)
else
answer=$(osascript -e 'display dialog "Select what to do?" '"${icon_string}"' buttons {"Remove mode", "Save and choose", "Cancel" } default button "Cancel" ' 2>/dev/null)
fi
answer=$(echo "${answer}"  | cut -f2 -d':' )
         case "$answer" in
            "Удалить мод"           ) REM_MODE   ; init=2 ;;
            "Remove mode"           ) REM_MODE   ; init=2 ;;
            "Save and choose"       ) inputs="Q" ; init=3 ;;
            "Сохранить и выбрать"   ) inputs="Q" ; init=3 ;;
         esac
}

GET_SET_PRESET(){
if [[ ! $(echo "$presetName" | egrep -ow "Basic|Grass|Homebrew|Man Page|Novel|Ocean|Pro|Red Sands|Silver Aerogel|Solid Colors") = "" ]]; then
 osascript -e 'tell application "Terminal" to  set current settings of window 1 to settings set "'"$presetName"'"' 
else
    GET_CUSTOM_SET
osascript -e "tell application \"Terminal\" to set background color of window 1 to $current_background" 
osascript -e "tell application \"Terminal\" to set normal text color of window 1 to $current_foreground" 
osascript -e "tell application \"Terminal\" to set the font name of window 1 to \"$current_fontname\"" 
osascript -e "tell application \"Terminal\" to set the font size of window 1 to $current_fontsize"
fi
if [[ $(osascript -e 'tell application "Terminal" to get {properties of tab 1} of window 1' | tr  ',' '\n' | grep -A1 "selected:true" | egrep -o "size:[0-9]{1,2}" | cut -f2 -d:) -gt 12 ]]; then
 osascript -e "tell application \"Terminal\" to set the font size of window 1 to 12"
fi
clear && printf '\e[8;45;94t' && printf '\e[3J' && printf "\033[H"
}

GET_CUSTOM_SET(){
######## GET_CURRENT_SET
if [[ ! $presetName = "Init180061Mode" ]]; then 
preset_num=$(echo "$MountEFIconf"  | grep "<key>BackgroundColor</key>" | wc -l | bc)
current=`echo "$MountEFIconf" | grep -A$((preset_num*11)) -ow "<key>Presets</key>" | grep -A 1 -e "<key>${presetName}</key>" | grep key | sed -e 's/.*>\(.*\)<.*/\1/'`
current_background=`echo "$MountEFIconf"  | grep -A 10 -E "<key>$current</key>" | grep -A 1 "BackgroundColor" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
current_foreground=`echo "$MountEFIconf"  | grep -A 10 -E "<key>$current</key>" | grep -A 1 "TextColor" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
current_fontname=`echo "$MountEFIconf"  | grep -A 10 -E "<key>$current</key>" | grep -A 1 "FontName" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
current_fontsize=`echo "$MountEFIconf"  | grep -A 10 -E "<key>$current</key>" | grep -A 1 "FontSize" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
else
    current_background="{4064, 8941, 17101}"; current_foreground="{65535, 65535, 65535}"; current_fontname="SF Mono Regular"; current_fontsize="11"
fi
########################
}

CLR_UNUSED_STR(){
printf '\033[1f'; printf ' %.0s' {1..94}
printf '\033[3f'; printf ' %.0s' {1..94}
printf '\033[5f'; printf ' %.0s' {1..94}
printf '\033[7f'; printf ' %.0s' {1..94}
printf '\033[9f'; printf ' %.0s' {1..94}
printf '\033[11f'; printf ' %.0s' {1..94}
printf '\033[13f'; printf ' %.0s' {1..94}
printf '\033[20f'; printf ' %.0s' {1..94}
}


UPDATE_GUI(){
bbuf=(); bufStruct=()
for i in 0 1 2 3 4 5 6; do SET_STRUCT_1 $i; done
if [[ $loc = "ru" ]]; then
    StructHints[0]="звёздочки заголовка;текст строки заголовка;римская цифра версии мак ос;арабские цифры версии мак ос;"
    StructHints[1]="цифра 0;скобка после цифры;текст обновления списка разделов;кавычки вокруг +;плюс;текст строки обозначающий плюсом подключенные разделы;"
    StructHints[2]="первый сверху ряд точек;заголовок INT;"
    StructHints[4]="второй сверху ряд точек;заголовок USB;"
    StructHints[6]="третий сверху ряд точек;"
else
    StructHints[0]="Header asterisks;header line text;Roman numeral of the mac os version;Arabic numerals of the mac os version;"
    StructHints[1]="number 0;bracket after the number 0;text to update the EFI list ;quotes around +;a plus;text line explain that + means mounted;"
    StructHints[2]="The first row of dots from the top;INT header;"
    StructHints[4]="The second row of dots from the top;заголовок USB;"
    StructHints[6]="The third row of dots from the top;"
fi
UPDATE_BOTTOM
}

UPDATE_BOTTOM(){
for i in 7 8 9 10 11 12; do SET_STRUCT_2 $i; done
if [[ $loc = "ru" ]]; then
    case $hints in
    0)  StructHints[7]="буква E;цвет всех строк подсказок по клавишам;"
        StructHints[8]="буква U;цвет всех строк подсказок по клавишам;"    
        StructHints[9]="буква A;цвет всех строк подсказок по клавишам;"
        StructHints[10]="буква I;цвет всех строк подсказок по клавишам;"
        StructHints[11]="буква Q;цвет всех строк подсказок по клавишам;"
        StructHints[12]="строка перед кусором;первое число строки;второе число строки;буква P;буква S;"
        ;;
    1)  StructHints[7]="буква C;цвет всех строк подсказок по клавишам;буква W;цвет всех строк подсказок по клавишам;"
        StructHints[8]="буква O;цвет всех строк подсказок по клавишам;буква E;цвет всех строк подсказок по клавишам;"
        StructHints[9]="буква S;цвет всех строк подсказок по клавишам;буква M;цвет всех строк подсказок по клавишам;"
        StructHints[10]="буква P;цвет всех строк подсказок по клавишам;"
        StructHints[11]="буква V;цвет всех строк подсказок по клавишам;"
        StructHints[12]="строка перед кусором;первое число строки;второе число строки;буква I;"
        ;;
    2)  StructHints[7]="буква O;цвет всех строк подсказок по клавишам;"
        StructHints[8]="буква C;цвет всех строк подсказок по клавишам;"
        StructHints[9]="первое число строки;второе число строки;строка перед кусором;"
        StructHints[10]="буква L;цвет всех строк подсказок по клавишам;"
        StructHints[11]="звёздочки сноски;текст сноски;"
        StructHints[12]="строка перед кусором;текст config.plist;"
        ;;                
    esac
else
        case $hints in
    0)  StructHints[7]="letter E;color of all lines of key tips;"
        StructHints[8]="letter U;color of all lines of key tips;"    
        StructHints[9]="letter A;color of all lines of key tips;"
        StructHints[10]="letter I;color of all lines of key tips;"
        StructHints[11]="letter Q;color of all lines of key tips;"
        StructHints[12]="line before cursor;first line number;second line number;letter P;letter S;"
        ;;
    1)  StructHints[7]="letter C;color of all lines of key tips;letter W;color of all lines of key tips;"
        StructHints[8]="letter O;color of all lines of key tips;letter E;color of all lines of key tips;"
        StructHints[9]="letter S;color of all lines of key tips;letter M;color of all lines of key tips;"
        StructHints[10]="letter P;color of all lines of key tips;"
        StructHints[11]="letter V;color of all lines of key tips;"
        StructHints[12]="line before cursor;first line number;second line number;letter I;"
        ;;
    2)  StructHints[7]="letter O;color of all lines of key tips;"
        StructHints[8]="letter C;color of all lines of key tips;"
        StructHints[9]="first line number;second line number;line before cursor;"
        StructHints[10]="letter L;color of all lines of key tips;"
        StructHints[11]="footnote stars;footnote text;"
        StructHints[12]="line before cursor;config.plist;"
        ;;                
    esac
fi 
}

SET_STRUCT_1(){
if [[ $loc = "ru" ]]; then
    case $1 in
    0)  bbuf[0]=$(printf '\033[2;0f'${cm[head_ast]}'*********           '${cm[head_str]}'Программа монтирует EFI разделы в Mac OS  ('${cm[head_X]}'X'${cm[head_str]}'.'${cm[head_os]}'9 '${cm[head_str]}'- '${cm[head_X]}'XII'${cm[head_str]}'.'${cm[head_os]}'4'${cm[head_str]}')          '${cm[head_ast]}'*********'${cm[clr]}'')
        bufStruct[0]="2 head_ast,0 head_str,20 head_X,63 head_os,65"
        ;;
    1)  bbuf[1]=$(printf '\033[4;0f      '${cm[head_num_sch]}'0'${cm[head_sch_br]}')  '${cm[head_sch]}'повторить поиск разделов                            '${cm[head_pls_qts]}'"'${cm[head_pls]}'+'${cm[head_pls_qts]}'"'${cm[head_pls_str]}' - подключенные  '${cm[clr]}'          ')
        bufStruct[1]="4 head_num_sch,6 head_sch_br,7 head_sch,10 head_pls_qts,62 head_pls,63 head_pls_str,68"
        ;;
    2)  bbuf[2]=$(printf '\033[6;0f    '${cm[dots_line1]}.......................................${cm[head_sata]}' INT '${cm[dots_line1]}......................................${cm[clr]}'      ')
        bufStruct[2]="6 dots_line1,4 head_sata,44"
        ;;
    3)  drive="SanDisk SD8SBAT128G1122"; dsize="209.7"; dmsize="Mb"; bsd=0 ; bsp=1; ch=1
        bbuf[3]=$(printf '\033[8;0f    '${cm[num_sata]}"  "$ch''${cm[num_sata_br]}')'${cm[mount_sata_pls]}'   +   '${cm[dn_sata]}''"$drive"'                       '${cm[dn_bsd_sata]}disk${cm[sata_bsd]}${bsd}${cm[dn_bsd_sata]}s${cm[sata_bsp]}${bsp}'          '${cm[pn_size_sata]}''"$dsize${cm[pn_size_msata]} $dmsize"'     '${cm[clr]}' ')
        bufStruct[3]="8 num_sata,6 num_sata_br,7 mount_sata_pls,11 dn_sata,15 dn_bsd_sata,61 sata_bsd,65 sata_bsp,67 pn_size_sata,78 pn_size_msata,84"
        StructHints[3]="порядковые номера для sata;скобка после номера;плюс обозначения подключенных;имя диска или псевдоним;имя BSD диска;цифра номера диска;цифра номера раздела;размер раздела;измерение раздела (Mb/Gb);"
        ;;
    4)  bbuf[4]=$(printf '\033[10;0f    '${cm[dots_line2]}''.......................................''${cm[head_usb]}' USB '${cm[dots_line2]}......................................'      ')
        bufStruct[4]="10 dots_line2,4 head_usb,44"
        ;;
    5)  drive="TOSHIBA MK2555GSXF"; dsize=" 31.6"; dmsize="Gb"; bsd=1 ; bsp=2; ch=2
        bbuf[5]=$(printf '\033[12;0f    '${cm[num_usb]}"  "$ch''${cm[num_usb_br]}')'${cm[mount_usb_pls]}'   +   '${cm[dn_usb]}''"$drive"'                            '${cm[dn_bsd_usb]}disk${cm[usb_bsd]}${bsd}${cm[dn_bsd_usb]}s${cm[usb_bsp]}${bsp}'          '${cm[pn_size_usb]}''"$dsize${cm[pn_size_musb]} $dmsize"'     '${cm[clr]}' ')
        bufStruct[5]="12 num_usb,6 num_usb_br,7 mount_usb_pls,11 dn_usb,15 dn_bsd_usb,61 usb_bsd,65 usb_bsp,67 pn_size_usb,79 pn_size_musb,84"
        StructHints[5]="порядковые номера для USB;скобка после номера;плюс обозначения подключенных;имя диска или псевдоним;имя BSD диска;цифра номера диска;цифра номера раздела;размер раздела;измерение раздела (Mb/Gb);" 
        ;;
    6)  bbuf[6]=$(printf '\033[14;0f    '${cm[dots_line3]}...................................................................................${cm[clr]}'     ')
        bufStruct[6]="14 dots_line3,4"
        ;;
    esac
else
       case $1 in
    0)  bbuf[0]=$(printf '\033[2;0f'${cm[head_ast]}'*********         '${cm[head_str]}'This program mounts EFI partitions on Mac OS  ('${cm[head_X]}'X'${cm[head_str]}'.'${cm[head_os]}'9 '${cm[head_str]}'- '${cm[head_X]}'XII'${cm[head_str]}'.'${cm[head_os]}'4'${cm[head_str]}')        '${cm[head_ast]}'*********'${cm[clr]}'')
        bufStruct[0]="2 head_ast,0 head_str,18 head_X,65 head_os,67"
        ;;
    1)  bbuf[1]=$(printf '\033[4;0f      '${cm[head_num_sch]}'0'${cm[head_sch_br]}')  '${cm[head_sch]}'update EFI partitions list                               '${cm[head_pls_qts]}'"'${cm[head_pls]}'+'${cm[head_pls_qts]}'"'${cm[head_pls_str]}' - mounted  '${cm[clr]}'          ')
        bufStruct[1]="4 head_num_sch,6 head_sch_br,7 head_sch,10 head_pls_qts,67 head_pls,68 head_pls_str,73"
        ;;
    2)  bbuf[2]=$(printf '\033[6;0f    '${cm[dots_line1]}.......................................${cm[head_sata]}' INT '${cm[dots_line1]}......................................${cm[clr]}'      ')
        bufStruct[2]="6 dots_line1,4 head_sata,44"
        ;;
    3)  drive="SanDisk SD8SBAT128G1122"; dsize="209.7"; dmsize="Mb"; bsd=0 ; bsp=1; ch=1
        bbuf[3]=$(printf '\033[8;0f    '${cm[num_sata]}"  "$ch''${cm[num_sata_br]}')'${cm[mount_sata_pls]}'   +   '${cm[dn_sata]}''"$drive"'                       '${cm[dn_bsd_sata]}disk${cm[sata_bsd]}${bsd}${cm[dn_bsd_sata]}s${cm[sata_bsp]}${bsp}'          '${cm[pn_size_sata]}''"$dsize${cm[pn_size_msata]} $dmsize"'     '${cm[clr]}' ')
        bufStruct[3]="8 num_sata,6 num_sata_br,7 mount_sata_pls,11 dn_sata,15 dn_bsd_sata,61 sata_bsd,65 sata_bsp,67 pn_size_sata,78 pn_size_msata,84"
        StructHints[3]="order numbers for sata;bracket after number;plus for mounted;drive name or alias;BSD disk name;disk number;partition or volume number;partition or volume size; dimension (Mb/Gb);"
        ;;
    4)  bbuf[4]=$(printf '\033[10;0f    '${cm[dots_line2]}''.......................................''${cm[head_usb]}' USB '${cm[dots_line2]}......................................'      ')
        bufStruct[4]="10 dots_line2,4 head_usb,44"
        ;;
    5)  drive="TOSHIBA MK2555GSXF"; dsize=" 31.6"; dmsize="Gb"; bsd=1 ; bsp=2; ch=2
        bbuf[5]=$(printf '\033[12;0f    '${cm[num_usb]}"  "$ch''${cm[num_usb_br]}')'${cm[mount_usb_pls]}'   +   '${cm[dn_usb]}''"$drive"'                            '${cm[dn_bsd_usb]}disk${cm[usb_bsd]}${bsd}${cm[dn_bsd_usb]}s${cm[usb_bsp]}${bsp}'          '${cm[pn_size_usb]}''"$dsize${cm[pn_size_musb]} $dmsize"'     '${cm[clr]}' ')
        bufStruct[5]="12 num_usb,6 num_usb_br,7 mount_usb_pls,11 dn_usb,15 dn_bsd_usb,61 usb_bsd,65 usb_bsp,67 pn_size_usb,79 pn_size_musb,84"
        StructHints[5]="order numbers for usb;bracket after number;plus for mounted;drive name or alias;BSD disk name;disk number;partition or volume number;partition or volume size; dimension (Mb/Gb);" 
        ;;
    6)  bbuf[6]=$(printf '\033[14;0f    '${cm[dots_line3]}...................................................................................${cm[clr]}'     ')
        bufStruct[6]="14 dots_line3,4"
        ;;
    esac
fi 
}

############## строки подсказок по клавишам #############################
SET_STRUCT_2(){
if [[ $loc = "ru" ]]; then
    if [[ $hints = 0 ]]; then
           case $1 in
        7)  bbuf[7]=$(printf '\033[15;1f'${cm[cl_E]}'      E  '${cm[kh_str]}'-   подключить EFI диска этой системы     '${cm[clr]}'')
            bufStruct[7]="15 cl_E,6 kh_str,13"
            ;;
	    8)  bbuf[8]=$(printf '\033[16;1f'${cm[cl_U]}'      U  '${cm[kh_str]}'-   отключить ВСЕ подключенные разделы EFI  '${cm[clr]}'')
            bufStruct[8]="16 cl_U,6 kh_str,13"
            ;;
        9)  bbuf[9]=$(printf '\033[17;1f'${cm[cl_A]}'      A  '${cm[kh_str]}'-   настроить авто-подключение EFI          '${cm[clr]}'')
            bufStruct[9]="17 cl_A,6 kh_str,13"
            ;;
       10)  bbuf[10]=$(printf '\033[18;1f'${cm[cl_I]}'      I  '${cm[kh_str]}'-   дополнительное меню                     '${cm[clr]}'')
            bufStruct[10]="18 cl_I,6 kh_str,13"
            ;;
	   11)  bbuf[11]=$(printf '\033[19;1f'${cm[cl_Q]}'      Q  '${cm[kh_str]}'-   закрыть окно и выход из программы     '${cm[clr]}'')
            bufStruct[11]="19 cl_Q,6 kh_str,13"
            ;; 
       12)  bbuf[12]=$(printf '\033[21;1f'${cm[curs_str]}'  Введите число от '${cm[curs_num_1]}'0'${cm[curs_str]}' до '${cm[curs_num_2]}'3'${cm[curs_str]}' ( '${cm[cl_P]}'P'${cm[curs_str]}','${cm[cl_U]}'U'${cm[curs_str]}','${cm[cl_E]}'E'${cm[curs_str]}','${cm[cl_A]}'A'${cm[curs_str]}','${cm[cl_S]}'S'${cm[curs_str]}','${cm[cl_I]}'I'${cm[curs_str]}' или '${cm[cl_Q]}'Q'${cm[curs_str]}' ):  '${cm[clr]}'            ')
            bufStruct[12]="21 curs_str,2 curs_num_1,19 curs_num_2,24 cl_P,28 cl_S,36"
            ;;
           esac
    elif [[ $hints = 1 ]]; then
           case $1 in
       7)   bbuf[7]=$(printf '\033[15;1f'${cm[cl_C]}'      C  '${cm[kh_str]}'-   подключить EFI с загрузчиком Clover       '${cm[cl_W]}'W'${cm[kh_str]}' - Режим EasyEFI '${cm[clr]}'')
            bufStruct[7]="15 cl_C,6 kh_str,13 cl_W,55 kh_str,59"
            ;;
	   8)   bbuf[8]=$(printf '\033[16;1f'${cm[cl_O]}'      O  '${cm[kh_str]}'-   подключить EFI с загрузчиком Open Core    '${cm[cl_E2]}'E'${cm[kh_str]}' - Редактор цвета'${cm[clr]}'')
            bufStruct[8]="16 cl_O,6 kh_str,13 cl_E2,55 kh_str,59"
            ;;
	   9)   bbuf[9]=$(printf '\033[17;1f'${cm[cl_S]}'      S  '${cm[kh_str]}'-   вызвать экран настройки MountEFI          '${cm[cl_M]}'M'${cm[kh_str]}' - Цветной мод   '${cm[clr]}'')
            bufStruct[9]="17 cl_S,6 kh_str,13 cl_M,55 kh_str,59"
            ;;
      10)   bbuf[10]=$(printf '\033[18;1f'${cm[cl_P]}'      P  '${cm[kh_str]}'-   открыть config.plist с EFI раздела            '${cm[clr]}'')
            bufStruct[10]="18 cl_P,6 kh_str,13"
            ;; 
      11)   bbuf[11]=$(printf '\033[19;1f'${cm[cl_V]}'      V  '${cm[kh_str]}'-   посмотреть версию программы    '${cm[clr]}'')
            bufStruct[11]="19 cl_V,6 kh_str,13"
            ;;
      12)   bbuf[12]=$(printf '\033[21;1f'${cm[curs_str]}'  Введите число от '${cm[curs_num_1]}'0'${cm[curs_str]}' до '${cm[curs_num_2]}''3' '${cm[curs_str]}'( '${cm[cl_P]}'P'${cm[curs_str]}','${cm[cl_O]}'O'${cm[curs_str]}','${cm[cl_C]}'C'${cm[curs_str]}','${cm[cl_S]}'S'${cm[curs_str]}','${cm[cl_I]}'I'${cm[curs_str]}'  или  '${cm[cl_Q]}'Q'${cm[curs_str]}' ):   '${cm[clr]}'          ')
            bufStruct[12]="21 curs_str,2 curs_num_1,19 curs_num_2,24 cl_I,36"
            ;;
           esac
    elif [[ $hints = 2 ]]; then 
           case $1 in      
       7)   bbuf[7]=$(printf '\033[15;1f'${cm[cl_O]}'      O  '${cm[kh_str]}'-  открыть первый по списку config.plist OpenCore      '${cm[clr]}'\n')
            bufStruct[7]="15 cl_O,6 kh_str,12"
            ;;  
	   8)   bbuf[8]=$(printf '\033[16;1f'${cm[cl_C]}'      C  '${cm[kh_str]}'-  открыть первый по списку config.plist Сlover        '${cm[clr]}'')
            bufStruct[8]="16 cl_C,6 kh_str,12"
            ;;
       9)   bbuf[9]=$(printf '\033[17;1f'${cm[curs_num_1]}'      0'${cm[kh_str]}'-'${cm[curs_num_2]}'2'${cm[kh_str]}' - открыть config.plist на разделе (томе) номер... '${cm[clr]}'')
            bufStruct[9]="17 curs_num_1,6 curs_num_2,8 kh_str,12"
            ;;
      10)   bbuf[10]=$(printf '\033[18;1f'${cm[cl_L]}'      L  '${cm[kh_str]}'-  открыть config.plist который был открыт ранее.        '${cm[clr]}'')
            bufStruct[10]="18 cl_L,6 kh_str,12"
            ;;
	  11)   bbuf[11]=$(printf '\033[19;1f'${cm[cl_ast]}'      ** '${cm[cl_str]}'возврат в главное меню через 5 сек или любой клавишей.  '${cm[clr]}'')
            bufStruct[11]="19 cl_ast,6 cl_str,9"
            ;;
      12)   bbuf[12]=$(printf '\033[21;1f'${cm[curs_str]}'  Открыть '${cm[cl_conf]}'config.plist'${cm[curs_str]}' ( номер EFI, '${cm[cl_O]}'O'${cm[curs_str]}', '${cm[cl_C]}'C'${cm[curs_str]}', '${cm[cl_L]}'L'${cm[curs_str]}' или Enter ):   '${cm[clr]}'    ')
            bufStruct[12]="21 curs_str,2 cl_conf,10"
            ;;
           esac
    fi 
else
        if [[ $hints = 0 ]]; then
           case $1 in
        7)  bbuf[7]=$(printf '\033[15;1f'${cm[cl_E]}'      E  '${cm[kh_str]}'-   mount the EFI of current system drive     '${cm[clr]}'')
            bufStruct[7]="15 cl_E,6 kh_str,13"
            ;;
	    8)  bbuf[8]=$(printf '\033[16;1f'${cm[cl_U]}'      U  '${cm[kh_str]}'-   unmount ALL mounted  EFI partitions  '${cm[clr]}'')
            bufStruct[8]="16 cl_U,6 kh_str,13"
            ;;
        9)  bbuf[9]=$(printf '\033[17;1f'${cm[cl_A]}'      A  '${cm[kh_str]}'-   set up EFI'"'"'s auto-mount          '${cm[clr]}'')
            bufStruct[9]="17 cl_A,6 kh_str,13"
            ;;
       10)  bbuf[10]=$(printf '\033[18;1f'${cm[cl_I]}'      I  '${cm[kh_str]}'-   extra menu                           '${cm[clr]}'')
            bufStruct[10]="18 cl_I,6 kh_str,13"
            ;;
	   11)  bbuf[11]=$(printf '\033[19;1f'${cm[cl_Q]}'      Q  '${cm[kh_str]}'-   close terminal and exit from the program   '${cm[clr]}'')
            bufStruct[11]="19 cl_Q,6 kh_str,13"
            ;; 
       12)  bbuf[12]=$(printf '\033[21;1f'${cm[curs_str]}'  Enter a num from  '${cm[curs_num_1]}'0'${cm[curs_str]}' to '${cm[curs_num_2]}'3'${cm[curs_str]}' ( '${cm[cl_P]}'P'${cm[curs_str]}','${cm[cl_U]}'U'${cm[curs_str]}','${cm[cl_E]}'E'${cm[curs_str]}','${cm[cl_A]}'A'${cm[curs_str]}','${cm[cl_S]}'S'${cm[curs_str]}','${cm[cl_I]}'I'${cm[curs_str]}' or '${cm[cl_Q]}'Q'${cm[curs_str]}' ):  '${cm[clr]}'             ')
            bufStruct[12]="21 curs_str,2 curs_num_1,20 curs_num_2,25 cl_P,29 cl_S,37"
            ;;
           esac
    elif [[ $hints = 1 ]]; then
           case $1 in
       7)   bbuf[7]=$(printf '\033[15;1f'${cm[cl_C]}'      C  '${cm[kh_str]}'-   mount EFI with Clover bootloader        '${cm[cl_W]}'W'${cm[kh_str]}' - EasyEFI Mode'${cm[clr]}'')
            bufStruct[7]="15 cl_C,6 kh_str,13 cl_W,53 kh_str,57"
            ;;
	   8)   bbuf[8]=$(printf '\033[16;1f'${cm[cl_O]}'      O  '${cm[kh_str]}'-   mount EFI with Open Core bootloader     '${cm[cl_E2]}'E'${cm[kh_str]}' - Color Editor'${cm[clr]}'')
            bufStruct[8]="16 cl_O,6 kh_str,13 cl_E2,53 kh_str,57"
            ;;
	   9)   bbuf[9]=$(printf '\033[17;1f'${cm[cl_S]}'      S  '${cm[kh_str]}'-   call MountEFI setup screen               '${cm[cl_M]}'M'${cm[kh_str]}' - Color Mode  '${cm[clr]}'')
            bufStruct[9]="17 cl_S,6 kh_str,13 cl_M,53 kh_str,57"
            ;;
      10)   bbuf[10]=$(printf '\033[18;1f'${cm[cl_P]}'      P  '${cm[kh_str]}'-   open config.plist from EFI partition            '${cm[clr]}'')
            bufStruct[10]="18 cl_P,6 kh_str,13"
            ;; 
      11)   bbuf[11]=$(printf '\033[19;1f'${cm[cl_V]}'      V  '${cm[kh_str]}'-   view the program version       '${cm[clr]}'')
            bufStruct[11]="19 cl_V,6 kh_str,13"
            ;;
      12)   bbuf[12]=$(printf '\033[21;1f'${cm[curs_str]}'  Enter a num from  '${cm[curs_num_1]}'0'${cm[curs_str]}' to '${cm[curs_num_2]}''3' '${cm[curs_str]}'( '${cm[cl_P]}'P'${cm[curs_str]}','${cm[cl_O]}'O'${cm[curs_str]}','${cm[cl_C]}'C'${cm[curs_str]}','${cm[cl_S]}'S'${cm[curs_str]}','${cm[cl_I]}'I'${cm[curs_str]}'  or  '${cm[cl_Q]}'Q'${cm[curs_str]}' ):   '${cm[clr]}'            ')
            bufStruct[12]="21 curs_str,2 curs_num_1,20 curs_num_2,25 cl_I,37"
            ;;
           esac
    elif [[ $hints = 2 ]]; then 
           case $1 in      
       7)   bbuf[7]=$(printf '\033[15;1f'${cm[cl_O]}'      O  '${cm[kh_str]}'-  open the first on the list OpenCore config.plist      '${cm[clr]}'\n')
            bufStruct[7]="15 cl_O,6 kh_str,12"
            ;;  
	   8)   bbuf[8]=$(printf '\033[16;1f'${cm[cl_C]}'      C  '${cm[kh_str]}'-  open the first on the list Clover config.plist        '${cm[clr]}'')
            bufStruct[8]="16 cl_C,6 kh_str,12"
            ;;
       9)   bbuf[9]=$(printf '\033[17;1f'${cm[curs_num_1]}'      0'${cm[kh_str]}'-'${cm[curs_num_2]}'2'${cm[kh_str]}' - open config.plist on partition (volume) number... '${cm[clr]}'')
            bufStruct[9]="17 curs_num_1,6 curs_num_2,8 kh_str,12"
            ;;
      10)   bbuf[10]=$(printf '\033[18;1f'${cm[cl_L]}'      L  '${cm[kh_str]}'-  open the config.plist that was last opened.        '${cm[clr]}'')
            bufStruct[10]="18 cl_L,6 kh_str,12"
            ;;
	  11)   bbuf[11]=$(printf '\033[19;1f'${cm[cl_ast]}'      ** '${cm[cl_str]}'return to the main menu after 5 seconds or by any key.  '${cm[clr]}'')
            bufStruct[11]="19 cl_ast,6 cl_str,9"
            ;;
      12)   bbuf[12]=$(printf '\033[21;1f'${cm[curs_str]}'  Open '${cm[cl_conf]}'config.plist'${cm[curs_str]}' ( EFI num, '${cm[cl_O]}'O'${cm[curs_str]}', '${cm[cl_C]}'C'${cm[curs_str]}', '${cm[cl_L]}'L'${cm[curs_str]}' or Enter ):   '${cm[clr]}'            ')
            bufStruct[12]="21 curs_str,2 cl_conf,7"
            ;;
           esac
    fi 
fi
}

SET_LOADER_STRUCT(){
if [[ $loc = "ru" ]]; then
    case "$1" in
        Clover )   drive="SanDisk SD8SBAT128G1122"; dsize="209.7"; dmsize="Mb"; bsd=0 ; bsp=1; ch=1
                   bbuf[3]=$(printf '\033[8;0f    '${cm[num_sata]}"  "$ch''${cm[num_sata_br]}')'${cm[mount_sata_pls]}'   +   '${cm[dn_sata]}''"$drive"${cm[ld_cl]}'         Clover        '${cm[dn_bsd_sata]}disk${cm[sata_bsd]}${bsd}${cm[dn_bsd_sata]}s${cm[sata_bsp]}${bsp}'          '${cm[pn_size_sata]}''"$dsize${cm[pn_size_msata]} $dmsize"'     '${cm[clr]}' ')
                   bufStruct[3]="8 num_sata,6 num_sata_br,7 mount_sata_pls,11 dn_sata,15 ld_cl,47 dn_bsd_sata,61 sata_bsd,65 sata_bsp,67 pn_size_sata,78 pn_size_msata,84"
                   StructHints[3]="числа нумерации для sata;скобка после номера; плюс для подключенных; имя диска или псевдоним;имя загрузчика (выбирается клавишей L);имя BSD диска;цифра номера диска;цифра номера раздела;размер раздела;измерение раздела (Mb/Gb);"
                    ;;
      OpenCore )   drive="TOSHIBA MK2555GSXF"; dsize=" 31.6"; dmsize="Gb"; bsd=1 ; bsp=2; ch=2
                   bbuf[5]=$(printf '\033[12;0f    '${cm[num_usb]}"  "$ch''${cm[num_usb_br]}')'${cm[mount_usb_dots]}' ...   '${cm[dn_usb]}''"$drive"${cm[ld_oc]}'             OpenCore       '${cm[dn_bsd_usb]}disk${cm[usb_bsd]}${bsd}${cm[dn_bsd_usb]}s${cm[usb_bsp]}${bsp}'          '${cm[pn_size_usb]}''"$dsize${cm[pn_size_musb]} $dmsize"'     '${cm[clr]}' ')
                   bufStruct[5]="12 num_usb,6 num_usb_br,7 mount_usb_dots,9 dn_usb,15 ld_oc,46 dn_bsd_usb,61 usb_bsd,65 usb_bsp,67 pn_size_usb,79 pn_size_musb,84"
                   StructHints[5]="числа нумерации для USB;скобка после номера; точки обозначают отключенные;имя диска или псевдоним;имя загрузчика (выбирается клавишей L);имя BSD диска;цифра номера диска;цифра номера раздела;размер раздела;измерение раздела (Mb/Gb);"
                   ;;
      "Windows")   drive="SanDisk SD8SBAT128G1122"; dsize="209.7"; dmsize="Mb"; bsd=0 ; bsp=1; ch=1
                   bbuf[3]=$(printf '\033[8;0f    '${cm[num_sata]}"  "$ch''${cm[num_sata_br]}')'${cm[mount_sata_dots]}' ...   '${cm[dn_sata]}''"$drive"${cm[ld_wn]}'        Windows        '${cm[dn_bsd_sata]}disk${cm[sata_bsd]}${bsd}${cm[dn_bsd_sata]}s${cm[sata_bsp]}${bsp}'          '${cm[pn_size_sata]}''"$dsize${cm[pn_size_msata]} $dmsize"'     '${cm[clr]}' ')
                   bufStruct[3]="8 num_sata,6 num_sata_br,7 mount_sata_dots,9 dn_sata,15 ld_wn,46 dn_bsd_sata,61 sata_bsd,65 sata_bsp,67 pn_size_sata,78 pn_size_msata,84"
                   StructHints[3]="числа нумерации для sata;скобка после номера; точки обозначают отключенные;имя диска или псевдоним;имя загрузчика (выбирается клавишей L);имя BSD диска;цифра номера диска;цифра номера раздела;размер раздела;измерение раздела (Mb/Gb);"
                   ;;
         Linux)    drive="TOSHIBA MK2555GSXF"; dsize=" 31.6"; dmsize="Gb"; bsd=1 ; bsp=2; ch=2
                   bbuf[5]=$(printf '\033[12;0f    '${cm[num_usb]}"  "$ch''${cm[num_usb_br]}')'${cm[mount_usb_pls]}'   +   '${cm[dn_usb]}''"$drive"${cm[ld_gb]}'              Linux         '${cm[dn_bsd_usb]}disk${cm[usb_bsd]}${bsd}${cm[dn_bsd_usb]}s${cm[usb_bsp]}${bsp}'          '${cm[pn_size_usb]}''"$dsize${cm[pn_size_musb]} $dmsize"'     '${cm[clr]}' ')
                   bufStruct[5]="12 num_usb,6 num_usb_br,7 mount_usb_pls,11 dn_usb,15 ld_gb,47 dn_bsd_usb,61 usb_bsd,65 usb_bsp,67 pn_size_usb,79 pn_size_musb,84"
                   StructHints[5]="числа нумерации для USB;скобка после номера; плюс для подключенных;имя диска или псевдоним;имя загрузчика (выбирается клавишей L);имя BSD диска;цифра номера диска;цифра номера раздела;размер раздела;измерение раздела (Mb/Gb);"
                   ;;
        Refind)    drive="SanDisk SD8SBAT128G1122"; dsize="209.7"; dmsize="Mb"; bsd=0 ; bsp=1; ch=1
                   bbuf[3]=$(printf '\033[8;0f    '${cm[num_sata]}"  "$ch''${cm[num_sata_br]}')'${cm[mount_sata_pls]}'   +   '${cm[dn_sata]}''"$drive"${cm[ld_rf]}'         Refind        '${cm[dn_bsd_sata]}disk${cm[sata_bsd]}${bsd}${cm[dn_bsd_sata]}s${cm[sata_bsp]}${bsp}'          '${cm[pn_size_sata]}''"$dsize${cm[pn_size_msata]} $dmsize"'     '${cm[clr]}' ')
                   bufStruct[3]="8 num_sata,6 num_sata_br,7 mount_sata_pls,11 dn_sata,15 ld_rf,47 dn_bsd_sata,61 sata_bsd,65 sata_bsp,67 pn_size_sata,78 pn_size_msata,84"
                   StructHints[3]="числа нумерации для sata;скобка после номера; плюс для подключенных;имя диска или псевдоним;имя загрузчика (выбирается клавишей L);имя BSD диска;цифра номера диска;цифра номера раздела;размер раздела;измерение раздела (Mb/Gb);"
                   ;;
"Не распознан")    drive="TOSHIBA MK2555GSXF"; dsize=" 31.6"; dmsize="Gb"; bsd=1 ; bsp=2; ch=2
                   bbuf[5]=$(printf '\033[12;0f    '${cm[num_usb]}"  "$ch''${cm[num_usb_br]}')'${cm[mount_usb_dots]}' ...   '${cm[dn_usb]}''"$drive"${cm[ld_unrec]}'           Не распознан     '${cm[dn_bsd_usb]}disk${cm[usb_bsd]}${bsd}${cm[dn_bsd_usb]}s${cm[usb_bsp]}${bsp}'          '${cm[pn_size_usb]}''"$dsize${cm[pn_size_musb]} $dmsize"'     '${cm[clr]}' ')
                   bufStruct[5]="12 num_usb,6 num_usb_br,7 mount_usb_dots,9 dn_usb,15 ld_unrec,44 dn_bsd_usb,61 usb_bsd,65 usb_bsp,67 pn_size_usb,79 pn_size_musb,84"
                   StructHints[5]="числа нумерации для USB;скобка после номера; точки обозначают отключенные;имя диска или псевдоним;имя загрузчика (выбирается клавишей L);имя BSD диска;цифра номера диска;цифра номера раздела;размер раздела;измерение раздела (Mb/Gb);"
                   ;;
    esac
else
        case "$1" in
        Clover )   drive="SanDisk SD8SBAT128G1122"; dsize="209.7"; dmsize="Mb"; bsd=0 ; bsp=1; ch=1
                   bbuf[3]=$(printf '\033[8;0f    '${cm[num_sata]}"  "$ch''${cm[num_sata_br]}')'${cm[mount_sata_pls]}'   +   '${cm[dn_sata]}''"$drive"${cm[ld_cl]}'         Clover        '${cm[dn_bsd_sata]}disk${cm[sata_bsd]}${bsd}${cm[dn_bsd_sata]}s${cm[sata_bsp]}${bsp}'          '${cm[pn_size_sata]}''"$dsize${cm[pn_size_msata]} $dmsize"'     '${cm[clr]}' ')
                   bufStruct[3]="8 num_sata,6 num_sata_br,7 mount_sata_pls,11 dn_sata,15 ld_cl,47 dn_bsd_sata,61 sata_bsd,65 sata_bsp,67 pn_size_sata,78 pn_size_msata,84"
                   StructHints[3]="numbers for sata;bracket after number;plus means mounted EFI;drive name or alias;bootloader name (selected with the L key);BSD disk name;disk number;partition or volume number;partition or volume size;partition dimension (Mb/Gb);"
                    ;;
      OpenCore )   drive="TOSHIBA MK2555GSXF"; dsize=" 31.6"; dmsize="Gb"; bsd=1 ; bsp=2; ch=2
                   bbuf[5]=$(printf '\033[12;0f    '${cm[num_usb]}"  "$ch''${cm[num_usb_br]}')'${cm[mount_usb_dots]}' ...   '${cm[dn_usb]}''"$drive"${cm[ld_oc]}'             OpenCore       '${cm[dn_bsd_usb]}disk${cm[usb_bsd]}${bsd}${cm[dn_bsd_usb]}s${cm[usb_bsp]}${bsp}'          '${cm[pn_size_usb]}''"$dsize${cm[pn_size_musb]} $dmsize"'     '${cm[clr]}' ')
                   bufStruct[5]="12 num_usb,6 num_usb_br,7 mount_usb_dots,9 dn_usb,15 ld_oc,46 dn_bsd_usb,61 usb_bsd,65 usb_bsp,67 pn_size_usb,79 pn_size_musb,84"
                   StructHints[5]="numbers for usb;bracket after number;dots mean unmounted EFI;drive name or alias;bootloader name (selected with the L key);BSD disk name;disk number;partition or volume number;partition or volume size;partition dimension (Mb/Gb);"
                   ;;
      "Windows")   drive="SanDisk SD8SBAT128G1122"; dsize="209.7"; dmsize="Mb"; bsd=0 ; bsp=1; ch=1
                   bbuf[3]=$(printf '\033[8;0f    '${cm[num_sata]}"  "$ch''${cm[num_sata_br]}')'${cm[mount_sata_dots]}' ...   '${cm[dn_sata]}''"$drive"${cm[ld_wn]}'        Windows        '${cm[dn_bsd_sata]}disk${cm[sata_bsd]}${bsd}${cm[dn_bsd_sata]}s${cm[sata_bsp]}${bsp}'          '${cm[pn_size_sata]}''"$dsize${cm[pn_size_msata]} $dmsize"'     '${cm[clr]}' ')
                   bufStruct[3]="8 num_sata,6 num_sata_br,7 mount_sata_dots,9 dn_sata,15 ld_wn,46 dn_bsd_sata,61 sata_bsd,65 sata_bsp,67 pn_size_sata,78 pn_size_msata,84"
                   StructHints[5]="numbers for sata;bracket after number;dots mean unmounted EFI;drive name or alias;bootloader name (selected with the L key);BSD disk name;disk number;partition or volume number;partition or volume size;partition dimension (Mb/Gb);"
                   ;;
         Linux)    drive="TOSHIBA MK2555GSXF"; dsize=" 31.6"; dmsize="Gb"; bsd=1 ; bsp=2; ch=2
                   bbuf[5]=$(printf '\033[12;0f    '${cm[num_usb]}"  "$ch''${cm[num_usb_br]}')'${cm[mount_usb_pls]}'   +   '${cm[dn_usb]}''"$drive"${cm[ld_gb]}'              Linux         '${cm[dn_bsd_usb]}disk${cm[usb_bsd]}${bsd}${cm[dn_bsd_usb]}s${cm[usb_bsp]}${bsp}'          '${cm[pn_size_usb]}''"$dsize${cm[pn_size_musb]} $dmsize"'     '${cm[clr]}' ')
                   bufStruct[5]="12 num_usb,6 num_usb_br,7 mount_usb_pls,11 dn_usb,15 ld_gb,47 dn_bsd_usb,61 usb_bsd,65 usb_bsp,67 pn_size_usb,79 pn_size_musb,84"
                   StructHints[3]="numbers for usb;bracket after number;plus means mounted EFI;drive name or alias;bootloader name (selected with the L key);BSD disk name;disk number;partition or volume number;partition or volume size;partition dimension (Mb/Gb);"
                   ;;
        Refind)    drive="SanDisk SD8SBAT128G1122"; dsize="209.7"; dmsize="Mb"; bsd=0 ; bsp=1; ch=1
                   bbuf[3]=$(printf '\033[8;0f    '${cm[num_sata]}"  "$ch''${cm[num_sata_br]}')'${cm[mount_sata_pls]}'   +   '${cm[dn_sata]}''"$drive"${cm[ld_rf]}'         Refind        '${cm[dn_bsd_sata]}disk${cm[sata_bsd]}${bsd}${cm[dn_bsd_sata]}s${cm[sata_bsp]}${bsp}'          '${cm[pn_size_sata]}''"$dsize${cm[pn_size_msata]} $dmsize"'     '${cm[clr]}' ')
                   bufStruct[3]="8 num_sata,6 num_sata_br,7 mount_sata_pls,11 dn_sata,15 ld_rf,47 dn_bsd_sata,61 sata_bsd,65 sata_bsp,67 pn_size_sata,78 pn_size_msata,84"
                   StructHints[3]="numbers for sata;bracket after number;plus means mounted EFI;drive name or alias;bootloader name (selected with the L key);BSD disk name;disk number;partition or volume number;partition or volume size;partition dimension (Mb/Gb);"
                   ;;
   Unrecognized)   drive="TOSHIBA MK2555GSXF"; dsize=" 31.6"; dmsize="Gb"; bsd=1 ; bsp=2; ch=2
                   bbuf[5]=$(printf '\033[12;0f    '${cm[num_usb]}"  "$ch''${cm[num_usb_br]}')'${cm[mount_usb_dots]}' ...   '${cm[dn_usb]}''"$drive"${cm[ld_unrec]}'           Unrecognized     '${cm[dn_bsd_usb]}disk${cm[usb_bsd]}${bsd}${cm[dn_bsd_usb]}s${cm[usb_bsp]}${bsp}'          '${cm[pn_size_usb]}''"$dsize${cm[pn_size_musb]} $dmsize"'     '${cm[clr]}' ')
                   bufStruct[5]="12 num_usb,6 num_usb_br,7 mount_usb_dots,9 dn_usb,15 ld_unrec,44 dn_bsd_usb,61 usb_bsd,65 usb_bsp,67 pn_size_usb,79 pn_size_musb,84"
                   StructHints[5]="numbers for usb;bracket after number;dots mean unmounted EFI;drive name or alias;bootloader name (selected with the L key);BSD disk name;disk number;partition or volume number;partition or volume size;partition dimension (Mb/Gb);"
                   ;;
    esac
     StructHints[5]="numbers for sata;bracket after number;dots mean unmounted EFI;drive name or alias;bootloader name (selected with the L key);BSD disk name;disk number;partition or volume number;partition or volume size;partition dimension (Mb/Gb);"

fi
}

SET_STRUCT_3(){
if [[ $loc = "ru" ]]; then
    case "$1" in
           1)  bbuf[1]=$(printf '\033[4;0f      '${cm[head_upd_sch_num]}'0'${cm[head_upd_sch_br]}')'${cm[head_upd_sch]}'  поиск разделов ..... '${cm[clr]}''"${cm[head_upd_sch_sp]}-\|/${cm[clr]}")
               bufStruct[1]="4 head_upd_sch_num,6 head_upd_sch_br,7 head_upd_sch,10 head_upd_sch_sp,31"
               StructHints[1]="цифра 0 строки поиска;скобка после цифры;текст поиск разделов;спинер;"
               ;;
           3)  drive="SanDisk SD8SBAT128G1122"; dsize="209.7"; dmsize="Mb"; bsd=0 ; bsp=1; ch=1
               bbuf[3]=$(printf '\033[8;0f    '${cm[num_sata]}"  "$ch''${cm[num_sata_br]}')'${cm[mount_sata_dots]}' ...   '${cm[dn_sata]}''"$drive"'                       '${cm[dn_bsd_sata]}disk${cm[sata_bsd]}${bsd}${cm[dn_bsd_sata]}s${cm[sata_bsp]}${bsp}'          '${cm[pn_size_sata]}''"$dsize${cm[pn_size_msata]} $dmsize"'     '${cm[clr]}' ')
               bufStruct[3]="8 num_sata,6 num_sata_br,7 mount_sata_dots,9 dn_sata,15 dn_bsd_sata,61 sata_bsd,65 sata_bsp,67 pn_size_sata,78 pn_size_msata,84"
               StructHints[3]="порядковые номера для sata;скобка после номера;точки для обозначения отключенных;имя диска или псевдоним;имя BSD диска;цифра номера диска;цифра номера раздела;размер раздела;измерение раздела (Mb/Gb);"
               ;;
          5)   drive="TOSHIBA MK2555GSXF"; dsize=" 31.6"; dmsize="Gb"; bsd=1 ; bsp=2; ch=2
               bbuf[5]=$(printf '\033[12;0f    '${cm[num_usb]}"  "$ch''${cm[num_usb_br]}')'${cm[mount_usb_dots]}' ...   '${cm[dn_usb]}''"$drive"'                            '${cm[dn_bsd_usb]}disk${cm[usb_bsd]}${bsd}${cm[dn_bsd_usb]}s${cm[usb_bsp]}${bsp}'          '${cm[pn_size_usb]}''"$dsize${cm[pn_size_musb]} $dmsize"'     '${cm[clr]}' ')
               bufStruct[5]="12 num_usb,6 num_usb_br,7 mount_usb_dots,9 dn_usb,15 dn_bsd_usb,61 usb_bsd,65 usb_bsp,67 pn_size_usb,79 pn_size_musb,84"
               StructHints[5]="порядковые номера для USB;скобка после номера;точки для обозначения отключенных;имя диска или псевдоним;имя BSD диска;цифра номера диска;цифра номера раздела;размер раздела;измерение раздела (Mb/Gb);" 
               ;;
         12)   bbuf[12]=$(printf '\033[21;0f  '${cm[ld_srch]}'Подождите. Ищем загрузочные разделы с '${cm[ld_srch_bt]}'BOOTx64.efi'${cm[ld_srch]}' ...  '${cm[clr]}''"${cm[ld_srch_sp]}-\|/${cm[clr]}")
               bufStruct[12]="21 ld_srch,2 ld_srch_bt,40 ld_srch_sp,57"
               StructHints[12]="текст строки поиска;bootx64.efi;спинер;"
               ;;
    esac
else
    case "$1" in
           1)  bbuf[1]=$(printf '\033[4;0f      '${cm[head_upd_sch_num]}'0'${cm[head_upd_sch_br]}')'${cm[head_upd_sch]}'  updating partitions list ..... '${cm[clr]}''"${cm[head_upd_sch_sp]}-\|/${cm[clr]}")
               bufStruct[1]="4 head_upd_sch_num,6 head_upd_sch_br,7 head_upd_sch,10 head_upd_sch_sp,41"
               StructHints[1]="number 0 of the search string;bracket after the number;text search for partitions;spiner;"
               ;;
           3)  drive="SanDisk SD8SBAT128G1122"; dsize="209.7"; dmsize="Mb"; bsd=0 ; bsp=1; ch=1
               bbuf[3]=$(printf '\033[8;0f    '${cm[num_sata]}"  "$ch''${cm[num_sata_br]}')'${cm[mount_sata_dots]}' ...   '${cm[dn_sata]}''"$drive"'                       '${cm[dn_bsd_sata]}disk${cm[sata_bsd]}${bsd}${cm[dn_bsd_sata]}s${cm[sata_bsp]}${bsp}'          '${cm[pn_size_sata]}''"$dsize${cm[pn_size_msata]} $dmsize"'     '${cm[clr]}' ')
               bufStruct[3]="8 num_sata,6 num_sata_br,7 mount_sata_pls,11 dn_sata,15 dn_bsd_sata,61 sata_bsd,65 sata_bsp,67 pn_size_sata,78 pn_size_msata,84"
               StructHints[3]="order numbers for sata;bracket after number;plus means mounted EFI;drive name or alias;BSD disk name;disk number;partition or volume number;partition or volume size; dimension (Mb/Gb);"
               ;;
           5)  drive="TOSHIBA MK2555GSXF"; dsize=" 31.6"; dmsize="Gb"; bsd=1 ; bsp=2; ch=2
               bbuf[5]=$(printf '\033[12;0f    '${cm[num_usb]}"  "$ch''${cm[num_usb_br]}')'${cm[mount_usb_dots]}' ...   '${cm[dn_usb]}''"$drive"'                            '${cm[dn_bsd_usb]}disk${cm[usb_bsd]}${bsd}${cm[dn_bsd_usb]}s${cm[usb_bsp]}${bsp}'          '${cm[pn_size_usb]}''"$dsize${cm[pn_size_musb]} $dmsize"'     '${cm[clr]}' ')
               bufStruct[5]="12 num_usb,6 num_usb_br,7 mount_usb_pls,11 dn_usb,15 dn_bsd_usb,61 usb_bsd,65 usb_bsp,67 pn_size_usb,79 pn_size_musb,84"
               StructHints[5]="order numbers for usb;bracket after number;dots mean unmounted EFI;drive name or alias;BSD disk name;disk number;partition or volume number;partition or volume size; dimension (Mb/Gb);" 
               ;;
          12)  bbuf[12]=$(printf '\033[21;0f  '${cm[ld_srch]}'Wait. Looking for boot partitions with '${cm[ld_srch_bt]}'BOOTx64.efi'${cm[ld_srch]}' ...  '${cm[clr]}''"${cm[ld_srch_sp]}-\|/${cm[clr]}")
               bufStruct[12]="21 ld_srch,2 ld_srch_bt,41 ld_srch_sp,58"
               StructHints[12]="text search for partitions;bootx64.efi;spiner;"
               ;;
    esac
fi 
}

CLEAR_BOTTOM(){ for i in 1 2 3 4 5 6 7; do printf '\033['$((14+i))';0;f                                                                           '; done; printf '\033[37;32;f'; }

BACKUP(){ old_cm=(); for i in ${!cm[@]}; do old_cm[i]=${cm[i]}; done ; }

function Progress {
let _progress=(${1}*100/${2}*100)/100 2>/dev/null
let _done=(${_progress}*3)/10 2>/dev/null
let _left=30-$_done 2>/dev/null
_fill=$(printf "%${_done}s")
_empty=$(printf "%${_left}s")
printf "   |${_fill// /|}${_empty// / }|  code: ${1}  " 2>/dev/null
}

PROGRESSBAR(){ if [[ ! $code = "" ]]; then   printf '\033[33;26f          '; Progress ${code} 255; printf '\033[37;32f'; fi; }


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
if [[ $cl_normal = 1 ]]; then printf '\033[26;25f''√' ;else printf '\033[26;25f'' '; fi
if [[ $cl_bold = 1 ]]; then printf '\033[27;25f''√' ;else printf '\033[27;25f'' '; fi
if [[ $cl_dim = 1 ]]; then printf '\033[28;25f''√' ;else printf '\033[28;25f'' '; fi
if [[ $cl_underl = 1 ]]; then printf '\033[29;25f''√'; else printf '\033[29;25f'' '; fi
if [[ $cl_blink = 1 ]]; then printf '\033[30;25f''√' ;else printf '\033[30;25f'' '; fi
if [[ $cl_inv = 1 ]]; then printf '\033[31;25f''√' ;else printf '\033[31;25f'' '; fi
if [[ $cl_bit = 1 ]]; then printf '\033[33;25f''√'; printf '\033[32;25f'' '; fi 
if [[ $cl_bit = 0 ]]; then printf '\033[32;25f''√'; printf '\033[33;25f'' '; fi
}

GET_POINTER_INPUT(){ 
             if [[ $init = 1 ]]; then printf '\033[2;1f'; SHOW_CURSOR; init=0
             elif [[ $inputs = [zZxXhHcCvVeE] ]]; then printf '\033[?25l\033[37;32;f                                                              ' 
             fi         
             while [[ ! ${inputs} =~ ^[0-7zZxXeEqQcCoOaAsSdDfFvVrRhHlLwWpPtT]+$ ]]; do
             read -s -r -n 1 inputs 
             if [[ "${inputs}" = $(printf '\033') ]]; then read -r -s -n 2 keys 
                      case "${inputs}" in
                '[A') inputs="R" ; break ;;
                '[B') inputs="V" ; break ;;
                '[D') inputs="D" break ;;
                '[C') inputs="F" break;;
            esac
             fi   
             if [[ ! $inputs = [0-7zZxXeEqQcCoOaAsSdDfFvVrRhHlLwWpPtT] ]]; then 
                        if [[ ${inputs} = "" ]]; then  unset inputs; fi 
                        
                        printf '\r'
                        
            fi
            printf '\r'
            done
}

SET_STRIP(){

posit=36; code2=40
if [[ ${cl_bit} = 0 ]]; then
for ((i=0;i<16;i++)) do 
#printf '\033[27;'$posit'f\e['$code2'm''   ''\e[0m'
printf '\033[28;'$posit'f\e['$code2'm''   ''\e[0m'
printf '\033[29;'$posit'f\e['$code2'm''   ''\e[0m'
printf '\033[30;'$posit'f\e['$code2'm''   ''\e[0m'
if [[ $code2 = 47 ]]; then code2=99; fi
let "code2++"; let "posit=posit+3"
done
strip=0
else
if [[ $strip = 0 ]]; then printf '\033[27;35f                                                  \033[31;35f                                                  '; strip=1; fi       
#printf '\033[27;36f\e['$rcol'm''                                                ''\e[0m'
printf '\033[28;36f\e['$rcol'm''                                                ''\e[0m'
printf '\033[29;36f\e['$rcol'm''                                                ''\e[0m'
printf '\033[30;36f\e['$rcol'm''                                                ''\e[0m'
printf '\033[37;32f'
fi
}

COLOR_TRANS(){
if [[ $cl_bit = 1 && $(echo $old_color | grep -o "38;5") = "" ]]; then code=$( echo $old_color | awk -F ';' '{print $NF}' )
if [[ $code -gt 29 && $code -lt 38 ]]; then code=$((code-30)); elif [[ $code -gt 89 && $code -lt 98 ]]; then code=$((code-82)); fi
old_color="38;5;"$code
fi
}

GET_ITEM_COLOR(){
oldItemColor=${cm[$(echo ${CurrStrList[ObjPtr]} | cut -f1 -d',')]}
old_color=$(echo "$oldItemColor" | sed s'/\\e\[0m//' |  sed s'/\\e\[//' | tr -d 'm')
if [[ $cl_bit = 1 && $(echo $old_color | grep -o "38;5") = "" ]]; then code=$( echo $old_color | awk -F ';' '{print $NF}' ); 
if [[ $code -gt 29 && $code -lt 38 ]]; then old_color="38;5;"$((code-30)); elif [[ $code -gt 89 && $code -lt 98 ]]; then old_color="38;5;"$((code-82)); fi
fi
if [[ ! $old_color = "" ]]; then COLOR_PARSER $old_color; fi
}

SHOW_ITEM_COLOR(){ # < $old_color $new_color
MAKE_COLOR
SHOW_TEXT_FLAGS
STRIP_POINTER OFF
if [[ ${cl_bit} = 0 ]]; then  
if [[ ${code} -ge 30 ]] && [[ ${code} -le 37 ]]; then let "clptr=code-29"; fi
if [[ ${code} -ge 90 ]] && [[ ${code} -le 97 ]]; then let "clptr=code-89"; fi
if [[ ${code} -ge 30 ]] && [[ ${code} -le 37 ]]; then let "NN=(code-29)*3+34" ;fi 
if [[ ${code} -ge 90 ]] && [[ ${code} -le 97 ]]; then let "NN=3*(code-89)+58"; fi
STRIP_POINTER ON
fi
SET_STRIP 
if [[ ${cl_bit} = 1 ]]; then
PROGRESSBAR
fi
}

SHOW_NEW_ITEM_COLOR(){
if [[ ! "$oldNewItemColor" = "$NewItemColor" ]]; then oldNewItemColor="$NewItemColor"; fi
if [[ ${inputs} = [rR] ]]; then NewItemColor="\e[0m"; else NewItemColor="\e[0m\e["$new_color"m"; fi
cm[$(echo ${CurrStrList[ObjPtr]} | cut -f1 -d',')]="${NewItemColor}"
if [[ $StrPtr -lt 7 ]]; then
    if [[ $StrPtr = 3 && ! $LoaderPointer1 = "" ]]; then SET_LOADER_STRUCT $LoaderPointer1
      elif [[ $StrPtr = 3 && $hidden = 1 ]]; then SET_STRUCT_3 3
        elif [[ $StrPtr = 5 && $hidden = 1 ]]; then SET_STRUCT_3 5
            elif [[ $StrPtr = 1 && $hidden = 1 ]]; then SET_STRUCT_3 1
                elif [[ $StrPtr = 5 && ! $LoaderPointer1 = "" ]]; then SET_LOADER_STRUCT "$LoaderPointer2"
                    else SET_STRUCT_1 $StrPtr
    fi
elif [[ $StrPtr = 12 && $hidden = 1 ]]; then SET_STRUCT_3 12
    elif [[ $StrPtr -lt 12 && $ObjPtr -gt 1 ]]; then for i in 7 8 9 10 11; do SET_STRUCT_2 $i; done
        elif [[ StrPtr -lt 13 ]]; then SET_STRUCT_2 $StrPtr
fi
SET_SCREEN; printf '\033[37;32f'
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

GET_CURRENT_STRUCT(){ CurrStrList=(${bufStruct[StrPtr]}); lnN=${CurrStrList[0]}; CurrStrSize=${#CurrStrList[@]}; IFS=';';HintWords=(${StructHints[StrPtr]}); unset IFS ; }

SET_SCREEN(){ CLR_UNUSED_STR; for i in "${!bbuf[@]}"; do echo "${bbuf[i]}";  done ; }
STRIP_POINTER(){ if [[ $1 = "ON" ]]; then yes "" | printf '\033[27;'$NN'f''•  \033[31;'$NN'f''•  \033[37;32f'; else  yes "" | printf '\033[27;'$NN'f''   \033[31;'$NN'f''   \033[37;32f'; fi ; }
SHOW_CURSOR(){ SET_SCREEN; printf '\033[23;36f                                                          \033[23;38f'"${HintWords[$((ObjPtr-1))]}"''; yes '' | printf '\033['$lnN';'$(echo ${CurrStrList[ObjPtr]} | cut -f2 -d',')'f'"\033[?25h"; } 

###############################################################
EDIT_COLORS(){

MountEFIconf=$( cat "${CONFPATH}" )

GET_LOCALE

GET_THEME_NAMES
if [[ "$1" = "" ]]; then 
    while true; do presetName=$(ASK_COLOR_MODE_PRESET 2>/dev/null) 
        if [[ ! $presetName = "" ]]; then break 
            else kill $(ps ax | grep -v grep | grep "System Events" | xargs | cut -f1 -d' ') 
        fi
    done
fi
if [[ ! "$presetName" = "false" ]]; then 

hints=0

GET_SET_PRESET  
GET_COLOR_MODE_PRESET
#COLOR_MODE
BACKUP
UPDATE_GUI
SHOW_CURSOR  

ObjPtr=1; StrPtr=0; CurrStrList=(${bufStruct[0]}); lnN=${CurrStrList[0]}; CurrStrSize=${#CurrStrList[@]}
IFS=';';HintWords=(${StructHints[StrPtr]}); unset IFS; oldEdItem=""
lastEditItem=""; new_cm=(); unset inputs
loaderPonter1=""; loaderPointer2=""; hidden=0

printf '\033[22;1f\033[1m'; printf '–%.0s' {1..94}
if [[ $loc = "ru" ]]; then
printf '\033[23;1f[Редактор цветного мода]\033[0m   Элемент:'
else
printf '\033[23;1f[Color Mode Editor]\033[0m    Item:'
fi
printf '\033[24;1f\033[1m'; printf '–%.0s' {1..94}; printf '\033[0m'

                if [[ $loc = "ru" ]]; then
printf '                                                                                        \n'
printf '     0) Нормальный                   \n'  
printf '     1) Жирный/яркий                 \n'
printf '     2) Тусклый                      \n'
printf '     3) Подчёркнутый                 \n'
printf '     4) Мигающий                     \n'
printf '     5) Инверсный                    \n'
printf '     6) Цветов      16               \n'
printf '     7) Цветов     256               \n'
                    else
printf '                                                                                        \n'
printf '     0) Normal                       \n'  
printf '     1) Bold/Bright                  \n'
printf '     2) Dim                          \n'
printf '     3) Underlined                   \n'
printf '     4) Blink                        \n'
printf '     5) Inverse                      \n'
printf '     6) Colors      16               \n'
printf '     7) Colors     256               \n'
                    fi

COLOR_PARSER 37
SHOW_TEXT_FLAGS
if [[ ${cl_bit} = 0 ]]; then  
if [[ ${code} -ge 30 ]] && [[ ${code} -le 37 ]]; then let "clptr=code-29"; fi
if [[ ${code} -ge 90 ]] && [[ ${code} -le 97 ]]; then let "clptr=code-89"; fi
if [[ ${code} -ge 30 ]] && [[ ${code} -le 37 ]]; then let "NN=(code-29)*3+34" ;fi 
if [[ ${code} -ge 90 ]] && [[ ${code} -le 97 ]]; then let "NN=3*(code-89)+58"; fi
STRIP_POINTER ON
else MAKE_COLOR; fi
SET_STRIP 
if [[ ! ${cl_bit} = 0 ]]; then
PROGRESSBAR
fi
printf '\033[35;5f'
printf '.%.0s' {1..88}
printf '\033[37;7f'
                                if [[ $loc = "ru" ]]; then
                        printf 'Выберите от 0 до 7 или :                                                           \n\n'
                        printf '           Z/X - изменить цвет шаг 1                     A/D - курсор влево/вправо            \n'
                        printf '           C/V - изменить цвет шаг 6 (256 цветов)        W/S - курсор вверх/вниз              \n'
                        printf '           E/E - отменить/возвратить изменение           H   - редактироать подсказки         \n'
                        printf '           T   - повторить последний цвет                R   - вставить отмену цвета          \n'
                        printf '           F   - показать скрытые элементы               L   - названия загрузчиков           \n'
                        printf '           P   - управлять пресетами                     Q   - выход с сохранением            \n'
			                   else
                        printf 'Select from 1 to 7 or :                                                          \n\n'
                        printf '           Z/X - select color, step 1                     A/D - move cursor left/right       \n'
                        printf '           C/V - select color, step 6 (256 colors)        W/S - move cursor up/down          \n'
                        printf '           E/E - cancel/return the editing                H   - edit GUI key hints           \n'
                        printf '           T   - edit with last used color                R   - insert stop color code       \n'
                        printf '           F   - show hidden items                        L   - edit bootloader names        \n'
                        printf '           P   - preset  management                       Q   - quit saving result           \n'
                                fi
                    cvar=0; init=1
                    while [[ $cvar = 0 ]]; 
                    do

                    GET_POINTER_INPUT

                   if [[ ${inputs} = [dDaA] ]]; then
                        OldObjPtr=$ObjPtr
                        if [[ ${inputs} = [dD] ]]; then if [[ $ObjPtr -eq $((CurrStrSize-1)) ]]; then ObjPtr=1; else let "ObjPtr++"; fi; fi
                        if [[ ${inputs} = [aA] ]]; then if [[ $ObjPtr -eq 1 ]]; then ObjPtr=$((CurrStrSize-1)); else let "ObjPtr--"; fi; fi
                        SHOW_CURSOR
                        GET_ITEM_COLOR                    
                    fi
                    if [[ ${inputs} = [sSwW] ]]; then
                        OldStrPtr=$StrPtr
                        if [[ ${inputs} = [sS] ]]; then  if [[ $StrPtr -eq 12 ]]; then StrPtr=0; else let "StrPtr++"; fi; fi
                        if [[ ${inputs} = [wW] ]]; then if [[ $StrPtr -eq 0 ]]; then StrPtr=12; else let "StrPtr--"; fi; fi
                        GET_CURRENT_STRUCT
                        if [[ $inputs = [sS] && $StrPtr -lt 6 && $StrPtr -ge 0 ]]; then
                           if [[ $ObjPtr = 3 && $StrPtr = 1 ]]; then let "ObjPtr=4"; fi
                                if [[ $ObjPtr = 4 && $StrPtr = 2 ]]; then let "ObjPtr=5"; fi
                                    if [[ $ObjPtr = 5 && ( $StrPtr = 2 || $StrPtr = 4 ) ]]; then let "ObjPtr=2"
                                            elif [[ $ObjPtr = 2 && ( $StrPtr = 3 || $StrPtr = 5 ) ]]; then let "ObjPtr=5"
                                                elif [[ $ObjPtr -gt 1  && ( $StrPtr = 2 || $StrPtr = 4 ) ]]; then let "StrPtr++"; GET_CURRENT_STRUCT; fi 
      
                        elif [[ $inputs = [wW] && $StrPtr -lt 6 && $StrPtr -gt 0 ]]; then
                            if [[ $ObjPtr = 5 && ( $StrPtr = 2 || $StrPtr = 4 ) ]]; then let "ObjPtr=2"
                                elif [[ $ObjPtr = 4 && $StrPtr = 2 ]]; then let "ObjPtr=2"
                                    elif [[ $ObjPtr = 2 && ( $StrPtr = 1 || $StrPtr = 3 ) ]]; then let "ObjPtr=5"
                                        elif [[ $ObjPtr -gt 1  && ( $StrPtr = 2 || $StrPtr = 4 ) ]]; then let "StrPtr--"; GET_CURRENT_STRUCT; fi
                        fi            
                        if [[ $ObjPtr -gt $((CurrStrSize-1)) ]]; then ObjPtr=$((CurrStrSize-1)); OldObjPtr=$ObjPtr; fi

                        SHOW_CURSOR
                        GET_ITEM_COLOR
                    fi

                    if [[ ${inputs} = [hH] ]]; then let "hints++"; if [[ $hints = 3 ]]; then hints=0; fi; UPDATE_BOTTOM
                        GET_CURRENT_STRUCT
                        if [[ $ObjPtr -gt $((CurrStrSize-1)) ]]; then ObjPtr=1; fi
                        CLEAR_BOTTOM; sleep 0.1; SET_SCREEN
                        SHOW_CURSOR
                        GET_ITEM_COLOR
                        if [[ $hidden = 1 ]]; then inputs="F"; fi
                    fi

                    if [[ ${inputs} = [0-7] ]]; then
                               
                               case ${inputs} in  
                             1)   if [[ $cl_bold = 1 ]]; then cl_bold=0; elif [[ $cl_bold = 0 ]]; then cl_bold=1; cl_normal=0; fi;;
                             2)   if [[ $cl_dim = 1 ]]; then cl_dim=0; elif [[ $cl_dim = 0 ]]; then cl_dim=1; cl_normal=0; fi;;
                             3)   if [[ $cl_underl = 1 ]]; then cl_underl=0; elif [[ $cl_underl = 0 ]]; then cl_underl=1; cl_normal=0; fi ;;
                             4)   if [[ $cl_blink = 1 ]]; then cl_blink=0; elif [[ $cl_blink = 0 ]]; then cl_blink=1; cl_normal=0; fi ;;
                             5)   if [[ $cl_inv = 1 ]]; then cl_inv=0; elif [[ $cl_inv = 0 ]]; then cl_inv=1; cl_normal=0; fi ;;
                             6)   if [[ $cl_bit = 1 ]]; then cl_bit=0; fi ; printf '\033[?25l'; MAKE_COLOR; SET_STRIP; printf '\033[33;36f'; printf ' %.0s' {1..48}; code=37; if [[ ${code} -ge 30 ]] && [[ ${code} -le 37 ]]; then let "NN=(code-29)*3+34" ;fi ; STRIP_POINTER ON ;;  
                             7)   if [[ $cl_bit = 0 ]]; then cl_bit=1; fi ; printf '\033[?25l'; STRIP_POINTER OFF; code=7; PROGRESSBAR;;
                             0)   if [[ $cl_normal = 0 ]]; then cl_normal=1;  fi ;;
                               esac
                             if [[ $cl_bold = 0 ]] && [[ $cl_dim = 0 ]] && [[ $cl_underl = 0 ]] && [[ $cl_blink = 0 ]] && [[ $cl_inv = 0 ]]; then cl_normal=1; fi
                              
                             MAKE_COLOR
                             SHOW_NEW_ITEM_COLOR
                             SET_STRIP                          
                             SHOW_TEXT_FLAGS
                             SHOW_CURSOR
                            
                    fi

                if [[ $inputs = [lL] ]]; then 
                    if [[ $LoaderPointer1 = "" ]]; then LoaderPointer1="Clover"; LoaderPointer2="OpenCore"; SET_LOADER_STRUCT $LoaderPointer1; SET_LOADER_STRUCT "$LoaderPointer2"
                        elif [[ $LoaderPointer1 = "Clover" ]]; then LoaderPointer1="Windows"; LoaderPointer2="Linux"; SET_LOADER_STRUCT $LoaderPointer1; SET_LOADER_STRUCT "$LoaderPointer2"
                            elif [[ $LoaderPointer1 = "Windows" ]]; then LoaderPointer1="Refind"; LoaderPointer2="$unrec"; if [[ $loc = "ru" ]]; then unrec="Не распознан"; else unrec="Unrecognized"; fi; SET_LOADER_STRUCT $LoaderPointer1; SET_LOADER_STRUCT "$LoaderPointer2"
                                elif [[ $LoaderPointer1 = "Refind" ]]; then LoaderPointer1="" ; LoaderPointer2="" ; SET_STRUCT_1 3; SET_STRUCT_1 5; fi

                    if [[ $LoaderPointer1 = "" ]]; then ObjPtr=1; else ObjPtr=5; fi
                    StrPtr=3
                    GET_CURRENT_STRUCT
                    GET_ITEM_COLOR
                    SHOW_CURSOR
                fi

                
                if [[ $inputs = [fF] ]]; then 
                        if [[ $hidden = 0 ]]; then hidden=1; SET_STRUCT_3 1; SET_STRUCT_3 12 ; SET_STRUCT_3 3; SET_STRUCT_3 5; else hidden=0; SET_STRUCT_1 1; SET_STRUCT_2 12; SET_STRUCT_1 3; SET_STRUCT_1 5; fi
                        ObjPtr=1; StrPtr=3
                        GET_CURRENT_STRUCT
                        GET_ITEM_COLOR
                        SHOW_CURSOR
                fi
                
           if [[ $inputs = [xX] ]] && [[ $cl_bit = 0 ]]; then
             if [[ "$lastEditItem" = "$StrPtr,$ObjPtr" ]]; then        
                STRIP_POINTER OFF
                
                if [[ ${code} = 37 ]]; then code=90 ; elif [[ ${code} = 97 ]]; then code=30
                    else
                if [[ ${code} -ge 30 ]] && [[ ${code} -le 36 ]]; then let "code++"; fi
                if [[ ${code} -ge 90 ]] && [[ ${code} -le 96 ]]; then let "code++"; fi
                    fi
                if [[ ${code} -ge 30 ]] && [[ ${code} -le 37 ]]; then let "NN=(code-29)*3+34" ;fi 
                if [[ ${code} -ge 90 ]] && [[ ${code} -le 97 ]]; then let "NN=3*(code-89)+58"; fi
 
                STRIP_POINTER ON
             else
                SHOW_ITEM_COLOR
             fi              
                MAKE_COLOR
                SHOW_NEW_ITEM_COLOR
                lastEditItem="$StrPtr,$ObjPtr"
                if [[ $strip = 1 ]]; then SET_STRIP; fi
               
         fi

         if [[ $inputs = [zZ] ]] && [[ $cl_bit = 0 ]]; then
            if [[ "$lastEditItem" = "$StrPtr,$ObjPtr" ]]; then          
                STRIP_POINTER OFF

                if [[ ${code} = 30 ]]; then code=97 ; elif [[ ${code} = 90 ]]; then code=37
                    else
                if [[ ${code} -ge 31 ]] && [[ ${code} -le 37 ]]; then let "code--"; fi
                if [[ ${code} -ge 91 ]] && [[ ${code} -le 97 ]]; then let "code--"; fi
                    fi
                if [[ ${code} -ge 30 ]] && [[ ${code} -le 37 ]]; then let "NN=(code-29)*3+34" ;fi 
                if [[ ${code} -ge 90 ]] && [[ ${code} -le 97 ]]; then let "NN=3*(code-89)+58"; fi
 
                STRIP_POINTER ON
            else
                SHOW_ITEM_COLOR
            fi              
                MAKE_COLOR
                SHOW_NEW_ITEM_COLOR
                lastEditItem="$StrPtr,$ObjPtr"
                if [[ $strip = 1 ]]; then SET_STRIP; fi                
         fi

              if [[ $inputs = [zZ] ]] && [[ $cl_bit = 1 ]]; then
                if [[ "$lastEditItem" = "$StrPtr,$ObjPtr" ]]; then
                    if [[ $code -gt 0 ]]; then let "code--"; else code=255; fi
                    PROGRESSBAR
                else
                    SHOW_ITEM_COLOR
                fi
                    MAKE_COLOR
                    SHOW_NEW_ITEM_COLOR
                    lastEditItem="$StrPtr,$ObjPtr"
                    SET_STRIP 
              fi

                if [[ $inputs = [xX] ]] && [[ $cl_bit = 1 ]]; then
                  if [[ "$lastEditItem" = "$StrPtr,$ObjPtr" ]]; then
                    if [[ $code -lt 255 ]]; then let "code++"; else code=0; fi
                    PROGRESSBAR
                  else
                    SHOW_ITEM_COLOR
                  fi
                    MAKE_COLOR
                    SHOW_NEW_ITEM_COLOR
                    lastEditItem="$StrPtr,$ObjPtr"
                    SET_STRIP 
                fi
                if [[ $inputs = [cC] ]] && [[ $cl_bit = 1 ]]; then
                  if [[ "$lastEditItem" = "$StrPtr,$ObjPtr" ]]; then
                    if [[ $code -gt 9 ]]; then let "code=code-6"; else code=255; fi
                    PROGRESSBAR
                  else
                      SHOW_ITEM_COLOR
                  fi
                    MAKE_COLOR
                    SHOW_NEW_ITEM_COLOR
                    lastEditItem="$StrPtr,$ObjPtr"
                    SET_STRIP 
                fi

                if [[ $inputs = [vV] ]] && [[ $cl_bit = 1 ]]; then
                  if [[ "$lastEditItem" = "$StrPtr,$ObjPtr" ]]; then
                    if [[ $code -lt 245 ]]; then let "code=code+6"; else code=0; fi
                    PROGRESSBAR
                  else
                     SHOW_ITEM_COLOR
                  fi
                    MAKE_COLOR
                    SHOW_NEW_ITEM_COLOR
                    lastEditItem="$StrPtr,$ObjPtr"
                    SET_STRIP 
                fi

                if [[ $inputs = [eE] ]]; then 
                                    if [[ $cl_bit = 0 ]]; then STRIP_POINTER OFF; fi
                                    currentModeItem=$(echo ${CurrStrList[ObjPtr]} | cut -f1 -d',')
                                    if [[ ! ${new_cm[currentModeItem]} = "" ]]; then cm[currentModeItem]=${new_cm[currentModeItem]}; unset new_cm[currentModeItem]
                                        else
                                    new_cm[currentModeItem]=${cm[currentModeItem]};cm[currentModeItem]=${old_cm[currentModeItem]}
                                    fi
                                    GET_ITEM_COLOR
                                    MAKE_COLOR
                                    SHOW_NEW_ITEM_COLOR
                                    SHOW_ITEM_COLOR
                                    SHOW_CURSOR                                    
                fi

            if [[ ${inputs} = [tT] ]]; then NewItemColor="$oldNewItemColor"; SHOW_NEW_ITEM_COLOR; SHOW_CURSOR; fi

            if [[ ${inputs} = [rR] ]]; then SHOW_NEW_ITEM_COLOR; SHOW_CURSOR; fi

            if [[ ${inputs} = [pP] ]]; then DELETE_OR_TAKE_NEW_PRESET; fi
            
            if [[ $inputs = [qQ] || $init -gt 1 ]]; then 
                if [[ ! $presetName = "false" &&  $inputs = [qQ] ]] ; then SAVE_COLOR_MODE_PRESET; fi
                if [[ $init -gt 1 ]]; then unset presetName; fi
                if [[ $inputs = [qQ] && $init -lt 2 ]]; then presetName="false"; fi
                unset inputs; cvar=1; break
            fi
            if [[ $inputs = "" ]]; then printf "\033[2A"; break; fi
            read -s -n 1  inputs
           if [[ "${inputs}" = $(printf '\033') ]]; then read -r -s -n 2 keys 
           case "${inputs}" in
                '[A') inputs="R" ; break ;;
                '[B') inputs="V" ; break ;;
                '[D') inputs="D" break ;;
                '[C') inputs="F" break;;
            esac
             fi        
done

fi
}
if [[ -f "${SERVFOLD_PATH}"/presetName ]]; then presetName=$(cat "${SERVFOLD_PATH}"/presetName | tr -d '\n'); rm -f "${SERVFOLD_PATH}"/presetName; fi
if [[ -f "${CONFPATH}" ]]; then
while true; do EDIT_COLORS "${presetName}"; if [[ "$presetName" = "false" ]]; then break; fi; done
#printf "\e[0m\033[?25h"
else
    if [[ $loc = "ru" ]]; then
    error_message='"Это редактор для программы MountEFI.\nФайл конфигурации MountEFI не найден.\n\nВыполнение прекращено!"'
    osascript -e 'display dialog '"${error_message}"'  with icon caution buttons { "Прекратить" } default button "Прекратить" giving up after 10' >>/dev/null 2>/dev/null
    else
    error_message='"This is MountEFI GUI editor.\nMountEFI config file not found.\n\nExecution canceled!"'
    osascript -e 'display dialog '"${error_message}"'  with icon caution buttons { "Abort" } default button "Abort" giving up after 10' >>/dev/null /2>/dev/null
    fi
fi
if [[ ! "$presetName" = "Init180061Mode" ]]; then
theme="system"
GET_THEME
if [[ $theme = "built-in" ]]; then CUSTOM_SET; else SET_SYSTEM_THEME; fi &
fi
clear && printf '\e[8;24;80t' && printf '\e[3J' && printf "\033[H"
}

COLOR_MODE_EDITOR



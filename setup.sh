#!/bin/bash

# функция отладки ###############################################
demo1="0"
deb=0


DEBUG(){
if [[ ! $deb = 0 ]]; then
printf '\n\n Останов '"$stop"'  :\n\n' 
printf '............................................................\n' 
#echo "lines = "$lines
#echo "inputs = "$inputs
#echo "slist = "${slist[@]}
#echo "nslist = "${nslist[@]}
#echo "apos = "$apos
#echo "strng = "$strng
#echo "strng2 = "$strng2
#echo "uuid = "$uuid
#echo "vari = "$vari
#echo "num1 = "$num1
#echo "pnum = "$pnum
#echo "alist(poi) = "${alist[$poi]}
#echo "ddcorr = "$ddcorr >> ~/temp.txt
#echo "corr = "$corr >> ~/temp.txt
#echo "scorr = "$scorr >> ~/temp.txt
#printf 'strng = *'$strng'*\n' 
#printf 'drive = *'"$drive"'*\n' 
#printf 'len ddrive = '${#ddrive}'\n' >> ~/temp.txt
#echo "strng = "$strng >> ~/temp.txt
#echo "adrive = ""$adrive" >> ~/temp.txt


printf '............................................................\n\n' 
sleep 0.5
read  -s -n1 
fi
}
#########################################################################################################################################
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
if [[ ${TTYc} = 0  ]]; then  sleep 0.5; osascript -e 'quit app "terminal.app"' & exit
	else
    sleep 1.2; osascript -e 'tell application "Terminal" to close first window' & exit
fi
}

#########################################################




# MountEFI версия скрипта настроек 1.3.2 master
# Добавлены опции автомонтирования 
# Добавлены  в конфиг настройки  цвета для встроенных тем вида {65535, 48573, 50629} По именам тоже работает как и ранее
# Добавлена очистка отсутствующих томов из автомонтирования
# Исключены mbr носители из автомонтирования ввиду ненужности. Они всегда монтируются системой автоматически. 
# Очистка от записей MountEFI истории bash перед выходом
# Установка таймаута закрытия программы после автомонтировая
# Автосокрытие курсора командами printf "\033[?25l"/ printf "\033[?25h"
# Возможность сохранять в конфиге псевдоним для вывода вместо имени физического диска
# Ускорено сканирование дисков
# Фиксы удвоения данных и испраление ошибки поиска системного раздела
# Добавление английского и обозначения размера поля ввода  в редактирование псевдонимов
# Авто переключение раскладки на латиницу после ввода псевдонима (если есть утилита в папке)
# Исправлен вывод размера разделов
# Фикс автопереключения раскладки на Мохаве
# Добавлен детект подключения / отключения медиа


#clear && printf "\033[0;0H"



cd $(dirname $0)


SET_LOCALE(){

if [[ -f ${HOME}/.MountEFIconf.plist ]] ; then
        locale=`cat ${HOME}/.MountEFIconf.plist | grep -A 1 "Locale" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
        if [[ ! $locale = "ru" ]] && [[ ! $locale = "en" ]]; then loc=`locale | grep LANG | sed -e 's/.*LANG="\(.*\)_.*/\1/'`
            else
                loc=`echo ${locale}`
        fi
    else   
        loc=`locale | grep LANG | sed -e 's/.*LANG="\(.*\)_.*/\1/'`
fi
            if [[ $loc = "ru" ]]; then
if [[ $locale = "ru" ]]; then loc_set="русский"; loc_corr=6; fi
if [[ $locale = "en" ]]; then loc_set="английский"; loc_corr=3; fi
if [[ $locale = "auto" ]]; then loc_set="автовыбор"; loc_corr=4; fi
            else
if [[ $locale = "ru" ]]; then loc_set="russian"; loc_corr=23; fi
if [[ $locale = "en" ]]; then loc_set="english"; loc_corr=23; fi
if [[ $locale = "auto" ]]; then loc_set="auto"; loc_corr=26; fi
            fi

}

GET_MENUE(){
menue=0
HasMenue=`cat ${HOME}/.MountEFIconf.plist | grep -A 1 "Menue" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
if [[ $HasMenue = "always" ]]
    then 
    menue=1
        if [[ $loc = "ru" ]]; then
    menue_set="всегда"; menue_corr=17
        else
    menue_set="always"; menue_corr=30
        fi
    else
            if [[ $loc = "ru" ]]; then
        menue_set="автовыбор"; menue_corr=14 
            else
        menue_set="auto"; menue_corr=32
            fi
fi

}

GET_OPENFINDER(){
OpenFinder=1
strng=`cat ${HOME}/.MountEFIconf.plist | grep -A 1 -e "OpenFinder</key>" | grep false | tr -d "<>/"'\n\t'`
if [[ $strng = "false" ]]; then OpenFinder=0
            if [[ $loc = "ru" ]]; then
        OpenFinder_set="Нет"; of_corr=7
            else
        OpenFinder_set="No"; of_corr=19
            fi
    else
            if [[ $loc = "ru" ]]; then
        OpenFinder_set="Да"; of_corr=8
            else
        OpenFinder_set="Yes"; of_corr=18
            fi
fi
}

GET_SHOWKEYS(){
ShowKeys=1
strng=`cat ${HOME}/.MountEFIconf.plist | grep -A 1 -e "ShowKeys</key>" | grep false | tr -d "<>/"'\n\t'`
if [[ $strng = "false" ]]; then ShowKeys=0
            if [[ $loc = "ru" ]]; then
        ShowKeys_set="Нет"; sk_corr=3
            else
        ShowKeys_set="No"; sk_corr=22
            fi
    else
            if [[ $loc = "ru" ]]; then
        ShowKeys_set="Да"; sk_corr=4
            else
        ShowKeys_set="Yes"; sk_corr=21
            fi
fi
}


GET_PRESETS_COUNTS(){
pcount=0
#pcount=`cat ${HOME}/.MountEFIconf.plist | grep -A 1  -e "<key>PresetsCounts</key>" | grep integer | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
pstring=`cat ${HOME}/.MountEFIconf.plist | grep  -e "<key>BackgroundColor</key>" | sed -e 's/.*>\(.*\)<.*/\1/' | tr ' \n' ';'`
IFS=';'; slist=($pstring); unset IFS;
pcount=${#slist[@]}
unset slist
unset pstring
}

GET_PRESETS_NAMES(){
pstring=`cat ${HOME}/.MountEFIconf.plist | grep  -B 2 -e "<key>BackgroundColor</key>" | grep key | sed -e 's/.*>\(.*\)<.*/\1/' | sed 's/BackgroundColor/;/g' | tr -d '\n'`
IFS=';'; plist=($pstring); unset IFS
unset pstring
}

GET_THEME(){
if [[ -f ${HOME}/.MountEFIconf.plist ]]; then
HasTheme=`cat ${HOME}/.MountEFIconf.plist | grep -E "<key>Theme</key>" | grep -Eo Theme | tr -d '\n'`
    if [[ $HasTheme = "Theme" ]]; then
theme=`cat ${HOME}/.MountEFIconf.plist |  grep -A 1 -e  "<key>Theme</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
    fi
fi
if [[ $theme = "system" ]]; then 
                if [[ $loc = "ru" ]]; then
            theme_set="системная"; theme_corr=14
                else
            theme_set="system"; theme_corr=30
                fi
    else
                if [[ $loc = "ru" ]]; then
            theme_set="встроенная"; theme_corr=13
                else
            theme_set="built-in"; theme_corr=28
                fi
fi
        
itheme_set=`cat ${HOME}/.MountEFIconf.plist | grep -A 1 -e "<key>CurrentPreset</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
        
GET_PRESETS_COUNTS

tlenth=`echo ${#itheme_set}`
if [[ $loc = "ru" ]]; then
let "btheme_corr=18-tlenth"
btspc_corr=19
else
let "btheme_corr=23-tlenth"
fi

}


SET_THEMES(){

HasTheme=`cat ${HOME}/.MountEFIconf.plist | grep -Eo "Theme"  | tr -d '\n'`
if [[ ! $HasTheme = "Theme" ]]; then
plutil -replace Theme -string system ${HOME}/.MountEFIconf.plist
else
 theme=`cat ${HOME}/.MountEFIconf.plist | grep -A 1 "Theme" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
   if [[ $theme = "system" ]]; then 
                GET_PRESETS_COUNTS
                CUSTOM_SET
 #               if [[ ! $pcount = 1 ]]; then
                plutil -replace Theme -string built-in ${HOME}/.MountEFIconf.plist
                GET_PRESETS_NAMES
                current=`cat ${HOME}/.MountEFIconf.plist | grep -A 1 -e "<key>CurrentPreset</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
 
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
                current=`cat ${HOME}/.MountEFIconf.plist | grep -A 1 -e "<key>CurrentPreset</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
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
                    plutil -replace CurrentPreset -string "${plist[$num]}" ${HOME}/.MountEFIconf.plist
                    unset demo
                    CUSTOM_SET
                fi
                   printf "\r\033[2A"
               
                
if [[ $demo = [sS] ]]; then let "var2=0"; fi

                
                done
 
        else
            plutil -replace Theme -string system ${HOME}/.MountEFIconf.plist
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

current=`cat ${HOME}/.MountEFIconf.plist | grep -A 1 -e "<key>CurrentPreset</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
current_background=`cat ${HOME}/.MountEFIconf.plist | grep -A 10 -E "<key>$current</key>" | grep -A 1 "BackgroundColor" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
current_foreground=`cat ${HOME}/.MountEFIconf.plist | grep -A 10 -E "<key>$current</key>" | grep -A 1 "TextColor" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
current_fontname=`cat ${HOME}/.MountEFIconf.plist | grep -A 10 -E "<key>$current</key>" | grep -A 1 "FontName" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
current_fontsize=`cat ${HOME}/.MountEFIconf.plist | grep -A 10 -E "<key>$current</key>" | grep -A 1 "FontSize" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`

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

########################## Инициализация нового конфига ##################################################################################

deleted=0
if [[ -f ${HOME}/.MountEFIconf.plist ]]; then
strng=`cat ${HOME}/.MountEFIconf.plist | grep -e "<key>CurrentPreset</key>" | grep key | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\t\n'`
      if [[ ! $strng = "CurrentPreset" ]]; then
        mypassword="0"
        login=`cat ${HOME}/.MountEFIconf.plist | grep -Eo "LoginPassword"  | tr -d '\n'`
                if [[ $login = "LoginPassword" ]]; then
        mypassword=`cat ${HOME}/.MountEFIconf.plist | grep -A 1 "LoginPassword" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
                fi
        theme=`cat ${HOME}/.MountEFIconf.plist |  grep -A 1 -e  "<key>Theme</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
        rm ${HOME}/.MountEFIconf.plist
        deleted=1
    fi
fi
         

if [[ ! -f ${HOME}/.MountEFIconf.plist ]]; then
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


strng=`cat ${HOME}/.MountEFIconf.plist | grep -e "<key>ShowKeys</key>" | grep key | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\t\n'`
if [[ ! $strng = "ShowKeys" ]]; then plutil -replace ShowKeys -bool YES ${HOME}/.MountEFIconf.plist; fi

strng=`cat ${HOME}/.MountEFIconf.plist | grep -e "<key>AutoMount</key>" | grep key | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\t\n'`
if [[ ! $strng = "AutoMount" ]]; then 
			plutil -insert AutoMount -xml  '<dict/>'   ${HOME}/.MountEFIconf.plist
			plutil -insert AutoMount.Enabled -bool NO ${HOME}/.MountEFIconf.plist
			plutil -insert AutoMount.ExitAfterMount -bool NO ${HOME}/.MountEFIconf.plist
			plutil -insert AutoMount.Open -bool NO ${HOME}/.MountEFIconf.plist
			plutil -insert AutoMount.PartUUIDs -string " " ${HOME}/.MountEFIconf.plist
fi

strng=`cat ${HOME}/.MountEFIconf.plist | grep AutoMount -A 11 | grep -o "Timeout2Exit" | tr -d '\n'`
if [[ ! $strng = "Timeout2Exit" ]]; then
            plutil -insert AutoMount.Timeout2Exit -integer 5 ${HOME}/.MountEFIconf.plist
fi

strng=`cat ${HOME}/.MountEFIconf.plist | grep -e "<key>RenamedHD</key>" |  sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\t\n'`
if [[ ! $strng = "RenamedHD" ]]; then
            plutil -insert RenamedHD -string " " ${HOME}/.MountEFIconf.plist
fi
#########################################################################################################################################

################################## функция автодетекта подключения ##############################################################################################
CHECK_HOTPLUG(){
ustring=`ioreg -c IOMedia -r  | grep "<class IOMedia," | cut -f1 -d"<" | sed 's/+-o/;/'` ; IFS=";"; uuid_list=($ustring); unset IFS; uuid_count=${#uuid_list[@]};
        if [[ ! $old_uuid_count = $uuid_count ]]; then inputs=0; old_uuid_count=$uuid_count
            
        fi
}
###################################################################################################################################################################


GET_UUID_S(){
ioreg_iomedia=`ioreg -c IOMedia -r | tr -d '"|+{}\t'`
uuids_iomedia=`echo "$ioreg_iomedia" | sed '/Statistics =/d'  | egrep -A12 -B12 "UUID ="`

}


GET_EFI_S(){

ioreg_iomedia=`ioreg -c IOMedia -r | tr -d '"|+{}\t'`

strng=`diskutil list | grep EFI | grep -oE '[^ ]+$' | xargs | tr ' ' ';'`
disk_images=`echo "$ioreg_iomedia" | egrep -A 22 "Apple UDIF" | grep "BSD Name" | cut -f2 -d "="  | tr -d " " | tr '\n' ';'`

IFS=';' 
slist=($strng)
ilist=($disk_images)
unset IFS;
pos=${#slist[@]}
posi=${#ilist[@]}

drives_iomedia=`echo "$ioreg_iomedia" |  egrep -A 22 "<class IOMedia,"`
sizes_iomedia=`echo "$ioreg_iomedia" |  sed -e s'/Logical Block Size =//' | sed -e s'/Physical Block Size =//' | sed -e s'/Preferred Block Size =//' | sed -e s'/EncryptionBlockSize =//'`

CHECK_HOTPLUG

}

GET_EFI_S

if [[ $par = "-r" ]]; then
ShowKeys=1
strng=`cat ${HOME}/.MountEFIconf.plist | grep -A 1 -e "ShowKeys</key>" | grep false | tr -d "<>/"'\n\t'`
if [[ $strng = "false" ]]; then ShowKeys=0; fi
if [[ $ShowKeys = 1 ]]; then lines=25; else lines=22; fi
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



# Установка/удаление пароля для sudo через конфиг
SET_USER_PASSWORD(){
if [[ -f ${HOME}/.MountEFIconf.plist ]]; then
login=`cat ${HOME}/.MountEFIconf.plist | grep -Eo "LoginPassword"  | tr -d '\n'`
    if [[ $login = "LoginPassword" ]]; then
                printf '\n\n'
                if [[ $loc = "ru" ]]; then
                echo "удалить сохранённый пароль из программы?"
                        else
                echo "delete saved password from this programm?"
                    fi
                read -p "(y/N) " -n 1 -r -s
                if [[ $REPLY =~ ^[yY]$ ]]; then
                plutil -remove LoginPassword ${HOME}/.MountEFIconf.plist
                if [[ $loc = "ru" ]]; then
                echo "пароль удалён. нажмите любую клавишу для продолжения ..."
                        else
                echo "password removed. press any key to continue...."
                    fi
                read -n 1 demo
                fi
        else
                
                printf '\n\n'
                    if [[ $loc = "ru" ]]; then
                echo "введите ваш пароль для постоянного хранения:"
                        else
                echo "enter password to save it into this programm:"
                    fi
                printf '\n'
                read -s mypassword
                if [[ $mypassword = "" ]]; then mypassword="?"; fi
                if echo $mypassword | sudo -Sk printf '' 2>/dev/null; then
                plutil -replace LoginPassword -string $mypassword ${HOME}/.MountEFIconf.plist
                printf "\r\033[1A"
                if [[ $loc = "ru" ]]; then
                printf '\nпароль '$mypassword' сохранён. нажмите любую клавишу для продолжения ...'
                        else
                printf '\n password '$mypassword' saved. press any key to continue....'
                    fi
                read -n 1 demo
                else
                printf "\r\033[1A"
                    if [[ $loc = "ru" ]]; then
                printf '\nНе верный пароль '$mypassword' не сохранён.\n'
                #printf 'нажмите любую клавишу для продолжения ...'
                        else
                printf '\nWrong password '$mypassword' not saved. \n'
                #printf 'press any key to continue....'
                    fi
                read -n 1 demo
                 
                
        fi
    fi
fi
}

#Получение пароля для sudo из конфига
GET_USER_PASSWORD(){
mypassword="0"
if [[ -f ${HOME}/.MountEFIconf.plist ]]; then
login=`cat ${HOME}/.MountEFIconf.plist | grep -Eo "LoginPassword"  | tr -d '\n'`
    if [[ $login = "LoginPassword" ]]; then
mypassword=`cat ${HOME}/.MountEFIconf.plist | grep -A 1 "LoginPassword" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
    fi
fi

if [[ $mypassword = 0 ]]
         then 
                    if [[ $loc = "ru" ]]; then
               mypassword_set="нет пароля"; pass_corr=9
                    else
               mypassword_set="not saved"; pass_corr=24
                    fi
    else 
        mypassword_set=`echo ${mypassword}`
        passl=`echo ${#mypassword}`
        if [[ $loc = "ru" ]]; then
        let "pass_corr=19-passl"
        else
        let "pass_corr=33-passl"
        fi
        
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
#        if [[ $loc = "ru" ]]; then
#printf '\n                          ! Смените раскладку на латиницу !\n'
 #           else
#printf '\n                          ! Change layout to UTF-8 ABC, US or EN !\n'
        #fi
	 fi
fi
}

REM_ABSENT(){
strng1=`cat ${HOME}/.MountEFIconf.plist | grep AutoMount -A 9 | grep -A 1 -e "PartUUIDs</key>"  | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
alist=($strng1); apos=${#alist[@]}
if [[ ! $apos = 0 ]]
	then
		var8=$apos
		posb=0
		while [[ ! $var8 = 0 ]]
					do
						if ! diskutil quiet info  ${alist[$posb]}  >&- 2>&- ; then  
						strng2=`echo ${strng1[@]}  |  sed 's/'${alist[$posb]}'//'`
						plutil -replace AutoMount.PartUUIDs -string "$strng2" ${HOME}/.MountEFIconf.plist
						strng1=$strng2
						fi
					let "posb++"
					let "var8--"
					done
alist=($strng1); apos=${#alist[@]}
fi
}

GET_AUTOMOUNT(){
autom_enabled=0
strng=`cat ${HOME}/.MountEFIconf.plist | grep AutoMount -A 3 | grep -A 1 -e "Enabled</key>" | grep true | tr -d "<>/"'\n\t'`
if [[ $strng = "true" ]]; then autom_enabled=1
            if [[ $loc = "ru" ]]; then
        am_set="Да"; am_corr=9
            else
        am_set="Yes"; am_corr=14
            fi
    else
            if [[ $loc = "ru" ]]; then
        am_set="Нет"; am_corr=8
            else
        am_set="No"; am_corr=15
            fi
fi
}

GETAUTO_OPEN(){
autom_open=0
strng=`cat ${HOME}/.MountEFIconf.plist | grep AutoMount -A 7 | grep -A 1 -e "Open</key>" | grep true | tr -d "<>/"'\n\t'`
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
strng=`cat ${HOME}/.MountEFIconf.plist | grep AutoMount -A 5 | grep -A 1 -e "ExitAfterMount</key>" | grep true | tr -d "<>/"'\n\t'`
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
strng=`cat ${HOME}/.MountEFIconf.plist | grep AutoMount -A 11 | grep -A 1 -e "Timeout2Exit</key>"  | grep integer | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
if [[ ! $strng = "" ]]; then auto_timeout=$strng; fi
ncorr=${#auto_timeout}
        if [[ $loc = "ru" ]]; then
         let "tmo_corr=5-ncorr" 
            else
         let "tmo_corr=11-ncorr"
            fi
}

GETEFI(){

GET_FULL_EFI

#GET_EFI_S

#if [[ $par = "-r" ]]; then
#ShowKeys=1
#strng=`cat ${HOME}/.MountEFIconf.plist | grep -A 1 -e "ShowKeys</key>" | grep false | tr -d "<>/"'\n\t'`
#if [[ $strng = "false" ]]; then ShowKeys=0; fi
#if [[ $ShowKeys = 1 ]]; then lines=25; else lines=22; fi
#else
#lines=22 
#fi
#let "lines=lines+pos"
}


GET_AUTOMOUNTED(){
strng1=`cat ${HOME}/.MountEFIconf.plist | grep AutoMount -A 9 | grep -A 1 -e "PartUUIDs</key>"  | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
alist=($strng1); apos=${#alist[@]}
}


SHOW_AUTOEFI(){

rm -f ~/.SetupMountEFItemp.txt
printf '\e[8;'${lines}';80t' && printf '\e[3J' && printf "\033[0;0H" 
 if [[ $loc = "ru" ]]; then
  printf '\nВыберите раздел и опции автомонтирования:                                      '
			else
        printf '\nSelect a partition and automount options:                                     '
	                 fi
var0=$pos; num1=0 ; ch=0

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

	     #dsze=`diskutil info /dev/${strng} | grep "$vmacos" | sed -e 's/.*Size:\(.*\)Bytes.*/\1/' | cut -f1 -d"(" | rev | sed 's/[ \t]*$//' | rev`
         
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
    #uuid=`diskutil info  $strng | grep  "Disk / Partition UUID:" | sed 's|.*:||' | tr -d '\n\t '`
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

            drive=`echo "$drives_iomedia" | grep -B 10 ${dstrng} | grep -m 1 -w "Media"  | cut -f1 -d "<" | sed -e s'/-o //'  | sed -e s'/Media//' | sed 's/ *$//' | tr -d "\n"`

            string1=$strng
            GET_RENAMEHD
            strng=$string1
            if [[ ! ${adrive} = "±" ]]; then drive="${adrive}"; fi
            dcorr=${#drive}
		    if [[ ${dcorr} -gt 30 ]]; then dcorr=0; drv="${drive:0:30}"; else let "dcorr=30-dcorr"; fi
            



	                 if [[ ! $mcheck = "Yes" ]]; then
			printf '\n      '$ch') ...   '"$drive""%"$dcorr"s"'    '${string}"%"$corr"s""%"$scorr"s"' '"$dsze"'     '  >> ~/.MountEFItemp.txt
		else
			printf '\n      '$ch')   +   '"$drive""%"$dcorr"s"'    '${string}"%"$corr"s""%"$scorr"s"' '"$dsze"'     '  >> ~/.MountEFItemp.txt
		fi


#          вывод подготовленного формата строки в файл "буфер экрана"
    if [[ $unuv = 1 ]]; then
            printf '\n      '$ch')   x    '"$drive""%"$dcorr"s"'    '${strng}"%"$corr"s""%"$scorr"s"' '"$dsze"'     '  >> ~/.SetupMountEFItemp.txt
                else
	if [[ $automounted = 0 ]]; then
			printf '\n      '$ch') ....   '"$drive""%"$dcorr"s"'    '${strng}"%"$corr"s""%"$scorr"s"' '"$dsze"'     '  >> ~/.SetupMountEFItemp.txt
		else
			printf '\n      '$ch') auto   '"$drive""%"$dcorr"s"'    '${strng}"%"$corr"s""%"$scorr"s"' '"$dsze"'     '  >> ~/.SetupMountEFItemp.txt
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

UPDATE_KEYS_INFO(){

GETAUTO_OPEN
GETAUTO_EXIT
GETAUTO_TIMEOUT
 if [[ $loc = "ru" ]]; then
#printf '\n'
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

UPDATE_AUTOEFI(){
printf '\e[8;'${lines}';80t' && printf '\e[3J' && printf "\033[0;0H" 
 if [[ $loc = "ru" ]]; then
  printf '\nВыберите раздел и опции автомонтирования:                                      '
			else
        printf '\nSelect a partition and automount options:                                     '
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

cat   ~/.SetupMountEFItemp.txt

printf '\n\n     '
	printf '.%.0s' {1..68}
printf '\n'

}

SET_AUTOMOUNT(){
clear
REM_ABSENT
GETEFI
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
printf '  Введите число от 0 до '$ch' (или O, C, D, E ):   ' ; printf '                             '
			else
printf '  Enter a number from 0 to '$ch' (or O, C, D, E ):   ' ; printf '                           '
                fi
printf "%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"
printf "\033[4A"
printf "\r\033[48C"
printf "\033[?25h"
inputs="±"
while [[ $inputs = "±" ]]
do
IFS="±"; read -n 1 -t 1 inputs ; unset IFS  ; CHECK_HOTPLUG
done
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
fi

if [[  ${inputs}  = [qQ] ]]; then
			GET_AUTOMOUNTED
			if [[ $apos = 0 ]]; then 
				plutil -replace AutoMount.Enabled -bool NO ${HOME}/.MountEFIconf.plist
			fi
	var5=1
fi

if [[  ${inputs}  = [oO] ]]; then
	if [[ $autom_open = 0 ]]; then 	
				plutil -replace AutoMount.Open -bool YES ${HOME}/.MountEFIconf.plist	
					else
				plutil -replace AutoMount.Open -bool NO ${HOME}/.MountEFIconf.plist
	fi
fi

if [[  ${inputs}  = [cC] ]]; then
	if [[ $autom_exit = 0 ]]; then 	
				plutil -replace AutoMount.ExitAfterMount -bool YES ${HOME}/.MountEFIconf.plist	
					else
				plutil -replace AutoMount.ExitAfterMount -bool NO ${HOME}/.MountEFIconf.plist
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
            var7=1
            done
fi
if [[ ! ${inputs} =~ ^[0oOdDcCtTqQ]+$ ]]; then

GET_AUTOMOUNTED
	
	am_check=0
	let "pois=inputs-1"
	uuid=`diskutil info  ${slist[$pois]} | grep  "Disk / Partition UUID:" | sed 's|.*:||' | tr -d '\n\t '`
    if [[ $uuid = "" ]]; then unuv=1; else unuv=0; fi
if [[ ! $apos = 0 ]]; then
	 let vari=$apos
	poi=0
            while [ $vari != 0 ]
		do
		 if [[ ${alist[$poi]} = $uuid ]]; then 
            if [[ $unuv = 0 ]]; then 
							strng2=`echo ${strng1[@]}  |  sed 's/'$uuid'//'`
							plutil -replace AutoMount.PartUUIDs -string "$strng2" ${HOME}/.MountEFIconf.plist							
 							vari=1
							am_check=1
                            cat  ~/.SetupMountEFItemp.txt | sed "s/$inputs) auto  /$inputs) ....  /" >> ~/.SetupMountEFItemp2.txt
                            rm ~/.SetupMountEFItemp.txt
                            awk 'NR>1{printf "\n"} {printf $0}' ~/.SetupMountEFItemp2.txt > ~/.SetupMountEFItemp.txt
                            rm  ~/.SetupMountEFItemp2.txt
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
			plutil -replace AutoMount.PartUUIDs -string "$strng1" ${HOME}/.MountEFIconf.plist
            cat  ~/.SetupMountEFItemp.txt | sed "s/$inputs) ....  /$inputs) auto  /" >> ~/.SetupMountEFItemp2.txt
            rm ~/.SetupMountEFItemp.txt
            awk 'NR>1{printf "\n"} {printf $0}' ~/.SetupMountEFItemp2.txt > ~/.SetupMountEFItemp.txt
            rm  ~/.SetupMountEFItemp2.txt
        fi
fi
	else
		if [[ $inputs = 0 ]]; then GETEFI; SHOW_AUTOEFI
	fi				
fi
done
clear
unset inputs
}

GET_INPUT(){

unset inputs
while [[ ! ${inputs} =~ ^[0-9qQ]+$ ]]; do

                if [[ $loc = "ru" ]]; then
printf '  Введите число от 0 до 9 (или Q - выход ):   ' ; printf '                             '
			else
printf '  Enter a number from 0 to 9 (or Q - exit ):   ' ; printf '                           '
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

SET_SCREEN(){
            if [[ $loc = "ru" ]]; then
printf ' 0) Установить все настройки по умолчанию                                      \n'
printf ' 1) Язык интерфейса программы = "'$loc_set'"'"%"$loc_corr"s"'(автовыбор, английский, русский) \n'
printf ' 2) Показывать меню = "'"$menue_set"'"'"%"$menue_corr"s"'(автовыбор, всегда)             \n'
printf ' 3) Пароль пользователя = "'"$mypassword_set"'"'"%"$pass_corr"s"'(пароль, нет пароля)            \n'
printf ' 4) Открывать папку EFI в Finder = "'$OpenFinder_set'"'"%"$of_corr"s"'(Да, Нет)                       \n'
printf ' 5) Установки темы =  "'$theme_set'"'"%"$theme_corr"s"'(системная, встроенная)         \n'
printf ' 6) Пресет "'$itheme_set'" из '$pcount' встроенных'"%"$btheme_corr"s"'(имя пресета)'"%"$btspc_corr"s"'\n'
printf ' 7) Показывать подсказки по клавишам = "'$ShowKeys_set'"'"%"$sk_corr"s"'(Да, Нет)                       \n'
printf ' 8) Подключить EFI при запуске  = "'$am_set'"'"%"$am_corr"s"'(Да, Нет)                       \n'
printf ' 9) Создать или править псевдонимы физических носителей                       \n'
#printf ' 8) Редактировать встроенные пресеты                                     \n'

            else
printf ' 0) Setup all parameters to defaults                                            \n'
printf ' 1) Program language = "'$loc_set'"'"%"$loc_corr"s"'(auto, russian, english) \n'
printf ' 2) Show menue = "'"$menue_set"'"'"%"$menue_corr"s"'(auto, always)\n'
printf ' 3) Save password = "'"$mypassword_set"'"'"%"$pass_corr"s"'(password, not saved)\n'
printf ' 4) Open EFI folder in Finder = "'$OpenFinder_set'"'"%"$of_corr"s"'(Yes, No) \n'
printf ' 5) Set theme =  "'$theme_set'"'"%"$theme_corr"s"'(system, built-in) \n'
printf ' 6) Theme preset "'$itheme_set'" of '$pcount' presets'"%"$btheme_corr"s"'(preset name) \n'
printf ' 7) Show binding keys help = "'$ShowKeys_set'"'"%"$sk_corr"s"'(Yes, No)               \n'
printf ' 8) Mount EFI on startup. Enabled = "'$am_set'"'"%"$am_corr"s"'(Yes, No)               \n'
printf ' 9) Create or edit aliases physical device/media                              \n'
#printf ' 8) Edit built-in themes presets                                                \n'

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
        printf '\n\n'
        

        GET_MENUE
        GET_USER_PASSWORD
        GET_OPENFINDER
        GET_THEME
        GET_SHOWKEYS
        GET_AUTOMOUNT
        SET_SCREEN
    


        printf '\n'
        printf '.%.0s' {1..80}
        printf '\n\n'
}

SHOW_DISKs(){
var0=$pos; num1=0 ; ch=0

macos=`sw_vers -productVersion`
macos=`echo ${macos//[^0-9]/}`
macos=${macos:0:4}
if [[ "$macos" = "1014" ]] || [[ "$macos" = "1013" ]] || [[ "$macos" = "1012" ]] || [[ "$macos" = "1015" ]]; then
        vmacos="Disk Size:"
    else
        vmacos="Total Size:"
fi

if [[ $loc = "ru" ]]; then
	printf '\n  Подключить (открыть) EFI разделы: (  +  уже подключенные) \n'

	printf '\n\n      0)  поиск разделов .....  '
		else
	printf '\n   Mount (open folder) EFI partitions:  (  +  already mounted) \n'

	printf '\n\n      0)  updating partitions list .....  '
        fi

spin='-\|/'
i=0



while [ $var0 != 0 ] 
do 
	let "ch++"

    let "i++"
	i=$(( (i+1) %4 ))
	printf "\b$1${spin:$i:1}"
	
	strng=`echo ${slist[$num1]}`
	 dstrng=`echo $strng | rev | cut -f2-3 -d"s" | rev`
		dlnth=`echo ${#dstrng}`
		let "corr=9-dlnth"

        let "i++"
	    i=$(( (i+1) %4 ))
	    printf "\b$1${spin:$i:1}"

		drv=`diskutil info /dev/${dstrng} | grep "Device / Media Name:" | cut -d":" -f2 | rev | sed 's/[ \t]*$//' | rev`
		dcorr=`echo ${#drv}`
		if [[ ${dcorr} -gt 30 ]]; then dcorr=30; drv=`echo ${drv:0:29}`; fi
		let "dcorr=30-dcorr"

	dsze=`diskutil info /dev/${strng} | grep "$vmacos" | sed -e 's/.*Size:\(.*\)Bytes.*/\1/' | cut -f1 -d"(" | rev | sed 's/[ \t]*$//' | rev`

    		scorr=`echo ${#dsze}`
    		let "scorr=scorr-5"
    		let "scorr=6-scorr"

             let "i++"
	         i=$(( (i+1) %4 ))
	         printf "\b$1${spin:$i:1}"

	mcheck=`diskutil info /dev/${strng}| grep "Mounted:" | cut -d":" -f2 | rev | sed 's/[ \t]*$//' | rev`
#          вывод подготовленного формата строки в файл "буфер экрана"
	if [[ ! $mcheck = "Yes" ]]; then
			printf '\n      '$ch') ...   '"$drv""%"$dcorr"s"${strng}"%"$corr"s"'  '"%"$scorr"s""$dsze"  >> ~/.SetupMountEFItemp.txt
		else
			printf '\n      '$ch')   +   '"$drv""%"$dcorr"s"${strng}"%"$corr"s"'  '"%"$scorr"s""$dsze"  >> ~/.SetupMountEFItemp.txt
		fi

            let "i++"
	         i=$(( (i+1) %4 ))
	         printf "\b$1${spin:$i:1}"    

	let "num1++"
	let "var0--"
done 

printf "\n\r\n\033[5A"



		if [[ $loc = "ru" ]]; then
	printf '  Подключить (открыть) EFI разделы: (  +  уже подключенные) \n' 
	printf '     '
	printf '.%.0s' {1..68} 
	printf '\n\n      0)  повторить поиск разделов\n' 
		else
	printf '   Mount (open folder) EFI partitions:  (  +  already mounted) \n' 
	printf '     '
	printf '.%.0s' {1..68} 
	printf '\n\n      0)  update EFI partitions list             \n' 
        fi


cat   ~/.SetupMountEFItemp.txt


printf '\n\n\n     '
	printf '.%.0s' {1..68}
printf '\n\n     '
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

SETUP_THEMES(){

strng=`diskutil list | grep EFI | grep -oE '[^ ]+$' | xargs | tr ' ' ';'`
IFS=';' ; slist=($strng); unset IFS; pos=${#slist[@]}
lines=22; let "lines=lines+pos"


var0=$pos
		num=0
		dnum=0
	while [ $var0 != 0 ] 
		do
		strng=`echo ${slist[$num]}`
		dstrng=`echo $strng | rev | cut -f2-3 -d"s" | rev`
		dlen=`echo ${#dstrng}`

		checkvirt=`diskutil info /dev/${dstrng} | grep "Device / Media Name:" | cut -d":" -f2 | rev | sed 's/[ \t]*$//' | rev`
		
		if [[ "$checkvirt" = "Disk Image" ]]; then
		unset slist[$num]
		let "pos--"
		else 
		nslist+=( $num )
		fi
		let "var0--"
		let "num++"
	done


rm -f   ~/.SetupMountEFItemp.txt
clear
SHOW_EFIs
SHOW_COLOR_TUNING
read -n1
rm -f   ~/.SetupMountEFItemp.txt 

}

####################################### псевдонимы #############################################################################


GET_FULL_EFI(){

GET_EFI_S

if [[ $par = "-r" ]]; then
ShowKeys=1
strng=`cat ${HOME}/.MountEFIconf.plist | grep -A 1 -e "ShowKeys</key>" | grep false | tr -d "<>/"'\n\t'`
if [[ $strng = "false" ]]; then ShowKeys=0; fi
if [[ $ShowKeys = 1 ]]; then lines=25; else lines=22; fi
else
lines=22 
fi
let "lines=lines+pos"

if [[ ! $pos = 0 ]]; then 
		var0=$pos
		num=0
		dnum=0; 
	while [[ ! $var0 = 0 ]] 
		do
		strng=`echo ${slist[$num]}`
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
		
		let "var0--"
		let "num++"
	done
fi
}

################################ получение имени диска для переименования ##########################################################
GET_RENAMEHD(){
adrive="±"
unset strng
strng=`cat ${HOME}/.MountEFIconf.plist | grep -A 1 "<key>RenamedHD</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
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
rm -f ~/.SetupMountEFIAtemp.txt
rm -f ~/.SetupMountEFItemp.txt
printf '\e[8;'${lines}';80t' && printf '\e[3J' && printf "\033[0;0H" 
                if [[ $loc = "ru" ]]; then
        printf '                             Настройкa псевдонимов                           '
			else
        printf '                                 Aliases setup                               '
	                 fi
var0=$pos; num=0 ; ch=0

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
	printf '\n\n\n    0)  updating partitions list .....      '
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

		drive=`echo "$drives_iomedia" | grep -B 10 ${dstring} | grep -m 1 -w "Media"  | cut -f1 -d "<" | sed -e s'/-o //'  | sed -e s'/Media//' | sed 's/ *$//' | tr -d "\n"`
        GET_RENAMEHD
		dcorr=${#drive}
		if [[ ${dcorr} -gt 30 ]]; then dcorr=0; drive="${drive:0:30}"; else let "dcorr=30-dcorr"; fi
		
	

	let "i++"
	i=$(( (i+1) %4 ))
	printf "\b$1${spin:$i:1}"

        
#          вывод подготовленного формата строки в файл "буфер экрана"

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
		    
            

	                 if [[ ! $mcheck = "Yes" ]]; then
			printf '\n      '$ch') ...   '"$ddrive""%"$ddcorr"s"'    '${string}"%"$corr"s""%"$scorr"s"' '"$dsize"'     '  >> ~/.SetupMountEFItemp.txt
		else
			printf '\n      '$ch')   +   '"$ddrive""%"$ddcorr"s"'    '${string}"%"$corr"s""%"$scorr"s"' '"$dsize"'     '  >> ~/.SetupMountEFItemp.txt
		fi
	


                    if [[ ! $adrive = "±" ]]; then 
                    acorr=${#adrive}
		          if [[ ${acorr} -gt 30 ]]; then acorr=0; adrive="${adrive:0:30}"; else let "acorr=30-acorr"; fi
		      printf '\n   '$ch') '"$drive""%"$dcorr"s""$adrive""%"$acorr"s""%"$corr"s"'  '${string:0:5}  >> ~/.SetupMountEFIAtemp.txt
                    else
              printf '\n   '$ch') '"$drive""%"$dcorr"s"'                              '"%"$corr"s"'  '${string:0:5}  >> ~/.SetupMountEFIAtemp.txt
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

cat   ~/.SetupMountEFIAtemp.txt

printf '\n\n   '
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


cat   ~/.SetupMountEFItemp.txt

    printf '\n\n     '
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
        printf '            *                                                                   \n\n'
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
                        drive=`echo "$drives_iomedia" | grep -B 10 ${dstring} | grep  -m 1 -w "Media"  | cut -f1 -d "<" | sed -e s'/-o //'  | sed -e s'/Media//' | sed 's/ *$//' | tr -d "\n"`
}


DEL_RENAMEHD(){ # inputs slist ->
adrive="±"
strng=`cat ${HOME}/.MountEFIconf.plist | grep -A 1 "<key>RenamedHD</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
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
        
        plutil -replace RenamedHD -string "$strng" ${HOME}/.MountEFIconf.plist
        else
         plutil -replace RenamedHD -string "" ${HOME}/.MountEFIconf.plist 
fi  
}

ADD_RENAMEHD(){ # drive demo -> 
adrive="±"
strng=`cat ${HOME}/.MountEFIconf.plist | grep -A 1 "<key>RenamedHD</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
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
 

        plutil -replace RenamedHD -string "$strng" ${HOME}/.MountEFIconf.plist
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
read demo
printf "\033[?25l"
        if [[ ! $demo = "" ]]; then 
            if [[ ${#demo} -gt 30 ]]; then demo="${demo:0:30}"; fi
#Фильтр недопустимых символов ввода
demo=`echo "$demo" | tr -cd "[:print:]\n"`
demo=`echo "$demo" | tr -d "=;{}]><[&^$"`

         ADD_RENAMEHD

fi
}



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
while [[ ! ${inputs} =~ ^[0-9rReEvVcCdDqQ]+$ ]]; do 

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
while [[ $inputs = "±" ]]
do
IFS="±"; read -n 1 -t 1 inputs ; unset IFS ; sym=1 ; CHECK_HOTPLUG
done
#IFS="±"; read -n 1 inputs ; unset IFS 
if [[ ${inputs} = "" ]]; then inputs="p" ;printf "\033[1A"; fi
printf "\r"
done
printf "\033[?25l"

if [[ $inputs = [cC] ]]; then 
    if [[ $vid = 0 ]]; then vid=1; else vid=0; fi
fi

if [[ $inputs = [qQ] ]]; then var8=1; unset inputs;  fi


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
                plutil -replace RenamedHD -string "" ${HOME}/.MountEFIconf.plist
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
                            printf "\r\033[2A"; printf '\n\n'"%"80"s"
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
                        if [[ $inputs -gt $ch ]]; then inputs="t"; fi &> /dev/null
                        if [[ ${inputs} = "" ]]; then inputs="p"; printf "\033[1A"; break; fi &> /dev/null
                        printf "\033[1A"
                        printf "\r"
                        done
                        if [[ ! ${inputs} = "p" ]]; then
                        GET_DRIVE
                        DEL_RENAMEHD
                        fi
                        SHOW_FULL_EFI
                        unset inputs
fi

if [[ ${inputs} = [1-9] ]] && [[ ${inputs} -le $ch ]]; then
                        printf "\r\033[2A"; printf '\n\n'"%"80"s"
                            if [[ $loc = "ru" ]]; then
                        printf '\r  Добавление псевдонима. (или просто "Enter" для отмены):\n\n'
                            else
                        printf '\r  Editing an alias. (or just "Enter" to cancel):\n\n'
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
                        if [[ $inputs -gt $ch ]]; then inputs="t"; fi &> /dev/null
                        if [[ ${inputs} = "" ]]; then inputs="p"; printf "\033[1A"; break; fi &> /dev/null
                        printf "\033[1A"
                        printf "\r"
                        done
                        if [[ ! ${inputs} = "p" ]]; then
                        GET_DRIVE
                        GET_RENAMEHD
                        EDIT_RENAMEHD
                        fi
                        SHOW_FULL_EFI
                        unset inputs
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

                        strng=`cat ${HOME}/.MountEFIconf.plist | grep -A 1 "<key>RenamedHD</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
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
                        
                        
if [[ $inputs = 0 ]]; then GET_FULL_EFI; clear && printf '\e[3J' && printf "\033[0;0H"; SHOW_FULL_EFI
fi                

UPDATE_FULL_EFI

done

unset slist
rm -f ~/.SetupMountEFIAtemp.txt
rm -f ~/.SetupMountEFItemp.txt
clear
}
###############################################################################
################### MAIN ######################################################
###############################################################################
SET_INPUT
theme="system"
var4=0
while [ $var4 != 1 ] 
do
printf '\e[3J' && printf "\033[0;0H" 
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

rm -f ${HOME}/.MountEFIconf.plist
 if [[ -f DefaultConf.plist ]]; then
            cp DefaultConf.plist ${HOME}/.MountEFIconf.plist
        else
             FILL_CONFIG
        fi
    fi
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
fi
#############################################################################

# ПОКАЗ МЕНЮ ################################################################
if [[ $inputs = 2 ]]; then 
   if [[ $menue = 0 ]]; then menue="always"
        else
            menue="auto"
        fi
  plutil -replace Menue -string $menue ${HOME}/.MountEFIconf.plist
fi
##############################################################################

# ПАРОЛЬ ПОЛЬЗОВАТЕЛЯ #########################################################
if [[ $inputs = 3 ]]; then SET_USER_PASSWORD; fi
###############################################################################

# Открывать папку в Finder ###################################################
if [[ $inputs = 4 ]]; then 
   if [[ $OpenFinder = 1 ]]; then 
  plutil -replace OpenFinder -bool NO ${HOME}/.MountEFIconf.plist
 else 
  plutil -replace OpenFinder -bool YES ${HOME}/.MountEFIconf.plist
  fi
fi  
###############################################################################

# Установка темы ##############################################################
if [[ $inputs = 5 ]]; then 
    if [[ $theme = "built-in" ]]; then 
        plutil -replace Theme -string system ${HOME}/.MountEFIconf.plist
                printf '\n\n'
                    if [[ $loc = "ru" ]]; then
                echo "включена системная тема. выполните перезапуск программы" 
                echo "нажмите любую клавишу для возврата в меню..."
                        else
                echo "set up system theme. restart required. "
                echo "press any key return to menu ...."
                    fi
                read -n 1 demo
        else
          plutil -replace Theme -string built-in ${HOME}/.MountEFIconf.plist
    fi
fi 

#################################################################################
 if [[ $inputs = 6 ]]; then 
    if [[ $theme = "built-in" ]]; then plutil -replace Theme -string system ${HOME}/.MountEFIconf.plist; fi
SET_THEMES
fi
      

# Показывать подсказку по клавишам управления  ################################
if [[ $inputs = 7 ]]; then 
   if [[ $ShowKeys = 1 ]]; then 
  plutil -replace ShowKeys -bool NO ${HOME}/.MountEFIconf.plist
 else 
  plutil -replace ShowKeys -bool YES ${HOME}/.MountEFIconf.plist
  fi
fi  
###############################################################################

# Подключение разделов при запуске программы  ################################
if [[ $inputs = 8 ]]; then 
   if [[ $autom_enabled = 1 ]]; then 
  plutil -replace AutoMount.Enabled -bool NO ${HOME}/.MountEFIconf.plist
 else 
  plutil -replace AutoMount.Enabled -bool YES ${HOME}/.MountEFIconf.plist
  SET_AUTOMOUNT
    rm -f ~/.SetupMountEFItemp.txt
  fi
fi  
###############################################################################

# создание псевдонимов имён дисков  ################################
if [[ $inputs = 9 ]]; then 
  SET_ALIASES
    rm -f ~/.SetupMountEFItemp.txt
fi
###############################################################################




#if [[ $inputs = 9 ]]; then SETUP_THEMES; clear ; SET_SCREEN; fi
           
if [[ $inputs = [qQ] ]]; then var4=1; printf '\n'; fi

done

if [[ $par = "-r" ]]; then exit 1; else EXIT_PROG; fi

####################### END MAIN #################################################
###################################################################################
###################################################################################

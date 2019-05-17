#!/bin/bash

# MountEFI версия 1.6 - появился конфиг - скрытый файл .MountEFIconf.plist в папке пользователя
# Параметр для темы теперь передается через конфиг, параметр: Theme формат: string значения: system или built-in
# Через конфиг можно передать пароль для sudo, параметр: LoginPassword формат: string, значение: пароль пользователя 
# В меню добавлена клавиша P для вызова интерактивного диалога сохранения/удаления пароля пользоваеля  в конфиге
# Исправлен баг пропадания строки с Q из основного меню. Строка пропадала после возврата из дополнительного меню и нажатия U
# при смене темы сделано уведомление на экране чтобы видеть какая тема будет при следующем запуске
# поправлено форматирование вывода в английском интерфейсе
# добавлена проверка пароля перед сохранением
# добавлена функция сохраения пароля для системы с одним разделом EFI

clear  && printf '\e[3J'

cd $(dirname $0)

if [[ ! -f ${HOME}/.MountEFIconf.plist ]]; then
        if [[ -f DefaultConf.plist ]]; then
            cp DefaultConf.plist ${HOME}/.MountEFIconf.plist
        else
#            touch ${HOME}/.MountEFIconf.plist
            echo '<?xml version="1.0" encoding="UTF-8"?>' >> ${HOME}/.MountEFIconf.plist
            echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' >> ${HOME}/.MountEFIconf.plist
            echo '<plist version="1.0">' >> ${HOME}/.MountEFIconf.plist
            echo '<dict>' >> ${HOME}/.MountEFIconf.plist
            echo '<key>Theme</key>' >> ${HOME}/.MountEFIconf.plist
            echo '<string>system</string>' >> ${HOME}/.MountEFIconf.plist
            echo '</dict>' >> ${HOME}/.MountEFIconf.plist
            echo '</plist>' >> ${HOME}/.MountEFIconf.plist
    fi                    
fi

# Определение функций кастомизации интерфейса #############################################
############################################################################################
# Colors for Apple Terminal
#


function list_colors {
    cat colors.csv
}

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
        echo "Normal test color set to: $*: $color"
    fi
}    

function set_background_color {
    color=$(get_apple_color $*)
    if [ "$color" != "" ] ; then
        osascript -e "tell application \"Terminal\" to set background color of window 1 to ${color}"
        echo "Background color set to: $*: $color"
    fi
}    

function set_theme {
    set_foreground_color $1
    set_background_color $2
}    

function set_font {
    osascript -e "tell application \"Terminal\" to set the font name of window 1 to \"$1\""
    osascript -e "tell application \"Terminal\" to set the font size of window 1 to $2"
}
#################################################################################################

SET_THEMES(){

HasTheme=`cat ${HOME}/.MountEFIconf.plist | grep -Eo "Theme"  | tr -d '\n'`
if [[ ! $HasTheme = "Theme" ]]; then
plutil -replace Theme -string system ${HOME}/.MountEFIconf.plist
else
 theme=`cat ${HOME}/.MountEFIconf.plist | grep -A 1 "Theme" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
   if [[ $theme = "system" ]]; then 
            plutil -replace Theme -string built-in ${HOME}/.MountEFIconf.plist
                printf '\n\n'
                    if [[ $loc = "ru" ]]; then
                echo "включена встроенная тема. выполните перезапуск программы" 
                echo "нажмите любую клавишу для возврата в меню..."
                        else
                echo "set up built-in theme. restart required. "
                echo "press any key return to menu ...."
                    fi
                read -n 1 demo
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


#################################################################################################

CUSTOM_SET(){

clear 

osascript -e "tell application \"Terminal\" to set the font size of window 1 to 12"
osascript -e "tell application \"Terminal\" to set background color of window 1 to {1028, 12850, 65535}"
osascript -e "tell application \"Terminal\" to set normal text color of window 1 to {65535, 65535, 65535}"

clear 

}

GET_THEME(){
if [[ -f ${HOME}/.MountEFIconf.plist ]]; then
HasTheme=`cat ${HOME}/.MountEFIconf.plist | grep -Eo "Theme"  | tr -d '\n'`
    if [[ $HasTheme = "Theme" ]]; then
theme=`cat ${HOME}/.MountEFIconf.plist | grep -A 1 "Theme" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
    fi
fi
}

theme="system"
GET_THEME
if [[ $theme = "built-in" ]]; then CUSTOM_SET; fi

# функция отладки ###############################################
demo=0
deb=0

DEBUG(){
if [[ ! $deb = 0 ]]; then
printf '\n\n Останов '"$stop"'  :\n\n'
printf '............................................................\n'
#term=`ps`; AllTTYcount=`echo $term | grep -Eo ttys[0-9][0-9][0-9] | wc -l | tr - " \t\n"`; echo $AllTTYcount
#echo "choice = "$choice
#echo "chs = "$chs
#echo "ch = "$ch
#echo "dlist = "${dlist[@]}
#echo "nlist = "${nlist[@]}
#echo "num = "$num
#echo "pnum ="$pnum
#echo "pos = "$pos
#echo "string = "$string
#echo "ttys001 --------------------------------------------"
#echo "mcheck = "$mcheck
#echo "mounted= "$mounted
#echo "was mounted = "$was_mounted
#echo "vname = "$vname
#echo "-----------------------------------------------------"
#echo
#echo "ttys000 --------------------------------------------"
#echo "PID = "$PID_ttys000
#echo "Time000 = "$Time000
#echo "-----------------------------------------------------"
#echo "Time Diff = "$TimeDiff
#echo "xkbs = "$xkbs
#echo "layout name = "$layout_name
#echo "choice = "$choice
#echo " layouts = "$layouts
#echo "keyboard = "$keyboard
#echo "layouts names = "${layouts_names[$num]}
#echo "mypassword = "$mypassword
#echo "login = "$login

printf '............................................................\n\n'
sleep 0.5
read  -n1 demo
fi
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

parm="$1"

loc=`locale | grep LANG | sed -e 's/.*LANG="\(.*\)_.*/\1/'`


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
    printf ' Программа не требует аргументов командной строки. Аргумент -h [ -help, -HELP, -H ]\n'
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
    printf ' The program does not require command line arguments. Argument -h [-help, -HELP, -H]\n'
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
                printf 'нажмите любую клавишу для продолжения ...'
                        else
                printf '\nWrong password '$mypassword' not saved. \n'
                printf 'press any key to continue....'
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
#stop="после функции GET_USER_PASSWORD"; DEBUG
}

# Возвращает в переменной TTYcount 0 если наш терминал один
CHECK_TTY_COUNT(){
term=`ps`
AllTTYcount=`echo $term | grep -Eo ttys[0-9][0-9][0-9] | wc -l | tr - " \t\n"`
let "TTYcount=AllTTYcount-MyTTYcount"
}

# Выход из программы с проверкой - выгружать терминал из трея или нет
EXIT_PROGRAM(){
CHECK_TTY_COUNT	
if [[ ${TTYcount} = 0  ]]; then  sleep 1.2; osascript -e 'quit app "terminal.app"' & exit
	else
    sleep 1.2; osascript -e 'tell application "Terminal" to close first window' & exit
fi
}

# Заполнение массивов dlist и nlist. Получаем списки EFI разделов - dlist
# И список указателей на валидные значения в нём - nlist

GETARR(){

string=`diskutil list | grep EFI | grep -oE '[^ ]+$' | xargs | tr ' ' ';'`
IFS=';' 
dlist=($string)
unset IFS;
pos=${#dlist[@]}
lines=25
let "lines=lines+pos"
lists_updated=1

if [[ ! $pos = 0 ]]; then 
		var0=$pos
		num=0
		dnum=0
	while [ $var0 != 0 ] 
		do
		string=`echo ${dlist[$num]}`
		dstring=`echo $string | rev | cut -f2-3 -d"s" | rev`
		dlenth=`echo ${#dstring}`

		checkvirt=`diskutil info /dev/${dstring} | grep "Device / Media Name:" | cut -d":" -f2 | rev | sed 's/[ \t]*$//' | rev`
		
		if [[ "$checkvirt" = "Disk Image" ]]; then
		unset dlist[$num]
		let "pos--"
		else 
		nlist+=( $num )
		fi
		let "var0--"
		let "num++"
	done

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

DO_MOUNT(){

		if [[ $flag = 1 ]]; then
        printf '\n\n  '
        if [[ ! $mypassword = "0" ]]; then
                echo $mypassword | sudo -S diskutil quiet mount  /dev/${string} 2>/dev/null
                    else
                        sudo printf ' '
                        sudo diskutil quiet mount  /dev/${string}
                        printf "\r\033[1A"
                        printf '                                                                  '
                        printf "\r\n\033[2A"
         fi

       		 else

        	 	diskutil quiet mount  /dev/${string}

		fi

}




# Определение функции получения информаци о системном разделе EFI
GET_SYSTEM_EFI(){

if [[ ${lists_updated} = 1 ]]; then
sysdrive=`diskutil info / | grep "Part of Whole:" | cut -d":" -f2 | rev | sed 's/[ \t]*$//' | rev | tr -d "\n"`
edname=`diskutil info $sysdrive | grep "Device / Media Name:" | cut -d":" -f2 | rev | sed 's/[ \t]*$//' | rev | tr -d "\n"`
var2=$pos
num=0
while [ $var2 != 0 ] 
do 
pnum=${nlist[num]}
string=`echo ${dlist[$pnum]}`
dstring=`echo $string | rev | cut -f2-3 -d"s" | rev`
dname=`diskutil info /dev/${dstring} | grep "Device / Media Name:" | cut -d":" -f2 | rev | sed 's/[ \t]*$//' | rev`
if [[ "$edname" = "$dname" ]]; then estring=`echo ${string}` ; enum=$pnum;  var2=1; fi
let "num++"
let "var2--"
done
lists_updated=0
fi
}

MOUNTED_CHECK(){

	mcheck=`diskutil info /dev/${string}| grep "Mounted:" | cut -d":" -f2 | rev | sed 's/[ \t]*$//' | rev`
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

mcheck=`diskutil info /dev/${string}| grep "Mounted:" | cut -d":" -f2 | rev | sed 's/[ \t]*$//' | rev`
	if [[ $mcheck = "Yes" ]]; then
		
		sleep 1.5

		diskutil quiet umount force  /dev/${string}


mcheck=`diskutil info /dev/${string}| grep "Mounted:" | cut -d":" -f2 | rev | sed 's/[ \t]*$//' | rev`

	if [[ $mcheck = "Yes" ]]; then

		printf '\n\n  '; sudo printf ' '

		sleep 1.5
            

                if [[ ! $mypassword = "0" ]]; then

                echo $mypassword | sudo -S diskutil quiet umount force  /dev/${string} 2>/dev/null
            
                    else
            
        	 	sudo diskutil quiet umount force  /dev/${string}

                    fi

	printf "\r\033[1A"
	printf '                                                                  '
	printf "\r\n\033[2A"


	fi
fi
}

# Определение функции розыска Clover в виде проверки бинарика EFI/BOOT/bootx64.efi 
##############################################################################
FIND_CLOVER(){


was_mounted=0
var1=$pos
num=0
spin='-\|/'
i=0
noefi=1

while [ $var1 != 0 ] 
do 
#stop="перед PNUM"; DEBUG
	pnum=${nlist[num]}
	string=`echo ${dlist[$pnum]}`
	mcheck=`diskutil info /dev/${string}| grep "Mounted:" | cut -d":" -f2 | rev | sed 's/[ \t]*$//' | rev`
	if [[ ! $mcheck = "Yes" ]]; then 

	was_mounted=0
#stop="после mcheck"; DEBUG	
       	
	DO_MOUNT	

	MOUNTED_CHECK

	else
		was_mounted=1
#stop="после was_mounted=1"; DEBUG
	fi
#stop="перед vname"; DEBUG
vname=`diskutil info /dev/${string} | grep "Mount Point:" | cut -d":" -f2 | rev | sed 's/[ \t]*$//' | rev`
#stop="после VNAME"; DEBUG
	if [[ -d "$vname"/EFI/BOOT ]]; then
			if [[ -f "$vname"/EFI/BOOT/BOOTX64.efi ]] && [[ -f "$vname"/EFI/BOOT/bootx64.efi ]] && [[ -f "$vname"/EFI/BOOT/BOOTx64.efi ]]; then 
#stop="после проверки наличия bootx64"; DEBUG
					check_loader=`xxd "$vname"/EFI/BOOT/BOOTX64.EFI | grep -Eo "Clover revision:"` ; check_loader=`echo ${check_loader:0:16}`
#stop="перед проверкой на кловерность"; DEBUG
                					if [[ ${check_loader} = "Clover revision:" ]]; then
#stop="после проверки на кловерность"; DEBUG
                       						 open "$vname/EFI"
							 was_mounted=1
#stop="после открытия папки EFI"; DEBUG
                 fi   
	   fi
	fi

#stop="перед  проверкой на отключение раздела"; DEBUG
		if [[ "$was_mounted" = 0 ]]; then
#stop="после проверки на отключение раздела"; DEBUG
	diskutil quiet  umount  force /dev/${string}; mounted=0
		
		UNMOUNTED_CHECK		

		fi
		
let "num++"
let "var1--"

done

nogetlist=1


}


FIND_OPENCORE(){


was_mounted=0
var1=$pos
num=0
spin='-\|/'
i=0
noefi=1

while [ $var1 != 0 ] 
do 
#stop="перед PNUM"; DEBUG
	pnum=${nlist[num]}
	string=`echo ${dlist[$pnum]}`
	mcheck=`diskutil info /dev/${string}| grep "Mounted:" | cut -d":" -f2 | rev | sed 's/[ \t]*$//' | rev`
	if [[ ! $mcheck = "Yes" ]]; then 

	was_mounted=0
#stop="после mcheck"; DEBUG	
       	
	DO_MOUNT	

	MOUNTED_CHECK

	else
		was_mounted=1
#stop="после was_mounted=1"; DEBUG
	fi
#stop="перед vname"; DEBUG
vname=`diskutil info /dev/${string} | grep "Mount Point:" | cut -d":" -f2 | rev | sed 's/[ \t]*$//' | rev`
#stop="после VNAME"; DEBUG
	if [[ -d "$vname"/EFI/BOOT ]]; then
			if [[ -f "$vname"/EFI/BOOT/BOOTX64.efi ]] && [[ -f "$vname"/EFI/BOOT/bootx64.efi ]] && [[ -f "$vname"/EFI/BOOT/BOOTx64.efi ]]; then 
#stop="после проверки наличия bootx64"; DEBUG
					check_loader=`xxd "$vname"/EFI/BOOT/BOOTX64.EFI | grep -Eo "OpenCore"` ; check_loader=`echo ${check_loader:0:8}`
#stop="перед проверкой на кловерность"; DEBUG
                					if [[ ${check_loader} = "OpenCore" ]]; then
#stop="после проверки на кловерность"; DEBUG
                       						 open "$vname/EFI"
							 was_mounted=1
#stop="после открытия папки EFI"; DEBUG
                 fi   
	   fi
	fi

#stop="перед  проверкой на отключение раздела"; DEBUG
		if [[ "$was_mounted" = 0 ]]; then
#stop="после проверки на отключение раздела"; DEBUG
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
	mcheck=`diskutil info /dev/${string}| grep "Mounted:" | cut -d":" -f2 | rev | sed 's/[ \t]*$//' | rev`


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
if [[ ${noefi} = 0 ]]; then order=2; fi

}

# У Эль Капитан другой термин для размера раздела
# Установка флага необходимости в SUDO - flag	
macos=`sw_vers -productVersion`
macos=`echo ${macos//[^0-9]/}`
macos=${macos:0:4}
if [[ "$macos" = "1014" ]] || [[ "$macos" = "1013" ]] || [[ "$macos" = "1012" ]]; then
        vmacos="Disk Size:"
        if [[ "$macos" = "1014" ]] || [[ "$macos" = "1013" ]]; then flag=1; else flag=0; fi
    else
        vmacos="Total Size:"
        flag=0
fi

# Блок обработки ситуации если найден всего один раздел EFI ########################
###################################################################################
GET_USER_PASSWORD
GETARR


if [[ $pos = 1 ]]; then
    clear 
unset string
string=`echo ${dlist[0]}`

mcheck=`diskutil info /dev/${string} | grep "Mounted:" | cut -d":" -f2 | rev | sed 's/[ \t]*$//' | rev`
	if [[ ! $mcheck = "Yes" ]]; then

            
                    
                    if [[ $loc = "ru" ]]; then
        printf '\n******    Программа монтирует EFI разделы в Mac OS (X.11 - X.14)    *******\n\n'
			else
        printf '\n******    This program mounts EFI partitions on Mac OS (X.11 - X.14)    *******\n\n'
	                 fi
                    	dstring=`echo $string | rev | cut -f2-3 -d"s" | rev`
		
    	printf '\n     '
	     let "corr=0"

    	dsize=`diskutil info /dev/${string} | grep "$vmacos" | sed -e 's/.*Size:\(.*\)Bytes.*/\1/' | cut -f1 -d"(" | rev | sed 's/[ \t]*$//' | rev`
	
	drive=`diskutil info /dev/${dstring} | grep "Device / Media Name:" | cut -d":" -f2 | rev | sed 's/[ \t]*$//' | rev`
    	
    	

    	
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

if [[ $mypassword = "0" ]] && [[ $flag = 1 ]]; then
        if [[ $loc = "ru" ]]; then
    printf '\n\nДля перехода в меню сохранения пароля нажмите Enter\n'
    printf 'или просто введите пароль для подключения EFI: '
         else
    printf '\n\nTo save your password permanent press Enter\n'
    printf 'or just enter your password to mount EFI: '
        fi
    read -s mypassword
    if [[ $mypassword = "" ]]; then SET_USER_PASSWORD; GET_USER_PASSWORD; fi
    if echo $mypassword | sudo -Sk printf '' 2>/dev/null; then
    printf '\nOK.'
        else
            if [[ ! $mypassword = "0" ]]; then
                        if [[ $loc = "ru" ]]; then
                printf '\nНе верный пароль '$mypassword' \n'
                                        else
                printf '\nWrong password '$mypassword' \n'
                        fi
            mypassword="0"
            fi
        fi
    fi        
			
DO_MOUNT

MOUNTED_CHECK
	fi
vname=`diskutil info /dev/${string} | grep "Mount Point:" | cut -d":" -f2 | rev | sed 's/[ \t]*$//' | rev`
clear
		if [[ $loc = "ru" ]]; then
			printf '\nРаздел: '${string}' ''подключен.\n\n'
   		 open "$vname"
			printf 'Выходим.. \n\n\n\n''\e[3J'
			else
			printf '\nPartition: '${string}' ''mounted.\n\n'
   		 open "$vname"
			printf 'Exit the program. \n\n\n\n''\e[3J'
		fi

EXIT_PROGRAM
			
fi
# Конец блока обработки если один  раздел EFI #################################################
###########################################################################################



# Определение  функции построения и вывода списка разделов 
GETLIST(){

printf '\e[8;'${lines}';80t' && printf '\e[3J'

var0=$pos
num=0
ch=0
unset string

rm -f   ~/.MountEFItemp.txt
touch  ~/.MountEFItemp.txt

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

	let "i++"
	i=$(( (i+1) %4 ))
	printf "\b$1${spin:$i:1}"

	pnum=${nlist[num]}
	string=`echo ${dlist[$pnum]}`
	
		
				
		dstring=`echo $string | rev | cut -f2-3 -d"s" | rev`
		dlenth=`echo ${#dstring}`
		let "corr=9-dlenth"

		drive=`diskutil info /dev/${dstring} | grep "Device / Media Name:" | cut -d":" -f2 | rev | sed 's/[ \t]*$//' | rev`
		dcorr=`echo ${#drive}`
		if [[ ${dcorr} -gt 30 ]]; then dcorr=30; drive=`echo ${drive:0:29}`; fi
		let "dcorr=30-dcorr"

	dsize=`diskutil info /dev/${string} | grep "$vmacos" | sed -e 's/.*Size:\(.*\)Bytes.*/\1/' | cut -f1 -d"(" | rev | sed 's/[ \t]*$//' | rev`

	let "i++"
	i=$(( (i+1) %4 ))
	printf "\b$1${spin:$i:1}"
	

    		scorr=`echo ${#dsize}`
    		let "scorr=scorr-5"
    		let "scorr=6-scorr"

	mcheck=`diskutil info /dev/${string}| grep "Mounted:" | cut -d":" -f2 | rev | sed 's/[ \t]*$//' | rev`
#          вывод подготовленного формата строки в файл "буфер экрана"
	if [[ ! $mcheck = "Yes" ]]; then
			printf '\n      '$ch') ...   '"$drive""%"$dcorr"s"${string}"%"$corr"s"'  '"%"$scorr"s""$dsize"  >> ~/.MountEFItemp.txt
		else
			printf '\n      '$ch')   +   '"$drive""%"$dcorr"s"${string}"%"$corr"s"'  '"%"$scorr"s""$dsize" >> ~/.MountEFItemp.txt
		fi


	let "num++"
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

	
cat  -v ~/.MountEFItemp.txt
#rm ~/.MountEFItemp.txt

	let "ch++"
	
	printf '\n\n\n     '
	printf '.%.0s' {1..68}
	if [[ $loc = "ru" ]]; then
	printf '\n      E  -   найти и подключить EFI системного диска \n'
	printf '      U  -   отключить ВСЕ подключенные разделы  EFI\n'
    printf '      I  -   дополнительное меню                     \n'
    printf '      P  -   сохранить/удалить пароль пользователя \n'
	printf '      Q  -   закрыть окно и выход из программы\n' 
			else
	printf '\n      E  -   find and mount this system drive EFI \n' 
	printf '      U  -   unmount ALL mounted  EFI partitions \n'
    printf '      I  -   extra menu                      \n'
    printf '      P  -   save/delete user password\n'  
	printf '      Q  -   close terminal and exit from the program\n' 
	     fi

	


	
printf '\n\n' 

}
# Конец определения GETLIST ###########################################################

# Определение функции обновления информации  экрана при подключении и отключении разделов
UPDATELIST(){

    clear && printf '\e[8;'${lines}';80t' && printf '\e[3J'

    if [[ ! $order = 3 ]] && [[ ! $order = 4 ]]; then
	     if [[ $order = 0 ]]; then
cat  ~/.MountEFItemp.txt | sed "s/$chs) ...  /$chs)   +  /" >> ~/.MountEFItemp2.txt
	else
cat  ~/.MountEFItemp.txt | sed "s/$chs)   +  /$chs) ...  /" >> ~/.MountEFItemp2.txt
	     fi

rm ~/.MountEFItemp.txt
mv  ~/.MountEFItemp2.txt ~/.MountEFItemp.txt
#cat  -v ~/.MountEFItemp.txt
#printf "\033[0;0H"
fi
		if [[ $loc = "ru" ]]; then
        	printf '\n******    Программа монтирует EFI разделы в Mac OS (X.11 - X.14)    *******\n'
	printf '\n  Подключить (открыть) EFI разделы: (  +  уже подключенные) \n' 
	printf '     '
	printf '.%.0s' {1..68} 
	printf '\n\n      0)  повторить поиск разделов\n' 
			else
        	printf '\n******    This program mounts EFI partitions on Mac OS (X.11 - X.14)    *******\n'
	printf '     '
	printf '.%.0s' {1..68}
	printf '\n   Mount (open folder) EFI partitions:  (  +  already mounted) \n'  
	printf '\n\n      0)  update EFI partitions list             \n' 
		fi

cat  -v ~/.MountEFItemp.txt
#printf "\r\033[1A"
	if [[ ! $order = 1 ]] || [[ ! $order = 0 ]]; then printf "\r\033[1A"; fi
    
	printf '\n\n\n\n     '
	printf '.%.0s' {1..68}
if [[ ! $order = 3 ]]; then
	     if [[ $loc = "ru" ]]; then
	printf '\n      E  -   найти и подключить EFI системного диска \n'
	printf '      U  -   отключить ВСЕ подключенные разделы  EFI\n'
    printf '      I  -   дополнительное меню                     \n'
    printf '      P  -   сохранить/удалить пароль пользователя \n'
	printf '      Q  -   закрыть окно и выход из программы\n\n' 
			else
	printf '\n      E  -   find and mount this system drive EFI \n' 
	printf '      U  -   unmount ALL mounted  EFI partitions \n'
    printf '      I  -   extra menu                      \n'
    printf '      P  -   save/delete user password\n' 
	printf '      Q  -   close terminal and exit from the program\n\n' 
	     fi
	else
        if [[ $loc = "ru" ]]; then
	printf '\n      C  -   найти и подключить EFI с загрузчиком Clover \n'
	printf '      O  -   найти и подключить EFI с загрузчиком Open Core\n'
	printf '      T  -   сменить тему терминала на следующем запуске программы\n'
    printf '      I  -   главное меню                     \n'
    printf '      Q  -   закрыть окно и выход из программы\n\n' 
			else
	printf '\n      C  -   find and mount EFI with Clover boot loader \n' 
	printf '      O  -   find and mount EFI with Open Core boot loader \n' 
	printf '      T  -   change the terminal theme to next program boot\n'
    printf '      I  -   main menu                      \n'
    printf '      Q  -   close terminal and exit from the program\n\n' 
	     fi
fi


	printf '\n'
	
    if [[ $sym = 2 ]]; then printf '\n'; fi
	printf "\r\n\033[1A"
	

	if [ $loc = "ru" ]; then
let "schs=$ch-1"
printf '  Введите число от 0 до '$schs' (или  U, E, Q ):  '; printf '                               '
			else
printf '  Enter a number from 0 to '$schs' (or  U, E, Q ):  ';  printf '                              '
	fi
	if [[ $order = 1 ]]; then
		if [ $loc = "ru" ]; then
	printf '\n\n  Oтключаем EFI разделы ...  '
				else
	printf '\n\n  Unmounting EFI partitions ....  '
			fi
	fi

}
# Конец определения функции UPDATELIST ######################################################

ADVANCED_MENUE(){

    order=3; UPDATELIST; GETKEYS
}
##################### Детект раскладки  и адаптация ввода для двухбайтовых UTF-8  #############
SET_INPUT(){

layout_name=`defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources | egrep -w 'KeyboardLayout Name' | sed -E 's/.+ = "?([^"]+)"?;/\1/' | tr -d "\n"`
xkbs=1
#stop="перед проверкой раскладки"; DEBUG
case ${layout_name} in
 "Russian"          ) xkbs=2 ;;
 "RussianWin"       ) xkbs=2 ;;
 "Russian-Phonetic" ) xkbs=2 ;;
 "Ukrainian"        ) xkbs=2 ;;
 "Ukrainian-PC"     ) xkbs=2 ;;
 "Byelorussian"     ) xkbs=2 ;;
 esac
#stop="после проверки раскладки"; DEBUG
if [[ $xkbs = 2 ]]; then 
cd $(dirname $0)
    if [[ -f "./xkbswitch" ]]; then 
declare -a layouts_names
layouts=`defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleEnabledInputSources | egrep -w 'KeyboardLayout Name' | sed -E 's/.+ = "?([^"]+)"?;/\1/' | tr  '\n' ';'`
IFS=";"; layouts_names=($layouts); unset IFS; num=${#layouts_names[@]}
keyboard="0"
#stop="после проверки наличия xkbswitch"; DEBUG
while [ $num != 0 ]; do 
case ${layouts_names[$num]} in
 "ABC"                ) keyboard=${layouts_names[$num]} ;;
 "US Extended"        ) keyboard="USExtended" ;;
 "USInternational-PC" ) keyboard=${layouts_names[$num]} ;;
 "U.S."               ) keyboard="US" ;;
 "British"            ) keyboard=${layouts_names[$num]} ;;
 "British-PC"         ) keyboard=${layouts_names[$num]} ;;
esac
#stop="после поиска английской раскладки"; DEBUG
        if [[ ! $keyboard = "0" ]]; then num=1; fi
let "num--"
done

if [[ ! $keyboard = "0" ]]; then ./xkbswitch -se $keyboard; fi
   else
        if [[ $loc = "ru" ]]; then
printf '\n\n                          ! Смените раскладку на латиницу !'
            else
printf '\n\n                          ! Change layout to UTF-8 ABC, US or EN !'
        fi
 printf "\r\n\033[3A\033[46C" ; if [[ $order = 3 ]]; then printf "\033[3C"; fi   fi
fi
}

# Определение функции обработки ввода кирилицы вместо латиницы
#############################
CYRILLIC_TRANSLIT(){

case ${choice} in
 
 [е] ) unset choice; choice="t";;
 [Е] ) unset choice; choice="T";;
 [г] ) unset choice; choice="u";;
 [с] ) unset choice; choice="c";;
 [й] ) unset choice; choice="q";;
 [у] ) unset choice; choice="e";;
 [ш] ) unset choice; choice="i";;
 [Ш] ) unset choice; choice="i";;
 [щ] ) unset choice; choice="o";;
 [Щ] ) unset choice; choice="O";;
 [Ў] ) unset choice; choice="O";;
 [ў] ) unset choice; choice="o";;
 [Г] ) unset choice; choice="U";;
 [У] ) unset choice; choice="E";;
 [С] ) unset choice; choice="C";;
 [Й] ) unset choice; choice="Q";;
 [з] ) unset choice; choice="p";;
 [З] ) unset choice; choice="P";;

esac

}
#############################
###############################################################


# Определение функции ожидания и фильтрации ввода с клавиатуры
GETKEYS(){

#cd $(dirname $0)

unset choice
while [[ ! ${choice} =~ ^[0-9uUqQ]+$ ]]; do
if [[ $order = 2 ]]; then 
printf '\r                                                          '
printf "\r\033[2A"
printf '\r                                                          '
order=0
fi

if [[ $sym = 2 ]]; then printf "\033[1A" ;

fi
if [[ $choice = " " ]]; then printf '\r\n'
 else printf "\r\n\033[1A"
fi
if [[ $order = 3 ]]; then 
    let "schs=$ch-1"
    if [[ $loc = "ru" ]]; then
printf '  Введите число от 0 до '$schs' (или  C, O, T, I, Q ):   ' ; printf '                             '
			else
printf '  Enter a number from 0 to '$schs' (or  C, O, T, I, Q ):   ' ; printf '                           '
    fi
        else
            let "schs=$ch-1"
            if [[ $loc = "ru" ]]; then
printf '  Введите число от 0 до '$schs' (или  U, E, I, P, Q ):   ' ; printf '                             '
			else
printf '  Enter a number from 0 to '$schs' (or  U, E, I, P, Q ):   ' ; printf '                           '
    fi
fi
printf '\n'
printf '                                                                                \n'
printf '                                                                                '
printf "\r\n\033[3A\033[49C"
if [[ ! $loc = "ru" ]]; then printf "\033[2C"; fi

if [[ ${ch} -le 8 ]]; then
SET_INPUT
IFS="±"; read -n 1 choice ; unset IFS ; sym=1 
else
IFS="±"; read choice; unset IFS ; CYRILLIC_TRANSLIT ; sym=2 ; if  [[ ${choice} = "" ]]; then choice="  "; fi
fi


if  [[ ${choice} = "" ]]; then unset choice; printf "\r\n\033[2A\033[49C"; fi


if [[ ! $order = 3 ]]; then
if [[ ! $choice =~ ^[0-9uUqQeEiIpP]$ ]]; then unset choice; fi
if [[ ${choice} = [uU] ]]; then unset nlist; UNMOUNTS; choice="R"; order=4; fi
if [[ ${choice} = [qQ] ]]; then choice=$ch; fi
if [[ ${choice} = [eE] ]]; then GET_SYSTEM_EFI; let "choice=enum+1"; fi
if [[ ${choice} = [iI] ]]; then ADVANCED_MENUE; fi
if [[ ${choice} = [pP] ]]; then SET_USER_PASSWORD; choice="0"; order=4; fi
else
if [[ ! $choice =~ ^[0-9qQcCoOtTiI]$ ]]; then unset choice; fi
if [[ ${choice} = [tT] ]]; then  SET_THEMES; choice="0"; order=4; fi
if [[ ${choice} = [oO] ]]; then  FIND_OPENCORE; choice="0"; order=4; fi
if [[ ${choice} = [cC] ]]; then  FIND_CLOVER; choice="0"; order=4; fi
if [[ ${choice} = [qQ] ]]; then choice=$ch; fi
if [[ ${choice} = [iI] ]]; then  order=4; UPDATELIST; fi
fi
! [[ ${choice} -ge 0 && ${choice} -le $ch  ]] && unset choice 

done

chs=$choice
if [[ $chs = 0 ]]; then nogetlist=0; fi

}
# Конец определения GETKEYS #######################################



# Определение функции монтирования разделов EFI ##########################################
MOUNTS(){
printf '\n'
let "num=chs-1"

pnum=${nlist[num]}
string=`echo ${dlist[$pnum]}`
	

mcheck=`diskutil info /dev/${string}| grep "Mounted:" | cut -d":" -f2 | rev | sed 's/[ \t]*$//' | rev`
if [[ ! $mcheck = "Yes" ]]; then

    DO_MOUNT

    MOUNTED_CHECK

	order=0; UPDATELIST

else 
	printf "\r\033[1A"
fi
    vname=`diskutil info /dev/${string} | grep "Mount Point:" | cut -d":" -f2 | rev | sed 's/[ \t]*$//' | rev`

open "$vname"

nogetlist=1

}
# Конец определения MOUNTS #################################################################

# Начало основноо цикла программы ###########################################################
############################ MAIN MAIN MAIN ################################################


chs=0
# переменная nogetlist является флагом - будет ли экран обновлён GETLIST или UPDATELIST
# если nogetlist=1 то обновление через функцию UPDATELIST
# значением этого флага управляют MOUNTS, UNMOUNTS, GETKEYS
nogetlist=0

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

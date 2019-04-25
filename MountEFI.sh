#!/bin/bash
clear




osascript -e "tell application \"Terminal\" to set the font size of window 1 to 12"
osascript -e "tell application \"Terminal\" to set background color of window 1 to {1028, 12850, 65535}"
osascript -e "tell application \"Terminal\" to set normal text color of window 1 to {65535, 65535, 65535}"

clear

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

# Блок определения функций ########################################################

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
		let "var0=var0-1"
		let "num=num+1"
	done

fi

	if [[ $pos = 0 ]]; then
clear
		if [ $loc = "ru" ]; then
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


# Функция отключения EFI разделов

UNMOUNTS(){

#		if [ $loc = "ru" ]; then
#	printf '\n\n  Oтключаем EFI разделы ...  '
#				else
#	printf '\n\n  Unmounting EFI partitions ....  '
#			fi
            

		GETARR
var1=$pos
num=0
spin='-\|/'
i=0
noefi=1

while [ $var1 != 0 ] 
do 

	pnum=${nlist[num]}
	string=`echo ${dlist[$pnum]}`
	mcheck=`diskutil info /dev/${string}| grep "Mounted:" | cut -d":" -f2 | rev | sed 's/[ \t]*$//' | rev`


if [ $mcheck = "Yes" ]; then
	noefi=0
	diskutil quiet umount  /dev/${string}
	order=1; let "chs=num+1"; UPDATELIST

	let "i++"
	i=$(( (i+1) %4 ))
	printf "\b$1${spin:$i:1}"
	fi

let "num=num+1"
	let "var1--"
done


#printf '\r                                      '
#if [[ ${noefi} = 0 ]]; then printf "\r\033[2A"
printf '\r                                                          '
printf "\r\033[2A"
printf '\r                                                          '
printf '\n\n'
#else 
#printf 'n\n'
#fi
nogetlist=1
if [[ ${noefi} = 0 ]]; then order=2; fi
}

# У Эль Капитан другой термин для размера раздела
# Установка флага необходимости в SUDO - flag	
macos=`sw_vers -productVersion`
macos=`echo ${macos//[^0-9]/}`
macos=${macos:0:4}
if [ "$macos" = "1014" ] || [ "$macos" = "1013" ] || [ "$macos" = "1012" ]; then
        vmacos="Disk Size:"
        if [ "$macos" = "1014" ] || [ "$macos" = "1013" ]; then flag=1; else flag=0; fi
    else
        vmacos="Total Size:"
        flag=0
fi

# Блок обработки ситуации если найден всего один раздел EFI ########################
###################################################################################
GETARR

if [[ $pos = 1 ]]; then
    clear 
unset string
string=`echo ${dlist[0]}`

mcheck=`diskutil info /dev/${string} | grep "Mounted:" | cut -d":" -f2 | rev | sed 's/[ \t]*$//' | rev`
	if [ ! $mcheck = "Yes" ]; then

            
		if [ $flag = 1 ]; then 
                    
                    if [ $loc = "ru" ]; then
        printf '\n******    Программа монтирует EFI разделы в Mac OS (X.11 - X.14)    *******\n'
			else
        printf '\n******    This program mounts EFI partitions on Mac OS (X.11 - X.14)    *******\n'
	                 fi
                    dstring=`echo $string | rev | cut -f2-3 -d"s" | rev`
		dlenth=`echo ${#dstring}`
    printf '\n\n     '
	let "corr=9-dlenth"
	printf  ${string}"%"$corr"s"

    	dsize=`diskutil info /dev/${string} | grep "$vmacos" | sed -e 's/.*Size:\(.*\)Bytes.*/\1/' | cut -f1 -d"(" | rev | sed 's/[ \t]*$//' | rev`
	
	drive=`diskutil info /dev/${dstring} | grep "Device / Media Name:" | cut -d":" -f2 | rev | sed 's/[ \t]*$//' | rev`
    corr=`echo ${#dsize}`
    let "corr=corr-5"
    let "corr=6-corr"
	printf '  '"%"$corr"s""$dsize"'   * '"$drive"
                    printf '\n\n\n '; sudo printf ' '
                sudo diskutil quiet mount /dev/${string}
            		else
                			diskutil quiet mount /dev/${string}
		fi

mcheck=`diskutil info /dev/${string} | grep "Mounted:" | cut -d":" -f2 | rev | sed 's/[ \t]*$//' | rev`
		if [ ! $mcheck = "Yes" ]; then
clear
			if [ $loc = "ru" ]; then
printf '\n\n !!! Не удалось подключить раздел EFI. Неизвестная ошибка !!!\n\n'
printf '\nВыходим. Конец программы. \n\n\n\n''\e[3J'
printf 'Нажмите любую клавишу закрыть терминал  '
				else
printf '\n\n !!! Failed to mount EFI partition. Unknown error. !!!\n\n'
printf '\nThe end of the program. \n\n\n\n''\e[3J'
printf 'Press any key to close the window  '
			fi
		     sleep 0.5
		     read  -n1 demo
     		     EXIT_PROGRAM
		fi
	fi
vname=`diskutil info /dev/${string} | grep "Mount Point:" | cut -d":" -f2 | rev | sed 's/[ \t]*$//' | rev`
clear
		if [ $loc = "ru" ]; then
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

var0=$pos
num=0
ch=0
unset string

rm -f   ~/.MountEFItemp.txt
touch  ~/.MountEFItemp.txt

			if [ $loc = "ru" ]; then
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
	if [ ! $mcheck = "Yes" ]; then
			printf '\n      '$ch') ...   '"$drive""%"$dcorr"s"${string}"%"$corr"s"'  '"%"$scorr"s""$dsize"  >> ~/.MountEFItemp.txt
		else
			printf '\n      '$ch')   +   '"$drive""%"$dcorr"s"${string}"%"$corr"s"'  '"%"$scorr"s""$dsize" >> ~/.MountEFItemp.txt
		fi


	let "num++"
	let "var0--"
done

printf "\n\r\n\033[5A"

		if [ $loc = "ru" ]; then
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
	
	printf '\n\n     '
	printf '.%.0s' {1..68}
	if [ $loc = "ru" ]; then

	printf '\n      U  -   отключить ВСЕ подключенные разделы  EFI \n' 
			else
	printf '\n      U  -   unmount ALL mounted  EFI partitions \n' 
	fi

	
	if [ $loc = "ru" ]; then
	printf '      Q  -   закрыть окно и выход из программы\n' 
			else
	printf '       Q  -  close terminal and exit from the program\n' 
	fi

	
printf '\n\n' 

}
# Конец определения GETLIST ###########################################################

# Определение функции обновления информации  экрана при подключении и отключении разделов
UPDATELIST(){


	if [[ $order = 0 ]]; then
cat  ~/.MountEFItemp.txt | sed "s/$chs) ...  /$chs)   +  /" >> ~/.MountEFItemp2.txt
	else
cat  ~/.MountEFItemp.txt | sed "s/$chs)   +  /$chs) ...  /" >> ~/.MountEFItemp2.txt
	fi

rm ~/.MountEFItemp.txt
mv  ~/.MountEFItemp2.txt ~/.MountEFItemp.txt
cat  -v ~/.MountEFItemp.txt
#printf "\033[0;0H"
clear

		if [ $loc = "ru" ]; then
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
printf "\r\033[1A"
	
	printf '\n\n     '
	printf '.%.0s' {1..68}
	if [ $loc = "ru" ]; then
	printf '\n      U  -   отключить ВСЕ подключенные разделы  EFI \n'
	printf '      Q  -   закрыть окно и выход из программы\n' 
			else
	printf '\n      U  -   unmount ALL mounted  EFI partitions \n' 
	printf '       Q  -  close terminal and exit from the program\n' 
	fi
	
	printf '\n\n'
	
	printf "\r\n\033[1A"
	
	if [ $loc = "ru" ]; then
let "schs=$ch-1"
printf '  Введите число от 0 до '$schs' (или  U, Q ):  '
			else
printf '  Enter a number from 0 to '$schs' (or  U, Q):  '
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

# Определение функции ожидания и фильтрации ввода с клавиатуры
GETKEYS(){
unset choice
while [[ ! ${choice} =~ ^[0-9uUqQ]+$ ]]; do
if [[ $order = 2 ]]; then 
printf '\r                                                          '
printf "\r\033[2A"
printf '\r                                                          '
order=0
fi
printf "\r\n\033[1A"
	if [ $loc = "ru" ]; then
let "schs=$ch-1"
printf '  Введите число от 0 до '$schs' (или  U, Q ):  '
			else
printf '  Enter a number from 0 to '$schs' (or  U, Q):  '
	fi


if [[ ${ch} -le 8 ]]; then 
read  -n1 choice
else
read choice
fi

if [[ ! $choice =~ ^[0-9uUqQ]$ ]]; then unset choice; fi
if [[ ${choice} = [uU] ]]; then unset nlist; UNMOUNTS; choice="R"; fi
if [[ ${choice} = [qQ] ]]; then choice=$ch; fi
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
if [ ! $mcheck = "Yes" ]; then

    if [ $flag = 1 ]; then 
                printf '\n  '; sudo printf ' '
            sudo diskutil quiet mount  /dev/${string}
        else 
            diskutil quiet mount  /dev/${string}
    fi
    mcheck=`diskutil info /dev/${string}| grep "Mounted:" | cut -d":" -f2 | rev | sed 's/[ \t]*$//' | rev`
 if [ ! $mcheck = "Yes" ]; then
clear
	if [ $loc = "ru" ]; then
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

	if [ $loc = "ru" ]; then
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
if  [ $chs = $ch ]; then
clear
	if [ $loc = "ru" ]; then
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

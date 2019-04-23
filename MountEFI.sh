#!/bin/sh

clear

osascript -e "tell application \"Terminal\" to set the font size of window 1 to 12"
osascript -e "tell application \"Terminal\" to set background color of window 1 to {1028, 12850, 65535}"
osascript -e "tell application \"Terminal\" to set normal text color of window 1 to {65535, 65535, 65535}"

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
		if [ $loc = "ru" ]; then
	printf '\nНеизвестная ошибка. Нет разделов EFI для монтирования\n'
	printf 'Конец программы...\n\n\n\n''\e[3J'
			else
	printf '\nUnknown error. No EFI partition found for mount\n'
	printf 'The end of the program...\n\n\n\n''\e[3J'
		fi
	exit 1
	fi
}


GETARR


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


if [[ $pos = 1 ]]; then
    clear 
unset string
string=`echo ${dlist[0]}`

mcheck=`diskutil info /dev/${string} | grep "Mounted:" | cut -d":" -f2 | rev | sed 's/[ \t]*$//' | rev`
	if [ ! $mcheck = "Yes" ]; then

		if [ $flag = 1 ]; then sudo diskutil quiet mount /dev/${string}
            		else
                			diskutil quiet mount /dev/${string}
		fi

mcheck=`diskutil info /dev/${string} | grep "Mounted:" | cut -d":" -f2 | rev | sed 's/[ \t]*$//' | rev`
		if [ ! $mcheck = "Yes" ]; then
			if [ $loc = "ru" ]; then
printf '\n\n !!! Не удалось подключить раздел EFI. Неизвестная ошибка !!!\n\n'
printf '\nВыходим. Конец программы. \n\n\n\n''\e[3J'
				else
printf '\n\n !!! Failed to mount EFI partition. Unknown error. !!!\n\n'
printf '\nThe end of the program. \n\n\n\n''\e[3J'
			fi
     		 exit 
		fi
	fi
vname=`diskutil info /dev/${string} | grep "Mount Point:" | cut -d":" -f2 | rev | sed 's/[ \t]*$//' | rev`

		if [ $loc = "ru" ]; then
			printf '\nРаздел: '${string}' ''подключен.\n\n'
   		 open "$vname"
			printf 'Выходим.. \n\n\n\n''\e[3J'
			else
			printf '\nPartition: '${string}' ''mounted.\n\n'
   		 open "$vname"
			printf 'Exit the program. \n\n\n\n''\e[3J'
		fi
sleep 1.2

osascript -e 'tell application "Terminal" to close first window' & exit
			
fi


GETLIST(){
		if [ $loc = "ru" ]; then
	printf '\n     Выберите действия:\n'
			else
	printf '\n      Select actions:\n'
		fi
var0=$pos
num=0
ch=0
unset string


		if [ $loc = "ru" ]; then
	printf '\n 0)  повторить поиск разделов'
	printf '\n\n Подключить EFI разделы: (    * -  уже подключенные) \n'
		else
	printf '\n 0)  update EFI partitions list'
	printf '\n\n Mount EFI partitions:  (   * -  already mounted) \n'
		fi

while [ $var0 != 0 ] 
do 
	let "ch++"
	
	pnum=${nlist[num]}
	string=`echo ${dlist[$pnum]}`
	mcheck=`diskutil info /dev/${string}| grep "Mounted:" | cut -d":" -f2 | rev | sed 's/[ \t]*$//' | rev`

				if [ $loc = "ru" ]; then
		if [ ! $mcheck = "Yes" ]; then
			printf '\n      '$ch')    ...      '
		else
			printf '\n      '$ch')         *   '
		fi
				else
		if [ ! $mcheck = "Yes" ]; then
			printf '\n         '$ch')    ...      '
		else
			printf '\n         '$ch')         *   '
		fi
				fi
	
		dstring=`echo $string | rev | cut -f2-3 -d"s" | rev`
		dlenth=`echo ${#dstring}`

	let "corr=9-dlenth"
	printf  ${string}"%"$corr"s"

    	dsize=`diskutil info /dev/${string} | grep "$vmacos" | sed -e 's/.*Size:\(.*\)Bytes.*/\1/' | cut -f1 -d"(" | rev | sed 's/[ \t]*$//' | rev`
	drive=`diskutil info /dev/${dstring} | grep "Device / Media Name:" | cut -d":" -f2 | rev | sed 's/[ \t]*$//' | rev`
    corr=`echo ${#dsize}`
    let "corr=corr-5"
    let "corr=6-corr"
	printf '  '"%"$corr"s""$dsize"'   . '"$drive"
	let "num=num+1"
	let "var0--"
done

	let "ch++"
	if [ $loc = "ru" ]; then
	printf '\n\n '$ch')  '' выход из программы не подключая EFI\n'
			else
	printf '\n\n '$ch')  ''  exit from the program without mounting EFI\n'
	fi
printf '\n\n'


unset choice
while [[ ! ${choice} =~ ^[0-9]+$ ]]; do
printf "\r\n\033[1A"
	if [ $loc = "ru" ]; then
printf 'Введите число от 0 до '$ch':  '
			else
printf 'Enter a number from 0 to '$ch':  '
	fi
read  -n1 choice
! [[ ${choice} -ge 0 && ${choice} -le $ch  ]] && unset choice
done
}

chs=0

while [ $chs = 0 ]; do
        clear && printf '\e[3J'
	if [ $loc = "ru" ]; then
        printf '\n\n******    Программа монтирует EFI разделы в Mac OS (X.11 - X.14)    *******\n\n'
			else
        printf '\n\n******    This program mounts EFI partitions on Mac OS (X.11 - X.14)    *******\n\n'
	fi
        unset nlist
        declare -a nlist
        GETARR
        GETLIST
        chs=$choice
done

if  [ $chs = $ch ]; then
	if [ $loc = "ru" ]; then
printf '\nВыходим. Конец программы. \n\n\n\n''\e[3J'
			else
printf '\nThe end of the program. \n\n\n\n''\e[3J'
	fi
sleep 1.2
    osascript -e 'tell application "Terminal" to close first window' & exit

fi

printf '\n'
let "num=chs-1"

pnum=${nlist[num]}
string=`echo ${dlist[$pnum]}`

    if [ $flag = 1 ]; then sudo diskutil quiet mount  /dev/${string}
        else 
            diskutil quiet mount  /dev/${string}
    fi
    mcheck=`diskutil info /dev/${string}| grep "Mounted:" | cut -d":" -f2 | rev | sed 's/[ \t]*$//' | rev`
if [ ! $mcheck = "Yes" ]; then
	if [ $loc = "ru" ]; then
printf '\n\n !!! Не удалось подключить раздел EFI. Неизвестная ошибка !!!\n\n'
printf '\nВыходим. Конец программы. \n\n\n\n''\e[3J'
			else
printf '\n\n !!! Failed to mount EFI partition. Unknown error. !!!\n\n'
printf '\nThe end of the program. \n\n\n\n''\e[3J'
	fi
exit 1 
fi

    vname=`diskutil info /dev/${string} | grep "Mount Point:" | cut -d":" -f2 | rev | sed 's/[ \t]*$//' | rev`
	if [ $loc = "ru" ]; then
printf '\nРаздел: '${string}' ''подключен.\n\n'
    open "$vname"
printf 'Выходим.. \n\n\n\n''\e[3J'
			else
printf '\nPartition: '${string}' ''mounted.\n\n'
    open "$vname"
printf 'Exit the program... \n\n\n\n''\e[3J'
	fi
sleep 1.2
    osascript -e 'tell application "Terminal" to close first window' & exit
exit
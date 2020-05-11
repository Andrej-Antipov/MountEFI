#!/bin/bash

#  Created by Андрей Антипов on 11.05.2020.#  Copyright © 2020 gosvamih. All rights reserved.

############################################################################## EasyESP #########################################################################################################################
prog_vers="1.0.0"
edit_vers="004"
##################################################################################################################################################################################################################

GET_LOCALE(){
if [[ ! ${MountEFIconf} = "" ]]; then 
        locale=`echo "$MountEFIconf" | grep -A 1 "Locale" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
        if [[ ! $locale = "ru" ]] && [[ ! $locale = "en" ]]; then loc=`defaults read -g AppleLocale | cut -d "_" -f1`
            else
                loc=`echo ${locale}`
        fi
else   
        loc=`defaults read -g AppleLocale | cut -d "_" -f1`; if [[ ! $loc = "ru" ]]; then loc="en"; fi
fi
}

UPDATE_CACHE(){
cache=1
if [[ -f ${HOME}/.MountEFIconf.plist ]]; then MountEFIconf=$( cat ${HOME}/.MountEFIconf.plist )
#elif [[ -f ~/Library/Application\ Support/EasyEFI/EasyEFIconf.plist ]]; then MountEFIconf=$( cat ~/Library/Application\ Support/EasyEFI/EasyEFIconf.plist )
else unset MountEFIconf; cache=0
fi
}

GET_APP_ICON(){
icon_string=""
if [[ -f "${ROOT}"/AppIcon.icns ]]; then 
   icon_string=' with icon file "'"$(echo "$(diskutil info $(df / | tail -1 | cut -d' ' -f 1 ) |  grep "Volume Name:" | cut -d':'  -f 2 | xargs)")"''"$(echo "${ROOT}" | tr "/" ":" | xargs)"':AppIcon.icns"'
fi 
}

ERROR_MSG(){
osascript -e 'display dialog '"${error_message}"'  with icon caution buttons { "OK"}  giving up after 3' >>/dev/null 2>/dev/null
if [[ ${menu_mode} = 0 ]]; then EXIT_PROGRAM; fi
}

DISPLAY_NOTIFICATION(){
osascript -e 'display dialog '"${MESSAGE}"'  '"${icon_string}"'  buttons { "OK"}  giving up after 3' >/dev/null 2>/dev/null
}

ERROR_NO_PASSWORD(){
if [[ $loc = "ru" ]]; then error_message='"Пароль не получен !\nНе могу подключить EFI раздел"'; else error_message='"Password not got!\nNCannot mount EFI partition"'; fi; ERROR_MSG
}

ERROR_NO_EI_FOUND(){
if [[ $loc = "ru" ]]; then error_message='"Странно !\nНе могу найти ни одного EFI раздела"'; else error_message='"Cannot find any EFI partition !"'; fi; ERROR_MSG
}

MESSAGE_SEARCH(){
osascript -e 'display dialog '"${MESSAGE}"' '"${icon_string}"' buttons { "OK"}' >>/dev/null 2>/dev/null
}

ONE_EFI_FOUND(){
if [[ $loc = "ru" ]]; then MESSAGE='"Открыть EFI раздел '${dlist[0]}' ?"'; else MESSAGE='"Open EFI partition '${dlist[0]}' ?"'; fi
if answer=$(osascript -e 'display dialog '"${MESSAGE}"' '"${icon_string}"' ' >>/dev/null 2>/dev/null); then cansel=0; else cansel=1; fi 2>/dev/null
}

################ запрос пароля sudo #################################
PROMT_SUDO_PASSWORD(){
mypassword=""        
        TRY=3
        while [[ ! $TRY = 0 ]]; do
        if [[ $loc = "ru" ]]; then
        if mypassword="$(osascript -e 'Tell application "System Events" to display dialog "Для подключения EFI разделов нужен пароль!\nОн будет храниться в вашей связке ключей\n\nПользователь:  '"$(id -F)"'\nВведите ваш пароль:" '"${icon_string}"' giving up after (110) with hidden answer  default answer ""' -e 'text returned of result')"; then cansel=0; else cansel=1; fi 2>/dev/null
        else
        if mypassword="$(osascript -e 'Tell application "System Events" to display dialog "Password is required to mount EFI partitions!\nIt will be keeped in your keychain\n\nUser Name:  '"$(id -F)"'\nEnter your password:" '"${icon_string}"' giving up after (110) with hidden answer  default answer ""' -e 'text returned of result')"; then cansel=0; else cansel=1; fi 2>/dev/null
        fi    
                if [[ $cansel = 1 ]] || [[ "${mypassword}" = "" ]]; then break; fi  
                if echo "${mypassword}" | sudo -Sk printf '' 2>/dev/null; then  break
                else
                        mypassword=""
                        let "TRY--"
                        if [[ ! $TRY = 0 ]]; then 
                        if [[ $loc = "ru" ]]; then
                        if [[ $TRY = 2 ]]; then ATTEMPT="ПОПЫТКИ"; LAST="ОСТАЛОСЬ"; fi
                        if [[ $TRY = 1 ]]; then ATTEMPT="ПОПЫТКА"; LAST="ОСТАЛАСЬ"; fi
                        MESSAGE='"НЕВЕРНЫЙ ПАРОЛЬ. '$LAST' '$TRY' '$ATTEMPT' !\n\nДля подключения разделов EFI нужен пароль"'
                        else
                        if [[ $TRY = 2 ]]; then ATTEMPT="ATTEMPTS"; fi
                        if [[ $TRY = 1 ]]; then ATTEMPT="ATTEMPT"; fi
                        MESSAGE='"INCORRECT PASSWORD. LEFT '$TRY' '$ATTEMPT' !\n\nPassword required to mount EFI partitions"'
                        fi
                DISPLAY_NOTIFICATION
                        fi
                fi
            done
}

ENTER_PASSWORD(){

SET_INPUT

if (security find-generic-password -a ${USER} -s efimounter -w) >/dev/null 2>&1; then
                if [[ "$1" = "force" ]]; then
                security delete-generic-password -a ${USER} -s efimounter >/dev/null 2>&1
                if [[ $loc = "ru" ]]; then
                MESSAGE='"СТАРЫЙ ПАРОЛЬ УДАЛЁН ИЗ СВЯЗКИ КЛЮЧЕЙ!"'
                else
                MESSAGE='"FORMER PASSWORD REMOVED FROM KEYCHAIN!"'
                fi
                DISPLAY_NOTIFICATION
                fi
fi

PROMT_SUDO_PASSWORD
if [[ ${mypassword} = "" ]]; then ERROR_NO_PASSWORD; else
    if (security find-generic-password -a ${USER} -s efimounter -w) >/dev/null 2>&1; then
        security delete-generic-password -a ${USER} -s efimounter >/dev/null 2>&1
    fi
        security add-generic-password -a ${USER} -s efimounter -w "${mypassword}" >/dev/null 2>&1
fi
}

GET_PASSWORD(){
mypassword=""
if (security find-generic-password -a ${USER} -s efimounter -w) >/dev/null 2>&1; then
mypassword=$(security find-generic-password -a ${USER} -s efimounter -w 2>/dev/null); fi
}

NEED_PASSWORD(){
need_password=0
if [[ ! $flag = 0 ]]; then 
              GET_PASSWORD
        if ! echo "${mypassword}" | sudo -Sk printf "" 2>/dev/null; then ENTER_PASSWORD "force"
           if [[ $mypassword = "" ]]; then need_password=1; fi
        fi
fi
}

GET_LOADERS(){
CheckLoaders=0
strng=$( echo "$MountEFIconf" | grep -A 1 -e "CheckLoaders</key>" | grep false | tr -d "<>/"'\n\t')
if [[ $strng = "true" ]]; then CheckLoaders=1
fi
}

GET_FLAG(){
macos=`sw_vers -productVersion`
macos=`echo ${macos//[^0-9]/}`
macos=${macos:0:4}
if [[ "$macos" = "1011" ]] || [[ "$macos" = "1012" ]]; then flag=0; else flag=1; GET_PASSWORD; fi
}

CHECK_USB(){

if [[ ! $posrm = 0 ]]; then
                usb=0
                for (( i=0; i<=$posrm; i++ ))
                do
                if [[ "${dstring}" = "${rmlist[$i]}" ]]; then usb=1; break; fi
                done                
            fi
}

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

# подготовка данных для вычисления hotplug
ustring=$( ioreg -c IOMedia -r  | tr -d '"|+{}\t'  | grep -A 10 -B 5  "Whole = Yes" | grep "BSD Name" | grep -oE '[^ ]+$' | xargs | tr ' ' ';') ; IFS=";"; uuid_list=($ustring); unset IFS; uuid_count=${#uuid_list[@]}
        if [[ ! $old_uuid_count = $uuid_count ]]; then old_uuid_count=$uuid_count; fi

pstring=$( df | cut -f1 -d " " | grep "/dev" | cut -f3 -d "/") ; puid_list=($pstring);  puid_count=${#puid_list[@]}
        if [[ ! $old_puid_count = $puid_count ]]; then  old_puid_count=$puid_count; old_puid_list=($pstring); old_uuid_list=($ustring); fi

}

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


for (( n=0; n<$pos; n++ )); do
    pnum=${nlist[$n]}
	string=`echo ${dlist[$pnum]}`
	dstring=`echo $string | rev | cut -f2-3 -d"s" | rev`
    CHECK_USB
    if [[ $usb = 1 ]]; then break; fi
done
fi
}

SET_INPUT(){

if [[ -f ~/Library/Preferences/com.apple.HIToolbox.plist ]]; then
    declare -a layouts_names
    layouts=$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleInputSourceHistory | egrep -w 'KeyboardLayout Name' | sed -E 's/.+ = "?([^"]+)"?;/\1/' | tr  '\n' ';') 2>/dev/null
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

GET_RENAMEHD(){

IFS=';'; rlist=( $(echo "$MountEFIconf" | grep -A 1 "RenamedHD" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n') ); unset IFS
rcount=${#rlist[@]}
if [[ ! $rcount = 0 ]]; then
      for posr in ${!rlist[@]}; do
            rdrive=$( echo "${rlist[$posr]}" | cut -f1 -d"=" )
            if [[ "$rdrive" = "$drive" ]]; then drive=$( echo "${rlist[posr]}" | rev | cut -f1 -d"=" | rev ); break; fi
         done
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
                echo "${mypassword}" | sudo -S diskutil quiet umount force  /dev/${string} 2>/dev/null           
                   else           
        	 	sudo diskutil quiet umount force  /dev/${string}
                   fi
	     fi
fi
}

UNMOUNTS(){

if [[ $loc = "ru" ]]; then
MESSAGE='"Отключение  EFI разделов .... !"'
else
MESSAGE='"Unmounting EFI partitions ....!"'
fi

MESSAGE_SEARCH &
mspid=$(($!+2))

GETARR

var1=$pos
num=0

cd "${ROOT}"

while [ $var1 != 0 ] 
do 

	pnum=${nlist[num]}; string=`echo ${dlist[$pnum]}`; mcheck=`df | grep ${string}`; if [[ ! $mcheck = "" ]]; then mcheck="Yes"; fi 
    if [[ $mcheck = "Yes" ]]; then diskutil quiet umount force  /dev/${string}; UNMOUNTED_CHECK; fi

    let "num++"
	let "var1--"
done

kill $mspid
wait $mspid 2>/dev/null
KILL_DIALOG
}

MOUNTED_CHECK(){

 mcheck=`df | grep ${string}`; if [[ ! $mcheck = "" ]]; then mcheck="Yes"; fi
	if [[ ! $mcheck = "Yes" ]]; then
    if [[ $loc = "ru" ]]; then
    MESSAGE='"НЕ УДАЛОСЬ ПОДКЛЮЧИТЬ РАЗДЕЛ EFI !\nОшибка подключения '${string}'"' 
    else
    MESSAGE='"FAILED TO MOUNT EFI PARTITION !\nError mounting '${string}'"' 
    fi
    DISPLAY_NOTIFICATION 
    fi
}

CHECK_PASSWORD(){
need_password=0
if ! echo "${mypassword}" | sudo -S printf "" 2>/dev/null; then        
       if [[ $password_was_entered = "0" ]]; then ENTER_PASSWORD "force"; password_was_entered=1;  fi
       if ! echo "${mypassword}" | sudo -S printf "" 2>/dev/null; then
            need_password=1
       fi
fi
}

DO_MOUNT(){
    	if [[ $flag = 0 ]]; then 
                    if ! diskutil quiet mount  /dev/${string} 2>/dev/null; then
                    sleep 1
                    diskutil quiet mount  /dev/${string} 2>/dev/null; fi  
        else
                    password_was_entered=0
                    if [[ $mypassword = "" ]]; then ENTER_PASSWORD; password_was_entered=1; fi
                    if [[ ! $mypassword = "" ]]; then
                        CHECK_PASSWORD
                        if [[ ${need_password} = 0 ]]; then
                            if ! sudo diskutil quiet mount  /dev/${string} 2>/dev/null; then 
                                sleep 1
                                sudo diskutil quiet mount  /dev/${string} 2>/dev/null
                            fi
                        fi
                    fi
        fi
MOUNTED_CHECK
}

GET_OPENFINDER(){
OpenFinder=1
strng=`echo "$MountEFIconf" | grep -A 1 -e "OpenFinder</key>" | grep false | tr -d "<>/"'\n\t'`
if [[ $strng = "false" ]]; then OpenFinder=0; fi
}

################################################### детект загрузчиков ##########################################################################################

CORRECT_OC_VERS(){

case $( md5 -qq "$vname"/EFI/OC/OpenCore.efi 2>/dev/null ) in 
        dd2bb459dfbb1fe04ca0cb61bb8f9581 ) oc_revision=.58r;;
        3e99e56bc16ed23129b3659a3d536ae9 ) oc_revision=.57r;;
                                        *)     oc_revision=""
esac 

}

################################ получение имени диска для переименования #####################
GET_OC_VERS(){

oc_revision=""

GET_CONFIG_VERS "OpenCore"

####### bootx64.efi у версии .57 и .58 одинаковый ###
######  уточняем версию через хэш OpenCore.efi ######
if [[ ${oc_revision} = "" ]]; then
    if [[ "${md5_loader}" = "10610877a9cc0ed958ff74ed7a192474" ]]; then
    CORRECT_OC_VERS
    fi
fi

if [[ ${oc_revision} = "" ]]; then

case "${md5_loader}" in
############## oc_hashes_strings 22 #################
297e30883f3db26a30e48f6b757fd968 ) oc_revision=.01r;;
e2c2dd105dc03dc16a69fd10ff2d0eac ) oc_revision=.01d;;
7805dc51bd280055d85775c512a832b0 ) oc_revision=.02r;;
bb222980e4823798202b3a9cff63b604 ) oc_revision=.02d;;
303a7f1391743e6bc52a38d614b5dd93 ) oc_revision=.03r;;
52195547d645623036effeadd31e21a9 ) oc_revision=.03d;;
91ea6c185c31a25c791da956c79808f9 ) oc_revision=.04r;;
5bb02432d1d1272fdcdff91fcf33d75b ) oc_revision=.04d;;
7844acab1d74aeccc5d2696627c1ed3d ) oc_revision=.50r;;
c221f59769bd185857b2c30858fe3aa2 ) oc_revision=.50d;;
eb66a8a986762b9cadecb6408ecb1ec7 ) oc_revision=.51r;;
c31035549f86156ff5e79b9d87240ec5 ) oc_revision=.51d;;
1ca142bf009ed537d84c980196c36d72 ) oc_revision=.52r;;
eaba9d5b467da41f5a872630d4ad7ff5 ) oc_revision=.52d;;
97f744526c733aa2e6505f01f37de6d7 ) oc_revision=.53r;;
b09cd76fadd2f7a14e76003b2ff4016f ) oc_revision=.53d;;
91e8abcf647af737d4a22fe3f98d00c0 ) oc_revision=.54r;;
5758e9b672486b863b18f6e5ff001b27 ) oc_revision=.54d;;
f3b1534643d3eb11fc18ac5a56528d79 ) oc_revision=.55r;;
07b64c16f48d61e5e9f2364467250912 ) oc_revision=.55d;;
12e5d34064fed06441b86b21f3fa3b7d ) oc_revision=.56r;;
9004a000df355d09a79ba510c055a5f0 ) oc_revision=.56d;;
10610877a9cc0ed958ff74ed7a192474 ) oc_revision=.5xr;;
9ff8a0c61dc1332dd58ecc311e0938b0 ) oc_revision=.57d;;
d90190bfea64112ed83621079371277a ) oc_revision=.58d;;
                                *)     oc_revision=""
                    esac
fi

################ no_release_hashes ##################
if [[ ${oc_revision} = "" ]]; then 
            
                 case "${md5_loader}" in
b3c22c4a30c3d6ee9dd8c9e202d62f1f ) oc_revision=.55ð
;;
e7d387c1e60de4a6264b65f0939fa58d ) oc_revision=.55n
;;
0b717fd908ae278a0b0de7c2ba21a5b3 ) oc_revision=.55ð
;;
bbce97ad42c5ce36ef1b00dd2d35cf41 ) oc_revision=.55ð
;;
ab9dcb265ab350bfe2695820394f269c ) oc_revision=.55n
;;
d3c0c19a82e9dbbf5e457ef85f8ad3b5 ) oc_revision=.55®
;;
13dd9af6c5289520dc7fad69299dd4c9 ) oc_revision=.55ð
;;
5e8fe9b3c1398f50c4bd126dade630ac ) oc_revision=.55®
;;
7a7b1fef20a36fcb216e0a012931b123 ) oc_revision=.55ð
;;
8e8fb33c3f0409bfc1d0e24a6340dc8a ) oc_revision=.55n
;;
4500e9f6f0d3d3fa9e4378931418b1f7 ) oc_revision=.54n
;;
3edc7635655663fdb9cf6979f7ef20f3 ) oc_revision=.54ð
;;
181e452d5aa32e168159aafbe8353d10 ) oc_revision=.54n
;;
005807d0d8ae2b8c0eed2822ab82ea5b ) oc_revision=.54ð
;;
aa99fb18962af96cc7d77f9331336aa7 ) oc_revision=.54n
;;
f8b52899bdff4a6c4062c1ef17acd1c9 ) oc_revision=.54ð
;;
31cd059b295eb8d3cccfb8d243dba02a ) oc_revision=.54®
;;
6a0aaf2df97fc11d9cca3b63a943d345 ) oc_revision=.54n
;;
992ea6899e67dabd396fca6b87b33058 ) oc_revision=.54ð
;;
8aab12ce737ec6b285a498c2e14700fd ) oc_revision=.54®
;;
5349b8cb888951e719fca0b6d7f017d3 ) oc_revision=.54n
;;
01a1c38cb71da54313a160504eb1aba0 ) oc_revision=.54ð
;;
d0a1ed17c3433f546fede7e2700e7322 ) oc_revision=.54®
;;
f677bc4739f8d94bdae1223727fbd67c ) oc_revision=.54ð
;;
96f479f194cc9048c43f511a5de793e8 ) oc_revision=.54n
;;
d0a1ed17c3433f546fede7e2700e7322 ) oc_revision=.53®
;;
2f674084287ebc38bd8d214f7c9f26f3 ) oc_revision=.53ð
;;
c6d4a4d0860d32e9e3faee2062a82a26 ) oc_revision=.53n
;;
                                *)     oc_revision=""
                    esac
fi

}

GET_CONFIG_VERS(){

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

}

GET_CONFIG_HASHES(){
oth_list_string="$( echo "$MountEFIconf" | grep XHashes  -A 9 | grep -A 1 -e "OTHER_HASHES</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' )"
IFS=';'; oth_list=($oth_list_string)
         ocr_list=( $( echo "$MountEFIconf" | grep XHashes  -A 7 | grep -A 1 -e "OC_REL_HASHES</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n' ) )
         ocd_list=( $( echo "$MountEFIconf" | grep XHashes  -A 5 | grep -A 1 -e "OC_DEV_HASHES" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n' ) )   
         clv_list=( $( echo "$MountEFIconf" | grep XHashes  -A 3 | grep -A 1 -e "CLOVER_HASHES</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n' ) )
unset IFS
}

GET_OTHER_LOADERS_STRING(){
if [[ ! ${#oth_list[@]} = 0 ]]; then 
                    for y in ${!oth_list[@]}; do
                    if [[ "${oth_list[y]:0:32}" = "${md5_loader}" ]]; then loader="Other"; loader+="${oth_list[y]:33}"; break; fi
                    done
               fi
}

GET_LOADER_STRING(){
                
               GET_OTHER_LOADERS_STRING
               
               if [[ ! "${loader:0:5}" = "Other" ]]; then
                
                    check_loader=$( xxd "$vname"/EFI/BOOT/BOOTX64.EFI | egrep -om1  "Clover|OpenCore|GNU/Linux|Microsoft C|Refind" )
                    case "${check_loader}" in
                    "Clover"    ) loader="Clover"; GET_CONFIG_VERS "Clover"
                                if [[ ${revision} = "" ]]; then
                                revision=$( xxd "$vname"/EFI/BOOT/BOOTX64.efi | grep -a1 "Clover" | cut -c 50-68 | tr -d ' \n' | egrep -o  'revision:[0-9]{4}' | cut -f2 -d: ); fi
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


SHIFT_UP(){
if [[ ! ${lddlist[pnum]} = "" ]]; then
                     max=0; for y in ${!mounted_loaders_list[@]}; do if [[ ${max} -lt ${y} ]]; then max=${y}; fi; done
                     for ((y=$((max+1));y>pnum;y--)); do mounted_loaders_list[y]=${mounted_loaders_list[((y-1))]}; done
fi
}

FIND_LOADERS(){
    unset loader; lflag=0
    if [[ $mcheck = "Yes" ]]; then 

vname=`df | egrep ${string} | sed 's#\(^/\)\(.*\)\(/Volumes.*\)#\1\3#' | cut -c 2-`

			if  [[ -f "$vname"/EFI/BOOT/BOOTX64.efi ]] && [[ -f "$vname"/EFI/BOOT/bootx64.efi ]] && [[ -f "$vname"/EFI/BOOT/BOOTx64.efi ]]; then 
                md5_loader=$( md5 -qq "$vname"/EFI/BOOT/BOOTx64.efi )                 
                if [[ ${md5_loader} = "" ]]; then loader=""; else
                   if [[ ${mounted_loaders_list[$pnum]} = ${md5_loader} ]]; then loader=""; else
                    SHIFT_UP
                    mounted_loaders_list[$pnum]="${md5_loader}"; lflag=1
                    GET_LOADER_STRING
                  fi
                fi
            else
                   if [[ ${mounted_loaders_list[pnum]} = "" ]] || [[ ! ${mounted_loaders_list[pnum]} = 0 ]]; then SHIFT_UP; loader="empty"; mounted_loaders_list[pnum]=0; fi
            fi
    fi
}

##############################################################################################################################################################
UPDATE_SCREEN(){

ask_efi_list=(); num=0; unset string; sata_lines=0; usb_lines=0; usb_screen_buffer=""; screen_buffer=""; var0=$pos; ldname=0

while [[ $var0 != 0 ]]; do

    pnum=${nlist[num]}
	string=`echo ${dlist[$pnum]}`
	dstring=`echo $string | rev | cut -f2-3 -d"s" | rev`
    dlenth=`echo ${#dstring}`
	let "corr=9-dlenth"
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
    CHECK_USB


    if [[ ! $CheckLoaders = 0 ]]; then FIND_LOADERS 
        if [[ ! ${loader} = "" ]];then
            if [[ ! ${lddlist[pnum]} = "" ]]; then
                     max=0; for y in ${!lddlist[@]}; do if [[ ${max} -lt ${y} ]]; then max=${y}; fi; done
                     for ((y=$((max+1));y>pnum;y--)); do lddlist[y]=${lddlist[((y-1))]}; ldlist[y]=${ldlist[((y-1))]}; done
            fi
             ldlist[pnum]=$loader; lddlist[pnum]=${dlist[pnum]}
        fi
 
                                lname=""
                                if [[ ${ldlist[pnum]:0:6} = "Clover" ]]; then
                                lname="Clover"; if [[ ! "${ldlist[pnum]:6:10}" = "" ]]; then lname+=" "${ldlist[pnum]:6:10}; fi
                                elif [[ ${ldlist[pnum]:0:12} = "unrecognized" ]]; then                 
                                     if [[ $loc = "ru" ]]; then lname="Не распознан"; else lname="Unrecognized"; fi
                                elif [[ ${ldlist[pnum]:0:5} = "Other" ]]; then
                                     lname="${ldlist[pnum]:5}"                                   
                                elif [[ ${ldlist[pnum]:0:9} = "GNU/Linux" ]]; then
                                     lname="GNU/Linux"
                                elif [[ ${ldlist[pnum]:0:6} = "refind" ]]; then
                                     lname="rEFInd"
                                elif [[ ${ldlist[pnum]:0:7} = "Windows" ]]; then
                                     lname="Windows MS"
                                elif [[ ${ldlist[pnum]:0:8} = "OpenCore" ]]; then
                                lname="OpenCore"; if [[ ! "${ldlist[pnum]:8:13}" = "" ]]; then lname+=" "${ldlist[pnum]:8:13}; fi
                                fi
                                
                                if [[ ! ${lname} = "" ]]; then ldname=1; lname1="-  "; lname1+="${lname}"; lname="${lname1}"; fi 
                                
    fi

    if [[ $usb = 1 ]]; then 
                    let "usb_lines++"
                    if [[ ! $mcheck = "Yes" ]]; then
        usb_screen_buffer+=$(printf '     ...   '"$drive""%"$dcorr"s"'    '${string}"%"$corr"s""%"$scorr"s"' '"$dsize"'   '"${lname}")";"
                            else
        usb_screen_buffer+=$(printf '       +   '"$drive""%"$dcorr"s"'    '${string}"%"$corr"s""%"$scorr"s"' '"$dsize"'   '"${lname}")";"
                    fi

    else
                    let "sata_lines++"
        
                     if [[ ! $mcheck = "Yes" ]]; then
               if [[ ${pnum} = 0 ]]; then  
        screen_buffer+=$(printf '     ...   '"$drive""%"$dcorr"s"'          '${string}"%"$corr"s""%"$scorr"s"' '"$dsize"'   '"${lname}")";"
               else
        screen_buffer+=$(printf '     ...   '"$drive""%"$dcorr"s"'    '${string}"%"$corr"s""%"$scorr"s"' '"$dsize"'   '"${lname}")";"
               fi
                    else
                if [[ ${pnum} = 0 ]]; then
        screen_buffer+=$(printf '       +   '"$drive""%"$dcorr"s"'         '${string}"%"$corr"s""%"$scorr"s"' '"$dsize"'   '"${lname}")";"
                else
        screen_buffer+=$(printf '       +   '"$drive""%"$dcorr"s"'    '${string}"%"$corr"s""%"$scorr"s"' '"$dsize"'   '"${lname}")";"
                fi
                    fi
    fi

    let "num++"
	let "var0--"

done
IFS=';'; ask_efi_list+=( ${screen_buffer} )
if [[ ! ${usb_screen_buffer} = "" ]]; then
if [[ ${ldname} = 1 ]]; then
ask_efi_list+=( "                                                                                               " ) 
ask_efi_list+=( "****************************************** USB *****************************************" )
else
ask_efi_list+=( "                                                                                 " ) 
ask_efi_list+=( "************************************** USB **************************************" )
fi
                                       ask_efi_list+=( ${usb_screen_buffer} )
fi
unset IFS

}


GETLIST(){

GET_LOADERS
CheckLoaders=1
if [[ ! $CheckLoaders = 0 ]]; then mounted_loaders_list=(); ldlist=(); lddlist=(); else lname=""; fi 

UPDATE_SCREEN
}

ASK_LIST(){
if [[ ${ldname} = 1 ]]; then 
efi_prompt_list='"*********************************************************************************************"'","
else
efi_prompt_list='"*****************************************************************************"'","
fi
for i in ${!ask_efi_list[@]}; do efi_prompt_list+='"'"${ask_efi_list[i]}"'"'; efi_prompt_list+=","; done
if [[ ${ldname} = 1 ]]; then
    if [[ $loc = "ru" ]]; then
    efi_prompt_list+='"'"                                                                                "'"'","
    efi_prompt_list+='"'"*********************************** дополнительно *****************************************"'"'","
        efi_prompt_list+='"                                  Отключить все подключенные EFI разделы  "'","
    if [[ ${menu_mode} = 1 ]]; then
        efi_prompt_list+='"                                  Найти и подключить разделы с OpenCore  "'","
        efi_prompt_list+='"                                  Найти и подключить разделы с Clover  "'","
        efi_prompt_list+='"                                  Проверить все BOOTx64.efi в разделах EFI  "'","
        efi_prompt_list+='"                                  Включить упрощённый режим управления  "'
    else
        efi_prompt_list+='"                                  Включить расширенный режим управления  "'
    fi
else
    efi_prompt_list+='"'"*************************************** additionally: ****************************************"'"'","
        efi_prompt_list+='"                                       Unmount ALL mounted EFI partitions  "'","
    if [[ ${menu_mode} = 1 ]]; then
        efi_prompt_list+='"                                       Find and mount EFI partitions with OpenCore  "'","
        efi_prompt_list+='"                                       Find and mount EFI partitions with Clover  "'","
        efi_prompt_list+='"                                       Searching all BOOTx64.efi in EFI partitions "'","
        efi_prompt_list+='"                                       Switch menu to simple management mode "'
    else
        efi_prompt_list+='"                                       Switch menu to advanced management mode "'
    fi
fi
else
efi_prompt_list+='"'"                                                                         "'"'","
if [[ $loc = "ru" ]]; then
efi_prompt_list+='"'"***************************** дополнительно: ******************************"'"'","
            efi_prompt_list+='"                          Отключить все подключенные EFI разделы  "'","
        if [[ ${menu_mode} = 1 ]]; then
            efi_prompt_list+='"                          Найти и подключить разделы с OpenCore  "'","
            efi_prompt_list+='"                          Найти и подключить разделы с Clover  "'","
            efi_prompt_list+='"                          Проверить все BOOTx64.efi в разделах EFI  "'","
            efi_prompt_list+='"                          Включить упрощённый режим управления  "'
        else
            efi_prompt_list+='"                          Включить расширенный режим управления  "'
        fi
else
efi_prompt_list+='"'"******************************* additionally: *********************************"'"'","
            efi_prompt_list+='"                                Unmount ALL mounted EFI partitions  "'","
        if [[ ${menu_mode} = 1 ]]; then
            efi_prompt_list+='"                                Find and mount EFI partitions with OpenCore  "'","
            efi_prompt_list+='"                                Find and mount EFI partitions with Clover  "'","
            efi_prompt_list+='"                                Searching all BOOTx64.efi in EFI partitions "'","
            efi_prompt_list+='"                                Switch menu to simple management mode "'
        else
            efi_prompt_list+='"                                Switch menu to advanced management mode "'
        fi
fi
fi

if [[ $loc = "ru" ]]; then
osascript <<EOD
tell application "System Events"    activate
set ThemeList to {$efi_prompt_list}
set FavoriteThemeAnswer to choose from list ThemeList with title "Список EFI / ESP разделов"  with prompt "Выберите один или несколько (CMD + клик) для подключения:\nЗнаком + отмечены подключенные." with multiple selections allowed OK button name {"Поехали!"} cancel button name {"Выход"}
end tell
EOD

else

osascript <<EOD
tell application "System Events"    activate
set ThemeList to {$efi_prompt_list}
set FavoriteThemeAnswer to choose from list ThemeList with title "EFI / ESP partition list"  with prompt "Select one or more (CMD + click) to mount:\nA + sign indicates mounted.." with multiple selections allowed cancel button name {"Exit"}
end tell
EOD

fi

}

FIND_CLOVER(){

NEED_PASSWORD

if [[ ${need_password} = 0 ]]; then

if [[ $loc = "ru" ]]; then
MESSAGE='"Поиск EFI разделов с загрузчиком Clover .... !"'
else
MESSAGE='"Searching for EFI partitions with Clover .... !"'
fi
MESSAGE_SEARCH &
mspid=$(($!+2))

was_mounted=0; var1=$pos; num=0
while [ $var1 != 0 ]; do 
    pnum=${nlist[num]}; string=`echo ${dlist[$pnum]}`; mcheck=`df | grep ${string}`; if [[ ! $mcheck = "" ]]; then mcheck="Yes"; fi
	if [[ ! $mcheck = "Yes" ]]; then was_mounted=0; DO_MOUNT ; else was_mounted=1; fi

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

    if [[ "$was_mounted" = 0 ]]; then diskutil quiet  umount  force /dev/${string}; mounted=0; UNMOUNTED_CHECK; fi
		
    let "num++"
    let "var1--"
done

kill $mspid
wait $mspid 2>/dev/null
KILL_DIALOG

fi
}

FIND_OPENCORE(){

NEED_PASSWORD

if [[ ${need_password} = 0 ]]; then

if [[ $loc = "ru" ]]; then
MESSAGE='"Поиск EFI разделов с загрузчиком OpenCore .... !"'
else
MESSAGE='"Searching for EFI partitions with OpenCore .... !"'
fi
MESSAGE_SEARCH &
mspid=$(($!+2))

was_mounted=0; var1=$pos; num=0
while [ $var1 != 0 ]; do 
    pnum=${nlist[num]}; string=`echo ${dlist[$pnum]}`; mcheck=`df | grep ${string}`; if [[ ! $mcheck = "" ]]; then mcheck="Yes"; fi
	if [[ ! $mcheck = "Yes" ]]; then was_mounted=0; DO_MOUNT ; else was_mounted=1; fi

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

    if [[ "$was_mounted" = 0 ]]; then diskutil quiet  umount  force /dev/${string}; mounted=0; UNMOUNTED_CHECK; fi
		
    let "num++"
    let "var1--"
done

kill $mspid
wait $mspid 2>/dev/null
KILL_DIALOG
fi
}

FIND_ALL_LOADERS(){

NEED_PASSWORD

if [[ ${need_password} = 0 ]]; then

if [[ $loc = "ru" ]]; then
MESSAGE='"Поиск и распознавание всех BOOTx64.efi\nв EFI разделах .... !"'
else
MESSAGE='"Searching for EFI partitions and detecting\nBOOTx64.efi loaders ....!"'
fi
MESSAGE_SEARCH &
mspid=$(($!+2))

mounted_loaders_list=(); ldlist=(); lddlist=()

was_mounted=0; var1=$pos; num=0
while [ $var1 != 0 ]; do 
    pnum=${nlist[num]}; string=`echo ${dlist[$pnum]}`; mcheck=`df | grep ${string}`; if [[ ! $mcheck = "" ]]; then mcheck="Yes"; fi
	if [[ ! $mcheck = "Yes" ]]; then was_mounted=0; DO_MOUNT ; else was_mounted=1; fi

    FIND_LOADERS

    if [[ ! ${loader} = "" ]];then
       if [[ ! ${lddlist[pnum]} = "" ]]; then
              max=0; for y in ${!lddlist[@]}; do if [[ ${max} -lt ${y} ]]; then max=${y}; fi; done
              for ((y=$((max+1));y>pnum;y--)); do lddlist[y]=${lddlist[((y-1))]}; ldlist[y]=${ldlist[((y-1))]}; done
       fi
             ldlist[pnum]="${loader}"; lddlist[pnum]=${dlist[pnum]}
    fi

    if [[ "$was_mounted" = 0 ]]; then diskutil quiet  umount  force /dev/${string}; mounted=0; UNMOUNTED_CHECK; fi
		
    let "num++"
    let "var1--"
done

kill $mspid
wait $mspid 2>/dev/null
KILL_DIALOG

fi
}

KILL_DIALOG(){
if [[ ! $(ps ax | grep -v grep | grep "display dialog" | xargs | cut -f1 -d' ') = "" ]]; then 
   kill $(ps ax | grep -v grep | grep "display dialog" | xargs | cut -f1 -d' '); fi
}

EXIT_PROGRAM(){
KILL_DIALOG
sudo -k
exit
}
############################################################################################
#################################### MAIN ##################################################

menu_mode=0
GET_FLAG
UPDATE_CACHE
GET_CONFIG_HASHES
GET_LOCALE 
cd "$(dirname "$0")"; ROOT="$(dirname "$0")"
GET_APP_ICON
if [[ $loc = "ru" ]]; then
MESSAGE='"Поиск EFI разделов .... !"'
else
MESSAGE='"Searching for EFI partitions ....!"'
fi
MESSAGE_SEARCH &
mspid=$(($!+2))
GETARR
if [[ ${pos} = 0 ]]; then menu_mode=0; KILL_DIALOG; ERROR_NO_EI_FOUND; fi
if [[ ${pos} = 1 ]]; then KILL_DIALOG; ONE_EFI_FOUND; if [[ $cansel = 0 ]]; then 
            NEED_PASSWORD; string=${dlist[0]}; DO_MOUNT
            GET_OPENFINDER; if [[ "${OpenFinder}" = "1" ]]; then open $(df | egrep ${string} | sed 's#\(^/\)\(.*\)\(/Volumes.*\)#\1\3#' | cut -c 2-); fi
            EXIT_PROGRAM; fi
fi

GETLIST
kill $mspid
wait $mspid 2>/dev/null
KILL_DIALOG
while true; do
#################### MAIN MENU #####################
result_names=$( ASK_LIST ) 

if [[ ! $(ps ax | grep -v grep | grep "System Events" | xargs | cut -f1 -d' ') = "" ]]; then 
   kill $(ps ax | grep -v grep | grep "System Events" | xargs | cut -f1 -d' '); fi
if [[ ${result_names} = "false" ]]; then break; fi

    modename=$(echo "${result_names}" | egrep -o "расширенный|advanced|упрощённый|simple")
        case ${modename} in
            расширенный ) menu_mode=1 ;;
            advanced    ) menu_mode=1 ;;
            упрощённый  ) menu_mode=0 ;;
            simple      ) menu_mode=0 ;;
        esac

if [[ ${modename} = "" ]]; then

    scan=( $(echo "${result_names}" | egrep -o "с Clover|с OpenCore|все BOOTx64.efi|with OpenCore|with Clover|all BOOTx64.efi" | egrep -o "Clover|OpenCore|BOOTx64.efi") )

        for i in ${!scan[@]}; do
            case ${scan[i]} in
            OpenCore    ) FIND_OPENCORE     ;;
            Clover      ) FIND_CLOVER       ;;
            BOOTx64.efi ) FIND_ALL_LOADERS  ;;
            esac
        done

    unmount=$(echo "${result_names}" | egrep -o "Отключить|Unmount")
    if [[ ! ${unmount} = "" ]]; then
        UNMOUNTS    
    fi

    disk_mount_list=( $(echo "${result_names}" | egrep -o "disk[0-9]*s[0-9]*") )
    if [[ ! ${#disk_mount_list[@]} = "0" ]]; then 
        NEED_PASSWORD    
    if [[ ${need_password} = 0 ]]; then
        UPDATE_CACHE
        GET_OPENFINDER
    for string in ${disk_mount_list[@]}; do
        mcheck=`df | grep ${string}`; if [[ ! $mcheck = "" ]]; then mcheck="Yes"; fi 
        if [[ ! $mcheck = "Yes" ]]; then wasmounted=0; DO_MOUNT; else wasmounted=1; fi
        vname=`df | egrep ${string} | sed 's#\(^/\)\(.*\)\(/Volumes.*\)#\1\3#' | cut -c 2-`
        if [[ $mcheck = "Yes" ]]; then if [[ "${OpenFinder}" = "1" ]] || [[ "${wasmounted}" = "1" ]]; then open "$vname"; fi; fi
    done
        if [[ ${menu_mode} = 0 ]]; then break; fi
    fi
    fi
fi
UPDATE_SCREEN
done

EXIT_PROGRAM
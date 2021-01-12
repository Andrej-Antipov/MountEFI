#!/bin/bash

#  Created by Андрей Антипов on 11.01.2021.#  Copyright © 2020 gosvamih. All rights reserved.

########################################################################## MountEFI scan agent ###################################################################################################################
prog_vers="1.9.0"
edit_vers="004"
serv_vers="011"
##################################################################################################################################################################################################################
# https://github.com/Andrej-Antipov/MountEFI/releases

logfile="${HOME}/Desktop/temp.txt"
TSP(){ printf "$(date '+%M:%S.'$(echo $(python -c 'import time; print repr(time.time())') | cut -f2 -d.))    "  >> "${logfile}" 2>/dev/null; }
DBG(){ if $DEBUG; then TSP; echo $1 >> "${logfile}" 2>/dev/null; fi;  }

CONFPATH="${HOME}/.MountEFIconf.plist"
SERVFOLD_PATH="${HOME}/Library/Application Support/MountEFI"
MEFIScA_PATH="${SERVFOLD_PATH}/MEFIScA"
STACK_PATH="${MEFIScA_PATH}/MEFIscanAgentStack"

MountEFIconf=$(cat "${CONFPATH}")

DEBUG=$(echo "${MountEFIconf}" | grep -A1 "DEBUG</key>" | egrep -o "false|true"); if [[ $DEBUG = "" ]]; then DEBUG="false"; fi

ocHashes32string=$(echo "${MountEFIconf}" | grep -A3  "<key>YHashes</key>" | grep -A1 -o "<key>ocHashes32</key>" | grep string |  sed -e 's/.*>\(.*\)<.*/\1/' | tr ';' '\n')
ocHashes64string=$(echo "${MountEFIconf}" | grep -A5  "<key>YHashes</key>" | grep -A1 -o "<key>ocHashes64</key>" | grep string |  sed -e 's/.*>\(.*\)<.*/\1/' | tr ';' '\n')


WAITFLAG_ON(){ if [[ -f "${MEFIScA_PATH}"/clientReady ]]; then touch "${MEFIScA_PATH}"/WaitSynchro; DBG "MEFIScA WAIT ON"; fi; }
WAITFLAG_OFF(){ rm -f "${MEFIScA_PATH}"/WaitSynchro; DBG "MEFIScA WAIT OFF"; }
WAIT_CLIENT_DOWN(){ DBG "MEFIScA wait Client Down"; while WAIT_CLIENT_OFFLINE ; do sleep 0.5; done; DBG "MEFISCA client seems DOWN:"; }
SERVER_GET_READY(){ touch "${MEFIScA_PATH}/ServerGetReady"; DBG "SERVER GET READY"; }
SERVER_READY_OFF(){ rm -f "${MEFIScA_PATH}/ServerGetReady"; DBG "SERVER READY OFF, ONLINE"; }
RELOADFLAG_OFF(){ rm -f "${MEFIScA_PATH}"/reloadFlag; }
CLIENT_READY(){ [[ -f "${MEFIScA_PATH}"/clientReady ]]; }
CLIENT_NOT_DOWN(){ [[ ! -f "${MEFIScA_PATH}"/clientDown ]]; }
CLIENT_RESTARTING(){ [[ -f "${MEFIScA_PATH}"/clientRestart ]]; }
CLEAR_PROHIBITION_FLAGS(){ "${MEFIScA_PATH}"/ClientHotplugReady "${MEFIScA_PATH}"/StackUptoDate; }
CLIENT_RUN(){ [[ ! $(ps xao tty,command | grep -v grep | egrep -o "MountEFI$" | wc -l | bc) = 0 ]]; }
WAIT_CLIENT_OFFLINE(){ CLIENT_RESTARTING || ( CLIENT_RUN && CLIENT_NOT_DOWN ); }
CLIENT_ONLINE(){ CLIENT_RUN && CLIENT_READY; }
HOTPLUG(){ [[ $hotplug = 1 ]] || [[ $update_screen_flag = 1 ]]; }
GET_OC_LIST_ITEM(){ oc_list[pnum]="${md5_loader}$( md5 -qq "$vname"/EFI/OC/OpenCore.efi 2>/dev/null )"; }

if [[ -f "${MEFIScA_PATH}"/reloadFlag ]]; then reloadFlag=1; RELOADFLAG_OFF; else reloadFlag=0; if [[ -d "${MEFIScA_PATH}" ]]; then rm -Rf "${STACK_PATH}"; fi; fi
touch "${MEFIScA_PATH}"/WaitSynchro; DBG "MEFIScA WAIT ON"

DBG "MEFIScA launch up v.008-007"

#############################################################################################
SAVE_LOADERS_STACK(){
    if [[ ! -d "${STACK_PATH}" ]]; then mkdir -p "${STACK_PATH}"; else rm -Rf "${STACK_PATH}"/*; fi
    sleep 0.125; WAITFLAG_ON; SERVER_GET_READY
    DBG "MEFIScA start data pass" ~/Desktop/temp.txt
    pushd "${STACK_PATH}" >/dev/null 2>/dev/null
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
    DBG "MEFIScA stop data pass"
    WAITFLAG_OFF
}

GET_MOUNTEFI_STACK(){
DBG "MEFIsCA start data get"
rm -f "${MEFIScA_PATH}"/clientReady "${MEFIScA_PATH}"/clientDown "${MEFIScA_PATH}"/clientRestart
IFS=';'; mounted_loaders_list=( $(cat "${STACK_PATH}"/mounted_loaders_list | tr '\n' ';' ) )
ldlist=( $(cat "${STACK_PATH}"/ldlist | tr '\n' ';' ) )
lddlist=( $(cat "${STACK_PATH}"/lddlist | tr '\n' ';' ) )
oc_list=( $(cat "${STACK_PATH}"/oc_list 2>/dev/null | tr '\n' ';' ) )
#DBG "MEFIScA oc_list got = $(for i in ${!oc_list[@]}; do printf "$i) ${oc_list[i]} "; done)"
if [[ -f "${STACK_PATH}"/dlist ]]; then dlist=( $(cat "${STACK_PATH}"/dlist | tr '\n' ';' ) ); fi;  unset IFS
for i in ${!mounted_loaders_list[@]}; do old_mounted[i]=${mounted_loaders_list[i]}; done
for i in ${!ldlist[@]}; do old_ldlist[i]="${ldlist[i]}"; done
for i in ${!dlist[@]}; do old_dlist[i]=${dlist[i]}; done
for i in ${!lddlist[@]}; do old_lddlist[i]=${lddlist[i]}; done
STORE_HOTPLUG_STATE
DBG "MEFIsCA stop data get"
}

##################################################################################################################################################

GET_OC_VERS(){

oc_revision=""

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

##################### проверка на загрузчик после монтирования ##################################################################################
GET_LOADER_STRING(){                              
               if [[ ! "${loader:0:5}" = "Other" ]]; then             
                    check_loader=$( xxd -l 40000 "$vname"/EFI/BOOT/BOOTX64.EFI | egrep -om1  "OpenCore" )
                    if [[ "${check_loader}" = "" ]]; then check_loader=$( xxd "$vname"/EFI/BOOT/BOOTX64.EFI | egrep -om1  "Clover|GNU/Linux|Microsoft C|Refind" ); fi
                    case "${check_loader}" in
                    "Clover"    ) loader="Clover"
                                revision=$( xxd "$vname"/EFI/BOOT/BOOTX64.efi | grep -a1 "Clover" | cut -c 50-68 | tr -d ' \n' | egrep -o  'revision:[0-9]{4}' | cut -f2 -d: )
                                if [[ ${revision} = "" ]]; then revision=$( xxd  "$vname"/EFI/BOOT/BOOTX64.efi | grep -a1 'revision:' | cut -c 50-68 | tr -d ' \n' | egrep -o  'revision:[0-9]{4}' | cut -f2 -d: ); fi
                                loader+="${revision:0:4}"
                                ;;
  
                    "OpenCore"  ) GET_OC_LIST_ITEM; GET_OC_VERS; loader="OpenCore"; loader+="${oc_revision}"
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
                fi
}
#######################################################################################################################################################

# Oпределение функции обновления экрана в случае замены файла загрузчика ####################################################
RECHECK_LOADERS(){
if [[ $pauser = "" ]] || [[ $pauser = 0 ]]; then
        let "pauser=2"; update_screen_flag=0
        for pnum in ${!dlist[@]}
        do
        mounted_check=$( df | grep ${dlist[$pnum]} )   
            if [[ ! $mounted_check = "" ]]; then 
            vname=`df | egrep ${dlist[$pnum]} | sed 's#\(^/\)\(.*\)\(/Volumes.*\)#\1\3#' | cut -c 2-`
                    if ! loader_sum=$( md5 -qq "$vname"/EFI/BOOT/BOOTx64.efi 2>/dev/null); then loader_sum=0; fi
                    if [[ ! ${loader_sum} = 0 ]] && [[ $( xxd -l 40000 "$vname"/EFI/BOOT/BOOTX64.EFI | egrep -om1 "OpenCore" ) = "OpenCore" ]]; then md5_loader=${loader_sum}; GET_OC_LIST_ITEM; GET_OC_VERS
                       if [[ ! "${old_oc_revision[pnum]}" = "${oc_revision}" ]]; then echo "••1••" ; old_oc_revision[pnum]="${oc_revision}"; update_screen_flag=1; else update_screen_flag=0; fi
                    fi
                    if [[ ! ${mounted_loaders_list[$pnum]} = ${loader_sum} ]] || [[ ${update_screen_flag} = 1 ]]; then 
                    mounted_loaders_list[$pnum]=${loader_sum}
                    if [[ ${loader_sum} = 0 ]]; then loader="empty"; else md5_loader=${loader_sum}; loader=""; oc_revision=""; revision="";  GET_LOADER_STRING; fi
                    ldlist[pnum]="$loader"; lddlist[pnum]=${dlist[$pnum]}
                    let "chs=pnum+1"; UPDATE_SCREEN; update_screen_flag=1; WAITFLAG_ON; break; fi
            fi
        done
    else
        let "pauser=pauser-1"
fi
}
#################################################################################################################################
##################### проверка на загрузчик после монтирования ##################################################################################
FIND_LOADERS(){

    unset loader; lflag=0
    if [[ $mcheck = "Yes" ]]; then 
vname=$(df | egrep ${string} | sed 's#\(^/\)\(.*\)\(/Volumes.*\)#\1\3#' | cut -c 2-)
			if  [[ -f "$vname"/EFI/BOOT/BOOTX64.efi ]]; then 
                md5_loader=$( md5 -qq "$vname"/EFI/BOOT/BOOTx64.efi )            
                if [[ ${md5_loader} = "" ]]; then loader=""
                    #elif [[ ${mounted_loaders_list[$pnum]} = ${md5_loader} ]]; then loader=""
                        else mounted_loaders_list[$pnum]="${md5_loader}"
                            lflag=1; GET_LOADER_STRING
                fi
            elif [[ ${mounted_loaders_list[pnum]} = "" ]] || [[ ! ${mounted_loaders_list[pnum]} = 0 ]]; then loader="empty"; mounted_loaders_list[pnum]=0
            fi
    fi
}
#######################################################################################################################################################

STORE_HOTPLUG_STATE(){
ustring=$( ioreg -c IOMedia -r  | tr -d '"|+{}\t'  | grep -A 10 -B 5  "Whole = Yes" | grep "BSD Name" | grep -oE '[^ ]+$' | xargs | tr ' ' ';') ; IFS=";"; uuid_list=($ustring); unset IFS; uuid_count=${#uuid_list[@]}
        if [[ ! $old_uuid_count = $uuid_count ]]; then old_uuid_count=$uuid_count; fi

pstring=$( df | cut -f1 -d " " | grep "/dev" | cut -f3 -d "/") ; puid_list=($pstring);  puid_count=${#puid_list[@]}
        if [[ ! $old_puid_count = $puid_count ]]; then  old_puid_count=$puid_count; old_puid_list=($pstring); old_uuid_list=($ustring); fi
}

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
ustring=`ioreg -c IOMedia -r  | tr -d '"|+{}\t'  | grep -A 10 -B 5  "Whole = Yes" | grep "BSD Name" | grep -oE '[^ ]+$' | xargs | tr ' ' ';'` ; IFS=";"; uuid_list=($ustring); unset IFS; uuid_count=${#uuid_list[@]}

        if [[ ! $old_uuid_count = $uuid_count ]]; then
            if [[  $old_uuid_count -lt $uuid_count ]]; then 
                synchro=1; WAITFLAG_ON
               ioreg_iomedia=`ioreg -c IOMedia -r | tr -d '"|+{}\t'`
                    disk_images=`echo "$ioreg_iomedia" | egrep -A 22 "Apple " | grep "BSD Name" | cut -f2 -d "="  | tr -d " " | tr '\n' ';'`
                    IFS=';'; ilist=($disk_images); unset IFS; posi=${#ilist[@]}
                else
                    synchro=3; WAIFLAG_ON
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
######################################################################################################################################################

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
if [[ ! ${#new_remlist[@]} = 0 ]]; then
    for i in ${!dlist[@]}; do pnum=${nlist[i]}; string=${dlist[$pnum]}
        for z in ${new_remlist[@]}; do 
        if [[ $string = $z ]] && [[ $(df | grep ${string}) = "" ]]; then
            DO_MOUNT
            if [[ ! $(df | grep ${string}) = "" ]]; then mcheck="Yes"
            FIND_LOADERS
            if [[ ! ${loader} = "" ]];then ldlist[pnum]="$loader"; lddlist[pnum]=${dlist[pnum]}; fi
            if ! diskutil quiet  umount /dev/${string}; then sleep 0.5; diskutil quiet  umount force /dev/${string}; fi
            fi
        fi
        done
    done
fi
}

WAIT_SYNCHRO(){
new_remlist=()
if [[ ${synchro} = 1 ]] || [[ ${synchro} = 3 ]]; then
if [[ ${synchro} = 3 ]]; then new_rmlist=( ${rmlist[@]} ); sleep 0.25; else
new_rmlist=( $( echo ${rmlist[@]} ${past_rmlist[@]} | tr ' ' '\n' | sort | uniq -u | tr '\n' ' ' ) )
if [[ ! ${#new_rmlist[@]} = 0 ]]; then
    init_time="$(date +%s)"; usblist=()
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
    if [[ ! ${#usblist[@]} = 0 ]]; then exec_time=0
        while true; do
            mounted_list=( $( df | cut -f1 -d" " | grep disk | cut -f3 -d/ | tr '\n' ' ') )
            usb_mounted_list=()
            for z in ${mounted_list[@]}; do for y in ${usblist[@]}; do if [[ ${z} = ${y} ]]; then usb_mounted_list+=( ${z} ); break; fi; done; done
            diff_usb=( $( echo ${usblist[@]} ${usb_mounted_list[@]} | tr ' ' '\n' | sort | uniq -u | tr '\n' ' ' ) )
            if [[ ${#diff_usb[@]} = 0 ]]; then break; fi
            exec_time="$(($(date +%s)-init_time))"
            if [[ ${exec_time} -ge 36 ]]; then break; fi
            sleep 0.25
        done
    fi
fi
fi
CORRECT_LOADERS_LIST
GET_LOADERS_FROM_NEW_PARTS
synchro=0
#######################
 fi
}

###################### движок детекта EFI разделов ####################################################
GETARR(){

past_rmlist=( ${rmlist[@]} )

ioreg_iomedia=$( ioreg -c IOMedia -r | tr -d '"|+{}\t' )
usb_iomedia=$( IOreg -c IOBlockStorageServices -r | grep "Device Characteristics" | tr -d '|{}"' | sed s'/Device Characteristics =//' | rev | cut -f2-3 -d, | rev | tr '\n' ';'  | xargs )
drives_iomedia=$( echo "$ioreg_iomedia" |  egrep -A 22 "<class IOMedia," )
string=$( diskutil list | grep EFI | grep -oE '[^ ]+$' | xargs | tr ' ' ';' )
disk_images=$( echo "$ioreg_iomedia" | egrep -A 22 "Apple " | grep "BSD Name" | cut -f2 -d "="  | tr -d " " | tr '\n' ';' )
syspart=$( df / | grep /dev | cut -f1 -d " " | sed s'/dev//' | tr -d '/ \n' )
IFS=';'; dlist=($string); ilist=($disk_images); usb_iolist=($usb_iomedia); unset IFS; pos=${#dlist[@]}; posi=${#ilist[@]}; pusb=${#usb_iolist[@]}

# exclude disk images
if [[ ! $posi = 0 ]]; then tmlist=()
for ((i=0;i<$pos;i++)); do match=0; for ((n=0;n<$posi;n++)); do if [[ $( echo ${dlist[i]} | rev | cut -f2-3 -d"s" | rev ) = ${ilist[n]} ]]; then match=1; break; fi; done
    if [[ $match = 0 ]]; then tmlist+=( ${dlist[i]} ); fi; done; if [[ ! ${#tmlist[@]} = 0 ]]; then dlist=( ${tmlist[@]} ); pos=${#dlist[@]}; fi
fi

# make list of disks
dmlist=(); for (( i=0; i<$pos; i++ )) do dmlist+=( $( echo ${dlist[i]} | rev | cut -f2-3 -d"s" | rev ) ); done
dmlist=( $(echo "${dmlist[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ') ); posd=${#dmlist[@]}

# get list of usb drives
rmlist=(); posrm=0; 
if [[ ! $pusb = 0 ]]; then usbnames=(); for (( i=0; i<$pusb; i++ )); do usbname="$(echo ${usb_iolist[i]} | cut -f3 -d=)"; usbnames+=( "${usbname}" ); done

for (( i=0; i<$posd; i++ )); do
    dmname=$( echo "$drives_iomedia" | grep -B 10 ${dmlist[i]} | grep -m 1 -w "IOMedia"  | cut -f1 -d "<" | sed -e s'/-o //'  | sed -e s'/Media//' | sed 's/ *$//' | tr -d "\n")
    if [[ ${#dmname} -gt 30 ]]; then dmname=$( echo "$dmname" | cut -f1-2 -d " " ); fi
        for (( n=0; n<$pusb; n++ )); do if [[ ! $( echo "$dmname" | grep -oE "${usbnames[n]}" ) = ""  ]]; then rmlist+=( ${dmlist[i]} ); fi; done
 done                            
fi

posrm=${#rmlist[@]}; if [[ $posrm = 0 ]]; then usb=0; else usb=1; fi

# подготовка данных для вычисления размеров
sizes_iomedia=$( echo "$ioreg_iomedia" |  sed -e s'/Logical Block Size =//' | sed -e s'/Physical Block Size =//' | sed -e s'/Preferred Block Size =//' | sed -e s'/EncryptionBlockSize =//')

# подготовка данных для вычисления hotplug
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
fi

STORE_HOTPLUG_STATE
}

zx=Mac-$(ioreg -rd1 -c IOPlatformExpertDevice | awk '/IOPlatformUUID/' | cut -f2 -d"=" | tr -d '" ' | cut -f2-4 -d '-' | tr -d - | rev)

efimounter=$(echo 0x7a 0x78 | xxd -r)

############################################ конец движка детекта EFI ###############################################

IF_UNLOCK_SAFE_MODE(){
if [[ "$(sysctl -n kern.safeboot)" = "1" ]]; then 
    if [[ $(kextstat -l | grep -ow com.apple.filesystems.msdosfs) = "" ]]; then 
        GET_PASSWORD
        if [[ ! "${mypassword}" = "0" ]] || [[ ! "${mypassword}" = "" ]]; then
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
        if [[ $flag = 0 ]]; then
                    if ! diskutil quiet mount readOnly /dev/${string} 2>/dev/null; then
                    sleep 1
                    diskutil quiet mount readOnly /dev/${string} 2>/dev/null; fi  
        else
                    if [[ $mypassword = "0" ]] || [[ $mypassword = "" ]]; then GET_PASSWORD; fi
                    if [[ ! $mypassword = "0" ]]; then
                            if ! echo "$mypassword" | sudo -S diskutil quiet mount readOnly /dev/${string} 2>/dev/null; then 
                                sleep 1
                                echo "$mypassword" | sudo -S diskutil quiet mount  readOnly /dev/${string} 2>/dev/null
                            fi
                    fi
        fi
}

STARTUP_FIND_LOADERS(){
if [[ $startup = 0 ]] && [[ $reloadFlag = 1 ]]; then
DBG "M: Reload detected"
GET_MOUNTEFI_STACK; reloadFlag=0
match=0; for i in ${ldlist[@]}; do if [[ ${i::8} = "OpenCore" ]]; then match=1; break; fi; done
    if [[ $match = 1 ]] && [[ ! ${#oc_list[@]} = 0 ]]; then 
#    echo "reload" > "${MEFIScA_PATH}"/serverRflag; DBG "MEFIScA Reload flag SET UP"
    DBG "M: OpenCore found in ldlist" 
    for pnum in ${!ldlist[@]}; do if [[ ${ldlist[pnum]::8} = "OpenCore" ]]; then GET_OC_VERS; loader="OpenCore"; loader+="${oc_revision}"; ldlist[pnum]="${loader}"; DBG "M: OC corection loader = $loader"; fi; done
    startup=1; sendData=1; WAITFLAG_OFF
    fi
fi

if [[ $startup = 0 ]] && [[ ! $reloadFlag = 1 ]]; then
#    echo "restart" > "${MEFIScA_PATH}"/serverRflag; DBG "MEFIScA Restart flag SET UP"
    DBG "MEFIScA Поиск загрузчиков при первом запуске"
    if [[ ! $mypassword = "0"  &&  ! $mypassword = "" ]] || [[ $flag = 0 ]]; then
        echo "$mypassword" | sudo -S printf ""
#        DBG "MEFIScA mypassword = $mypassword, flag = $flag"
        for i in ${!dlist[@]}; do 
        pnum=${nlist[i]}
            string=${dlist[$pnum]}
            old_dlist[pnum]=${dlist[pnum]}
            if [[ $(df | grep ${string}) = "" ]]; then was_mounted=0
        
                if [[ $flag = 0 ]]; then diskutil quiet mount readOnly  /dev/${string} 2>/dev/null
                elif ! sudo diskutil quiet mount readOnly  /dev/${string} 2>/dev/null; then 
                sleep 0.5
                sudo diskutil quiet mount readOnly  /dev/${string} 2>/dev/null
                fi
            else 
                was_mounted=1
            fi
                if [[ ! $(df | grep ${string}) = "" ]]; then mcheck="Yes"
            
                    FIND_LOADERS

                    if [[ ! ${loader} = "" ]]; then ldlist[pnum]="${loader}"; lddlist[pnum]=${dlist[pnum]}; fi
                    if [[ $was_mounted = 0 ]]; then if ! diskutil quiet  umount /dev/${string}; then sleep 0.5; diskutil quiet  umount force /dev/${string}; fi; fi
                fi
                old_ldlist[pnum]=${ldlist[pnum]}
                if [[ ${ldlist[pnum]::8} = "OpenCore" ]]; then old_oc_revision[pnum]=${ldlist[0]:8}; fi  
        done
    fi
    old_mounted=(${mounted_loaders_list[@]}); old_lddlist=(${lddlist[@]})
    startup=1; sendData=1; WAITFLAG_OFF
fi
}

GET_PASSWORD(){
mypassword="0"
if (security find-generic-password -a ${USER} -s ${!efimounter} -w) >/dev/null 2>&1; then mypassword=$(security find-generic-password -a ${USER} -s ${!efimounter} -w); fi
}

# Установка флага необходимости в SUDO - flag
GET_FLAG(){
macos=$(sw_vers -productVersion | tr -d .); macos=${macos:0:4}
if [[ ${#macos} = 3 ]]; then macos+="0"; fi
if [[ "$macos" = "1011" ]] || [[ "$macos" = "1012" ]]; then flag=0; else flag=1; GET_PASSWORD; fi
}

UPDATE_SCREEN(){
##################### обновление данных буфера экрана при детекте хотплага партиции ###########################
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
  fi
let "num++"
let "var0--"
done
}
################################### конец функции обновления списка подключенных  на экране ##################################

# Определение  функции построения и вывода списка разделов 
GETLIST(){
var0=$pos; num=0; ch=0; unset string
while [ $var0 != 0 ]; do 
	let "ch++"
	pnum=${nlist[num]}; string=`echo ${dlist[$pnum]}`
    mcheck=`df | grep ${string}`; if [[ ! $mcheck = "" ]]; then mcheck="Yes"; fi
    if [[ $mcheck = "Yes" ]]; then
    FIND_LOADERS 
    if [[ ! ${loader} = "" ]];then ldlist[pnum]="$loader"; lddlist[pnum]=${dlist[pnum]}; fi
    fi                
	let "num++"; let "var0--"
done
}

CLIENT_IS_ONLINE(){  DBG "MEFIScA клиент онлайн"; SAVE_LOADERS_STACK;  while CLIENT_ONLINE; do sleep 0.5; done; DBG "MEFIScA клиент сам по себе"; WAIT_CLIENT_DOWN; GET_MOUNTEFI_STACK; SERVER_READY_OFF; }
CLIENT_IS_OFFLINE(){ CHECK_HOTPLUG_DISKS; CHECK_HOTPLUG_PARTS; if HOTPLUG; then DBG "MEFIScA Hotplug detected: $hotplug $update_screen_flag"; update_screen_flag=0 ; break; fi; }

# Конец определения GETLIST ###########################################################

############################################################## INIT #####################################################

if [[ ! -d "${MEFIScA_PATH}" ]]; then mkdir -p "${MEFIScA_PATH}"; fi

nlist=(); dlist=(); mounted_loaders_list=(); ldlist=(); lddlist=(); oc_list=()
old_dlist=(); old_mounted=(); old_ldlist=(); old_lddlist=()
old_oc_revision=(); past_rmlist=(); rmlist=()
lists_updated=0; synchro=0; startup=0

IF_UNLOCK_SAFE_MODE
GET_FLAG

CLEAR_PROHIBITION_FLAGS

unset aa
################################################################ MAIN ######################################################

while true; do

        GETARR
        WAIT_SYNCHRO
        GETLIST
        
        STARTUP_FIND_LOADERS

    while true; do
        sleep 0.8; if CLIENT_ONLINE; then unset aa; CLIENT_IS_ONLINE; else sleep 0.8; if CLIENT_ONLINE; then unset aa; CLIENT_IS_ONLINE; fi; fi
        if [[ $aa = "" ]]; then DBG "MEFIScA ONLINE"; aa=0; fi; CLIENT_IS_OFFLINE
    done
done

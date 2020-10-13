#!/bin/bash

#  Created by Андрей Антипов on 14.10.2020.#  Copyright © 2020 gosvamih. All rights reserved.

########################################################################## MountEFI scan agent ###################################################################################################################
prog_vers="1.8.0"
edit_vers="058"
##################################################################################################################################################################################################################
# https://github.com/Andrej-Antipov/MountEFI/releases


CONFPATH="${HOME}/.MountEFIconf.plist"
SERVFOLD_PATH="${HOME}/Library/Application Support/MountEFI"

zx=Mac-$(ioreg -rd1 -c IOPlatformExpertDevice | awk '/IOPlatformUUID/' | cut -f2 -d"=" | tr -d '" ' | cut -f2-4 -d '-' | tr -d - | rev)

efimounter=$(echo 0x7a 0x78 | xxd -r)

ERRLOG(){
echo "$1" >> "${SERVFOLD_PATH}"/MEFIScA/error.log
}

DEBLOG(){
echo "$1" >> "${SERVFOLD_PATH}"/MEFIScA/debug.log
}


touch "${SERVFOLD_PATH}"/MEFIScA/WaitSynchro

if [[ -d "${SERVFOLD_PATH}"/MEFIScA ]]; then rm -Rf "${SERVFOLD_PATH}"/MEFIScA/MEFIscanAgentStack; fi

#############################################################################################
SAVE_LOADERS_STACK(){

if [[ -d "${SERVFOLD_PATH}"/MEFIScA/MEFIscanAgentStack ]]; then rm -Rf "${SERVFOLD_PATH}"/MEFIScA/MEFIscanAgentStack; fi
mkdir -p "${SERVFOLD_PATH}"/MEFIScA/MEFIscanAgentStack

if [[ ! ${#dlist[@]} = 0 ]]; then 
            #touch "${SERVFOLD_PATH}"/MEFIScA/MEFIscanAgentStack/AllDiskNameList
            max=0; for y in ${!dlist[@]}; do if [[ ${max} -lt ${y} ]]; then max=${y}; fi; done
            for ((h=0;h<=max;h++)); do echo "${dlist[h]}" >> "${SERVFOLD_PATH}"/MEFIScA/MEFIscanAgentStack/dlist; done
fi

if [[ ! ${#mounted_loaders_list[@]} = 0 ]]; then 
            #touch "${SERVFOLD_PATH}"/MEFIScA/MEFIscanAgentStack/MountedLoadersList
            max=0; for y in ${!mounted_loaders_list[@]}; do if [[ ${max} -lt ${y} ]]; then max=${y}; fi; done
            for ((h=0;h<=max;h++)); do echo ${mounted_loaders_list[h]} >> "${SERVFOLD_PATH}"/MEFIScA/MEFIscanAgentStack/mounted_loaders_list; done
fi

if [[ ! ${#ldlist[@]} = 0 ]]; then 
            #touch "${SERVFOLD_PATH}"/MEFIScA/MEFIscanAgentStack/LoaderNameList
            max=0; for y in ${!ldlist[@]}; do if [[ ${max} -lt ${y} ]]; then max=${y}; fi; done
            for ((h=0;h<=max;h++)); do echo "${ldlist[h]}" >> "${SERVFOLD_PATH}"/MEFIScA/MEFIscanAgentStack/ldlist; done
fi

if [[ ! ${#lddlist[@]} = 0 ]]; then 
            #touch "${SERVFOLD_PATH}"/MEFIScA/MEFIscanAgentStack/DiskNameList
            max=0; for y in ${!lddlist[@]}; do if [[ ${max} -lt ${y} ]]; then max=${y}; fi; done
            for ((h=0;h<=max;h++)); do echo ${lddlist[h]} >> "${SERVFOLD_PATH}"/MEFIScA/MEFIscanAgentStack/lddlist; done
fi
}

GET_MOUNTEFI_STACK(){
IFS=';'; mounted_loaders_list=( $(cat "${SERVFOLD_PATH}"/MEFIScA/MEFIscanAgentStack/mounted_loaders_list | tr '\n' ';' ) )
ldlist=( $(cat "${SERVFOLD_PATH}"/MEFIScA/MEFIscanAgentStack/ldlist | tr '\n' ';' ) )
lddlist=( $(cat "${SERVFOLD_PATH}"/MEFIScA/MEFIscanAgentStack/lddlist | tr '\n' ';' ) )
if [[ -f "${SERVFOLD_PATH}"/MEFIScA/MEFIscanAgentStack/dlist ]]; then dlist=( $(cat "${SERVFOLD_PATH}"/MEFIScA/MEFIscanAgentStack/dlist | tr '\n' ';' ) ); fi;  unset IFS
}


##################### получение имени и версии загрузчика ######################################################################################

GET_LOADER_STRING(){                              
               if [[ ! "${loader:0:5}" = "Other" ]]; then                
                    check_loader=$( xxd "$vname"/EFI/BOOT/BOOTX64.EFI | egrep -om1  "Clover|OpenCore|GNU/Linux|Microsoft C|Refind" )
                    case "${check_loader}" in
                    "Clover"    ) loader="Clover"
                                revision=$( xxd "$vname"/EFI/BOOT/BOOTX64.efi | grep -a1 "Clover" | cut -c 50-68 | tr -d ' \n' | egrep -o  'revision:[0-9]{4}' | cut -f2 -d: )
                                if [[ ${revision} = "" ]]; then revision=$( xxd  "$vname"/EFI/BOOT/BOOTX64.efi | grep -a1 'revision:' | cut -c 50-68 | tr -d ' \n' | egrep -o  'revision:[0-9]{4}' | cut -f2 -d: ); fi
                                loader+="${revision:0:4}"
                                ;;
  
                    "OpenCore"  )  loader="OpenCore"
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

##################################################################################################################################################

GET_OC_VERS(){

oc_revision=""

######  уточняем версию через хэши BOOTx64.efi + OpenCore.efi ######
if [[ ${oc_revision} = "" ]]; then
    md5_full="${md5_loader}$( md5 -qq "$vname"/EFI/OC/OpenCore.efi 2>/dev/null )"
############################### уточняем версияю Open Core по OpenCore.efi ###################
############################### CORRECT_OC_VERS ##############################################
case "${md5_full}" in
58c4b4a88f8c41f84683bdf4afa3e77cf6bcc6d06d95a1e657e61a15666cde9f ) oc_revision=.62r;;
5ef1fc5a81e8e4e6aeb504c91d4a1d7786652faf1a336a446b187ae283d2cc9a ) oc_revision=.62d;;
75624767ed4f08a1ebc9f655711ba95d8ef8d1803e91c6718dfee59408b6a468 ) oc_revision=.61d;;
58c4b4a88f8c41f84683bdf4afa3e77c3255c15833abcb05789af00c0e50bf82 ) oc_revision=.61r;;
58c4b4a88f8c41f84683bdf4afa3e77c5010a4db83dacbcc14b090e00472c661 ) oc_revision=.60r;;
bb901639773a1c319a3ff804128bdfb4f663a56f66b9d95fd053a46b0829fa5c ) oc_revision=.60d;;
01dfbdd3175793d729999c52882dd3b6da4a5e54641317b2aa7715f8b4273791 ) oc_revision=.59r;;
efbad161ffbf7a17374d08ec924651fef46456574b8b67f603de74c201b4e130 ) oc_revision=.59d;;
10610877a9cc0ed958ff74ed7a192474dd2bb459dfbb1fe04ca0cb61bb8f9581 ) oc_revision=.58r;;
d90190bfea64112ed83621079371277ab85c28aa004291a96bf74d95eea3364a ) oc_revision=.58d;;
10610877a9cc0ed958ff74ed7a1924743e99e56bc16ed23129b3659a3d536ae9 ) oc_revision=.57r;;
9ff8a0c61dc1332dd58ecc311e0938b088e8aec480eb24e757241580731d2023 ) oc_revision=.57d;;
12e5d34064fed06441b86b21f3fa3b7d947f8ccfec961d02f54d1a2f5c808504 ) oc_revision=.56r;;
9004a000df355d09a79ba510c055a5f0db78c5fef3550213e947b8d6fa5338e4 ) oc_revision=.56d;;
f3b1534643d3eb11fc18ac5a56528d794bdb27730c0c06275e2fc389348d46d0 ) oc_revision=.55r;;
07b64c16f48d61e5e9f2364467250912217a07b161306324d147681914a319c3 ) oc_revision=.55d;;
91e8abcf647af737d4a22fe3f98d00c021aa72da926ec362ab58626b60c36ac8 ) oc_revision=.54r;;
5758e9b672486b863b18f6e5ff001b27d36cb1eafafcd9b94d3526aece5bc8b4 ) oc_revision=.54d;;
97f744526c733aa2e6505f01f37de6d78cc62a1017afa01c2c75ad4b6fca8df2 ) oc_revision=.53r;;
b09cd76fadd2f7a14e76003b2ff4016f1d821f7a51eab7c39999328438770fa7 ) oc_revision=.53d;;
1ca142bf009ed537d84c980196c36d72ba2a5846697e7895753e7b05989738e5 ) oc_revision=.52r;;
eaba9d5b467da41f5a872630d4ad7ff552f819181055f501b6882c2a73268dbc ) oc_revision=.52d;;
eb66a8a986762b9cadecb6408ecb1ec7ff42893722bc0a3278c7d8029b797342 ) oc_revision=.51r;;
c31035549f86156ff5e79b9d87240ec54be8a2620c923129b3bac0b2d1b8fd6b ) oc_revision=.51d;;
7844acab1d74aeccc5d2696627c1ed3d081f9922be27b2d1e82fc8dbd3426498 ) oc_revision=.50r;;
c221f59769bd185857b2c30858fe3aa2ec0e6c7dfa2ab84eaad52f167e85466f ) oc_revision=.50d;;
                                                                *)     oc_revision=""
esac 
######################################################################################
fi

if [[ ${oc_revision} = "" ]]; then

case "${md5_loader}" in
############## oc_hashes_strings 29 #################
5ef1fc5a81e8e4e6aeb504c91d4a1d77 ) oc_revision=.62x;;
75624767ed4f08a1ebc9f655711ba95d ) oc_revision=.61x;;
58c4b4a88f8c41f84683bdf4afa3e77c ) oc_revision=.6xr;;
bb901639773a1c319a3ff804128bdfb4 ) oc_revision=.60x;;
01dfbdd3175793d729999c52882dd3b6 ) oc_revision=.59x;;
efbad161ffbf7a17374d08ec924651fe ) oc_revision=.59x;;
d90190bfea64112ed83621079371277a ) oc_revision=.58x;;
9ff8a0c61dc1332dd58ecc311e0938b0 ) oc_revision=.57x;;
10610877a9cc0ed958ff74ed7a192474 ) oc_revision=.5xr;;
12e5d34064fed06441b86b21f3fa3b7d ) oc_revision=.56x;;
9004a000df355d09a79ba510c055a5f0 ) oc_revision=.56x;;
f3b1534643d3eb11fc18ac5a56528d79 ) oc_revision=.55x;;
07b64c16f48d61e5e9f2364467250912 ) oc_revision=.55x;;
91e8abcf647af737d4a22fe3f98d00c0 ) oc_revision=.54x;;
5758e9b672486b863b18f6e5ff001b27 ) oc_revision=.54x;;
97f744526c733aa2e6505f01f37de6d7 ) oc_revision=.53x;;
b09cd76fadd2f7a14e76003b2ff4016f ) oc_revision=.53x;;
1ca142bf009ed537d84c980196c36d72 ) oc_revision=.52x;;
eaba9d5b467da41f5a872630d4ad7ff5 ) oc_revision=.52x;;
eb66a8a986762b9cadecb6408ecb1ec7 ) oc_revision=.51x;;
c31035549f86156ff5e79b9d87240ec5 ) oc_revision=.51x;;
7844acab1d74aeccc5d2696627c1ed3d ) oc_revision=.50x;;
c221f59769bd185857b2c30858fe3aa2 ) oc_revision=.50x;;
91ea6c185c31a25c791da956c79808f9 ) oc_revision=.04r;;
5bb02432d1d1272fdcdff91fcf33d75b ) oc_revision=.04d;;
303a7f1391743e6bc52a38d614b5dd93 ) oc_revision=.03r;;
52195547d645623036effeadd31e21a9 ) oc_revision=.03d;;
7805dc51bd280055d85775c512a832b0 ) oc_revision=.02r;;
bb222980e4823798202b3a9cff63b604 ) oc_revision=.02d;;
297e30883f3db26a30e48f6b757fd968 ) oc_revision=.01r;;
e2c2dd105dc03dc16a69fd10ff2d0eac ) oc_revision=.01d;;
                                *)     oc_revision=""
                    esac
fi

}

##################### проверка на загрузчик после монтирования ##################################################################################
GET_LOADER_STRING(){                              
               if [[ ! "${loader:0:5}" = "Other" ]]; then                
                    check_loader=$( xxd "$vname"/EFI/BOOT/BOOTX64.EFI | egrep -om1  "Clover|OpenCore|GNU/Linux|Microsoft C|Refind" )
                    case "${check_loader}" in
                    "Clover"    ) loader="Clover"
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

                    if [[ ! ${loader_sum} = 0 ]] && [[ $( xxd "$vname"/EFI/BOOT/BOOTX64.EFI | egrep -om1 "OpenCore" ) = "OpenCore" ]]; then md5_loader=${loader_sum}; GET_OC_VERS
                       if [[ ! "${old_oc_revision[pnum]}" = "${oc_revision}" ]]; then old_oc_revision[pnum]="${oc_revision}"; update_screen_flag=1; else update_screen_flag=0; fi
                    fi

                    if [[ ! ${mounted_loaders_list[$pnum]} = ${loader_sum} ]] || [[ ${update_screen_flag} = 1 ]]; then 
                    touch "${SERVFOLD_PATH}"/MEFIScA/WaitSynchro
                    mounted_loaders_list[$pnum]=${loader_sum}
                    if [[ ${loader_sum} = 0 ]]; then loader="empty"; else md5_loader=${loader_sum}; loader=""; oc_revision=""; revision="";  GET_LOADER_STRING; fi
                    ldlist[pnum]="$loader"; lddlist[pnum]=${dlist[$pnum]}
                    let "chs=pnum+1"; if [[ "${recheckLDs}" = "1" ]]; then recheckLDs=2; fi; UPDATE_SCREEN; break; fi
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

			if  [[ -f "$vname"/EFI/BOOT/BOOTX64.efi ]] && [[ -f "$vname"/EFI/BOOT/bootx64.efi ]] && [[ -f "$vname"/EFI/BOOT/BOOTx64.efi ]]; then 
                md5_loader=$( md5 -qq "$vname"/EFI/BOOT/BOOTx64.efi )               
                if [[ ${md5_loader} = "" ]]; then loader=""; else
                   if [[ ${mounted_loaders_list[$pnum]} = ${md5_loader} ]]; then loader=""; else
                    mounted_loaders_list[$pnum]="${md5_loader}"; lflag=1
                    GET_LOADER_STRING
                  fi
                fi
            else
                   if [[ ${mounted_loaders_list[pnum]} = "" ]] || [[ ! ${mounted_loaders_list[pnum]} = 0 ]]; then loader="empty"; mounted_loaders_list[pnum]=0; fi
            fi
    fi
}
#######################################################################################################################################################

################################## функция автодетекта подключения ##############################################################################################
CHECK_HOTPLUG_PARTS(){
#echo "old_puid_count = $old_puid_count" >> ~/Desktop/test.txt
pstring=`df | cut -f1 -d " " | grep "/dev" | cut -f3 -d "/"` ; puid_list=($pstring);  puid_count=${#puid_list[@]}
#echo "puid_count = $puid_count" >> ~/Desktop/test.txt
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

#echo "old_uuid_count = $old_uuid_count" >> ~/Desktop/test.txt
 
                       RECHECK_LOADERS

hotplug=0
ustring=`ioreg -c IOMedia -r  | tr -d '"|+{}\t'  | grep -A 10 -B 5  "Whole = Yes" | grep "BSD Name" | grep -oE '[^ ]+$' | xargs | tr ' ' ';'` ; IFS=";"; uuid_list=($ustring); unset IFS; uuid_count=${#uuid_list[@]}
#echo "uuid_count = $uuid_count" >> ~/Desktop/test.txt
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
######################################################################################################################################################

############################# корректировка списка разделов с загрузчиками ######################################### 
CORRECT_LOADERS_LIST(){

           temp_lddlist=(); temp_ldlist=(); temp_mllist=()

    for k in ${!dlist[@]}; do
        for y in ${!lddlist[@]}; do
        if [[ ${dlist[k]} = ${lddlist[y]} ]]; then
                temp_ldlist[k]=${ldlist[y]}
                temp_lddlist[k]=${lddlist[y]}
                temp_mllist[k]=${mounted_loaders_list[y]}
                break
        fi
        done
    done
    
    ldlist=(); lddlist=(); mounted_loaders_list=()
    for k in ${!temp_lddlist[@]}; do lddlist[k]=${temp_lddlist[k]}; done
    for k in ${!temp_ldlist[@]}; do ldlist[k]=${temp_ldlist[k]}; done
    for k in ${!temp_mllist[@]}; do mounted_loaders_list[k]=${temp_mllist[k]}; done

synchro=0

}

GET_LOADERS_FROM_NEW_PARTS(){
if [[ ! ${#new_remlist[@]} = 0 ]]; then
    for i in ${!dlist[@]}; do pnum=${nlist[i]}; string=${dlist[$pnum]}
        for z in ${new_remlist[@]}; do 
        if [[ $string = $z ]]; then
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

WAIT_SYNCHRO(){
if [[ ${synchro} = 1 ]] || [[ ${synchro} = 3 ]]; then
if [[ ${synchro} = 3 ]]; then new_rmlist=( ${rmlist[@]} ); sleep 0.25; else
new_rmlist=( $( echo ${rmlist[@]} ${past_rmlist[@]} | tr ' ' '\n' | sort | uniq -u | tr '\n' ' ' ) )
if [[ ! ${#new_rmlist[@]} = 0 ]]; then
    init_time="$(date +%s)"; usblist=()
    for z in ${dlist[@]}; do for y in ${new_rmlist[@]}; do if [[ "$y" = "$( echo $z | rev | cut -f2-3 -d"s" | rev )" ]]; then usblist+=( $z ); break; fi; done; done
    new_remlist=(${usblist[@]})
    if [[ ! ${#usblist[@]} = 0 ]]; then
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
            if [[ ${exec_time} -ge 30 ]]; then break; fi
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
past_rmlist=( ${rmlist[@]} ); rmlist=(); posrm=0
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
ustring=$( ioreg -c IOMedia -r  | tr -d '"|+{}\t'  | grep -A 10 -B 5  "Whole = Yes" | grep "BSD Name" | grep -oE '[^ ]+$' | xargs | tr ' ' ';') ; IFS=";"; uuid_list=($ustring); unset IFS; uuid_count=${#uuid_list[@]}
        if [[ ! $old_uuid_count = $uuid_count ]]; then old_uuid_count=$uuid_count; fi

pstring=$( df | cut -f1 -d " " | grep "/dev" | cut -f3 -d "/") ; puid_list=($pstring);  puid_count=${#puid_list[@]}
        if [[ ! $old_puid_count = $puid_count ]]; then  old_puid_count=$puid_count; old_puid_list=($pstring); old_uuid_list=($ustring); fi

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
}

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
                    if ! diskutil quiet mount  /dev/${string} 2>/dev/null; then
                    sleep 1
                    diskutil quiet mount  /dev/${string} 2>/dev/null; fi  
        else
                    if [[ $mypassword = "0" ]] || [[ $mypassword = "" ]]; then GET_PASSWORD; fi
                    if [[ ! $mypassword = "0" ]]; then
                            if ! echo "$mypassword" | sudo -S diskutil quiet mount  /dev/${string} 2>/dev/null; then 
                                sleep 1
                                echo "$mypassword" | sudo -S diskutil quiet mount  /dev/${string} 2>/dev/null
                            fi
                    fi
        fi
}

STARTUP_FIND_LOADERS(){
if [[ ! $mypassword = "0"  &&  ! $mypassword = "" ]] || [[ $flag = 0 ]]; then
    echo "$mypassword" | sudo -S printf ""
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
            diskutil quiet  umount force /dev/${string}
            fi
        fi   
    done
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

SHOW_DATA(){
if [[ ${old_dlist[@]} = ${dlist[@]} ]] && [[ ${old_mounted[@]} = ${mounted_loaders_list[@]} ]] && [[ ${old_ldlist[@]} = ${ldlist[@]} ]] && [[ ${old_lddlist[@]} = ${lddlist[@]} ]]; then
    true
else
        #rm -f "${SERVFOLD_PATH}"/MEFIScA/StackUptoDate;
        echo ${dlist[@]}
        echo ${mounted_loaders_list[@]}
        echo ${ldlist[@]}
        echo ${lddlist[@]}  
        old_dlist=(${dlist[@]}); old_mounted=(${mounted_loaders_list[@]}); old_ldlist=(${ldlist[@]}); old_lddlist=(${lddlist[@]})
        #SAVE_LOADERS_STACK
        #touch "${SERVFOLD_PATH}"/MEFIScA/StackUptoDate
fi
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

# Конец определения GETLIST ###########################################################

############################################################## INIT #####################################################

if [[ ! -d "${SERVFOLD_PATH}"/MEFIScA ]]; then mkdir -p "${SERVFOLD_PATH}"/MEFIScA; fi

nlist=(); dlist=(); mounted_loaders_list=(); ldlist=(); lddlist=()
ld_dlist=(); old_mounted=(); old_ldlist=(); old_lddlist=()
old_oc_revision=()

lists_updated=0; synchro=0; recheckLDs=0; startup=0

IF_UNLOCK_SAFE_MODE

GET_FLAG

################################################################ MAIN ######################################################

while true; do

        nlist=(); rmlist=(); posrm=0
        GETARR

        WAIT_SYNCHRO
        GETLIST
        if [[ $startup = 0 ]]; then STARTUP_FIND_LOADERS; startup=1; fi

    while true; do
        sleep 0.9
        if [[ ! $(ps xao tty,command | grep -v grep | egrep -o "MountEFI$" | wc -l | bc) = 0 ]]; then 
            rm -f "${SERVFOLD_PATH}"/MEFIScA/StackUptoDate
            SAVE_LOADERS_STACK
            touch "${SERVFOLD_PATH}"/MEFIScA/StackUptoDate
            rm -f "${SERVFOLD_PATH}"/MEFIScA/WaitSynchro
            while [[ ! $(ps xao tty,command | grep -v grep | egrep -o "MountEFI$" | wc -l | bc) = 0 ]]; do sleep 1.5; done
            GET_MOUNTEFI_STACK
        else
            if [[ -f "${SERVFOLD_PATH}"/MEFIScA/WaitSynchro ]]; then rm -f "${SERVFOLD_PATH}"/MEFIScA/WaitSynchro; fi
            CHECK_HOTPLUG_DISKS
            CHECK_HOTPLUG_PARTS
            if [[ $hotplug = 1 ]] || [[ $update_screen_flag = 1 ]]; then  touch "${SERVFOLD_PATH}"/MEFIScA/WaitSynchro; break; fi
        #SHOW_DATA
        fi
    done
done
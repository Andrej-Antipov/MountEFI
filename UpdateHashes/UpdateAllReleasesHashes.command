#!/bin/bash

clear


UPDATE_OC_HASHES_LIST(){
if [[ ! ${dbg_hash} = 0 ]] && [[ ! ${rls_hash} = 0 ]] && [[ ! ${oc_vrs} = 0 ]]; then 
    if [[ "${oc_vrs:0:1}" = 0 ]]; then fsg="."; else fsg="${oc_vrs:0:1}"; fi
    rel_string="${rls_hash}${rls_hash2}"" ) oc_revision=""${fsg}""${oc_vrs:1:1}""${oc_vrs:2:1}""r;;"
    dbg_string="${dbg_hash}${dbg_hash2}"" ) oc_revision=""${fsg}""${oc_vrs:1:1}""${oc_vrs:2:1}""d;;"
    hsh_string=$( cat OC_hashes.txt | grep oc_hashes_strings )
    hsh_count=$( echo $hsh_string | cut -f3 -d' ' )
    let "new_count=hsh_count+2"
    new_string=$( echo $hsh_string | sed s'/'$hsh_count'/'$new_count'/' )
    echo "${rel_string}" >> OC_hashes.txt
    echo "${dbg_string}" >> OC_hashes.txt
    cat OC_hashes.txt | sed s'/'"$hsh_string"'/'"$new_string"'/' | tr -s '\n' >> OC_hashes2.txt
    mv -f OC_hashes2.txt OC_hashes.txt
    echo "list of OpenCore hashes updated"
else
    echo "no data to update list of OpenCore hashes"
fi

}

cd "$(dirname "$0")"

rm -f OC_hashes.txt
echo "############## oc_hashes_strings 00 #################" >> OC_hashes.txt

oc_versions=( 0.8.6 0.8.7 0.8.8 0.8.9 0.9.0 0.9.1 0.9.2 0.9.3 0.9.4 0.9.5 0.9.6 0.9.7)

    echo "list of hashes needs to update. downloading OC releases... "
if ping -c 1 google.com >> /dev/null 2>&1; then

 for i in ${!oc_versions[@]}; do

            case ${oc_versions[i]} in

        0.0.1 )     v1=""   ;   v2="v"   ;;
        0.0.2 )     v1=""   ;   v2="v"   ;;
        0.0.3 )     v1="v"  ;   v2="v"   ;;
            * )     v1=""   ;   v2=""    ;;

            esac
                
    latest_RELEASE="https://github.com/acidanthera/OpenCorePkg/releases/download/$v1${oc_versions[i]}/OpenCore-$v2${oc_versions[i]}-RELEASE.zip"
    latest_DEBUG="https://github.com/acidanthera/OpenCorePkg/releases/download/$v1${oc_versions[i]}/OpenCore-$v2${oc_versions[i]}-DEBUG.zip"

    echo $latest_RELEASE
    echo $latest_DEBUG

    dbg_hash=0
    rls_hash=0
    oc_vrs=$( echo ${oc_versions[i]} | sed 's/[^0-9]//g' )

    while :;do printf '.' ;sleep 0.4;done &
    trap "kill $!" EXIT 
    if [[ ! -d OC/$oc_vrs/DEBUG ]]; then
    mkdir -p OC/$oc_vrs/DEBUG
    curl -L -s -o OC/$oc_vrs/DEBUG/DEBUG.zip $latest_DEBUG 2>/dev/null
    fi
    if [[ ! -d OC/$oc_vrs/RELEASE ]]; then
    mkdir -p OC/$oc_vrs/RELEASE
    curl -L -s -o OC/$oc_vrs/RELEASE/RELEASE.zip $latest_RELEASE 2>/dev/null
    fi
    #cp OC/$oc_vrs/RELEASE/RELEASE.zip ~/Desktop
    cd OC/$oc_vrs/DEBUG
    unzip  -o -qq DEBUG.zip 2>/dev/null
    if [[ -f EFI/BOOT/BOOTx64.efi ]]; then dbg_hash=$( md5 -qq EFI/BOOT/BOOTx64.efi ); dbg_hash2=$( md5 -qq EFI/OC/OpenCore.efi )
                    elif [[ -f X64/EFI/BOOT/BOOTx64.efi ]]; then dbg_hash=$( md5 -qq X64/EFI/BOOT/BOOTx64.efi ); dbg_hash2=$( md5 -qq X64/EFI/OC/OpenCore.efi )
						else
							dbg_hash=$( md5 -qq BOOT/BOOTx64.efi ); dbg_hash2=$( md5 -qq OC/OpenCore.efi )
    fi
    cd ../RELEASE
    unzip  -o -qq RELEASE.zip 2>/dev/null
    if [[ -f EFI/BOOT/BOOTx64.efi ]]; then rls_hash=$( md5 -qq EFI/BOOT/BOOTx64.efi ); rls_hash2=$( md5 -qq EFI/OC/OpenCore.efi )
		elif [[ -f X64/EFI/BOOT/BOOTx64.efi ]]; then rls_hash=$( md5 -qq X64/EFI/BOOT/BOOTx64.efi ); rls_hash2=$( md5 -qq X64/EFI/OC/OpenCore.efi )
                        else rls_hash=$( md5 -qq BOOT/BOOTx64.efi ); rls_hash2=$( md5 -qq OC/OpenCore.efi )
    fi
    cd "$(dirname "$0")"
    kill $!
    wait $! 2>/dev/null
    trap " " EXIT

    UPDATE_OC_HASHES_LIST

  done

else
    echo "NO INTERNET CONNECTION"
fi
   

printf '\n\n\n'

exit

#!/bin/bash

clear

GET_LIST_LATEST_VERSION(){
num_str=$( cat OC_hashes.txt | cut -f2 -d')' | cut -f2 -d= | tr -d '.;' | sed 's/[^0-9]//g' | tr '\n' ';' )
IFS=';'; llver=($num_str); unset IFS; pllver=${#llver[@]}; latest=0
for ((i=0;i<$pllver;i++)); do
    if [[ ${latest} -lt ${llver[i]} ]]; then latest=${llver[i]}; fi
done
if [[ ${#latest} = 2 ]]; then latest="0""${latest}"; fi
}

GET_SCRIPT_LATEST_VERSION(){
cat ../MountEFI.sh | grep "$pattern"  -A"${count_str}" >> OC_hashes_scrpt.txt
num_str=$( cat OC_hashes_scrpt.txt | cut -f2 -d')' | cut -f2 -d= | tr -d '.;' | sed 's/[^0-9]//g' | tr '\n' ';' )
rm -f OC_hashes_scrpt.txt
IFS=';'; llver=($num_str); unset IFS; pllver=${#llver[@]}; latest_script=0
for ((i=0;i<$pllver;i++)); do
    if [[ ${latest_script} -lt ${llver[i]} ]]; then latest_script=${llver[i]}; fi
done
if [[ ${#latest_script} = 2 ]]; then latest_script="0""${latest_script}"; fi
}

GET_SERVER_LATEST_VERTION(){
oc_vrs=0
if ping -c 1 google.com >> /dev/null 2>&1; then
latest_OC=$( curl -s https://api.github.com/repos/acidanthera/OpenCorePkg/releases/latest | grep browser_download_url | cut -d '"' -f 4 )
oc_vrs=$( echo $latest_OC |  rev | cut -d '/' -f1  | rev | sed 's/[^0-9]//g' | grep -m1 '[0-9]*' )
fi
}

UPDATE_OC_HASHES_LIST(){
if [[ ! ${dbg_hash} = 0 ]] && [[ ! ${rls_hash} = 0 ]] && [[ ! ${oc_vrs} = 0 ]]; then 
    if [[ "${oc_vrs:0:1}" = 0 ]]; then fsg="."; else fsg="${oc_vrs:0:1}"; fi
    rel_string="${rls_hash}"" ) oc_revision=""${fsg}""${oc_vrs:1:1}""${oc_vrs:2:1}""r;;"
    dbg_string="${dbg_hash}"" ) oc_revision=""${fsg}""${oc_vrs:1:1}""${oc_vrs:2:1}""d;;"
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

GET_LIST_LATEST_VERSION
echo "list latest vertion is "${latest}
GET_SERVER_LATEST_VERTION
if [[ ! ${oc_vrs} = 0 ]]; then
echo "server latest vertion is "${oc_vrs}
else
echo "server latest vertion didn't get"
fi

if [[ "${oc_vrs}" -eq "${latest}" ]]; then echo "no need to download new one"
    else

  if [[ "${oc_vrs}" -gt "${latest}" ]]; then 
    echo "list of hashes needs to update. downloading OC release... "
    if ping -c 1 google.com >> /dev/null 2>&1; then
    latest_RELEASE=$( echo "$latest_OC" | grep RELEASE )
    latest_DEBUG=$( echo "$latest_OC" | grep DEBUG )
    dbg_hash=0
    rls_hash=0

    if [[ ! -d OC_latest/OC_latest/$oc_vrs/DEBUG ]]; then mkdir -p OC_latest/$oc_vrs/DEBUG; fi
    if [[ ! -d OC_latest/$oc_vrs/RELEASE ]]; then mkdir -p OC_latest/$oc_vrs/RELEASE; fi
    while :;do printf '.' ;sleep 0.4;done &
    trap "kill $!" EXIT 
    if [[ ! -f OC_latest/$oc_vrs/DEBUG/EFI/BOOT/BOOTx64.efi ]]; then
    curl -L -s -o OC_latest/$oc_vrs/DEBUG/DEBUG.zip $latest_DEBUG 2>/dev/null
    fi
    if [[ ! -f OC_latest/$oc_vrs/RELEASE/EFI/BOOT/BOOTx64.efi ]]; then
    curl -L -s -o OC_latest/$oc_vrs/RELEASE/RELEASE.zip $latest_RELEASE 2>/dev/null
    fi
    cp OC_latest/$oc_vrs/RELEASE/RELEASE.zip ~/Desktop
    cd OC_latest/$oc_vrs/DEBUG
    unzip  -o -qq DEBUG.zip 2>/dev/null
    dbg_hash=$( md5 -qq EFI/BOOT/BOOTx64.efi )
    cd ../RELEASE
    unzip  -o -qq RELEASE.zip 2>/dev/null
    rls_hash=$( md5 -qq EFI/BOOT/BOOTx64.efi )
    cd ../../..
    kill $!
    wait $! 2>/dev/null
    trap " " EXIT

    UPDATE_OC_HASHES_LIST

    else
        echo "NO INTERNET CONNECTION"
    fi
  fi    
fi

if [[ -f ../MountEFI.sh ]]; then 

    hashes_str=$( cat ../MountEFI.sh  | grep -n oc_hashes_strings )
    pattern=$( echo $hashes_str | cut -f2 -d: )
    first_str=$( echo $hashes_str | cut -f1 -d: )
    count_str=$( echo $hashes_str | cut -f3 -d' ' )
    count_str2=$( cat OC_hashes.txt | grep -n oc_hashes_strings | cut -f3 -d' ' )

    GET_LIST_LATEST_VERSION

    echo "check list latest vertion again and it is "${latest}

    GET_SCRIPT_LATEST_VERSION
    echo "script latest vertion is = "${latest_script}

    if [[ ${latest_script} -lt ${latest} ]]; then

     cp ../MountEFI.sh MountEFI.sh.back
     cat ../MountEFI.sh | sed -e ''$((first_str+1))','$((first_str+count_str))'D'  >> MountEFI.sh
     cat MountEFI.sh | sed -E '/'"$pattern"'/r OC_hashes.txt' | grep -v "$pattern"  >> MountEFI2.sh
     rm -f MountEFI.sh
     echo "updating MountEFI edit version"
     edit_vers=$(cat MountEFI2.sh | grep -m1 "edit_vers=" | sed s'/edit_vers=//' | tr -d '" \n')
     edit_vers=$(echo $edit_vers | bc)
     if [[ $edit_vers -lt 100 ]]; then 
            a=$( echo "0"$((edit_vers+1))); 
            if [[ ${#a} = 4 ]]; then a=$( echo $a | bc ); fi
            cat MountEFI2.sh | sed s'/edit_vers="0'$edit_vers'"/edit_vers="'$a'"/' >> MountEFI.sh
            else 
            a=$( echo $((edit_vers+1)))
            cat MountEFI2.sh | sed s'/edit_vers="'$edit_vers'"/edit_vers="'$a'"/' >> MountEFI.sh
     fi

     rm -f MountEFI2.sh
     mv -f MountEFI.sh ../MountEFI.sh;
        echo "hashes in file MountEFI.sh just UPDATED"
        echo "need to update kext ...."
    else
        echo "file MountEFI.sh no need to change"
    fi

else
    echo "file MountEFI.sh not found"
fi

printf '\n\n\n'

exit
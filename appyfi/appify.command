#!/bin/sh

cd "$(dirname "$0")"

clear

rm -f MountEFI; rm -f setup

if [[ -f ../MountEFI.sh ]]; then 
            edit_vers=$(cat ../MountEFI.sh | grep "edit_vers=" | sed s'/edit_vers=//' | tr -d '" \n')
            prog_vers=$(cat ../MountEFI.sh | grep "prog_vers=" | sed s'/prog_vers=//' | tr -d '" \n')
            vers="$prog_vers"".""$edit_vers"
            
            ./appify ../MountEFI.sh >>/dev/null
            cp MountEFI.app/Contents/MacOS/MountEFI .
            rm -R MountEFI.app
fi

if [[ -f ../setup.sh ]]; then 
            ./appify ../setup.sh >>/dev/null
            cp setup.app/Contents/MacOS/setup .
            rm -R setup.app
fi
            if [[ ../Extra ]]; then rm -R -f ../Extra; fi
            mkdir ../Extra
            if [[ -f MountEFI ]]; then cp MountEFI ../Extra; fi
            if [[ -f setup ]]; then cp setup ../Extra; fi

if [[ ! -d ../MountEFI.app ]] && [[ -f ../MountEFI.zip ]]; then unzip  -o -qq ../MountEFI.zip -d ../. ; rm -R -f ../*MACOSX ; fi

if [[ -d ../MountEFI.app ]]; then 
            if [[ -f MountEFI ]]; then 
                mv -f MountEFI ../MountEFI.app/Contents/Resources/MountEFI 
                plutil -replace CFBundleShortVersionString -string "$vers" ../MountEFI.app/Contents/Info.plist
            fi
            if [[ -f setup ]]; then
                
                mv -f setup ../MountEFI.app/Contents/Resources/setup
            fi
fi

cd ..
if [[ -f DefaultConf.plist ]]; then 
        if [[ -f MountEFI.app/Contents/Resources/DefaultConf.plist ]]; then rm MountEFI.app/Contents/Resources/DefaultConf.plist; fi
        cp DefaultConf.plist MountEFI.app/Contents/Resources/
fi

if [[ -f colors.csv ]]; then 
        if [[ ! -f MountEFI.app/Contents/Resources/colors.csv ]]; then cp colors.csv MountEFI.app/Contents/Resources ; fi
fi

if [[ -f xkbswitch ]]; then 
        if [[ ! -f MountEFI.app/Contents/Resources/xkbswitch ]]; then cp xkbswitch MountEFI.app/Contents/Resources ; fi
        
fi


if [[ -d MountEFI.app ]]; then
ditto -c -k --sequesterRsrc --keepParent MountEFI.app  newMountEFI.zip
mv -f newMountEFI.zip MountEFI.zip
fi
 
cat  ~/.bash_history | sed -n '/appify/!p' >> ~/new_hist.txt; rm ~/.bash_history; mv ~/new_hist.txt ~/.bash_history
#osascript -e 'quit app "terminal.app"' & exit

exit

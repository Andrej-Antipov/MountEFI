#!/bin/sh

cd $(dirname $0)

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

if [[ -d ../MountEFI.app ]]; then
            if [[ -f MountEFI ]]; then 
                rm -f ../MountEFI.app/Contents/Resources/MountEFI
                mv MountEFI ../MountEFI.app/Contents/Resources/MountEFI 
                plutil -replace CFBundleShortVersionString -string "$vers" ../MountEFI.app/Contents/Info.plist
            fi
            if [[ -f setup ]]; then
                rm -f ../MountEFI.app/Contents/Resources/setup
                mv setup ../MountEFI.app/Contents/Resources/setup
            fi
fi

 
cat  ~/.bash_history | sed -n '/appify/!p' >> ~/new_hist.txt; rm ~/.bash_history; mv ~/new_hist.txt ~/.bash_history
osascript -e 'quit app "terminal.app"' & exit

exit

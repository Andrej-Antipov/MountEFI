#!/bin/sh

cd "$(dirname "$0")"

clear

rm -f MountEFI; rm -f setup

if [[ -f ../MountEFI.sh ]]; then 
            edit_vers=$(cat ../MountEFI.sh | grep -m1 "edit_vers=" | sed s'/edit_vers=//' | tr -d '" \n')
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



            if [[ -d ../Extra ]]; then rm -R -f ../Extra; fi
            mkdir ../Extra
            if [[ -f MountEFI ]]; then cp MountEFI ../Extra; fi
            if [[ -f setup ]]; then cp setup ../Extra; fi

if [[ ! -d ../MountEFI.app ]]; then
    if  [[ -f ../MountEFI.zip ]]; then unzip  -o -qq ../MountEFI.zip -d ../. ; rm -R -f ../*MACOSX ; fi
fi

if [[ -d ../MountEFI.app ]]; then
            if [[ -f MountEFI ]]; then 
                mv -f MountEFI ../MountEFI.app/Contents/Resources/MountEFI 
                plutil -replace CFBundleShortVersionString -string "$vers" ../MountEFI.app/Contents/Info.plist
            fi
            if [[ -f setup ]]; then
                
                mv -f setup ../MountEFI.app/Contents/Resources/setup
            fi
            if [[ -f ../Notifiers/AppIcon.icns ]]; then rm -f ../MountEFI.app/Contents/Resources/AppIcon.icns; cp ../Notifiers/AppIcon.icns ../MountEFI.app/Contents/Resources/AppIcon.icns; fi
            touch ../MountEFI.app
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

if [[ ! "$edit_vers" = "" ]] || [[ ! "$prog_vers" = "" ]]; then
            if [[ ! -d Updates ]]; then mkdir Updates; fi
            current_vers=$(echo "$prog_vers" | tr -d ".")
            if [[ ${#current_vers} = 2 ]]; then current_vers+="0"; fi
            if [[ ! -d Updates/$current_vers ]]; then mkdir Updates/$current_vers; fi
            if [[ -d Updates/$current_vers/$edit_vers ]]; then rm -Rf Updates/$current_vers/$edit_vers; fi
            if [[ -f Updates/$current_vers/"$edit_vers".zip ]]; then rm -f Updates/$current_vers/"$edit_vers".zip; fi
            mkdir Updates/$current_vers/$edit_vers
            if [[ -f Extra/MountEFI ]]; then cp -a Extra/MountEFI Updates/$current_vers/$edit_vers; fi
            if [[ -f Extra/setup ]]; then cp -a Extra/setup Updates/$current_vers/$edit_vers; fi
            if [[ -d MountEFI.app ]]; then cp -a MountEFI.app/Contents/document.wflow Updates/$current_vers/$edit_vers; cp -a MountEFI.app/Contents/MacOS/"Application Stub" Updates/$current_vers/$edit_vers; fi
            if ls Updates/$current_vers/$edit_vers/* 2>/dev/null >/dev/null; then 
                ditto -c -k --sequesterRsrc --keepParent Updates/$current_vers/$edit_vers Updates/$current_vers/"$edit_vers"".zip"
                if [[ -d Autoupdates ]]; then rm -Rf Autoupdates; fi
                mkdir Autoupdates; touch Autoupdates/AutoupdatesInfo.txt
                echo $current_vers >> Autoupdates/AutoupdatesInfo.txt
                echo $edit_vers >> Autoupdates/AutoupdatesInfo.txt
                #if [[ -f Updates/$current_vers/$edit_vers/MountEFI ]]; then echo "MountEFI;"$(md5 -qq Updates/$current_vers/$edit_vers/MountEFI) >> Autoupdates/AutoupdatesInfo.txt; fi
                #if [[ -f Updates/$current_vers/$edit_vers/setup ]]; then echo "setup;"$(md5 -qq Updates/$current_vers/$edit_vers/setup) >> Autoupdates/AutoupdatesInfo.txt; fi
                #if [[ -f Updates/$current_vers/$edit_vers/document.wflow ]]; then echo "document.wflow;"$(md5 -qq Updates/$current_vers/$edit_vers/document.wflow) >> Autoupdates/AutoupdatesInfo.txt; fi
                #if [[ -f Updates/$current_vers/$edit_vers/"Application Stub" ]]; then echo ""Application Stub";"$(md5 -qq Updates/$current_vers/$edit_vers/"Application Stub") >> Autoupdates/AutoupdatesInfo.txt; fi
                if [[ -f Updates/$current_vers/"$edit_vers"".zip" ]]; then echo $(md5 -qq Updates/$current_vers/"$edit_vers"".zip") >> Autoupdates/AutoupdatesInfo.txt; fi
            fi
            rm -Rf Updates/$current_vers/$edit_vers
fi             
 
cat  ~/.bash_history | sed -n '/appify/!p' >> ~/new_hist.txt; rm ~/.bash_history; mv ~/new_hist.txt ~/.bash_history
#osascript -e 'quit app "terminal.app"' & exit

exit

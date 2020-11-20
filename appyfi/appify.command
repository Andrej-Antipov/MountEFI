#!/bin/sh

# Версия для нового апплета

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


MAKE_NEW_APPLET(){
            if [[ -d "${SOURCE}" ]]; then
                ROOT="../MountEFI.app/Contents/Resources"
                TARGET="../MountEFI.app/Contents"
                mv -f "${SOURCE}/script" "${ROOT}/script" 2>/dev/null
                if [[ ! -d "${ROOT}/MainMenu.nib" ]]; then mv -f "${SOURCE}/MainMenu.nib" "${ROOT}/" 2>/dev/null; fi 
                if [[ ! -f "${ROOT}/AppSettings.plist" ]]; then mv -f "${SOURCE}/AppSettings.plist" "${ROOT}/AppSettings.plist" 2>/dev/null; fi
                if [[ ! -f "$TARGET/MacOS/MountEFI" ]]; then mv -f "${SOURCE}/MountEFI" "$TARGET/MacOS/MountEFI" 2>/dev/null; fi
                mv -f "${SOURCE}/Info.plist" "$TARGET/Info.plist" 2>/dev/null
                rm -f "$TARGET/document.wflow" 2>/dev/null
                rm -f "$TARGET/MacOS/Automator"* 2>/dev/null
                rm -f "$TARGET/MacOS/Application"* 2>/dev/null
                plutil -replace CFBundleShortVersionString -string "$vers" ../MountEFI.app/Contents/Info.plist
                rm -Rf "${SOURCE}"
            fi
}

BACK_OLD_APPLET(){
                ROOT="../MountEFI.app/Contents/Resources"
                TARGET="../MountEFI.app/Contents"
                rm -Rf "${ROOT}/MainMenu.nib"
                rm -f "${ROOT}/script" "${ROOT}/AppSettings.plist" "$TARGET/MacOS/MountEFI"*
                mv -f "${SOURCE}/Info.plist" "$TARGET/Info.plist" 2>/dev/null 
                mv -f "${SOURCE}/Application Stub" "$TARGET/MacOS/Application Stub" 2>/dev/null
                mv -f "${SOURCE}/document.wflow" "$TARGET/document.wflow" 2>/dev/null
                plutil -replace CFBundleShortVersionString -string "$vers" ../MountEFI.app/Contents/Info.plist
                rm -Rf "${SOURCE}"

}

if [[ ! -d ../MountEFI.app ]]; then
    if  [[ -f ../MountEFI.zip ]]; then unzip  -o -qq ../MountEFI.zip -d ../. ; rm -R -f ../*MACOSX ; fi
 
  elif [[ -d ../MountEFI.app ]]; then
            if [[ -f MountEFI ]]; then 
                mv -f MountEFI ../MountEFI.app/Contents/Resources/MountEFI 
                #plutil -replace CFBundleShortVersionString -string "$vers" ../MountEFI.app/Contents/Info.plist
            fi
            if [[ -f setup ]]; then
                
                mv -f setup ../MountEFI.app/Contents/Resources/setup
            fi
            chmod +x ../MountEFI.app/Contents/Resources/MountEFI ../MountEFI.app/Contents/Resources/setup
            if [[ -f ../Notifiers/AppIcon.icns ]]; then rm -f ../MountEFI.app/Contents/Resources/AppIcon.icns; cp ../Notifiers/AppIcon.icns ../MountEFI.app/Contents/Resources/AppIcon.icns; fi
            if [[ -d ../Notifiers/Newapp ]]; then 
                cp -a ../Notifiers/Newapp .Newapp
                SOURCE=".Newapp"
                MAKE_NEW_APPLET
                elif [[ -f ../MountEFI.app/Contents/Resources/MountEFI ]]; then
                     cp -a ../Notifiers/Oldapp .Oldapp
                     SOURCE=".Oldapp"
                BACK_OLD_APPLET
            fi 
            if [[ -f ../MountEFI.app/Contents/document.wflow ]]; then 
                cat ../MountEFI.app/Contents/document.wflow | sed s'/edit_vers="[0-9]*"/edit_vers="'$edit_vers'"/' > .document.wflow
                if [[ -s .document.wflow ]]; then mv -f .document.wflow ../MountEFI.app/Contents/document.wflow; fi
                elif [[ -f ../MountEFI.app/Contents/Resources/script ]]; then 
                    cat ../MountEFI.app/Contents/Resources/script | sed s'/edit_vers="[0-9]*"/edit_vers="'$edit_vers'"/' > .script
                    if [[ -s .script ]]; then mv -f .script ../MountEFI.app/Contents/Resources/script; chmod +x ../MountEFI.app/Contents/Resources/script; fi
            fi
            if [[ -f ../Notifiers/MEFIScA.sh ]]; then cp -a ../Notifiers/MEFIScA.sh ../MountEFI.app/Contents/Resources/MEFIScA.sh; fi
            if [[ -f ../Notifiers/color_editor.sh ]]; then cp -a ../Notifiers/color_editor.sh ../MountEFI.app/Contents/Resources/cm_edit 
                    chmod +x ../MountEFI.app/Contents/Resources/cm_edit; fi
            touch ../MountEFI.app
            rm -f .document.wflow
fi

cd ..

if [[ -f Notifiers/DefaultConf.plist ]]; then 
        if [[ -f MountEFI.app/Contents/Resources/DefaultConf.plist ]]; then rm MountEFI.app/Contents/Resources/DefaultConf.plist; fi
        cp Notifiers/DefaultConf.plist MountEFI.app/Contents/Resources/
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
touch MountEFI.app
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
            if [[ -f Notifiers/DefaultConf.plist ]]; then cp -a Notifiers/DefaultConf.plist Updates/$current_vers/$edit_vers; fi
            if [[ -d MountEFI.app ]] && [[ ! -d Notifiers/Newapp ]]; then
                cp -a MountEFI.app/Contents/Info.plist Updates/$current_vers/$edit_vers 
                cp -a MountEFI.app/Contents/document.wflow Updates/$current_vers/$edit_vers
                cp -a MountEFI.app/Contents/MacOS/"Application Stub" Updates/$current_vers/$edit_vers
            fi
            if ls Updates/$current_vers/$edit_vers/* 2>/dev/null >/dev/null; then
            if [[ -d Notifiers/Newapp ]]; then 
                    cp -a Notifiers/Newapp Updates/$current_vers/$edit_vers; rm -f Updates/$current_vers/$edit_vers/document.wflow
                    plutil -replace CFBundleShortVersionString -string "$vers" Updates/$current_vers/$edit_vers/Newapp/Info.plist
                    cat Updates/$current_vers/$edit_vers/Newapp/script | sed s'/edit_vers="[0-9]*"/edit_vers="'$edit_vers'"/' > Updates/$current_vers/$edit_vers/Newapp/.script
                    if [[ -s Updates/$current_vers/$edit_vers/Newapp/.script ]]; then mv -f Updates/$current_vers/$edit_vers/Newapp/.script Updates/$current_vers/$edit_vers/Newapp/script; fi
                    rm -f Updates/$current_vers/$edit_vers/.script; chmod +x Updates/$current_vers/$edit_vers/Newapp/script
            fi
                if [[ -d Notifiers/Oldapp ]]; then 
                    cp -a Notifiers/Oldapp/document.wflow Updates/$current_vers/$edit_vers
                    #cp -a Notifiers/Oldapp/Info.plist Updates/$current_vers/$edit_vers
                fi
                
                if [[ -f Notifiers/OC_Hashes.txt ]]; then cp -a Notifiers/OC_Hashes.txt Updates/$current_vers/$edit_vers/OC_Hashes.txt ; fi
                if [[ -f Notifiers/MEFIScA.sh ]]; then cp -a Notifiers/MEFIScA.sh Updates/$current_vers/$edit_vers/ ; fi
                if [[ -f Notifiers/color_editor.sh ]]; then cp -a Notifiers/color_editor.sh Updates/$current_vers/$edit_vers/cm_edit ; chmod +x Updates/$current_vers/$edit_vers/cm_edit; fi

                ditto -c -k --sequesterRsrc --keepParent Updates/$current_vers/$edit_vers Updates/$current_vers/"$edit_vers"".zip"
                if [[ -d Autoupdates ]]; then rm -Rf Autoupdates; fi
                #mkdir Autoupdates; touch Autoupdates/AutoupdatesInfo.txt
                echo $current_vers > Updates/AutoupdatesInfo.txt
                echo $edit_vers >> Updates/AutoupdatesInfo.txt
                if [[ -f Updates/$current_vers/"$edit_vers"".zip" ]]; then echo $(md5 -qq Updates/$current_vers/"$edit_vers"".zip") >> Updates/AutoupdatesInfo.txt; fi

            fi
            rm -Rf Updates/$current_vers/$edit_vers
fi 

if [[ -f ~/.bash_history ]]; then cat  ~/.bash_history | sed -n '/appify/!p' >> ~/new_hist.txt; rm -f ~/.bash_history; mv ~/new_hist.txt ~/.bash_history ; fi >/dev/null 2>/dev/null
if [[ -f ~/.zsh_history ]]; then cat  ~/.zsh_history | sed -n '/appify/!p' >> ~/new_z_hist.txt; rm -f ~/.zsh_history; mv ~/new_z_hist.txt ~/.zsh_history ; fi >/dev/null 2>/dev/null

exit

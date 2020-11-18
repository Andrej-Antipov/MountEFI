#!/bin/bash

#  Created by Андрей Антипов on 18.11.2020.#  Copyright © 2020 gosvamih. All rights reserved.


COLOR_MODE(){
#######################################################################################################################################################
################################################### блок установки модификации цветного вывода ######################################################
# cm        # список модификаторов цвета
# cm_ptr   # список указателей на элементы списка модификаторов cm
cm=() 
cm_ptr=( head_ast head_str head_os head_X head_sch head_upd_sch head_upd_sch_num head_upd_sch_br head_upd_sch_sp head_num_sch head_sch_br head_pls \
head_pls_str head_pls_qts head_sata head_usb dots_line1 dots_line2 dots_line3 num_sata num_sata_br num_usb num_usb_br mount_sata_pls mount_sata_dots \
mount_usb_pls mount_usb_dots dn_sata dn_usb dn_bsd_sata pn_size_sata pn_size_msata dn_bsd_usb pn_size_usb pn_size_musb sata_bsd sata_bsp usb_bsd usb_bsp \
rv0 kh_str curs_str curs_num_1 curs_num_2 ld_unrec ld_oc ld_cl ld_wn ld_rf ld_gb ld_oth cl_Q cl_P cl_U cl_E cl_A cl_S cl_I cl_V cl_C cl_O cl_L cl_W cl_M \
cl_E2 cl_ast cl_str cl_conf ld_srch ld_srch_sp ld_srch_bt rv1 rv2 rv3 clr dark)
for i in ${!cm_ptr[@]}; do export ${cm_ptr[i]}=$i; done

Black="\e[0m\e[30m"  Cyan="\e[0m\e[36m"  LightBlue="\e[0m\e[94m" Red="\e[0m\e[31m" LightGray="\e[0m\e[37m" LightMagenta="\e[0m\e[95m"
Green="\e[0m\e[32m" DarkGray="\e[0m\e[90m" LightCyan="\e[0m\e[96m" Yellow="\e[0m\e[33m" LightRed="\e[0m\e[91m" White="\e[0m\e[97m"
Blue="\e[0m\e[34m" LightGreen="\e[0m\e[92m" Magenta="\e[0m\e[35m" LightYellow="\e[0m\e[93m"
BBlack="\e[0m\e[1;30m" BCyan="\e[0m\e[1;36m" BLightBlue="\e[0m\e[1;94m" BRed="\e[0m\e[1;31m" BLightGray="\e[0m\e[1;37m"
BLightMagenta="\e[0m\e[1;95m" BGreen="\e[0m\e[1;32m" BDarkGray="\e[0m\e[1;90m" BLightCyan="\e[0m\e[1;96m" BYellow="\e[0m\e[1;33m"
BLightRed="\e[0m\e[1;91m" BWhite="\e[0m\e[1;97m" BBlue="\e[0m\e[1;34m" BLightGreen="\e[0m\e[1;92m" BMagenta="\e[0m\e[1;35m" 
BLightYellow="\e[0m\e[1;93m" DBlack="\e[0m\e[2;30m" DCyan="\e[0m\e[2;36m" DLightBlue="\e[0m\e[2;94m" DRed="\e[0m\e[2;31m"
DLightGray="\e[0m\e[2;37m" DLightMagenta="\e[0m\e[2;95m" DGreen="\e[0m\e[2;32m" DDarkGray="\e[0m\e[2;90m" DLightCyan="\e[0m\e[2;96m"
DYellow="\e[0m\e[2;33m" DLightRed="\e[0m\e[2;91m" DWhite="\e[0m\e[2;97m" DBlue="\e[0m\e[2;34m" DLightGreen="\e[0m\e[2;92m" 
DMagenta="\e[0m\e[2;35m" DLightYellow="\e[0m\e[2;93m" cOFF="\e[0m" Dim="\e[0m\e[2m" Bright="\e[0m\e[1m" Orange="\e[38;5;222m" Limon="\e[38;5;116m"
ForSATA="\e[38;5;228m" 

cm[head_ast]="$DWhite"              # звёздочки заголовка
cm[head_str]="$Cyan"                # строка заголовка
cm[head_os]="$Green"                # версия мак ос арабскими
cm[head_X]="$LightMagenta"          # версия мак ос латинскими
cm[head_sch]="$LightGray"           # строка "повторить поиск раздела"
cm[head_upd_sch]="$LightGray"       # строка поиска (по клавише 0)
cm[head_upd_sch_num]="$BCyan"       # цифра ноль в строке поиса по 0
cm[head_upd_sch_br]="$LightGray"    # скобка строки поиска по 0
cm[head_upd_sch_sp]="$LightGray"    # спинер строки поиска по 0
cm[head_num_sch]="$BLightCyan"      # цифра 0 строки повторения поиска
cm[head_sch_br]="$LightGray"        # скобка у строки повторения поиска
cm[head_pls]="$cOFF"                # цвет + у строки "подключенные"
cm[head_pls_str]="$LightGray"       # цвет строки "подключенные"
cm[head_pls_qts]="$DCyan"           # кавычки строки "подключенные"
cm[head_sata]="$ForSATA"            # цвет слова SATA
cm[head_usb]="$Limon"               # цвет слова USB
cm[dots_line1]="$LightGray"         # первый сверху ряд точек
cm[dots_line2]="$LightGray"         # второй сверху ряд точек
cm[dots_line3]="$LightGray"         # третий сверху ряд точек
cm[num_sata]="$LightYellow"         # числа для sata
cm[num_sata_br]="$LightYellow"      # скобка после числа sata
cm[num_usb]="$LightCyan"            # числа для usb
cm[num_usb_br]="$LightCyan"         # скобка после числа usb
cm[mount_sata_pls]="$BLightMagenta" # цвет плюса для примонтированных sata
cm[mount_sata_dots]="$Yellow"       # цвет точек для отключенных sata
cm[mount_usb_pls]="$BLightMagenta"  # цвет плюса для примонтированных sata
cm[mount_usb_dots]="$Cyan"          # цвет точек для отключенных sata
cm[dn_sata]="$LightYellow"          # имена дисков sata              
cm[dn_usb]="$LightCyan"             # имена дисков usb
cm[dn_bsd_sata]="$LightYellow"      # имя BSD для SATA
cm[pn_size_sata]="$Orange"          # размер раздела для SATA
cm[pn_size_msata]="$LightYellow"    # размерность раздела для SATA
cm[dn_bsd_usb]="$LightCyan"         # имя BSD для USB
cm[pn_size_usb]="$Limon"            # размер раздела для USB
cm[pn_size_musb]="$LightCyan"       # размерность раздела для USB
cm[sata_bsd]="$Orange"              # имя BSD номер диска SATA
cm[sata_bsp]="$Orange"              # имя BSD номер тома SATA
cm[usb_bsd]="$Limon"                # имя BSD номер диска USB
cm[usb_bsp]="$Limon"                # имя BSD номер тома USB
cm[rv0]="$cOFF"                     # резерв
cm[kh_str]="$LightGray"             # текст подсказок по клавишам
cm[curs_str]="$LightGray"           # строка подсказок перед кусором
cm[curs_num_1]="$BLightCyan"        # первое число строки подсказки
cm[curs_num_2]="$BLightYellow"      # втоое число строки подсказки
cm[ld_unrec]="$Red"                 # загрузчик не распознан
cm[ld_oc]="$Limon"                  # загрузчик OpenCore
cm[ld_cl]="$Green"                  # загрузчик Clover
cm[ld_wn]="$LightBlue"              # загрузчик Windows
cm[ld_rf]="$LightRed"               # загрузчик Refind
cm[ld_gb]="$LightYellow"            # загрузчик Grub
cm[ld_oth]="$LightMagenta"          # загрузчик из списка Other
cm[cl_Q]="$LightMagenta"            # цвет букв Q строки подсказки
cm[cl_P]="$BLightBlue"              # буква P
cm[cl_U]="$BCyan"                   # буква U
cm[cl_E]="$BLightYellow"            # буква E
cm[cl_A]="$BRed"                    # буква A
cm[cl_S]="$BLightMagenta"           # буква S
cm[cl_I]="$BLightGreen"             # буква I
cm[cl_V]="$BGreen"                  # буква V
cm[cl_C]="$BLightGreen"             # буква C
cm[cl_O]="$BLightCyan"              # буква O
cm[cl_L]="$BYellow"                 # буква L
cm[cl_W]="$BLightCyan"              # буква W
cm[cl_M]="$BLightGreen"             # буква M
cm[cl_E2]="$BLightBlue"             # буква E для редактора цвета
cm[cl_ast]="$Yellow"                # цвет звёздочек подсказки функции P                   
cm[cl_str]="$Cyan"                  # цвет строки после звёздочек
cm[cl_conf]="$LightMagenta"         # цвет config,plist в строке функции P
cm[ld_srch]="$LightGray"            # строка поиска загрузчиков
cm[ld_srch_sp]="$LightMagenta"      # спинер поиска загрузчиков
cm[ld_srch_bt]="$LightMagenta"      # bootx64.efi в строке поиска загрузчиков
cm[rv1]="$cOFF"                     # резерв
cm[rv2]="$cOFF"                     # резерв
cm[rv3]="$cOFF"                     # резерв
cm[clr]="$cOFF"                     # конец применения цвета
cm[dark]="0"                        # флаг тёмной темы

cm_string="\e[0m\e[2;38;5;15m+\e[0m\e[38;5;39m+\e[0m\e[32m+\e[0m\e[95m+\e[0m\e[37m+\e[0m\e[38;5;228m+\e[0m\e[38;5;39m+\e[0m\e[38;5;64m+"\
"\e[0m\e[38;5;228m+\e[0m\e[38;5;39m+\e[0m\e[37m+\e[0m+\e[0m\e[37m+\e[0m\e[2;36m+\e[0m\e[38;5;228m+\e[38;5;116m+\e[0m\e[37m+"\
"\e[0m\e[37m+\e[0m\e[37m+\e[0m\e[93m+\e[0m\e[93m+\e[0m\e[96m+\e[0m\e[96m+\e[0m\e[38;5;15m+\e[0m\e[33m+\e[0m\e[38;5;15m+"\
"\e[0m\e[38;5;8m+\e[0m\e[38;5;227m+\e[0m\e[38;5;44m+\e[0m\e[38;5;11m+\e[0m\e[38;5;227m+\e[0m\e[93m+\e[0m\e[38;5;14m+\e[0m\e[38;5;44m+"\
"\e[0m\e[96m+\e[0m\e[38;5;227m+\e[0m\e[38;5;227m+\e[0m\e[38;5;44m+\e[0m\e[38;5;44m+\e[0m+\e[0m\e[37m+\e[0m\e[37m+\e[0m\e[1;38;5;44m+"\
"\e[0m\e[1;93m+\e[0m\e[31m+\e[0m\e[38;5;159m+\e[0m\e[38;5;10m+\e[0m\e[1;38;5;31m+\e[0m\e[38;5;167m+\e[0m\e[1;38;5;184m+\e[0m\e[95m+"\
"\e[0m\e[95m+\e[0m\e[38;5;9m+\e[0m\e[1;36m+\e[0m\e[1;93m+\e[0m\e[1;31m+\e[0m\e[1;95m+\e[0m\e[1;92m+\e[0m\e[1;32m+\e[0m\e[1;92m+"\
"\e[0m\e[1;96m+\e[0m\e[1;33m+\e[0m\e[38;5;11m+\e[0m\e[1;92m+\e[0m\e[38;5;88m+\e[0m\e[33m+\e[0m\e[36m+\e[0m\e[95m+\e[0m\e[38;5;7m+"\
"\e[0m\e[38;5;7m+\e[0m\e[38;5;28m+\e[0m+\e[0m+\e[0m+\e[0m+0"

IFS='+'; cm=($cm_string); unset IFS

current_background="{4064, 8941, 17101}"; current_foreground="{65535, 65535, 65535}"; current_fontname="SF Mono Regular"; current_fontsize="11"
osascript -e "tell application \"Terminal\" to set background color of window 1 to $current_background" \
-e "tell application \"Terminal\" to set normal text color of window 1 to $current_foreground" \
-e "tell application \"Terminal\" to set the font name of window 1 to \"$current_fontname\"" \
-e "tell application \"Terminal\" to set the font size of window 1 to $current_fontsize"

###########################################################################################################################################################
}
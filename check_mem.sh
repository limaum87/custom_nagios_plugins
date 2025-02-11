#!/bin/bash

if [ "$1" = "-w" ] && [ "$2" -gt "0" ] && [ "$3" = "-c" ] && [ "$4" -gt "0" ]; then
        FreeM=$(free -m)
        
        # Extrair valores da memória
        memTotal_m=$(echo "$FreeM" | grep Mem | awk '{print $2}')
        memAvailable_m=$(echo "$FreeM" | grep Mem | awk '{print $7}')

        # Calcular memória usada corretamente
        memUsedCorrected=$((memTotal_m - memAvailable_m))
        memUsedPrc=$((memUsedCorrected * 100 / memTotal_m))

        # Avaliar os limites
        if [ "$memUsedPrc" -ge "$4" ]; then
                echo "Memory: CRITICAL Total: $memTotal_m MB - Used: $memUsedCorrected MB - $memUsedPrc% used!|TOTAL=$memTotal_m;;;; USED=$memUsedCorrected;;;;"
                exit 2
        elif [ "$memUsedPrc" -ge "$2" ]; then
                echo "Memory: WARNING Total: $memTotal_m MB - Used: $memUsedCorrected MB - $memUsedPrc% used!|TOTAL=$memTotal_m;;;; USED=$memUsedCorrected;;;;"
                exit 1
        else
                echo "Memory: OK Total: $memTotal_m MB - Used: $memUsedCorrected MB - $memUsedPrc% used!|TOTAL=$memTotal_m;;;; USED=$memUsedCorrected;;;;"
                exit 0
        fi
else
        sName=$(basename "$0")
        echo -e "\n\n\t\t### $sName Version 2.0###\n"
        echo -e "# Usage:\t$sName -w <warnlevel> -c <critlevel>"
        echo -e "\t\t= warnlevel and critlevel is percentage value without %\n"
        echo "# EXAMPLE:\t/usr/lib64/nagios/plugins/$sName -w 80 -c 90"
        echo -e "\nThis script is released under an open license and is free for everyone to use, modify, and distribute."
        echo -e "No copyright restrictions. Shared for the benefit of all.\n\n"
        exit
fi

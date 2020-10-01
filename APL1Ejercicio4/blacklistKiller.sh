#!/bin/bash

declare -a blackproc
    i=0;
    cat 
    for proceso in $(cat "$archivoDeBlacklist" )
    do
        blackproc[i]="$proceso"
        ((i++))
    done
    

    
    while true;
    do    
        for i in "${!blackproc[@]}" 
        do 
            proceso_encontrado=$(ps aux|grep ${blackproc[i]}| grep -v "grep" -c)
            if [ $proceso_encontrado -gt 0 ]
            then
                fecha="$(date +"%Y-%m-%d_%H:%M:%S")"
                killed_pids="$(ps aux | grep ${blackproc[i]} | grep -v "grep" | awk '{print $1,$2,$11}')"
                echo $fecha $killed_pids >> "$directorioSalida/$outputFileName" 
                #para que no se vea en la terminal la salida de la pantalla.
                killall $killed_pids 2> /dev/null 
            fi    
        done
    done
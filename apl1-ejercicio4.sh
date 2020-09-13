#!/bin/bash

# Command line help
display_help() {
    echo
    echo "Usage: $0 [option...]"
    echo
    echo "   -b,    [Requiered] Path absoluto o relativo del archivo con la blacklist de procesos."
    echo "   -o,    [Optional]  Path absoluto o relativo del directorio donde se generara el archivo de salida. Opcional. Si no se informa, se generará en el directoio de ejecución."
    echo
    exit 1
}

emptyDirectory() { 
    echo "No se ha indicado el directorio para el $1";
    display_help;
    exit 0;
}

parametersError() { 
    echo "Error. El directorio $1 no es un directorio válido o el file no tiene permisos de lectura"
    display_help;
    exit 0;
}

callSintaxError() { 
    echo "Error de sintaxis en la llamada a la función. Cantidad minima de parametros requerida no cumplida"
    display_help;
    exit 0;
}

# INICIO DE VALIDACION DE PARAMETROS
    if [ "$1" == "-h" ] || [ "$1" == "-help" ]; then
                display_help # Mostramos la ayuda sobre el call de la función.
    else

        if [ $# -lt 2 ] ; then # Verifico si no cumple la cantidad minima de parametros requeridos
            callSintaxError
        fi

        while [[ $# > 0 ]] # Itero sobre la cantidad de parametros que se ingresaron.
        do
            case "$1" in
                -b) # Hacemos los parametros se desplacen una posición para atras, ej: $2 pasa a ser $1.
                    shift 
                        # Validación del parametro -b (Obligatorio y válido)
                        if [ -z "$1" ] ; then
                                emptyDirectory "Blacklist (-b)";
                        elif
                            [ ! -r "$1" ] ; then
                                parametersError "$1";
                            else
                                archivoDeBlacklist="$1"; # Asigno la variable correspondiente ya que paso las validaciones.
                        fi
                    shift 
                    ;;
                -o)
                    shift
                        # Validación del parametro -o (Opcional pero válido, no informa que se cree si no exista, revisar esa opción)
                        if [ -z "$1" ] ; then
                            directorioSalida=$(echo $PWD);
                        elif
                            [ ! -r "$1" ] ; then
                                parametersError "$1";
                        else 
                            directorioSalida="$1"; # Asigno la variable correspondiente ya que paso las validaciones.
                        fi
                    shift 
                    ;;
                *)
                    shift 
                    ;;
            esac
        done
        if [ -z "$directorioSalida" ] ; then # Si no hay parametro -o, estara vacio directorio_salida, por ende se asigna el directorio actual
             directorioSalida=$(echo $PWD);
        fi
    fi
# FIN DE VALIDACION DE PARAMETROS

echo "" 
    echo "  EJECUTANDO EL SCRIPT: $0"
    echo ""
    echo "  1 - Directorio blacklist:           "$archivoDeBlacklist""
    echo "  2 - Directorio de Salida:           "$directorioSalida""
    echo ""
#Aca empieza el algoritmo matador de procesos...
    declare -a blackproc
    i=0;
    for proceso in $(cat "$archivoDeBlacklist" ) #| tr ‘[A-Z]’ ‘[a-z]’)
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
                echo $fecha $killed_pids >> "$directorioSalida/logfile.log" 

                killall $killed_pids 2> /dev/null #para que no se vea en la terminal la salida de la pantalla.

            fi    
        done
    done
    
#FIN   

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
    echo "Error. El directorio $1 no es un directorio válido o no tiene permisos de escritura"
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

        if [ $# -lt 2 ] || [ $# -gt 4 ]; then # Verifico si no cumple la cantidad minima de parametros requeridos
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
                            [ ! -w "$1" ] ; then
                                parametersError "$1";
                        else 
                            directorioSalida="$1"; # Asigno la variable correspondiente ya que paso las validaciones.
                        fi
                    shift 
                    ;;
                *)
                    callSintaxError;
                    shift 
                    ;;
            esac
        done
        if [ -z "$directorioSalida" ] ; then # Si no hay parametro -o, estara vacio directorio_salida, por ende se asigna el directorio actual
             directorioSalida=$(echo $PWD);
        fi
    fi
# FIN DE VALIDACION DE PARAMETROS

# Se debia crear el archivo que guarda los procesos del blacklist cerrados.
    outputFileName=$(echo blacklist_{$(date +"%Y-%m-%d_%H:%M:%S")}.out)
    touch "$directorioSalida/$outputFileName" && chmod +w "$directorioSalida/$outputFileName"

    export directorioSalida
    export outputFileName
    export archivoDeBlacklist
# Se le da permisos de ejecucion al segundo script, y se lo ejecuta en segundo plano    
    chmod +x "$PWD/depuradorBlacklist.sh"
    ./depuradorBlacklist.sh &
    
#FIN   

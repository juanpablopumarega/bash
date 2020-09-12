#!/bin/bash

# Command line help
display_help() {
    echo
    echo "Usage: $0 [option...]"
    echo
    echo "   -d,    [Requiered] Path absoluto o relativo a analizar."
    echo "   -o,    [Optional]  Path absoluto o relativo del directorio donde se generara el archivo de salida. Opcional. Si no se informa, se generará en el directoio de ejecución."
    echo "   -u,    [Optional]  Tamaño definido en KB para definir el umbral a analizar. Si no es indicado, se considerará como umbral el promedio de peso de los archivos inspeccionados"
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
                -d) # Hacemos los parametros se desplacen una posición para atras, ej: $2 pasa a ser $1.
                    shift 
                        # Validación del parametro -d (Obligatorio y válido)
                        if [ -z "$1" ] ; then
                                emptyDirectory "Analisis (-d)";
                        elif
                            [ ! -r "$1" ] ; then
                                parametersError "$1";
                            else
                                directorioDeAnalisis="$1"; # Asigno la variable correspondiente ya que paso las validaciones.
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
                -u)
                    shift
                        # Validación del parametro -u (Opcional)
                        if [ -z "$1" ] ; then
                            umbral=$(echo "-1");
                        else
                            umbral="$1"; # Asigno la variable correspondiente ya que paso las validaciones.
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


#Calculamos el umbral si no existe
    if [ -z $umbral ] || [[ $umbral == "-1" ]] ; then
        echo "Entro?"
        umbral=$(find $directorioDeAnalisis -type f -ls | awk '{sum += $7; n++;} END {print sum/n;}');
    fi

#Nombre del archivo de salida
    outputFileName=$(echo resultado_$(date +"%Y-%m-%d_%H:%M:%S").out)

#Impresiones por pantalla de ayuda, borrar antes de entregar.
    echo "" 
    echo "  EJECUTANDO EL SCRIPT: $0"
    echo ""
    echo "  1 - Nombre de archivo de salida:    "$outputFileName""
    echo "  2 - Directorio a analizar:          "$directorioDeAnalisis""
    echo "  3 - Directorio de Salida:           "$directorioSalida""
    echo "  4 - Umbral:                         "$umbral""
    echo ""




#FIN
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

            if [[ "$1" != "-d" ]] && [[ "$1" != "-o" ]] && [[ "$1" != "-u" ]]; then
                callSintaxError;
            fi

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
        umbral=$(find $directorioDeAnalisis -type f -ls | awk '{sum += $7; n++;} END {print int(sum/n);}');
    fi

#Nombre del archivo de salidaq
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

#Inicio el ciclo para detectar archivos duplicados
    declare -A array

    #Genero un file temporal donde obtengo el listado de todos los files del directorio a analizar
    filePivote="/tmp/APL1Ejercicio3_pivote.dat"
    find $directorioDeAnalisis -type f -name "*" -ls | awk '{print$11}' > $filePivote

    echo ""

    for linea in $(cat $filePivote)
    do
        fileName=$(basename "$linea"); #Obtengo el nombre del file
        if [[ ! -z ${array[$fileName]} ]] ; then
            array[$fileName]=1; #Si esta duplicado lo marcamos con el flag 1.
        else
            array[$fileName]=0; #No dulicado flag 0.
        fi
    done

    #echo "Intentando mostrar el array"
    #for key in "${!array[@]}"; do echo "$key => ${array[$key]}"; done

# Muestro el nombre del file duplicado y realizo un find para obtener los detalles del mismo.
    echo "ARCHIVO DUPLICADOS" >> $directorioSalida/$outputFileName;
    
    for key in "${!array[@]}"; 
    do 
        if [[ ${array[$key]} == 1 ]] ; then
            echo "Filename: $key" >> $directorioSalida/$outputFileName;
            find $directorioDeAnalisis -name $key -type f -ls | awk '{print$10,$11}' >> $directorioSalida/$outputFileName;
        fi
    done   

#Muestro los files que superen el umbral.
    echo "" >> $directorioSalida/$outputFileName;
    echo "ARCHIVOS QUE SUPEREN EL UMBRAL: $umbral    [ SIZE | FILE ]" >> $directorioSalida/$outputFileName;
    echo "$(find $directorioDeAnalisis -type f -name "*" -size +"$umbral"c -ls | awk '{print $7,$11}' | sort -r)" >> $directorioSalida/$outputFileName;
    echo ""

# Muestro por pantalla el file resultante
    cat $directorioSalida/$outputFileName;

# Elimino el file pivote
    rm $filePivote;

#FIN
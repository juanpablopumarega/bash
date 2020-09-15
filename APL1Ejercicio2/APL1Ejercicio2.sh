#!/bin/bash

# Command line help
display_help() {
    echo
    echo "Usage: $0 [option...]"
    echo
    echo "   -s,    [Required] Path absoluto o relativo del archivo con los stopwords. "
    echo "   -o,    [Optional]  Path absoluto o relativo del directorio donde se generara el archivo de salida. Opcional. Si no se informa, se generaraá en el directoio de ejecución."
    echo "   -i,    [Required]  Path absoluto o relativo del archivo de texto a analizar"
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

        if [ $# -lt 4 ] ; then # Verifico si no cumple la cantidad minima de parametros requeridos
            callSintaxError
        fi

        while [[ $# > 0 ]] # Itero sobre la cantidad de parametros que se ingresaron.
        do
        
            if [[ "$1" != "-s" ]] || [[ "$1" != "-i" ]]; then
                callSintaxError;
            fi

            case "$1" in
                -s) # Hacemos los parametros se desplacen una posición para atras, ej: $2 pasa a ser $1.
                    shift 
                        # Validación del parametro -s (Obligatorio y válido)
                        if [ -z "$1" ] ; then
                                emptyDirectory "Archivo de Stop Wordssssss (-s)";
                        elif
                            [ ! -r "$1" ] ; then
                                parametersError "$1";
                            else
                                archivo_stopwords="$1"; # Asigno la variable correspondiente ya que paso las validaciones.
                        fi
                    shift 
                    ;;
                -o)
                    shift
                        # Validación del parametro -o (Opcional pero válido, no informa que se cree si no exista, revisar esa opción)
                        if [ -z "$1" ] ; then
                            directorio_salida=$(echo $PWD);
                        elif
                            [ ! -r "$1" ] ; then
                                parametersError "$1";
                        else 
                            directorio_salida="$1"; # Asigno la variable correspondiente ya que paso las validaciones.
                        fi
                    shift 
                    ;;
                -i)
                    shift
                        # Validación del parametro -i (Obligatorio y válido)
                        if [ -z "$1" ] ; then
                            emptyDirectory "Archivo a Analizar (-i)";
                        elif
                            [ ! -r "$1" ] ; then
                                parametersError "$1";
                        else
                            archivo_analizar="$1"; # Asigno la variable correspondiente ya que paso las validaciones.
                        fi
                    shift 
                    ;;
                *)
                    shift 
                    ;;
            esac
        done
        if [ -z "$directorio_salida" ] ; then # Si no hay parametro -o, estara vacio directorio_salida, por ende se asigna el directorio actual
             directorio_salida=$(echo $PWD);
        fi
    fi
# FIN DE VALIDACION DE PARAMETROS

#Nombre del archivo de salida
    outputFileName=$(echo frecuencias_$(basename "$archivo_analizar")_$(date +"%Y-%m-%d_%H:%M:%S").out)

#Impresiones por pantalla de ayuda, borrar antes de entregar.
    echo "" 
    echo "  EJECUTANDO EL SCRIPT: $0"
    echo ""
    echo "  1 - Nombre de archivo de salida:    "$outputFileName""
    echo "  2 - Archivo de StopWords:           "$archivo_stopwords""
    echo "  3 - Directorio de Salida:           "$directorio_salida""
    echo "  4 - Archivo a Analizar:             "$archivo_analizar""
    echo ""

#Doble for para leer por linea y luego por palabra a eliminar.
    for linea in $(cat "$archivo_stopwords" | tr ‘[a-z]’ ‘[A-Z]’)
    do
        for word in $linea
        do
            sed -i -e 's/'"$word"'//g' "$archivo_analizar" #reemplazo la palabra de Stop Words por nada en el archivo analizado.
        done
    done

#Eliminamos doble espacio, puntos, comas, guines, signos de admiración y exclamación resultante
    #sed -i -e 's/  / /; s/\,//; s/\.//; s/\-//; s/\?//; s/\!//' "$archivo_analizar"
#Este cambio es para que tenga en cuenta todos los signos de puntuacion. 
    sed -i -e 's/[[:punct:]]/ /g' "$archivo_analizar"
#Y luego de ahi eliminar los posibles esapcios dobles
    sed -i -e 's/  / /g' "$archivo_analizar" #la g al final es para que tome todos? 

#Llenamos un array asociativo con las palabras del archivo y contamos la ocurrencia de cada una.
    declare -A array

    for word in $(cat "$archivo_analizar" | tr ‘[a-z]’ ‘[A-Z]’)
    do
        if [[ ! -z ${array[$word]} ]] ; then
            array[$word]=$(( ${array[$word]} + 1 ))
        else
            array[$word]=1;
        fi
    done

#Escribo el archvio de salida leyendo el array
    for i in "${!array[@]}" 
    do 
        echo "$i,${array[$i]}" >> "$directorio_salida/$outputFileName"
    done

#Otorgo permisos de ejecución y realizo el sort sobre los 5 ma repetidos (-t indica separador, -k2 indica segunda columna, -nr orden numerico y de descendente)
    chmod +r "$directorio_salida/$outputFileName"
    cat "$directorio_salida/$outputFileName" | sort -t"," -k2nr | head -5

#FIN

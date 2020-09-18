#!/bin/bash

# Command line help
display_help() {
    echo
    echo "Usage: $0 [option...]"
    echo
    echo "   -s,    [Required]  Path absoluto o relativo del archivo con los stopwords. "
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
    echo "Error de sintaxis en la llamada a la función. Cantidad minima/maxima de parametros requerida no cumplida"
    display_help;
    exit 0;
}

# INICIO DE VALIDACION DE PARAMETROS
    if [ "$1" == "-h" ] || [ "$1" == "-help" ]; then
                display_help # Mostramos la ayuda sobre el call de la función.
    else

        if [ $# -lt 4 ] || [ $# -gt 6 ]; then # Verifico si no cumple la cantidad minima de parametros requeridos
            callSintaxError
        fi

        while [[ $# > 0 ]] # Itero sobre la cantidad de parametros que se ingresaron.
        do
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
                    callSintaxError;
                    shift 
                    ;;
            esac
        done
        if [ -z "$directorio_salida" ] ; then # Si no hay parametro -o, estara vacio directorio_salida, por ende se asigna el directorio actual
             directorio_salida=$(echo $PWD);
        fi
    fi
# FIN DE VALIDACION DE PARAMETROS

#Genero un archivo temporal en /tmp con el contenido ya transformado a mayusculas
    archivoTEMP=$(echo /tmp/"$(basename "$archivo_analizar").mayus")
    cat "$archivo_analizar" | tr ‘[a-z]’ ‘[A-Z]’ > "$archivoTEMP";

#Doble for para leer por linea y luego por palabra a eliminar.
    for word in $(cat "$archivo_stopwords" | tr ‘[a-z]’ ‘[A-Z]’)
    do
        sed -i -e 's/\b'"$word"'\b//g' "$archivoTEMP" #reemplazo la palabra de Stop Words por nada en el archivo analizado.
    done

#Este cambio es para que tenga en cuenta todos los signos de puntuacion. 
    sed -i -e 's/[[:punct:]]/ /g' "$archivoTEMP";

#Llenamos un array asociativo con las palabras del archivo y contamos la ocurrencia de cada una.
    declare -A array

    for word in $(cat "$archivoTEMP" | tr ‘[a-z]’ ‘[A-Z]’)
    do
        if [[ ! -z ${array[$word]} ]] ; then
            array[$word]=$(( ${array[$word]} + 1 ))
        else
            array[$word]=1;
        fi
    done

#Nombre del archivo de salida
    outputFileName=$(echo frecuencias_$(basename "$archivo_analizar")_$(date +"%Y-%m-%d_%H:%M:%S").out)

#Escribo el archvio de salida leyendo el array
    for i in "${!array[@]}" 
    do 
        echo "$i,${array[$i]}" >> "/tmp/$outputFileName.tmp"
    done

#Crep el file de salida ordenado (-t indica separador, -k2 indica segunda columna, -nr orden numerico y de descendente)
    cat "/tmp/$outputFileName.tmp" | sort -t"," -k2nr > "$directorio_salida/$outputFileName"

#Muestro el top 5
    cat "$directorio_salida/$outputFileName" | head -5

#Borro el file temporal utilizado
    rm "$archivoTEMP";
    rm "/tmp/$outputFileName.tmp";

#FIN

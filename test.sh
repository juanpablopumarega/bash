#!/bin/bash

# Command line help
display_help() {
    echo
    echo "Usage: $0 [option...]"
    echo
    echo "   -s,           Path absoluto o relativo del archivo con los stopwords. Required"
    echo "   -o,           Path absoluto o relativo del directorio donde se generara el archivo de salida. Opcional. Si no se informa, se generaraá en el directoio de ejecución."
    echo "   -i,           Path absoluto o relativo del archivo de texto a analizar"
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



#Iniciamos con la validacion de cantidad y parseo de los argumentos recibidos.
    if [ "$1" == "-h" ] || [ "$1" == "-help" ]; then
                display_help # Mostramos la ayuda sobre el call de la función.
    else

        if [ $# -lt 4 ] ; then # Verifico si no cumple la cantidad minima de parametros requeridos
            callSintaxError
        fi

        while [[ $# > 0 ]] # Itero sobre la cantidad de parametros que se ingresaron.
        do
            case $1 in
                -s) # Hacemos los parametros se desplacen una posición para atras, ej: $2 pasa a ser $1.
                    shift 
                    archivo_stopwords=$1 
                    shift 
                    ;;
                -o)
                    shift 
                    directorio_salida=$1 
                    shift 
                    ;;
                -i)
                    shift 
                    archivo_analizar=$1 
                    shift 
                    ;;
                *)
                    shift 
                    ;;
            esac
        done
    fi
    
#Validación del parametro -s (Obligatorio y válido)
    if [ -z $archivo_stopwords ] ; then
        emptyDirectory "Archivo de Stop Words (-s)";
    elif
        [ ! -r $archivo_stopwords ] ; then
            parametersError $archivo_stopwords;
    fi

#Validación del parametro -o (Opcional pero válido, no informa que se cree si no exista, revisar esa opción)
    if [ -z $directorio_salida ] ; then
        directorio_salida=$(echo $PWD);
    elif
        [ ! -r $directorio_salida ] ; then
            parametersError $directorio_salida;
    fi

#Validación del parametro -i (Obligatorio y válido)
    if [ -z $archivo_analizar ] ; then
        emptyDirectory "Archivo a Analizar (-i)";
    elif
        [ ! -r $archivo_analizar ] ; then
            parametersError $archivo_analizar;
    fi

#Nombre del archivo de salida
timestamp=$(date +"%Y-%m-%d_%H:%M:%S")
outputFileName=$(echo frecuencias_$archivo_analizar_{$timestamp}.out)

#Impresiones por pantalla de ayuda
echo "Nombre de archivo de salida: $outputFileName"
echo "archivo_stopwords: $archivo_stopwords"
echo "directorio_salida: $directorio_salida"
echo "archivo_analizar: $archivo_analizar"




#!/bin/bash

# Command line help
display_help() {
    echo
    echo "Usage: $0 [option...]"
    echo
    echo "   --aria,    [Required] Path absoluto o relativo del archivo que contiene la lista de atributos aria."
    echo "   --tags,    [Required] Path absoluto o relativo del archivo que contiene la lista de etiquetas a analizar."
    echo "   --web,     [Required] Path absoluto o relativo del archivo HTML a evaluar."
    echo "   --out,     [Required] Path absoluto o relativo del archivo de salida"
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
    if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
        display_help # Mostramos la ayuda sobre el call de la función.
    else

        if [ $# -ne 8 ] ; then # Verifico si no cumple la cantidad minima de parametros requeridos
            callSintaxError
        fi

        while [[ $# > 0 ]] # Itero sobre la cantidad de parametros que se ingresaron.
        do
            case "$1" in
                --aria) # Hacemos los parametros se desplacen una posición para atras, ej: $2 pasa a ser $1.
                        shift 
                            # Validación del parametro -aria (Obligatorio y válido)
                            if [ -z "$1" ] ; then
                                    emptyDirectory "Analisis (--aria)";
                            elif
                                [ ! -r "$1" ] ; then
                                    parametersError "$1";
                                else
                                    fileAria="$1"; # Asigno la variable correspondiente ya que paso las validaciones.
                            fi
                        shift 
                        ;;
                --tags)
                        shift 
                            # Validación del parametro -tags (Obligatorio y válido)
                            if [ -z "$1" ] ; then
                                    emptyDirectory "Analisis (--tags)";
                            elif
                                [ ! -r "$1" ] ; then
                                    parametersError "$1";
                                else
                                    fileTags="$1"; # Asigno la variable correspondiente ya que paso las validaciones.
                            fi
                        shift 
                        ;;
                --web)
                        shift 
                            # Validación del parametro -web (Obligatorio y válido)
                            if [ -z "$1" ] ; then
                                    emptyDirectory "Analisis (--web)";
                            elif
                                [ ! -r "$1" ] ; then
                                    parametersError "$1";
                                else
                                    fileHTML="$1"; # Asigno la variable correspondiente ya que paso las validaciones.
                            fi
                        shift 
                        ;;
                --out)
                        shift 
                            # Validación del parametro -out (Obligatorio y válido)
                            if [ -z "$1" ] ; then
                                    emptyDirectory "Analisis (--out)";
                            elif
                                [ ! -r "$1" ] ; then
                                    parametersError "$1";
                                else
                                    outputFileDirectory="$1"; # Asigno la variable correspondiente ya que paso las validaciones.
                            fi
                        shift 
                        ;;
                *)  
                        callSintaxError;
                        shift 
                        ;;
            esac
        done
    fi
# FIN DE VALIDACION DE PARAMETROS

#Nombre del archivo de salida
    outputFileName=$(echo accessibilityTest_$(date +"%Y-%m-%d_%H:%M:%S").out)

#Creo el archivo de salida con ese encabezado
    echo "{" > "$outputFileDirectory/$outputFileName";
    echo -e '\t' "[" >> "$outputFileDirectory/$outputFileName";

#Contamos la cantidad de tags que analizamos
    cantidadTags=$(cat "$fileTags" | wc -w);
    cont=0;

#Iteramos el contador para saber cuando llegamos al limite de tag
#Interamos el file de tags procesando las coincidencias de todos los tags que llegan por archivo
    for word in $(cat "$fileTags") 
    do 
        (( cont++ ));
        grep -n \<$word "$fileHTML" | grep -vif "$fileAria" | awk -f parseo.awk -v etiqueta=$word -v cantidadTags=$cantidadTags -v contadorTags=$cont>> "$outputFileDirectory/$outputFileName"
    done;

    echo -e '\t' "]" >> "$outputFileDirectory/$outputFileName";
    echo "}" >> "$outputFileDirectory/$outputFileName";

    #Lo siguiente se hace para obtener la cantidad de lineas a modificar y controlar que sea distinto de 0. Para saber que mensaje mostrar por pantalla. 
    flag=$(grep "\"cantidad\":" "$outputFileDirectory/$outputFileName" | sed  's/,//g' | awk '{sum += $2;} END {print sum;}');

    echo "El proceso ha llegado al final correctamente."

    #Comparacion para saber que imprimir.
    if [[ $flag -gt 0 ]] ; then 
        echo "Se deben realizar cambios en el archivo, la cantidad de lineas a corregir son: $flag."
    else 
        echo "No se deben realizar cambios en el archivo."
    fi


#FIN 

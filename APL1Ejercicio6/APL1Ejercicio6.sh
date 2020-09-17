#!/bin/bash

# Command line help
display_help() {
    echo
    echo "Usage: $0 [option...]"
    echo
    echo "   -c,    [Required] Si este parámetro está presente se comprimen los archivos"
    echo "   -n,    [Required] Cantidad de días a tener en cuenta para comprimir, si no está por defecto son 30"
    echo "   -d,    [Required] Si este parámetro está presente se descomprimen los archivos"
    echo "   -p,    [Required] Indica el nombre del paciente del cual se quiere descomprimir la historia clínica"
    echo "   -hc,   [Required] Path relativo o absoluto del directorio en donde se encuentran las historias clínicas de los pacientes y el archivo “últimas visitas.txt”"
    echo "   -z,    [Required]  path relativo o absoluto del directorio en donde se guardan los archivos comprimidos"
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

        if [ $# -gt 7 ] ; then # Verifico si no cumple la cantidad minima de parametros requeridos
            callSintaxError
        fi

        while [[ $# > 0 ]] # Itero sobre la cantidad de parametros que se ingresaron.
        do
            case "$1" in
                -c) # 
                if "$1" in 
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


#Nombre del archivo de salidaq
    outputFileName=$(echo accessibilityTEst_$(date +"%Y-%m-%d_%H:%M:%S").out)

#Impresiones por pantalla de ayuda, borrar antes de entregar.
    echo "" 
    echo "  EJECUTANDO EL SCRIPT: $0"
    echo ""
    echo "  1 - File de Arias:                  "$fileAria""
    echo "  2 - File de Tags:                   "$fileTags""
    echo "  3 - File HTML a analizar:           "$fileHTML""
    echo "  4 - File de Salida:                 "$outputFileDirectory/$outputFileName""
    echo ""

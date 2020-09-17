#!/bin/bash

# Command line help
display_help() {
    echo
    echo "Usage: $0 [option...]"
    echo
    echo "   -c,    [-Unique] Si este parámetro está presente se comprimen los archivos"
    echo "   -n,    [Optional if -c] Cantidad de días a tener en cuenta para comprimir, por defecto son 30"
    echo "   -d,    [-Unique] Si este parámetro está presente se descomprimen los archivos"
    echo "   -p,    [Required if -d] Indica el nombre del paciente del cual se quiere descomprimir la historia clínica"
    echo "   -hc,   [Required] Path relativo o absoluto del directorio en donde se encuentran las historias clínicas de los pacientes y el archivo “últimas visitas.txt”"
    echo "   -z,    [Required] Path relativo o absoluto del directorio en donde se guardan los archivos comprimidos"
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
    flag=0;

    if [ "$1" == "-h" ] || [ "$1" == "-help" ]; then
        display_help # Mostramos la ayuda sobre el call de la función.
    else

        if [ $# -lt 5 ] ; then # Verifico si no cumple la cantidad minima de parametros requeridos.
            callSintaxError;
        fi

        while [[ $# > 0 ]] # Itero sobre la cantidad de parametros que se ingresaron.
        do
            case "$1" in
                -c)
                    # Validación del parametro -c (Uncio y válido).
                    if [ $flag = "d" ] || [ $flag = "p" ] ; then
                        parametersError "$1";
                    else
                        if [[ $flag == 0 ]] ; then
                            flag="c";
                        fi
                        action="$1"; # Asigno la variable correspondiente ya que paso las validaciones.
                    fi
                    shift
                    ;;
                -d)
                    # Validación del parametro -d (Unico y válido).
                    if [ $flag = "c" ] || [ $flag = "n" ] ; then
                        parametersError "$1";
                    else
                        if [[ $flag == 0 ]] ; then
                            flag="d";
                        fi
                        action="$1"; # Asigno la variable correspondiente ya que paso las validaciones.
                    fi 
                    shift
                    ;;
                -n)
                    shift #VALIDAR QUE SEAN DIAS
                    if [[ $1 < 1 ]] || [ $flag = "d" ] || [ $flag = "p" ] ; then
                        callSintaxError;
                    else
                        if [[ $flag == 0 ]] ; then
                            flag="n";
                        fi
                        cantDias=$1;
                    fi
                    shift
                    ;;
                -p)
                    shift
                    if [ -z "$1" ] || [ $flag = "c" ] || [ $flag = "n" ] ; then
                        callSintaxError;
                    else
                        if [[ $flag == 0 ]] ; then
                            flag="p";
                        fi
                        nombrePacienteADescomprimir=$1;
                    fi
                    shift
                    ;;    
                -hc)
                    shift
                        if [ -z "$1" ] ; then
                            emptyDirectory "Analisis (-hc)";
                        elif [ ! -r "$1" ] ; then
                            parametersError "$1";
                        else
                            directoryHC="$1"; # Asigno la variable correspondiente ya que paso las validaciones. Historias Clinicas
                        fi
                    shift
                    ;;
                -z)
                    shift
                        if [ -z "$1" ] ; then
                            emptyDirectory "Analisis (-z)";
                        elif [ ! -r "$1" ] ; then
                            parametersError "$1";
                        else
                            fileZ="$1"; # Asigno la variable correspondiente ya que paso las validaciones. Historias Clinicas
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

    #Si no recibimos cantidad de dias por parametros, el default será 30.
    if [ -z $cantDias ] && [ $action = "-c" ] ; then
        cantDias=30;
    fi

# FIN DE VALIDACION DE PARAMETROS

#Impresiones por pantalla de ayuda, borrar antes de entregar.
    echo "" 
    echo "  EJECUTANDO EL SCRIPT: $0"
    echo ""
    echo "  1 - La accion a realizar es                 "$action""
    echo "  2 - Cantidad de dias antiguedad:            "$cantDias""
    echo "  3 - Paciente a descomprimir:                "$nombrePacienteADescomprimir""
    echo "  4 - File de historia clinica:               "$directoryHC/ultimasvisitas.txt""
    echo "  5 - Directorio donde guardar comprimidos:   "$fileZ""
    echo ""

#Declaro el array a utilizar.
    declare -A ListadoPacientes

#Declaramos la fecha de hoy para realizar la comparación contra el archivo de historiales.
    fechaHoy=$(date +"%Y-%m-%d")

#Comprimimos si llega la acción.
    if [[ $action == "-c" ]]; then

        if [ ! -r "$directoryHC"/ultimasvisitas.txt ] ; then
            parametersError;
        fi

        while read -r line
        do
            nombre="$(echo "$line" | cut -d '|' -f 1)"
            fecha=$(echo "$line" | cut -d '|' -f 2)

            #Si existe un directorio con el nombre del paciente, lo cargo en el array.
            if [ -d "$directoryHC"/"$nombre" ] ; then
                ListadoPacientes["$nombre"]=$fecha
            fi 
        done < "$directoryHC"/ultimasvisitas.txt 

    #Comprimimos el/los archivos de los pacientes cuya ultima consulta fue previa a la variable -n
    for key in "${!ListadoPacientes[@]}";
        do     
            fechaUltVisita=${ListadoPacientes[$key]}
            difDias="$(( ($(date -d $fechaHoy +%s) - $(date -d $fechaUltVisita +%s)) / 86400 ))"
            
            if [ $cantDias -lt $difDias ] ; then 
                cd "$directoryHC"
                tar -zcf "$key".tar.gz "$key"
                rm -r "$key"
                mv -f "$key".tar.gz "$fileZ"/"$key"
                echo "$key - - - - - - - - Compresion correcta"
                (( cantidadComprimidos++ ))
                cd - > /dev/null
            fi
        done
        echo "Se han comprimido exitosamente: $cantidadComprimidos"

#Descomprimimos si llega la acción.
    elif [[ $action == "-d" ]]; then
        cd "$directoryHC"
        tar -xzf "$nombrePacienteADescomprimir".tar.gz
        rm -r "$nombrePacienteADescomprimir".tar.gz
        echo "$nombrePacienteADescomprimir - - - - - - - - - - Descompresion correcta"
        cd - > /dev/null
    fi


#Falta que el comprimido viaje hacia otro rumbo.
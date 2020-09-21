#####################################################################################################################
# APL:              1                                                                                               #
# Ejercicio:        1                                                                                               #
# Entrega N°:       1                                                                                               #
# Nombre Script:    APL1Ejercicio1.sh                                                                               #
# Ejemplo de uso:                                                                                                   #
# Grupo 2                                                                                                           #
# Fernández Durante Cynthya Alexandra   DNI:48693815                                                                #
# Lopez Pumarega Juan Pablo             DNI:34593023                                                                #
# Miranda Andres                        DNI:32972232                                                                #
# Paiva Gordillo Nahuel Alejo           DNI:38455227                                                                #
# Salerti Natalia                       DNI:41559796                                                                #
#####################################################################################################################



#!/bin/bash 




ErrorS() # (1) Función. Salida por pantalla de comentarios de como debe ser la sintaxis del script ejecutado.
{ 
    echo "Error. La sintaxis del script es la siguiente:"
    echo "      Pruebe: $0 nombre_archivo L"  
    echo "      Pruebe: $0 nombre_archivo C" 
    echo "      Pruebe: $0 nombre_archivo M"
} 
 
ErrorP() # (2) Función. Salida por pantalla en caso de que el archivo no exista o no posea permisos de lectura correspondientes para el usuario.
{ 
    echo "Error. $1 no tiene permisos de lectura"  
}
 
if test  $# -lt 2 ; then # (3) Se verifica que existan al menos 2 parámetros enviados al script
    ErrorS
    exit;
fi
 
if ! test -r $1; then # (4) Se verifica que exista el archivo y este tenga permisos de lectura
    ErrorP
    exit;

elif test -f $1 && (test $2 = "L" || test $2 = "C" || test $2 = "M"); then #(5) En caso de que el archivo exista y el segundo parámetro coincida con algun patrón establecido, se procederá con el análisis.
    if [ "$2" == "L" ] ; then # (5.1) Se cuentan y se imprime por pantalla la cantidad de lineas que contiene el archivo. 
        res=`wc -l $1 | cut -d ' ' -f 1`;
        echo "La cantidad de saltos de línea es de: $res";
    elif [ "$2" == "C" ] ; then # (5.2) Se cuentan y se imprime por pantalla la cantidad de carácteres que contiene el archivo.
        res=`wc -m $1 | cut -d ' ' -f 1`;
        echo "La cantidad de carácteres en el archivo es de: $res";
    elif [ "$2" == "M" ] ; then # (5.3) Se imprime por pantalla la cantidad de carácteres que contiene la línea más larga del archivo.
        res=`wc -L $1 | cut -d ' ' -f 1`;
        echo "La longitud de la línea más larga es de: $res";
    fi         
else
    ErrorS
fi


#   Responda: 
#   a.¿Cuál es el objetivo de este script? 
#       - Hace uso del comando wc, con una salida mas amigable para el usuario.
#   b.¿Qué parámetros recibe? 
#       - Parámetros entrantes: 
#           (1) Nombre de un archivo
#           (2) Argumentos con la siguiente funcionalidad:
#                   L: mostrar saltos de línea 
#                   C: cantidad de carácteres 
#                   M: longitud de la línea más larga.
#
#   c.Comentar el código según la funcionalidad (no describa los comandos, indique la lógica) 
#       - Ver en líneas.
#   d.Completar los “echo” con el mensaje correspondiente. 
#       - Ver en líneas.
#   e.¿Qué información brinda la variable “$#”? ¿Qué otras variables similares conocen? Explíquelas. 
#       - La información que nos brinda es la cantidad de parámetros escritos en el comando. 
#   f.Explique las diferencias entre los distintos tipos de comillas que se pueden utilizar en Shell scripts.
#       - "Comillas Dobles": Se interpretan las variables dentro de las comillas, es decir se muestra el contenido de las mismas y no el nombre.
#       - 'Comillas Simples': Se define una cadena de caracteres, donde el contenido es literal.
#       - `Acento grave`: Le indica a bash que el contenido corresponde a un comando.
#   g.¿Existe algún error en el código?, de ser así indique el motivo y corríjalo.
#       - "Fi" : este error se encontraba al final del código, y es un error ya que bash es un código case sensitive. Tendría que haber dicho "fi".
#       - "res=`wc –l $1`" por posible error en el copiado del script desde el pdf, el "-" era "–", lo que no es un argumento válido para el comando wc.
#       - Error de sintaxis antes decia "! test $1 -r", el comando debería ser "! test -r $1" 
#       - Se agregó exit en las líneas 16 y 17, porque el script no debe continuar ejecutandose luego de las validaciones.
#       - "if !test -r $1; then": en esta línea no existe el espacio necesario entre el comando test y su negación.
       
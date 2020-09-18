BEGIN{
    FS = ":"
    cont = 0;
}

{
    array[$1];
    cont++;
}

END{
    print("\t\t{");
    printf("\t\t\t\"tag\": \"%s\",\n",etiqueta);
    printf("\t\t\t\"cantidad\": %d,\n", cont);
    printf("\t\t\t\"lineas\": [");
   
    cont2 = 1;

    for (key in array){
        if (cont2 == cont)
            printf("%d", key);
        else{
            printf("%d, ", key);
            cont2++;
        }
    }   
    
    print("]");

    if (contadorTags==cantidadTags)
        print("\t\t}");
    else
        print("\t\t},");
}
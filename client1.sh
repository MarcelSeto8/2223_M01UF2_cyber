#!/bin/bash

if [ "$1" == "-h" ]
then
	SCRIPT=`basename $0` #LIMPIA Y DEJA SOLO EL NOMBRE DEL SCRIPT YA QUE VARIABLE $0 TE DICE LA RUTA
	
	echo "Ejemplo de uso"
	echo " $SCRIPT 127.0.0.1"
	exit 0 #acabamos sin ningun error marcado
fi


IP_SERVER="localhost"
IP_LOCAL=`ip address | grep -i inet | grep enp0s3 | sed "s/^ *//g" | cut -d " " -f 2 | cut -d "/" -f 1`

PORT="4242"

echo "La IP LOCAL: $IP_LOCAL"


if [ "$1" != "" ]
then
	IP_SERVER=$1
	echo "IP del servidor: $IP_SERVER"
fi

echo "Cliente HMTP"

echo "(1) SEND - Enviando el handshake"
MD5_IP=`echo $IP_LOCAL | md5sum | cut -d " " -f 1`

echo "GREEN_POWA $IP_LOCAL $MD5_IP" | nc $IP_SERVER $PORT


echo "(2) LISTEN - Escuchando confirmación"


MSG=`nc -l $PORT`

echo $MSG


if [ "$MSG" != "OK_HMTP" ]
then
    echo "ERROR 1: Handshake mal formado"
		exit 1
fi

echo "Seguimos"

echo "(5) SEND - Enviamos el nombre de archivo"

FILE_NAME="elon_musk.jpg"

FILE_MD5=`echo $FILE_NAME | md5sum | cut -d " " -f 1`

echo "FILE_NAME $FILE_NAME $FILE_MD5" | nc $IP_SERVER $PORT

echo "(6) LISTEN - Confirmación nombre archivo"

MSG=`nc -l $PORT`


if [ "$MSG" != "OK_FILE_NAME" ]
then
echo "ERROR 2: Nombre de archivo enviado incorrectamente"
exit 2
fi

echo "(9) SEND - Enviando datos del archivo"
cat memes/$FILE_NAME | nc $IP_SERVER $PORT

echo "(10) LISTEN - Escuchamos confirmacion datos archivo"

MSG=`nc -l $PORT`

if [ "$MSG" != "OK_DATA_RCPT" ]
then
		echo "ERROR 3: Datos enviados incorrectamente"
    exit 3
fi


echo "(13) SEND - MD5 de los datos"
DATA_MD5=`cat memes/$FILE_NAME | md5sum | cut -d " " -f 1`
echo "DATA_MD5 $DATA_MD5" | nc $IP_SERVER $PORT

echo "(14) LISTEN - MD5 comprobacion"
MSG=`nc -l $PORT`
if [ "$MSG" != "OK_DATA_MD5" ]
then
echo "ERROR 4: MD5 incorrecto"
echo "Mensaje de error: $MSG"
exit 4
fi


echo "Fin del envio"



exit 0

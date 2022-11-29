#!/bin/bash

IP_LOCAL=`ip address | grep -i inet | grep enp0s3 | sed "s/^ *//g" | cut -d " " -f 2 | cut -d "/" -f 1`
echo $IP_LOCAL

echo "Servidor HMTP"

echo "(0) LISTEN - Levantando el servidor"
PORT="4242"
MSG=`nc -l $PORT`
HANDSHAKE=`echo $MSG | cut -d " " -f 1`
IP_CLIENT=`echo $MSG | cut -d " " -f 2`
IP_CLIENT_MD5=`echo $MSG | cut -d " " -f 3`

echo "(3) SEND - Confirmación Handshake"
MD5_IP=`echo $IP_CLIENT | md5sum | cut -d " " -f 1`

if [ "$IP_CLIENT_MD5" != "$MD5_IP" ]
then
echo "ERROR 1: ip mal formada"
exit 1
fi


if [ "$HANDSHAKE" != "GREEN_POWA" ]
then
	 echo "KO_HMTP" | nc $IP_CLIENT $PORT
	 exit 1
fi
 	 echo "OK_HMTP" | nc $IP_CLIENT $PORT


echo "(4) LISTEN - Escuchando el nombre de archivo"

MSG=`nc -l $PORT`

echo $MSG

PREFIX=`echo $MSG | cut -d " " -f 1`
NOMBRE=`echo $MSG | cut -d " " -f 2`
FILE_MD5=`echo $MSG | cut -d " " -f 3`

echo "(7) SEND - Comprobación nombre archivo"

if [ "$PREFIX" != "FILE_NAME" ]
then
    echo "KO_FILE_NAME" | nc $IP_CLIENT $PORT
    exit 2
fi

MD5SUM=`echo $NOMBRE | md5sum | cut -d " " -f 1`

if [ "$MD5SUM" != "$FILE_MD5" ]
then
		echo "KO_FILE_MD5" | nc $IP_CLIENT $PORT
 		exit 3
fi

echo "OK_FILE_NAME" | nc $IP_CLIENT $PORT

echo "(8) LISTEN - Escuchando datos de archivo"

nc -l $PORT > inbox/$NOMBRE

echo "(11) SEND - Confirmacion recepcion datos"

echo "OK_DATA_RCPT" | nc $IP_CLIENT $PORT

echo "(12) LISTEN- MD5 de los datos"
MSG=`nc -l $PORT`
PREFIX=`echo $MSG | cut -d " " -f 1`
DATA_MD5=`echo $MSG | cut -d " " -f 2`

if [ "$PREFIX" != "DATA_MD5" ]
then
echo "KO_MD5_PREFIX" | nc $IP_CLIENT $PORT
exit 4
fi

FILE_MD5=`cat inbox/elon_musk.jpg | md5sum | cut -d " " -f 1`

if [ "$DATA_MD5" != "$FILE_MD5" ]
then
echo "KO_DATA_MD5" | nc $IP_CLIENT $PORT
exit 5
fi

echo "OK_DATA_MD5" | nc $IP_CLIENT $PORT

echo "Fin de la recepcion"


exit 0


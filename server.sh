#!/bin/bash

IP_LOCAL=`ip address | grep -i inet | grep enp0s3 | sed "s/^ *//g" | cut -d " " -f 2 | cut -d "/" -f 1`

echo "La IP del servidor es: $IP_LOCAL"

echo "Servidor HMTP"


echo "(0) LISTEN - Levantando el servidor"
PORT="4242"
MSG=`nc -l $PORT`

HANDSHAKE=`echo $MSG | cut -d " " -f 1`
IP_CLIENT=`echo $MSG | cut -d " " -f 2`


echo "(3) SEND - Confirmación Handshake"

if [ "$HANDSHAKE" != "GREEN_POWA" ]
then 
	echo "KO_HMTP" | nc $IP_CLIENT $PORT
	exit 1
fi 
echo "OK_HMTP" | nc $IP_CLIENT $PORT


echo "(4) LISTEN - Escuchando contador"

MSG=`nc -l $PORT`
CONTADOR=`echo $MSG`


echo "(7) SEND - Confirmación Contador"
if [ "$CONTADOR" != "$MSG" ]
then 	
	echo "KO_CONTADOR" | nc $IP_CLIENT $PORT
	exit 2
fi
echo "OK_CONTADOR" | nc $IP_CLIENT $PORT


for AUX in {0..$CONTADOR}
do


echo "(8) LISTEN - Escuchando el Nombre de archivos"
MSG=`nc -l $PORT`

echo $MSG

PREFIX=`echo $MSG | cut -d " " -f 1`
NOMBRE=`echo $MSG | cut -d " " -f 2`
FILE_MD5=`echo $MSG | cut -d " " -f 3`


echo "(11) SEND - Comprobación nombre archivo"

if [ "$PREFIX" != "FILE_NAME" ]
then
	echo "KO_FILE_NAME" | nc $IP_CLIENT $PORT
	exit 3
fi

MD5SUM=`echo $NOMBRE | md5sum |cut -d " " -f 1`

if [ "$MD5SUM" != "$FILE_MD5"]
then
	echo "KO_FILE_MD5" | nc $IP_CLIENT $PORT
	exit 4
fi

echo "OK_FILE_NAME" | nc $IP_CLIENT $PORT


echo "(12) LISTEN - Escuchando datos de archivo"

nc -l $PORT > inbox/$NOMBRE


echo "(15) SEND - Confirmacion recepcion datos"

echo "OK_DATA_RCPT" | nc $IP_CLIENT $PORT


echo "(16) LISTEN - MD5 de los datos"
MSG=`nc -l $PORT`
PREFIX=`echo $MSG | cut -d " " -f 1`
DATA_MD5=`echo $MSG | cut -d " " -f 2`

if [ "$PREFIX" != "DATA_MD5" ]
then
echo "KO_MD5_PREFIX" | nc $IP_CLIENT $PORT
exit 5
fi

FILE_MD5=`cat inbox/$FILE_NAME | md5sum | cut -d " " -f 1`
if [ "$DATA_MD5" != "$FILE_MD5" ]
then
	echo "KO_DATA_MD5" | nc $IP_CLIENT $PORT
	exit 6
fi

echo "OK_DATA_MD5" | nc $IP_CLIENT $PORT
done

echo "Fin de la recepcion"

exit 0

#!/bin/bash

IP_SERVER="localhost"
IP_LOCAL="127.0.0.1"

PORT="4242"

echo "Cliente HMTP"

echo "(1) SEND - Enviando el handshake"

echo "GREEN_POWA $IP_LOCAL" | nc $IP_SERVER $PORT

echo "(2) LISTEN - Escuchando confirmación"

MSG=`nc -l $PORT`

echo $MSG

if [ $MSG != "OK_HMTP" ]
then 
	echo "ERROR 1: Handshake mal formado"
	exit 1
fi

echo "Seguimos"

echo "(5)SEND - Contar y enviar contador"
CONTADOR=0
for AUX in memes/*
do
$CONTADOR += 1
done

echo "FILE_CONTADOR $CONTADOR" | nc $IP_SERVER $PORT

echo "(6) LISTEN - Confirmación contador"

MSG=`nc -l $PORT`

if [ "$MSG" != "OK_CONTADOR" ]
then
	echo "ERROR 2: Contador erroneo"
	exit 2
fi


for AUX in {0..$CONTADOR}
do

echo "(9) SEND - Nombre de archivos"

FILE_NAME="elon_musk$AUX.jpg"

FILE_MD5=`echo $FILE_NAME | md5sum | cut -d " " -f 1`

echo "FILE _NAME $FILE_NAME $FILE_MD5" | nc $IP_SERVER $PORT


echo "(10) LISTEN - Confirmación nombre archivo"

MSG=`nc -l $PORT`

if [ "$MSG" != "OK_FILA_NAME" ]
then
	echo "ERROR 3: Nombre de archivo enviado incorrectamente"
	exit 3
fi
#####
echo "(13) SEND - Enviando datos del archivo"
cat memes/$FILE_NAME | nc $IP_SERVER $PORT

echo "(14) LISTEN - Escuchamos confirmación datos archivo"

MSG=`nc -l $PORT`

if [ "$MSG" != "OK_DATA_RCPT" ]
then
	echo "ERROR 4: Datos enviados incorrectamente"
	exit 4
fi


echo "(17) SEND - MD5 de los datos"

DATA_MD5=`cat memes/$FILE_NAME | md5sum | cut -d " " -f 1`

echo "DATA_MD5 $DATA_MD5" | nc $IP_SERVER $PORT

echo "(18) LISTEN - MD5 comprobacion"
MSG=`nc -l $PORT`

if [ "$MSG" != "OK_DATA_MD5" ]
then
	echo "ERROR 5: MD5 incorrect"
	echo "Mensaje de error: $MSG"
	exit 5
fi
done

echo "Fin del envio"

exit 0



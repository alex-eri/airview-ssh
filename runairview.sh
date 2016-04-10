#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )"

copyws() 
{
    rm -rf ./tmp/
    mkdir -p ./tmp/
    cp ./airview* ./tmp/
}

getjar()
{
    scp -P $PORT $LOGIN@$HOST:/usr/www/airview.jar.pack.gz ./airview.jar.pack.gz
    unpack200 ./airview.jar.pack.gz ./airview.jar
}

start()
{
#ssh $HOST -p $PORT -l $LOGIN /bin/sh /sbin/airview web_start
#ssh -f -N $HOST -p $PORT -l $LOGIN  -L 18888:localhost:18888
ssh $HOST -f -p $PORT -l $LOGIN -L 18888:localhost:18888 /bin/sh "/sbin/airview start & sleep 10; wait \$(cat /tmp/airview/settings/pid)" 
}

ui()
{
javaws -Xnofork -jnlp ./tmp/airview.jnlp
return $?
}

stop()
{
ssh $HOST -p $PORT -l $LOGIN /bin/sh /sbin/airview stop
}


for i in "$@"
do
case $i in
    -l=*|--login=*)
    LOGIN="${i#*=}"
    ;;
    -p=*|--port=*)
    PORT="${i#*=}"
    ;;
    -h=*|--host=*)
    HOST="${i#*=}"
    ;;
    -d|--download)
    DOWNLOAD=YES
    ;;
    *)
    HOST=$i
    ;;
esac
done


[ "$HOST" ] || (echo "runairview.sh [--login=login] [--port=port] [--download] host" && exit 1)
[ "$LOGIN" ] || LOGIN=ubnt
[ "$PORT" ] || PORT=22


echo $LOGIN@$HOST:$PORT

[ "$DOWNLOAD" ] && getjar
copyws && start && ui || stop


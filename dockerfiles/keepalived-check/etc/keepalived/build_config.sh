#!/bin/bash
set -eu
BASE_DIR=$(cd `dirname $0` && pwd)
cd $BASE_DIR

if [ -f "../config.cfg" ];then
	. ../config.cfg
elif [ -f "./config.cfg" ];then 
	. ./config.cfg
fi

VIRTUAL_ROUTER_ID=`echo $KEEPALIVED_VIP|awk -F. '{print $4}'`
PRIORITY=`echo $LOCAL_IP|awk -F. '{print $4}'`

OTHER_IPS=""
i=1
for NODE_IP in `echo $NODE_LIST|sed 's/\,/ /g'`;do
        if [ "$NODE_IP" != "$LOCAL_IP" ];then
                OTHER_IPS+="\t$NODE_IP\n"
        fi
        let i=$i+1
done

replace_var(){
    files=$@
    echo $files | xargs sed -i 's/--ENNAME--/'"$ETH"'/g'
    echo $files | xargs sed -i 's/--PRIORITY--/'"$PRIORITY"'/g'
    echo $files | xargs sed -i 's/--VIRTUAL_ROUTER_ID--/'"$VIRTUAL_ROUTER_ID"'/g'
    echo $files | xargs sed -i 's/--LOCAL_IP--/'"$LOCAL_IP"'/g'
    echo $files | xargs sed -i 's/--OTHER_IPS--/'"$OTHER_IPS"'/g'
    echo $files | xargs sed -i 's/--KEEPALIVED_VIP--/'"$KEEPALIVED_VIP"'/g'
    echo $files | xargs sed -i 's/--BITMASK--/'"$BITMASK"'/g'
}

pre_conf(){
    rm -f $1
    cp $1.temp $1
    files="$1"
    replace_var $files
}

cp keepalived-${CHECK_SERVICE}.conf keepalived.conf.temp
pre_conf keepalived.conf

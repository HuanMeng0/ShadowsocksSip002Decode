#!/bin/sh
#Author: HuanMeng
#Website: https://ihuanmeng.com/

#For OpenWRT


# Usage
# bash script.sh SUB_URL


SIP002_SOURCES=$1

decodeStep1(){
	decodeStep1String=`wget -qO- ${SIP002_SOURCES} | base64 --decode`
}

decodeStep2(){
	removeSSPrefix=`echo ${decodeStep1String} | sed 's#ss:\/\/##g'`
	
	for link in ${removeSSPrefix}
	do
		decodeLink ${link}
	done


	echo "**************************"
	echo "Done."
	echo "**************************"
}


decodeLink(){
	link=$1
	encryptAndPassword=`echo ${link} | awk -F '@' '{print \$1}'`
	Hostname=`echo ${link} | awk -F '@' '{print \$2}' | awk -F ':' '{print \$1}'`
	Port=`echo ${link} | awk -F '@' '{print \$2}' | awk -F ':' '{print \$2}' | awk -F '#' '{print \$1}' `
	encryptMethod=`echo ${encryptAndPassword} | base64 --decode | awk -F ':' '{print \$1}'`
	password=`echo ${encryptAndPassword} | base64 --decode | awk -F ':' '{print \$2}'`
	
	aliasName=`echo ${Hostname} | sed -r 's#(\-|\.)##g'`
	
	uci set shadowsocks-libev.${aliasName}=server
	uci set shadowsocks-libev.${aliasName}.server=${Hostname}
	uci set shadowsocks-libev.${aliasName}.server_port=${Port}
	uci set shadowsocks-libev.${aliasName}.method=${encryptMethod}
	uci set shadowsocks-libev.${aliasName}.password=${password}
	uci commit shadowsocks-libev
	
	echo "-----------------------";
	echo "Alias Name ：" ${aliasName};
	echo "Hostname: " ${Hostname};
	echo "Port: "  ${Port};
	echo "Encrypt Method : "${encryptMethod};
	echo "Password : "${password};
	echo "-----------------------";
}


decodeStep1
decodeStep2
#! /bin/bash

chmod 777 /usr/apache-tomcat7/webapps/NetperfTool/*

interface=`ifconfig -a |grep "^e"|awk '{print $1}'`

port=()
index=0
for n in ${interface[@]}
do
	port[index]=${n%:*}
    echo ${port[index]}
	index=`expr $index + 1`
done

#config static ip on Redhat 7
function Setip_Redhat7 () {
     IPS=(200.1.1.1 200.1.2.1 200.1.3.1 200.1.4.1)
     Gateways=(200.1.1.1 200.1.2.1 200.1.3.1 200.1.4.1)
service firewalld stop

#rm -rf /etc/sysconfig/network-scripts/ifcfg-*
for name in `find /etc/sysconfig/network-scripts/ifcfg-*`
do
	if [ "${name##*/}" != "ifcfg-lo" ]; then
		echo "delete it: $name"
		rm -rf $name
	else
		echo $name
	fi
done

# if these is not ifcfg-lo file,create it
file="/etc/sysconfig/network-scripts/ifcfg-lo"
# -f .... $file ....,..........
if [ ! -f "$file" ]; then
  echo "file not existed,please create it"
  echo "DEVICE=lo
IPADDR=127.0.0.1
NETMASK=255.0.0.0
NETWORK=127.0.0.0
BROADCAST=127.255.255.255
ONBOOT=yes
NAME=loopback">/etc/sysconfig/network-scripts/ifcfg-lo
fi 


i=0
Portlength=${#port[@]}
#
while [ $i -lt $Portlength ]
do 
echo "${port[$i]}"
#------ rewrite the ifcfg-xxx file-------
hwaddr=`ifconfig ${port[$i]} |grep "ether" |awk '{print $2}'`

echo "DEVICE=${port[$i]}
HWADDR=$hwaddr
TYPE=Ethernet
ONBOOT=yes
NM_CONTROOLED=yes
BOOTPROTO=static
IPADDR=${IPS[$i]}
NETMASK=255.255.255.0
GATEWAY=${Gateways[$i]}">/etc/sysconfig/network-scripts/ifcfg-${port[$i]}

#
echo "${port[$i]},${IPS[$i]}:">>/usr/apache-tomcat7/webapps/NetperfTool/client_ip_interface.txt

echo $i
sudo ifdown ${port[$i]} &&sudo ifup ${port[$i]}

#------ i++ --------
i=`expr $i + 1` 
done
}

#set static ip on redhat6.x
function Setip_Redhat6 () {

IPS=(200.1.1.1 200.1.2.1 200.1.3.1 200.1.4.1)
Gateways=(200.1.1.1 200.1.2.1 200.1.3.1 200.1.4.1)

#close firewall 
service iptables stop

#rm -rf /etc/sysconfig/network-scripts/ifcfg-*

for name in `find /etc/sysconfig/network-scripts/ifcfg-*`
do
	if [ "${name##*/}" != "ifcfg-lo" ]; then
		echo "delete it: $name"
		rm -rf $name
	else
		echo $name
	fi
done

# if these is not ifcfg-lo file,create it
file="/etc/sysconfig/network-scripts/ifcfg-lo"
# -f .... $file ....,..........
if [ ! -f "$file" ]; then
  echo "file not existed,please create it"
  echo "DEVICE=lo
IPADDR=127.0.0.1
NETMASK=255.0.0.0
NETWORK=127.0.0.0
BROADCAST=127.255.255.255
ONBOOT=yes
NAME=loopback">/etc/sysconfig/network-scripts/ifcfg-lo
fi 



i=0
Portlength=${#port[@]}
#
while [ $i -lt $Portlength ]
do 
echo "${port[$i]}"
#------ rewrite the ifcfg-xxx file-------
hwaddr=`ifconfig ${port[$i]} |grep "HWaddr" |awk '{print $5}'`

echo "DEVICE=${port[$i]}
HWADDR=$hwaddr
TYPE=Ethernet
ONBOOT=yes
NM_CONTROOLED=no
BOOTPROTO=static
IPADDR=${IPS[$i]}
NETMASK=255.255.255.0
GATEWAY=${Gateways[$i]}">/etc/sysconfig/network-scripts/ifcfg-${port[$i]}

#
echo "${port[$i]},${IPS[$i]}:">>/usr/apache-tomcat7/webapps/NetperfTool/client_ip_interface.txt

echo $i

sudo ifdown ${port[$i]} &&sudo ifup ${port[$i]}

#------ i++ --------
i=`expr $i + 1` 

done

# Redhat 6.5 restart network
if cat /etc/redhat-release |grep 6.5 ;then
     echo "Redhat6.5 restart network"
     service network restart
fi

}

#config static ip on Suse11
function Setip_SUSE11 () {
     IPS=(200.1.2.1 200.1.1.1 200.1.3.1 200.1.4.1)
     Gateways=(200.1.2.1 200.1.1.1 200.1.3.1 200.1.4.1)
#close firewall 
#/etc/init.d/SuSEfirewall2_init stop
#/etc/init.d/SuSEfirewall2_setup stop

#close firewall suse12
SuSEfirewall2 stop
#rm -rf /etc/sysconfig/network/ifcfg-*

for name in `find /etc/sysconfig/network/ifcfg-*`
do
	if [ "${name##*/}" != "ifcfg-lo" ]; then
		echo "delete it: $name"
		rm -rf $name
	else
		echo $name
	fi
done

# if these is not ifcfg-lo file,create it
file="/etc/sysconfig/network/ifcfg-lo"
# -f .... $file ....,..........
if [ ! -f "$file" ]; then
  echo "file not existed,please create it"
  echo "DEVICE=lo
IPADDR=127.0.0.1
NETMASK=255.0.0.0
NETWORK=127.0.0.0
BROADCAST=127.255.255.255
ONBOOT=yes
NAME=loopback">/etc/sysconfig/network/ifcfg-lo
fi 


i=0
Portlength=${#port[@]}
#
while [ $i -lt $Portlength ]
do 
echo "${port[$i]}"
#------ rewrite the ifcfg-xxx file-------
hwaddr=`ifconfig ${port[$i]} |grep "ether" |awk '{print $2}'`

echo "DEVICE=${port[$i]}
HWADDR=$hwaddr
TYPE=Ethernet
ONBOOT=yes
NM_CONTROOLED=yes
BOOTPROTO=static
IPADDR=${IPS[$i]}
NETMASK=255.255.255.0
GATEWAY=${Gateways[$i]}">/etc/sysconfig/network/ifcfg-${port[$i]}

#
echo "${port[$i]},${IPS[$i]}:">>/usr/apache-tomcat7/webapps/NetperfTool/client_ip_interface.txt

echo $i
sudo ifdown ${port[$i]} &&sudo ifup ${port[$i]}

#------ i++ --------
i=`expr $i + 1` 
done

}


# if these is a client_ip_interface  file,delete it
fileclient="/usr/apache-tomcat7/webapps/NetperfTool/client_ip_interface.txt"
if [ -f "$fileclient" ]; then
  echo "client_ip_interface.txt file existe,delete it"
  rm -rf $fileclient
fi

#

if cat /etc/redhat-release |grep 7 ;then
     echo "Redhat7"
	 Setip_Redhat7
elif cat /etc/redhat-release |grep 6 ;then
    if cat /etc/redhat-release |grep 6.5 ;then
		echo "Redhat6.5 service NetworkManager stop"
		service NetworkManager stop
	fi
	echo "Redhat6.x"
	Setip_Redhat6
elif lsb_release -d |grep SUSE|grep 11;then 
	echo "Suse11"
	Setip_SUSE11
elif lsb_release -d |grep SUSE|grep 12;then 
	echo "Suse12"
	Setip_SUSE11
fi



# to start  lo interface in avoid tomcat can't start 
sudo ifup lo

echo "ifup lo ok"


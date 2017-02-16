#! /bin/bash

#cd /root/Desktop

#close interface
interface=`ifconfig -a |grep "^e"|awk '{print $1}'`
port=()
index=0
for n in ${interface[@]}
do
	port[index]=${n%:*}
	index=`expr $index + 1`
done

i=0
Portlength=${#port[@]}
#
while [ $i -lt $Portlength ]
do 

if cat /etc/redhat-release |grep 6.5 ;then
     echo "Redhat6.5 will restart network,not redhat 6.5 ifdown and ifup"
	 service NetworkManager stop
else  
     sudo ifdown ${port[$i]} &&sudo ifup ${port[$i]} 
fi

#------ i++ --------
i=`expr $i + 1` 
done

if cat /etc/redhat-release |grep 6.5 ;then
     echo "Redhat6.5 restart network"
     service network restart
fi

# judge whether installed jdk or not
#install jdk on client

rpm -qa | grep jdk
if [ $? -eq 0 ] ; then
    echo "The system has been installed JDK"
else
    echo "installing JDK..."
	cd /usr
	mkdir java 
	# if these is a java install rpm file
    file="/root/Desktop/jdk-7u79-linux-x64.rpm"
    # -f .... $file ....,..........
    if [ ! -f "$file" ]; then
       echo "file not existed,please create it"
	else
	   cp -r /root/Desktop/jdk-7u79-linux-x64.rpm /usr/java
	   cd java
	   rpm -i jdk-7u79-linux-x64.rpm
	   #set java environment
	   cat >> /etc/profile << EFF
JAVA_HOME=/usr/java/jdk1.7.0_79
PATH=$JAVA_HOME/bin:$PATH
CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
export JAVA_HOME
export PATH
export CLASSPATH

export CATALINA_HOME=/usr/apache-tomcat7/
export JRE_HOME=/usr/java/jdk1.7.0_79
EFF

		#使环境变量立即生效
		source /etc/profile
		#判断环境变量是否已经生效
		java -version
		if [ $? -ne 0 ] ;then
			echo "Have not set java path."
		else
			echo "set java path successfully!"
		fi
	
	fi

	
fi 



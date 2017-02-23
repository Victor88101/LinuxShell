#!/bin/bash
# used for install and set vsftpd 
# 20170223

echo "***************install vsftpd BEGIN*****************"
if [[ `rpm -qa|grep vsftpd` = "" ]]
then
	yum -y install vsftpd
else
	echo "vsftpd have been installed!!"
fi
echo "***************install vsftpd END*****************"

echo "***************add ftp user BEGIN*****************"
useradd -d /home/ftp -s /sbin/nologin vvftp
echo vvftp | passwd vvftp --stdin
echo "***************add ftp user END****************"

echo "*************set ftp listen_port BEGIN**************"
if [[ `sed -n "/listen_port=.*/p" /etc/vsftpd/vsftpd.conf` == '' ]]
then 
	echo "listen_port=9021" >> /etc/vsftpd/vsftpd.conf
else
	sed -i "s/listen_port=.*/listen_port=9021/g" /etc/vsftpd/vsftpd.conf
fi
sed -i "s/.*write_enable=.*/write_enable=NO/g" /etc/vsftpd/vsftpd.conf
service vsftpd restart
echo "*************set ftp listen_port END**************"

echo "***************set iptables BEGIN***************"
iptables -IINPUT -p tcp --dport 9021 -j ACCEPT
iptables save
service iptables restart
echo "***************set iptables END*****************"


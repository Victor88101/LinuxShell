#!/bin/bash
# used for init system basic configuraction 
# V1 20170208 

ETHCONF=/etc/sysconfig/network-scripts/ifcfg-eth0
NETWORK=/etc/sysconfig/network
SYSCTL=/etc/sysctl.conf

IPADDR=10.192.87.106
NETMASK=255.255.255.0
GATEWAY=10.192.87.1
DNS1=10.192.87.1

HOSTNAME=zabbix-web

MAXPROCCESSES=100000
OPENFILES=100000

SELINUXCONF=/etc/selinux/config

# set IP
setIP(){
        echo "***************start SetIP***************** "
        echo -e "IPADDR=$IPADDR\nNETMASK=$NETMASK\nGATEWAY=$GATEWAY\nDNS1=$DNS1"
        sed -i -e s/dhcp/static/g -e '/^IPADDR/d' -e '/^NETMASK/d' -e '/^GATEWAY/d' -e '/^DNS1/d' $ETHCONF
        echo -e "IPADDR=$IPADDR\nNETMASK=$NETMASK\nGATEWAY=$GATEWAY\nDNS1=$DNS1" >>$ETHCONF
        echo "***************SetIP end********************"
}

# set Hostname
setHostName(){
        echo "***************start SetHostName***************** "
        echo "set hostname to $HOSTNAME"
        sed -i -e "/^HOSTNAME=/a HOSTNAME=$HOSTNAME" -e /^HOSTNAME=/d  $NETWORK
        echo "set Hostname success!!"
        echo "***************SetHostName end********************"
}

# set yum repos
setYumRepos(){
        echo "***************start SetYumRepos***************** "
        if [[ `grep -e "mirrors\.aliyun\.com" /etc/yum.repos.d/CentOS-Base.repo` == "" ]] 
        then 
                mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
                curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo  
                yum makecache
        fi
        echo "***************SetYumRepos end********************"
}

# set time synchronization
setTimeSync(){
        echo "***************start SetTimeSync***************** "
        if [[ `rpm -qa | grep ntpdate` == '' ]]
        then
                echo "start install ntpdate..."
                yum install -y ntpdate
        fi 

        echo "*/5 * * * * /usr/sbin/ntpdate time.windows.com >/dev/null 2 >&1" >> /etc/crontab
        echo "***************SetTimeSync end********************"
}


# set ulimit
setUlimit(){
        echo "***************start SetUlimit***************** "
        sed -i /^ulimit/d /etc/profile
        echo "ulimit -u 100000 -n 100000 " >> /etc/profile
        source /etc/profile
        echo "***************SetUlimit end********************"

}

# close Firewall
closeFirewall(){
        echo "***************start closeFirewall***************** "
        
        sed -e '/^SELINUX=/a SELINUX=disabled' -e /^SELINUX=/d $SELINUXCONF

        service iptables stop

        echo "***************closeFirewall end********************* "
}

setIP
setHostName
setYumRepos
setTimeSync
setUlimit
closeFirewall

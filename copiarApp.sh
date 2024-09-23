#!/bin/bash
#
#Copiado de SNMD
cp ./snmpd/snmp-meenn.conf /etc/snmp/snmpd.conf.d/
echo "Copiado de SNMP de forma correcta..."
#
#Copiado de Fail2ban
cp ./fail2ban/* /etc/fail2ban/
echo "Copiado de JAIL de forma correcta..."
#
#Copiado de Aplicaciones de UFW
cp ./ufw/* /etc/applications.d/
echo "Copiado de Aplicaciones UFW de forma correcta..."
#
#Copiado de SSH
cp .ssh/* /etc/ssh/sshd_config.d/
#!/bin/bash
#
#Copiado de SNMD
cp ./snmpd/* /etc/snmp/snmpd.conf.d/
echo "Copiado de SNMP de forma correcta..."
#
#Copiado de Fail2ban
cp ./fail2ban/* /etc/fail2ban/
echo "Copiado de JAIL de forma correcta..."
#
#Copiado de Aplicaciones de UFW
cp ./ufw/* /etc/ufw/applications.d/
echo "Copiado de Aplicaciones UFW de forma correcta..."
#
#Copiado de SSH
cp .ssh/ssh-servidor.conf /etc/ssh/sshd_config.d/
cp .ssh/banner /etc/ssh/
echo "Copiado configuracion de SSH de forma correcta..."
#
#Copiando nginx de sitio web
cp ./nginx/* /var/www/html
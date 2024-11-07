#!/bin/bash
#
#Copiado de SNMP
cp ./snmpd/* /etc/snmp/snmpd.conf.d/
echo
echo "Copiado de SNMP de forma correcta..."
echo
#
#Copiado de Fail2ban
cp ./fail2ban/* /etc/fail2ban/
echo
echo "Copiado de JAIL de forma correcta..."
echo
#
#Copiado de Aplicaciones de UFW
cp ./ufw/* /etc/ufw/applications.d/
echo
echo "Copiado de Aplicaciones UFW de forma correcta..."
echo
#
#Copiado de SSH
cp ./ssh/ssh-servidor.conf /etc/ssh/sshd_config.d/
cp ./ssh/banner /etc/ssh/
echo
echo "Copiado configuracion de SSH de forma correcta..."
echo
#
#Copiando nginx de sitio web
cp -r ./nginx/* /var/www/html
echo
echo "copiado Archivos de html"
echo
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
rm -r /etc/fail2ban/jail.d/*
mv /etc/fail2ban/fail-ubuntu.conf /etc/fail2ban/jail.d/
echo
echo "Copiado de JAIL de forma correcta..."
echo
#
#Copiado de Aplicaciones de UFW
rm -r /etc/ufw/applications.d/*
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
rm -r /var/www/html/*
cp -r ./nginx/* /var/www/html
echo
echo "copiado Archivos de html"
echo
#Copiado de Alias en Home
echo
cp ./home/.bash_aliases $HOME
echo "Copiado de Alias de forma correcta..."
echo
#Activacion de log de UFW
echo
ufw logging medium
ufw status enable
ufw allow "nginx full"
echo
echo "Activacion de log de UFW de forma correcta..."
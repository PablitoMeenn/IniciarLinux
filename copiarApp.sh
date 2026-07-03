#!/bin/bash
#
#Copiado de SNMP
sudo cp ./snmpd/* /etc/snmp/snmpd.conf.d/
echo
echo "Copiado de SNMP de forma correcta..."
echo
#
#Copiado de Fail2ban
sudo cp ./fail2ban/* /etc/fail2ban/
sudo rm -r /etc/fail2ban/jail.d/*
sudo mv /etc/fail2ban/fail-ubuntu.conf /etc/fail2ban/jail.d/
echo
echo "Copiado de JAIL de forma correcta..."
echo
#
#Copiado de SSH
sudo cp ./ssh/ssh-servidor.conf /etc/ssh/sshd_config.d/
sudo cp ./ssh/banner /etc/ssh/
cp ./ssh/config $HOME/.ssh/config
chmod 600 $HOME/.ssh/config
echo
echo "Copiado configuracion de SSH de forma correcta..."
echo
#
#Copiando nginx de sitio web
sudo rm -r /var/www/html/*
sudo cp -r ./nginx/* /var/www/html
echo
echo "copiado Archivos de html"
echo
#
#Copiado de Alias en Home
echo
cp ./home/.bash_aliases $HOME
chmod 644 $HOME/.bash_aliases
echo "Copiado de Alias de forma correcta..."
echo
echo
sudo ufw logging medium
sudo ufw enable
sudo ufw allow "Nginx FULL"
sudo ufw allow openssh
sudo ufw allow snmp
sudo ufw allow samba
echo
echo "Activacion de log de UFW de forma correcta..."
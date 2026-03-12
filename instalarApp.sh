#!/bin/bash
#
# Actualizar la lista de paquetes
echo "Actualizando lista de paquetes..."
sudo apt update
#
# Instalar los programas
sudo apt install -y vim git htop bpytop fail2ban snmpd ufw openssh-server samba cifs-utils cmatrix #nginx 
#
echo "Limpieza de paquetes innecesarios..."
sudo apt autoremove -y
#
echo "Instalación completada."
#
#!/bin/bash
#
# Actualizar la lista de paquetes
echo "Actualizando lista de paquetes..."
sudo apt update
#
# Instalar los programas
sudo apt install -y btop cifs-utils cmatrix curl fail2ban git mtr nginx openssh-server samba snmpd ufw vim
#
echo "Limpieza de paquetes innecesarios..."
sudo apt autoremove -y
#
echo "Instalación completada."
#
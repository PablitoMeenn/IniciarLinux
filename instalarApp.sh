#!/bin/bash
#
# Actualizar la lista de paquetes
echo "Actualizando lista de paquetes..."
sudo apt update
#
# Instalar los programas
sudo apt install -y vim htop fail2ban snmpd ufw openssh-server nginx samba cifs-utils iperf3
#
echo "Limpieza de paquetes innecesarios..."
sudo apt autoremove -y
#
echo "Instalación completada."
#
sudo ufw logging medium

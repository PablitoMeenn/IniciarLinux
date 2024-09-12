#!/bin/bash

# Actualizar la lista de paquetes
echo "Actualizando lista de paquetes..."
sudo apt update

# Instalar los programas
sudo apt install -y vim htop fail2ban

echo "Limpieza de paquetes innecesarios..."
sudo apt autoremove -y

echo "Instalación completada."

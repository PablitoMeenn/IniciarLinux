#!/bin/bash

# Actualizar la lista de paquetes
echo "Actualizando lista de paquetes..."
sudo apt update

# Lista de programas a instalar
programas=(
  "htop"
  "vim"
  "wget"
  "snmpd"
  "fail2ban"
)

# Instalar los programas
echo "Instalando programas..."
for programa in "${programas[@]}"; do
  echo "Instalando $programa..."
  sudo apt install -y "$programa"
done

echo "Limpieza de paquetes innecesarios..."
sudo apt autoremove -y

echo "Instalación completada."

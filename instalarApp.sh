#!/usr/bin/env bash
set -Eeuo pipefail

source /etc/os-release
DISTRO=${ID:-}

case "$DISTRO" in
	ubuntu)
		DISTRO_NAME="Ubuntu"
		PACKAGE_MANAGER=apt
		RECOMMENDED_PACKAGES=(btop cifs-utils cmatrix curl fail2ban git mtr nginx openssh-server samba snmpd ufw vim)
		PACKAGE_NAMES=(btop cifs-utils cmatrix curl fail2ban git mtr nginx openssh-server samba snmpd ufw vim)
		;;
	fedora)
		DISTRO_NAME="Fedora"
		PACKAGE_MANAGER=dnf
		RECOMMENDED_PACKAGES=(btop cifs-utils cmatrix curl fail2ban git mtr nginx openssh-server samba net-snmp firewalld vim)
		PACKAGE_NAMES=(btop cifs-utils cmatrix curl fail2ban git mtr nginx openssh-server samba net-snmp firewalld vim)
		;;
	manjaro)
		DISTRO_NAME="Manjaro"
		PACKAGE_MANAGER=pacman
		RECOMMENDED_PACKAGES=(btop cifs-utils cmatrix curl fail2ban git mtr nginx openssh samba net-snmp ufw vim)
		PACKAGE_NAMES=(btop cifs-utils cmatrix curl fail2ban git mtr nginx openssh samba net-snmp ufw vim)
		;;
	*)
		printf 'Distribución no compatible: %s. Sistemas admitidos: Ubuntu, Fedora y Manjaro.\n' "${PRETTY_NAME:-desconocida}" >&2
		exit 1
		;;
esac

if [[ $EUID -eq 0 ]]; then
	SUDO=()
elif command -v sudo >/dev/null 2>&1; then
	SUDO=(sudo)
else
	echo "Se necesita sudo para instalar paquetes." >&2
	exit 1
fi

echo "Sistema detectado: ${PRETTY_NAME:-$DISTRO_NAME}"
echo "Perfil recomendado: instalar las herramientas del proyecto; en Fedora se conserva firewalld, su firewall nativo."
echo
echo "1) Instalación recomendada (todos los paquetes compatibles)"
echo "2) Elegir paquetes manualmente"
read -r -p "Selecciona una opción [1]: " choice
choice=${choice:-1}

case "$choice" in
	1)
		PACKAGES=("${RECOMMENDED_PACKAGES[@]}")
		;;
	2)
		echo "Indica los números separados por espacios. Opciones disponibles para $DISTRO_NAME:"
		for index in "${!PACKAGE_NAMES[@]}"; do
			printf '%2d) %s\n' "$((index + 1))" "${PACKAGE_NAMES[index]}"
		done
		read -r -p "Paquetes a instalar: " selections
		PACKAGES=()
		for selection in $selections; do
			if [[ ! $selection =~ ^[0-9]+$ ]] || (( selection < 1 || selection > ${#PACKAGE_NAMES[@]} )); then
				echo "Opción no válida: $selection" >&2
				exit 1
			fi
			PACKAGES+=("${RECOMMENDED_PACKAGES[selection - 1]}")
		done
		if ((${#PACKAGES[@]} == 0)); then
			echo "No seleccionaste paquetes; no se harán cambios."
			exit 0
		fi
		;;
	*)
		echo "Opción no válida; no se harán cambios." >&2
		exit 1
		;;
esac

printf '\nSe instalarán: %s\n' "${PACKAGES[*]}"
read -r -p "¿Continuar? [s/N] " confirmation
if [[ ! $confirmation =~ ^[sS]([iI])?$ ]]; then
	echo "Instalación cancelada."
	exit 0
fi

case "$PACKAGE_MANAGER" in
	apt)
		"${SUDO[@]}" apt update
		"${SUDO[@]}" apt install -y "${PACKAGES[@]}"
		"${SUDO[@]}" apt autoremove -y
		;;
	dnf)
		"${SUDO[@]}" dnf install -y "${PACKAGES[@]}"
		;;
	pacman)
		"${SUDO[@]}" pacman -Syu --needed --noconfirm "${PACKAGES[@]}"
		;;
esac

echo "Instalación completada en $DISTRO_NAME."
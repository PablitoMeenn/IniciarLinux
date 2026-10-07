#!/usr/bin/env bash
# Detiene el script ante errores, variables sin definir o fallos dentro de tuberías.
set -Eeuo pipefail

# Sitúa el directorio de trabajo junto a este script y carga la identificación del sistema.
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
cd "$SCRIPT_DIR"
source /etc/os-release

# Selecciona nombres de servicios y rutas que cambian según la distribución.
case "${ID:-}" in
	ubuntu)
		DISTRO_NAME=Ubuntu
		SSH_UNIT=ssh.service
		FIREWALL=ufw
		FIREWALL_COMMAND=ufw
		WEB_ROOT=/var/www/html
		SAMBA_GROUP=nogroup
		;;
	fedora)
		DISTRO_NAME=Fedora
		SSH_UNIT=sshd.service
		FIREWALL=firewalld
		FIREWALL_COMMAND=firewall-cmd
		WEB_ROOT=/usr/share/nginx/html
		SAMBA_GROUP=nobody
		;;
	manjaro)
		DISTRO_NAME=Manjaro
		SSH_UNIT=sshd.service
		FIREWALL=ufw
		FIREWALL_COMMAND=ufw
		WEB_ROOT=/usr/share/nginx/html
		SAMBA_GROUP=nobody
		;;
	*)
		printf 'Distribución no compatible: %s. Sistemas admitidos: Ubuntu, Fedora y Manjaro.\n' "${PRETTY_NAME:-desconocida}" >&2
		exit 1
		;;
esac

# Usa sudo solo cuando el script no se ejecuta ya con permisos de administrador.
if [[ $EUID -eq 0 ]]; then
	SUDO=()
elif command -v sudo >/dev/null 2>&1; then
	SUDO=(sudo)
else
	echo "Se necesita sudo para copiar configuraciones del sistema." >&2
	exit 1
fi

# Permite aplicar las configuraciones junto con el firewall o copiar sin modificarlo.
echo "Sistema detectado: ${PRETTY_NAME:-$DISTRO_NAME}"
echo "Firewall recomendado: $FIREWALL"
echo "1) Aplicar configuraciones y activar el firewall recomendado"
echo "2) Aplicar configuraciones sin modificar el firewall"
read -r -p "Selecciona una opción [1]: " choice
choice=${choice:-1}
if [[ $choice != 1 && $choice != 2 ]]; then
	echo "Opción no válida; no se harán cambios." >&2
	exit 1
fi
if [[ $choice == 1 ]] && ! command -v "$FIREWALL_COMMAND" >/dev/null 2>&1; then
	echo "No está instalado $FIREWALL. Ejecuta primero instalarApp.sh o elige no modificar el firewall." >&2
	exit 1
fi
# SSH debe estar instalado para validar la configuración del servidor que se copia.
if ! command -v sshd >/dev/null 2>&1; then
	echo "No se encontró sshd. Instala primero el servidor OpenSSH antes de copiar configuraciones." >&2
	exit 1
fi

# Instala archivos del sistema con privilegios; install -D crea los directorios necesarios.
install_system_file() {
	local source_file=$1
	local destination=$2
	local mode=$3
	"${SUDO[@]}" install -D -m "$mode" -- "$source_file" "$destination"
}
# Instala archivos en el HOME del usuario actual, sin usar sudo.
install_user_file() {
	local source_file=$1
	local destination=$2
	local mode=$3
	install -D -m "$mode" -- "$source_file" "$destination"
}

# SNMP: instala la configuración del proyecto como fragmento y activa su directorio de inclusión.
install_system_file snmpd/snmp-servidor.conf /etc/snmp/snmpd.conf.d/snmp-server.conf 0644
"${SUDO[@]}" install -d -m 0755 /etc/snmp/snmpd.conf.d
if ! "${SUDO[@]}" grep -Fqx 'includeDir /etc/snmp/snmpd.conf.d' /etc/snmp/snmpd.conf; then
	printf '\nincludeDir /etc/snmp/snmpd.conf.d\n' | "${SUDO[@]}" tee -a /etc/snmp/snmpd.conf >/dev/null
fi
# Descarga el complemento "distro" usado por SNMP; si falla, el resto del script continúa.
temp_distro=$(mktemp)
if curl -fLsS --retry 2 -o "$temp_distro" https://raw.githubusercontent.com/librenms/librenms-agent/master/snmp/distro; then
	"${SUDO[@]}" install -D -m 0755 "$temp_distro" /usr/bin/distro
else
	echo "Aviso: no se pudo descargar /usr/bin/distro; la extensión SNMP distro no funcionará." >&2
fi
rm -f "$temp_distro"

# Fail2ban: instala las reglas y adapta el nombre de la unidad SSH a la distribución.
install_system_file fail2ban/fail2ban.local /etc/fail2ban/fail2ban.local 0644
install_system_file fail2ban/jail.local /etc/fail2ban/jail.local 0644
temp_jail=$(mktemp)
sed "s/_SYSTEMD_UNIT=ssh\.service/_SYSTEMD_UNIT=$SSH_UNIT/" fail2ban/fail-ubuntu.conf > "$temp_jail"
install_system_file "$temp_jail" /etc/fail2ban/jail.d/ssh-server.conf 0644
rm -f "$temp_jail"

# UFW necesita esta definición para reconocer las reglas de la aplicación qBittorrent.
if [[ $FIREWALL == ufw ]]; then
	install_system_file ufw/applications.d/qBittorrent /etc/ufw/applications.d/qBittorrent 0644
fi

# SSH: copia la configuración del servidor y el banner, y comprueba que sshd pueda leerla.
install_system_file ssh/ssh-servidor.conf /etc/ssh/sshd_config.d/00-iniciarlinux.conf 0644
install_system_file ssh/banner /etc/ssh/banner 0644
if ! "${SUDO[@]}" sshd -t; then
	echo "La configuración de SSH no es válida; se retirará el fragmento agregado." >&2
	"${SUDO[@]}" rm -f /etc/ssh/sshd_config.d/00-iniciarlinux.conf
	exit 1
fi

# Samba: adapta el grupo compartido y agrega el fragmento sin reemplazar smb.conf existente.
SAMBA_CONFIG=/etc/samba/smb.conf
SAMBA_FRAGMENT=/etc/samba/smb.conf.d/iniciarlinux.conf
temp_samba=$(mktemp)
sed "s/force group = nogroup/force group = $SAMBA_GROUP/" samba/smb.conf > "$temp_samba"
install_system_file "$temp_samba" "$SAMBA_FRAGMENT" 0644
rm -f "$temp_samba"
if "${SUDO[@]}" test -e "$SAMBA_CONFIG"; then
	if ! "${SUDO[@]}" grep -Fqx "include = $SAMBA_FRAGMENT" "$SAMBA_CONFIG"; then
		"${SUDO[@]}" sed -i "/^\[global\]/a include = $SAMBA_FRAGMENT" "$SAMBA_CONFIG"
	fi
else
	printf '[global]\ninclude = %s\n' "$SAMBA_FRAGMENT" | "${SUDO[@]}" tee "$SAMBA_CONFIG" >/dev/null
fi

# Nginx: copia archivos y subdirectorios al directorio web de la distribución sin borrar otros archivos.
"${SUDO[@]}" install -d -m 0755 "$WEB_ROOT"
for web_file in nginx/*; do
	if [[ -d $web_file ]]; then
		"${SUDO[@]}" install -d -m 0755 "$WEB_ROOT/$(basename "$web_file")"
		while IFS= read -r -d '' nested_file; do
			destination="$WEB_ROOT/${nested_file#nginx/}"
			install_system_file "$nested_file" "$destination" 0644
		done < <(find "$web_file" -type f -print0)
	else
		install_system_file "$web_file" "$WEB_ROOT/$(basename "$web_file")" 0644
	fi
done

# Usuario: instala la configuración SSH del cliente y los alias de Bash en el HOME actual.
install -d -m 0700 "$HOME/.ssh"
install_user_file ssh/config "$HOME/.ssh/config" 0600
install_user_file home/.bash_aliases "$HOME/.bash_aliases" 0644

# Mensajes de inicio: Ubuntu usa update-motd.d; otros sistemas usan profile.d.
if [[ -d /etc/update-motd.d ]]; then
	MOTD_DIR=/etc/update-motd.d
	MOTD_SUFFIX=
else
	MOTD_DIR=/etc/profile.d
	MOTD_SUFFIX=.sh
fi
install_system_file Varios/70-custom-info "$MOTD_DIR/70-custom-info$MOTD_SUFFIX" 0755
install_system_file Varios/71-custom-fail2ban "$MOTD_DIR/71-custom-fail2ban$MOTD_SUFFIX" 0755

# Firewall: solo se modifica al elegir la opción 1; se permiten los servicios y puertos del proyecto.
if [[ $choice == 1 ]]; then
	if [[ $FIREWALL == ufw ]]; then
		# UFW: configura SSH, web, Samba, SNMP y qBittorrent antes de activarlo.
		"${SUDO[@]}" ufw logging medium
		"${SUDO[@]}" ufw allow OpenSSH ||
		"${SUDO[@]}" ufw allow "Nginx FULL"
		"${SUDO[@]}" ufw allow snmp
		"${SUDO[@]}" ufw allow samba
		"${SUDO[@]}" ufw enable
	else
		# firewalld: activa el servicio, agrega las reglas permanentes y recarga la configuración.
		"${SUDO[@]}" systemctl enable --now firewalld
		for service in ssh http https samba; do
			"${SUDO[@]}" firewall-cmd --permanent --add-service="$service"
		done
		"${SUDO[@]}" firewall-cmd --permanent --add-port=161/udp
		"${SUDO[@]}" firewall-cmd --permanent --add-port=47379/tcp
		"${SUDO[@]}" firewall-cmd --reload
	fi
	# Habilita SSH al arranque y lo inicia ahora, después de aplicar la regla del firewall.
	"${SUDO[@]}" systemctl enable --now "$SSH_UNIT"
fi

# Indica que terminó la copia; no implica que se hayan iniciado los demás servicios.
echo "Configuraciones copiadas en $DISTRO_NAME."
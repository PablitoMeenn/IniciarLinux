#!/usr/bin/env bash
#
# instalarApp.sh - Instala y activa el mismo set de programas en Ubuntu, Fedora o Manjaro.
# Detecta el sistema operativo y propone la opción recomendada por defecto.
#
set -uo pipefail

# ---------- Colores ----------
VERDE="\e[32m"; AMARILLO="\e[33m"; ROJO="\e[31m"; AZUL="\e[34m"; NEGRITA="\e[1m"; RESET="\e[0m"

# ---------- Paquetes por distribución ----------
# Fedora usa firewalld (viene por defecto), por eso no se instala ufw.
PKGS_UBUNTU=(btop cifs-utils cmatrix curl fail2ban git mtr nginx openssh-server samba snmpd ufw vim)
PKGS_FEDORA=(btop cifs-utils cmatrix curl fail2ban git mtr nginx openssh-server samba net-snmp firewalld vim)
PKGS_MANJARO=(btop cifs-utils cmatrix curl fail2ban git mtr nginx openssh samba net-snmp ufw vim)

# ---------- Servicios por distribución ----------
SRV_UBUNTU=(ssh nginx fail2ban smbd nmbd snmpd)
SRV_FEDORA=(sshd nginx fail2ban smb nmb snmpd)
SRV_MANJARO=(sshd nginx fail2ban smb nmb snmpd)

# ---------- Variables globales ----------
NOMBRE_SO="desconocido"
RECOMENDADO=0
SRV_OK=()
SRV_FALLO=()

# ---------- Funciones auxiliares ----------
info()  { echo -e "${AZUL}==>${RESET} $*"; }
ok()    { echo -e "${VERDE}✔${RESET} $*"; }
warn()  { echo -e "${AMARILLO}⚠${RESET} $*"; }
error() { echo -e "${ROJO}✘${RESET} $*" >&2; }

# Detecta la distro: RECOMENDADO = 1 Ubuntu, 2 Fedora, 3 Manjaro, 0 desconocida
detectar_so() {
    [[ -f /etc/os-release ]] || return
    # shellcheck disable=SC1091
    . /etc/os-release
    local id="${ID:-}" like="${ID_LIKE:-}"
    NOMBRE_SO="${PRETTY_NAME:-$id}"

    case "$id" in
        ubuntu)  RECOMENDADO=1; return ;;
        fedora)  RECOMENDADO=2; return ;;
        manjaro) RECOMENDADO=3; return ;;
    esac
    # Derivadas (Mint, Pop!_OS, EndeavourOS, etc.)
    case " $like " in
        *" ubuntu "*|*" debian "*) RECOMENDADO=1 ;;
        *" fedora "*|*" rhel "*)   RECOMENDADO=2 ;;
        *" arch "*)                RECOMENDADO=3 ;;
    esac
}

# ---------- Servicios ----------
habilitar_servicios() {
    info "Habilitando e iniciando servicios..."
    local s
    for s in "$@"; do
        if ! systemctl list-unit-files "${s}.service" --no-legend 2>/dev/null | grep -q "^${s}.service"; then
            warn "Servicio ${s} no encontrado, se omite."
            SRV_FALLO+=("$s (no existe)")
            continue
        fi
        if sudo systemctl enable --now "$s" >/dev/null 2>&1; then
            ok "$s activo"
            SRV_OK+=("$s")
        else
            error "$s no pudo iniciarse (revisa: journalctl -u $s)"
            SRV_FALLO+=("$s")
        fi
    done
}

# ufw (Ubuntu / Manjaro): se permite SSH ANTES de activarlo para no perder acceso remoto
configurar_ufw() {
    info "Configurando ufw..."
    sudo ufw allow 22/tcp >/dev/null
    sudo ufw --force enable >/dev/null
    sudo systemctl enable --now ufw >/dev/null 2>&1
    ok "ufw activo (SSH permitido en 22/tcp)"
}

# firewalld (Fedora): retira ufw si existía y deja SSH permitido
configurar_firewalld() {
    if rpm -q ufw >/dev/null 2>&1; then
        info "Retirando ufw (Fedora usará firewalld)..."
        sudo systemctl disable --now ufw >/dev/null 2>&1
        sudo dnf remove -y ufw
    fi
    info "Configurando firewalld..."
    sudo systemctl enable --now firewalld >/dev/null 2>&1
    sudo firewall-cmd --permanent --add-service=ssh >/dev/null
    sudo firewall-cmd --reload >/dev/null
    ok "firewalld activo (SSH permitido)"
}

# ---------- Instaladores ----------
instalar_ubuntu() {
    command -v apt >/dev/null || { error "apt no está disponible en este sistema."; exit 1; }
    info "Actualizando lista de paquetes..."
    sudo apt update
    info "Instalando programas..."
    sudo apt install -y "${PKGS_UBUNTU[@]}" || { error "Falló la instalación."; exit 1; }
    info "Limpieza de paquetes innecesarios..."
    sudo apt autoremove -y

    habilitar_servicios "${SRV_UBUNTU[@]}"
    configurar_ufw
}

instalar_fedora() {
    command -v dnf >/dev/null || { error "dnf no está disponible en este sistema."; exit 1; }
    info "Actualizando metadatos de repositorios..."
    sudo dnf makecache
    info "Instalando programas..."
    sudo dnf install -y "${PKGS_FEDORA[@]}" || { error "Falló la instalación."; exit 1; }
    info "Limpieza de paquetes innecesarios..."
    sudo dnf autoremove -y

    habilitar_servicios "${SRV_FEDORA[@]}"
    configurar_firewalld
}

instalar_manjaro() {
    command -v pacman >/dev/null || { error "pacman no está disponible en este sistema."; exit 1; }
    info "Sincronizando repositorios e instalando programas..."
    # -Syu evita actualizaciones parciales (recomendado en Arch/Manjaro)
    sudo pacman -Syu --needed --noconfirm "${PKGS_MANJARO[@]}" || { error "Falló la instalación."; exit 1; }

    info "Limpieza de paquetes huérfanos..."
    local huerfanos
    huerfanos=$(pacman -Qtdq 2>/dev/null || true)
    if [[ -n "$huerfanos" ]]; then
        # shellcheck disable=SC2086
        sudo pacman -Rns --noconfirm $huerfanos
    else
        ok "No hay paquetes huérfanos."
    fi

    # En Arch/Manjaro samba y snmpd no traen archivo de configuración: se crea uno mínimo
    if [[ ! -f /etc/samba/smb.conf ]]; then
        info "Creando /etc/samba/smb.conf mínimo..."
        sudo mkdir -p /etc/samba
        sudo tee /etc/samba/smb.conf >/dev/null <<'EOF'
[global]
   workgroup = WORKGROUP
   server string = Samba Server
   server role = standalone server
   map to guest = Bad User
EOF
    fi
    if [[ ! -f /etc/snmp/snmpd.conf ]]; then
        info "Creando /etc/snmp/snmpd.conf mínimo (solo localhost)..."
        sudo mkdir -p /etc/snmp
        sudo tee /etc/snmp/snmpd.conf >/dev/null <<'EOF'
agentAddress udp:127.0.0.1:161
rocommunity public 127.0.0.1
EOF
    fi

    habilitar_servicios "${SRV_MANJARO[@]}"
    configurar_ufw
}

# ---------- Menú ----------
mostrar_menu() {
    local opciones=("" "Ubuntu" "Fedora" "Manjaro")

    echo -e "\n${NEGRITA}Instalador de aplicaciones${RESET}"
    if [[ "$RECOMENDADO" -ne 0 ]]; then
        echo -e "Sistema detectado: ${VERDE}${NOMBRE_SO}${RESET}\n"
    else
        warn "No se pudo identificar el sistema (${NOMBRE_SO}).\n"
    fi

    local i
    for i in 1 2 3; do
        if [[ "$i" -eq "$RECOMENDADO" ]]; then
            echo -e "  ${VERDE}$i) ${opciones[$i]}  (recomendado)${RESET}"
        else
            echo "  $i) ${opciones[$i]}"
        fi
    done
    echo "  0) Salir"
    echo
}

resumen() {
    echo
    echo -e "${NEGRITA}Resumen de servicios${RESET}"
    [[ ${#SRV_OK[@]} -gt 0 ]]    && ok "Activos: ${SRV_OK[*]}"
    [[ ${#SRV_FALLO[@]} -gt 0 ]] && warn "Con problemas: ${SRV_FALLO[*]}"
}

# ---------- Programa principal ----------
main() {
    if [[ $EUID -eq 0 ]]; then
        warn "Estás ejecutando como root; no es necesario, el script usa sudo."
    fi

    detectar_so
    mostrar_menu

    local prompt="Elige una opción"
    [[ "$RECOMENDADO" -ne 0 ]] && prompt+=" [${RECOMENDADO}]"
    read -rp "$prompt: " opcion
    opcion="${opcion:-$RECOMENDADO}"

    if [[ ! "$opcion" =~ ^[0-3]$ ]]; then
        error "Opción inválida."; exit 1
    fi
    [[ "$opcion" -eq 0 ]] && { echo "Saliendo."; exit 0; }

    # Advertir si la elección no coincide con el sistema detectado
    if [[ "$RECOMENDADO" -ne 0 && "$opcion" -ne "$RECOMENDADO" ]]; then
        warn "La opción elegida no coincide con el sistema detectado."
        read -rp "¿Continuar de todos modos? [s/N]: " conf
        [[ "${conf,,}" == "s" ]] || { echo "Cancelado."; exit 0; }
    fi

    case "$opcion" in
        1) instalar_ubuntu ;;
        2) instalar_fedora ;;
        3) instalar_manjaro ;;
    esac

    resumen
    echo
    ok "Instalación completada."
}

main "$@"
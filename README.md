<div align="center">

# 🐧 IniciarLinux

**Scripts para instalar herramientas y aplicar configuraciones en Ubuntu, Fedora y Manjaro.**

![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)
![Fedora](https://img.shields.io/badge/Fedora-51A2DA?style=for-the-badge&logo=fedora&logoColor=white)
![Manjaro](https://img.shields.io/badge/Manjaro-35BF5C?style=for-the-badge&logo=manjaro&logoColor=white)

![Bash](https://img.shields.io/badge/Bash-4EAA25?style=flat-square&logo=gnubash&logoColor=white)
![HTML5](https://img.shields.io/badge/HTML5-E34F26?style=flat-square&logo=html5&logoColor=white)
![CSS](https://img.shields.io/badge/CSS-663399?style=flat-square&logo=css&logoColor=white)
![systemd](https://img.shields.io/badge/systemd-requerido-2B2B2B?style=flat-square&logo=linux&logoColor=white)

![Último commit](https://img.shields.io/github/last-commit/PablitoMeenn/IniciarLinux?style=flat-square&label=%C3%BAltimo%20commit)
![Tamaño del repositorio](https://img.shields.io/github/repo-size/PablitoMeenn/IniciarLinux?style=flat-square&label=tama%C3%B1o)
![Lenguaje principal](https://img.shields.io/github/languages/top/PablitoMeenn/IniciarLinux?style=flat-square)

</div>

---

## 📑 Contenido

- [Tecnologías](#-tecnologías)
- [Requisitos](#-requisitos)
- [Uso recomendado](#-uso-recomendado)
- [Qué hace cada script](#-qué-hace-cada-script)
- [Paquetes](#-paquetes)
- [Firewall](#-firewall)
- [Estructura del proyecto](#-estructura-del-proyecto)
- [Después de copiar](#-después-de-copiar)

## 🧰 Tecnologías

**Servicios**

![Nginx](https://img.shields.io/badge/Nginx-009639?style=for-the-badge&logo=nginx&logoColor=white)
![OpenSSH](https://img.shields.io/badge/OpenSSH-1D1D1D?style=for-the-badge&logo=gnubash&logoColor=white)
![Samba](https://img.shields.io/badge/Samba-A80030?style=for-the-badge)
![Fail2ban](https://img.shields.io/badge/Fail2ban-C62828?style=for-the-badge)
![SNMP](https://img.shields.io/badge/SNMP-net--snmp-0A66C2?style=for-the-badge)

**Firewall**

![UFW](https://img.shields.io/badge/UFW-Ubuntu%20%C2%B7%20Manjaro-E95420?style=for-the-badge)
![firewalld](https://img.shields.io/badge/firewalld-Fedora-51A2DA?style=for-the-badge)

**Utilidades**

![Git](https://img.shields.io/badge/Git-F05032?style=flat-square&logo=git&logoColor=white)
![Vim](https://img.shields.io/badge/Vim-019733?style=flat-square&logo=vim&logoColor=white)
![curl](https://img.shields.io/badge/curl-073551?style=flat-square&logo=curl&logoColor=white)
![fastfetch](https://img.shields.io/badge/fastfetch-info%20del%20equipo-6E40C9?style=flat-square)
![btop](https://img.shields.io/badge/btop-monitoreo-6E40C9?style=flat-square)
![mtr](https://img.shields.io/badge/mtr-red-6E40C9?style=flat-square)
![cmatrix](https://img.shields.io/badge/cmatrix-terminal-6E40C9?style=flat-square)
![cifs-utils](https://img.shields.io/badge/cifs--utils-unidades%20de%20red-6E40C9?style=flat-square)

**Gestores de paquetes**

![apt](https://img.shields.io/badge/apt-Ubuntu-E95420?style=flat-square&logo=ubuntu&logoColor=white)
![dnf](https://img.shields.io/badge/dnf-Fedora-51A2DA?style=flat-square&logo=fedora&logoColor=white)
![pacman](https://img.shields.io/badge/pacman-Manjaro-35BF5C?style=flat-square&logo=manjaro&logoColor=white)

**Extras**

![Proxmox](https://img.shields.io/badge/Proxmox-filtros%20Fail2ban-E57000?style=flat-square&logo=proxmox&logoColor=white)
![qBittorrent](https://img.shields.io/badge/qBittorrent-TCP%2047379-2F67BA?style=flat-square&logo=qbittorrent&logoColor=white)
![LibreNMS](https://img.shields.io/badge/LibreNMS-extensi%C3%B3n%20distro-0A66C2?style=flat-square)

## ✅ Requisitos

- Una instalación actualizada de Ubuntu, Fedora o Manjaro con `systemd`.
- `bash`, acceso a Internet y permisos de administrador (`sudo`).
- Ejecutar los scripts desde una terminal local. La configuración SSH cambia opciones del servidor.

## 🚀 Uso recomendado

```bash
git clone https://github.com/PablitoMeenn/IniciarLinux.git
cd IniciarLinux
chmod +x instalarApp.sh copiarApp.sh
./instalarApp.sh
./copiarApp.sh
```

## ⚙️ Qué hace cada script

| Script | Función |
| --- | --- |
| [instalarApp.sh](instalarApp.sh) | Detecta la distribución, propone el perfil recomendado, instala los paquetes y habilita los servicios y el firewall. |
| [copiarApp.sh](copiarApp.sh) | Copia las configuraciones del proyecto a sus destinos y, de forma opcional, aplica las reglas del firewall. |

**`instalarApp.sh`** lee `/etc/os-release` y marca como recomendada la opción de tu sistema; las distribuciones derivadas (Mint, Pop!_OS, EndeavourOS, etc.) se asocian a Ubuntu, Fedora o Manjaro según corresponda. Si eliges un perfil distinto al detectado, pide confirmación antes de continuar. Al terminar muestra un resumen de los servicios activos y de los que tuvieron problemas.

**`copiarApp.sh`** requiere que el servidor OpenSSH esté instalado y ofrece dos opciones: aplicar las configuraciones junto con el firewall recomendado, o aplicarlas sin modificar el firewall. Esto es lo que copia:

| Componente | Origen | Destino |
| --- | --- | --- |
| SNMP | [snmpd/](snmpd/) | `/etc/snmp/snmpd.conf.d/snmp-server.conf` |
| Fail2ban | [fail2ban/](fail2ban/) | `/etc/fail2ban/` y `/etc/fail2ban/jail.d/ssh-server.conf` |
| SSH (servidor) | [ssh/ssh-servidor.conf](ssh/ssh-servidor.conf), [ssh/banner](ssh/banner) | `/etc/ssh/sshd_config.d/00-iniciarlinux.conf`, `/etc/ssh/banner` |
| SSH (cliente) | [ssh/config](ssh/config) | `~/.ssh/config` |
| Samba | [samba/smb.conf](samba/smb.conf) | `/etc/samba/smb.conf.d/smb-local.conf` |
| Nginx | [nginx/](nginx/) | `/var/www/html` (Ubuntu) o `/usr/share/nginx/html` (Fedora y Manjaro) |
| Alias de Bash | [home/.bash_aliases](home/.bash_aliases) | `~/.bash_aliases` |
| MOTD | [MOTD/](MOTD/) | `/etc/update-motd.d/` o `/etc/profile.d/` |
| UFW | [ufw/applications.d/qBittorrent](ufw/applications.d/qBittorrent) | `/etc/ufw/applications.d/qBittorrent` |

Los archivos de configuración del proyecto se escriben directamente en sus destinos. El contenido web se copia sin borrar otros archivos del directorio del sitio, y las configuraciones Samba y SNMP se agregan como fragmentos incluidos, sin vaciar las configuraciones existentes.

> [!WARNING]
> El script crea el usuario Samba `Carpeta` con una contraseña predefinida en [copiarApp.sh](copiarApp.sh) y comparte `/tmp/directorio-samba`. Cambia la contraseña con `sudo smbpasswd Carpeta` después de ejecutarlo.

## 📦 Paquetes

| Herramienta | Ubuntu | Fedora | Manjaro |
| --- | --- | --- | --- |
| Monitoreo y utilidades | `btop`, `cmatrix`, `fastfetch`\*, `mtr-tiny`, `vim` | `btop`, `cmatrix`, `fastfetch`, `mtr`, `vim` | `btop`, `cmatrix`, `fastfetch`, `mtr`, `vim` |
| Red y archivos compartidos | `cifs-utils`, `curl`, `git` | `cifs-utils`, `curl`, `git` | `cifs-utils`, `curl`, `git` |
| Servicios | `fail2ban`, `nginx`, `openssh-server`, `samba`, `snmpd` | `fail2ban`, `nginx`, `openssh-server`, `samba`, `net-snmp` | `fail2ban`, `nginx`, `openssh`, `samba`, `net-snmp` |
| Firewall recomendado | `ufw` | `firewalld` | `ufw` |

En Fedora, firewalld es el firewall nativo y no se instala UFW. Los nombres de paquetes pueden variar si se utilizan repositorios o versiones no estándar.

\* En Ubuntu, `fastfetch` se instala aparte porque no está en los repositorios de Ubuntu 24.04 LTS. Si no está disponible, el instalador continúa y muestra cómo agregarlo desde el PPA oficial del proyecto.

## 🔥 Firewall

El segundo script recomienda UFW en Ubuntu y Manjaro, y firewalld en Fedora. Puedes elegir no cambiar el firewall. Si aplicas las reglas, se permite lo siguiente y además se habilita e inicia el servicio SSH:

| Servicio | Regla |
| --- | --- |
| SSH | `OpenSSH` / `ssh` |
| Web | HTTP y HTTPS |
| Samba | `samba` |
| SNMP | 161/udp |
| qBittorrent | 47379/tcp |

> [!CAUTION]
> Comprueba las reglas antes de confirmar, especialmente si el equipo está expuesto a Internet o lo administras remotamente.

## 🗂️ Estructura del proyecto

```text
IniciarLinux/
├── instalarApp.sh      # Instala paquetes y habilita servicios
├── copiarApp.sh        # Copia configuraciones y configura el firewall
├── MOTD/               # Mensajes de inicio: información del equipo y estado de Fail2ban
├── fail2ban/           # Jails y configuración local de Fail2ban
├── home/               # Alias de Bash del usuario
├── nginx/              # Página de inicio (HTML y CSS)
├── samba/              # Recurso compartido de Samba
├── snmpd/              # Configuración del agente SNMP
├── ssh/                # Configuración del servidor, del cliente y banner
├── ufw/                # Perfil de aplicación de qBittorrent
└── _Otros/             # Notas de post-instalación y filtros Fail2ban para Proxmox
```

## 🔍 Después de copiar

El script valida la configuración de SSH con `sshd -t` y, si no es válida, retira el fragmento agregado. Si eliges aplicar las reglas del firewall, también habilita e inicia el servicio SSH; con la opción de no modificar el firewall, no lo inicia. Revisa los archivos y el estado con `systemctl status`.

Al terminar, el script ejecuta `fastfetch` para mostrar las características del equipo (sistema, kernel, CPU, memoria, discos, etc.).

> [!TIP]
> Conserva una sesión de administración abierta al probar SSH o firewall para evitar perder acceso.

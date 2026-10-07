# IniciarLinux

Scripts para instalar herramientas y aplicar configuraciones en Ubuntu, Fedora y Manjaro.

## Requisitos

- Una instalación actualizada de Ubuntu, Fedora o Manjaro con `systemd`.
- `bash`, acceso a Internet y permisos de administrador (`sudo`).
- Ejecutar los scripts desde una terminal local. La configuración SSH cambia opciones del servidor.

## Uso recomendado

```bash
git clone https://github.com/PablitoMeenn/IniciarLinux.git
cd IniciarLinux
chmod +x instalarApp.sh copiarApp.sh
./instalarApp.sh
./copiarApp.sh
```

El instalador detecta la distribución, muestra los paquetes compatibles y propone el perfil recomendado. También permite elegir paquetes individualmente y pide confirmación antes de instalar. Para aplicar todo el conjunto de configuraciones, utiliza el perfil recomendado; el copiado requiere que el servidor OpenSSH y el firewall de la distribución estén instalados.

El segundo script recomienda UFW en Ubuntu y Manjaro, y firewalld en Fedora. Puedes elegir no cambiar el firewall. Si aplicas las reglas, se permiten SSH, web, Samba, SNMP y el puerto TCP 47379 de qBittorrent; además, se habilita e inicia el servicio SSH. Comprueba las reglas antes de confirmar, especialmente si el equipo está expuesto a Internet o lo administras remotamente.

Los archivos de configuración del proyecto se escriben directamente en sus destinos. El contenido web se copia sin borrar otros archivos del directorio del sitio, y las configuraciones Samba y Fail2ban se agregan sin vaciar las configuraciones existentes.

## Paquetes

| Herramienta | Ubuntu | Fedora | Manjaro |
| --- | --- | --- | --- |
| Monitoreo y utilidades | `btop`, `cmatrix`, `mtr`, `vim` | `btop`, `cmatrix`, `mtr`, `vim` | `btop`, `cmatrix`, `mtr`, `vim` |
| Red y archivos compartidos | `cifs-utils`, `curl`, `git` | `cifs-utils`, `curl`, `git` | `cifs-utils`, `curl`, `git` |
| Servicios | `fail2ban`, `nginx`, `openssh-server`, `samba`, `snmpd` | `fail2ban`, `nginx`, `openssh-server`, `samba`, `net-snmp` | `fail2ban`, `nginx`, `openssh`, `samba`, `net-snmp` |
| Firewall recomendado | `ufw` | `firewalld` | `ufw` |

En Fedora, firewalld es el firewall nativo y no se instala UFW. Los nombres de paquetes pueden variar si se utilizan repositorios o versiones no estándar; revisa la lista que muestra el instalador antes de confirmar.

## Después de copiar

El script valida la configuración de SSH. Si eliges aplicar las reglas del firewall, también habilita e inicia el servicio SSH; con la opción de no modificar el firewall, no lo inicia. Revisa los archivos y el estado con `systemctl status`. Conserva una sesión de administración abierta al probar SSH o firewall para evitar perder acceso.
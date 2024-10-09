# Plugins de Nagios

## Plugin de Nagios para Monitoreo de Memoria en Linux

### Descripción

Este plugin de Nagios está diseñado para monitorear y reportar el uso de memoria y swap en sistemas operativos Linux. Proporciona información detallada sobre la memoria total, usada y libre, así como el uso de swap, permitiendo a los administradores de sistemas detectar problemas de rendimiento y gestionar mejor los recursos del sistema.

### Características

- **Monitoreo de Memoria**: Mide el uso de la memoria RAM en tiempo real, incluyendo el total, el usado, el libre y el caché.
- **Monitoreo de Swap**: Proporciona datos sobre el uso de la memoria swap, ayudando a identificar cuándo el sistema está utilizando swap en exceso, lo cual puede indicar problemas de rendimiento.
- **Umbrales Configurables**: Permite establecer umbrales de advertencia y críticos para el uso de memoria y swap, enviando alertas a Nagios si se superan.
- **Soporte para Unidades**: Permite seleccionar entre mostrar el uso de memoria en megabytes (MB) o gigabytes (GB).
- **Salida Formateada**: Genera una salida clara y estructurada que puede ser fácilmente interpretada por Nagios.

### Requisitos

- **Perl**: Este script requiere Perl 5.10 o superior.
- **Sistema Operativo**: Debe ejecutarse en un sistema Linux con acceso a `/proc/meminfo`.
- **Nagios**: Debe estar configurado para ejecutar scripts de plugins.

### Instalación

1. **Clonar el Repositorio**:
   ```bash
   git clone https://github.com/tu_usuario/tu_repositorio.git
   cd tu_repositorio

   Dar Permisos de Ejecución: Asegúrate de que el script tenga permisos de ejecución:

2. **Dar permiso al Script**:
`chmod +x check_memory.pl`

4. **Mover Script a la carpeta de Plugins**:
Mover el Script a la Carpeta de Plugins de Nagios: Mueve el script a la carpeta de plugins de Nagios, generalmente ubicada en /usr/lib/nagios/plugins/:
`sudo mv check_memory.pl /usr/lib/nagios/plugins/`

### Uso

El script se puede ejecutar directamente desde la línea de comandos o configurarse como un comando en Nagios.
`check_memory.pl -w {advertencia} -c {crítico} -W {advertencia} -C {crítico} -u {unidad}`

Opciones
-w {advertencia}: Establecer el valor de advertencia para el uso de memoria (por defecto: 95%).
-c {crítico}: Establecer el valor crítico para el uso de memoria (por defecto: 98%).
-W {advertencia}: Establecer el valor de advertencia para el uso de swap (por defecto: 95%).
-C {crítico}: Establecer el valor crítico para el uso de swap (por defecto: 98%).
-u {unidad}: Establecer la unidad de medida (MB o GB, por defecto: MB).
-h: Muestra el mensaje de ayuda.

Ejemplo de Uso
Para ejecutar el script y verificar el uso de memoria y swap, puedes usar el siguiente comando:

`/usr/lib/nagios/plugins/check_memory.pl -w 80 -c 90 -W 40 -C 60 -u GB`

Este comando configurará los umbrales de advertencia y crítico para el uso de memoria y swap, mostrando los resultados en gigabytes.

### Integración con Nagios
Para integrar este script en Nagios, puedes definir un nuevo comando en el archivo de configuración de Nagios (commands.cfg):

`define command {
    command_name    check_memory
    command_line    /usr/lib/nagios/plugins/check_memory.pl -w $ARG1$ -c $ARG2$ -W $ARG3$ -C $ARG4$ -u $ARG5$
}`

Luego, puedes usar este comando en la definición de un servicio en tu archivo de configuración de servicios:

`define service {
    use                 generic-service
    host_name           tu_host
    service_description Memoria y Swap
    check_command       check_memory!80!90!40!60!GB
}`

### Salida del Script
La salida del script está diseñada para ser compatible con Nagios. Se presenta en el siguiente formato:

`[MEMORIA] Total: X GB - Usado: Y GB - Z% [SWAP] Total: A GB - Usado: B GB - C% | MTOTAL=D;;;; MUSED=E;;;; STOTAL=F;;;; SUSED=G;;;;
Donde X, Y, Z, A, B, C, D, E, F y G representan los valores correspondientes de memoria y swap.`

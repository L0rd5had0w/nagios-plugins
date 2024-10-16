# Plugins de Nagios

## Plugin de Nagios para Monitoreo de Bloqueos en BD SQL Server

### Descripción

El plugin `check_mssql_lock` es una herramienta diseñada para monitorear bloqueos en bases de datos Microsoft SQL Server (MSSQL). Este plugin permite a los administradores de sistemas detectar y gestionar bloqueos que pueden afectar el rendimiento de la base de datos, proporcionando información crítica sobre el estado de las conexiones y los bloqueos activos.

### Características

- **Monitoreo de Bloqueos**: Verifica el número de bloqueos activos en la base de datos.
- **Umbrales Configurables**: Permite establecer umbrales de advertencia y crítico para el número de bloqueos.
- **Salida Formateada**: Genera una salida compatible con Nagios, facilitando la integración en sistemas de monitoreo.

### Requisitos

- **Perl**: Este script requiere Perl 5.10 o superior.
- **Módulo DBD::ODBC**: Necesario para la conexión a bases de datos MSSQL.
- **Acceso a la Base de Datos**: Credenciales válidas para conectarse a la base de datos MSSQL.

### Instalación

1. **Instalar Dependencias**:
   Asegúrate de tener instalado el módulo `DBD::ODBC`:
   ```bash
   cpan DBD::ODBC

Tomar en cuenta que hay que instalar el Driver de SQL Server para el ODBC, revisar el siguiente enlace:

[Instalación del controlador ODBC de Microsoft para SQL Server](https://learn.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server?view=sql-server-ver16&tabs=ubuntu18-install%2Cubuntu17-install%2Cubuntu16-install%2Cubuntu16-13-install%2Cubuntu-offline)

Actualizar el Script con la versión de Driver que se tenga instalada.

![image](https://github.com/user-attachments/assets/ab198420-e5fd-47e7-ba5a-cebc216bb517)


2. **Clonar el Repositorio**:
   ```bash
   git clone https://github.com/tu_usuario/tu_repositorio.git
   cd tu_repositorio

   Dar Permisos de Ejecución: Asegúrate de que el script tenga permisos de ejecución:

3. **Dar permiso al Script**:
`chmod +x check_mssql_lock.pl`

4. **Mover Script a la carpeta de Plugins**:
Mover el Script a la Carpeta de Plugins de Nagios: Mueve el script a la carpeta de plugins de Nagios, generalmente ubicada en /usr/lib/nagios/plugins/:
`sudo mv check_mssql_lock.pl /usr/lib/nagios/plugins/`

### Uso

El script se puede ejecutar directamente desde la línea de comandos o configurarse como un comando en Nagios.
`check_mssql_lock.pl -s SERVER_NAME -d DATABASE_NAME -u USERNAME -p PASSWORD [-t umbral]`

Opciones
-s SERVER_NAME: Nombre del servidor MSSQL.
-d DATABASE_NAME: Nombre de la base de datos.
-u USERNAME: Nombre de usuario para la conexión.
-p PASSWORD: Contraseña para la conexión.
-t umbral: Número de bloqueos a partir del cual se considera crítico (por defecto: 5).
-h: Muestra el mensaje de ayuda.

### Integración con Nagios
Para integrar este script en Nagios, puedes definir un nuevo comando en el archivo de configuración de Nagios (commands.cfg):

`define command {
    command_name    check_mssql_locks
    command_line    /usr/lib/nagios/plugins/check_mssql_lock.pl -s $ARG1$ -d $ARG2$ -u $ARG3$ -p $ARG4$ -t $ARG5$
}
`

Luego, puedes usar este comando en la definición de un servicio en tu archivo de configuración de servicios:

`define service {
    use                 generic-service
    host_name           tu_host
    service_description Bloqueos MSSQL
    check_command       check_mssql_locks!SERVER_NAME!DATABASE_NAME!USERNAME!PASSWORD!5
}
`

### Salida del Script
La salida del script está diseñada para ser compatible con Nagios. Se presenta en el siguiente formato:

`[BLOCKED] Total: X | bloqueos=Y;;;;`
   
## Plugin de Nagios para Monitoreo de Memoria en Linux

### Descripción

Este plugin de Nagios está diseñado para monitorear y reportar el uso de memoria y swap en sistemas operativos Linux. Proporciona información detallada sobre la memoria total, usada y libre, así como el uso de swap, permitiendo a los administradores de sistemas detectar problemas de rendimiento y gestionar mejor los recursos del sistema.

Este Plugin, es basado en el trabajo de Lukasz Golodin, lukasz.gogolin@gmail.com.

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

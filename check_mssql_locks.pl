#!/usr/bin/perl

use strict;
use warnings;
use DBI;
use Getopt::Long;

# Variables de conexión
my ($server_name, $database_name, $username, $password, $threshold) = (undef, undef, undef, undef, 5);

# Opciones de línea de comandos
GetOptions(
    's=s' => \$server_name,
    'd=s' => \$database_name,
    'u=s' => \$username,
    'p=s' => \$password,
    't=i' => \$threshold,
    'h'   => sub { print_help(); exit 0; },
) or die "Error en los argumentos. Usa -h para ayuda.";

# Validar que se proporcionen los parámetros necesarios
die "Error: Se requiere SERVER_NAME, DATABASE_NAME, USERNAME y PASSWORD.\n" 
    unless defined $server_name && defined $database_name && defined $username && defined $password;

# Configuración del DSN
my $dsn = "DBI:ODBC:Driver={ODBC Driver 17 for SQL Server};Server=$server_name;Database=$database_name;";

# Conectar a la base de datos
my $dbh = DBI->connect($dsn, $username, $password, { RaiseError => 1, PrintError => 0 })
    or die "No se pudo conectar a la base de datos: $DBI::errstr";

# Consulta para verificar bloqueos
my $sql = "
    SELECT COUNT(*) AS Bloqueos
    FROM sys.dm_exec_requests AS r
    JOIN sys.dm_exec_sessions AS s ON r.session_id = s.session_id
    WHERE r.blocking_session_id <> 0
    AND DATEDIFF(minute, s.last_request_start_time, GETDATE()) >= 2;
";

my $sth = $dbh->prepare($sql);
$sth->execute();

my ($bloqueos) = $sth->fetchrow_array();
$sth->finish();
$dbh->disconnect();

# Generar mensaje de salida
if ($bloqueos > $threshold) {
    print "CRITICAL: $bloqueos bloqueos activos | bloqueos=$bloqueos\n";
    exit 2;  # Estado crítico
} elsif ($bloqueos > 0) {
    print "WARNING: $bloqueos bloqueos activos | bloqueos=$bloqueos\n";
    exit 1;  # Estado de advertencia
} else {
    print "OK: No hay bloqueos activos | bloqueos=$bloqueos\n";
    exit 0;  # Estado OK
}

# Función de ayuda
sub print_help {
    print "Uso: $0 -s SERVER_NAME -d DATABASE_NAME -u USERNAME -p PASSWORD [-t umbral] [-h]\n";
    print "Monitorea bloqueos en bases de datos MSSQL.\n";
    print "-s SERVER_NAME: Nombre del servidor MSSQL\n";
    print "-d DATABASE_NAME: Nombre de la base de datos\n";
    print "-u USERNAME: Nombre de usuario para la conexión\n";
    print "-p PASSWORD: Contraseña para la conexión\n";
    print "-t umbral: Número de bloqueos a partir del cual se considera crítico (default: 5)\n";
    print "-h: Muestra esta ayuda\n";
}

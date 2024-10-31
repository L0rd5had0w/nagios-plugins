#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

# Establecer valores predeterminados
my $optW = 80;  # Umbral de advertencia para el uso de CPU
my $optC = 90;  # Umbral crítico para el uso de CPU

# Función de ayuda
sub printHelp {
    print "\nAyuda para $0\n";
    print "Uso básico: $0 -w {advertencia} -c {crítico}\n";
    print "Los conmutadores de comando son opcionales, los valores predeterminados para advertencia son 80% y crítico son 90%\n";
    print "-w - Establece el valor de advertencia para el uso de CPU. Predeterminado es 80%\n";
    print "-c - Establece el valor crítico para el uso de CPU. Predeterminado es 90%\n";
    print "-h  - Muestra este mensaje de ayuda\n";
    print "Ejemplo: $0 -w 75 -c 85\n";
    exit 1;
}

# Validar umbrales
sub validateThreshold {
    my ($threshold) = @_;
    if ($threshold !~ /^[0-9]+$/ || $threshold < 0 || $threshold > 100) {
        die "error: El umbral debe ser un número entre 0 y 100\n";
    }
}

# Leer información de uso de CPU desde /proc/stat
sub readCpuUsage {
    open my $fh, '<', '/proc/stat' or die "error: No se pudo abrir /proc/stat: $!\n";
    my $line = <$fh>;
    close $fh;

    my @fields = split ' ', $line;
    my $user = $fields[1];
    my $nice = $fields[2];
    my $system = $fields[3];
    my $idle = $fields[4];
    my $iowait = $fields[5];
    my $irq = $fields[6];
    my $softirq = $fields[7];

    my $total = $user + $nice + $system + $idle + $iowait + $irq + $softirq;
    my $cpu_used = 100 * ($total - $idle) / $total;  # Calcular el uso de CPU
    my $cpu_available = 100 - $cpu_used;  # Calcular CPU disponible
    return ($total, $cpu_used, $cpu_available);  # Retornar total, usado y disponible
}

# Preparar mensaje de salida
sub prepareOutputMessage {
    my ($cpuTotal, $cpuUsed, $cpuAvailable) = @_;
    return sprintf("Uso de CPU: %.2f%% en uso, %.2f%% disponible", $cpuUsed, $cpuAvailable);
}

# Verificar umbrales y salir con el estado apropiado
sub checkThresholds {
    my ($cpuUsagePercent, $message) = @_;
    if ($cpuUsagePercent >= $optC) {
        print "$message\n";
        exit 2;  # Estado crítico
    } elsif ($cpuUsagePercent >= $optW) {
        print "$message\n";
        exit 1;  # Estado de advertencia
    } else {
        print "$message\n";
        exit 0;  # Estado OK
    }
}

# Procesar argumentos
GetOptions(
    'w=i' => \$optW,
    'c=i' => \$optC,
    'h'   => \&printHelp,
) or printHelp();

# Validar umbrales
validateThreshold($optW);
validateThreshold($optC);

# Leer información de uso de CPU
my ($cpuTotal, $cpuUsed, $cpuAvailable) = readCpuUsage();

# Preparar mensaje de salida
my $message = prepareOutputMessage($cpuTotal, $cpuUsed, $cpuAvailable);

# Verificar umbrales y salir con el estado apropiado
checkThresholds($cpuUsed, $message);

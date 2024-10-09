#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

# Establecer valores predeterminados
my $optMW = 95;  # Umbral de advertencia para el uso de memoria
my $optMC = 98;  # Umbral crítico para el uso de memoria
my $optSW = 95;  # Umbral de advertencia para el uso de swap
my $optSC = 98;  # Umbral crítico para el uso de swap
my $unit = "MB"; # Unidad de medida predeterminada

# Función de ayuda
sub printHelp {
    print "\nAyuda para $0\n";
    print "Uso básico: $0 -w {advertencia} -c {crítico} -W {advertencia} -C {crítico} -u {unidad}\n";
    print "Los conmutadores de comando son opcionales, los valores predeterminados para advertencia son 95% y crítico son 98%\n";
    print "-w - Establece el valor de advertencia para el uso de memoria. Predeterminado es 95%\n";
    print "-c - Establece el valor crítico para el uso de memoria. Predeterminado es 98%\n";
    print "-W - Establece el valor de advertencia para el uso de swap. Predeterminado es 95%\n";
    print "-C - Establece el valor crítico para el uso de swap. Predeterminado es 98%\n";
    print "-u - Establece la unidad de medida (MB o GB). Predeterminado es MB\n";
    print "-h  - Muestra este mensaje de ayuda\n";
    print "Ejemplo: $0 -w 80 -c 90 -W 40 -C 60 -u GB\n";
    exit 1;
}

# Validar umbrales
sub validateThreshold {
    my ($threshold) = @_;
    if ($threshold !~ /^[0-9]+$/ || $threshold < 0 || $threshold > 100) {
        die "error: El umbral debe ser un número entre 0 y 100\n";
    }
}

# Leer información de memoria y swap
sub readMemorySwapInfo {
    my %meminfo;
    open my $fh, '<', '/proc/meminfo' or die "No se puede abrir /proc/meminfo: $!";
    while (<$fh>) {
        if (/^MemTotal:\s+(\d+)/) {
            $meminfo{total} = $1;
        } elsif (/^MemFree:\s+(\d+)/) {
            $meminfo{free} = $1;
        } elsif (/^Buffers:\s+(\d+)/) {
            $meminfo{buffers} = $1;
        } elsif (/^Cached:\s+(\d+)/) {
            $meminfo{cached} = $1;
        } elsif (/^SwapTotal:\s+(\d+)/) {
            $meminfo{swap_total} = $1;
        } elsif (/^SwapFree:\s+(\d+)/) {
            $meminfo{swap_free} = $1;
        }
    }
    close $fh;
    return \%meminfo;
}

# Calcular el uso de memoria
sub calculateMemoryUsage {
    my ($meminfo) = @_;
    my $memTotal_b = $meminfo->{total} * 1024;
    my $memFree_b = $meminfo->{free} * 1024;
    my $memBuffer_b = $meminfo->{buffers} * 1024;
    my $memCache_b = $meminfo->{cached} * 1024;
    my $memUsed_b = $memTotal_b - $memFree_b - $memBuffer_b - $memCache_b;
    my $memUsedPrc = int(($memUsed_b * 100) / $memTotal_b);
    return ($memTotal_b, $memUsed_b, $memUsedPrc);
}

# Calcular el uso de swap
sub calculateSwapUsage {
    my ($meminfo) = @_;
    my $swapTotal_b = $meminfo->{swap_total} * 1024;
    my $swapFree_b = $meminfo->{swap_free} * 1024;
    my $swapUsed_b = ($meminfo->{swap_total} - $meminfo->{swap_free}) * 1024;
    my $swapUsedPrc = $swapTotal_b == 0 ? 0 : int(($swapUsed_b * 100) / $swapTotal_b);
    return ($swapTotal_b, $swapUsed_b, $swapUsedPrc);
}

# Preparar mensaje de salida
sub prepareOutputMessage {
    my ($memTotal_b, $memUsed_b, $memUsedPrc, $swapTotal_b, $swapUsed_b, $swapUsedPrc) = @_;
    my $memTotal_m = $unit eq "GB" ? $memTotal_b / (1024 * 1024) : $memTotal_b / 1024;
    my $memUsed_m = $unit eq "GB" ? $memUsed_b / (1024 * 1024) : $memUsed_b / 1024;
    my $swapTotal_m = $unit eq "GB" ? $swapTotal_b / (1024 * 1024) : $swapTotal_b / 1024;
    my $swapUsed_m = $unit eq "GB" ? $swapUsed_b / (1024 * 1024) : $swapUsed_b / 1024;

    return "[MEMORIA] Total: $memTotal_m $unit - Usado: $memUsed_m $unit - $memUsedPrc% [SWAP] Total: $swapTotal_m $unit - Usado: $swapUsed_m $unit - $swapUsedPrc% | MTOTAL=$memTotal_b;;;; MUSED=$memUsed_b;;;; STOTAL=$swapTotal_b;;;; SUSED=$swapUsed_b;;;;";
}

# Verificar umbrales y salir con el estado apropiado
sub checkThresholds {
    my ($memUsedPrc, $swapUsedPrc, $message) = @_;
    if ($memUsedPrc >= $optMC || $swapUsedPrc >= $optSC) {
        print "$message\n";
        exit 2;
    } elsif ($memUsedPrc >= $optMW || $swapUsedPrc >= $optSW) {
        print "$message\n";
        exit 1;
    } else {
        print "$message\n";
        exit 0;
    }
}

# Procesar argumentos
GetOptions(
    'w=i' => \$optMW,
    'c=i' => \$optMC,
    'W=i' => \$optSW,
    'C=i' => \$optSC,
    'u=s' => \$unit,
    'h'   => \&printHelp,
) or printHelp();

# Validar umbrales
validateThreshold($optMW);
validateThreshold($optMC);
validateThreshold($optSW);
validateThreshold($optSC);

# Validar unidad
if ($unit ne "MB" && $unit ne "GB") {
    die "error: Unidad no válida. Use MB o GB.\n";
}

# Leer información de memoria y swap
my $meminfo = readMemorySwapInfo();

# Calcular el uso de memoria
my ($memTotal_b, $memUsed_b, $memUsedPrc) = calculateMemoryUsage($meminfo);

# Calcular el uso de swap
my ($swapTotal_b, $swapUsed_b, $swapUsedPrc) = calculateSwapUsage($meminfo);

# Preparar mensaje de salida
my $message = prepareOutputMessage($memTotal_b, $memUsed_b, $memUsedPrc, $swapTotal_b, $swapUsed_b, $swapUsedPrc);

# Verificar umbrales y salir con el estado apropiado
checkThresholds($memUsedPrc, $swapUsedPrc, $message);

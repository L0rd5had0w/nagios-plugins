#!/usr/bin/env perl

use strict;
use warnings;
use JSON;
use LWP::UserAgent;
use Getopt::Long;

# Clase para manejar la creación de mensajes
package MessageBuilder {
    sub new {
        my ($class) = @_;
        return bless {}, $class;
    }

    sub create_message {
        my ($self, $subject, $output, $long_message) = @_;
        
        my %message = (
            summary => $subject,
            title   => $subject,
            text    => $output,
            '@type' => 'MessageCard',
            '@context' => 'https://schema.org/extensions',
        );

        # Agregar el mensaje largo si se proporciona
        $message{text} .= "\n\n" . $long_message if $long_message;

        return \%message;
    }
}

# Clase para manejar el envío de mensajes a Microsoft Teams
package TeamsNotifier {
    sub new {
        my ($class, $url) = @_;
        my $self = {
            url => $url,
            ua  => LWP::UserAgent->new,
        };
        return bless $self, $class;
    }

    sub send {
        my ($self, $message_json) = @_;
        
        my $response = $self->{ua}->post($self->{url}, Content_Type => 'application/json', Content => $message_json);

        if ($response->is_success) {
            print "Notificación enviada con éxito.\n";
            return 1;
        } else {
            warn "Error al enviar la notificación: " . $response->status_line . "\n";
            return 0;
        }
    }
}

# Función principal para ejecutar el script
sub main {
    my ($url, $subject, $output, $long_message) = @_;

    # Validar URL
    die "Error: No se proporcionó la URL.\n" unless $url;

    my $message_builder = MessageBuilder->new();
    my $message_dict = $message_builder->create_message($subject, $output, $long_message);
    my $message_json = encode_json($message_dict);

    my $notifier = TeamsNotifier->new($url);
    $notifier->send($message_json);
}

# Análisis de argumentos de línea de comandos
my ($subject, $output, $url, $help);
GetOptions(
    'subject=s' => \$subject,
    'output=s'  => \$output,
    'url=s'     => \$url,
    'help'      => \$help,
) or die "Error en los argumentos de línea de comandos.\n";

# Mostrar ayuda si se solicita
if ($help) {
    print "Uso: $0 --subject <asunto> --output <salida> --url <url>\n";
    print "Envía notificaciones a Microsoft Teams usando WebHooks.\n";
    print "\nOpciones:\n";
    print "  --subject    Asunto del mensaje.\n";
    print "  --output     Salida a incluir en el mensaje.\n";
    print "  --url        URL del WebHook de Microsoft Teams.\n";
    print "  --help       Muestra esta ayuda.\n";
    exit(0);
}

# Leer el mensaje largo desde STDIN si está disponible
my $long_message = do { local $/; -t STDIN ? '' : <STDIN> };

# Llamar a la función principal
main($url, $subject, $output, $long_message);

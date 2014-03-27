package Supervisord::Client;
use strict;
use warnings;
use LWP::Protocol::http::SocketUnixAlt;
use RPC::XML::Client;
use Moo::Lax;
use Carp;
use Safe::Isa;
use Config::INI::Reader;

LWP::Protocol::implementor(
    supervisorsocketunix => 'LWP::Protocol::http::SocketUnixAlt' );

has path_to_supervisor_config => (
    is       => 'ro',
    required => 0,
);

has serverurl => (
    is       => 'ro',
    required => 0,
);

has rpc        => ( is => 'lazy' );
has _serverurl => ( is => 'lazy' );

sub _build__serverurl {
    my $self = shift;
    return $self->serverurl if $self->serverurl;
    my $hash =
      Config::INI::Reader->read_file( $self->path_to_supervisor_config );
    return $hash->{supervisorctl}{serverurl}
      || croak "couldnt find serverurl in supervisorctl section of "
      . $self->path_to_supervisor_config;
}

sub _build_rpc {
    my $self = shift;
    my $url  = $self->_serverurl;
    $url =~ s|unix://|supervisorsocketunix:|g;
    $url .= "//RPC2";
    my $cli = RPC::XML::Client->new($url);
}

sub BUILD {
    my $self = shift;
    $self->path_to_supervisor_config
      || $self->serverurl
      || croak "path_to_supervisor_config or serverurl required.";
}

our $AUTOLOAD;

sub AUTOLOAD {
    my $remote_method = $AUTOLOAD;
    $remote_method =~ s/.*:://;
    my ( $self, @args ) = @_;
    my $ret = $self->rpc->send_request( "supervisor.$remote_method", @args );
    return $ret->value if $ret->$_can("value");
}

1;

=head1 NAME

Supervisord::Client - a perl client for Supervisord's XMLRPC.

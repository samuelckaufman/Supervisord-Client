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
    $self->send_rpc_request("supervisor.$remote_method", @args );
}
sub send_rpc_request {
    my( $self, @params ) = @_;
    my $ret = $self->rpc->send_request( @params );
    return $ret->value if $ret->$_can("value");
}

1;

=head1 NAME

Supervisord::Client - a perl client for Supervisord's XMLRPC.

=head1 SYNOPSIS

    my $client = Supervisord::Client->new( serverurl => "unix:///tmp/socky.sock" );
    #or
    my $client = Supervisord::Client->new( path_to_supervisor_config => "/etc/supervisor/supervisor.conf" );
    warn $_->{description} for(@{ client->getAllProcessInfo });
    #or
    warn $_->{description} for(@{ client->send_rpc_request("supervisor.getAllProcessInfo") });

=head1 DESCRIPTION

This module is for people who are using supervisord (  L<http://supervisord.org/> ) to manage their daemons,
and are using the unix socket form of the RPC ( as opposed to http server ).
This module will work with either, but really you're not getting much vs L<RPC::XML::Client> for the http version;
the http over Unix socket part is where this module comes in handy.
See L<http://supervisord.org/api.html> for the API docs.

=head1 METHODS

=head2 new

Constructor, provided by Moo.

=head2 rpc

Access to the RPC::XML::Client object.

=head2 send_rpc_request( remote_method, @params )

=head2 AUTOLOAD

This module uses AUTOLOAD to proxy calls to send_rpc_request. See synopsis for examples.

=head1 CONSTRUCTOR PARAMETERS

=over

=item path_to_supervisor_config

optional - ex: /tmp/super.sock

=item serverurl

optional - in supervisor format, ex: unix:///tmp.super.sock

One of the two is required.

=back

=head1 LICENSE

This library is free software and may be distributed under the same terms as perl itself.

=head1 AUTHOR

Samuel Kaufman L<skaufman@cpan.org>


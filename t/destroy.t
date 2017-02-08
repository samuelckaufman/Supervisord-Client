use strict;
use warnings;
use Test::More;
plan tests => 1;

use Supervisord::Client;

BEGIN {
    package Test::RPC::XML::Client;
    sub new {
        bless {}, shift;
    }

    sub send_request {
        my $self   = shift;
        my $method = shift;
        push @{$self->{requests}}, $method;
    }
}

my $rpc = Test::RPC::XML::Client->new;

{
    my $client = Supervisord::Client->new(
        serverurl => 'http://supervisor:9001',
        rpc       => $rpc,
    );

    $client->getAllProcessInfo;
}

is_deeply(
    $rpc->{requests},
    ['supervisor.getAllProcessInfo'],
    'object destruction does not result in RPC call to supervisor.DESTROY'
);

done_testing;

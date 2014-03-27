use strict;
use warnings FATAL => 'all';
use Supervisord::Client;
my $client = Supervisord::Client->new( path_to_supervisor_config => $ARGV[0] );
warn $client->getAllProcessInfo;

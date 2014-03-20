use strict;
use warnings FATAL => 'all';
use LWP::Protocol::http::SocketUnix;
use LWP::UserAgent;
use Data::Dumper::Concise;
use RPC::XML::Client;
LWP::Protocol::implementor( file => 'LWP::Protocol::http::SocketUnix' );
#my $ua = LWP::UserAgent->new;
my $path = "file:///home/skaufman/dev/Supervisord-Client/example/supervisor.sock";
my $cli = RPC::XML::Client->new($path);
#my $resp = $cli->send_request('supervisor.getVersion');
my $resp = $cli->send_request('supervisor.getAllProcessInfo');
warn Dumper $resp->value;
#my $req =
#"POST /RPC2 HTTP/1.1\r\nHost: localhost\r\nAccept-Encoding: identity\r\nContent-Length: 115\r\nContent-Type: text/xml\r\nAccept: text/xml\r\nUser-Agent: xmlrpclib.py/1.0.1 (by www.pythonware.com)\r\n\r\n<?xml version='1.0'?>\n<methodCall>\n<methodName>supervisor.getVersion</methodName>\n<params>\n</params>\n</methodCall>\n";

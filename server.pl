#!usr/bin/perl

use warnings;
use strict;

use IO::Socket::INET;
use utf8;

$| = 1;

print 'WebServices Server app'."\n";
print '---'."\n\n";



# CONFIG

# Listen on this IP and PORT. Use 0.0.0.0 to listen on all network adapters.
my($SERVER_IP) = '0.0.0.0';
my($SERVER_PORT) = '1337';

# Example request=>responses
my(%SERVER_RESPONSE) = (
	'1000'=>'1010',
	'2000'=>'2010',
	'3000'=>'3010');

# /CONFIG



# creating a listening socket
my($SERVER_SOCKET) = new IO::Socket::INET (
    LocalHost => $SERVER_IP,
    LocalPort => $SERVER_PORT,
    Proto => 'tcp',
    Listen => 5,
    Reuse => 1);
die 'Cannot create socket '.$!."\n" unless $SERVER_SOCKET;

my($CLIENT_PORT,$CLIENT_IP,$CLIENT_SOCKET,$client_data);
my($proxy_request,$proxy_request_url,$proxy_request_auth);

while (1) {
	
	print 'Waiting for new connection on port '.$SERVER_PORT.'...'."\n";
	$client_data = ServerReceive();
	ServerRespond(ResponseGen($client_data));
	print '---'."\n\n";
	
}

$SERVER_SOCKET->close();

exit;



sub ServerReceive {
    $CLIENT_SOCKET = $SERVER_SOCKET->accept();
    $CLIENT_IP = $CLIENT_SOCKET->peerhost();
    $CLIENT_PORT = $CLIENT_SOCKET->peerport();
    print '  Connection from client '.$CLIENT_IP.':'.$CLIENT_PORT."\n";

    # read up to 4096 characters from the connected client
	my($client_data) = '';
    $CLIENT_SOCKET->recv($client_data, 4096);
	
	# Remove trailing junk, eg. CR or LF
	$client_data =~ s/[\r\n]$//g;

	open(FILE,'>server.log');
	print FILE "\n".'////////// RECEIVED FROM CLIENT //////////'."\n";
	print FILE $client_data;
	close(FILE);
    print '    received data from '.$CLIENT_IP.':'.$CLIENT_PORT."\n";
	
	return($client_data);
}



sub ServerRespond {
	my($rdata) = @_;

	# write response data to the connected client
    print '  Replying to client '.$CLIENT_IP.':'.$CLIENT_PORT;
    my($client_size) = $CLIENT_SOCKET->send($rdata);
	open(FILE,'>>server.log');
	print FILE "\n".'////////// SENT TO CLIENT //////////'."\n";
	print FILE $rdata;
	close(FILE);
	print ', sent data of length '.$client_size."\n";

    # notify client that response has been sent
	$CLIENT_SOCKET->shutdown(SHUT_RDWR);
	$CLIENT_SOCKET->close();	
}



sub ResponseGen {
	my($client_request) = @_;
	
	if (length($SERVER_RESPONSE{$client_request})) {
		return($SERVER_RESPONSE{$client_request});
	} else {
		return('<Undefined client request>');
	}
}

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
our $SERVER_IP = '0.0.0.0';
our $SERVER_PORT = '1337';

# Example request=>responses
our %SERVER_RESPONSE = (
	'1000'=>'1010',
	'2000'=>'2010',
	'3000'=>'3010');

# /CONFIG



# creating a listening socket
my $server_socket = new IO::Socket::INET (
    LocalHost => $SERVER_IP,
    LocalPort => $SERVER_PORT,
    Proto => 'tcp',
    Listen => 5,
    Reuse => 1);
die 'Cannot create socket '.$!."\n" unless $server_socket;

my($client_socket, $client_data);

while (1) {
	
	print 'Waiting for new connection on port '.$SERVER_PORT.'...'."\n";
	$client_data = ServerReceive(\$server_socket, \$client_socket);
	ServerRespond(ResponseGen($client_data), \$client_socket);
	print '---'."\n\n";
	
}

$server_socket->close();

exit;



sub ServerReceive {
	my($server_socket_ref, $client_socket_ref) = @_;
	
    $$client_socket_ref = $$server_socket_ref->accept();
    my $client_ip = $$client_socket_ref->peerhost();
    my $client_port = $$client_socket_ref->peerport();
    print '  Connection from client '.$client_ip.':'.$client_port."\n";

    # read up to 4096 characters from the connected client
    $$client_socket_ref->recv(my $client_data, 4096);
	
	# Remove trailing junk, eg. CR or LF
	$client_data =~ s/[\r\n]$//g;

	open(FILE,'>server.log');
	print FILE "\n".'////////// RECEIVED FROM CLIENT //////////'."\n";
	print FILE $client_data;
	close(FILE);
    print '    received data from '.$client_ip.':'.$client_port.' ['.$client_data.']'."\n";
	
	return $client_data;
}



sub ServerRespond {
	my($rdata, $client_socket_ref) = @_;

	# write response data to the connected client
    my $client_ip = $$client_socket_ref->peerhost();
    my $client_port = $$client_socket_ref->peerport();
    print '  Replying to client '.$client_ip.':'.$client_port;
    my $client_size = $$client_socket_ref->send($rdata);
	open(my $FILE, '>>server.log');
	print $FILE "\n".'////////// SENT TO CLIENT //////////'."\n";
	print $FILE $rdata;
	close($FILE);
	print ', sent data of length '.$client_size."\n";

    # notify client that response has been sent
	$$client_socket_ref->shutdown(SHUT_RDWR);
	$$client_socket_ref->close();	
}



sub ResponseGen {
	my($client_request) = @_;
	
	if (length($SERVER_RESPONSE{$client_request})) {
		return($SERVER_RESPONSE{$client_request});
	} else {
		return('<Undefined client request>');
	}
}

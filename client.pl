#!usr/bin/perl

use warnings;
use strict;

use IO::Socket::INET;
use utf8;

$| = 1;

print 'WebServices Client app'."\n";
print '---'."\n\n";



# CONFIG

my($SERVER_IP) = '127.0.0.1';
my($SERVER_PORT) = '1337';

# /CONFIG



my($client_request) = 'This should generate an <undefined client request> response.';
while (1) {
	ComCycle($client_request);
	print 'New request:';
	$client_request = <STDIN>;
}



exit;



sub ComCycle {
	my($client_request) = @_;
	my($client_socket,$client_req_size,$server_response);

	# create a connecting socket
	$client_socket = new IO::Socket::INET (
		PeerHost => $SERVER_IP,
		PeerPort => $SERVER_PORT,
		Proto => 'tcp',
		);
	die 'cannot connect to the server '.$!."\n" unless $client_socket;
	print '  Connected to '.$SERVER_IP.':'.$SERVER_PORT;

	# data to send to a server
	$client_req_size = $client_socket->send($client_request);
	# Finnished writing
	$client_socket->shutdown(SHUT_WR);
	print ', sent data of length '.$client_req_size."\n";
	print '['.$client_request.']'."\n";

	# receive a response of up to 4096 characters from server
	$server_response = '';
	$client_socket->recv($server_response, 4096);
	my($data,$headers,$content);
	($headers,$content) = split(/\r\n\r\n/,$server_response,2);

	print '  Response:'."\n";
	print '['.$server_response.']'."\n";

	$client_socket->close();
}

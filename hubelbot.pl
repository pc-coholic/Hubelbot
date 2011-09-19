use strict;
use vars qw($VERSION %IRSSI);

use Irssi;

$VERSION = '1.00';
%IRSSI = (
    authors     => 'Martin Gross',
    contact     => 'martin@pc-coholic.de',
    name        => 'Hubelbot',
    description => 'This script listens ' .
                   'to your hubels and ' .
                   'counts them.',
    license     => 'Public Domain',
    url		=> 'http://www.pc-coholic.de/',
);

#--------------------------------------------------------------------
# Process incoming messages
#--------------------------------------------------------------------

sub process_incoming {
	my ($server, $msg, $nick, $address, $target) = @_;
#	print $server;
#	print $msg;
#	print $nick;
#	print $address;
#	print $target;
#	print "-----------------------------";
}

Irssi::signal_add("message public", "process_incoming");

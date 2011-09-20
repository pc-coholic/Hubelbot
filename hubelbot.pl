use strict;
use vars qw($VERSION %IRSSI);

use Irssi;
use Irssi::UI;

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
# Config
#--------------------------------------------------------------------
our $botname            = "hubelbot";
our $debug              = 0;
our $inform             = 1;
our $datadir            = Irssi::get_irssi_dir() . "/hubeldata";
our $announce1          = 0;
our $announce_msg       = "";
our $megahubel          = 20;
our $announce_megahubel = "";
our $megahubel_msg      = "";

#--------------------------------------------------------------------
# Run on startup
#--------------------------------------------------------------------
our $win = Irssi::window_find_name("<" . $botname . ">");

if (!$win) {
	$win = Irssi::Windowitem::window_create("<" . $botname . ">", 1);
	$win->set_name("<" . $botname . ">");
}
$win->set_active();

mkdir "$datadir", 0777 unless -d "$datadir";

#--------------------------------------------------------------------
# Process incoming messages
#--------------------------------------------------------------------
sub process_incoming {
	my ($server, $msg, $nick, $address, $target) = @_;
	my $pcount = 0;
	my $ccount = 0;
	$pcount += () = $msg =~ /(jemand|irgendwer|man|einer)/i;
	$ccount += () = $msg =~ /(sollte|m\xfcsste|muesste|k\xf6nnte|koennte|h\xe4tte|haette|br\xe4uchte|braeuchte|m\xf6chte|moechte)/i;
	dprint($target . "/" . $nick . " => pcount: " . $pcount . " | ccount: " . $ccount);
	
	if ($pcount > 0 & $ccount > 0) {
		my $hubel = set_totalcount($nick, "hub");
		my $total = set_totalcount($nick, "all");
		my $ratio = $hubel / $total;
		$win->print("Awarding one Hubel to " . $nick . " - new ratio: " . 
			$hubel . "/" . $total . " = " . $ratio , "MESSAGES");
		iprint($msg);

	} else {
		my $hubel = get_totalcount($nick, "hub");
		my $total = set_totalcount($nick, "all");
		my $ratio = $hubel / $total;
		iprint("New line for " . $nick . " - new ratio: " .
			$hubel . "/" . $total . " = " . $ratio);
		dprint($msg);
	}
}

#--------------------------------------------------------------------
# Add 1 to count of total number of lines written by a person
# If no countfile exists yet, create a new one
#--------------------------------------------------------------------
sub set_totalcount() {
	my ($nick, $type) = @_;
	
	my $count = get_totalcount($nick, $type);
	my $filename = $datadir . "/" . $nick . "." . $type;

	open FILE, ">", $filename or die $!;
	$count++;

	print FILE $count;
	close(FILE);
	
	return $count;
}

#--------------------------------------------------------------------
# Get count of total number of lines written by a person
#--------------------------------------------------------------------
sub get_totalcount() {
	my ($nick, $type) = @_;
	my $count;
	my $filename = $datadir . "/" . $nick . "." . $type;
	
	if (open my $in, "<",  $filename) {
		$count = <$in>;
	} else {
		$count = 0;
	}

	return $count;
}


#--------------------------------------------------------------------
# Handle debug-printing
#--------------------------------------------------------------------
sub dprint() {
	my ($message) = @_;
	
	if ($debug == 1) {
		$win->print($message);
	}
}

#--------------------------------------------------------------------
# Handle info-printing
#--------------------------------------------------------------------
sub iprint() {
	my ($message) = @_;
	
	if ($inform == 1) {
		$win->print($message);
	}
}
Irssi::signal_add("message public", "process_incoming");

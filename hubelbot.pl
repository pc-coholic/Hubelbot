use strict;
use vars qw($VERSION %IRSSI);

use Irssi;
use Irssi::UI;
use Switch;
use utf8;

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
our $botkeyword		= "hubel"; # No leading ! - it's added automatically
our $debug              = 0;
our $inform             = 1;
our $datadir            = Irssi::get_irssi_dir() . "/hubeldata";
our $announce1          = 0;
our $announce_msg       = "";
our $megahubel          = 20;
our $announce_megahubel = "";
our $megahubel_msg      = "";
our $botmaster          = "martin";

# sven: wenn der konjunktiv groesser als 0.2 hubel wird, wirds kritisch
our $critical_level     = 0.2;

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

	if (substr($msg, 0, 1) eq '!') {
		process_command(@_);
	} else {
		process_hubel(@_);
	}
}

#--------------------------------------------------------------------
# Count hubels and do stuff
#--------------------------------------------------------------------
sub process_command() {
	my ($server, $msg, $nick, $address, $target) = @_;
	
	my @words = ($msg =~ /(\w+)/g);

	if (($words[0] eq  $botkeyword) && ($words[1] eq "award") && ($words[2] ne "")) {
		if ($nick eq $botmaster) {
			set_count($words[2], "hub");
			print_hubels($words[2], $server, $target, $words[2]);
			$win->print("Awarding one complementary Hubel to " . $words[2], "MESSAGES");
		} else {
                        $msg = "$nick: Hahahaha... No.";
                        $server->command("/notice $target $msg");

		}
	} elsif (($words[0] eq  $botkeyword) && ($words[1] eq "clear") && ($words[2] ne "") && ($nick eq $botmaster)) {
		#clear hubellog
		$win->print("Clearing hubelstats of " . $words[2], "MESSAGES");		
	} elsif (($words[0] eq $botkeyword) && ($words[1] eq "")) {
		print_hubels($nick, $server, $target, $nick);
	} elsif (($words[0] eq $botkeyword) && ($words[1] ne "")) {
		print_hubels($words[1], $server, $target, $nick);
	} elsif ($words[0] eq $botkeyword) {
		$server->command("/notice $target $nick: Sorry, command not understood");
	} else {
		process_hubel(@_);
	}
}

#--------------------------------------------------------------------
# Count hubels and do stuff
#--------------------------------------------------------------------
sub process_hubel() {
	my ($server, $msg, $nick, $address, $target) = @_;
	
	my $pcount = 0;
	my $ccount = 0;
	
	$pcount += () = $msg =~ /(jemand|irgendwer|man|einer)/i;
	$ccount += () = $msg =~ /(sollte|m\xfcsste|muesste|müsste|k\xf6nnte|koennte|könnte|h\xe4tte|haette|hätte|br\xe4uchte|braeuchte|bräuchte|m\xf6chte|moechte|möchte)/i;
	dprint($target . "/" . $nick . " => pcount: " . $pcount . " | ccount: " . $ccount);
	
	if ($pcount > 0 & $ccount > 0) {
		my $hubel = set_count($nick, "hub");
		my $total = get_count($nick, "all");
		my $ratio = $hubel / $total;
		$win->print("Awarding one Hubel to " . $nick . " - new ratio: " . 
			$hubel . "/" . $total . " = " . $ratio , "MESSAGES");
		iprint($msg);

	} else {
		my $hubel = get_count($nick, "hub");
		my $total = set_count($nick, "all");
		my $ratio = $hubel / $total;
		iprint("New line for " . $nick . " - new ratio: " .
			$hubel . "/" . $total . " = " . $ratio);
		dprint($msg);
	}
}

#--------------------------------------------------------------------
# print nice text with hubels for person
#--------------------------------------------------------------------
sub print_hubels() {
	my ($nick, $server, $target, $requestor) = @_;
	
	my $ratio = get_count($nick, "hub") / get_count($nick, "all");

	my $msg;
	
	if ($nick eq $requestor) {
		$msg = "$requestor: You currently rank at $ratio hubel.";
	} else {
		$msg = "$requestor: $nick currently ranks at $ratio hubel.";
	}
	
	$server->command("/notic $target $msg");
}

#--------------------------------------------------------------------
# Add 1 to count of total number of lines written by a person
# If no countfile exists yet, create a new one
#--------------------------------------------------------------------
sub set_count() {
	my ($nick, $type) = @_;
	
	my $count = get_count($nick, $type);
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
sub get_count() {
	my ($nick, $type) = @_;
	my $count;
	my $filename = $datadir . "/" . $nick . "." . $type;
	
	if (open my $in, "<",  $filename) {
		$count = <$in>;
	} else {
		$count = 0;
	}
	
	if (($type eq "all") && ($count == 0)) {
		$count = 1;
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

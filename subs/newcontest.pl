# Chose a contest from the list of available contests.

use strict;

load_subs("readrules.pl");

sub newcontest {

my $contest;
my %names;
my $filename;
my $mycall = $_[0] || "";
my $assisted;
my $bands;
my $modes;
my $operator;
my $power;
my $transmitter;
my $fix='';
my $rig;
my $rigfile;
my $ch;


my @contests;			# all definition files
if (-d "defs") {
	# load defs from local directory
	$main::contestpath = "defs/";
	@contests = <defs/*.def>;
} else {
	# load them from the installed paths
	$main::contestpath = "/usr/local/share/yfktest/defs/";
	@contests = </usr/local/share/yfktest/defs/*.def>;
}

foreach (@contests) {
	open FH, $_;
	$names{$_} = <FH>;
	chomp($names{$_});
	close FH;
}

@contests = ("Open File...", @contests);
$names{$main::contestpath.'Open File....def'} = "Open existing YFKtest contest log.";

my $wmain = newwin(24,80,0,0);
attron($wmain, COLOR_PAIR(4));
addstr($wmain, 0, 0, " " x (24*80));
addstr($wmain, 0, 0, "YFKtest - New contest / Open Contest - Please chose a contest from the list:");

my $wdialog = newwin(20,70,3,5);
attron($wdialog , COLOR_PAIR(5));
addstr($wdialog , 0, 0, " " x (20*70));

refresh($wmain);
refresh($wdialog);

my $x = 0;
my $y = -1;
my $nr = 0;
my $activeentry=1;			# nr of the highlighted contest

do {
	$y = -1;
	$x = 0;
	$nr = 0;
	
	foreach my $test (@contests) {
		$nr++;
		$y++;

		if ($y > 19) {			# Check if we need to go to the next column
			$y = 0;
			$x += 1;
		}
	
		$test =~ s#^(/usr/local/share/yfktest/|)defs/([\w\-_]+)[.]def$#$2#g;

		if ($nr == $activeentry) {
			attron($wdialog, COLOR_PAIR(1));
		}
		else {
			attron($wdialog, COLOR_PAIR(5));
		}
		
		addstr($wdialog, $y, $x*15, $test);
		attron($wdialog, COLOR_PAIR(5));
	}
	refresh($wdialog);
	
	my $tmp = $main::contestpath.$contests[$activeentry-1].'.def';

	addstr($wmain, 23, 0, "Contest: $names{$tmp}                               ");
	refresh($wmain);
	
	$ch = getch();


	if (($ch eq KEY_DOWN) && ($activeentry <= $#contests)) {
		$activeentry++;
	}
	elsif (($ch eq KEY_UP) && ($activeentry > 1)) {
		$activeentry--;
	}

} until ($ch =~ /\s/);

$contest = $contests[$activeentry-1];

if ($contest eq 'Open File...') {
	return 0;
}

# We have chosen a contest. Now set the general data (Callsign etc.).

$filename = $contest;

&readrules($contest);

addstr($wmain, 0, 0, " " x (24*80));
addstr($wmain, 0, 0, "YFKtest - New contest: $contest");
refresh($wmain);
addstr($wdialog , 0, 0, " " x (20*70));


do {

attron($wdialog, COLOR_PAIR(5));
addstr($wdialog , 1, 3 , "Filename:");
addstr($wdialog , 2, 3 , "Call:");
addstr($wdialog , 3, 3 , "Assisted:");
addstr($wdialog , 3, 48 , " Use the cursor keys  ");
addstr($wdialog , 4, 48 , " to change settings.  ");
addstr($wdialog , 4, 3 , "Band:");
addstr($wdialog , 5, 3 , "Mode:");
addstr($wdialog , 6, 3 , "Operator:");
addstr($wdialog , 7, 3 , "Power:");
addstr($wdialog , 8, 3 , "Transmitter:");
addstr($wdialog , 9, 3 , $main::fixexchangename) if ($main::fixexchange); 
addstr($wdialog , 9, 48 , "(if applicable)") if ($main::fixexchange);
addstr($wdialog , 10, 3 , "CAT control:");

refresh($wdialog);

$filename = &readw(\$wdialog, 1, 20, '[\-\w]', "$filename");
$mycall = &readw(\$wdialog, 2, 20, 'call', $mycall);

$assisted = &chose(\$wdialog, 3, 20, 'ASSISTED NON-ASSISTED', $assisted);
$bands = &chose(\$wdialog, 4, 20, 'ALL 160M 80M 40M 20M 15M 10M 6M 2M 222 432 902 1.2G', $bands);
$modes = &chose(\$wdialog, 5, 20, 'CW MIXED PSK SSB RTTY', $modes);
$operator = &chose(\$wdialog, 6, 20, 'SINGLE-OP MULTI-OP CHECKLOG', $operator);
$power = &chose(\$wdialog, 7, 20, 'HIGH LOW QRP', $power);
$transmitter = &chose(\$wdialog, 8, 20, 'ONE TWO LIMITED UNLIMITED SWL',
		$transmitter);

if ($main::fixexchange eq 'exc1s') {
	$main::exc1s = &readw(\$wdialog, 9, 20, 'call', $fix);
	$fix = $main::exc1s;
}
elsif ($main::fixexchange eq 'exc2s') {
	$main::exc2s = &readw(\$wdialog, 9, 20, 'call', $fix);
	if ($contest eq 'IOTA') {
		$main::exc2s =~ s/([A-Z]{2})/$1-/;
	}
	$fix = $main::exc2s;
}


$rig = &chose(\$wdialog, 10, 20, 'Rigctld NO', $rig);

if ($rig eq 'NO') {
	$main::rigctld = 0;
}

refresh($wdialog);

# All ok?

addstr($wdialog, 18, 5, "Press Enter to continue, 'e' to edit the settings above.");
curs_set(0);
refresh($wdialog);

$ch = getch();

} until ($ch ne 'e');

delwin($wmain);
delwin($wdialog);

$filename .= ".yfk";

if (-e $filename) {
		endwin;
		print "Error, file already exists! Open existing contest log by\n".
				"giving the filename as command line argument.\n";
		exit;
}
else {
	open LOG, ">$filename";
	print LOG "YFKtest\n";
	print LOG $contest."\n".$mycall."\n".$assisted."\n".$bands."\n".$modes.
			"\n".$operator."\n".$power."\n".$transmitter."\n".$fix."\n".
			$main::cwmessages[0]."\n".$main::cwmessages[1]."\n".
			$main::cwmessages[2]."\n".$main::cwmessages[3]."\n".
			$main::cwmessages[4]."\n".$main::cwmessages[5]."\n".
			$main::cwmessages[6]."\n";
	close LOG;
}


return ($contest, $filename, $mycall, $assisted, $bands, $modes, $operator,
		$power, $transmitter);
}



sub readw {
		my ($window, $y, $x, $regex, $text) = @_;
		my $pos = 0;								# relative cursor x pos
		my $toupper = 0;
		my $ch;
		$text ||= "";  # avoids perl warnings about empty data

		if ($regex eq 'call') {
				$toupper = 1;
				$regex = '[a-zA-Z0-9/]';
		}

		curs_set(1);

		do {
			addstr($$window , $y, $x , $text.' ');
			move($$window, $y, $x+$pos);
			refresh($$window);

			$ch = getch;

			
			if ($ch eq KEY_LEFT) {
				$pos-- if $pos;
			}
			elsif ($ch eq KEY_RIGHT) {
				$pos++ if ($pos < length($text));
			}
			elsif ($ch =~ /^$regex$/) {
				$pos++;
				if ($toupper) { $ch = "\U$ch"; }
				$text = substr($text, 0, $pos-1).$ch.substr($text, $pos-1, );
			}
			elsif (($ch eq KEY_DC) && ($pos < length($text))) {
				$text = substr($text, 0, $pos).substr($text, $pos+1, );
			}
			elsif ((($ch eq KEY_BACKSPACE) || (ord($ch)==8) || (ord($ch)==0x7F))
				   	&& ($pos > 0)) {
				$text = substr($text, 0, $pos-1).substr($text, $pos, );
				$pos--;
			}
		} until ($ch =~ /\s+/);

		return $text;
}

sub chose {

my ($window, $y, $x, $options, $setting) =  @_;

my @opts = split(/\s+/, $options);
my $nr = 0;
my $ch;

if ($setting) {					# Preset field
	foreach (@opts) {
		if ($_ eq $setting) {
			last;
		}
		$nr++;
	}
}

do {
		addstr($$window, $y, $x, $opts[$nr]."              "); 	# ;-)
		move($$window, $y, $x);
		refresh($$window);
		
		$ch = getch();

		if ($ch eq KEY_LEFT) {
			$nr-- if $nr;
			$ch = '';
		}
		elsif ($ch eq KEY_RIGHT) {
			$nr++ if ($nr < $#opts);
			$ch = '';
		}

} until ($ch =~ /^\s+$/);

curs_set(1);

return $opts[$nr];

}

return 1;

# Local Variables:
# tab-width:4
# End: **

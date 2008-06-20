#!/usr/bin/perl -w

# yfktest - a simple, single operator ham radio contest logbook
# 
# Copyright (C) 2008  Fabian Kurz, DJ1YFK
#
# This program is free software; you can redistribute it and/or modify 
# it under the terms of the GNU General Public License as published by 
# the Free Software Foundation; either version 2 of the License, or 
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, 
# but WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the 
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License 
# along with this program; if not, write to the 
# Free Software Foundation, Inc., 59 Temple Place - Suite 330, 
# Boston, MA 02111-1307, USA. 

use strict;
use Curses;
#use IO::Socket;
#use threads;
#use threads::shared;
use IO::Socket::INET;

our $VERSION="0.0.10";

# Since Hamlib may be unavailable, 'use Hamlib' might crash the program. So we
# search in @INC for hamlib.pm and (if available) we 'manually' use it.

our $hashamlib = 0;
foreach (@INC) {
	if (-e $_."/Hamlib.pm") {
		$hashamlib = 1;
	}
}
if ($hashamlib) {
	require Hamlib; import Hamlib;
}

our $cwspeed=32;

our $cwsocket = IO::Socket::INET->new(PeerAddr => "localhost",
PeerPort => "6789", Proto    => "udp", Type     => SOCK_DGRAM,)
or die "Cannot open socket for CWdaemon.\n";

print $cwsocket chr(27)."2 $cwspeed";

#our $netsocket = IO::Socket::INET->new(PeerAddr => "192.168.0.74",
#PeerPort => "9871", Proto   => "udp", Type => SOCK_DGRAM,)
#or die "Cannot open socket for Network.\n";

our $netname = "STN1";

require "subs/newcontest.pl";
require "subs/filebrowser.pl";
require "subs/checkmulti1.pl";
require "subs/checkcall.pl";
require "subs/showscore.pl";
require "subs/partialcheck.pl";
require "subs/readakey.pl";
require "subs/wipeqso.pl";
require "subs/qsy.pl";
require "subs/logqso.pl";
require "subs/displaylog.pl";
require "subs/scoreqso.pl";
require "subs/readlog.pl";
require "subs/dupecheck.pl";
require "subs/rate.pl";
require "subs/readrules.pl";
require "subs/writelog.pl";
require "subs/sendcw.pl";
require "subs/dxcc.pl";
require "subs/callinfo.pl";
require "subs/rigctl.pl";
require "subs/keyboardmode.pl";
require "subs/editcwmessages.pl";
require "subs/guessexchange.pl";
require "subs/readconfigfile.pl";
require "subs/showhelp.pl";
require "subs/rategraph.pl";
#require "subs/net_receiveqso.pl";

our $version = "0.0.9";

our ($contest,			# definition file: defs/$contest.def
	$filename,			# of this current contest log
	$mycall,
	$assisted,			# for cabrillo log
	$bands,				
	$modes,	
	$operator,
	$power,
	$transmitter);

our $entryfields = 1;	# contest dependant
our $activefield = 'call';

# printf-string for the cabrillo output
our $cabrilloline='no cabrillo format defined!';
our $cabrillovalues='band date utc ...';
our $cabrilloname='CONTEST-NAME';

our ($exc1len, $exc2len, $exc3len, $exc4len) = (4,4,4,4);

our $fixexchange='';	# fixed exchange like in IOTA, ITU etc.
						# contains which exchange will be fixed, i.e. exc1, 2..
our $fixexchangename='';# what to ask the user for, like "IOTA-Ref:"?
our $exc1s = '';		# actual value of the fixed exchange value
our $exc2s = '';

our $tmp='';

our $counter=0;
my $curpos = 0;

# For guessexchange, only consider every callsign once, save in $lastguessed
our $lastguessed = '';
# A hash for use with guessexchange, for example "callsign -> State"
our %guesshash = ();


# Valid characters for the 4 entry fields  (will be read from def file)
our @validchars = ('[0-9A-Za-z]', '', '', '');

# Valid complete entries that can be logged (example: IOTA) (will be read fm
# def file)
our @validentry = ('.+', '', '', '');


my $oldcall=''; 			# check if call was changed. otherwise no PC/SPC


our $editnr=0;				# the QSO which is currently being edited (if any),
							# 0 = no QSO being edited, normal operation

my $oldeditnr = 0;			# we have to check if it changes now and then


our $rigmodel = ''; 			# New: Hamlib.
our $rigpath = '';			
our $rigctl=0;

our %s_qsos = ("160" =>0,"80" => 0, "40" => 0, "30" => 0, "20" => 0,
				"17" => 0, "15" => 0, "12" => 0, "10" => 0, "6" => 0);
our %s_qsopts = ("160" =>0,"80" => 0, "40" => 0, "30" => 0, "20" => 0, "17" =>
				0, "15" => 0, "12" => 0, "10" => 0, "6" => 0);
our %s_mult1 = ("160" => 0,"80"=> 0, "40" => 0, "30" => 0, "20" => 0, "17" =>
				0, "15" => 0, "12" => 0, "10" => 0, "6" => 0, "All" => 0);
our %s_mult2 = ("160" => 0,"80"=> 0, "40" => 0, "30" => 0, "20" => 0, "17" =>
				0, "15" => 0, "12" => 0, "10" => 0, "6" => 0, "All" => 0);
our %s_dupes = ("160" => 0,"80" => 0,"40" => 0, "30" => 0, "20" => 0, "17" =>
				0, "15" => 0, "12" => 0, "10" => 0, "6" => 0, "All" => 0);
our $s_sum = 0;


our ($defmult1, $defmult2, $defqsopts);


our @qsos;			# Array of hashes with single QSOs.
#our @net_qsos : shared;	# Array of hashes with single QSOs received over the net

our @cwmessages  = ('');


open SCP, "master.scp";
our @scp = <SCP>;
$scp[1] = $scp[2] = '';
close SCP;

our %qso = (		# The current QSO
		'nr' => 1,
		'utc' => '',
		'date' => '20070101',
		'call' => '',
		'rst' => '599',
		'excs' => '',		# sent exchange
		'exc1' => '',
		'exc2' => '',
		'exc3' => '',
		'exc4' => '',
		'band' => '20',
		'mode' => 'CW',
		'stn' => $netname
);

# our %net_qso : shared = ();

our %tmpqso;			# current Q will be saved here while editing prev QSOs

# Will be changed later if needed.
our $mycont='EU';
our $mydxcc='DL';

initscr();
noecho();
keypad(1);

if (!has_colors) {
		die "Your terminal can't display colors.";
}

start_color();
curs_set(0);

printw "YFKtest v$version - Copyright (C) 2008 Fabian Kurz, DJ1YFK
This is free software, and you are welcome to redistribute it
under certain conditions (see COPYING).

Press any key to continue.";

getch();


init_pair(1, COLOR_BLACK, COLOR_YELLOW);
init_pair(2, COLOR_BLUE, COLOR_GREEN);
init_pair(3, COLOR_BLUE, COLOR_CYAN);
init_pair(4, COLOR_WHITE, COLOR_BLUE);
init_pair(5, COLOR_WHITE, COLOR_BLACK);
init_pair(6, COLOR_WHITE, COLOR_RED);


# Look for ~/.yfktest config file...

readconfigfile();

# If a file was supplied as command line argument, continue this contest,
# otherwise start a new contest or ask for a filename...

unless ($ARGV[0]) {

	($contest, $filename, $mycall, $assisted, $bands, $modes, $operator,
			 $power, $transmitter) = &newcontest($mycall);

	 if ($contest eq '0') {		# No new contest, open a file
			$filename = &filebrowser();
	 }
}

# Read a contest file, IF $ARGV[0] or $contest == 0.

if ($ARGV[0] || ($contest eq '0')) {
	
		unless ($filename) {
			$filename = $ARGV[0];
		}

		if (-r $filename) {
			printw "\nOpening log file $filename...\n";

			unless (($contest = &readlog()) &&
					($qso{'nr'} = $#qsos+2) 
			) {
				printw "$filename not a valid contest log! Exiting.\n";
				getch; endwin; exit;
			} else {					# Read log OK, now rescore!

					# read the rules and fill neccessary variables...
					&readrules($contest);

					if ($tmp) {
						if ($fixexchange eq 'exc1s') {
							$exc1s = $tmp;
						}
						elsif ($fixexchange eq 'exc2s') {
							$exc2s = $tmp;
						}
					}


					printw "Rescoring the log: ";
					my $i = 0;

					my @tmp = &dxcc($mycall);
					($mydxcc, $mycont) = @tmp[7,3];

					foreach (@qsos) {
						$i++;
						if ($i % 10 == 0) { printw $i.' '; }
						refresh();
						%qso = %{$_};
						&scoreqso(\%qso, \@qsos, \%s_qsos, \%s_qsopts,
								\%s_mult1, \%s_mult2, \%s_dupes, \$s_sum);
					}
					refresh();
					&wipeqso(\%qso, \$curpos, \$activefield);

					$qso{'nr'} = $i+1;

			}


		}
		else {
			printw "File $filename not found. Exiting.";
			getch; endwin; exit;
		}
}


my @tmp = &dxcc($mycall);
($mydxcc, $mycont) = @tmp[7,3];

if ($modes eq 'SSB') {
	$qso{'mode'} = 'SSB';
	$qso{'rst'} = '59';
}

# Activate Hamlib if needed.

if ($rigctl) {
	Hamlib::rig_set_debug(0);
	our $rig = new Hamlib::Rig($rigmodel);
	$rig->set_conf("rig_pathname", $rigpath);	# Set path/device
	$rig->open();
}

##############################################################################
# Actual logging starts here
##############################################################################

our $wmain = newwin(24,80,0,0);
attron($wmain, COLOR_PAIR(3));
addstr($wmain, 0,0, ' 'x(24*80));
refresh($wmain);

our $wcheck = newwin(($contest eq 'DXPED' ? 10 : 7), 38,0,0);
attron($wcheck, COLOR_PAIR(4));

our $winfo = newwin(($contest eq 'DXPED' ? 3 : 6), 35, 
		($contest eq 'DXPED' ?  11 : 8),0);
attron($winfo, COLOR_PAIR(4));
addstr($winfo, 0,0, ' 'x(6*35));
refresh($winfo);

our $wshowscore = newwin(10,21,14,59);
our $wpartialcheck = newwin(9,40,0,39);

our $wrate = newwin(4, 16, 10, 62);
attron($wrate, COLOR_PAIR(4));
addstr($wrate, 0,0, "   QSO Rates:   ");
addstr($wrate, 1,0, " "x66);
addstr($wrate, 3,0, "  CW-Speed: $cwspeed");
refresh($wrate);

my $ch='';

# initial display
&showscore(\$wshowscore, \%s_qsos, \%s_mult1, \%s_mult2, \%s_dupes, $s_sum);
&rate(\$wrate, \@qsos);
&displaylog(\$wmain, \@qsos, 0);
&partialcheck(\$wpartialcheck, \%qso, \@qsos, \@scp);
&checkcall(\$wcheck, \@qsos, 'blabla');


# net_receiveqso will write received network QSOs to @net_qsos, which is a data
# structure like @qsos, and can be pushed into @qsos
# my $net_thread = threads->new(\&net_receiveqso);


halfdelay(1);
while (1) {

#		if (keys(%net_qso)) {
#			&logqso(\%net_qso,\@qsos,\@validentry, $filename);
#			&scoreqso(\%net_qso, \@qsos, \%s_qsos, \%s_qsopts, \%s_mult1,
#						\%s_mult2, \%s_dupes, \$s_sum);
#			&displaylog(\$wmain, \@qsos, $editnr);
#			&showscore(\$wshowscore, \%s_qsos, \%s_mult1, \%s_mult2,
#						\%s_dupes, $s_sum);
#			&rate(\$wrate, \@qsos);
#			%net_qso = ();
#		}

		if (($qso{'call'} ne $oldcall) or ($oldeditnr != $editnr)) {
			&displaylog(\$wmain, \@qsos, $editnr);
			&partialcheck(\$wpartialcheck, \%qso, \@qsos, \@scp);
			&checkcall(\$wcheck, \@qsos, $qso{'call'});
			&dupecheck(\$wmain, \%qso, \@qsos) unless $editnr;
			&callinfo();
		}
		$oldcall = $qso{'call'};
		$oldeditnr = $editnr;

		&rigctl('get') unless ($editnr || ($counter % 20) || (!$rigctl));
		$counter++;

		my $ch = &readakey(\$wmain, \%qso, $entryfields, \$activefield,
				\$curpos, \@validchars, \@validentry);	

		if ($ch ne 'ok') {		# some special key/function pressed
			if (!$editnr && ($ch =~ /^(f\d|ins|esc|plus|pgup|pgdwn)$/)) {
				&sendcw($ch);
			}
			elsif ($ch eq 'wipe') {								# Alt-W, F11
				&wipeqso(\%qso, \$curpos, \$activefield);
			}
			elsif ($ch eq 'help' || $ch eq 'rate') {	# alt-h alt-r

				if ($ch eq 'help') { &showhelp(); }
				else { &rategraph(); }

				touchwin($wmain);			# Restore Screen etc.
				touchwin($wrate);
				&displaylog(\$wmain, \@qsos, 0);
				&partialcheck(\$wpartialcheck, \%qso, \@qsos, \@scp);
				&checkcall(\$wcheck, \@qsos, $qso{'call'});
				&showscore(\$wshowscore, \%s_qsos, \%s_mult1, \%s_mult2, 
						\%s_dupes, $s_sum);
				&rate(\$wrate, \@qsos);

			}
			elsif ($ch eq 'keyboard') {							# Alt-K
				&keyboardmode() if ($qso{'mode'} eq 'CW');
			}
			elsif ($ch eq 'cwmessages') {							# Alt-M
				&editcwmessages(\$wcheck);
			}
			elsif ($ch eq 'log') {		# enter pressed
				&qsy(\%qso, \$curpos);	# check for: '20M', 'SSB', '21025' etc.

				if ($qso{'call'} eq 'QUIT') {
					endwin;
					print "Thanks for using YFKtest!\n";
					exit;
				}

				# normal operation, not editing
				if (!$editnr && &logqso(\%qso,\@qsos,\@validentry,$filename)) {
					if ($qso{'call'} eq 'WRITELOG') {
						&writelog();
					}
					else {
					&scoreqso(\%qso, \@qsos, \%s_qsos, \%s_qsopts, \%s_mult1,
							\%s_mult2, \%s_dupes, \$s_sum);
					}
					&wipeqso(\%qso, \$curpos, \$activefield);
				}
				elsif ($editnr && &logeditqso()) {				# edit old QSO
					%{$qsos[$editnr-1]} = %qso;
					$editnr = 0;							# XXX No rescoring
					%qso = %tmpqso;
					delete $tmpqso{'call'};
					addstr($wmain,23,0,"                                     ");
					&wipeqso(\%qso, \$curpos, \$activefield);
				}
				&showscore(\$wshowscore, \%s_qsos, \%s_mult1, \%s_mult2,
						\%s_dupes, $s_sum);
				&rate(\$wrate, \@qsos);
			}	# log
			elsif ($ch eq 'up') {			# arrow up -> edit prev.
				unless (defined($tmpqso{'call'})) {
					%tmpqso = %qso;
				}
				
				if ($editnr) {
					$editnr-- unless $editnr == 1;
				}
				else {
					$editnr = ($#qsos+1);
				}
				
				%qso = %{$qsos[$editnr-1]} if (@qsos); 
			}
			elsif ($ch eq 'down') {			# arrow up -> edit prev.
				next unless $editnr;
				if ($editnr <= $#qsos) {
						%qso = %{$qsos[$editnr]};
						$editnr++;
				}
				else {								# at last QSO
						$editnr = 0;
						%qso = %tmpqso;				# restore QSO
						delete $tmpqso{'call'};
						addstr($wmain,23,0,"                                     ");
						&wipeqso(\%qso, \$curpos, \$activefield);
				}
			}
			elsif ($editnr && ($ch =~ /f([123])/)) {
					&qsyband('up') if $1 == 1; 
					&qsyband('down') if $1 == 2; 
					&togglemode() if $1 == 3; 
			}
		}

		addstr($wmain,23,0,"Edit QSO $editnr. QSY: F1/2, Mode: F3") if $editnr;
		refresh($wmain);;


}	# main loop







endwin();



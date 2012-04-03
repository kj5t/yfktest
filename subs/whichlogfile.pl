
sub whichlogfile {

# If a file was supplied as command line argument, continue this contest,
# otherwise start a new contest or ask for a filename...
unless ($ARGV[0]) {

	($contest, $filename, $mycall, $assisted, $bands, $modes, $operator,
			 $power, $transmitter) = &newcontest($mycall);

	 if ($contest eq '0') {								# No new contest, open a file
			$filename = &filebrowser();
	 }
}

# Read a contest file, IF $ARGV[0] or $contest == 0.

if ($ARGV[0] || ($contest eq '0')) {
	
		unless ($filename) {
			$filename = $ARGV[0];
		}

		if (-r $filename) {
#			printw "\nOpening log file $filename...\n";
			attron(COLOR_PAIR(6));
			printw "\nOpening file..";

			unless (($contest = &readlog()) &&
					($qso{'nr'} = $#qsos+2)) {
#				printw "\n\n$filename is not a valid contest log! Press *any* key to exit.\n";
				printw "Its' not a valid contest log! Press *any* key to exit.\n";
				getch; endwin; exit;
			} else {							# Read log OK, now rescore!

				&scorelog ();

			}
		} else {
##			printw "\n\nFile $filename not found. Press *any* key to exit.\n";
			attron(COLOR_PAIR(6));
#			printw "\n The log file cannot be found. Press *any* key to exit.\n";
			printw "\n The log file you entered cannot be found. Press *any* key to exit.\n";
			getch; endwin; exit;
			exit;
		}
	}
}

sub scorelog() {

			&readrules($contest);				# read the rules and fill neccessary variables...

			if ($tmp) {
				if ($fixexchange eq 'exc1s') {
					$exc1s = $tmp;
				}
				elsif ($fixexchange eq 'exc2s') {
						$exc2s = $tmp;
				}
			}


			printw "Rescoring the log:";
			my $i = 0;

			my @tmp = &dxcc($mycall);
			($mydxcc, $mycont) = @tmp[7,3];

			foreach (@qsos) {
				$i++;
				if ($i % 10 == 0) { printw $i.' '; }
				refresh();
				%qso = %{$_};
				unless ($qso{'call'} =~ /^DEL/) {
					&scoreqso(\%qso, \@qsos, \%s_qsos, \%s_qsopts,
						\%s_mult1, \%s_mult2, \%s_dupes, \$s_sum);
				}
			}
			refresh();
			&wipeqso(\%qso, \$curpos, \$activefield);

			$qso{'nr'} = $i+1;

		}

return 1;



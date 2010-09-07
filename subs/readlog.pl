
sub readlog {
		my $line;
		my $i=0;
		my %qso;
		my $contest;


		open LOG, $main::filename or die "Not able to open $main::filename!";

		$line = <LOG>;

		unless ($line =~ /YFKtest/) {
			return 0;
		}

		$contest = <LOG>;			# contest type
		chomp($contest);

		$main::mycall = <LOG>;
		$main::assisted = <LOG>;
		$main::bands = <LOG>;
		$main::modes = <LOG>;
		$main::operator = <LOG>;
		$main::power= <LOG>;
		$main::transmitter= <LOG>;
		
		
		$main::tmp = <LOG>;			# :-|  fixed exchange. will be put to right
									# var in main.
		$main::cwmessages[0] = <LOG>;
		$main::cwmessages[1] = <LOG>;
		$main::cwmessages[2] = <LOG>;
		$main::cwmessages[3] = <LOG>;
		$main::cwmessages[4] = <LOG>;
		$main::cwmessages[5] = <LOG>;
		$main::cwmessages[6] = <LOG>;


		chomp(@main::cwmessages);


		chomp($main::mycall, $main::assisted, $main::bands, $main::modes,
				$main::operator, $main::power, $main::transmitter, $main::tmp);



		while ($line = <LOG>) {
				$i++;
				$line =~ s/\s//g;			# remove spaces
				@a = split(/;/, $line);
				$qso{'nr'} = $a[0];
				$qso{'band'} = $a[1];
				$qso{'freq'} = $a[2];
				$qso{'mode'} = $a[3];
				$qso{'utc'} = $a[4];
				$qso{'date'} = $a[5];
				$qso{'call'} = $a[6];

				# make sure *something* is in the exc's

				$qso{'exc1'} = $qso{'exc2'} = $qso{'exc3'} = $qso{'exc4'} = '';

				$qso{'exc1'} = $a[7] if defined($a[7]);
				$qso{'exc2'} = $a[8] if defined($a[8]);
				$qso{'exc3'} = $a[9] if defined($a[9]);
				$qso{'exc4'} = $a[10] if defined($a[10]);
				
				$qso{stn} = $a[11] if defined($a[11]);


				if ($qso{'mode'}  eq 'SSB') {
						$qso{'rst'} = '59';
				}
				else {
						$qso{'rst'} = '599';
				}

				#	push @{$_[0]}, { %qso }
				push @main::qsos, {%qso};

		}

		printw "Read $i QSOs.\n";

		close LOG;
		return $contest;
}

return 1;

# Local Variables:
# tab-width:4
# End: **

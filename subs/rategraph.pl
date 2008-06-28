
# Make a graph of the QSO-Rate, starting at the first QSO, for either 24h or
# 48h.



sub rategraph {
	my $ch='';

	curs_set(0);
	my $wgraph = newwin(24,80,0,0);
	attron($wgraph, COLOR_PAIR(4));
	addstr($wgraph , 0,0, ' 'x(24*80));
	attron($wgraph, A_BOLD);
	addstr($wgraph , 0,0, "QSO Rate - Press Any Key To Return");
	attroff($wgraph, A_BOLD);



	my (%rates, %days);

	my $n = $#main::qsos;

	for (0..$n) {
		my $day = substr($main::qsos[$_]{date}, -2, 2);
		my $hour = substr($main::qsos[$_]{utc}, 0, 2);
		if (defined($rates{$day.$hour})) {
			$rates{$day.$hour}++;
		}
		else {
			$rates{$day.$hour} =  1;
		}
		$days{$day} = 1;
	}

	unless (keys(%days)) { return }

	# Find maximum rate
	
	my $max=0;
	foreach (values %rates) {
		if ($_ > $max) {
			$max = $_;
		}
	}

	&scale($wgraph, 18, 13, $max, 16);

	my $x = 15;
	foreach $day (sort keys %days) {
		for (0..23) {
			$x++;
			$hour = sprintf("%02d", $_);

			addstr($wgraph , 20, $x, substr($hour,0,1));
			addstr($wgraph , 21, $x, substr($hour,1,1));

			if (defined($rates{$day.$hour})) {
				&vertbar($wgraph, 18, $x, int(16*$rates{$day.$hour}/$max));
			}

		}
	}

	refresh($wgraph);
	$ch = getch() until ($ch =~ /\s+/);

	delwin($wgraph);
	curs_set(1);
	return 0;

}






sub vertbar {
	my ($win, $y, $x, $height) = @_;

	attron($win, COLOR_PAIR(3));
	for (0..$height) {
		addstr($win , $y-$_, $x, " ");
	}
	attron($win, COLOR_PAIR(4));

}

sub scale {
	my ($win, $y, $x, $max, $height) = @_;

	for (0..4) {
		addstr($win , $y - int($_ * $height / 4), $x, int($_ * $max/4) );
	}

}






return 1;

# Local Variables:
# tab-width:4
# End: **

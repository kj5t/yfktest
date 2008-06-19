sub partialcheck {
	my $window = $_[0];
	my %qso = %{$_[1]};
	my $qsoref = $_[2];
	my $scpref = $_[3];
	attron($$window, COLOR_PAIR(4));
	addstr($$window, 0,0, ' 'x999);	
	move($$window, 0,0);
	refresh($$window);

	my $call = $qso{'call'};
	my $band = $qso{'band'};
	my $mode = $qso{'mode'};


	my %partials;					# value = 1 means needed, 2 means dupe

	if (length($call) > 1) {
		foreach (@{$scpref}) {
			chomp $_;
			if (index($_, $call) > -1) {
				if (($_ eq $band) && ($_ eq $mode)) {
						$partials{$_} = 2;		# dupe
				}
				else {
						$partials{$_} = 1 unless defined($partials{$_});
				}
			}
		}
		foreach (@{$qsoref}) {
			if (index($_->{'call'}, $call) > -1) {
				if (($_->{'band'} eq $band) && ($_->{'mode'} eq $mode)) {
						$partials{$_->{'call'}} = 2;		# dupe
				}
				else {
						$partials{$_->{'call'}} = 1 
						unless defined($partials{$_->{'call'}});
				}
			}
		}

	}

	foreach (sort keys %partials) {
		if ($partials{$_} == 1) {
			attron($$window, COLOR_PAIR(4));
		}
		else {
			attron($$window, COLOR_PAIR(1));
		}
		addstr($$window, $_);
		attron($$window, COLOR_PAIR(4));
		addstr($$window, ' ');

	}


	refresh($$window);



}

return 1;

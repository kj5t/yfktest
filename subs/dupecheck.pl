


sub dupecheck {
	my $window = $_[0];
	my %qso = %{$_[1]};
	my $qsoref = $_[2];

	addstr($$window, 23, 18, "    ");

	foreach (@{$qsoref}) {
	
			if (($_->{'call'} eq $qso{'call'}) &&
				($_->{'band'} eq $qso{'band'}) &&
				($_->{'mode'} eq $qso{'mode'})) {

					addstr($$window, 23, 18, "DUPE");
					last;
			}
	}

	refresh($$window);

	return 1;

}





return 1;

# Local Variables:
# tab-width:4
# End: **

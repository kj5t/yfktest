# general QSY by entering a band like '160M' or a mode in the callfield

sub qsy {
	my $value=0;
	if ($_[0]->{'call'} =~ /^(6|10|12|15|17|20|30|40|80|160)M$|^(\d{4,5})$/) {
		$value = $1 if defined $1;
		$value = $2 if defined $2;

		if ($value =~ /^(6|10|12|15|17|20|30|40|80|160)$/) {
				$_[0]->{'band'} = $value;
		}
		elsif (my $tmp = &ishamfreq($value)) {
				$_[0]->{'band'} = $tmp;
		}
		else {				# Number entered is not a freqency in a ham band
			return 0;
		}
		&rigctld($value) if $main::rigctld;
		$_[0]->{'call'} = '';
		${$_[1]} = 0;				# cursor position
		
		&rigctl($value) if $main::rigctl;
		$_[0]->{'call'} = '';
		${$_[1]} = 0;				# cursor position
	}
	elsif ($_[0]->{'call'} =~ /^(CW|SSB|RTTY|P31|P63)$/) {
		$_[0]->{'mode'} = $1;
		&rigctld($1) if $main::rigctld;
		$_[0]->{'call'} = '';
		${$_[1]} = 0;				# cursor position
		$_[0]->{'mode'} = $1;
		&rigctl($1) if $main::rigctl;
		$_[0]->{'call'} = '';
		${$_[1]} = 0;
		
		if ($1 eq 'SSB') {
			$_[0]->{'rst'} = '59';
		}
		else {
			$_[0]->{'rst'} = '599';
		}

	}
#	elsif ($_[0]->{'call'} =~ /^(CW|SSB|RTTY|P31|P63)$/) {
#		$_[0]->{'mode'} = $1;
#		&rigctld($1) if $main::rigctld;
#		$_[0]->{'call'} = '';
#		${$_[1]} = 0;				# cursor position

#		if ($1 eq 'SSB') {
#			$_[0]->{'rst'} = '59';
#		}
#		else {
#			$_[0]->{'rst'} = '599';
#		}

#	}


}

# QSY band up or down
sub qsyband {
	my $direction = shift;
	my $currentband = $main::qso{'band'};
	my @bands = qw/160 80 40 30 20 17 15 12 10/;
	my $pos=0;

	for (0..$#bands) {
		$pos = $_ if ($bands[$_] eq $currentband);
	}

	if ($direction eq 'up') {
		$main::qso{'band'} = $bands[($pos+1) % ($#bands+1)];		
	}
	else {
		$main::qso{'band'} = $bands[($pos-1) % ($#bands+1)];		
	}
}

sub togglemode {
	if ($main::qso{'mode'} eq 'SSB') {
		$main::qso{'mode'} = 'CW';
	}
	elsif ($main::qso{'mode'} eq 'CW') {
		$main::qso{'mode'} = 'RTTY';
	}
	else {
		$main::qso{'mode'} = 'SSB';
	}
}

# Convert a freq to a band, otherwise return 0
sub ishamfreq {
	my $freq = shift;
	if (($freq >= 1800) && ($freq <= 2000)) { return 160 }
	elsif (($freq >= 3500) && ($freq <= 4000)) { return 80 }
	elsif (($freq >= 7000) && ($freq <= 7300)) { return 40 }
	elsif (($freq >= 10100) && ($freq <= 10150)) { return 30 }
	elsif (($freq >= 14000) && ($freq <= 14350)) { return 20 }
	elsif (($freq >= 18068) && ($freq <= 18168)) { return 17 }
	elsif (($freq >= 21000) && ($freq <= 21450)) { return 15 }
	elsif (($freq >= 24890) && ($freq <= 24990)) { return 12 }
	elsif (($freq >= 28000) && ($freq <= 29700)) { return 10 }
	elsif (($freq >= 50000) && ($freq <= 54000)) { return 6 }
	else { return 0 }
}





return 1;

# Local Variables:
# tab-width:4
# End: **

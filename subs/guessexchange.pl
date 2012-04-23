
# FOC marathon
my %foc;
if (-e 'call_no_name.txt') {

open FOC, find_file('call_no_name.txt');
my $line;
while ($line = <FOC>) {
	map {s/\r//g;} ($line);
	chomp($line);
	$line =~ s/"//g;
	my @a = split(/,/, $line);
	$foc{$a[0]} = $a[1];	# Call = Name, Nr
}
close FOC;

}



sub guessexchange {

	if ($_[0] == 1) {


	if ($main::contest eq 'CQWW') {
		if ($main::lastguessed eq $main::qso{call}) {		# only guess once!
			return '';
		}
		my $zone = (&dxcc($main::qso{call}))[1];
		if ($zone) {
			$main::lastguessed = $main::qso{call};
			return $zone;
		}
		else {				# invalid call?
			return '';
		}
	} # CQWW
	if (($main::contest eq 'GACW-DX') || ($main::contest eq 'GACW')){
		if ($main::lastguessed eq $main::qso{call}) {		# only guess once!
			return '';
		}
		my $zone = (&dxcc($main::qso{call}))[1];
		if ($zone) {
			$main::lastguessed = $main::qso{call};
			return $zone;
		}
		else {				# invalid call?
			return '';
		}
	} # GACW	
	if ($main::contest eq 'IARU') {
		if ($main::lastguessed eq $main::qso{call}) {		# only guess once!
			return '';
		}
		my $itu = (&dxcc($main::qso{call}))[2];
		if ($itu) {
			$main::lastguessed = $main::qso{call};
			return $itu;
		}
		else {				# invalid call?
			return '';
		}
	} # IARU
	elsif ($main::contest eq 'FOC') {
		if ($main::lastguessed eq $main::qso{call}) {
			return '';
		}
		if (defined($foc{$main::qso{call}})) {
			return $foc{$main::qso{call}}
		}
	}
	elsif ($main::contest =~ /ARRLDX/) {	# Guess States/Power
		if ($main::lastguessed eq $main::qso{call}) {
			return '';
		}
		if (defined($main::guesshash{$main::qso{call}})) {
			return $main::guesshash{$main::qso{call}}
		}
	}
	elsif ($main::contest =~ /ALLASIAN/) {
		if ($main::lastguessed eq $main::qso{call}) {
			return '';
		}
		if (defined($main::guesshash{$main::qso{call}})) {
			return $main::guesshash{$main::qso{call}}
		}
	}
	elsif ($main::contest =~ /ARRL-FD/) {
		if ($main::lastguessed eq $main::qso{call}) {
			return '';
		}
		if (defined($main::guesshash{$main::qso{call}})) {
			return (split(/\//, $main::guesshash{$main::qso{call}}))[0];
		}
	}
#	elsif ($main::contest =~ /QRP-TTF/) {
#		if ($main::lastguessed eq $main::qso{call}) {
#			return '';
#		}
#		if (defined($main::guesshash{$main::qso{call}})) {
#			return (split(/!/, $main::guesshash{$main::qso{call}}))[0];
#		}
#	}

	} # guess exchange 1
#	else { # guess exchange 2
	elsif ($_[0] == 2) {

		if ($main::contest =~ /ARRL-FD/) {
			if ($main::lastguessed eq $main::qso{call}) {
				return '';
			}
			if (defined($main::guesshash{$main::qso{call}})) {
				return (split(/\//, $main::guesshash{$main::qso{call}}))[1];
			}
		}
		if ($main::contest =~ /QRP-TTF/) {
			if ($main::lastguessed eq $main::qso{call}) {
				return '';
			}
			if (defined($main::guesshash{$main::qso{call}})) {
				return (split(/!/, $main::guesshash{$main::qso{call}}))[1];
			}
		}
		if ($main::contest eq 'NRA') {
			if ($main::lastguessed eq $main::qso{call}) {		# only guess once!
				return '';
			}
			my $zone = (&dxcc($main::qso{call}))[1];
			if ($zone) {
				$main::lastguessed = $main::qso{call};
				return $zone;
			}
			else {				# invalid call?
				return '';
			}
		}
#		if ($main::contest eq 'IOTA') {
#			if ($main::lastguessed eq $main::qso{call}) {		# only guess once!
#				return '';
#			}
#			my $iota = (&dxcc($main::iota{$call}))[1];
#			if ($iota) {
#				$main::lastguessed = $main::iota{$call};
#				return $zone;
#			}
#			else {				# invalid call?
#				return '';
#			}
#		}
	}
	elsif ($_[0] == 3) { # guess exchange 3
		if ($main::contest =~ /QRP-TTF/) {
			if ($main::lastguessed eq $main::qso{call}) {
				return '';
			}
			if (defined($main::guesshash{$main::qso{call}})) {
				return (split(/!/, $main::guesshash{$main::qso{call}}))[2];
			}
		}
	}


}

return 1;

# Local Variables:
# tab-width:4
# End: **

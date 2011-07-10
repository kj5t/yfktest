$| = 1;

sub rigctld {

	my $band = shift;
	my $freq='';
	my $mode='';

	if ($band eq 'get') {
			if (!$main::hamlibsock) {
				return 0;					# XXX maybe try to reconnect?
			}

		    print $main::hamlibsock "f\n";
		    $freq = <$main::hamlibsock>;
		    chomp($freq);

			print $main::hamlibsock "m\n";
			$mode = <$main::hamlibsock>;
			<$main::hamlibsock>;			# bandwidth and END not needed..
			chomp($mode);

			if ($mode =~ /CW/) {	# CW, CWR
				$mode = "CW";
			}
			elsif ($mode =~ /SB/) {
				$mode = "SSB";
			}


		unless ($freq =~ /^[0-9]+$/) {
			return 0;
		}
		
		$freq /= 1000000;
		
addstr($wmain, 23, 40, "$freq MHz      ");

		$main::qso{'freq'} = $freq;
		
		if (($freq >= 1.800) && ($freq <= 2.000)) { $freq = "160"; }
		elsif (($freq >= 3.500) && ($freq <= 4.000)) { $freq = "80"; }
		elsif (($freq >= 5.250) && ($freq <= 5.450)) { $freq = "60"; }
		elsif (($freq >= 7.000) && ($freq <= 7.300)) { $freq = "40"; }
		elsif (($freq >=10.100) && ($freq <=10.150)) { $freq = "30"; }
		elsif (($freq >=14.000) && ($freq <=14.350)) { $freq = "20"; }
		elsif (($freq >=18.068) && ($freq <=18.168)) { $freq = "17"; }
		elsif (($freq >=21.000) && ($freq <=21.450)) { $freq = "15"; }
		elsif (($freq >=24.890) && ($freq <=24.990)) { $freq = "12"; }
		elsif (($freq >=28.000) && ($freq <=29.700)) { $freq = "10"; }
		elsif (($freq >=50.000) && ($freq <=54.000)) { $freq = "6"; }
		elsif (($freq >=144.000) && ($freq <=148.000)) { $freq = "2"; }
		else {
			return 0;
		}
			
		$main::qso{'band'} = $freq if $freq;
		$main::qso{'mode'} = $mode;# unless ($main::qso{'mode'} eq 'RTTY');
	} #get
	else {	# set band or mode
		if ($band =~ /SSB|CW|RTTY/) {

			$mode = '';

			if ($band eq 'RTTY') { #return 1; }
					print $main::hamlibsock "M RTTY 0";
			}
			elsif ($band eq 'CW') {
					print $main::hamlibsock "M CW 0";
			}
			elsif ($band eq 'SSB') {
				if ($qso{'band'} > 20) {
						print $main::hamlibsock "M LSB 0";
				}
				else {
						print $main::hamlibsock "M USB 0";
				}
			}
		}
		elsif ($band =~ /^[0-9]+$/) {			# band/freq
			if ($band eq '6') { $band = '50000000'; }
			elsif ($band eq '10') { $band = '28000000'; }
			elsif ($band eq '12') { $band = '24890000'; }
			elsif ($band eq '15') { $band = '21000000'; }
			elsif ($band eq '17') { $band = '18068000'; }
			elsif ($band eq '20') { $band = '14000000'; }
			elsif ($band eq '30') { $band = '10100000'; }
			elsif ($band eq '40') { $band = '7000000'; }
			elsif ($band eq '60') { $band = '5250000'; }
			elsif ($band eq '80') { $band = '3500000'; }
			elsif ($band eq '160') { $band = '1800000'; }
			# if nothing matched, it was a frequency which will be passed right
			# through, after conversion mHz to Hz
			else { $band *= 1000 }

				print $main::hamlibsock "F $band";
		}
	}
	$main::counter = 0;
}





return 1;

# Local Variables:
# tab-width:4
# End: **

#| = 1;

sub rigctld {

#	my ($freq, $mode);

#	my $sock = new IO::Socket::INET (PeerAddr => 'localhost',
#			PeerPort => '4532', Proto => 'tcp', type => SOCK_STREAM);

#	return 0 unless $sock;

	
	my $band = shift;
#	my $freq = '';
#	my $mode = '';

	if ($band eq 'get1') {
		print $sock "f";
		$freq = <$sock>;
		chomp($freq);
		<$sock>;
		
		print $sock "m";
		$mode = <$sock>;
		chomp($mode);
		
		
		if (($mode eq 'CW')||($mode eq 'CWR')) {
			$mode = 'CW';
		}
		elsif(($mode eq 'USB')||($mode eq 'LSB')) {
			$mode = 'SSB';
		}
		else {
			return 0;
		}

		unless ($freq =~ /^[0-9]+$/) {
			return 0;
		}

		$freq /= 1000;
			
		if (($freq >= 1800) && ($freq <= 2000)) { $freq = "160"; }
		elsif (($freq >= 3500) && ($freq <= 4000)) { $freq = "80"; }
		elsif (($freq >= 7000) && ($freq <= 7300)) { $freq = "40"; }
		elsif (($freq >=10100) && ($freq <=10150)) { $freq = "30"; }
		elsif (($freq >=14000) && ($freq <=14350)) { $freq = "20"; }
		elsif (($freq >=18068) && ($freq <=18168)) { $freq = "17"; }
		elsif (($freq >=21000) && ($freq <=21450)) { $freq = "15"; }
		elsif (($freq >=24890) && ($freq <=24990)) { $freq = "12"; }
		elsif (($freq >=28000) && ($freq <=29700)) { $freq = "10"; }
		elsif (($freq >=50000) && ($freq <=54000)) { $freq = "6"; }
#		elsif (($freq >=144000) && ($freq <=148000)) { $freq = "2"; }
		else {
			return 0;
		}
			
		$main::qso{'band'} = $freq if $freq;
		$main::qso{'mode'} = $mode unless ($main::qso{'mode'} eq 'RTTY');
	} #get
	else {	# set band or mode
		if ($band =~ /SSB|CW|RTTY/) {

			if ($band eq 'RTTY') {
				print $sock "M RTTY 0\n";
			}
			elsif ($band eq 'CW') {
				print $sock "M CW 0\n";
			}
			elsif ($band eq 'SSB') {
				if ($qso{'band'} > 20) {
					print $sock "M LSB 0\n";
				}
				else {
				print $sock "M USB 0\n";
				}
			}
		}
		else {			# band/freq
			if ($band eq '6') { $band = '50000000'; }
			elsif ($band eq '10') { $band = '28000000'; }
			elsif ($band eq '12') { $band = '24890000'; }
			elsif ($band eq '15') { $band = '21000000'; }
			elsif ($band eq '17') { $band = '18068000'; }
			elsif ($band eq '20') { $band = '14000000'; }
			elsif ($band eq '30') { $band = '10100000'; }
			elsif ($band eq '40') { $band = '7000000'; }
			elsif ($band eq '80') { $band = '3500000'; }
			elsif ($band eq '160') { $band = '1800000'; }
			# if nothing matched, it was a frequency which will be passed right
			# through, after conversion kHz to Hz
			else { $band *= 1000 }

			print $sock "F ".$band;

	return 1;
		}

	}

	$main::counter1 = 0;
}





return 1;

# Local Variables:
# tab-width:4
# End: **

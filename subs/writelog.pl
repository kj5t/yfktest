use strict;

sub writelog {
		my $i;
		my $cn = $main::cabrilloname;
		my @cabvalues;		# values of the cbr file, like mode, date,	freq...

		my %freq = (160 => 1800, 80 => 3500, 40 => 7000, 30 => 10100,
				20 => 14000, 17 => 18068, 15=>21000, 12 => 24890, 
				10 => 28000, 6 => 50000);

		if ($main::contest eq 'NAQP') {
			if ($main::exc1s =~ /\//) {
				my ($name, $state) = split(/\//, $main::exc1s);
				$main::exc1s = sprintf("%-10s %2s", $name, $state);
			}
		}

		# cabrillo first
		open CBR, ">$main::filename.cbr";

		# for stuff like CQ-WPX-CW ...
		$cn =~ s/!MODE!/$main::modes/;

		print CBR "START-OF-LOG: 3\r\n";
		print CBR "CALLSIGN: $main::mycall\r\n";
		print CBR "CATEGORY-ASSISTED: $main::assisted\r\n";
		print CBR "CATEGORY-BAND: $main::bands\r\n";
		print CBR "CATEGORY-MODE: $main::modes\r\n";
		print CBR "CATEGORY-OPERATOR: $main::operator\r\n";
		print CBR "CATEGORY-POWER: $main::power\r\n";
		print CBR "CATEGORY-TRANSMITTER: $main::transmitter\r\n";
		print CBR "CLAIMED-SCORE: $main::s_sum\r\n";
		print CBR "CLUB: \r\n";
		print CBR "CONTEST: $cn\r\n";
		print CBR "CREATED-BY: YFKtest $main::version\r\n";
		print CBR "LOCATION: \r\n" if ($main::contest eq 'IOTA');
		if ($main::contest eq 'ARRLDX-DX') {
			print CBR "LOCATION: DX\r\n";
		}
		elsif ($main::contest eq 'ARRLDX-US') {
			print CBR "LOCATION: $main::exc1s\r\n";
		}
		print CBR "NAME: \r\n";
		print CBR "ADDRESS: \r\n";
		print CBR "ADDRESS: \r\n";
		print CBR "ADDRESS: \r\n";
		print CBR "ADDRESS: \r\n";
		print CBR "OPERATORS: $main::mycall \r\n";
		print CBR "SOAPBOX: \r\n";

		# actual log...
		@cabvalues = split(/\s+/, $main::cabrillovalues);
		foreach $i (0.. $#main::qsos) {

				my @values;

				foreach (@cabvalues) {
					if ($_ eq 'mycall') {
						push @values, $main::mycall;
					}
#					elsif ($_ eq 'band') {
#						push @values, $freq{$main::qsos[$i]{'band'}};
#					}
#					elsif ($qso{freq} > 0) {
#						push @values, $main::qsos[$i]{'freq'};
#					}	
					elsif ($_ =~ /^freq/) {
						if ($main::qsos[$i]{'freq'}) {
						push @values, $main::qsos[$i]{'freq'} /=0.001;
						}
						else {
							push @values, $freq{$main::qsos[$i]{'band'}};
						}
					}
					elsif ($_ =~ /^rst/) {
						if ($main::qsos[$i]{'mode'} eq 'SSB') {
							push @values, '59';
						}
						else {
							push @values, '599';
						}
					}
					elsif ($_ eq 'mode') {
						if ($main::qsos[$i]{'mode'} eq 'SSB') {
							push @values, 'PH';
						}
						elsif ($main::qsos[$i]{'mode'} eq 'RTTY') {
							push @values, 'RY';
						}
						elsif ($main::qsos[$i]{'mode'} eq 'CW') {
							push @values, 'CW';
						}
						elsif ($main::qsos[$i]{'mode'} eq 'P31') {
							push @values, 'P3';
						}
						elsif ($main::qsos[$i]{'mode'} eq 'P63') {
							push @values, 'P6';
						}
						else {
							push @values, '??';
						}
					}
					elsif ($_ eq 'exc1s') {
							push @values, $main::exc1s;
					}
					elsif ($_ eq 'exc2s') {
							push @values, $main::exc2s;
					}
					elsif ($_ eq 'stn') {
							$main::qsos[$i]{stn} =~ /(\d)$/;
							push @values, $1;
					}
					elsif (defined($main::qsos[$i]{$_})) {
						push @values, $main::qsos[$i]{$_};
					}
				
				}

				# Some contest specific exceptions...

				if ($main::contest eq 'IOTA') {
					unless ($values[11]) {
							$values[11] .= '------';
					}
					else {
						$values[11] =~ s/([A-Z]{2})/$1-/;
					}
				}
				elsif ($main::contest eq 'CQIR') {
						$values[11] .= '---' unless $values[11];
						$values[7] .= '---' unless $values[7];
				}
				elsif ($main::contest eq 'NAVAL') {
						if ($main::exc1s ne '') {
							$values[6] = $main::exc1s;
						}
				}
			


				print CBR sprintf($main::cabrilloline."\r\n", @values);
		}
		
		print CBR "END-OF-LOG:\r\n";
		close CBR;


		# ADIF
		open ADIF, ">$main::filename.adi";

		print ADIF "YFKtest log for $main::mycall in $main::contest Contest".
					"\r\n\r\n<eoh>\r\n";

		foreach $i (0..$#main::qsos) {

			print ADIF "<call:".length($main::qsos[$i]{'call'}).'>'.
					$main::qsos[$i]{'call'}.' ';

			my $date = $main::qsos[$i]{'date'};
			$date =~ s/-//g;
			print ADIF "<qso_date:8>".$date.' ';
			print ADIF "<time_on:4>".$main::qsos[$i]{'utc'}."\r\n";

			print ADIF "<band:".(length($main::qsos[$i]{'band'})+1).'>'.
					$main::qsos[$i]{'band'}.'m  ';

			if ($main::qsos[$i]{'freq'}) {
			print ADIF "<freq:".(length($main::qsos[$i]{'freq'})).'>'.
					(($main::qsos[$i]{'freq'} /=1000).' ');
								}
			else {
					print ADIF " ";
			}
					
			my $mode = $main::qsos[$i]{'mode'};
			if ($mode eq 'P31') { $mode = 'PSK31'; }
			if ($mode eq 'P63') { $mode = 'PSK63'; }
			print ADIF "<mode:".length($mode).'>'.
					$mode.'  ';

			my $rst = '599';
			if ($main::qsos[$i]{'mode'} eq 'SSB') { 
					$rst = '59';
			}

			print ADIF "<rst_sent:".length($rst).'>'.$rst.' ';
			print ADIF "<rst_rcvd:".length($rst).'>'.$rst.' ';
			
			print ADIF "<stx:".length($i+1).'>'.($i+1).' ';

			if ($main::qsos[$i]{'exc1'} =~ /^\d+$/) {	
				print ADIF "<srx:".length($main::qsos[$i]{'exc1'}).'>'.
					($main::qsos[$i]{'exc1'}+1).' ';
			}

			print ADIF "\r\n";

			# contest specific exchanges...
			if (($main::contest eq 'IOTA') && $main::qsos[$i]{'exc2'}) {
				my $iota = $main::qsos[$i]{'exc2'};
				$iota =~ s/([A-Z]{2})/$1-/;
				print ADIF "<iota:6>".$iota.' ';

			}
			elsif ($main::contest eq 'CQWW') {
				print ADIF "<cqz:".length($main::qsos[$i]{'exc1'}).'>'.
						$main::qsos[$i]{'exc1'}.' ';
			}
			elsif (($main::contest eq 'IARU') && 
					($main::qsos[$i]{'exc1'} =~ /^\d+$/)) {
				print ADIF "<ituz:".length($main::qsos[$i]{'exc1'}).'>'.
						$main::qsos[$i]{'exc1'}.' ';

			}

			print ADIF "\r\n<eor>\r\n\r\n";

		}
		close ADIF;

		# SUM File
		
		open SUM, ">$main::filename.sum";
		
		print SUM "Contest             : $main::contest \r\n";
		print SUM "Callsign            : $main::mycall \r\n";
		print SUM "Mode                : $main::modes \r\n";
		print SUM "Operator            : $main::operator \r\n";
		print SUM "Transmitter         : $main::transmitter \r\n";
		print SUM "Assisted            : $main::assisted \r\n";
		print SUM "Power               : $main::power \r\n";
		print SUM "Sent Exchange       : $main::exc1s"."$main::exc2s \r\n";
		print SUM "\r\n";
		print SUM "Band    QSO    Qpts   Dupes   Mult1   Mult2\r\n";
		print SUM "-------------------------------------------\r\n";


		my ($t_qso, $t_qsopts, $t_dupes, $t_mult1, $t_mult2) = (0,0,0,0,0);

		foreach (sort {$a <=> $b} keys %main::s_qsos) {
			$t_qso  += $main::s_qsos{$_};
			$t_qsopts  += $main::s_qsopts{$_};
			$t_dupes  += $main::s_dupes{$_};
			$t_mult1  += &count($main::s_mult1{$_});
			$t_mult2  += &count($main::s_mult2{$_});
			printf(SUM "%4d   %4d    %4d    %4d    %4d     %3d\r\n", 
					$_, $main::s_qsos{$_}, 
					$main::s_qsopts{$_}, $main::s_dupes{$_},
					&count($main::s_mult1{$_}), &count($main::s_mult2{$_}),
					);
		}
		print SUM "-------------------------------------------\r\n";
	
		$t_mult1  += &count($main::s_mult1{'All'});
		$t_mult2  += &count($main::s_mult2{'All'});

		my $s_sum = $main::s_sum;
		1 while $s_sum =~ s/^(\d+)(\d{3,3})/$1.$2/;

		printf(SUM " ALL   %4d    %4d    %4d    %4d     %3d\r\n"
				, $t_qso, $t_qsopts, $t_dupes, $t_mult1, $t_mult2);
		
		print SUM "===========================================\r\n";
		
		print SUM " Total Score: $s_sum \r\n\r\n ";
		
		print SUM " Logged with YFKtest v$main::version\r\n";

		close SUM;

	curs_set(0);
	addstr($main::wmain, 23,18, "Files written...");
	refresh($main::wmain);
	sleep 1;
	addstr($main::wmain, 23,18, "                ");
	refresh($main::wmain);

	return 1;

}




#sub count {
#		my @a = split(/\s+/, $_[0]);
#		return $#a;
#}




return 1;

# Local Variables:
# tab-width:4
# End: **

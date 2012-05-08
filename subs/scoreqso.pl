
sub scoreqso {
	load_subs("dxcc.pl");
	
	my %qso = %{$_[0]};
	my $qsoref = $_[1];		# ref to QSO AoH
	my $s_qsos = $_[2];
	my $s_qsopts = $_[3];
	my $s_mult1 = $_[4];
	my $s_mult2 = $_[5];
	my $s_dupes = $_[6];

	# IOTA test
#	$defqsopts = 'dx=5~cont=3~own=1~exc2=((AF|AS|NA|SA|EU|AN)\d{3,3})=15';
#	$defqsopts = 'dx=6~cont=3~own=1~exc2=((AF|AS|NA|SA|EU|AN)\d{3,3})=15';

# Check for dupe

	unless ($main::contest eq 'NCCC-SPRINT') {
		foreach (@{$qsoref}) {
			if (($_->{'call'} eq $qso{'call'}) &&
				($_->{'band'} eq $qso{'band'}) &&
				($_->{'mode'} eq $qso{'mode'}) &&	
				($_->{'nr'} < $qso{'nr'}-1)) {
					$s_dupes->{$qso{'band'}}++;
					return 1;
			}
		}	
	}

	# handy vars to use
	#  Although there is no need to spell these out specifically, it
	#  makes less knowledgeable perl users have an easier and simpiler
	#  time writing rulls in the .def files.
	my $band = $qso{'band'};
	my $call = $qso{'call'};
	my $mode = $qso{'mode'};
	my $exc1 = $qso{'exc1'};
	my $exc2 = $qso{'exc2'};
	my ($cont, $dxcc) = (&dxcc($qso{'call'}))[3,7];
	my $score = 1;
	
	# Not a dupe if here, so do scoring
	
	$s_qsos->{$qso{'band'}}++;

	# QSO-Points can be determined by:
	# * Nothing; fixed
	# * DX=x, same Cont=y, same DXCC=z, $field matching $regex = p

	if (exists($main::coderefs{$main::contest}{'SCORE'})) {

		# eval the code, which should:
		#  - set $score to the score value for the QSO (defaults to 1)
		eval $main::coderefs{$main::contest}{'SCORE'} or die $@;

		$s_qsopts->{$qso{'band'}} += $score;
	} elsif ($main::defqsopts eq 'iaru') {
		(undef, undef, undef, my $cont, undef, undef, undef, undef, undef) 
						= &dxcc($qso{'call'});

		if ($qso{'exc1'} =~ /^\d+$/) {		# ITU Zone
			if ($main::exc1s eq $qso{'exc1'}) {
				$s_qsopts->{$qso{'band'}} += 1;
			}
			elsif ($cont eq $main::mycont) {
				$s_qsopts->{$qso{'band'}} += 3;
			}
			else {
				$s_qsopts->{$qso{'band'}} += 5;
			}
		}
		else {	# HQ or R123/AC. The latter will be wrong but I don't care
				$s_qsopts->{$qso{'band'}} += 1;
		}
	}
	elsif ($main::defqsopts =~ /fixed=(\d+)/) {
			$s_qsopts->{$qso{'band'}} += $1;
	}
	elsif ($main::defqsopts eq 'wpx') {
		my $dxpts = 3;
		my $contpts = 1;
		my $ownpts = 1;
		my ($dxcc, $cont);
			
		(undef, undef, undef, $cont, undef, undef, undef, $dxcc) 
				 = &dxcc($qso{'call'});

			if (($cont eq $main::mycont) && ($main::mycont eq 'NA')) {
				$contpts = 2;
			}
			
			if ($qso{'band'} > 20) {
				$dxpts *= 2;
				$contpts *= 2;
			}

			if ($main::mycont ne $cont) {
				$s_qsopts->{$qso{'band'}} += $dxpts;
			}
			elsif ($main::mydxcc ne $dxcc) {
				$s_qsopts->{$qso{'band'}} += $contpts;
			}
			else {
				$s_qsopts->{$qso{'band'}} += $ownpts;
			}
	}	#dx,cont,own,regex
	elsif($main::defqsopts eq 'nra' ) {
		my $cqzone = $qso{'exc2'};
		if ($cqzone eq $main::exc2s) {		# same CQ zone
			if ($qso{band} < 40) {			# 20-10m
				$s_qsopts->{$qso{'band'}} += 4;
			}
			else {							# 40-80m
				$s_qsopts->{$qso{'band'}} += 2;
			}
		}
		else {								# other zone
			if ($qso{band} < 40) {			# 20-10m
				$s_qsopts->{$qso{'band'}} += 8;
			}
			else {							# 40-80m
				$s_qsopts->{$qso{'band'}} += 6;
			}
		}
	}
	elsif($main::defqsopts eq 'epc' ) {
		my ($cont, $dxcc) = (&dxcc($qso{'call'}))[3,7];
		if ($dxcc eq $main::mydxcc) {		# same DXCC country
			$s_qsopts->{$qso{'band'}} += 1;
		}
			if ($qso{call} =~ /\/(MM)/i) {
					$s_qsopts-> {$qso{'band'}} += 3;
			}
		elsif ($cont eq $main::mycont) {
			if ($qso{band} > 15) {			# 20-80m
				$s_qsopts->{$qso{'band'}} += 2;
			}
			else {							# 40-80m
				$s_qsopts->{$qso{'band'}} += 3;
			}
		}
		elsif ($cont ne $main::mycont) {
			if ($qso{band} == 40) {			# 40m
				$s_qsopts->{$qso{'band'}} += 4;
			}
			elsif ($qso{band} == 20){				# 20m
				$s_qsopts->{$qso{'band'}} += 4;
			}
			elsif ($qso{band} == 15){				# 15m
				$s_qsopts->{$qso{'band'}} += 4;
			}
			elsif ($qso{band} == 10){				# 10m
				$s_qsopts->{$qso{'band'}} += 5;
			}
			elsif ($qso{band} == 80){							# 40-80m
				$s_qsopts->{$qso{'band'}} += 6;
			}
		}
	}
	elsif ($main::defqsopts eq 'gacw-dx') {
		my ($cont, $dxcc) = (&dxcc($qso{'call'}))[3,7];
		if ($dxcc eq $main::mydxcc) {		# same DXCC country
			$s_qsopts->{$qso{'band'}} += 0;
		}
		elsif ($cont eq 'SA') {
			$s_qsopts->{$qso{'band'}} += 5;
		}
		elsif ($cont eq $main::mycont) {
			$s_qsopts->{$qso{'band'}} += 1;
		}
		else {							
			$s_qsopts->{$qso{'band'}} += 3;
		}
	}
	elsif ($main::defqsopts eq 'gacw') {
		my ($cont, $dxcc) = (&dxcc($qso{'call'}))[3,7];
		if ($dxcc eq $main::mydxcc) {		# same DXCC country
			$s_qsopts->{$qso{'band'}} += 0;
		}
		elsif ($cont eq $main::mycont) {
			$s_qsopts->{$qso{'band'}} += 1;
		}
		else {							
			$s_qsopts->{$qso{'band'}} += 3;
		}
	}
	elsif($main::defqsopts=~/dx=(\d+)~cont=(\d+)~own=(\d+)~(\w+)=(.+?)=(\d+)/) {
			my $dxpts = $1;
			my $contpts = $2;
			my $ownpts = $3;
			my $field = $4;
			my $regex = $5;
			my $specialpts = $6;
			my ($cont, $dxcc);
			my $modemult = 1;		# different pts for CW and SSB?

			(undef, undef, undef, $cont, undef, undef, 
				undef, $dxcc)	= &dxcc($qso{'call'});


			if ($main::contest eq 'CQIR') {
				if ($qso{'mode'} eq 'SSB') { $modemult = 2; }
				else { $modemult = 3; }
			}

			if ($qso{$field} =~ /$regex/) {	
				if ($main::contest eq 'IOTA') {
						my $iota = $qso{'exc2'};
						$iota =~ s/([A-Z]{2})/$1-/;
						if ($iota eq $main::exc2s) {	#same island
							$specialpts = 3;
						}
				}

				$s_qsopts->{$qso{'band'}} += ($specialpts * $modemult);

			}
			elsif ($main::mycont ne $cont) {
				$s_qsopts->{$qso{'band'}} += ($dxpts * $modemult);
			}
			elsif ($main::mydxcc ne $dxcc) {
				$s_qsopts->{$qso{'band'}} += ($contpts * $modemult);
				# CQWW: NA-NA QSOs one point more
				if (($main::contest eq 'CQWW') && ($main::mycont eq 'NA')) {
					$s_qsopts->{$qso{'band'}} += 1;
				}
			}
			else {
				$s_qsopts->{$qso{'band'}} += ($ownpts * $modemult);
				# CQWW: NA-NA QSOs with same country = 2 points 
				if (($main::contest eq 'CQWW') && ($main::mycont eq 'NA')) {
					$s_qsopts->{$qso{'band'}} += 2;
				}
			}
	}	#dx,cont,own,regex
	elsif ($main::defqsopts eq 'rdac-dx') {
		my $dxcc;
		$dxcc = (&dxcc($qso{'call'}))[7];

		if ($dxcc =~ /^UA/) {
			$s_qsopts->{$qso{'band'}} += 10;
		}
	} # RDAC-DX
	elsif ($main::defqsopts eq 'rdac-ru') {
		my ($cont, $dxcc) = (&dxcc($qso{'call'}))[3,7];

		if (($dxcc =~ /^UA/) && ($qso{'call'} =~ /\//)) {	# C1 / C2
			$s_qsopts->{$qso{'band'}} += 10;
		}
		elsif ($dxcc eq $main::mydxcc) {			# Own country
			$s_qsopts->{$qso{'band'}} += 1;
		}
		elsif (($cont ne $main::mycont) && ($dxcc =~ /^UA/)) {	# UA, diff cont
			$s_qsopts->{$qso{'band'}} += 2;
		}
		elsif (($cont eq $main::mycont) && ($dxcc ne $main::mydxcc)) {
			$s_qsopts->{$qso{'band'}} += 3;
		}
		else {	# DX
			$s_qsopts->{$qso{'band'}} += 5;
		}
	}
	elsif ($main::defqsopts eq 'rdxc-dx') {
		my ($cont, $dxcc) = (&dxcc($qso{'call'}))[3,7];

		if ($dxcc =~ /^UA/) {
			$s_qsopts->{$qso{'band'}} += 10;
		}
		elsif ($dxcc =~ /^UA2/) {
			$s_qsopts->{$qso{'band'}} += 10;
		}
		elsif ($dxcc =~ /^R1FJ/) {
			$s_qsopts->{$qso{'band'}} += 10;
		}
		elsif ($dxcc =~ /^R1MV/) {
			$s_qsopts->{$qso{'band'}} += 10;
		}
		elsif ($qso{call} eq 'R1AN') {
			$s_qsopts->{$qso{'band'}} += 10;
		}
		elsif ($qso{call} eq 'R1ANF') {
			$s_qsopts->{$qso{'band'}} += 10;
		}
		elsif ($dxcc =~ /^UA9/) {
			$s_qsopts->{$qso{'band'}} += 10;
		}
		elsif (($cont eq $main::mycont) && ($dxcc ne $main::mydxcc)) {
			$s_qsopts->{$qso{'band'}} += 3;
		}
		elsif ($dxcc eq $main::mydxcc) {
			$s_qsopts->{$qso{'band'}} += 2;
		}
		else {	# DX
			$s_qsopts->{$qso{'band'}} += 5;
		}
	} # RDXC-DX
	elsif ($main::defqsopts eq 'rdxc-ru') {
		my ($cont, $dxcc) = (&dxcc($qso{'call'}))[3,7];

		if (($dxcc =~ /^UA/) && ($qso{'call'} =~ /\//)) {	# C1 / C2
			$s_qsopts->{$qso{'band'}} += 2;
		}
		elsif ($dxcc =~ /^UA9/) {
			$s_qsopts->{$qso{'band'}} += 5;
		}
		elsif ($dxcc =~ /^R1FJ/) {
			$s_qsopts->{$qso{'band'}} += 2;
		}
		elsif ($dxcc =~ /^R1MV/) {
			$s_qsopts->{$qso{'band'}} += 2;
		}
		elsif ($dxcc =~ /^R1AN/) {
			$s_qsopts->{$qso{'band'}} += 5;
		}
		elsif (($cont eq $main::mycont) && ($dxcc =~ /^UA2/)) {
			$s_qsopts->{$qso{'band'}} += 2;
		}
		elsif (($cont ne $main::mycont) && ($dxcc =~ /^UA/)) {	# UA, diff cont
			$s_qsopts->{$qso{'band'}} += 5;
		}
		elsif (($cont eq $main::mycont) && ($dxcc ne $main::mydxcc)) {
			$s_qsopts->{$qso{'band'}} += 3;
		}
		else {	# DX
			$s_qsopts->{$qso{'band'}} += 5;
		}
	}
	elsif ($main::defqsopts eq 'almeihf') {
		my $dxcc;
		$dxcc = (&dxcc($qso{'call'}))[7];

		if ($dxcc =~ /^CT/) {
			$s_qsopts->{$qso{'band'}} += 3;
			
			    if ($qso{call} eq 'CT1ARR') {
					$s_qsopts-> {$qso{'band'}} = 6;# $ct1arr = 6;
			    }

		}
		else {	# DX
		$s_qsopts->{$qso{'band'}} += 1;
		}
		
	} # ALMEI-DX
	elsif ($main::defqsopts eq 'naqp') {
		my ($cont, $dxcc) = (&dxcc($qso{'call'}))[3,7];
		
		if (($cont eq 'NA') || ($dxcc eq 'KH6')) {
			$s_qsopts->{$qso{'band'}} += 1;
		}
	}
	elsif ($main::defqsopts eq 'reg1fd') {
		my ($cont, $dxcc) = (&dxcc($qso{'call'}))[3,7];

		my ($myportable, $otherportable) = (0,0);
		if ($qso{'call'} =~ /\/(P|M|MM|AM)/i) { $otherportable = 1; }
		if ($main::mycall =~ /\/(P|M|MM|AM)/i) { $myportable = 1; }

		if (($myportable + $otherportable) == 0) {		# fixed<->fixed
			$s_qsopts->{$qso{'band'}} += 0;
		}
		elsif ($cont eq 'EU') {							# EU
			if ($otherportable) { $s_qsopts->{$qso{'band'}} += 4; }
			else { $s_qsopts->{$qso{'band'}} += 2; }
		}
		else {											# DX
			if ($otherportable) { $s_qsopts->{$qso{'band'}} += 6; }
			else { $s_qsopts->{$qso{'band'}} += 3; }
		}
	}
	elsif ($main::defqsopts eq 'reg1fd-irts') {
		my ($cont, $dxcc) = (&dxcc($qso{'call'}))[3,7];

		my ($myportable, $otherportable) = (0,0);
		if ($qso{'call'} =~ /\/(P|M|MM|AM)/i) { $otherportable = 1; }
		if ($main::mycall =~ /\/(P|M|MM|AM)/i) { $myportable = 1; }

		if (($myportable + $otherportable) == 0) {		# fixed<->fixed
			$s_qsopts->{$qso{'band'}} += 0;
		}
		elsif ($dxcc =~ /^(ZA|7X|C3|EK|OE|A9|EU|ON|T9|E7|A2|LZ|XT|TJ|TN|9A|5B|OK|9Q|OZ|J2|SU|ES|ET|OY|OH|Z3|F|TR|C5|4L|DL|9G|ZB2|SV|HA|TF|YI|EI|4X|I|TU|JY|UN|5Z|9K|YL|OD|7P|EL|HB0|LY|LX|TZ|9H|3B|ER|3A|JT|4O|CN|C9|V5|PA|5N|LA|A4|SP|CT|A7|3X|YO|R|T7|6W|YU|9L|OM|S5|ZS|EA|3DA|SM|HB9|YK|EY|5H|3V|TA|EZ|5X|UR|A6|G|9J|Z2)$/) {							# EU
			if ($otherportable) { $s_qsopts->{$qso{'band'}} += 5; }
			else { $s_qsopts->{$qso{'band'}} += 2; }
		}
		else {											# DX
			$s_qsopts->{$qso{'band'}} += 3; 
		}
	}
	elsif ($main::defqsopts eq 'sac') {
		my ($cont, $dxcc) = (&dxcc($qso{'call'}))[3,7];
		if ($dxcc =~ /(JW|JX|LA|OH|OH0|OJ0|OX|OZ|OY|SM|TF)/) {
			if (($main::mycont eq 'EU') || ($qso{'band'} < 40)) {
				$s_qsopts->{$qso{'band'}} += 1;
			}
			else {	# DX on lowbands
				$s_qsopts->{$qso{'band'}} += 3;
			}
		}
	}
	elsif ($main::defqsopts eq 'arrlfd') {
		if ($qso{mode} eq 'SSB' && $main::power eq 'HIGH') {
			$s_qsopts->{$qso{band}} += 1;
		}
		elsif ($qso{mode} eq 'SSB' && $main::power ne 'HIGH') {
			$s_qsopts->{$qso{band}} += 2;
		}
		elsif ($main::power eq 'LOW') {
			$s_qsopts->{$qso{band}} += 4;
		}
		elsif ($main::power eq 'QRP-BATTERY') {
			$s_qsopts->{$qso{band}} += 10;
		}
		else { # Just a 2x digital contact
			$s_qsopts->{$qso{band}} += 2;
		}
	}
	elsif ($main::defqsopts eq 'cncw') {
		my ($cont, $dxcc) = (&dxcc($qso{'call'}))[3,7];
		if ($dxcc =~ /^EA/) {
				$s_qsopts->{$qso{'band'}} += 1;
		}		
	}
	elsif ($main::defqsopts eq 'dtc') {
		if ($qso{'call'} =~ /0HSC|0RTC|DF0ACW|DL0AGC|DK0AG|DL0CWW|DL0DA/) {
				$s_qsopts->{$qso{'band'}} += 2;
		}
		else {
				$s_qsopts->{$qso{'band'}} += 1;
		}
		# No multipliers, just QSO-points. Create one multiplier so the final
		# score is not zero.
		$s_mult1->{$qso{'band'}} = ' 1 ';
	}
	elsif ($main::defqsopts eq 'ref-f') {
		my ($cont, $dxcc) = (&dxcc($qso{'call'}))[3,7];
		if ($dxcc =~ /^(F|TK)$/) {
				$s_qsopts->{$qso{'band'}} += 6;
		}
		elsif ($dxcc =~ /^(FM|FG|FS|FK|FT|FJ|FH|FO|FP|FR|FT|FW|FY)$/) {
				$s_qsopts->{$qso{'band'}} += 15;
		}
		elsif ($cont eq 'EU') {
				$s_qsopts->{$qso{'band'}} += 1;
		}
		else {
				$s_qsopts->{$qso{'band'}} += 2
		}
	}
	elsif ($main::defqsopts eq 'foc') {
		# QSO points: 1 for every member; double points for G4FOC.
		#             5-band QSO: +10 points, 6-band-QSO: +5 points
		#
		# The s_mult2 hash is used to save the worked members.
		# key = callsign, value = bands (e.g. $s_mult2{DJ1YFK} = "160 80 "

		if ($qso{exc1}) {			# Zero for non-members
			my $g4foc = 1;			# Multiplier for G4FOC?

			if ($qso{call} eq 'G4FOC') {
				$g4foc = 2;
			}

			# Make sure Hash is initialized.
			unless(defined($s_mult2->{$qso{call}})) {
				$s_mult2->{$qso{call}} = '';
			}
			
			# Add to hash if new band.
			unless ($s_mult2->{$qso{call}} =~ / $qso{band} /) {
					$s_mult2->{$qso{call}} .= " $qso{band} ";
			}

			# Count number of bands, add bonus accordingly.
			my @tmp = split(/\s+/, $s_mult2->{$qso{call}});
			
			if ($#tmp == 5) {
				$s_qsopts->{$qso{band}} += 11 * $g4foc;
			}
			elsif ($#tmp == 6) {
				$s_qsopts->{$qso{band}} += 6 * $g4foc;
			}
			else {
				$s_qsopts->{$qso{band}} += 1 * $g4foc;
			}
		}

	}
	elsif ($main::defqsopts eq 'arrl-dx') {
		my ($cont, $dxcc) = (&dxcc($qso{call}))[3,7];
		if ($dxcc =~ /^(K|VE)$/) {
				$s_qsopts->{$qso{band}} += 3;
		}
	}
	elsif ($main::defqsopts eq 'aa-dx') {
		my $cont = (&dxcc($qso{call}))[3];
		if ($cont eq 'AS') {
			if ($qso{band} eq '160') {
				$s_qsopts->{$qso{band}} += 3;
			}
			elsif ($qso{band} eq '80' || $qso{band} eq '10') {
				$s_qsopts->{$qso{band}} += 2;
			}
			else {
				$s_qsopts->{$qso{band}} += 1;
			}
		}
	}
	elsif ($main::defqsopts eq 'aa-as') {
		my $cont = (&dxcc($qso{call}))[3];
		my $scoremult = 1; 
		if ($cont ne 'AS') {
			$scoremult = 3;
		}

		if ($qso{band} eq '160') {
			$s_qsopts->{$qso{band}} += 3 * $scoremult;
		}
		elsif ($qso{band} eq '80' || $qso{band} eq '10') {
			$s_qsopts->{$qso{band}} += 2 * $scoremult;
		}
		else {
			$s_qsopts->{$qso{band}} += 1 * $scoremult;
		}
	}
	elsif ($main::defqsopts eq 'qrparci') {
		my ($cont, $dxcc) = (&dxcc($qso{'call'}))[3,7];
		if ($qso{'exc3'} =~ /^\d+$/) {		# ARCI Member number
			$s_qsopts->{$qso{'band'}} += 5;
		}
		else {
			if ($cont eq $main::mycont) {	# same continent
			$s_qsopts->{$qso{'band'}} += 2;
			}
			else {				# dx !!
			$s_qsopts->{$qso{'band'}} += 4;
			}
		}
	}
	elsif ($main::defqsopts eq 'nmqso') {
		if ($qso{mode} eq 'SSB') {
			$s_qsopts->{$qso{'band'}} += 1;
		}
		else { # Just a 2x "digital" contact
			$s_qsopts->{$qso{'band'}} += 2;
		}
	}
	elsif ($main::defqsopts eq 'nmqso-nonnm') {		# NM QSO Party - Non-NM
		my $qsopts=$qso{'exc2'};

		if (defined($qsopts)) {

			if (&isnmcounty($qsopts)) {
				if ($qso{mode} eq 'SSB') {
				$s_qsopts->{$qso{'band'}} += 1;
				}
				else { # Just a 2x "digital" contact
				$s_qsopts->{$qso{'band'}} += 2;
				}
			}
		}
	}
	elsif ($main::defqsopts eq 'nvqso') {
		if ($qso{mode} eq 'SSB') {
			$s_qsopts->{$qso{'band'}} += 2;
		}
		else { # Just a 2x "digital" contact
			$s_qsopts->{$qso{'band'}} += 3;
		}
	}
	elsif ($main::defqsopts eq 'nvqso-nonnm') {		# NV QSO Party - Non-NM
		my $qsopts=$qso{'exc2'};

		if (defined($qsopts)) {

			if (&isnvcounty($qsopts)) {
				if ($qso{mode} eq 'SSB') {
				$s_qsopts->{$qso{'band'}} += 2;
				}
				else { # Just a 3x "digital" contact
				$s_qsopts->{$qso{'band'}} += 3;
				}
			}
		}
	}

	#############################################
	# Mult 1 - can be one of the following:
	#  * Prefix
	#  * exch1..4
	#  * DXCC

	if (exists($main::coderefs{$main::contest}{'MULT1'})) {

		my $mult = '';

		# eval the code, which should:
		#  - set $mult to the unique multiplier keyword (eg, country code)
		eval $main::coderefs{$main::contest}{'MULT1'} or die $@;

		# remember the multiplier keyword if not seen before
		unless (!$mult || $s_mult1->{$band} =~ / $mult /) {
			$s_mult1->{$band} .= " $mult ";
		}
	} elsif ($main::defmult1 =~ /prefix-(.+)/) {
		my $prefix;
		my $bands = $1;

		# get rid of inimportant appendixes...	
		if (index($qso{'call'}, '/') > -1) {
			$qso{'call'} =~ s/((\/QRP)|(\/P)|(\/M)|(\/A))//g;
		}
		if (index($qso{'call'}, '/') < 0) {
			$qso{'call'} =~ /^(.+?)[A-Z]+$/;
			$prefix = $1;
		}
		else {
				my $x;
				my @a = split(/\//, $qso{'call'});
				
				# put the addition to a[0], main call to a[1]
				unless (length($a[0]) < length($a[1])){
						($a[0], $a[1]) = ($a[1], $a[0]);
				}

				if ($a[0] =~ /[A-Z][0-9]+$/) {		# W4/DJ1YFK -> W4
						$prefix = $a[0];
				}
				elsif ($a[0] =~ /^[A-Z]+$/) {		# OH/DJ1YFK -> OH0
						$prefix = $a[0].'0';
				}
				elsif ($a[0] =~ /^[0-9]$/) {		# DJ1YFK/3 -> DJ3
						$qso{'call'} =~ /^(.+?)[0-9]/;
						$prefix = $1.$a[0];
				}
				else {								# Unknown case...
						$qso{'call'} =~ /^(.+?)[A-Z]+$/;
						$prefix = $1;
				}
		}

		if ($bands eq 'band') {	# mults by band
			if (index($s_mult1->{$qso{'band'}}, " $prefix ") == -1) {
					$s_mult1->{$qso{'band'}} .= " $prefix ";
			}
		}
		else {					# mults over all bands
			if (index($s_mult1->{'All'}, " $prefix ") == -1) {
					$s_mult1->{'All'} .= " $prefix ";
			}
		}
	} # defmult1=prefix
	elsif (($main::defmult1 =~ /(exc\d)-(\w+)-(\w+)/) &&
			($qso{$1} ne '')) {			# might be empty, like in IOTA..
		my $mult = $qso{$1};

		# $2 can be 'band' or 'all', $3 can be 'mode' or 'all'.

		if ($2 eq 'band') {
			if ($3 eq 'all') {		# regardless of mode
				unless ($s_mult1->{$qso{'band'}} =~ / $mult /) {
						$s_mult1->{$qso{'band'}} .= " $mult ";
				}
			}
			elsif ($3 eq 'mode') {
				unless ($s_mult1->{$qso{'band'}} =~ / $mult$qso{'mode'} /) {
						$s_mult1->{$qso{'band'}} .= " $mult$qso{'mode'} ";
				}
			}
		}
		else {	# mults over all bands
			if ($3 eq 'all') {
				unless ($s_mult1->{'All'} =~ / $mult /) {
						$s_mult1->{'All'} .= " $mult ";
				}
			}
			elsif ($3 eq 'mode') {
				unless ($s_mult1->{'All'} =~ / $mult$qso{'mode'} /) {
						$s_mult1->{'All'} .= " $mult$qso{'mode'} ";
				}
			}
		}
	} # exc[0-2]...
	# DXCC as multiplier
	elsif ($main::defmult1 =~ /(dxcc|wae)-(\w+)-(\w+)/) {	
		# $2 can be by 'band' or 'all', $3 can be by 'mode' or 'all'.

		my $mult;

		if ($1 eq 'wae') {
			$mult= (&dxcc($qso{'call'}, 'wae'))[7];
		}
		else {		# only DXCCs
			$mult= (&dxcc($qso{'call'}))[7];
		}

		if ($2 eq 'band') {
			if ($3 eq 'all') {		# regardless of mode
				unless ($s_mult1->{$qso{'band'}} =~ / $mult /) {
						$s_mult1->{$qso{'band'}} .= " $mult ";
				}
			}
			elsif ($3 eq 'mode') {
				unless ($s_mult1->{$qso{'band'}} =~ / $mult$qso{'mode'} /) {
						$s_mult1->{$qso{'band'}} .= " $mult$qso{'mode'} ";
				}
			}
		}
		else {	# mults over all bands
			if ($3 eq 'all') {
				unless ($s_mult1->{'All'} =~ / $mult /) {
						$s_mult1->{'All'} .= " $mult ";
				}
			}
			elsif ($3 eq 'mode') {
				unless ($s_mult1->{'All'} =~ / $mult$qso{'mode'} /) {
						$s_mult1->{'All'} .= " $mult$qso{'mode'} ";
				}
			}
		}
	}	# DXCC
	# North American QSO Party: Mults: US States/VE Provinces and NA DXCCs
	elsif ($main::defmult1 eq 'naqp') {
		my ($cont, $dxcc) = (&dxcc($qso{'call'}))[3,7];
		my $mult = '';

		if ($dxcc =~ /^K|^VE/) {	# STATE/PROV
				$mult = $qso{'exc2'};
		}
		elsif ($cont eq 'NA') {
			$mult = $dxcc;
		}

		unless ($s_mult1->{$qso{'band'}} =~ / $mult /) {
				$s_mult1->{$qso{'band'}} .= " $mult ";
		}
	}
	elsif ($main::defmult1 eq 'sac') {		# Nordic Country districts
		my ($cont, $dxcc) = (&dxcc($qso{'call'}))[3,7];
		if ($dxcc =~ /(JW|JX|LA|OH|OH0|OJ0|OX|OZ|OY|SM|TF)/) {
			my $mult = $1;
			$qso{'call'} =~ /([0-9\/])/;		# first number or /
			if ($1 eq '/') {
				$mult = $mult.'0';
			}
			else {
				$mult = $mult.$1;
			}
		
			unless ($s_mult1->{$qso{'band'}} =~ / $mult /) {
				$s_mult1->{$qso{'band'}} .= " $mult ";
			}
		}
	}
	elsif ($main::defmult1 eq 'cncw') {		# Concurso nacional de CW
		my ($mydistrict, $mult);

		unless ($main::mycall =~ /([1-9\/])/) {
			$mydistrict = '0';						# should not happen!
		}
		else {
			if ($1 eq '/') { $mydistrict = 0; }
			else { $mydistrict = $1; }
		}

		if ($qso{'call'} =~ /^(AM|AN|AO|EA|EB|EC|ED|EE|EF|EG|EH)/) {
			
			if ($qso{'call'} =~ /([1-9\/])/) {		# first nr or /
			
				if ($1 eq '/') { $mult = '0'; }
				else { $mult = $1; }
			}
			else {
				$mult = 0;							# shouldn't happen!
			}

			unless ($mult eq $mydistrict || 
					$s_mult1->{$qso{'band'}} =~ / $mult /) {
				$s_mult1->{$qso{'band'}} .= " $mult ";
			}
		}
	}
	elsif ($main::defmult1 eq 'naval') {		# Intl Naval Contest
			my $mult;
			($mult) = ($qso{'exc1'} =~ /^([A-Z]{2}\d+)/);
			if (defined($mult)  && !($s_mult1->{All} =~ / $mult /)) {
				$s_mult1->{All} .= " $mult ";
			}
	}
	elsif ($main::defmult1 eq 'cq160') {		# US states, VE provs & DXCC
			my $mult=$qso{'exc1'};

			if (defined($mult)) {
				my $cty = (&dxcc($qso{'call'}, 'wae'))[7];

				if ($cty =~ /^(VE|K)$/) {				# state/prov = mult
					unless (&isusstate($mult) || &isveprov($mult)) {
						$mult = '';			# Not a valid exchange!
					}
				}
				else {						# non-US/VE; DXCC is Mult
					$mult = $cty;
				}

				if (!($s_mult1->{All} =~ / $mult /)) {
					$s_mult1->{All} .= " $mult ";
				}

			}
	}
	elsif ($main::defmult1 eq 'ref-f') {		# Departments, DXCCs
		my $cty = (&dxcc($qso{'call'}))[7];
		my $mult = $qso{'exc1'};

		if ($cty =~ /^F|^TK/) {
			$mult =~ s/^(\d)$/0$1/;				# Add leading zero if needed
			unless ($mult =~
					/^(TK|FM|FG|FS|FK|FT|FJ|FH|FO|FP|FR|FT|FW|FY|[0-9]{2})$/) {
				$mult = '';			# invalid exchange, no mult
			}
		}
		else {
			$mult = $cty;
		}

		unless ($s_mult1->{$qso{'band'}} =~ / $mult /) {
			$s_mult1->{$qso{'band'}} .= " $mult ";
		}
	}
#	elsif ($main::defmult1 =~ /rdxc/) {
#		if ($qso{'exc1'} =~ /[A-Z]{2}/) {		# Only RDAs, no Serials
#			my $mult = $qso{'exc1'};
#			unless ($s_mult1->{'All'} =~ / $mult$qso{'mode'} /) {
#					$s_mult1->{'All'} .= " $mult$qso{'mode'} ";
#					$s_mult1->{$qso{'band'}} =~ s/ UA //;
#					$s_mult1->{$qso{'band'}} =~ s/ UA2 //;
#					$s_mult1->{$qso{'band'}} =~ s/ UA9 //;
#					$s_mult1->{$qso{'band'}} =~ s/ R1FJ //;
#					$s_mult1->{$qso{'band'}} =~ s/ R1MV //;
#					$s_mult1->{$qso{'band'}} =~ s/ R1AN //;
#			}
#		}
#	}
	elsif ($main::defmult1 eq 'foc') {
		# Mults are actually bonus points.
		# 2 per DXCC (over all bands), 5 per Continent (over all bands)
		my ($cont, $dxcc) = (&dxcc($qso{'call'}))[3,7];

		unless ($s_mult1->{All} =~ / D-$dxcc /) {
				$s_mult1->{All} .= " D-$dxcc ";
				$s_qsopts->{$qso{band}} += 2;
		}
		
		unless ($s_mult2->{All} =~ / C-$cont /) {
				$s_mult2->{All} .= " C-$cont ";
				$s_qsopts->{$qso{band}} += 5;
		}
	}
	elsif ($main::defmult1 eq 'nmqso-nonnm') {		# NM QSO Party - Non-NM
		my $mult=$qso{'exc2'};

		if (defined($mult)) {

			my $cty = (&dxcc($qso{'call'}, 'wae'))[7];

			if ($cty =~ /^(K)$/) {				# state = mult
				unless (&isnmcounty($mult)) {
					$mult = '';			# Not a valid exchange!
				}
				if (!($s_mult1->{All} =~ / $mult /)) {
					$s_mult1->{All} .= " $mult ";
				}
			}

		}
	}
	elsif ($main::defmult1 eq 'nvqso-nonnm') {		# NV QSO Party - Non-NM
		my $mult=$qso{'exc2'};

		if (defined($mult)) {

			my $cty = (&dxcc($qso{'call'}, 'wae'))[7];

			if ($cty =~ /^(K)$/) {				# state = mult
				unless (&isnvcounty($mult)) {
					$mult = '';			# Not a valid exchange!
				}
				if (!($s_mult1->{All} =~ / $mult /)) {
					$s_mult1->{All} .= " $mult ";
				}
			}

		}
	}
	elsif ($main::defmult1 eq 'state-prov') {	# US states, VE provs 
			my $mult=$qso{'exc1'};

			if (defined($mult)) {
				my $cty = (&dxcc($qso{'call'}, 'wae'))[7];

				if ($cty =~ /^(VE|K)$/) {				# state/prov = mult
					unless (&isusstate($mult) || &isveprov($mult)) {
						$mult = '';			# Not a valid exchange!
					}
					else {	# Save to Guess-Hash for next QSO.
						$main::guesshash{$qso{call}} = $mult;
					}
				}
				else {
					$mult = '';
				}

				if (!($s_mult1->{$qso{band}} =~ / $mult /)) {
					$s_mult1->{$qso{band}} .= " $mult ";
				}

			}
	}
	elsif ($main::defmult1 eq 'none') {	
		$s_mult1->{All} = ' 1 ';
	}

	# Exchange guessing stuff.. should be in its own file?
	
	if ($main::contest eq 'ARRLDX-US') {
		$main::guesshash{$qso{call}} = $qso{exc1};
	}
	elsif ($main::contest eq 'ARRL-FD') {
		$main::guesshash{$qso{call}} = $qso{exc1}.'/'.$qso{exc2};
	}
	elsif ($main::defmult1 =~ /hungarian/) {		# HA counties by band
		if ($qso{'exc1'} =~ /[A-Z]{2}/) {
			my $mult = $qso{'exc1'};
			unless ($s_mult1->{$qso{'band'}} =~ / $mult /) {
					$s_mult1->{$qso{'band'}} .= " $mult ";
			}
		}
		# Remove HA from mult1, since it doesn't count as DXCC mult
		$s_mult1->{$qso{'band'}} =~ s/ HA //;
	}
	elsif ($main::contest =~ /ALLASIAN/) {
		$main::guesshash{$qso{call}} = $qso{exc1};
	}
	elsif ($main::contest eq 'QRP-TTF') { # changed to ! becuase both / es - in field 
		$main::guesshash{$qso{call}} = $qso{exc1}.'!'.$qso{exc2}.'!'.$qso{exc3};
	}





	###################################################
	# MULT 2 MULT 3 MULT 2
	###################################################

	if (exists($main::coderefs{$main::contest}{'MULT2'})) {

		my $mult = '';

		# eval the code, which should:
		#  - set $mult to the unique multiplier keyword (eg, country code)
		eval $main::coderefs{$main::contest}{'MULT2'} or die $@;

		# remember the multiplier keyword if not seen before
		unless (!$mult || $s_mult2->{$band} =~ / $mult /) {
			$s_mult2->{$band} .= " $mult ";
		}
	} elsif (($main::defmult2 =~ /(exc\d)-(\w+)-(\w+)/) &&
			($qso{$1} ne '')) {			# might be empty, like in IOTA..
		my $mult = $qso{$1};

		# $2 can be 'band' or 'all', $3 can be 'mode' or 'all'.

		if ($2 eq 'band') {
			if ($3 eq 'all') {		# regardless of mode
				unless ($s_mult2->{$qso{'band'}} =~ / $mult /) {
						$s_mult2->{$qso{'band'}} .= " $mult ";
				}
			}
			elsif ($3 eq 'mode') {
				unless ($s_mult2->{$qso{'band'}} =~ / $mult$qso{'mode'} /) {
						$s_mult2->{$qso{'band'}} .= " $mult$qso{'mode'} ";
				}
			}
		}
		else {	# mults over all bands
			if ($3 eq 'all') {
				unless ($s_mult2->{'All'} =~ / $mult /) {
						$s_mult2->{'All'} .= " $mult ";
				}
			}
			elsif ($3 eq 'mode') {
				unless ($s_mult2->{'All'} =~ / $mult$qso{'mode'} /) {
						$s_mult2->{'All'} .= " $mult$qso{'mode'} ";
				}
			}
		}
	} # exc[0-2]...
	elsif ($main::defmult2 =~ /rdac/) {
		if ($qso{'exc1'} =~ /[A-Z]{2}[0-9]{2}/) {		# Only RDAs, no Serials
			my $mult = $qso{'exc1'};
			unless ($s_mult2->{'All'} =~ / $mult$qso{'mode'} /) {
					$s_mult2->{'All'} .= " $mult$qso{'mode'} ";
			}
		}
	}
	elsif ($main::defmult2 =~ /rdxc/) {
		if ($qso{'exc1'} =~ /[A-Z]{2}/) {		# Only RDAs, no Serials
			my $mult = $qso{'exc1'};
			unless ($s_mult2->{$qso{'band'}} =~ / $mult /) {
					$s_mult2->{$qso{'band'}} .= " $mult ";
			}
		}
		$s_mult1->{$qso{'band'}} =~ s/ UA //;
		$s_mult1->{$qso{'band'}} =~ s/ UA //;
		$s_mult1->{$qso{'band'}} =~ s/ UA2 //;
		$s_mult1->{$qso{'band'}} =~ s/ UA9 //;
		$s_mult1->{$qso{'band'}} =~ s/ R1FJ //;
		$s_mult1->{$qso{'band'}} =~ s/ R1MV //;
		$s_mult1->{$qso{'band'}} =~ s/ R1AN //;
	}
	elsif ($main::defmult2 =~ /yodx/) {		# YO provinces by band
		if ($qso{'exc1'} =~ /[A-Z]{2}/) {
			my $mult = $qso{'exc1'};
			unless ($s_mult2->{$qso{'band'}} =~ / $mult /) {
					$s_mult2->{$qso{'band'}} .= " $mult ";
			}
		}
		# Remove YO from mult1, since it doesn't count as DXCC mult
		$s_mult1->{$qso{'band'}} =~ s/ YO //;
	}
	elsif ($main::defmult2 =~ /smrei/) {		# EA provinces by band
		if ($qso{'exc1'} =~ /[A-Z]{1}/) {
			my $mult = $qso{'exc1'};
			unless ($s_mult2->{$qso{'band'}} =~ / $mult /) {
					$s_mult2->{$qso{'band'}} .= " $mult ";
			}
		}
		# Remove EA from mult1, since it doesn't count as DXCC mult
		$s_mult1->{$qso{'band'}} =~ s/ EA //;
	}
	elsif ($main::defmult2 =~ /cncw/) {		# EA provinces by band
		if ($qso{'exc1'} =~ /[A-Z]{1}/) {
			my $mult = $qso{'exc1'};
			my $provincia = $qso{'exc1'};
			if ($provincia eq $main::exc2s) {
					$mult = '';
			}
			unless ($s_mult2->{$qso{'band'}} =~ / $mult /) {
					$s_mult2->{$qso{'band'}} .= " $mult ";
			}
		}
	}
	elsif ($main::defmult2 =~ /portuday/) {		# CT provinces by band
		if ($qso{'exc1'} =~ /[A-Z]{2}/) {
			my $mult = $qso{'exc1'};
			unless ($s_mult2->{$qso{'band'}} =~ / $mult /) {
					$s_mult2->{$qso{'band'}} .= " $mult ";
			}
		}
		# Remove CT from mult1, since it doesn't count as DXCC mult
		$s_mult1->{$qso{'band'}} =~ s/ CT //;
	}
	elsif ($main::defmult2 =~ /almeihf/) {		# CT provinces by band
		if ($qso{'exc1'} =~ /[A-Z]{2}/) {
			my $mult = $qso{'exc1'};
			unless ($s_mult2->{$qso{'band'}} =~ / $mult /) {
					$s_mult2->{$qso{'band'}} .= " $mult ";
			}
		}
		# Remove CT from mult1, since it doesn't count as DXCC mult
		$s_mult1->{$qso{'band'}} =~ s/ CT //;
	}
	elsif ($main::defmult2 =~ /cqzone/) {
		my $mult = $qso{'exc1'};
		$mult += 0;					# remove leading zero if any
		unless ($s_mult2->{$qso{'band'}} =~ / $mult /) {
				$s_mult2->{$qso{'band'}} .= " $mult ";
		}
	}	
	elsif ($main::defqsopts =~ /arrlfd/) {	# ARRL-FD "wildcard" eye-candy data storage
		my $mult = $qso{'exc2'};
		unless ($s_mult2->{$qso{'band'}} =~ / $mult /) {
				$s_mult2->{$qso{'band'}} .= " $mult ";
		}
	}
	elsif ($main::defmult2 =~ /qrpttf/) {		# SOTA station counts as one more mult
		if ($qso{'exc3'} =~ /\//) {
			my $mult = $qso{'exc3'};
#			unless ($s_mult2->{$qso{'band'}} =~ / $mult /) {
					$s_mult2->{$qso{'band'}} .= " $mult ";
#			}
		}
	}

	#######################################################
	# Other stuff - could be used for the following:      #
	#  * to change $multall - a SIMPLE overall multiplier #
	#######################################################

	my $multall = 1;					# a SIMPLE overall multiplier

	if ($main::defqsopts =~ /qrparci/) {
		if ($main::power eq '>5W') { $multall = 1; }
		elsif ($main::power eq '>1W') { $multall = 7; }
		elsif ($main::power eq '>250mW') { $multall = 10; }
		elsif ($main::power eq '>55mW') { $multall = 15; }
		else { $multall = 20; }
	}
	if ($main::defqsopts =~ /nmqso/) {
		if ($main::power eq 'HIGH') { $multall = 1; }
		elsif ($main::power eq 'LOW') { $multall = 2; }
		else { $multall = 5; }
	}
	if ($main::defmult2 =~ /qrpttf/) {
		if ($main::transmitter eq 'HOME') { $multall = 1; }
		elsif ($main::transmitter eq 'HILL') { $multall = 2; }
		elsif ($main::transmitter eq 'SUMMIT') { $multall = 3; }
		else { $multall = 4; }
	}

	# Total points

	my	$multsum =
				&count($s_mult1->{160}) + &count($s_mult1->{80}) +
				&count($s_mult1->{40}) + &count($s_mult1->{20}) + 
				&count($s_mult1->{15}) + &count($s_mult1->{10}) +
				&count($s_mult1->{12}) + &count($s_mult1->{17}) +
				&count($s_mult1->{30}) +
				&count($s_mult1->{'All'});

		$multsum +=	&count($s_mult2->{160}) + &count($s_mult2->{80}) +
				&count($s_mult2->{40}) + &count($s_mult2->{20}) + 
				&count($s_mult2->{15}) + &count($s_mult2->{10}) +
				&count($s_mult2->{12}) + &count($s_mult2->{17}) +
				&count($s_mult2->{30}) +
				&count($s_mult2->{'All'});

	my $qsoptsum = 0;

	if ($main::defmult2 =~ /qrpttf/) {
		$qsoptsum = 
			($s_qsopts->{160} * (&count($s_mult1->{160}) + &count($s_mult2->{160}))) +
			($s_qsopts->{80} * (&count($s_mult1->{80}) + &count($s_mult2->{80}))) +
			($s_qsopts->{40} * (&count($s_mult1->{40}) + &count($s_mult2->{40}))) +
			($s_qsopts->{20} * (&count($s_mult1->{20}) + &count($s_mult2->{20}))) +
			($s_qsopts->{15} * (&count($s_mult1->{15}) + &count($s_mult2->{15}))) +
			($s_qsopts->{10} * (&count($s_mult1->{10}) + &count($s_mult2->{10})));
	}else{
		$qsoptsum = $s_qsopts->{160} + $s_qsopts->{80} + $s_qsopts->{40} + 
			$s_qsopts->{20} + $s_qsopts->{15} + $s_qsopts->{10} +
			$s_qsopts->{17} + $s_qsopts->{12} + $s_qsopts->{30};
	}

	if (($main::defqsopts eq 'foc') || ($main::defqsopts eq 'arrlfd')) {
		${$_[7]} = $qsoptsum;		# no mults here, but mult hashes abused
	}
	elsif ($main::defmult2 eq 'qrpttf') {
		${$_[7]} = $qsoptsum * $multall; # strict per band mults requirement
	}
	else {
		${$_[7]} = $qsoptsum * $multsum * $multall;
	}

}



sub isusstate {
	my $test = shift;
	if ($test =~
			/^(AL|AK|AZ|AR|CA|CO|CT|DE|DC|FL|GA|GU|HI|ID|IL|IN|IA|KS|KY|LA|ME|MD|MA|MI|MN|MS|MO|MT|NE|NV|NH|NJ|NM|NY|NC|ND|OH|OK|OR|PA|PR|RI|SC|SD|TN|TX|UT|VT|VI|VA|WA|WV|WI|WY)$/)
	{
		return 1;
	}
	return 0;
}

sub isveprov {
	my $test = shift;
	if ($test =~
			/^(NB|NS|QC|ON|MB|SK|AB|BC|NWT|NF|LB|YT|PEI|NU)$/
	) {
		return 1;
	}
	else {
		return 0;
	}
}

sub isnmcounty {
	my $test = shift;
	if ($test =~
			/^(BER|CAT|CHA|CIB|COL|CUR|DEB|DON|EDD|GRA|GUA|HAR|HID|LEA|LIN|LOS|LUN|MCK|MOR|OTE|QUA|RIO|ROO|SJU|SMI|SAN|SFE|SIE|SOC|TAO|TOR|UNI|VAL)$/
	) {
		return 1;
	}
	else {
		return 0;
	}
}

sub isnvcounty {
	my $test = shift;
	if ($test =~
			/^(CAR|CHU|CLA|DOU|ELK|ESM|EUR|HUM|LAN|LIN|LYO|MIN|NYE|PER|STO|WAS|WHI)$/
	) {
		return 1;
	}
	else {
		return 0;
	}
}


return 1;

# Local Variables:
# tab-width:4
# End: **

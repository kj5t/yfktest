use strict;

my %friends;
my %iota;
my %foc;

open FRIEND, find_file('friend.ini');
my $line;
while ($line = <FRIEND>) {
		chomp($line);
	my @a = split(/=/, $line);
	$friends{$a[0]} = $a[1];
}
close FRIEND;

#open IOTA, find_file('iota.txt');
#my $line1;
#while ($line1 = <IOTA>) {
#		chomp($line1);
#	my @a = split(/=/, $line1);
#	$iota{$a[0]} =  $a[1];
#}
#close IOTA;

# FOC marathon

if (-e 'call_no_name.txt') {

open FOC, find_file('call_no_name.txt');
my $line;
while ($line = <FOC>) {
	map {s/\r//g;} ($line);
	chomp($line);
	$line =~ s/"//g;
	my @a = split(/,/, $line);
	$foc{$a[0]} = "$a[2] $a[1]";	# Call = Name, Nr
	$foc{$a[1]} = "$a[0] $a[1]";	# Nr = Call, Name
}
close FOC;

}
else {
	$foc{0} = 1;
}


sub callinfo {
	my $win = $main::winfo;
	my $call = $main::qso{'call'};
	my $contest = $main::contest;
	move($win, 0,0);
	addstr($win, ' 'x1234);

	if ($contest eq 'CQWW') {		# CQWW - Show worked Zones
		my $band = $main::qso{'band'};
		my $mults = $main::s_mult2{$band};

		my @info = &dxcc($call);
		if ($call eq '') { return 0; }
		addstr($win, 0, 0, "$info[7] - $info[0] - CQ-Zone: $info[1]".' 'x80);

		# CQ-Zone multi table
		move($win, 1,0);
		for (my $i=1; $i <= 40 ; $i++) {
			if ($mults =~ / $i /) {
				attron($win, COLOR_PAIR(2));
			}
			else {
				attron($win, COLOR_PAIR(4));
			}
			addstr($win, ($i < 10) ? '0'.$i : $i);
			attron($win, COLOR_PAIR(4));
			addstr($win, " ") unless ($i =~ /12|24|36/);
		}
		refresh($win);

	} # CQWW Zones
	elsif ($contest eq 'EUHFC') {		# EUHFC = Show Mults wkd/needed.
		my $band = $main::qso{'band'};
		my $mults = $main::s_mult1{$band};

		move($win, 0,0);
		for (my $i=50; $i < 109 ; $i++ ) {
			my $year = sprintf("%02d", ($i%100));
			if ($mults =~ / $year /) {
				attron($win, COLOR_PAIR(2));
			}
			else {
				attron($win, COLOR_PAIR(4));
			}
			addstr($win, $year);
			attron($win, COLOR_PAIR(4));
			addstr($win, " ") unless ($year =~ /61|73|85|97/);
		}
#		addstr($win, 0, 0, $mults);
		refresh($win);

	} # EUHFC
	elsif ($contest eq 'YODX') {	# YO-DX-Contest: Show provinces
		my $band = $main::qso{'band'};
		my $mults = $main::s_mult2{$band};
		my @districts = qw/AB AG AR BC BH BN BR BT BU BV BZ CJ CL CS CT CV DB
		DJ GJ GL GR HD HR IF IL IS MH MM MS NT OT PH SB SJ SM SV TL TM TR VL VN
		VS/;

		move($win, 0,0);
		foreach my $d (@districts) {
			if ($mults =~ / $d /) {
				attron($win, COLOR_PAIR(2));
			}
			else {
				attron($win, COLOR_PAIR(4));
			}
			addstr($win, $d);
			attron($win, COLOR_PAIR(4));
			addstr($win, " ") unless ($d =~ /CJ|IF|SV/);
		}
		addstr($win, 4, 0, "Name: $friends{$call}".' 'x20) if defined ($friends{$call});
		refresh($win);
	} #YODX
	elsif ($contest eq 'HADXTEST') {	# HA-DX-Contest: Show counties
		my $band = $main::qso{'band'};
		my $mults = $main::s_mult2{$band};
		my @districts = qw/BA BE BN BO BP CS FE GY HB HE KO NG PE SA SO TO VA VE ZA/;

		move($win, 0,0);
		foreach my $d (@districts) {
			if ($mults =~ / $d /) {
				attron($win, COLOR_PAIR(2));
			}
			else {
				attron($win, COLOR_PAIR(4));
			}
			addstr($win, $d);
			attron($win, COLOR_PAIR(4));
			addstr($win, " ") unless ($d =~ /NG/);
		}
		addstr($win, 4, 0, "Name: $friends{$call}".' 'x20) if defined ($friends{$call});
		refresh($win);
	} #HADXTEST
	elsif ($contest eq 'CNCW') {	# Concurso Nacional de CW: Show provinces
		my $band = $main::qso{'band'};
		my $mults = $main::s_mult2{$band};
		my @districts = qw/AV BU C LE LO LU O OU P PO S SA SG SO VA ZA BI HU NA SS TE VI Z B GI L T BA CC CR CU GU M TO A AB CS MU V IB AL CA CO GR H J MA SE GC TF CE ML/;

		move($win, 0,0);
		foreach my $d (@districts) {
			if ($mults =~ / $d /) {
				attron($win, COLOR_PAIR(2));
			}
			else {
				attron($win, COLOR_PAIR(4));
			}
			addstr($win, $d);
			attron($win, COLOR_PAIR(4));
			addstr($win, " ") unless ($d =~ /CE/);
			addstr($win, " ") if ($d =~ /GI/);
		}
		addstr($win, 4, 0, "Name: $friends{$call}".' 'x20) if defined ($friends{$call});
		refresh($win);
	} #CNCW
#	elsif ($contest eq 'SMREY-DX') {	# His Majesty King of Spain: Show provinces
#		my $band = $main::qso{'band'};
#		my $mults = $main::s_mult2{$band};
#		my @districts = qw/AV BU C LE LO LU O OU P PO S SA SG SO VA ZA BI HU NA SS TE VI Z B GI L T BA CC CR CU GU M TO A AB CS MU V IB AL CA CO GR H J MA SE GC TF CE ML/;

#		move($win, 0,0);
#		foreach my $d (@districts) {
#			if ($mults =~ / $d /) {
#				attron($win, COLOR_PAIR(2));
#			}
#			else {
#				attron($win, COLOR_PAIR(4));
#			}
#			addstr($win, $d);
#			attron($win, COLOR_PAIR(4));
#			addstr($win, " ") unless ($d =~ /CE/);
#			addstr($win, " ") if ($d =~ /GI/);
#		}
#		addstr($win, 4, 0, "Name: $friends{$call}".' 'x20) if defined ($friends{$call});
#		refresh($win);
#	} #SMREY-DX
	elsif ($contest eq 'PDCON-DX') {	# Portugal Day Contest: Show provinces
		my $band = $main::qso{'band'};
		my $mults = $main::s_mult2{$band};
		my @districts = qw/AV BJ BR BG CB CO EV FR GD LR LX PG PT SR ST VC VS
		AC MD/;

		move($win, 0,0);
		foreach my $d (@districts) {
			if ($mults =~ / $d /) {
				attron($win, COLOR_PAIR(2));
			}
			else {
				attron($win, COLOR_PAIR(4));
			}
			addstr($win, $d);
			attron($win, COLOR_PAIR(4));
			addstr($win, " ") unless ($d =~ /PT/);
		}
		addstr($win, 4, 0, "Name: $friends{$call}".' 'x20) if defined ($friends{$call});
		refresh($win);
	}
	elsif ($contest eq 'ALMEIHF-DX') {	# Portugal Day Contest: Show provinces
		my $band = $main::qso{'band'};
		my $mults = $main::s_mult2{$band};
		my @districts = qw/AV BJ BR BG CB CO EV FR GD LR LX PG PT SR ST VC VS
		AC MD/;

		move($win, 0,0);
		foreach my $d (@districts) {
			if ($mults =~ / $d /) {
				attron($win, COLOR_PAIR(2));
			}
			else {
				attron($win, COLOR_PAIR(4));
			}
			addstr($win, $d);
			attron($win, COLOR_PAIR(4));
			addstr($win, " ") unless ($d =~ /PG/);
		}
		addstr($win, 4, 0, "Name: $friends{$call}".' 'x20) if defined ($friends{$call});
		refresh($win);
	}
	elsif ($contest eq 'ALMEIHF') {	# Portugal Day Contest: Show provinces
		my $band = $main::qso{'band'};
		my $mults = $main::s_mult2{$band};
		my @districts = qw/AV BJ BR BG CB CO EV FR GD LR LX PG PT SR ST VC VS
		AC MD/;

		move($win, 0,0);
		foreach my $d (@districts) {
			if ($mults =~ / $d /) {
				attron($win, COLOR_PAIR(2));
			}
			else {
				attron($win, COLOR_PAIR(4));
			}
			addstr($win, $d);
			attron($win, COLOR_PAIR(4));
			addstr($win, " ") unless ($d =~ /PG/);
		}
#		addstr($win, 3, 0, "Iota: $iota{$call}".' 'x20) if defined ($iota{$call});
		addstr($win, 4, 0, "Name: $friends{$call}".' 'x20) if defined ($friends{$call});
		refresh($win);
	}
	elsif ($contest eq 'FOC') {	# FOC Marathon
		my @info = &dxcc($call);
		if ($call eq '') { return 0; }


		addstr($win, 0, 0, "$info[7] - $info[0]".' 'x80);
		addstr($win, 1, 0, "CQZ: $info[1], ITU: $info[2]".' 'x80);
		addstr($win, 2, 0, "Name: $friends{$call}".' 'x80) if 
												defined ($friends{$call});

		addstr($win, 3, 0, "FOC: $foc{$call}".' 'x80) if defined($foc{$call});

		if (defined $foc{0}) {
			addstr($win, 2, 0, "Warning: Missing call_no_name.txt");
			addstr($win, 3, 0, "for exchange guessing; available");
			addstr($win, 4, 0, "from VP9KF's website.");
		}

		refresh($win);
	} 
	elsif ($contest eq 'IOTA') {	# IOTA
		my @info = &dxcc($call);
		if ($call eq '') { return 0; }


		addstr($win, 0, 0, "$info[7] - $info[0]".' 'x80);
		addstr($win, 1, 0, "CQZ: $info[1], ITU: $info[2]".' 'x80);
		addstr($win, 2, 0, "Iota: ".' 'x80);
		addstr($win, 2, 6, "$iota{$call}".' 'x80) if defined ($iota{$call});
		refresh($win);
	}
	elsif ($contest eq 'SMREY-DX') {	# His Majesty King of Spain: Show provinces
		my $band = $main::qso{'band'};
		my $mults = $main::s_mult2{$band};
		my @districts = qw/AV BU C LE LO LU O OU P PO S SA SG SO VA ZA BI HU NA SS TE VI Z B GI L T BA CC CR CU GU M TO A AB CS MU V IB AL CA CO GR H J MA SE GC TF CE ML/;

		move($win, 0,0);
		foreach my $d (@districts) {
			if ($mults =~ / $d /) {
				attron($win, COLOR_PAIR(2));
			}
			else {
				attron($win, COLOR_PAIR(4));
			}
			addstr($win, $d);
			attron($win, COLOR_PAIR(4));
			addstr($win, " ") unless ($d =~ /CE/);
			addstr($win, " ") if ($d =~ /GI/);
		}
		addstr($win, 4, 0, "Name: $friends{$call}".' 'x20) if defined ($friends{$call});
		refresh($win);
	} #SMREY-DX
	elsif ($contest eq 'ARRLDX-DX') {		# ARRLDX, DX side: Show Mults
		my $band = $main::qso{'band'};
		my $mults = $main::s_mult1{$band};
		my @districts = qw/NB NS QC ON MB SK AB BC NWT NF LB YT PEI NU AL AZ AR CA CO CT DE DC FL GA ID IL IN IA KS KY LA ME MD MA MI MN MS MO MT NE NV NH NJ NM NY NC ND OH OK OR PA RI SC SD TN TX UT VT VA WA WV WI WY/;

		move($win, 0,0);
		foreach my $d (@districts) {
			if ($mults =~ / $d /) {
				attron($win, COLOR_PAIR(2));
			}
			else {
				attron($win, COLOR_PAIR(4));
			}
			addstr($win, $d);
			attron($win, COLOR_PAIR(4));
			addstr($win, " ") unless ($d =~ /MA|NC|VT/);
			addstr($win, " ") if ($d =~ /LB|DC|SV/);
		}

		refresh($win);
	}
	else {							# Show generic callsign info.
		my @info = &dxcc($call);
		if ($call eq '') { return 0; }
		addstr($win, 0, 0, "$info[7] - $info[0]".' 'x80);
		addstr($win, 1, 0, "CQZ: $info[1], ITU: $info[2]".' 'x80);
		addstr($win, 2, 0, "Name: $friends{$call}".' 'x80) if defined ($friends{$call});
#		addstr($win, 3, 0, "Iota: $iota{$call}".' 'x80) if defined ($iota{$call});
	refresh($win);
	return 0;

	} # else, generic info


}


return 1;

# Local Variables:
# tab-width:4
# End: **

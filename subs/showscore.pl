sub showscore {
	my $window = $_[0];
	my %s_qso = %{$_[1]};
	my %s_mult1 = %{$_[2]};		# 80 => 'HB9 DL1 UU7' -> need to count them!
	my %s_mult2 = %{$_[3]};
	my %s_dupes = %{$_[4]};
	my $s_sum = $_[5];

	my ($t_qso, $t_mult1, $t_mult2) = (0,0,0);

	attron($$window, COLOR_PAIR(4));
	addstr($$window, 0,0, ' 'x999);

	if ($main::contest eq 'DXPED') {
	addstr($$window,2,1,sprintf(" 2m: %4d   6m: %4d", $s_qso{2}, $s_qso{6}));
	addstr($$window,3,1,sprintf("10m: %4d  12m: %4d", $s_qso{10}, $s_qso{12}));
	addstr($$window,4,1,sprintf("15m: %4d  17m: %4d", $s_qso{15}, $s_qso{17}));
	addstr($$window,5,1,sprintf("20m: %4d  30m: %4d", $s_qso{20}, $s_qso{30}));
	addstr($$window,6,1,sprintf("40m: %4d  60m: %4d", $s_qso{40}, $s_qso{60}));
	addstr($$window,7,1,sprintf("80m: %4d 160m: %4d", $s_qso{80}, $s_qso{160}));
	attron($$window, COLOR_PAIR(1));
	addstr($$window, 0, 0, "  DXpedition Summary ");
	addstr($$window, 1, 0, "                     ");
	addstr($$window, 1, (11-length($main::mycall)/2), $main::mycall);
	addstr($$window, 9, 0, " Total QSOs: ".($#main::qsos+1)."          ");
	}
	else { # Normal contest, 6 Bands 
	my $y = 2;
	foreach (qw/10 15 20 40 80 160/) {
		$t_qso  += $s_qso{$_};
		$t_mult1  += &count($s_mult1{$_});
		$t_mult2  += &count($s_mult2{$_});
		addstr($$window, $y, 1, "$_");
		addstr($$window, $y, 4, sprintf(" %4d %3d %3d %2d", $s_qso{$_}, 
				&count($s_mult1{$_}), &count($s_mult2{$_}), $s_dupes{$_}));
		$y++;
	}
	attron($$window, COLOR_PAIR(2));


	$t_mult1  += &count($s_mult1{'All'});
	$t_mult2  += &count($s_mult2{'All'});

	1 while $s_sum =~ s/^(\d+)(\d{3,3})/$1,$2/;

	addstr($$window, 0, 0, " Total Score:     $s_sum ");
	attron($$window, A_BOLD);	
	addstr($$window, 1, 0, " B     Qs  M1  M2  D ");
	attroff($$window, A_BOLD);	
#	addstr($$window, $y, 0, sprintf(" ALL %4d %3d %3d          ", $t_qso, 
	addstr($$window, 9, 0, sprintf(" ALL %5d %3d %3d          ", $t_qso, 
				$t_mult1, $t_mult2));

	} # normal contest

	refresh($$window);

}



sub count {
		my @a = split(/\s+/, $_[0]);

		return $#a;
}


return 1;

# Local Variables:
# tab-width:4
# End: **

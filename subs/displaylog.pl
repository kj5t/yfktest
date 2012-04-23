

sub displaylog {
	my $window = $_[0];
	my @qsos = @{$_[1]};
	my $editnr = $_[2];
	my $i;

	my $y = 21;

	my $stop = $#qsos;

	if ($editnr && ($editnr < $stop-4)) {
		$stop = $editnr-1;
	}

	my $start = $stop - 5;

	if ($start < 0) { $start = 0; }

for ($i = $stop; $i >= $start; $i--) {

	$y--;

curs_set(0);
attron($$window, COLOR_PAIR(3));
addstr($$window, $y, 0, ' 'x59);
#addstr($$window, $y, 0, $i+1);
#move($$window, 22, 18);
#				        move($$window, 22, 18+$curpos);

if ($contest eq 'QRP-TTF') {
	addstr($$window, $y, 0, $qsos[$i]{'nr'});
	addstr($$window, $y, 5, $qsos[$i]{'band'}.'  ');
	addstr($$window, $y, 9, $qsos[$i]{'mode'}.'  ');
	addstr($$window, $y, 13, $qsos[$i]{'utc'}.'  ');
	addstr($$window, $y, 18, $qsos[$i]{'call'}.'            ');
	addstr($$window, $y, 31, $qsos[$i]{'exc1'}.''x$exc1len);
	addstr($$window, $y, 37, $qsos[$i]{'exc2'}.''x$exc2len);
	addstr($$window, $y, 43, $qsos[$i]{'exc3'}.''x$exc3len);
	addstr($$window, $y, 49, $qsos[$i]{'exc4'}.''x$exc4len);

	move($$window, $y, 0);
	chgat($$window, 58, A_REVERSE, 1, 0) if ($editnr == ($i+1));
}else{
	addstr($$window, $y, 0, $qsos[$i]{'nr'});
	addstr($$window, $y, 5, $qsos[$i]{'band'}.'  ');
	addstr($$window, $y, 9, $qsos[$i]{'mode'}.'  ');
	addstr($$window, $y, 13, $qsos[$i]{'utc'}.'  ');
	addstr($$window, $y, 18, $qsos[$i]{'call'}.'            ');
	addstr($$window, $y, 31, $qsos[$i]{'rst'}.'   ');
	addstr($$window, $y, 37, $qsos[$i]{'exc1'}.'    ');
	addstr($$window, $y, 44, $qsos[$i]{'exc2'}.'     ');
	addstr($$window, $y, 49, $qsos[$i]{'exc3'}.' ');
	addstr($$window, $y, 54, $qsos[$i]{'exc4'}.' ');

	move($$window, $y, 0);
	chgat($$window, 58, A_REVERSE, 1, 0) if ($editnr == ($i+1));
}

}

while ($y > 15) {
	$y--;
	addstr($$window, $y, 0, ' 'x59);

}	

refresh($$window);



}





return 1;

# Local Variables:
# tab-width:4
# End: **

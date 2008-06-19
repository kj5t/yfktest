# Check-Multi

sub checkmulti1 {
	my $window = $_[0];
	curs_set(0);
	addstr($$window, 0, 0, ' ' x 240);
	attron($$window, A_BOLD);
	addstr($$window, 0, 8, 'Check Mult1');
	attroff($$window, A_BOLD);
#	addstr($$window, 1, 1, '   2  160 0435 KC1XX     03');
#	addstr($$window, 2, 1, ' 234   80 0237 KC1XX     03');
#	addstr($$window, 3, 1, ' 352   40 1957 KC1XX     03');
#	addstr($$window, 4, 1, ' 642   20 1202 KC1XX     03');
#	addstr($$window, 5, 1, '1124   15 1354 KC1XX     03');
#	addstr($$window, 6, 1, '1652   10 1421 KC1XX     03');
	refresh($$window);
}


return 1;

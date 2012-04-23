load_subs("gettime.pl");

sub readakey {
	my $window = $_[0];
	my %qso = %{$_[1]};			# reference to the current qso hash
	my $entryfields = $_[2];	# depending on contest. 0 to 4
	my $activefield = ${$_[3]};	# active entry field, string.
	my $curpos = ${$_[4]};
	my @validchars = @{$_[5]}; 	# regex for valid characters in fields
	my @validentry = @{$_[6]}; 	# regex for valid complete entry (like IOTA nr)

	my $ch ='';

	# The field positions are fixed. 
	# Call: y = 22, x = 14
	# Rst:   x = 25
	# exc1: x = 29
	# exc2: x = 35
	# exc3: x = 40
	# exc4: x = 45

	&refreshscreen(\$window, $activefield, $curpos, \%qso);



	$ch = getch();

	if (ord($ch) == 195) {		# 2-byte sequence in some consoles
		$ch = getch();		# 2nd byte. Alt + ?
		if (ord($ch) == 171) {		# Alt-K
			return 'keyboard';
		}
		elsif (ord($ch) == 163) {	# alt-c = set configs screen
			return 'config';
		}
		elsif (ord($ch) == 168) {	# alt-h = help screen
			return 'help';
		}
		elsif (ord($ch) == 175) {	# alt-o = help screen
			return 'help';
		}
		elsif (ord($ch) == 178) {	# alt-r = rate screen
			return 'rate';
		}
		elsif (ord($ch) == 172) {	# alt-l = rate screen
			return 'override';
		}
		elsif (ord($ch) == 173) {	# alt-m edit cw messages
			return 'cwmessages';
		}
		elsif (ord($ch) == 183) {	# alt-w
			return 'wipe';
		}
		elsif (ord($ch) == 184) {
			return 'esc';
		}
		else {
			return 0;
		}
	}
	elsif (ord($ch) == 27) {	# ESC-Sequences...
		$ch = getch();
		if (ord($ch) == 104) {		# Alt-h
			return 'help';
		}
		if (ord($ch) == 111) {		# Alt-o
			return 'help';
		}
		elsif (ord($ch) == 99) {		# Alt-c
			return 'config';
		}
		elsif (ord($ch) == 114) {		# Alt-r
			return 'rate';
		}
		elsif (ord($ch) == 108) {		# Alt-l
			return 'override';
		}
		elsif (ord($ch) == 107) {		# Alt-k
			return 'keyboard';
		}
		elsif (ord($ch) == 109) {	# Alt-m edit cw messages
			return 'cwmessages';
		}
		elsif (ord($ch) == 119) {
			return 'wipe';
		}
		elsif (ord($ch) == 120) {
			return 'esc';
		}
		else  {
			return 0;
		}
	}
	elsif ((ord($ch) == 247) || ($ch eq KEY_F(11))) {	# alt-w
		return 'wipe';
	}
	elsif (ord($ch) == 232) {	# Alt-h -> HELP
		return 'help';
	} 
	elsif (ord($ch) == 239) {	# Alt-o -> HELP
		return 'help';
	} 
	elsif (ord($ch) == 227) {	# Alt-c -> set configs screen
		return 'config';
	} 
	elsif (ord($ch) == 242) {	# Alt-r -> Rate Graph
		return 'rate';
	} 
	elsif (ord($ch) == 236) {	# Alt-l -> Rate Graph
		return 'override';
	} 
	elsif (ord($ch) == 235) {	# Alt-k -> keyboard mode
		return 'keyboard';
	} 
	elsif (ord($ch) == 237) {	# Alt-m -> edit cw messages
		return 'cwmessages';
	} 
	elsif (ord($ch) == 10) {	# return
		return 'log';
	}
	elsif ($ch eq KEY_F(1)) {
		return 'f1';
	}
	elsif ($ch eq KEY_F(2)) {
		return 'f2';
	}
	elsif ($ch eq KEY_F(3)) {
		return 'f3';
	}
	elsif ($ch eq KEY_F(4)) {
		return 'f4';
	}
	elsif ($ch eq KEY_F(5)) {
		return 'f5';
	}
	elsif ($ch eq KEY_F(6)) {
		return 'f6';
	}
	elsif ($ch eq KEY_F(7)) {
		return 'f7';
	}
	elsif ($ch eq KEY_F(8)) {
		return 'f8';
	}
	elsif ($ch eq KEY_F(9)) {
		return 'f9';
	}
	elsif ($ch eq KEY_IC) {
		return 'ins';
	}
	elsif ($ch eq KEY_PPAGE) {
		return 'pgup';
	}
	elsif ($ch eq KEY_NPAGE) {
		return 'pgdwn';
	}
	elsif (ord($ch) == 248) {		# ESC or Alt-X
		return 'esc';
	}
	elsif ($ch eq KEY_ESC) {		# ESC
		return 'esc';
	}
	elsif ($ch eq KEY_UP) {
		return 'up';
	}
	elsif ($ch eq KEY_DOWN) {
		return 'down';
	}


	if (($activefield eq 'exc1') && ($entryfields > 0)) {
			my $text = $_[1]->{'exc1'};

			if ($text eq '') {
					$text = &guessexchange(1);
			}

			($curpos, $text, $nextfield) = 
			&editfield($ch, $curpos, $validchars[0], $text, 'exc2', $exc1len);
		
			if ($nextfield) {
				${$_[3]} = $nextfield;			# set new active field
			}
			
			$_[1]->{'exc1'} = $text;
			${$_[4]} = $curpos;
	}
	elsif (($activefield eq 'exc2') && ($entryfields > 1)) {
			my $text = $_[1]->{'exc2'};

			if ($text eq '') {
					$text = &guessexchange(2);
			}

			($curpos, $text, $nextfield) = 
			&editfield($ch, $curpos, $validchars[1], $text, 'exc3', $exc2len);
		
			if ($nextfield) {
				${$_[3]} = $nextfield;			# set new active field
			}
			
			$_[1]->{'exc2'} = $text;
			${$_[4]} = $curpos;
	}
	elsif (($activefield eq 'exc3') && ($entryfields > 2)) {
			my $text = $_[1]->{'exc3'};

			if ($text eq '') {
					$text = &guessexchange(3);
			}

			($curpos, $text, $nextfield) = 
			&editfield($ch, $curpos, $validchars[2], $text, 'exc4', $exc3len);
		
			if ($nextfield) {
				${$_[3]} = $nextfield;			# set new active field
			}
			
			$_[1]->{'exc3'} = $text;
			${$_[4]} = $curpos;
	}
	elsif (($activefield eq 'exc4') && ($entryfields > 3)) {
			my $text = $_[1]->{'exc4'};
			($curpos, $text, $nextfield) = 
			&editfield($ch, $curpos, $validchars[3], $text, 'call', $exc4len);
		
			if ($nextfield) {
				${$_[3]} = $nextfield;			# set new active field
			}
			
			$_[1]->{'exc4'} = $text;
			${$_[4]} = $curpos;
	}
	# none of the conditions above may have been true because we jumped from an
	# exc field to the next, which does not exist. in that case, always go to
	# 'call'.
	else {
			my $text = $_[1]->{'call'};
			${$_[3]} = 'call';
			($curpos, $text, $nextfield) = 
				&editfield($ch, $curpos, '[a-zA-Z0-9\/]', $text, 'exc1',12);
		
			if ($nextfield) {
				${$_[3]} = $nextfield;			# set new active field
			}
			
			$_[1]->{'call'} = $text;
			${$_[4]} = $curpos;
	}

	&refreshscreen(\$window, $activefield, $curpos, \%qso);

}



sub editfield {
	my $ch = $_[0];
	my $curpos = $_[1];
	my $regex = $_[2];
	my $text = $_[3];
	my $nextfield = $_[4];
	my $len = $_[5];
	my $realnextfield = 0;

			if ($ch eq KEY_LEFT) {
				$curpos-- if $curpos;
			}
			elsif ($ch eq KEY_RIGHT) {
				$curpos++ if ($curpos < length($text));
			}
			elsif (($ch =~ /^$regex$/) && (length($text) < $len)) {
				$curpos++;
				$ch = "\U$ch";
				$text = substr($text, 0, $curpos-1).$ch.substr($text, $curpos-1, );
			}
			elsif (($ch eq KEY_DC) && ($curpos < length($text))) {
				$text = substr($text, 0, $curpos).substr($text, $curpos+1, );
			}
			elsif ((($ch eq KEY_BACKSPACE) || (ord($ch)==8) || (ord($ch)==0x7F))
				   	&& ($curpos > 0)) {
				$text = substr($text, 0, $curpos-1).substr($text, $curpos, );
				$curpos--;
			}
			elsif (($ch eq ' ') || ($ch eq "\t" && $tabnextfield)) {	# next field.
				$curpos = 0;
				$realnextfield = $nextfield;			# we actually move
			}
			elsif ($ch eq "\t") {
				$curpos = 0;
				$realnextfield = 'call';			# tab -> to callsign
			}

	return ($curpos, $text, $realnextfield);
}



sub refreshscreen {
	my $window = ${$_[0]};
	my $activefield = $_[1];
	my $curpos = $_[2];
	my %qso = %{$_[3]};

	curs_set(0);
	addstr($$window, 22, 0, $qso{'nr'}.' ');
	addstr($$window, 22, 5, $qso{'band'}.'  ');
	addstr($$window, 22, 9, $qso{'mode'}.'  ');
	addstr($$window, 22, 13, &gettime());
	addstr($$window, 22, 18, $qso{'call'}.'            ');
	if ($contest eq 'QRP-TTF') {
		addstr($$window, 22, 31, $qso{'exc1'}.' 'x$exc1len);
		addstr($$window, 22, 37, $qso{'exc2'}.' 'x$exc2len);
		addstr($$window, 22, 43, $qso{'exc3'}.' 'x$exc3len);


		move($$window, 22, 0);
		chgat($$window, -1, A_NORMAL, 1, 0);
		if ($activefield eq 'call') {
			move($$window, 22, 18);
			chgat($$window, 12, A_REVERSE, 1, 0);
			move($$window, 22, 18+$curpos);
		}
		elsif ($activefield eq 'exc1') {
			move($$window, 22, 31);
			chgat($$window, $exc1len, A_REVERSE, 1, 0);
			move($$window, 22, 31+$curpos);
		}
		elsif ($activefield eq 'exc2') {
			move($$window, 22, 37);
			chgat($$window, $exc2len, A_REVERSE, 1, 0);
			move($$window, 22, 37+$curpos);
		}
		elsif ($activefield eq 'exc3') {
			move($$window, 22, 43);
			chgat($$window, $exc3len, A_REVERSE, 1, 0);
			move($$window, 22, 43+$curpos);
		}
	}else{
		addstr($$window, 22, 31, $qso{'rst'}.'   ');
		addstr($$window, 22, 37, $qso{'exc1'}.' 'x$exc1len);
		addstr($$window, 22, 43, $qso{'exc2'}.' 'x$exc2len);
		addstr($$window, 22, 49, $qso{'exc3'}.' 'x$exc3len);
		addstr($$window, 22, 55, $qso{'exc4'}.' 'x$exc4len);


		move($$window, 22, 0);
		chgat($$window, -1, A_NORMAL, 1, 0);
		if ($activefield eq 'call') {
			move($$window, 22, 18);
			chgat($$window, 12, A_REVERSE, 1, 0);
			move($$window, 22, 18+$curpos);
		}
		elsif ($activefield eq 'rst') {
			move($$window, 22, 31);
			chgat($$window, 3, A_REVERSE, 1, 0);
			move($$window, 22, 31+$curpos);
		}
		elsif ($activefield eq 'exc1') {
			move($$window, 22, 37);
			chgat($$window, $exc1len, A_REVERSE, 1, 0);
			move($$window, 22, 37+$curpos);
		}
		elsif ($activefield eq 'exc2') {
			move($$window, 22, 43);
			chgat($$window, $exc2len, A_REVERSE, 1, 0);
			move($$window, 22, 43+$curpos);
		}
		elsif ($activefield eq 'exc3') {
			move($$window, 22, 49);
			chgat($$window, $exc3len, A_REVERSE, 1, 0);
			move($$window, 22, 49+$curpos);
		}
		elsif ($activefield eq 'exc4') {
			move($$window, 22, 55);
			chgat($$window, $exc4len, A_REVERSE, 1, 0);
			move($$window, 22, 55+$curpos);
		}
	}
	curs_set(1);
	refresh($$window);



}




return 1;

# Local Variables:
# tab-width:4
# End: **

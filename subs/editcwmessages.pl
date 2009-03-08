use strict;
use warnings;

sub editcwmessages {
	my $window = $_[0];
	
	curs_set(0);
	addstr($$window, 0, 0, ' ' x 270);

	my $aline = 0; 		# active/selected line
	my $ypos = 0;
	my $ch='';

	do {
		for (0..6) {
			if ($_ == $aline) { attron($$window, A_BOLD); }
			else { attroff($$window, A_BOLD); }
			addstr($$window, $_, 1, "F".($_+1)." ".$main::cwmessages[$_]);

		}
		refresh($$window);

		$ch = getch();

		if (($ch eq KEY_UP) && ($aline > 0)) { $aline-- }
		elsif (($ch eq KEY_DOWN) && ($aline < 6)) { $aline++ }

	} until ($ch =~ /\s+/);

	my $message = $main::cwmessages[$aline];

	addstr($$window, 0, 0, ' ' x 270);
	attron($$window, A_BOLD);
	addstr($$window, 0, 10, 'Edit CW Message '.($aline+1));
	attroff($$window, A_BOLD);

	addstr($$window, 2, 1, $message);
	move($$window, 2, 1);
	chgat($$window, 35, A_REVERSE, 1, 0);

	addstr($$window, 4, 1, 'Values which will be replaced: ');
	addstr($$window, 5, 1, 'MYCALL HISCALL NR EXC1S EXC2S');

	curs_set(1);
	addstr($$window, 2, 1, $message);
	move($$window, 2, 1);
	my $curpos = 0;

	do {
		addstr($$window, 2, 1, $message.' 'x39);
		move($$window, 2, $curpos+1);
		refresh($$window);
		$ch = getch();
		if ($ch eq KEY_LEFT) {
			$curpos-- if $curpos;
		}
		elsif ($ch eq KEY_RIGHT) {
			$curpos++ if ($curpos < length($message));
		}
		elsif (($ch =~ /^[A-Z+-a-z0-9\/ =\?]$/) && (length($message) < 25)) {
			$curpos++;
			$ch = "\U$ch";
			$message = substr($message, 0, $curpos-1).$ch.substr($message, $curpos-1, );
		}
		elsif (($ch eq KEY_DC) && ($curpos < length($message))) {
			$message = substr($message, 0, $curpos).substr($message, $curpos+1, );
		}
		elsif ((($ch eq KEY_BACKSPACE) || (ord($ch)==8) || (ord($ch)==0x7F))
			   	&& ($curpos > 0)) {
			$message = substr($message, 0, $curpos-1).substr($message, $curpos, );
			$curpos--;
		}
		else {
			beep unless ($ch eq '-1');
		}
		

	} until ($ch =~ /\n/);

	# We edited message $aline+1 which is in line 10+($aline+1) in the log file
	
	open LOG, $main::filename;
	my @array = <LOG>;
	close LOG;

	$array[$aline+10] = $message."\n";

	open LOG, ">$main::filename";
	print LOG @array;
	close LOG;

	$main::cwmessages[$aline] = $message;

}


1;


# Local Variables:
# tab-width:4
# End: **

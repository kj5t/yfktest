sub sendcw {
	my $c = shift;

	# Just to make sure the speed is right. Could be wrong if user aborted
	# sending after "++".
	print $main::cwsocket chr(27)."2$main::cwspeed";
	
	if ($c eq 'esc') {
		print $main::cwsocket chr(27)."4";
	}
	if ($c =~ /f(\d)/) {
		print $main::cwsocket &cwmsg($main::cwmessages[$1-1]).' ';
	}
	elsif ($c eq 'ins') {
		print $main::cwsocket
			"$main::qso{'call'} ".&cwmsg($main::cwmessages[1]).' ';
	}
	elsif ($c eq 'pgup') {
		$main::cwspeed+=2 unless $main::cwspeed > 59;
		print $main::cwsocket chr(27)."2$main::cwspeed";
		addstr($main::wrate, 3,0, "  CW-Speed: $main::cwspeed");
		refresh($main::wrate);

	}
	elsif ($c eq 'pgdwn') {
		$main::cwspeed-=2 unless $main::cwspeed < 11;
		print $main::cwsocket chr(27)."2$main::cwspeed";
		addstr($main::wrate, 3,0, "  CW-Speed: $main::cwspeed");
		refresh($main::wrate);
	}

}


sub cwmsg {
	my $string = shift;

	$string =~ s/MYCALL/$main::mycall/g;
	$string =~ s/HISCALL/$main::qso{'call'}/g;
	$string =~ s/\bNR\b/$main::qso{'nr'}/g;
	$string =~ s/\bEXC1S\b/$main::exc1s/g;
	$string =~ s/\bEXC2S\b/$main::exc2s/g;

	return $string;

}


1;

# Local Variables:
# tab-width:4
# End: **

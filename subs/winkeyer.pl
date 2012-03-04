sub winkeyer {

	if ($main::winkey) {

		if (-r 'winkeydaemon.sh') {
		system('sh winkeydaemon.sh');
		sleep 1;
	}
	else {
		my $wdialog2 = newwin(24,80,0,0);
		attron($wdialog2, COLOR_PAIR(4));
		addstr($wdialog2, 0, 0, " " x (24*80));
		addstr($wdialog2, 0, 0, "Winkey configuration");

		addstr($wdialog2, 1, 0, "Do you have a winkeyer attached?");
		my $choice='YES NO';

		$main::winkey = &chose(\$wdialog2, 1, 50, $choice);

		if ($main::winkey =~ /NO/) {
			$main::winkey = 0;
		}
		else {
			$main::winkey = 1;

		addstr($wdialog2, 5, 0 , "Winkey port:");
		$tmp = &chose(\$wdialog2, 5, 20, '/dev/ttyS0 /dev/ttyS1 /dev/ttyUSB0
		/dev/ttyUSB1 /dev/ttyUSB2 /dev/ttyUSB3');
		$main::winkeypath = $tmp;
		
		open RIGFILE2, ">winkeydaemon.sh";
		print RIGFILE2 ".\/winkeydaemon.pl -d ";
		print RIGFILE2 $tmp."  ";
		
		close RIGFILE2;
		system('sh winkeydaemon.sh');
		sleep 1;
		refresh($wdialog2);
		}
	}
}
}

return 1;

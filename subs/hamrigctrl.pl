sub hamrigctrl {

	if ($main::rigctld) {

		if (-r 'rigctld.sh') {
			system('sh rigctld.sh');
			sleep 1;
	}
	else {
		my $wdialog1 = newwin(24,80,0,0);
		attron($wdialog1, COLOR_PAIR(4));
		addstr($wdialog1, 0, 0, " " x (24*80));
		addstr($wdialog1, 0, 0, "Radio configuration");

		addstr($wdialog1, 1, 0, "Is your radio connected to the computer ?");
		my $choice='YES NO';

		$main::rigctld = &chose(\$wdialog1, 1, 50, $choice);

		if ($main::rigctld =~ /NO/) {
			$main::rigctld = 0;
		}
		else {
			$main::rigctld = 1;

		my %hamlibrigs = &readhamlibrigs();

		addstr($wdialog1, 5, 0 , "Hamlib rig:");
		addstr($wdialog1, 6, 0 , "Hamlib port:");
		addstr($wdialog1, 7, 0 , "Hamlib speed:");
		my @a = sort keys(%hamlibrigs);
		my $tmp = "@a";
		$tmp = &chose(\$wdialog1, 5, 20, $tmp);

		$main::rigmodel = $hamlibrigs{$tmp};
		$tmp = &chose(\$wdialog1, 6, 20, '/dev/ttyS0 /dev/ttyS1 /dev/ttyUSB0
		/dev/ttyUSB1 /dev/ttyUSB2 /dev/ttyUSB3');
		$main::rigspeed = &chose(\$wdialog1, 7, 20, '1200 4800 9600 19200 38400');
		$main::rigpath = $tmp;
		
		open RIGFILE1, ">rigctld.sh";
		print RIGFILE1 "rigctld -m ";
		print RIGFILE1 $main::rigmodel." "."-r ".$tmp." -s ".$main::rigspeed. " &";
		
		close RIGFILE1;
		system('sh rigctld.sh');
		sleep 1;
		refresh($wdialog1);
		}
	}
}
}

sub readhamlibrigs {
	my $line;
	my %hash;
	open RIG, "hamlibrigs";
	while ($line = <RIG>) {
		chomp($line);
		my @a = split(/\s+/, $line);
		$hash{$a[0]} = $a[1];
	}
	close RIG;
	return %hash;
}

return 1;

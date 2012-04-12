
sub setconfigs {

		&readconfigfile();

		my $filename=".yfktest";
		my $wdialog3 = newwin(24,80,0,0);
		attron($wdialog3, COLOR_PAIR(4));
		addstr($wdialog3, 0, 0, " " x (24*80));
		addstr($wdialog3, 0, 0, "YFKtest configuration");
		addstr($wdialog3, 1, 0, "Do you want to change the configuration options ?");

		my $choice='YES NO';
		$choice = &chose(\$wdialog3, 1, 50, $choice);

		if ($choice =~ /NO/) {
			addstr($wdialog3, 3, 0, "Thanks anyways");
			sleep 2;
			return 0;
		}
		else {

		attron($wdialog3, COLOR_PAIR(6));
		addstr($wdialog3 , 3, 10 , " Use the LEFT and RIGHT cursor keys to change settings. ");
		addstr($wdialog3 , 4, 10 , " Then press <enter> to set and move down. ");
		attron($wdialog3, COLOR_PAIR(4));

		my $line = 7;
		my @configs = qw /mycall rigctld winkey tabnextfield cwspeed nologdupe colorscheme showmsgkeys ops wantcqrepeat cqinterval/;
		foreach (sort @configs) {
			unless ($_ =~ m/CONFIG/) {
			addstr($wdialog3, $line, 15-(length($_)), "$_ : ");
			$line ++;
			}
		}

		addstr($wdialog3, 7, 40 , "Four different color schemes to try.");
		addstr($wdialog3, 8, 40 , "Time in seconds between auto-cq xmits.");
		addstr($wdialog3, 9, 40 , "Set the starting cwspeed.");
		addstr($wdialog3,10, 40 , "Enter in the station callsign.");
		addstr($wdialog3,11, 40 , "Require pressing Alt+l to log a dupe.");
		addstr($wdialog3,12, 40 , "Optional: Add your handle or call.");
		addstr($wdialog3,13, 40 , "Enable the rig control hookup. ");
		addstr($wdialog3,14, 40 , "Show the cw message key's titles.");
		addstr($wdialog3,15, 40 , "Sets tab key to work same as spacebar.");
		addstr($wdialog3,16, 40 , "Turns on automatic running/cq-repeat.");
		addstr($wdialog3,17, 40 , "Enable the winkeyer hookup.");

		$colorscheme = &chose(\$wdialog3, 7, 18, '0 1 2 3', $colorscheme);
		$cqinterval = &chose(\$wdialog3, 8, 18, '4 6 8 10 12 14 16', $cqinterval);
		$cwspeed = &chose(\$wdialog3, 9, 18, '18 20 22 24 26 28 30', $cwspeed);

		attron($wdialog3,COLOR_PAIR(6));
		addstr($wdialog3 , 5, 10 , " Enter in the call you would like . ");
		attron($wdialog3,COLOR_PAIR(4));

		$mycall = &readw(\$wdialog3, 10, 18, 'call', $mycall);

		attron($wdialog3,COLOR_PAIR(6));
		addstr($wdialog3 , 5, 10 , " Use '0' to Turn OFF & '1' to Turn ON . ");
		attron($wdialog3,COLOR_PAIR(4));

		$nologdupe = &chose(\$wdialog3, 11, 18, '0 1', $nologdupe);
		$ops = &readw(\$wdialog3, 12, 18, 'call', $ops);
		$rigctld = &chose(\$wdialog3,  13, 18, '0 1', $rigctld);

		attron($wdialog3,COLOR_PAIR(6));
		addstr($wdialog3 , 19, 1 , "NOTE: The winkeyer & rig-control cannot work until the program is restarted.");
		attron($wdialog3,COLOR_PAIR(4));

		$showmsgkeys = &chose(\$wdialog3, 14, 18, '0 1', $showmsgkeys);
		$tabnextfield = &chose(\$wdialog3, 15, 18, '0 1', $tabnextfield);

		attron($wdialog3,COLOR_PAIR(6));
		addstr($wdialog3 , 21, 1 , " After this final selection, press <enter> & the configuration will be set . ");
		attron($wdialog3,COLOR_PAIR(4));

		$wantcqrepeat = &chose(\$wdialog3, 16, 18, '0 1', $wantcqrepeat);
		$winkey = &chose(\$wdialog3, 17, 18, '0 1', $winkey);

		open CONFIGS, ">$filename";
		print CONFIGS "CONFIG\n";
		print CONFIGS "mycall\=".$mycall."\n"."rigctld\=".$rigctld."\n"."winkey\=".$winkey."\n".
			"tabnextfield\=".$tabnextfield."\n"."cwspeed\=".$cwspeed."\n"."nologdupe\=".
			$nologdupe."\n"."colorscheme\=".$colorscheme."\n"."showmsgkeys\=".$showmsgkeys."\n".
			"ops\=".$ops."\n"."wantcqrepeat\=".$wantcqrepeat."\n"."cqinterval\=".$cqinterval."\n";
		close CONFIGS;
		}
		sleep 1;

#		unless ($main::cwspeed > 59) {
		print $main::cwsocket chr(27)."2$main::cwspeed";
		addstr($main::wrate, 3,0, "  CW-Speed: $main::cwspeed");
		refresh($main::wrate);
#		}

#		refresh($wdialog3);
		return 1;

}

return 1;

# Local Variables:
# tab-width:4
# End: **

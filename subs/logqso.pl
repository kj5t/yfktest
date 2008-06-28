load_subs("gettime.pl");
load_subs("getdate.pl");

sub logqso {
	my %qso = %{$_[0]};
#	my @validentry = @{$_[2]};		# regexes
	my $filename = $_[3];

	my @validentry = @main::validentry;

	if ($qso{'call'} eq 'WRITELOG') {
		return 1;
	}

	# check validity of this QSO
	if (
			($qso{'call'} =~ /[A-Z0-9][A-Z0-9][A-Z]/) &&
			($qso{'exc1'} =~ /^$validentry[0]$/) &&
			($qso{'exc2'} =~ /^$validentry[1]$/) &&
			($qso{'exc3'} =~ /^$validentry[2]$/) &&
			($qso{'exc4'} =~ /^$validentry[3]$/)
	) {

		# for QSOs NOT coming over the network
		unless (defined($qso{stn})) {
			$qso{stn} = $main::netname;
		}

		${$_[0]}{'nr'}++;

		$qso{'utc'} = &gettime();
		$qso{'date'} = &getdate();

		push @{$_[1]}, { %qso };

		open LOG, ">>$filename";

		my $logline = sprintf(
				"%-4s;%-3s;%3s;%-4s;%-8s;%-12s;%-6s;%-6s;%-6s;%-6s;%-6s\n",
				$qso{'nr'}, $qso{'band'}, $qso{'mode'}, $qso{'utc'},
				$qso{'date'}, $qso{'call'}, $qso{'exc1'}, $qso{'exc2'},
				$qso{'exc3'}, $qso{'exc4'}, $qso{stn});

		print LOG $logline;
		close LOG;

		# Send the QSO over the net...

#		print STDERR "$qso{stn} == $main::netname ?\n";

		$logline = sprintf(
				"%-4s;%-3s;%3s;%-4s;%-8s;%-12s;%-6s;%-6s;%-6s;%-6s;%-6s\n",
				0, $qso{'band'}, $qso{'mode'}, $qso{'utc'},
				$qso{'date'}, $qso{'call'}, $qso{'exc1'}, $qso{'exc2'},
				$qso{'exc3'}, $qso{'exc4'}, $qso{stn});


#		if ($qso{stn} eq $main::netname) {
#			print $main::netsocket "YFK:$logline";
#		}

		return 1;
	}
	else {
		return 0;
	}

}

# Logging an edited QSO.

sub logeditqso {
		my $success = 0;
		my %qso = %main::qso;		# less typing
		my @validentry = @main::validentry;

		unless (
				($qso{'call'} =~ /[A-Z0-9][A-Z0-9][A-Z]/) &&
				($qso{'exc1'} =~ /^$validentry[0]$/) &&
				($qso{'exc2'} =~ /^$validentry[1]$/) &&
				($qso{'exc3'} =~ /^$validentry[2]$/) &&
				($qso{'exc4'} =~ /^$validentry[3]$/)
		) {
			addstr($main::wmain,23,0, "Invalid data entered QSO not changed!");
			return 0;
		}


		open LOG, $main::filename;
		my @log = <LOG>;
		close LOG;

		# search for the QSO with the same number as $editnr:

		# The number in the array might be different from the actual number, so
		# we search the actual number. Also the QSO has to be from the same
		# station. XXX

#		my $realeditnr = $main::qsos[$editnr]{'nr'};

		for (my $i=0 ; $i <= $#log; $i++) {
			next while ($i < 17);						# HEADER
			if ($log[$i] =~ /^$qso{'nr'}.+$main::netname\s*$/) {
				$log[$i] =  sprintf(
				"%-4s;%-3s;%3s;%-4s;%-8s;%-12s;%-6s;%-6s;%-6s;%-6s;%-6s\n",
				$qso{'nr'}, $qso{'band'}, $qso{'mode'}, $qso{'utc'},
				$qso{'date'}, $qso{'call'}, $qso{'exc1'}, $qso{'exc2'},
				$qso{'exc3'}, $qso{'exc4'}, $qso{stn});
				$success = 1;
				last;
			}

		}

		if ($success) {
			open LOG, ">$main::filename";
			print LOG @log;
			close LOG;
		}

		return $success;
}







return 1;

# Local Variables:
# tab-width:4
# End: **

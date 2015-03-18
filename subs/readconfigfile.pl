

sub readconfigfile {


	my $filename=".yfktest";

	if (-r $filename) {
			open CONF, ".yfktest" or return;
	} else {
	open CONF, $ENV{HOME}."/.yfktest" or return;
	}
	while ($line = <CONF>) {
		if ($line =~ /mycall=(.+)/) {
			$main::mycall = uc($1);
		}
		elsif ($line =~ /rigctld=(.+)/) {
			$main::rigctld = $1;
		}
		elsif ($line =~ /winkey=(.+)/) {
			$main::winkey = $1;
		}
		elsif ($line =~ /cwspeed=(.+)/) {
			$main::cwspeed = $1;
		}
		elsif ($line =~ /tabnextfield=(.+)/) {
			$main::tabnextfield = $1;
		}
		elsif ($line =~ /nologdupe=(.+)/) {
			$main::nologdupe = $1;
		}
		elsif ($line =~ /colorscheme=(.+)/) {
			$main::colorscheme = $1;
		}
		elsif ($line =~ /showmsgkeys=(.+)/) {
			$main::showmsgkeys = $1;
		}
		elsif ($line =~ /ops=(.+)/) {
			$main::ops = uc($1);
		}
		elsif ($line =~ /wantcqrepeat=(.+)/) {
			$main::wantcqrepeat = $1;
		}
		elsif ($line =~ /cqinterval=(.+)/) {
			$main::cqinterval = $1;
		}
		elsif ($line =~ /submitname=(.+)/) {
			$main::submitname = $1;
		}
		elsif ($line =~ /address1=(.+)/) {
			$main::address1 = $1;
		}
		elsif ($line =~ /address2=(.+)/) {
			$main::address2 = $1;
		}
		elsif ($line =~ /address3=(.+)/) {
			$main::address3 = $1;
		}
		elsif ($line =~ /address4=(.+)/) {
			$main::address4 = $1;
		}
	}

	close CONF;

}



return 1;

# Local Variables:
# tab-width:4
# End: **

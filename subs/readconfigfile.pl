

sub readconfigfile {

	open CONF, $ENV{HOME}."/.yfktest";

	while ($line = <CONF>) {
		if ($line =~ /mycall=(.+)/) {
			$main::mycall = uc($1);
		}
	}

	close CONF;

}



return 1;

# Local Variables:
# tab-width:4
# End: **

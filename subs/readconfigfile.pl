

sub readconfigfile {

	open CONF, $ENV{HOME}."/.yfktest" || return 1;

	while ($line = <CONF>) {
		if ($line =~ /mycall=(.+)/) {
			$main::mycall = $1;
		}
	}

	close CONF;

}



return 1;

# Local Variables:
# tab-width:4
# End: **

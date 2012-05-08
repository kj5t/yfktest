sub sendvoice {

	my $service = 'mplayer';
	my $status = `/bin/ps cax | /bin/grep $service`;
	if (!$status) {
		my $c = shift;
#		if ($c eq 'esc') { `pkill $service`; }
		if ($c =~ /f(\d)/) { `$service voice/test > /dev/null 2>&1`; }
	}

}

1;

# Local Variables:
# tab-width:4
# End: **

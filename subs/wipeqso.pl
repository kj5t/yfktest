
sub wipeqso {

${$_[1]} = 0;			# curpor position
${$_[2]} = 'call';		# active field

# initialize QSO hash
$_[0]->{'call'} = '';

if ($_[0]->{'mode'} eq 'SSB') {
	$_[0]->{'rst'} = '59'; 
}
else {
	$_[0]->{'rst'} = '599'; 
}

$_[0]->{'exc1'} = ''; 
$_[0]->{'exc2'} = ''; 
$_[0]->{'exc3'} = ''; 
$_[0]->{'exc4'} = ''; 
$_[0]->{'stn'} = $main::netname; 
}


return 1;

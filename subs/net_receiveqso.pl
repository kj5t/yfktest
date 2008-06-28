use strict;
use warnings;


sub net_receiveqso {

my $MySocket = new IO::Socket::INET->new(LocalPort=>9871, Proto=>'udp');

while (1) {
$MySocket->recv(my $line,1024);

$line =~ s/\s+//g;

if ($line =~ /^YFK:(.+)/) {
	
	my @rx = split(/;/, $1);


	if ($rx[10] ne $main::netname) {

		%main::net_qso = (        # The current QSO
   	     'nr' => $rx[0],
   	     'utc' => $rx[3],
   	     'date' => $rx[4],
   	     'call' => $rx[5],
   	     'rst' => '599',
		 'excs' => '',
   	     'exc1' => $rx[6],
   	     'exc2' => $rx[7],
   	     'exc3' => $rx[8],
   	     'exc4' => $rx[9],
   	     'band' => $rx[1],
   	     'mode' => $rx[2],
		 'stn' => $rx[10] 
 		);

 	}

	@rx = ();

}

}


}

return 1;

# Local Variables:
# tab-width:4
# End: **

sub readrules {

	my $contest = shift;


	open RULES, "defs/$contest.def";
		@rules = <RULES>;
		chomp(@rules);
	close RULES;

		foreach (@rules) {				# remove comments
			$_ =~ s/[\s\t]+#.+$//g;
		}

		$main::defmult1 =		$rules[1];
		$main::defqsopts =		$rules[2];
		$main::defmult2 = 		$rules[3];
		$main::entryfields = 	$rules[4];
		$main::exc1len =	 	$rules[5];
		$main::exc2len =	 	$rules[6];
		$main::exc3len =	 	$rules[7];
		$main::exc4len =	 	$rules[8];

		@main::validchars = @rules[9, 11, 13, 15];
		@main::validentry = @rules[10, 12, 14, 16];
		
		$main::cabrilloline =	$rules[17];
		$main::cabrillovalues=	$rules[18];
		$main::cabrilloname=	$rules[19];
		
		$main::fixexchange	=	$rules[20];
		$main::fixexchangename = $rules[21];

		@main::cwmessages = @rules[22..28] unless $#main::cwmessages;

}

return 1;

# Local Variables:
# tab-width:4
# End: **

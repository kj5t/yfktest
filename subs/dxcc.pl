use strict;
use POSIX;				# needed for acos in distance/direction calculation

# Now we read cty.dat from K1EA, or exit when it's not found.

open CTY, "cty.dat";

my %prefixes;			# hash of arrays  main prefix -> (all, prefixes,..)
my %dxcc;				# hash of arrays  main prefix -> (CQZ, ITUZ, ...)
my $mainprefix;

my $lidadditions="^QRP\$|^LGT\$";
my $csadditions="(^P\$)|(^M{1,2}\$)|(^AM\$)";


while (my $line = <CTY>) {
	if (substr($line, 0, 1) ne ' ') {			# New DXCC
		$line =~ /\s+([*A-Za-z0-9\/]+):\s+$/;
		$mainprefix = $1;
		$line =~ s/\s{2,}//g;
		@{$dxcc{$mainprefix}} = split(/:/, $line);
	}
	else {										# prefix-line
		$line =~ s/\s+//g;
		unless (defined($prefixes{$mainprefix}[0])) {
			@{$prefixes{$mainprefix}} = split(/,|;/, $line);
		}
		else {
			push(@{$prefixes{$mainprefix}}, split(/,|;/, $line));
		}
	}
}



###############################################################################
#
# &wpx derives the Prefix following WPX rules from a call. These can be found
# at: http://www.cq-amateur-radio.com/wpxrules.html
#  e.g. DJ1YFK/TF3  can be counted as both DJ1 or TF3, but this sub does 
# not ask for that, always TF3 (= the attached prefix) is returned. If that is 
# not want the OP wanted, it can still be modified manually.
#
###############################################################################
 
sub wpx {
  my ($prefix,$a,$b,$c);
  
  # First check if the call is in the proper format, A/B/C where A and C
  # are optional (prefix of guest country and P, MM, AM etc) and B is the
  # callsign. Only letters, figures and "/" is accepted, no further check if the
  # callsign "makes sense".
  # 23.Apr.06: Added another "/X" to the regex, for calls like RV0AL/0/P
  # as used by RDA-DXpeditions....
    
if ($_[0] =~ 
	/^((\d|[A-Z])+\/)?((\d|[A-Z]){3,})(\/(\d|[A-Z])+)?(\/(\d|[A-Z])+)?$/) {
   
    # Now $1 holds A (incl /), $3 holds the callsign B and $5 has C
    # We save them to $a, $b and $c respectively to ensure they won't get 
    # lost in further Regex evaluations.
   
    ($a, $b, $c) = ($1, $3, $5);
    if ($a) { chop $a };            # Remove the / at the end 
    if ($c) { $c = substr($c,1,)};  # Remove the / at the beginning
    
    # In some cases when there is no part A but B and C, and C is longer than 2
    # letters, it happens that $a and $b get the values that $b and $c should
    # have. This often happens with liddish callsign-additions like /QRP and
    # /LGT, but also with calls like DJ1YFK/KP5. ~/.yfklog has a line called    
    # "lidadditions", which has QRP and LGT as defaults. This sorts out half of
    # the problem, but not calls like DJ1YFK/KH5. This is tested in a second
    # try: $a looks like a call (.\d[A-Z]) and $b doesn't (.\d), they are
    # swapped. This still does not properly handle calls like DJ1YFK/KH7K where
    # only the OP's experience says that it's DJ1YFK on KH7K.

if (!$c && $a && $b) {                  # $a and $b exist, no $c
        if ($b =~ /$lidadditions/) {    # check if $b is a lid-addition
            $b = $a; $a = undef;        # $a goes to $b, delete lid-add
        }
        elsif (($a =~ /\d[A-Z]+$/) && ($b =~ /\d$/)) {   # check for call in $a
        }
}    

	# *** Added later ***  The check didn't make sure that the callsign
	# contains a letter. there are letter-only callsigns like RAEM, but not
	# figure-only calls. 

	if ($b =~ /^[0-9]+$/) {			# Callsign only consists of numbers. Bad!
			return undef;			# exit, undef
	}

    # Depending on these values we have to determine the prefix.
    # Following cases are possible:
    #
    # 1.    $a and $c undef --> only callsign, subcases
    # 1.1   $b contains a number -> everything from start to number
    # 1.2   $b contains no number -> first two letters plus 0 
    # 2.    $a undef, subcases:
    # 2.1   $c is only a number -> $a with changed number
    # 2.2   $c is /P,/M,/MM,/AM -> 1. 
    # 2.3   $c is something else and will be interpreted as a Prefix
    # 3.    $a is defined, will be taken as PFX, regardless of $c 

    if ((not defined $a) && (not defined $c)) {  # Case 1
            if ($b =~ /\d/) {                    # Case 1.1, contains number
                $b =~ /(.+\d)[A-Z]*/;            # Prefix is all but the last
                $prefix = $1;                    # Letters
            }
            else {                               # Case 1.2, no number 
                $prefix = substr($b,0,2) . "0";  # first two + 0
            }
    }        
    elsif ((not defined $a) && (defined $c)) {   # Case 2, CALL/X
           if ($c =~ /^(\d)$/) {              # Case 2.1, number
                $b =~ /(.+\d)[A-Z]*/;            # regular Prefix in $1
                # Here we need to find out how many digits there are in the
                # prefix, because for example A45XR/0 is A40. If there are 2
                # numbers, the first is not deleted. If course in exotic cases
                # like N66A/7 -> N7 this brings the wrong result of N67, but I
                # think that's rather irrelevant cos such calls rarely appear
                # and if they do, it's very unlikely for them to have a number
                # attached.   You can still edit it by hand anyway..  
                if ($1 =~ /^([A-Z]\d)\d$/) {        # e.g. A45   $c = 0
                                $prefix = $1 . $c;  # ->   A40
                }
                else {                         # Otherwise cut all numbers
                $1 =~ /(.*[A-Z])\d+/;          # Prefix w/o number in $1
                $prefix = $1 . $c;}            # Add attached number    
            } 
            elsif ($c =~ /$csadditions/) {
                $b =~ /(.+\d)[A-Z]*/;       # Known attachment -> like Case 1.1
                $prefix = $1;
            }
            elsif ($c =~ /^\d\d+$/) {		# more than 2 numbers -> ignore
                $b =~ /(.+\d)[A-Z]*/;       # see above
                $prefix = $1;
			}
			else {                          # Must be a Prefix!
                    if ($c =~ /\d$/) {      # ends in number -> good prefix
                            $prefix = $c;
                    }
                    else {                  # Add Zero at the end
                            $prefix = $c . "0";
                    }
            }
    }
    elsif (defined $a) {                    # $a contains the prefix we want
            if ($a =~ /\d$/) {              # ends in number -> good prefix
                    $prefix = $a
            }
            else {                          # add zero if no number
                    $prefix = $a . "0";
            }
    }

# In very rare cases (right now I can only think of KH5K and KH7K and FRxG/T
# etc), the prefix is wrong, for example KH5K/DJ1YFK would be KH5K0. In this
# case, the superfluous part will be cropped. Since this, however, changes the
# DXCC of the prefix, this will NOT happen when invoked from with an
# extra parameter $_[1]; this will happen when invoking it from &dxcc.
    
if (($prefix =~ /(\w+\d)[A-Z]+\d/) && (not defined $_[1])) {
        $prefix = $1;                
}
    
return $prefix;
}
else { return ''; }    # no proper callsign received.
} # wpx ends here


##############################################################################
#
# &dxcc determines the DXCC country of a given callsign using the cty.dat file
# provided by K1EA at http://www.k1ea.com/cty/cty.dat .
# An example entry of the file looks like this:
#
# Portugal:                 14:  37:  EU:   38.70:     9.20:     0.0:  CT:
#     CQ,CR,CR5A,CR5EBD,CR6EDX,CR7A,CR8A,CR8BWW,CS,CS98,CT,CT98;
#
# The first line contains the name of the country, WAZ, ITU zones, continent, 
# latitude, longitude, UTC difference and main Prefix, the second line contains 
# possible Prefixes and/or whole callsigns that fit for the country, sometimes 
# followed by zones in brackets (WAZ in (), ITU in []).
#
# This sub checks the callsign against this list and the DXCC in which 
# the best match (most matching characters) appear. This is needed because for 
# example the CTY file specifies only "D" for Germany, "D4" for Cape Verde.
# Also some "unusual" callsigns which appear to be in wrong DXCCs will be 
# assigned properly this way, for example Antarctic-Callsigns.
# 
# Then the callsign (or what appears to be the part determining the DXCC if
# there is a "/" in the callsign) will be checked against the list of prefixes
# and the best matching one will be taken as DXCC.
#
# The return-value will be an array ("Country Name", "WAZ", "ITU", "Continent",
# "latitude", "longitude", "UTC difference", "DXCC").   
#
###############################################################################

sub dxcc {
	my $testcall = $_[0];
	my $wae=0;
	my $matchchars=0;
	my $matchprefix='';
	my $test;
	my $zones = '';                 # annoying zone exceptions
	my $goodzone;
	my $letter='';

	if (defined($_[1])) {			# WAEs separately?
		$wae = 1;
	}

if ($testcall =~ /(^OH\/)|(\/OH[1-9]?$)/) {    # non-Aland prefix!
    $testcall = "OH";                      # make callsign OH = finland
}
elsif ($testcall =~ /\w\/\w/) {             # check if the callsign has a "/"
    $testcall = &wpx($testcall,1)."AA";		# use the wpx prefix instead, which may
                                         # intentionally be wrong, see &wpx!
}

$letter = substr($testcall, 0,1);

foreach $mainprefix (keys %prefixes) {

	foreach $test (@{$prefixes{$mainprefix}}) {
		my $len = length($test);

		if ($letter ne substr($test,0,1)) {			# gains 20% speed
			next;
		}

		$zones = '';

		if (($len > 5) && ((index($test, '(') > -1)			# extra zones
						|| (index($test, '[') > -1))) {
				$test =~ /^([A-Z0-9\/]+)([\[\(].+)/;
				$zones .= $2 if defined $2;
				$len = length($1);
		}

		if ((substr($testcall, 0, $len) eq substr($test,0,$len)) &&
								($matchchars <= $len))	{
			$matchchars = $len;
			$matchprefix = $mainprefix;
			$goodzone = $zones;
		}
	}
}

my @mydxcc;										# save typing work

if (defined($dxcc{$matchprefix})) {
	@mydxcc = @{$dxcc{$matchprefix}};
}
else {
	@mydxcc = qw/Unknown 0 0 0 0 0 0 ?/;
}

# Different zones?

if ($goodzone) {
	if ($goodzone =~ /\((\d+)\)/) {				# CQ-Zone in ()
		$mydxcc[1] = $1;
	}
	if ($goodzone =~ /\[(\d+)\]/) {				# ITU-Zone in []
		$mydxcc[2] = $1;
	}
}

# cty.dat has special entries for WAE countries which are not separate DXCC
# countries. Those start with a "*", for example *TA1. Those have to be changed
# to the proper DXCC. Since there are opnly a few of them, it is hardcoded in
# here.

unless ($wae) {
	if ($mydxcc[7] =~ /^\*/) {							# WAE country!
		if ($mydxcc[7] eq '*TA1') { $mydxcc[7] = "TA" }		# Turkey
		if ($mydxcc[7] eq '*4U1V') { $mydxcc[7] = "OE" }	# 4U1VIC is in OE..
		if ($mydxcc[7] eq '*GM/s') { $mydxcc[7] = "GM" }	# Shetlands
		if ($mydxcc[7] eq '*IT9') { $mydxcc[7] = "I" }		# Sicily
		if ($mydxcc[7] eq '*JW/b') { $mydxcc[7] = "JW" }	# Bear Island
		if ($mydxcc[7] eq '*IG9') { $mydxcc[7] = "I" }		# African Italy 
	}
}


# CTY.dat uses "/" in some DXCC names, but I prefer to remove them, for example
# VP8/s ==> VP8s etc.

$mydxcc[7] =~ s/\///g;

return @mydxcc; 

} # dxcc ends here 


return 1;

# Local Variables:
# tab-width:4
# End: **

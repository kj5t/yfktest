sub getdate {
    my @date = gmtime();        # $date[2] has hour, 1 has minutes
    if ($date[3] < 10) { $date[3] = "0".$date[3]; }   # Add 0 if neccessary
	$date[4]++;
    if ($date[4] < 10) { $date[4] = "0".$date[4]; }
    return ($date[5]+1900).'-'.$date[4].'-'.$date[3];
}

return 1;

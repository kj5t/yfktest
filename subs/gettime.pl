sub gettime {
    my @date = gmtime();        # $date[2] has hour, 1 has minutes
    if ($date[1] < 10) { $date[1] = "0".$date[1]; }   # Add 0 if neccessary
    if ($date[2] < 10) { $date[2] = "0".$date[2]; }
    return $date[2].$date[1];
}

return 1;

# Local Variables:
# tab-width:4
# End: **

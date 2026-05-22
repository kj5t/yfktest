use strict;
use POSIX qw(WNOHANG);
use Errno qw(EAGAIN);
use Fcntl qw(F_GETFL F_SETFL O_NONBLOCK);
use Digest::MD5 qw(md5_hex);

# Aliases to main-package variables used in this file.
# Suppresses perl -w "used only once" warnings that would appear before
# Curses is initialised (and therefore be visible as raw terminal text).
our ($mycall, $contest, $version, $exc1s, $exc2s, $exc3s, $wmain, $ops, $modes, $s_sum,
     $power, $assisted, $transmitter, $operator, $bands);
our (@qsos, %s_qsos, %s_qsopts, %s_mult1, %s_mult2);

our $rtc_logfile = 'rtc-server.log';

sub rtc_log {
    my ($msg) = @_;
    open my $fh, '>>', $rtc_logfile or return;
    my @t = gmtime(time);
    printf $fh "[%04d-%02d-%02d %02d:%02d:%02dZ] %s\n",
        $t[5]+1900, $t[4]+1, $t[3], $t[2], $t[1], $t[0], $msg;
    close $fh;
}

our $rtc_enabled     = 0;
our $rtc_callsign    = '';
our $rtc_password    = '';
our $rtc_contest     = '';
our $rtc_url         = 'http://scoredistributor.net/';
our $rtc_dxcccountry = '';
our $rtc_cqzone      = '';
our $rtc_iaruzone    = '';
our $rtc_arrlsection = '';
our $rtc_stproth     = '';
our $rtc_grid6       = '';
our $rtc_mult1type   = '';   # e.g. state, zone, country, wpxprefix, gridsquare, hq
our $rtc_mult2type   = '';

our @rtc_pending_new        = ();
our @rtc_pending_replace    = ();
our @rtc_pending_delete     = ();
our $rtc_pending_deletelog  = 0;   # set before a full resync to prepend <deletelog>
our $rtc_last_post       = 0;
our $rtc_post_interval   = 120;
our $rtc_pipe_pid        = 0;
our $rtc_pipe_fh         = undef;
our $rtc_xml_file        = '';
our $rtc_response        = '';
our $rtc_status          = '';
our $rtc_status_expire   = 0;

sub rtc_read_config {
    my $filename = -r 'rtc-server.conf' ? 'rtc-server.conf'
                 : -r "$ENV{HOME}/rtc-server.conf" ? "$ENV{HOME}/rtc-server.conf"
                 : return;

    open my $fh, '<', $filename or return;
    while (my $line = <$fh>) {
        chomp $line;
        $line =~ s/\s+$//;
        next if $line =~ /^\s*#/ or $line eq '';
        if    ($line =~ /^enabled=(.+)/)      { $rtc_enabled      = $1; }
        elsif ($line =~ /^callsign=(.+)/)     { $rtc_callsign     = uc($1); }
        elsif ($line =~ /^password=(.+)/)     { $rtc_password     = $1; }
        elsif ($line =~ /^contest=(.+)/)      { $rtc_contest      = $1; }
        elsif ($line =~ /^url=(.+)/)          { $rtc_url          = $1; }
        elsif ($line =~ /^dxcccountry=(.+)/)  { $rtc_dxcccountry  = uc($1); }
        elsif ($line =~ /^cqzone=(.+)/)       { $rtc_cqzone       = $1; }
        elsif ($line =~ /^iaruzone=(.+)/)     { $rtc_iaruzone     = $1; }
        elsif ($line =~ /^arrlsection=(.+)/)  { $rtc_arrlsection  = uc($1); }
        elsif ($line =~ /^stproth=(.+)/)      { $rtc_stproth      = uc($1); }
        elsif ($line =~ /^grid6=(.+)/)        { $rtc_grid6        = uc($1); }
        elsif ($line =~ /^mult1type=(.+)/)    { $rtc_mult1type    = lc($1); }
        elsif ($line =~ /^mult2type=(.+)/)    { $rtc_mult2type    = lc($1); }
    }
    close $fh;
}

sub rtc_qso_id {
    my ($qso) = @_;
    return md5_hex(join("\x00", $main::mycall // '', $main::contest // '',
                               $qso->{'nr'}, $qso->{'date'}, $qso->{'utc'}));
}

sub rtc_cabrillo_mode {
    my ($mode) = @_;
    my %m = (SSB => 'PH', FM => 'PH', RTTY => 'RY', CW => 'CW', P31 => 'P3', P63 => 'P6');
    return $m{$mode} // $mode;
}

sub rtc_cabrillo_string {
    my ($qso) = @_;

    my %band2freq = (160 => 1800, 80 => 3500, 40 => 7000, 30 => 10100,
                     20 => 14000, 17 => 18068, 15 => 21000, 12 => 24890,
                     10 => 28000, 6 => 50000, 2 => 144000);
    my $freq = $qso->{'freq'}
        ? int($qso->{'freq'} / 0.001 + 0.5)
        : ($band2freq{$qso->{'band'}} // 14000);

    my $mode = rtc_cabrillo_mode($qso->{'mode'});

    (my $date = $qso->{'date'}) =~ s/(\d{4})(\d{2})(\d{2})/$1-$2-$3/;

    # RTC contest uses no RST; format is:
    #   QSO: freq mode date time mycall my_serial(04d) my_grid call their_serial(04d) their_grid
    if ($main::contest eq 'RTC') {
        my $my_nr   = sprintf('%04d', $qso->{'nr'} // 1);
        my $my_grid = uc($qso->{'exc1s'} // '');
        my $th_nr   = sprintf('%04d', int($qso->{'exc1'} // 0));
        my $th_grid = uc($qso->{'exc2'} // '');
        return "QSO: $freq $mode $date $qso->{'utc'} $main::mycall $my_nr $my_grid $qso->{'call'} $th_nr $th_grid";
    }

    my $rst  = ($qso->{'mode'} eq 'SSB' || $qso->{'mode'} eq 'FM') ? '59' : '599';

    my @sent;
    push @sent, $qso->{'exc1s'} if ($qso->{'exc1s'} // '') =~ /\S/;
    push @sent, $qso->{'exc2s'} if ($qso->{'exc2s'} // '') =~ /\S/;
    push @sent, $qso->{'exc3s'} if ($qso->{'exc3s'} // '') =~ /\S/;

    my @rcvd;
    push @rcvd, $qso->{'exc1'} if ($qso->{'exc1'} // '') =~ /\S/;
    push @rcvd, $qso->{'exc2'} if ($qso->{'exc2'} // '') =~ /\S/;
    push @rcvd, $qso->{'exc3'} if ($qso->{'exc3'} // '') =~ /\S/;
    push @rcvd, $qso->{'exc4'} if ($qso->{'exc4'} // '') =~ /\S/;

    my $cbr = "QSO: $freq $mode $date $qso->{'utc'} $main::mycall $rst";
    $cbr .= ' ' . join(' ', @sent) if @sent;
    $cbr .= " $qso->{'call'} $rst";
    $cbr .= ' ' . join(' ', @rcvd) if @rcvd;

    return $cbr;
}

sub rtc_xml_escape {
    my ($s) = @_;
    $s =~ s/&/&amp;/g;
    $s =~ s/</&lt;/g;
    $s =~ s/>/&gt;/g;
    return $s;
}

sub rtc_contact_xml {
    my ($tag, $qso) = @_;
    my $id  = rtc_qso_id($qso);
    my $cbr = rtc_xml_escape(rtc_cabrillo_string($qso));
    # date is already YYYY-MM-DD; utc is HHMM — build HH:MM:00
    my $ts = sprintf('%s %s:%s:00',
        $qso->{'date'},
        substr($qso->{'utc'}, 0, 2), substr($qso->{'utc'}, 2, 2));
    return "  <$tag>\n    <ID>$id</ID>\n    <CabrilloString>$cbr</CabrilloString>\n    <timestamp>$ts</timestamp>\n  </$tag>\n";
}

sub rtc_os_mode {
    my ($m) = @_;
    return 'PH' if $m eq 'SSB';
    return $m;   # CW, MIXED, RTTY, etc. pass through
}

sub rtc_count_mults {
    my ($val) = @_;
    return 0 unless defined $val;
    my $s = "$val";
    # Plain integer (no mults appended yet)
    return int($val) if $s =~ /^\d+$/;
    # yfktest stores mults as a space-separated string, with the initial integer
    # value (0) stringified as the first token when the first mult is appended.
    # Count non-empty tokens, skipping that leading "0".
    my @items = grep { /\S/ && $_ ne '0' } split(/\s+/, $s);
    return scalar @items;
}

sub rtc_breakdown_xml {
    # Spec uses bare numbers ("20", "40") not band suffixed with M
    my @band_order = qw(160 80 60 40 30 20 17 15 12 10 6 2);
    my $mode = rtc_os_mode($main::modes // 'CW');

    my ($total_q, $total_pts, $total_m1, $total_m2) = (0, 0, 0, 0);
    my $xml = "    <breakdown>\n";

    for my $b (@band_order) {
        my $q = $main::s_qsos{$b} // 0;
        next unless $q > 0;
        my $pts = $main::s_qsopts{$b} // 0;
        my $m1  = rtc_count_mults($main::s_mult1{$b});
        my $m2  = rtc_count_mults($main::s_mult2{$b});
        $xml .= qq{      <qso band="$b" mode="$mode">$q</qso>\n};
        $xml .= qq{      <mult band="$b" mode="$mode" type="$rtc_mult1type">$m1</mult>\n} if $rtc_mult1type;
        $xml .= qq{      <mult band="$b" mode="$mode" type="$rtc_mult2type">$m2</mult>\n} if $rtc_mult2type;
        $xml .= qq{      <point band="$b" mode="$mode">$pts</point>\n};
        $total_q   += $q;
        $total_pts += $pts;
        $total_m1  += $m1;
        $total_m2  += $m2;
    }

    # yfktest accumulates the running mult total in the 'All' key, not per-band
    my $grand_m1 = rtc_count_mults($main::s_mult1{'All'}) || $total_m1;
    my $grand_m2 = rtc_count_mults($main::s_mult2{'All'}) || $total_m2;
    $xml .= qq{      <qso band="total" mode="ALL">$total_q</qso>\n};
    $xml .= qq{      <mult band="total" mode="ALL" type="$rtc_mult1type">$grand_m1</mult>\n} if $rtc_mult1type;
    $xml .= qq{      <mult band="total" mode="ALL" type="$rtc_mult2type">$grand_m2</mult>\n} if $rtc_mult2type;
    $xml .= qq{      <point band="total" mode="ALL">$total_pts</point>\n};
    $xml .= "    </breakdown>\n";
    return $xml;
}

sub rtc_build_xml {
    my $qth = '';
    $qth .= "      <dxcccountry>$rtc_dxcccountry</dxcccountry>\n" if $rtc_dxcccountry;
    $qth .= "      <cqzone>$rtc_cqzone</cqzone>\n"                 if $rtc_cqzone;
    $qth .= "      <iaruzone>$rtc_iaruzone</iaruzone>\n"           if $rtc_iaruzone;
    $qth .= "      <arrlsection>$rtc_arrlsection</arrlsection>\n"  if $rtc_arrlsection;
    $qth .= "      <stproth>$rtc_stproth</stproth>\n"              if $rtc_stproth;
    $qth .= "      <grid6>$rtc_grid6</grid6>\n"                    if $rtc_grid6;

    my $call      = $main::mycall   // '';
    my $operator  = $main::ops      || $call;
    my $score     = $main::s_sum    // 0;
    my $breakdown = rtc_breakdown_xml();

    # <class> attributes from contest setup — map yfktest values to OS spec values
    my $cl_power  = $main::power       // 'HIGH';
    my $cl_asst   = $main::assisted    // 'NON-ASSISTED';
    my $cl_tx     = $main::transmitter // 'ONE';
    my $cl_ops    = $main::operator    // 'SINGLE-OP';
    my $cl_bands  = $main::bands       // 'ALL';
    my $cl_mode   = rtc_os_mode($main::modes // 'CW');

    my @t = gmtime(time);
    my $ts = sprintf('%04d-%02d-%02d %02d:%02d:%02d',
        $t[5]+1900, $t[4]+1, $t[3], $t[2], $t[1], $t[0]);

    my $xml = qq{<?xml version="1.0"?>\n<rtc>\n  <dynamicresults>\n};
    $xml .= qq{    <contest>$rtc_contest</contest>\n};
    $xml .= qq{    <call>$call</call>\n};
    $xml .= qq{    <ops>$operator</ops>\n};
    $xml .= qq{    <soft>YFKtest</soft>\n};
    $xml .= qq{    <version>$main::version</version>\n};
    $xml .= qq{    <class power="$cl_power" assisted="$cl_asst" transmitter="$cl_tx" ops="$cl_ops" bands="$cl_bands" mode="$cl_mode" overlay="N/A"></class>\n};
    $xml .= "    <qth>\n$qth    </qth>\n";
    $xml .= $breakdown;
    $xml .= qq{    <score>$score</score>\n};
    $xml .= qq{    <timestamp>$ts</timestamp>\n};
    $xml .= "  </dynamicresults>\n";
    # Spec 3.0: <contactinfo> is used for both new and edited QSOs
    $xml .= rtc_contact_xml('contactinfo', $_) for @rtc_pending_new;
    $xml .= rtc_contact_xml('contactinfo', $_) for @rtc_pending_replace;
    $xml .= "  <contactdelete>\n    <ID>$_</ID>\n  </contactdelete>\n" for @rtc_pending_delete;
    # <deletelog> must appear when a full resync is required (after ResyncLog response)
    if ($rtc_pending_deletelog) {
        $xml .= "  <deletelog>\n    <contest>$rtc_contest</contest>\n  </deletelog>\n";
        $rtc_pending_deletelog = 0;
    }
    $xml .= "</rtc>\n";
    return $xml;
}

sub rtc_post {
    return if $rtc_pipe_pid;
    return unless $rtc_callsign && $rtc_password;

    my $xml    = rtc_build_xml();
    my $tmpxml = "/tmp/yfk_rtc_$$.xml";

    open my $wfh, '>', $tmpxml or return;
    print $wfh $xml;
    close $wfh;

    rtc_log("POST $rtc_url");
    rtc_log("--- BEGIN XML ---\n$xml--- END XML ---");

    # open('-|') forks; child sets up stdin/stderr then execs curl.
    # Curl's stdout (the JSON response) is read by the parent via $pipe_fh.
    my $pipe_fh;
    my $pid = open($pipe_fh, '-|');
    unless (defined $pid) {
        unlink $tmpxml;
        return;
    }

    if ($pid == 0) {
        # Child: isolate from terminal before exec
        open STDIN,  '<', '/dev/null' or POSIX::_exit(1);
        open STDERR, '>', '/dev/null' or POSIX::_exit(1);
        exec('curl', '-s', '--max-time', '10',
             '-L',                              # follow HTTP→HTTPS redirects
             '--compressed',                   # Accept-Encoding: gzip, deflate (per spec)
             '-X', 'POST',
             '-H', 'Content-Type: application/xml',
             '-H', "User-Agent: YFKtest/$main::version",
             '-u', "$rtc_callsign:$rtc_password",
             '--data-binary', "\@$tmpxml",
             $rtc_url);
        POSIX::_exit(1);
    }

    # Parent: make pipe non-blocking so reads in rtc_tick never stall
    my $flags = fcntl($pipe_fh, F_GETFL, 0);
    fcntl($pipe_fh, F_SETFL, $flags | O_NONBLOCK) if defined $flags;

    $rtc_pipe_fh  = $pipe_fh;
    $rtc_pipe_pid = $pid;
    $rtc_xml_file = $tmpxml;
    $rtc_response = '';
}

sub rtc_check_result {
    return unless $rtc_pipe_pid;

    my $buf = '';
    my $ret = sysread($rtc_pipe_fh, $buf, 4096);

    if (!defined $ret) {
        return if $! == EAGAIN;   # curl still running — check again next tick
        # Unexpected read error: clean up and move on
        rtc_cleanup_pipe();
        return;
    }

    if ($ret > 0) {
        $rtc_response .= $buf;
        return;   # accumulate more
    }

    # EOF: curl is done
    my $response = $rtc_response;
    rtc_cleanup_pipe();
    rtc_process_response($response);
}

sub rtc_cleanup_pipe {
    close $rtc_pipe_fh if $rtc_pipe_fh;
    waitpid($rtc_pipe_pid, 0) if $rtc_pipe_pid;
    unlink $rtc_xml_file     if $rtc_xml_file;
    $rtc_pipe_fh  = undef;
    $rtc_pipe_pid = 0;
    $rtc_xml_file = '';
    $rtc_response = '';
}

sub rtc_process_response {
    my ($response) = @_;
    rtc_log("RESPONSE: " . ($response ne '' ? $response : '(empty)'));

    if ($response =~ /"Status"\s*:\s*"(?:OK|CFM)"/) {
        @rtc_pending_new = @rtc_pending_replace = @rtc_pending_delete = ();
        if ($response =~ /"Description"\s*:\s*"([^"]+)"/) {
            $rtc_status = "WARN:$1";
        } else {
            $rtc_status = 'OK';
        }
    } elsif ($response =~ /"Status"\s*:\s*"ResyncLog"/) {
        rtc_resync_log();
        $rtc_status = 'RESYNC';
    } elsif ($response =~ /"Status"\s*:\s*"Error"/) {
        my ($desc) = $response =~ /"Description"\s*:\s*"([^"]+)"/;
        $rtc_status = 'ERR:' . ($desc // '?');
    } elsif ($response eq '') {
        $rtc_status = 'no resp';
    } else {
        $rtc_status = 'bad resp';
    }

    $rtc_status_expire = time + 8;
    rtc_display_status();
}

sub rtc_resync_log {
    # Spec 3.0 §2.5: on ResyncLog, send <deletelog> then re-upload all QSOs
    @rtc_pending_new = @rtc_pending_replace = @rtc_pending_delete = ();
    $rtc_pending_deletelog = 1;
    for my $qso (@main::qsos) {
        next if ($qso->{'call'} // '') =~ /^DEL/;
        my %q = %$qso;
        $q{'exc1s'} = $main::exc1s // '';
        $q{'exc2s'} = $main::exc2s // '';
        $q{'exc3s'} = $main::exc3s // '';
        push @rtc_pending_new, \%q;
    }
}

sub rtc_display_status {
    return unless defined $main::wmain;
    my $label = $rtc_status ne '' ? sprintf("%-10s", "RTC:$rtc_status") : ' ' x 10;
    addstr($main::wmain, 0, 70, substr($label, 0, 10));
    refresh($main::wmain);
}

sub rtc_tick {
    return unless $rtc_enabled;

    rtc_check_result();

    if ($rtc_status_expire && time > $rtc_status_expire) {
        $rtc_status        = '';
        $rtc_status_expire = 0;
        rtc_display_status();
    }

    my $now = time;
    if (($now - $rtc_last_post >= $rtc_post_interval) && !$rtc_pipe_pid) {
        $rtc_last_post = $now;
        rtc_post();
    }
}

sub rtc_queue_new_qso {
    my ($qso) = @_;
    return unless $rtc_enabled;
    my %q = %$qso;
    $q{'exc1s'} = $main::exc1s // '';
    $q{'exc2s'} = $main::exc2s // '';
    $q{'exc3s'} = $main::exc3s // '';
    push @rtc_pending_new, \%q;
}

sub rtc_queue_replace_qso {
    my ($qso) = @_;
    return unless $rtc_enabled;
    my $id = rtc_qso_id($qso);
    my %q  = %$qso;
    $q{'exc1s'} = $main::exc1s // '';
    $q{'exc2s'} = $main::exc2s // '';
    $q{'exc3s'} = $main::exc3s // '';
    @rtc_pending_new     = grep { rtc_qso_id($_) ne $id } @rtc_pending_new;
    @rtc_pending_replace = grep { rtc_qso_id($_) ne $id } @rtc_pending_replace;
    push @rtc_pending_replace, \%q;
}

sub rtc_queue_delete_qso {
    my ($qso) = @_;
    return unless $rtc_enabled;
    my $id = rtc_qso_id($qso);
    @rtc_pending_new     = grep { rtc_qso_id($_) ne $id } @rtc_pending_new;
    @rtc_pending_replace = grep { rtc_qso_id($_) ne $id } @rtc_pending_replace;
    push @rtc_pending_delete, $id unless grep { $_ eq $id } @rtc_pending_delete;
}

rtc_read_config();

return 1;

# Local Variables:
# tab-width:4
# End:

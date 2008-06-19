#!/usr/bin/perl 

use strict;
  use warnings;
  use LWP 5.64;


  my $qsos = $ARGV[0];
  my $score = $ARGV[1];
  my $hhmm = $ARGV[2];

  my $browser = LWP::UserAgent->new;
  
  my $url = 'http://www.getscores.org/postscore.aspx';
  my $response = $browser->post( $url,
    [ 'xml' =>  '<?xml version="1.0" ?>
  <!DOCTYPE dynamicresults SYSTEM "http://www.hornucopia.com/dynamicresults.dtd">
 <dynamicresults>
  <contest>CQ-WW-SSB</contest>
  <call>DM7A</call>
  <ops>DJ1YFK</ops>
  <class power="HIGH" ops="SINGLE-OP-ASSISTED" bands="ALL" mode="SSB" overlay="N/A" />
  <club>WWYC - IRC</club>
 <qth>
  <dxcccountry>DL</dxcccountry>
  <cqzone>14</cqzone>
  <iaruzone>28</iaruzone>
  <arrlsection></arrlsection>
  <stprvoth></stprvoth>
  <grid6>JO61ua</grid6>
  </qth>
 <breakdown>
  <qso band="160">0</qso>
  <mult band="160" type="country">0</mult>
  <mult band="160" type="zone">0</mult>
  <qso band="80">0</qso>
  <mult band="80" type="country">0</mult>
  <mult band="80" type="zone">0</mult>
  <qso band="40">0</qso>
  <mult band="40" type="country">0</mult>
  <mult band="40" type="zone">0</mult>
  <qso band="20">0</qso>
  <mult band="20" type="country">0</mult>
  <mult band="20" type="zone">0</mult>
  <qso band="15">0</qso>
  <mult band="15" type="country">0</mult>
  <mult band="15" type="zone">0</mult>
  <qso band="10">0</qso>
  <mult band="10" type="country">0</mult>
  <mult band="10" type="zone">0</mult>
  <qso band="total">'.$qsos.'</qso>
  <mult band="total" type="country">0</mult>
  <mult band="total" type="zone">0</mult>
  </breakdown>
  <score>'.$score.'</score>
  <timestamp>2007-10-27 '.$hhmm.':00</timestamp>
  </dynamicresults>'
    ]
  );
  die "$url error: ", $response->status_line
   unless $response->is_success;
  die "Weird content type at $url -- ", $response->content_type
   unless $response->content_type eq 'text/html';

print $response->content;


package Blosxom::Header::Util;
use strict;
use warnings;
use Exporter 'import';
use HTTP::Date ();
use CGI::Util;

our @EXPORT_OK = qw( str2time time2str expires );

my %str2time;
sub str2time { $str2time{ $_[0] } ||= HTTP::Date::str2time( $_[0] ) }

my %time2str;
sub time2str { $time2str{ $_[0] } ||= HTTP::Date::time2str( $_[0] ) }

my %expires;
sub expires { $expires{ $_[0] } ||= CGI::Util::expires( $_[0] ) }

1;

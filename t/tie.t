use strict;
use Blosxom::Header;
use Data::Dumper;
use Test::More;

{
    package blosxom;
    our $header = { -type => 'text/html' };
}

{
    tie my %header, 'Blosxom::Header';
    is $header{Content_Type}, 'text/html', 'get';
    ok exists $header{Content_Type}, 'exists';
    $header{Status} = '304 Not Modified';
    is $blosxom::header->{-status}, '304 Not Modified', 'set';
    is_deeply [ @header{'Content_Type', 'Status'} ],
              [ 'text/html', '304 Not Modified' ], 'slice';
    is_deeply [ keys %header ], [ '-type', '-status' ], 'keys';
    is delete $header{Status}, '304 Not Modified', 'delete';
    is_deeply $blosxom::header, { -type => 'text/html' };
}

done_testing;

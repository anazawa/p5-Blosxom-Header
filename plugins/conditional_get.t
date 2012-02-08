use strict;
use FindBin;
use Test::More;

{
    package blosxom;
    our $static_entries = 0;
    our $header = {};
    our $output;
}

my $plugin = 'conditional_get';

require_ok "$FindBin::Bin/$plugin";
can_ok $plugin, qw/start last/;
ok $plugin->start();

my $tests_ref = do join(q{}, <DATA>);
for my $test (@$tests_ref) {
    # initial configuration
    %$blosxom::header = %{ $test->{header} };
    $blosxom::output  = $test->{output};
    local %ENV        = %{ $test->{env} };

    $plugin->last();

    is_deeply $blosxom::header, $test->{expected}{header};
    is $blosxom::output, $test->{expected}{output};
}

done_testing;

__DATA__
[
    {
        header  => { '-type' => 'text/html' },
        env      => { REQUEST_METHOD => 'GET' },
        output   => 'abcdj',
        expected => {
            header => { '-type' => 'text/html' },
            output => 'abcdj',
        }
    },
    {
        header => {
            '-type' => 'text/html',
            '-etag' => 'Foo', 
        },
        env => {
            REQUEST_METHOD     => 'GET',
            HTTP_IF_NONE_MATCH => 'Foo',
        },
        output => 'abcdj',
        expected => {
            header => {
                '-type'  => q{},
                '-etag'  => 'Foo',
                'Status' => '304 Not Modified',
            },
            output => q{},
        }
    },
    {
        header => {
            '-type'          => 'text/html',
            '-last-modified' => 'Wed, 23 Sep 2009 13:36:33 GMT',
        },
        env => {
            REQUEST_METHOD         => 'GET',
            HTTP_IF_MODIFIED_SINCE => 'Wed, 23 Sep 2009 13:36:33 GMT',
        },
        output => 'abcdj',
        expected => {
            header => {
                '-type'  => q{},
                '-last-modified' => 'Wed, 23 Sep 2009 13:36:33 GMT',
                'Status'        => '304 Not Modified',
            },
            output => q{},
        }
    },
    {
        header => {
            '-type'          => 'text/html',
            '-last-modified' => 'Wed, 23 Sep 2009 13:36:33 GMT',
        },
        env => {
            REQUEST_METHOD         => 'GET',
            HTTP_IF_MODIFIED_SINCE => 'Wed, 23 Sep 2009 13:36:32 GMT',
        },
        output => 'abcdj',
        expected => {
            header => {
                 '-type'          => 'text/html',
                 '-last-modified' => 'Wed, 23 Sep 2009 13:36:33 GMT',
            },
            output => 'abcdj',
        }
    },
    {
        header => {
            '-type'          => 'text/html',
            '-last-modified' => 'Wed, 23 Sep 2009 13:36:33 GMT'
        },
        env => {
            'REQUEST_METHOD' => 'GET',
            'HTTP_IF_MODIFIED_SINCE'
                => 'Wed, 23 Sep 2009 13:36:33 GMT; length=2',
        },
        output => 'abcdj',
        expected => {
            header => {
                '-type'  => q{},
                '-last-modified' => 'Wed, 23 Sep 2009 13:36:33 GMT',
                'Status'        => '304 Not Modified'
            },
            output => q{},
        }
    },
    {
        header => {
            '-type' => 'text/html',
            '-etag' => 'Foo', 
        },
        env => {
            REQUEST_METHOD     => 'POST',
            HTTP_IF_NONE_MATCH => 'Foo',
        },
        output => 'abcdj',
        expected => {
            header => {
                '-type' => 'text/html',
                '-etag' => 'Foo',
            },
            output => 'abcdj',
        }
    },
];
__END__

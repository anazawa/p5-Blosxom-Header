use inc::Module::Install;

name 'Blosxom-Headers';
all_from 'lib/Blosxom/Headers.pm';

requires 'HTTP::Status';
test_requires 'Test::More';

WriteAll;


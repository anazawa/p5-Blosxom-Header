use inc::Module::Install;

name 'Blosxom-Header';
all_from 'lib/Blosxom/Header.pm';

requires 'Carp';
requires 'Exporter';
requires 'Scalar::Util';
test_requires 'Test::More';
test_requires 'Test::Warn';

WriteAll;

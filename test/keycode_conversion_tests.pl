use warnings;
use strict;
use FindBin;
use lib "$FindBin::Bin/../";
require 'keycode_conversion.pl';
use Test::More;

is (&alphanumeric_to_keycode('.'), 49, 'Test period converts correcty');
is (&alphanumeric_to_keycode(','), 41, 'Test comma converts correcty');
is (&alphanumeric_to_keycode('a'), '1c', 'Test a converts correcty');
is (&alphanumeric_to_keycode('A'), '121cf012', 'Test A converts correcty');
is (&alphanumeric_to_keycode('abc'), '1c3221', 'Test abc converts correcty');
is (&alphanumeric_to_keycode('abC.'), '1c321221f01249', 'Test abC. converts correcty');
is (&alphanumeric_to_keycode('k 1 b c'), '42163221', 'Test alphanumeric string with spaces converts correcty');

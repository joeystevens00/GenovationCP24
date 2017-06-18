use Clipboard;
local $/=undef;
open FILE, 'C:\Users\jstevens\macro_scripts\comment_block.txt' or die "couldn't open file: $!";
my $string = <FILE>;
close FILE;

Clipboard->copy($string);






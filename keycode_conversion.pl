use strict; 
use warnings;

################################################################################
################################################################################
##
## Helpers
##
################################################################################
################################################################################
sub Level1OrLevel2
{
    my ($option) = @_;
    foreach (keys %{$option})
    {
        return $_ if($option->{$_} eq 'true');
    }
}




################################################################################
################################################################################
##
## Keycode translation
##
################################################################################
################################################################################

our %keycodes = (
    a => '1c',
    b => '32',
    c => '21',
    d => '23',
    e => '24',
    f => '2b',
    g => '34',
    h => '33',
    i => '43',
    j => '3b',
    k => '42',
    l => '4b',
    m => '3a',
    n => '31',
    o => '44',
    p => '4d',
    q => '15',
    r => '2d',
    s => '1b',
    t => '2c',
    u => '3c',
    v => '2a',
    w => '1d',
    x => '22',
    y => '35',
    z => '1a',
    0 => '45',
    1 => '16',
    2 => '1e',
    3 => '26',
    4 => '25',
    5 => '2e',
    6 => '36',
    7 => '3d',
    8 => '3e',
    9 => '46'
);

sub alphanumeric_to_keycode
{
    my ($option) = @_;
    my $return_str = "";
    # For each char in the string
    foreach (split('', $option))
    {
        # If we have the char  defined in the translation map  
        if (defined $keycodes{$_}) 
        {
            $return_str .= $keycodes{$_};
        }

        # If the char is an uppercase letter
        elsif($_ =~ /[A-Z]/)
        {
            # Convert the char to lowcase and wrap in shift down / shift up 
            $return_str .= '12' . $keycodes{lc $_} . 'f012';
        }

        # If .
        elsif($_ eq '.')
        {
            $return_str .= '49';
        }

        # If ,
        elsif($_ eq ',')
        {
            $return_str .= '41';
        }

        else 
        {
            if (not $_ =~ /^\s*$/)
            {
                print "$_ is not a known character. Use \@Rawcodes with the appropriate keycode. ";
            }
        }
    }
    return $return_str;
}
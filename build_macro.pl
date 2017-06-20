#!/usr/bin/perl -w
use strict;
use warnings;
use Data::Dumper;

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
    foreach (split('', $option))
    {
        if (defined $keycodes{$_}) 
        {
        	$return_str .= $keycodes{$_};
        }
    }
    return $return_str;
}

################################################################################
################################################################################
##
## Process keys and generate CKD
##
################################################################################
################################################################################


my $macro_set = $ARGV[0];
$macro_set .= '_keys';

chdir($macro_set) or die "$!";
my @files = <*>;
my @generated_ckd;


# Global params. Don't care to support customization for now
push @generated_ckd, '[GLOBAL_PARAMETERS]',
	'Model_Number=CP24', 'Number_Of_Keys=24',
	'Key_Roll_Over=2', 'LED_Function=1',
	'LED2_Function=2', 'LED3_Function=4',
	'Character_Pacing=1';




# Iterate through all of the keyfiles and generate the CKD code
foreach my $file (@files) 
{
	open my $info, $file or die "Could not open $file: $!";

	push @generated_ckd, '[' . uc $file . "]";
	push @generated_ckd, 'L1_MacroMode=0';
	push @generated_ckd, 'L2_MacroMode=0';
	my ($level1, $level2, $level1_code, $level2_code);
	my ($level1autorepeat, $level2autorepeat, $rawcodes) = (0) x 3;
	while(my $line = <$info>)
	{


		$_=$line;
		chomp;
		
		
		if ($line =~ /^ *$/ or $line =~ /^$/ )
		{
			next
		}
		
		
		# If we're beginning the Level1 block for the key
		# %%Level1
		if ( m/^%%Level1/ )
		{
			$level1='true';
			$level2='false';

		}

		# If we're beginning the Level2 block for the key
		# %%Level2	
		if ( m/^%%Level2/ )
		{
			$level1='false';
			$level2='true';
		}
	
		my $level = Level1OrLevel2(
			{
				'Level_1' => $level1,
				'Level_2' => $level2
			}
		);
		
		
		# If we're at the end of the Level1 or Level2 block
		# %%Level1End
		# %%Level2End
		if ( m/^%%Level1End/i || m/^%%Level2End/i )
		{
			my $levelend = $_;
			
			# If the key can be auto repeated
			# %%L1_AutoRepeat
			if (m/%%L1_AutoRepeat/i)
			{
				$level1autorepeat = 1;	
			}
		
			# If the key can be auto repeated
			# %%L2_AutoRepeat
			if (m/%%L2_AutoRepeat/i)
			{
				$level2autorepeat = 1;		
			}
			
			
			# If autorepeat is on
			if ($levelend =~ /Level1/i && $level1autorepeat == 1)
			{
				push @generated_ckd, 'L1_AutoRepeat=1';
			}
			if ($levelend =~ /Level2/i && $level2autorepeat == 1)
			{
				push @generated_ckd, 'L2_AutoRepeat=1';
			}			
			if ($levelend =~ /Level1/i)
			{
				$level1_code =~ s/\R//g;
				push @generated_ckd, 'Level_1_Codes=' . $level1_code;
			}
			if ($levelend =~ /Level2/i)
			{
				$level2_code =~ s/\R//g;
				push @generated_ckd, 'Level_2_Codes=' . $level2_code; 
			}
		}

	
		# If the line contains the Name of the key codes
		if (m/^%Name/i)
		{
			chomp;
			my @name = split /=/, $line;
			$name[1] =~ s/\R//g;
	
			push @generated_ckd,  $level . "_Name=" . $name[1];
		}
		

		# If the line is not a comment or other special syntax then add it to the codes
		if (not $line =~ /^(#.*$|%.*$|@.*$)/)
		{
			# If raw codes are off
			if ($rawcodes == 0)
			{
				$level1_code .= &alphanumeric_to_keycode($line) if $level1 eq 'true';
				$level2_code .= &alphanumeric_to_keycode($line) if $level2 eq 'true';
			}
			else
			{
				$level1_code .= $line if $level1 eq 'true';
				$level2_code .= $line if $level2 eq 'true';			
			}
		}
		
		# If rawcodes is being turned on (do not translate the text to keycodes)
		if (m/^\@Rawcodes/i)
		{
			
			$rawcodes = 1;
		}
		
		if (m/^\@RawcodesEnd/i)
		{
			$rawcodes = 0;
		}

		
	}

	close $info;
}


## Write the CKD #####################################################
#
# 
#
#
chdir('..') or die "$!";
# Write out the generated file
open (my $ckd_fh, '>', $macro_set . "_generated.ckd");
	foreach my $line (@generated_ckd)
	{
			print $ckd_fh $line . "\n";
	}
close $ckd_fh;
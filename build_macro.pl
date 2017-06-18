#!/usr/bin/perl -w
use strict;
use warnings;
use Data::Dumper;

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
	my ($level1, $level2, $level1_code, $level2_code);
	push @generated_ckd, '[' . uc $file . "]";
	push @generated_ckd, 'L1_AutoRepeat=0';
	push @generated_ckd, 'L2_AutoRepeat=0';
	push @generated_ckd, 'L1_MacroMode=0';
	push @generated_ckd, 'L2_MacroMode=0';
	while(my $line = <$info>)
	{
		$_=$line;
		if ( m/^%%Level1/ )
		{
			$level1='true';
			$level2='false';

		}
		if ( m/^%%Level2/ )
		{
			$level1='false';
			$level2='true';
		}
		
		if ( m/^%%Level1End/ )
		{
			$level1_code =~ s/\R//g;
			chomp;
			push @generated_ckd, 'Level_1_Codes=' . $level1_code; 
		}
	
		if ( m/^%%Level2End/ )
		{
			$level2_code =~ s/\R//g;
			chomp;
			push @generated_ckd, 'Level_2_Codes=' . $level2_code; 
		}

		if ($level1 eq 'true')
		{
			if (m/^%Name/)
			{
				chomp;
				my @name = split /=/, $line;
				$name[1] =~ s/\R//g;
				push @generated_ckd,  'Level_1_Name=' . $name[1];
			}

		if (not $line =~ /^(#.*$|%.*$)/)
			{
				chomp;
				$level1_code .= $line;
			}
		}
		if ($level2 eq 'true')
		{
			if (m/^%Name/)
			{
				chomp;
				my @name = split /=/, $line;
				$name[1] =~ s/\R//g;
				push @generated_ckd,  'Level_2_Name=' . $name[1];
			}

			if (not $line =~ /^(#|%)/)
			{
				chomp;
				$level2_code .= $line;
			}
		}
	}

	close $info;
}

chdir('..') or die "$!";
# Write out the generated file
open (my $ckd_fh, '>', $macro_set . "_generated.ckd");
	foreach my $line (@generated_ckd)
	{
			print $ckd_fh $line . "\n";
	}
close $ckd_fh;
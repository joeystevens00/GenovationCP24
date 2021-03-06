#!/usr/bin/perl -w
use strict;
use warnings;
use Data::Dumper;
use File::Path;
use File::Spec;
use Cwd;

require 'keycode_conversion.pl';


################################################################################
################################################################################
##
## Process keys and generate CKD
##
################################################################################
################################################################################


my $macro_set = $ARGV[0];
$macro_set .= '_keys';
my $keys_directory = $macro_set . '/keys';
chdir($keys_directory) or die "$!";
my @files = <*>;
my @generated_ckd;


# Iterate through all of the keyfiles and generate the CKD code
foreach my $file (@files) 
{
	open my $info, $file or die "Could not open $file: $!";

	if ($file eq 'global')
	{
		push @generated_ckd, <$info>;
		next;
	}

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
			
			# If the key is a level shift
			if (m/%%LShift/i)
			{
				push @generated_ckd, 'KeyType=1';
				
			}
			
			# if the key is a level toggle
			if (m/%%LToggle/i)
			{
				push @generated_ckd, 'KeyType=0';
				
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
chdir('..') or die "$!";

# Detect if the generated directory exists. If not make it.
my $generated_directory = $macro_set . '/out';
my $outfile = $generated_directory .  '/' . $macro_set . "_generated.ckd";
my $pwd = cwd();
if (! -d $generated_directory)
{
	print  "\n" . $pwd . '/' . $generated_directory . "\n";
	mkdir($pwd . '/' . $generated_directory) or die "$!";
}

# Write out the generated file
open (my $ckd_fh, '>',  $outfile);
	foreach my $line (@generated_ckd)
	{
			print $ckd_fh $line . "\n";
	}
close $ckd_fh;

print "Successfully generated file: $pwd/$outfile";
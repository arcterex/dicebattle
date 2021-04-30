#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use Getopt::Long;

# Dice Battle 1.0
# Takes two command line arguments, --skill or -s and --penalty or -p, this is 
# the number of skill dice and penalty dice.
# If no arguments, defaults to $num_skill and $num_penalty set in Globals

# step 1: roll X number of 6-sided dice (iterate through 1 to 5) (SkillDice)
# step 2: roll Y number of 6-sided dice (iterate through 0 to 5) (PenaltyDice)
# step 3: for each Y, if there is an X then cancel it out
#              example: if you rolled 3 Skill Dice of 5,3,2 and 3 PenaltyDice 
#              of 5,2,1, then the 5 and 2 would cancel, leaving just a 3 for the 
#              SkillDice
# step 4: take the highest number that are still on the SkillDice (note that it 
# can be 0 if all of the SkillDice were canceled by PenaltyDice).  In the 
# example above, "3" would be the highest number
# step 5: Iterate through $somehighnumber for each combination of SkillDice and 
# PenaltyDice (1-5 SkillDice * 0-5 PenaltyDice = 30 combinations) and record 
# number of hits for each number so that I can do stats.

# Globals
my $dice_sides = 6;
my $debug = 0;
my $help = 0;

# sort resulting stats by dice number instead of number of results
my $sort_by_number = 0;

# default number of dice to roll in the dice battle if not set from command
my $num_skill   = 20;
my $num_penalty = 20;

# ---------------------------------- code below -----------------------

# Return a random number from a six sided dice
sub roll_dice() {
   my $roll = rand(6);
   # Increment by one so it's 1-6 not 0-5
   $roll++;
   return int $roll;
}

# Roll the dice a certain number of times and return an array of the random results
sub roll_num_dice {
   my $num_dice = shift;
   print "Rolling $num_dice dice\n" if $debug;
   my @roll = ();
   foreach(1..$num_dice) {
      my $roll_number = roll_dice();
      push(@roll, $roll_number);
   }
   return @roll;
}

# take two arrays of random numbers and compare, eliminate, and return an array 
# with just the remaining values with the highest one at $array[0];
sub compare_rolls {
   my ($skill, $bad) = @_;

   my @skill = @$skill;
   my @bad   = @$bad;

   print "Skill\n" . Dumper \@skill if $debug;
   print "Penalty\n"   . Dumper \@bad if $debug;

   for ( my $i = 0; $i < @skill; $i++ ) {
      next if( ! defined $skill[$i] );

      for( my $j = 0; $j < @bad; $j++ ) {
         next if( ! defined $bad[$j] );
         
         if( $skill[$i] == $bad[$j] ) {
            $skill[$i] = undef;
            $bad[$j]   = undef;
            last;
         }
      }
   }

   @skill = grep defined, @skill;
   @skill = sort { $b <=> $a} @skill;

   print "\n----\nEnding array:\n" . Dumper \@skill if $debug;

   # special case = our array is 0 length because everything is eliminated
   if( !@skill ) {
      @skill = (0);
   }

   print "Highest number = $skill[0]\n" if $debug;
   
   return @skill;
}

# Base test case
#my @skill_roll_result   = roll_num_dice(15);
#my @penalty_roll_result = roll_num_dice(0);
#my @complete_roll = compare_rolls(\@skill_roll_result, \@penalty_roll_result);

# roll through each iteration of 1..$skill and 0..$penalty and record the results
sub dice_battle {
   my $total_iterations = 0;
   my ($skill, $penalty) = @_;
   my $results = {};

   # loop through 1..$skill
   for( my $i = 1; $i <= $skill; $i++ ) {
      for( my $j = 0; $j <= $penalty; $j++ ) {
         print "Skill = $i vs Pentalty = $j\n" if $debug;
         $total_iterations++;
         my @skill_result = roll_num_dice($i);
         my @penalty_result = roll_num_dice($j);
         my @roll_result = compare_rolls(\@skill_result, \@penalty_result);

         my $final_result = $roll_result[0];
         print "$i vs $j = $final_result\n" if $debug;
         $results->{$final_result} += 1;
      }
   }
   my %results_hash = %$results;

   print Dumper $results if $debug;
   print "Total iterations = $total_iterations\n";

   # sort the hash
   my %r2 = %results_hash;
   my @sorted_results = sort { $results_hash{$b} <=> $results_hash{$a} } keys %results_hash;

   if( $sort_by_number ) {
      foreach my $r (@sorted_results) {
         print "Battle result = $r - Happened " . $results_hash{$r} . " times\n";
      }
   } 
   else 
   {
      foreach my $key ( sort { $a <=> $b} keys %results_hash ) {
         print "Battle Result = $key - Happened " . $results->{$key} . " times\n";
      }
   }
}

# --------------- Main code -------------------
GetOptions( "skill=i"      => \$num_skill,
            "penalty=i"    => \$num_penalty,
            "debug"        => \$debug,
            "number_sort"  => \$sort_by_number,
            "help"         => \$help)
            or die("Error in command line arguments\n");

if( $help ) {
   print "Help:\n";
   print "Set number of skill and penalty dice from the command line with:\n\n";
   print " --skill, -s <number>     Skill dice to roll\n";
   print " --penalty, -p <number>   Penalty dice to roll\n";
   print " --number_sort            Sort result by number not dice number\n";
   print "\n";
   exit;
}

print <<"END"; 

▓█████▄  ██▓ ▄████▄  ▓█████     ▄▄▄▄    ▄▄▄     ▄▄▄█████▓▄▄▄█████▓ ██▓    ▓█████
▒██▀ ██▌▓██▒▒██▀ ▀█  ▓█   ▀    ▓█████▄ ▒████▄   ▓  ██▒ ▓▒▓  ██▒ ▓▒▓██▒    ▓█   ▀
░██   █▌▒██▒▒▓█    ▄ ▒███      ▒██▒ ▄██▒██  ▀█▄ ▒ ▓██░ ▒░▒ ▓██░ ▒░▒██░    ▒███
░▓█▄   ▌░██░▒▓▓▄ ▄██▒▒▓█  ▄    ▒██░█▀  ░██▄▄▄▄██░ ▓██▓ ░ ░ ▓██▓ ░ ▒██░    ▒▓█  ▄
░▒████▓ ░██░▒ ▓███▀ ░░▒████▒   ░▓█  ▀█▓ ▓█   ▓██▒ ▒██▒ ░   ▒██▒ ░ ░██████▒░▒████▒
 ▒▒▓  ▒ ░▓  ░ ░▒ ▒  ░░░ ▒░ ░   ░▒▓███▀▒ ▒▒   ▓▒█░ ▒ ░░     ▒ ░░   ░ ▒░▓  ░░░ ▒░ ░
 ░ ▒  ▒  ▒ ░  ░  ▒    ░ ░  ░   ▒░▒   ░   ▒   ▒▒ ░   ░        ░    ░ ░ ▒  ░ ░ ░  ░
 ░ ░  ░  ▒ ░░           ░       ░    ░   ░   ▒    ░        ░        ░ ░      ░
   ░     ░  ░ ░         ░  ░    ░            ░  ░                     ░  ░   ░  ░
 ░          ░                        ░

END

print "Doing battle!\n";
print "Skill dice:   $num_skill\n";
print "Penalty dice: $num_penalty\n";
print "\n..... FIGHT!.... \n\n";

dice_battle($num_skill, $num_penalty);

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
my $runs = 10;
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
   print "Rolling $num_dice dice... " if $debug;
   my @roll = ();
   foreach(1..$num_dice) {
      my $roll_number = roll_dice();
      print "$roll_number\n" if $debug;
      push(@roll, $roll_number);
   }
   return @roll;
}

# take two arrays of random numbers and compare, eliminate, and return 
# just an integer from 0-6 with the winning number in it
sub compare_rolls {
   my ($skill, $bad) = @_;

   my @skill = @$skill;
   my @bad   = @$bad;

   @skill = reverse sort @skill;
   @bad = reverse sort @bad;

   print "-> Skill\n" . Dumper \@skill if $debug;
   print "-> Penalty\n"   . Dumper \@bad if $debug;
   
   # First thing is shortcut a couple of things.
   # 1 - if the size of @bad is zero, then the top dice in @skill
   # automatically wins
   # 2 - if the max number in @skill is higher than the max number in @bad
   # it automatically wins

   if( ! @bad ) { 
      print "Shortcut! Zero size bad array, returning skill max\n" if $debug;
      return $skill[0]; 
   }

   if( $skill[0] > $bad[0] ) {
      print "Shortcut! Skill max > bad max, returning skill max\n" if $debug;
      return $skill[0];
   }
   
   # No shortcuts, iterate through the arrays
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
   
   #   return @skill;
   return $skill[0];
}

# roll through each iteration of 1..$skill and 0..$penalty and record the results
# Goal is to get the stats on each individual combination.  I'm going to store 
# these in a nested hash with the following format

# New way of doing it with N iterations of just the number given
# Store the stats as follows:
# ie: 1 vs 2 penalty dice
# $var->{"1,2"}->{1}->3    # in 1s vs 2p the number 1 came out, 2 times, 2, 1
#              ->{2}->1    # time, 3 7 times, etc.
#              ->{3}->7
#     ->{"2,2"}->{1}->0
#              ->{2}->4
#              ->{3}->2 etc

sub dice_battle {
   my $total_iterations = 0;
   my ($skill, $penalty) = @_;
   my $results = {};

   # Have to do this all $runs times
   for( 0..$runs ) {
      # loop through 1..$skill
      for( my $i = 1; $i <= $skill; $i++ ) {
         for( my $j = 0; $j <= $penalty; $j++ ) {
            print "Skill = $i vs Pentalty = $j\n" if $debug;
            $total_iterations++;
            my @skill_result = roll_num_dice($i);
            my @penalty_result = roll_num_dice($j);
            my $roll_result = compare_rolls(\@skill_result, \@penalty_result);

            print "$i vs $j = $roll_result\n" if $debug;
            # $results->{$final_result} += 1;
            my $key = "$i,$j";
            $results->{$key}->{$roll_result}++;
            print "Adding 1 to $key -> $roll_result\n" if $debug;
         }
      }
   }

   display_results($results, $skill, $penalty);
=pod
   my %results_hash = %$results;

   print Dumper $results if $debug;
   print "\n\nTotal iterations = $total_iterations\n\n";

   # sort the hash
   my %r2 = %results_hash;
   my @sorted_results = sort { $results_hash{$b} <=> $results_hash{$a} } keys %results_hash;

   # Sort results by the dice number or the result number
   if( ! $sort_by_number ) {
      # Sort by the dice
      foreach my $r (@sorted_results) {
         print "Battle result: Die $r - won " . $results_hash{$r} . " times\n";
      }
   } 
   else 
   {
      # Sort by the result (with -n)
      foreach my $key ( sort { $a <=> $b} keys %results_hash ) {
         print "Battle Result: Die $key - won " . $results->{$key} . " times\n";
      }
   }
=cut
}

sub display_results {
   my ($results, $skill, $penalty) = @_;

   print "Results of battle (sorted by ";
   print $sort_by_number ? "die" : "result";
   print "): \n";
   print Dumper $results if $debug;

   #   my @keys = keys %{ $results };
   
   # First iterate through each set of dice rolls, and create the keys and 
   # then display the results from each

   for( my $i = 1; $i <= $skill; $i++ ) {
      for( my $j = 0; $j <= $penalty; $j++ ) {
         print "Skill: $i Penalty: $j\n";
         print "---------------------\n";
         # now loop through the hash for this key
         my $key = "$i,$j";
         my $r = $results->{$key};

         if( $sort_by_number ) {
            print "Sorted by dice number\n" if $debug;
            print Dumper $r if $debug;
            foreach( sort keys %{ $r } ) {
               print "Die: $_ wins: $results->{$key}->{$_}\n";
            }
         } else {
            print "Sorted by result number\n" if $debug;
            print Dumper $r if $debug;
            foreach my $die( sort { $r->{$a} <=> $r->{$b} } keys %$r ) {
               print "Die: $die wins: $r->{$die}\n";
            }
            
         }
         print "\n";
      }
   }
}

# --------------- Main code -------------------
GetOptions( "skill=i"      => \$num_skill,
            "penalty=i"    => \$num_penalty,
            "debug"        => \$debug,
            "number_sort"  => \$sort_by_number,
            "runs=i"       => \$runs,
            "help"         => \$help)
            or die("Error in command line arguments\n");

if( $help ) {
   print "Help:\n";
   print "Set number of skill and penalty dice from the command line with:\n\n";
   print " --skill, -s <number>     Skill dice to roll\n";
   print " --penalty, -p <number>   Penalty dice to roll\n";
   print " --number_sort            Sort result by dice number not result number\n";
   print "\n";
   exit;
}

if( ! $debug ) {
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
   print "Skill dice  : $num_skill\n";
   print "Penalty dice: $num_penalty\n";
   print "Iterations  : $runs\n";
   print "\n..... FIGHT!.... \n\n";
}
if( $debug ) {
   print <<"END";
Runs:          $runs
Skill Dice:    $num_skill
Penalty Dice:  $num_penalty


END
}

dice_battle($num_skill, $num_penalty);

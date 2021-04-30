# Dice Battle 

A simple dice stats program for my buddy SP.

## Spec

1. Roll X number of 6-sided dice (iterate through 1 to 5) (SkillDice)
2. Roll Y number of 6-sided dice (iterate through 0 to 5) (PenaltyDice)
3. For each Y, if there is an X then cancel it out

> example: if you rolled 3 Skill Dice of 5,3,2 and 3 PenaltyDice 
> of 5,2,1, then the 5 and 2 would cancel, leaving just a 3 for the 
> SkillDice
4. Take the highest number that are still on the SkillDice (note that it 
can be 0 if all of the SkillDice were canceled by PenaltyDice).  In the 
example above, "3" would be the highest number
5. Iterate through $somehighnumber for each combination of SkillDice and 
PenaltyDice (1-5 SkillDice * 0-5 PenaltyDice = 30 combinations) and record 
number of hits for each number so that I can do stats.

## Usage
Download the .pl file, then make it executable:

```
$ chmod 755 ./dicestats.pl
```

Run the command with -h to get the help text.

```
Help:
Set number of skill and penalty dice from the command line with:

 --skill, -s <number>     Skill dice to roll
 --penalty, -p <number>   Penalty dice to roll
 --number_sort            Sort result by dice number not result number
 ```

## Results
When you run the program you'll get a result that looks something like this:

```
Skill dice:   10
Penalty dice: 10

Total iterations = 110

Battle result: Die 6 - won 40 times
Battle result: Die 5 - won 24 times
Battle result: Die 4 - won 14 times
Battle result: Die 0 - won 12 times
Battle result: Die 3 - won 10 times
Battle result: Die 2 - won 6 times
Battle result: Die 1 - won 4 times
```

This means that for the roles of 10 skill dice and 10 penalty dice, resulting
in 110 iterations, a 6 resulted in the winning dice 4r times, a 5 24 times, etc.

The 0 is the result of a skill dice rolled against no penalty dice.

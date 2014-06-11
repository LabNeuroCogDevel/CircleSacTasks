#!/usr/bin/env perl
use strict; use warnings;
use Data::Dumper;
use 5.14.0;

# example input "snd[.5]; mem {1L=1/2 [.5], 4L=1/2 [.5] }; CATCH=1/6; dly[1];"

my @seq    = ();
my %events = ();
while(<>) {
 my @F = split /;/;

 # read in event by event
 for (@F) {
   # skip if it doesnt look like a name and time
   next if ! /\w+.*\[/; 

   # DEAL WITH CATCH TRIALS
   next if /CATCH\s*=\s*[\d\.\/]+/;

   print "# $_\n";

   # get name, should be first bit of word characters
   /^\s*(?<name>\w+)/;
   my $name=$+{name};
   print "using $name\n";
   say STDERR "no name for event!" and exit unless $name;
   say STDERR "name $name already used!" and exit if exists($events{$name});
   push @seq, $name;

   # add timing to events
   # should be like [.5]
   # -- assume that mulitple matches will match manipulations
   my @timing=();
   while(/ \[   (?<timing> [\d \. \/]+  )  \]/xg){
    push @timing, $+{timing};
   }


   #####
   # look for any conditions/manipulations
   # like { name=occurance ... }
   my $condMatch=""; 
   $condMatch=$& if /{.+}/;
   my @cond=();
   # {1L=1/2 [.5], 4L=1/2 [.5] }
   while($condMatch=~m/ (?<cond> \w+ ) \s* = \s* (?<count>[\d\.\/]+)  /xg){
    push @cond, [ $name .":".$+{cond}, $+{count} ] ;
   }
   # default
   push @cond, [ $name, $timing[0] ] if($#cond<0);
   
   # build events hash
   # eventName =>  array of hashes with prefix, occurRatio, and duration
   if( ( $#cond<0 && $#timing==0) || ($#cond == $#timing) ) {
      $events{$name} = [ map { { event=>$name, name=>$cond[$_]->[0], occurRatio=>$cond[$_]->[0], duration=>$timing[$_] } } (0..$#cond)  ];
   } else {
     say STDERR "$name: have " , $#timing+1 , " times -- should be 1 or match # manipulations\n";
   }
 }



}

# seq like: 
#  (snd mem dly)
# events like:
#  ( snd => [ {event=>snd,name=>snd,    occurRatio=>1  , duration=>.5 ],
#    mem => [ {event=>mem,name=>mem.1L, occurRation=>.5, duration=>.5},
#             {event=>mem,name=>mem.4L, occurRation=>.5, duration=>.5}
#           ]
#  )          

## build tree/ all possible event sequences
# allseq will be array of trial arrays
# (
#   [ {seq} {memL1} {dly} ]
#   [ {seq} {memL1} {dly} ]
# )

my @allseq=([]);
for my $event (@seq) {
   my @prevseq=@allseq; # make a copy that isn't touched by adding all conditions of this event
   @allseq=();
   
   
   # for each condition of this event
   for my $condition (@{ $events{$event} }){
      
      my @newseq=@prevseq;
      # start with all the trial sequences that we had before
      # but add this condtion to each
      for my $i (0..$#newseq) {
        say "trlsq $i: adding ", $condition->{name}," to ", join("\t",map {$_->{name}} @{$newseq[$i]});
        push @{$newseq[$i]}, $condition;
        push @allseq, $newseq[$i];
      }

      # add this condition for each sequence that already exists
      # unless the previous trial sequence ended in a catch!

   }
   say "**", $#allseq+1, " trial seqs";
   say Dumper(@allseq);

   #say "# $event";
   #say Dumper($allseq[0]);
   #say Dumper($allseq[1]);
   #say "\n";
}

for my $trial (@allseq) {
 say join("\t",map {$_->{name}} @$trial);
}

#!/usr/bin/env perl
use strict; use warnings;
use 5.14.0; # use "say"
use List::Util qw(shuffle reduce sum);
my $VERBOSE=1;
use Data::Dumper;

# example input "snd[.5]; mem {1L=1/2 [.5], 4L=1/2 [.5] }; CATCH=1/6; dly[1];"

my @seq    = ();
my %events = ();
my $nCatch=0;
while(<>) {
 my @F = split /;/;

 # read in event by event
 for (@F) {
   # skip if it doesnt look like a name and time
   next if ! /(\w+.*\[)|(CATCH)/; 

   my $name;
   my @cond=();
   my @timing=();


   # DEAL WITH CATCH TRIALS
   if(/ CATCH \s*=\s* ( [\d\.\/]+ )/x){
     $nCatch++;
     my $occur=sprintf('%0.4f',$1);
     $name="CATCH".$nCatch;

     @cond=( [ $name, $occur ], ["NO".$name, 1-$occur] );
     @timing=(0, 0);

     $events{$name} = [ map { { event=>$name, name=>$cond[$_]->[0], occurRatio=>$cond[$_]->[1], duration=>$timing[$_] } } (0..$#cond)  ];
     push @seq, $name;
     next;
   }

   # get name, should be first bit of word characters
   /^\s*(?<name>\w+)/;
   $name=$+{name};
   say STDERR "no name for event!" and exit unless $name;
   say STDERR "name $name already used!" and exit if exists($events{$name});
   push @seq, $name;

   # add timing to events
   # should be like [.5]
   # -- assume that mulitple matches will match manipulations
   while(/ \[   (?<timing> [\d \. \/]+  )  \]/xg){
    push @timing, $+{timing};
   }


   #####
   # look for any conditions/manipulations
   # like { name=occurance ... }
   my $condMatch=""; 
   $condMatch=$& if /{.+}/;
   # {1L=1/2 [.5], 4L=1/2 [.5] }
   while($condMatch=~m/ (?<cond> \w+ ) \s* = \s* (?<count>[\d\.\/]+)  /xg){
    push @cond, [ $name .":".$+{cond}, $+{count} ] ;
   }
   # default
   push @cond, [ $name, 1 ] if($#cond<0);
   
   # build events hash
   # eventName =>  array of hashes with prefix, occurRatio, and duration
   if(  $#timing==0 || ($#cond == $#timing) ) {
      $events{$name} = [ map { { event=>$name, name=>$cond[$_]->[0], 
                                 occurRatio=>sprintf("%.04f",$cond[$_]->[1]), 
                                 duration=>sprintf("%.02f",$timing[$_]||$timing[0])      } 
                              } (0..$#cond)  ];
   } else {
     say STDERR "$name: have " , $#timing+1 , " times -- should be 1 or match # manipulations\n";
   }
 }



}

# seq like: 
#  (snd mem dly)
# events like:
#  ( snd => [ {event=>snd,name=>snd,    occurRatio=>1 , duration=>.5 ],
#    mem => [ {event=>mem,name=>mem.1L, occurRatio=>.5, duration=>.5},
#             {event=>mem,name=>mem.4L, occurRatio=>.5, duration=>.5}
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
   
   
   # add all catches here
   # done here because we dont want to add it for each condition
   for my $seq (@prevseq) {
     next if @$seq <= 0;
     push @allseq, $seq if @$seq>0 && @$seq[@$seq-1]->{name} =~ /^CATCH\d+$/; 
   }
   

   # for each condition of this event
   for my $condition (@{ $events{$event} }){
      
      # start with all the trial sequences that we had before
      # but add this condtion to each
      for my $i (0..$#prevseq) {
        my @newseq = @{$prevseq[$i]};
        
        # don't extend trials that end it catch
        next if $#newseq>0 && $newseq[$#newseq]->{name} =~ /^CATCH\d+$/; 

        push @newseq, $condition; 
        push @allseq, [@newseq ];
        #say "added $condition->{name}: ", join("\t", map {$_->{name} } @newseq );
      }
   }

}

# calculate occur ratio and total time for each trial sequence
# new data structure
#   ( {dur=> ##, freq=> ##, seq=> [ {name=>,event=>,occurRatio=>,duration=>}, {} , {}, ... ] }
#     {dur=> ##, freq=> ##, seq=> [ {name=>,event=>,occurRatio=>,duration=>}, {} , {}, ... ] }
#      ...
#   )
#
my @alltrials=();
for my $trialseq (@allseq) {
 my $freq = reduce {$a*$b} 1, map {$_->{occurRatio} } @$trialseq;
 my $time = reduce {$a+$b} 0, map {$_->{duration}   } @$trialseq;

 push @alltrials, {dur=>$time, freq=>$freq, seq=>$trialseq};
}



## build run/block
# we need to know 
#  * total time --> total number of trials
#  * mean ITI
#  * cushion times?
# need to create:
#  * # of times each trial sequence is presented
#  * distribution of ITIs

my $TOTALTIME=5.4*60 + 8;
my $MEANITI=4;
my $MINITI=2;
my $MAXITI=8;
# time that will be used by trials
my $avgTrlTime =  reduce { $a + $b->{freq}*($b->{dur}+$MEANITI) } 0, @alltrials;
# number of trials
#my $NTRIAL = sprintf("%d",$TOTALTIME / $avgTrlTime);
#say "$TOTALTIME/$avgTrlTime = ", $TOTALTIME/$avgTrlTime, " = $NTRIAL";
my $NTRIAL = $TOTALTIME / $avgTrlTime; # dont round here, round when we do trial seq freqs

# create number of repetitions for each trial sequence
# TODO: do we round or floor?
#$alltrials[$_]->{nRep} = sprintf("%d",$NTRIAL*$alltrials[$_]->{freq}+.5) for (0..$#alltrials);
$alltrials[$_]->{nRep} = sprintf("%d",$NTRIAL*$alltrials[$_]->{freq}) for (0..$#alltrials);

my $usedTime =  reduce { $a + $b->{nRep}*($b->{dur}+$MEANITI) } 0, @alltrials;
say "# will use $usedTime out of $TOTALTIME, leaving ", $TOTALTIME - $usedTime, "s for additional ITI";

# print out each trial sequence for visual varification
say "$_->{nRep} ($_->{freq}*$TOTALTIME) @ $_->{dur}s: ",
     join("\t",map {"$_->{name} $_->{duration}s"} @{$_->{seq}})   for (@alltrials);




# create a shuffled list of trial sequence indices
# this will be the final order that trial sequences are presented
my @trialSeqIDX;
push @trialSeqIDX, ($_)x$alltrials[$_]->{nRep} for (0..$#alltrials);
@trialSeqIDX = shuffle @trialSeqIDX;


## create ITIs
use Math::Random qw(random_exponential);
my $ITItime =  $TOTALTIME - reduce { $a + $b->{nRep}*$b->{dur} } 0, @alltrials;
my ($itcount,$ITIsum,@ITIs) = (0,99,0);
until (  $ITIsum - $ITItime  <= 1 && $ITIsum - $ITItime > 0 ) {
  @ITIs = map {sprintf("%.1f",$_)} random_exponential($NTRIAL,$MEANITI);
  @ITIs = map {$_=$_>$MAXITI?$MAXITI:$_; $_=$_<$MINITI?$MINITI:$_ } @ITIs;
  $ITIsum=sum(@ITIs);
  $itcount++; # near 50 iterations
}
#say join("\t",$itcount,$ITIsum,@ITIs);

## create 1D files, finally!
for my $trlseq (0..$NTRIAL) {
  @seq = @{$alltrials[$trialSeqIDX[$trlseq]]};
}

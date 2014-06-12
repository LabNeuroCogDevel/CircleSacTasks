#!/usr/bin/env perl
use strict; use warnings;
use 5.14.0; # use "say"
use List::Util qw/shuffle reduce sum/;
use List::MoreUtils qw/uniq zip/;
my $VERBOSE=1;
use Data::Dumper;

# example input "TEST=mem-dly;TR=2;TOTALTIME=300;snd[.5]; mem {1L=.33 [.3], 4L=.66 [.5] }; CATCH=1/6; dly[1.2];"

my @seq    = ();
my %events = ();
my $nCatch=0;
my @sumstable = ();

# SETTINGS
my $TOTALTIME;
my $TR=1.5;
my $STARTTIME=2;
my $MEANITI=3;
my $MINITI=1;
my $MAXITI=99; #no max
my $TESTS="";  #no tests
my $NITER=2;

while(<>) {
 # remove comments
 s/#.*//g;

 # split by semi-colon (for one liners)
 my @F = split /;/;

 # read in event by event
 for (@F) {
  

   # check for some settings
   $TOTALTIME=$1 and next if m/^ \s* TOTALTIME \s* = \s* ( [\d\.]+ ) \s* $/xi;
   $TR=$1 and next if m/^ \s* TR \s* = \s* ( [\d\.]+ ) \s* $/xi;
   $TESTS=$1 and next if m/^ \s* TESTS \s* = \s* ( .+ )$/xi;
   $NITER=$1 and next if m/^ \s* NITER \s* = \s* ( .+ )$/xi;

   
   # skip if it doesnt look like a name and time or catch
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
   # {1L=1/2 [.5], 4L=1/2 [.5] }
   # [.5] {1L,4L}
   my $condMatch=""; 
   if(/{.+}/) {
      $condMatch=$&;
      my $condcount = /,/g + 1;
      $condcount=1 if ! $condcount;
      while($condMatch=~m/ (?<cond> \w+ )  \s* ( (= \s* (?<count>[\d\.\/]+) ) | , |}\s* $)     /xg){
       #say "$_: $& --> $condcount";
       push @cond, [ $name .":".$+{cond}, $+{count}?$+{count}:(1/$condcount) ] ;
      }
   }
   # default condition is name, and full occurance
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

say "need a TOTALTIME=; line" and exit if(!$TOTALTIME || $TOTALTIME <= 0 );
say "need a TR=; line" and exit if(!$TR || $TR <= 0 );

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
#   [ {seq} {memL4} {dly} ]
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
say "# will use $usedTime out of $TOTALTIME, leaving ", $TOTALTIME - $usedTime, "s in addition to the $MEANITI sec meaned ITI";

# print out each trial sequence for visual varification
say "$_->{nRep} ($_->{freq}*$TOTALTIME) @ $_->{dur}s: ",
     join("\t",map {"$_->{name} $_->{duration}s"} @{$_->{seq}})   for (@alltrials);




# create a shuffled list of trial sequence indices
# this will be the final order that trial sequences are presented
my @trialSeqIDX;
push @trialSeqIDX, ($_)x$alltrials[$_]->{nRep} for (0..$#alltrials);
@trialSeqIDX = shuffle @trialSeqIDX;

# update total trials to the actual total 
$NTRIAL = $#trialSeqIDX;


## create ITIs
# sample from expodential
#  subtract min from mean and add it back to the result
#  cap at max ITI
use Math::Random qw(random_exponential);
my $ITItime =  $TOTALTIME - reduce { $a + $b->{nRep}*$b->{dur} } 0, @alltrials;


open my $FHsums, ">", "stimSums.txt" or die "cannot open output txt file";
say $FHsums join("\t",qw/it h LC/);

for my $deconIt (1..$NITER) {
  my ($itcount,$ITIsum,@ITIs) = (0,99,0);
  until (   $ITItime - $ITIsum <= .5 && $ITItime - $ITIsum  > 0 ) {
    @ITIs = map {sprintf("%.2f",$_+$MINITI)} random_exponential($NTRIAL,$MEANITI-$MINITI);
    @ITIs = map {$_=$_>$MAXITI?$MAXITI:$_} @ITIs;
    $ITIsum=sum(@ITIs);
    $itcount++;# near 50 iterations
    say "\tgenerating ITI, on  $itcount iteration" if($itcount>500  && $itcount%50==0 && $VERBOSE);
  }
  say "accounting for $ITIsum of $ITItime ITI time: ", sprintf("%.2f",$ITItime-$ITIsum), " ($itcount itrs)" if $VERBOSE;
  #say join("\t",@ITIs) if $VERBOSE;
  
  
  ## create 1D files, finally!
  my $timeused=$STARTTIME;
  my %files;
  my $odir="stims/$deconIt/";
  mkdir "stims" if ! -d "stims/";
  mkdir "$odir" if ! -d "$odir";
  
  
  for my $seqno (0..$NTRIAL-1) {
    my $trlseq=$trialSeqIDX[$seqno];
    for my $seq (@{$alltrials[$trlseq]->{seq} }) {
     # skip catches
     next if $seq->{event} =~ /^CATCH/;
  
     # open the file to write to if we need it
     open($files{$seq->{name}}, ">", "$odir/$seq->{name}.1D") unless exists($files{$seq->{name}}) ;
  
  
     # print to 1D file
     print { $files{$seq->{name}} } "$timeused ";
  
     # also print to event type if name and event aren't the same
     if($seq->{event} ne $seq->{name} ) {
        open($files{$seq->{event}}, ">", "$odir/$seq->{event}.1D") unless exists($files{$seq->{event}}) ;
        print { $files{$seq->{event}} } "$timeused ";
     }
  
     #say "$timeused $seq->{name} [$seq->{event}] ($seq->{duration})";
     $timeused+=$seq->{duration};
    }
    #say "$timeused ITI ($ITIs[$seqno])";
    $timeused+=$ITIs[$seqno];
    #say "$seqno, $trlseq, ",join("\t",map {$_->{name}}  @{$alltrials[$trlseq]->{seq} });
  }
  say "final ITI gets a bump of ", $TOTALTIME - $timeused;
  
  ## what does the 3dDeconvolve command look like
  
  my %allconditions = map { $_->{name} => $_->{duration}  }  map {@$_} values %events;
  my @stims = grep {$_!~/^(NO)?CATCH/} keys %allconditions;
  my @cmd=();
  push @cmd, ("-nodata ". sprintf("%d",$TOTALTIME/$TR+.5) ." $TR", "-polort 9");
  push @cmd, "-x1D $deconIt/X.xmat.1D ";
  push @cmd, "-num_stimts ". ($#stims+1);
  for my $stimno (0..$#stims ) {
   my $stimno_1=$stimno+1;
   push @cmd, "-stim_times $stimno_1 $odir/$stims[$stimno].1D 'BLOCK($allconditions{$stims[$stimno]},1)' -stim_label $stimno_1 $stims[$stimno]" ;
  }
  
  
  ## do we have any tests to run?
  my @testEq;
  foreach my $test (split/,/,$TESTS) {
   my $testName=$test;
   $testName=~s/\s//g; #remove white space
   #$testName=~y/+-/PM/;#repace addition and subtraction
   
   # if an event has conditions/manipulations
   # refing that event should have all manips in the contrast matrix
   
   # get the plus and minus to zip back 
   my $init='+'; #if not otherwise given, we start with plus
   $init=$1 if $test=~s/^\s*([+-])//; # make sure we dont have a bad first field
   my @seps = $test =~ /[+-]/g;
   @seps=('+',@seps); 
  
   # extract names from tests
   my @comp = split /[+-]/, $test;
   
   # search for actual names
   # and replace
   for  (0..$#comp){
     $comp[$_]=~s/\s//g;
     my $expanded="";
     if(!$events{$comp[$_]}){
       $expanded=" $seps[$_]$comp[$_]";
       say "WARNING: $comp[$_] is unknown to top level events list, using $expanded";
     } else {
        for my $h (@{ $events{$comp[$_]} }){
             $expanded.=" $seps[$_]$h->{name}";
        }
     }
     $comp[$_]=$expanded;
   }
  
   push @testEq,{eq=> join('',@comp), name=>$testName };
  }
  
  push @cmd, "-num_glt ". ($#testEq+1);
  push @cmd, "-gltsym 'SYM: $testEq[$_]->{eq}'  -glt_label ". ($_+1). " $testEq[$_]->{name}" for (0..$#testEq);
  
  open my $CMD, '-|', "3dDeconvolve ". join(" ",@cmd) ;#." 2>/dev/null";
  my $label="";
  my %results=();
  while(<$CMD>){
    $label="$2" and next if m/^(Stimulus|General).*:\s+([\w:\+\-]+)/;
    push @{$results{$1}}, {label=>$label, value=>$2} and next if m/^  (h|LC).+=\s+([\d\.]+)/;
  }
  
  my @sums;
  push @sums,sum(map {$_->{value}} @{$results{$_}} ) for (qw/h LC/);
  say $FHsums join("\t",$deconIt,@sums);
  push @sumstable, [@sums] 

}


## ALTERNATIVE ITI
#say "\n";
#my (@ITIpsbl, @ITIdist);
#my $ITIinterval=.25;
#push  @ITIpsbl, $MINITI+$ITIinterval*$_ for (0..($MAXITI-$MINITI)*1/$ITIinterval);
#push @ITIdist, sprintf("%.2f",  $NTRIAL * (1/$MEANITI) *exp(-1/$MEANITI * $_) ) for @ITIpsbl; 
#say join("\t",@ITIpsbl);
#say join("\t",@ITIdist);

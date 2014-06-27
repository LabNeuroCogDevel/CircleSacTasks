#!/usr/bin/env perl
use strict; use warnings;
use 5.14.0; # use "say"
use List::Util qw/shuffle reduce sum/;
use List::MoreUtils qw/uniq zip/;
my $VERBOSE=1;
use Data::Dumper;

my @seq    = ();
my %events = ();
my $nCatch=0;
my @sumstable = ();

# SETTINGS
#
my $TOTALTIME=234;
my $STARTTIME=8;
my $ENDTIME=12;
my $TOTALSCANNER=$TOTALTIME + $STARTTIME + $ENDTIME;
my $TR=1.5;
my $MEANITI=3;
my $MINITI=1;
my $MAXITI=99; #no max
#my $NITER=2;
my $NITER=200;
my $TOTALTRIALS=36;
#my $TESTS="";  #no tests

# need dly for L1 and dly for L4 
my $TESTS="mem, mem:L4 - mem:L1, dly"; # care about extracting response and memory

say "need a TOTALTIME=; line" and exit if(!$TOTALTIME || $TOTALTIME <= 0 );
say "need a TR=; line" and exit if(!$TR || $TR <= 0 );

my $taskname="workingMemory_vardly";
mkdir "$taskname" if ! -d "$taskname/";

@seq = qw/ snd  mem CATCH1 dly CATCH2 RSP/;
%events = (
 snd=> [ {event=>"snd", name=>"snd", occurRatio=>1, duration=>.5, nrep=>36   }  ],

 mem=> [  {event=>"mem", name=>"mem:L1", occurRatio=>1/2, duration=>.5, nrep=>12} ,
          {event=>"mem", name=>"mem:L4", occurRatio=>1/2, duration=>.5, nrep=>12} ] ,

 CATCH1=> [ {event=>"CATCH1", name=>"CATCH1",   occurRatio=>1/6, duration=>0, nrep=>3   } ,
            {event=>"CATCH1", name=>"NOCATCH1", occurRatio=>5/6, duration=>0, nrep=>30  }  ],

 dly   => [ {event=>"dly", name=>"dly:short", occurRatio=>1, duration=>1, nrep=>15},
            {event=>"dly", name=>"dly:long",  occurRatio=>1, duration=>3, nrep=>15}   ],

 CATCH2=> [ {event=>"CATCH2", name=>"CATCH2",   occurRatio=>1/6, duration=>0, nrep=>3      } ,
            {event=>"CATCH2", name=>"NOCATCH2", occurRatio=>5/6, duration=>0, nrep=>24     }  ],

 RSP  =>  [ {event=>"RSP", name=>"RSP:change",  occurRatio=>1,   duration=>2, nrep=>3     },
            {event=>"RSP", name=>"RSP:nochange",occurRatio=>1,   duration=>2, nrep=>3     }] 
);




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
 my $name = join("::",map{ $_->{name} } @$trialseq);
 my $freq = reduce {$a*$b} 1, map {$_->{occurRatio} } @$trialseq;
 my $time = reduce {$a+$b} 0, map {$_->{duration}   } @$trialseq;
 my $nRep = reduce {$a>$b?$b:$a} 99, map {$_->{nrep}   } @$trialseq;

 # we need to break up the catch trials for short and long
 # was 3 for each, but insetad 2 for long, 1 for short
 $nRep -=2 if $name=~m/L(1|4).*short.*:catch/i;
 $nRep -=1 if $name=~m/L(1|4).*long.*:catch/i;
 say "$nRep $name";
 push @alltrials, {dur=>$time, freq=>$freq, seq=>$trialseq, nRep=>$nRep, seqname=>$name};
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
my $NTRIAL=$TOTALTRIALS;
#my $NTRIAL = $TOTALTIME / $avgTrlTime; # dont round here, round when we do trial seq freqs

say "TOTAL SCAN TIME = $TOTALSCANNER ->" . (sprintf("%d",$TOTALSCANNER/$TR+.5) * $TR)  if $VERBOSE;
say "TOTAL TRIALSEQ  = " . (1+$#alltrials) if $VERBOSE;
say "TOTAL TRIAL     = $NTRIAL"     if $VERBOSE;
say "AVG   TRIAL TIME= $avgTrlTime" if $VERBOSE;

# create number of repetitions for each trial sequence
# TODO: do we round or floor?
#$alltrials[$_]->{nRep} = sprintf("%d",$NTRIAL*$alltrials[$_]->{freq}+.5) for (0..$#alltrials);
#$alltrials[$_]->{nRep} = sprintf("%d",$NTRIAL*$alltrials[$_]->{freq}+.5) for (0..$#alltrials);

my $usedTime =  reduce { $a + $b->{nRep}*($b->{dur}+$MEANITI) } 0, @alltrials;
say "# will use $usedTime out of $TOTALTIME, leaving ", $TOTALTIME - $usedTime, "s in addition to the $MEANITI sec meaned ITI";

# print out each trial sequence for visual varification
say "$_->{nRep} ($_->{freq}*".sprintf("%.2f",$NTRIAL).") @ $_->{dur}s: ",
     join("\t",map {"$_->{name} $_->{duration}s"} @{$_->{seq}})   for (@alltrials);




say " ***** \nready to run 3dDeconvolve?" if $VERBOSE;
readline;

## all random
# # create a shuffled list of trial sequence indices
# # this will be the final order that trial sequences are presented
# my @trialSeqIDX;
# push @trialSeqIDX, ($_)x$alltrials[$_]->{nRep} for (0..$#alltrials);
# @trialSeqIDX = shuffle @trialSeqIDX;

#########
## FOR ATTENTION ONLY
# we want psudeo blocked, so shuffly pop, hab, and flex separetly
# the hash trialSeqIdx looks like
#   flex => [1 1 1 4 4 4 5 ...]
#   hab  => [2 2 3 3 3 7 7 7 ...]
#   cue  => [6 6 6 8 8  9 9 ...]
my %trialSeqIDX;
my @cuedist=qw/flex hab pop/;
for (0..$#alltrials){
  my $seqname = reduce {$a.$b->{name}} '', @{$alltrials[$_]->{seq}};
  $seqname =~ /(flex|pop|hab)/;
  my $key=$1;
  if($key) {
     push @{$trialSeqIDX{$key}}, ($_)x$alltrials[$_]->{nRep};
  } else {
    # these are the catch trials
    # until we run out of reps, add them one by one to a different type
    my $trialidx=$_;
    my $cuedistIDX=0;
    push @{$trialSeqIDX{$cuedist[++$cuedistIDX %( $#cuedist+1)]}}, $trialidx for (1..$alltrials[$trialidx]->{nRep} )
  }
}

# # ATTN: give each sequence a trialtype value
# doesn't help with cue
#for my $ttype (@cuedist){
# for my $seqno (uniq(@{$trialSeqIDX{$ttype}} )){
#   $alltrials[$seqno]->{trialtype} = $ttype;
#  }
#}

my @trialSeqIDX = ();
for my $ttype (shuffle @cuedist) {
   push @trialSeqIDX, {seqno=>$_ ,ttype=>$ttype} for shuffle @{$trialSeqIDX{$ttype}} 
}
#########

# update total trials to the actual total 
$NTRIAL = $#trialSeqIDX +1;


## create ITIs
# sample from expodential
#  subtract min from mean and add it back to the result
#  cap at max ITI
use Math::Random qw(random_exponential);
my $ITItime =  $TOTALTIME - reduce { $a + $b->{nRep}*$b->{dur} } 0, @alltrials;


open my $FHsums, ">", "$taskname/stimSums.txt" or die "cannot open output txt file";
say $FHsums join("\t",qw/it h LC/);

my @noCatchSeq = grep { ! /CATCH/ } @seq;


for my $deconIt (1..$NITER) {


  # FOR ATTENTION ONLY
  # new shuffle of events
  my @trialSeqIDX = ();
  #push @trialSeqIDX,shuffle @{$trialSeqIDX{$_}} for (shuffle @cuedist);
  for my $ttype (shuffle @cuedist) {
      push @trialSeqIDX, {seqno=>$_ ,ttype=>$ttype} for shuffle @{$trialSeqIDX{$ttype}} 
  }

  my ($itcount,$ITIsum,@ITIs) = (0,99,0);
  until (   $ITItime - $ITIsum <= .5 && $ITItime - $ITIsum  > 0 ) {
    @ITIs = map {sprintf("%.2f",$_+$MINITI)} random_exponential($NTRIAL,$MEANITI-$MINITI);
    @ITIs = map {$_=$_>$MAXITI?$MAXITI:$_} @ITIs;
    $ITIsum=sum(@ITIs);
    $itcount++;# near 50 iterations
    say "\tgenerating ITI, on  $itcount iteration: $ITIsum sum vs $ITItime time" if($itcount>500  && $itcount%50==0 && $VERBOSE);
  }
  say "accounting for $ITIsum of $ITItime ITI time: ", sprintf("%.2f",$ITItime-$ITIsum), " ($itcount itrs)" if $VERBOSE;
  #say join("\t",@ITIs) if $VERBOSE;
  
  
  ## create 1D files, finally!
  my $timeused=$STARTTIME;
  my %files;
  my $odir="$taskname/stims/$deconIt/";
  mkdir "$taskname/stims" if ! -d "$taskname/stims/";
  mkdir "$odir" if ! -d "$odir";

  
  
  # write sequence and timing to read into matlab
  open($files{alltiming}, ">", "$odir/alltiming.txt") unless exists($files{alltiming}) ;

  my %secbump; # this hash records if we've given the 30second minibrake a trial type
  for my $seqno (0..$NTRIAL-1) {
    my $trlseq=$trialSeqIDX[$seqno]->{seqno};

    my @eventseq=@{$alltrials[$trlseq]->{seq} };
    my @eventSeqTime=();

    # write out times for each event to 1D
    for my $seq (@eventseq) {

     # skip catches
     next if $seq->{event} =~ /^CATCH/;

     push @eventSeqTime, [ $seq->{name},$timeused ];
  
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

     ## ATTENTION ONLY
     # add MINIBLOCKREST if we've finished with one type
    }

    # finish catch trials with string of all -1
    push @eventSeqTime, [ $noCatchSeq[$_], -1 ] for ( ($#eventSeqTime+1)..($#noCatchSeq));
    
    
    # write out this trial
    print {$files{alltiming}} join("\t", map {$_->[0]."\t".$_->[1]} @eventSeqTime ), "\n";


    
    #say "$timeused ITI ($ITIs[$seqno])";
    $timeused+=$ITIs[$seqno];

    #say "$seqno, $trlseq, ",join("\t",map {$_->{name}}  @{$alltrials[$trlseq]->{seq} });
  }

  say "final ITI gets a bump of ", $TOTALTIME - $timeused;
  
  ## what does the 3dDeconvolve command look like
  
  my %allconditions = map { $_->{name} => $_->{duration}  }  map {@$_} values %events;
  my @stims = grep {$_!~/^(NO)?CATCH/} keys %allconditions;
  my @cmd=();
  push @cmd, ("-nodata ". sprintf("%d",$TOTALSCANNER/$TR+.5) ." $TR", "-polort 4");
  push @cmd, "-x1D $odir/X.xmat.1D ";
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
  
  say join(" ",@cmd) ;
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


## ALTERNATIVE SCANNER#say "\n";
#my (@ITIpsbl, @ITIdist);
#my $ITIinterval=.25;
#push  @ITIpsbl, $MINITI+$ITIinterval*$_ for (0..($MAXITI-$MINITI)*1/$ITIinterval);
#push @ITIdist, sprintf("%.2f",  $NTRIAL * (1/$MEANITI) *exp(-1/$MEANITI * $_) ) for @ITIpsbl; 
#say join("\t",@ITIpsbl);
#say join("\t",@ITIdist);

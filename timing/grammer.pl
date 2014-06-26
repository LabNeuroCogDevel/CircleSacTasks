#!/usr/bin/env perl
use strict; use warnings;
use 5.14.0;
use Regexp::Grammars;
use Data::Dumper;
use Tree::Simple;
use List::Util qw/shuffle reduce sum min/;
# TEST=mem-dly;TR=2;TOTALTIME=300;
# snd[.5]; mem {1L=.33 [.3], 4L=.66 [.5] }; CATCH=1/6; dly[1.2]; 
my $parser = qr{
 <Tree>

 <rule: Tree> <[Event]>* % (;)

 <rule: Event>     <Name>  <Freq>?  <Dur>? <nReps>? <Manips>?
 <rule: Name>      \w+|-
 <rule: Num>       \d{0,}(\.\d+)?
 <rule: Dur>       \[<Num>\] 
 <rule: Manips>    <blocktype> <[Event]>+ % (,) (\<<ITI>\>)? [\)\}]
 <rule: blocktype> [\(\{]
 <rule: Freq>      =<Num>
 <rule: ITI>       <[Num]>+ % (,)
 <rule: nReps>     \<<Num>\>
 <rule: RT>        "<Num>"
}xms;

#"snd [2]; mem (b {aa <2>,bb},a=1 [3] <10,10,30>); dly" =~ $parser;
#"snd [.5]; mem [3] {high,low}; dly [1]; test [2] {same,diff};" =~ $parser;
#"snd; mem {high,low};-;dly {short,long {extra,normal}};-; test;" =~ $parser;
"cue [.5]  <5> ; mem [.5] {high <5> ,low <5> };- <2> ; dly [1] <3>;- <2>; test [2] <1>;" =~ $parser;
say Dumper(%/);
# prase input
my %inputed = %{$/{Tree}};


my @head;

# build the tree
my $tree = Tree::Simple->new({id=>"start", name=>"start"},Tree::Simple->ROOT);
push @head, $tree;

#my $tree;
#push @head, Tree::Simple->ROOT;
for my $event (@{$inputed{Event}}) {
   my $e = extractEvent($event);
   # cath trials
   if($event->{Name} eq "-") {
     map {Tree::Simple->new($e, $_) } @head;
   # event with manipulations
   }elsif($event->{Manips}) {
      @head = addEvents(\@head,$e->{name},@{$event->{Manips}->{Event}}) 
   # just an event
   } else {
     @head = map {Tree::Simple->new($e, $_) } @head;
   }
}


# parse tree: build sequences
my @seqs = SeqTree($tree,{seq=>'',nrep=>'',dur=>0,freq=>1});
say "Seqs:";
say join("\n",Dumper(@seqs));


###############################
# 
###############################

#### tear each branch of the tree into a sequence of events (a trial)
# recursive: parent of current branch, and the info from all chidlren (trial Info)
sub SeqTree {
 my $parent = shift;
 my $trialInfo = shift;
 my $children = $parent->getAllChildren;
 my $e = $parent->getNodeValue();

 # pretty print
 my $seq = $trialInfo->{seq};
 $seq .= ($seq?" -> ":"")  .  "$e->{id} ($e->{freq}% $e->{nreps}X $e->{dur}s)";

 # get freq,dur,and reps at thsi point
 my $freq =    ($e->{freq}||1    ) * ($trialInfo->{freq}||1   );
 my $dur  =    ($e->{dur} ||0    ) + ($trialInfo->{freq}||0   );
 my $nrep = min($e->{nrep}||9**99  ,  $trialInfo->{freq}||9*99);

 my $thisevent={ seq=>$seq, nrep=>$nrep,dur=>$dur,freq=>$freq  };

 my @seqs= ($thisevent);

 #return @seqs unless $children;
 if($#{$children}>=0){
   @seqs = map {SeqTree($_, $thisevent )} @$children;
 }
 return @seqs;

};


sub extractEvent {
 my $event=shift;
 my $parent=shift;
 say Dumper($parent);
 my $prefix=$parent?$parent->{id}||"":"";

 my $freq =    ($event->{freq}||1    ) * ($parent->{freq}||1   );
 my $dur  =    ($event->{dur} ||0    ) + ($parent->{freq}||0   );
 my $nrep = min($event->{nrep}||9**99  ,  $parent->{freq}||9*99);


 my $hashref = { id=> $prefix?"$prefix:$event->{Name}":$event->{Name},
             name=> $event->{Name} 
  };

  $hashref->{lc($_)} = $event->{$_}?$event->{$_}->{Num}:"" for qw/Freq nReps Dur/;
  return $hashref;
};

# event ; event [duration]; event {mani, mani}; event {mani [dur] <reps>, mani=ratio } 
# Thoughts
# () are blocked, {} are random manipulations
# if eventname =  Endblock, new tree
# 


## recurse through events in the parsed grammer 
# the parent and prefix are passed in
# returned: list of exit nodes
sub addEvents {
 # parent node and prefix
 my $parent=shift;
 my $prefix=shift;
 
 my @ends;
 # add each event to the tree recursively
 for my $event (@_){
   my $name = $event->{Name};
   $name="$prefix:$name" if $prefix;
   say "$name";
   my $e = extractEvent($event, $parent);
   
   my @subtree;
   # recurse through all manipulations
   if($event->{Manips}){
     my $subevents = $event->{Manips}->{Event};
     #@subtree = map {addEvents([$_],$e->{id},@$subevents) } @{$parent};
     @subtree = addEvents($parent,$e->{id},@$subevents) ;
   } else {
     @subtree = map {Tree::Simple->new($e, $_)} @{$parent};
   }

   push @ends, @subtree;
 }
 return @ends;
};

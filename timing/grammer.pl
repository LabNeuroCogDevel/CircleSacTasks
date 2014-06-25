#!/usr/bin/env perl
use strict; use warnings;
use 5.14.0;
use Regexp::Grammars;
use Data::Dumper;
use Tree::Simple;
# TEST=mem-dly;TR=2;TOTALTIME=300;
# snd[.5]; mem {1L=.33 [.3], 4L=.66 [.5] }; CATCH=1/6; dly[1.2]; 
my $parser = qr{
 <Tree>

 <rule: Tree> <[Event]>* % (;)

 <rule: Event>     <Name> <Dur>? <Manips>?
 <rule: Name>      \w+
 <rule: Num>       \d+(\.\d+)?
 <rule: Dur>       \[ <Num> \] 
 <rule: Manips>    <blocktype> <[Manip]>+ % (,) (\<<ITI>\>)? [\)\}]
 <rule: Manip>     <Name> <Manips> | <Name> <Freq>? <Dur>? <Reps>?
 <rule: blocktype> [\(\{]
 <rule: Freq>      =<Num>
 <rule: ITI>       <[Num]>+ % (,)
 <rule: Reps>      \<<Num>\>
 <rule: RT>        "<Num>"
}xms;

#"snd [2]; mem (b {aa <2>,bb},a=1 [3] <10,10,30>); dly" =~ $parser;
#"snd [.5]; mem [3] {high,low}; dly [1]; test [2] {same,diff};" =~ $parser;
"snd; mem {high,low}; dly {short,long {extra,normal}}; test;" =~ $parser;
say Dumper(%/);
# prase input
my %inputed = %{$/{Tree}};


# build the tree
my $tree = Tree::Simple->new({id=>"root", name=>"root"},Tree::Simple->ROOT);
my @head;
push @head, $tree;
for my $event (@{$inputed{Event}}) {
   my $e = { id=> $event->{Name}, name=> $event->{Name}, freq=> 1, nrep=>'', 'dur'=>0 };
   @head = map {Tree::Simple->new($e, $_) } @head;
   @head = addEvents(\@head,$e->{name},@{$event->{Manips}->{Manip}}) if $event->{Manips};
}
#say Dumper($tree);


# parse tree: build sequences
my @seqs = SeqTree($tree,'');
say "Seqs:";
say join("\n",@seqs);

sub SeqTree {
 my $parent = shift;
 my $seq = shift;
 my $children = $parent->getAllChildren;
 my $e = $parent->getNodeValue();
 $seq .= " -> $e->{id}";
 my @seqs= ($seq);

 #return @seqs unless $children;
 if($#{$children}>=0){
   @seqs = map {SeqTree($_,$seq)} @$children;
 }
 return @seqs;

};




# event ; event [duration]; event {mani, mani}; event {mani [dur] <reps>, mani=ratio } 
# Thoughts
# () are blocked, {} are random manipulations
# if eventname =  Endblock, new tree
# 



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
   my $e = { id=> $name, name=>$event->{Name}, freq=> 1, nrep=>'', 'dur'=>0 };
   # add to the tree
   #my $subtree = Tree::Simple->new($event->{Name}, $parent);
   
   my @subtree;
   # recurse through all manipulations
   if($event->{Manips}){
     my $subevents = $event->{Manips}->{Manip};
     #@subtree = map {addEvents([$_],$e->{id},@$subevents) } @{$parent};
     @subtree = addEvents($parent,$e->{id},@$subevents) ;
   } else {
     @subtree = map {Tree::Simple->new($e, $_)} @{$parent};
   }

   push @ends, @subtree;
 }
 return @ends;
};

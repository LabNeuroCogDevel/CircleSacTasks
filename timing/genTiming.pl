#!/usr/bin/env perl
use strict; use warnings;
use 5.14.0;

use Tree::Simple;
use Tree::Simple;
#use Data::TreeDumper;
use Data::Dumper;
my $tree=Tree::Simple->new("eventree.1", Tree::Simple->ROOT);
my @ends = ($tree);
my @catchEnds = ();

while(<>){
 for (split/;/){
  # manip [.3] {
  #while($event=~s/ (?<event>[\w\[\] ]+) \s* (?<rep>=?[\d\.]+) \s* (?<repeat>[\({])(?<rest> .+ ) [}\)] /$+{rest}/xg){
  # my $repeat = $1 eq ")" ? 1 : 0;
  # my @events = split/,/, $+{rest};

  #}

  next unless m/ (?<event>\w+) \s* \[ \s* (?<dur>[\d\.]+) \s* \]/x;
  my $eventName="$+{event}";
  say "$eventName $+{dur} ";
  my $event={name=>$eventName, duration=>$+{dur}, repeated=>0, freq=>1  };

  # add to the end of everything in this tree
   my @newends=();
   for my $treeend (@ends){
      my $newtree = Tree::Simple->new($event);
      $newtree->setUID($eventName);
      my $added = $treeend->addChild($newtree );
      if($eventName !~ /^CATCH/){
        push @newends, $newtree;;
      } else {
        push @catchEnds, $newtree;;
      }
   }
   @ends=@newends;
 }
}


say Dumper($tree);



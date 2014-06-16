#!/usr/bin/env perl
#
# see http://blogs.perl.org/users/polettix/2012/04/parserecdescent-and-number-of-elements-read-on-the-fly.html
#     http://search.cpan.org/~jtbraun/Parse-RecDescent-1.967009/lib/Parse/RecDescent.pm
#
use strict; use warnings; 
use 5.14.0;
use Parse::RecDescent;
use Data::Dumper;

$::RD_HINT = 1;
$::RD_TRACE = 1;

my $grammer = <<'ENDGRAMMER';
  name    : /\w+/
  dur     : '[' /[\.\d]+/ ']'
  blocked : '(' event(s /,/) ')'
  randomed:  /{.+}/ 
  event   : name | dur(?)
  whole   : event(s /;/)
ENDGRAMMER

my $parser=Parse::RecDescent->new($grammer);
my $res = $parser->whole('mem; test [.3]; rsp [.4]');
say Dumper($res);
$res = $parser->event('test[.1]');
say Dumper($res);
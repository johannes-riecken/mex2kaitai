use v6;
unit class Bar;
use Test;
# use Grammar::Debugger;
grammar Grammar is export {
  rule TOP { [ (<block> | <number>) <.ws> ]* }
  rule block { 'BEGIN' ( <number> )* 'END' }
  # RULE BLOck { 'BEGIN' [ <number> <.ws> ]* 'END' }
  token number { <digit> }
  proto token baz {*}
  token baz:sym<cmp> { ( '<' || '>' ) }
  token quux { <baz> }
  proto rule stmt {*}
  rule stmt:sym<Cmp> { <sym> <quux> }

}

class Actions {
   method baz (Match:D $/, :$sym) { say "In baz: $/";make ~$/[0] };
   method quux (Match:D $/) {say "In quux: $/";make ~$<baz> }
   method number ($/) { say "In number: $/";make +$/ }
   method block ($/) { say "In block: $/";make map { .made }, $<number> }
   method TOP ($/) { say "In top: $/";make ($<block>.made // $<number>.made) }
   # METHOD baz:sym<cmp> ($/) { say "In sym-baz: ";dd $/;dd %_;make ~$/ };
#    method TOP(Match:D $/ -->List:D) {
#        my %caps = $<stmt>.caps;
#        my $keyw = .Str
#            given %caps<sym>:delete;
#        my %args = %caps.pairs.map: {.key => .value.made};
#        make ($keyw,%args);
#    }
}

grammar Math {
  rule TOP { <sum> }
  token number { \d+ }
  rule unit { <number> | '(' <sum> ')' }
  rule product { <unit> + % '*' }
  rule sum { <product> + % '+' }
}

class MathActions {
  method number($/) { make +$/ }
  method unit($/) { make $<number>.made // $<sum>.made }
  method product($/) { make [*] $<unit>>>.made }
  method sum($/) { make [+] $<product>>>.made }
  method TOP($/) { make $<sum>.made }
}


my $actions = MathActions.new;
say "1.";
say Math.parse('4 + 5 * (1 + 3)', actions => $actions).made();
say "2.";
say Math.parse('4', actions => $actions).made();
say "3.";
say Math.parse('4 + 5', actions => $actions).made();
say "4.";
say Math.parse('5 * 3', actions => $actions).made();
say "5.";
say Math.parse('( 4 )', actions => $actions).made();

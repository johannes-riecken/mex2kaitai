use v6;
unit package Foo;

grammar Grammar is export {
  rule TOP { <stmt> ';' }
  token type { 'Long' | 'Int' }
  token number { \d+ }
  token identifier { <alpha>\w* }
  proto token fixed {*}
  token fixed:sym<cmp_op> { '<' || '>' }

  rule numberOrIdentifier { <number> || <identifier> }

  proto rule stmt {*}
  rule stmt:sym<GoTo> { <sym> <stmt:sym<Set>> <pos=.number> }
  rule stmt:sym<Set>  { <sym> <var=.identifier> <target=.numberOrIdentifier> }
  rule stmt:sym<Get>  { <sym> <var=.identifier> <type> }
}

class Actions {
   method number($/)     { make +$/ }
   method identifier($/) { make ~$/ }
   method type($/)       { make ~$/ }
   method numberOrIdentifier($/)   { make ($<number> // $<identifier>).made }
   method TOP($/) {
       my %caps = $<stmt>.caps;
       my $keyw = .Str
           given %caps<sym>:delete;
       my %args = %caps.pairs.map: {.key => .value.made};
       make ($keyw,%args);
   }
}

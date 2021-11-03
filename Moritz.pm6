grammar S-Expression {
  proto token atom {*}
  token atom:sym<integer> { <[-+]>?\d+ }
  token atom:sym<string> { '"' ( <-["\\]>+ | "\\" . )* '"' }
  token atom:sym<identifier> { .+ }
  rule TOP { <atom> }
}

class Identifier {
  has $.str;
}

class S-Actions {
  method atom:sym<identifier>($/) { make Identifier.new(str => ~$/) }
}


use Test;
my %atoms =
  integer => ('1', '01234', '-23', '+12'),
  identifier => ('abc', '=', '*_*'),
  string => ('""', '"abc"', Q'"abc\"def"', Q'"\\"'),
;
my %not-atoms =
  identifier => ('', '_'),
  string => ('', '"""', Q'"\"',),
;
for %atoms.keys.sort -> $atom {
  for %atoms{$atom}.list -> $test {
    ok S-Expression.parse($test,
      rule => "atom:sym<$atom>"),
      "Parsing '$test' as atom $atom";
  }
}
for %not-atoms.keys.sort -> $atom {
  for %not-atoms{$atom}.list -> $test {
    nok try {S-Expression.parse($test,
      rule => "atom:sym<$atom>") },
      "Not parsing '$test' as atom $atom";
  }
}

my @tests = '()', '(abc)', ' (abc) ', '( abc )',
  '(1)', '(+1)', '(-1)', '( () ( ) )';
for @tests -> $t {
  ok S-Expression.parse($t), "can parse '$t'";
}

my $m = S-Expression.parse(
  Q'((a "b") 23 "ab \\cd")',
  actions => S-Actions.new,
);
ok $m, 'Can parse S-Expression with action method';
is-deeply $m.made,
  [[[Identifier.new(str => "a"), "b"], 23, "ab \\cd"],],
  "correct data extracted";

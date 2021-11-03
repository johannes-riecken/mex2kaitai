use v6;
use Test;
use Foo;
my $actions = Foo::Actions.new;
my $s;
# $s = 'GoTo 2 ;';
$s = 'GoTo Set foo 3 2 ;';
is-deeply Foo::Grammar.parse($s, :$actions).made, ('GoTo', {pos => 2});
$s = 'Set foo 3;';
is-deeply Foo::Grammar.parse($s, :$actions).made, ('Set', {var => 'foo', target => 3});
$s = 'Get bar Long ;';
is-deeply Foo::Grammar.parse($s, :$actions).made, ('Get', {var => 'bar', type => 'Long'});
$s = 'Set foo bar ;';
is-deeply Foo::Grammar.parse($s, :$actions).made, ('Set', {var => 'foo', target => 'bar'});
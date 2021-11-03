use v6;
unit package Mex;

grammar Grammar is export {
  # rule TOP { (<block> | <statement> | <pragma> | <.comment>)* };
  rule TOP { <statement>+ };
  rule statement { <stmt> ';' };
  rule block { <if_block> | <do_block> };
  rule comment { '#' .* };

  proto rule partial_stmt {*}
  rule partial_stmt:sym<If> { <sym> <lhs=.identifier> <cmp_op=.fixed:sym<cmp_op>> <rhs=.identifier> }
  rule partial_stmt:sym<Else> { <sym> }
  rule partial_stmt:sym<EndIf> { <sym> }
  rule partial_stmt:sym<Do> { <sym> }
  rule partial_stmt:sym<While> { <sym> <lhs=.numberOrIdentifier> <cmp_op=.fixed:sym<cmp_op>> <rhs=.numberOrIdentifier> }
  rule if_block { <partial_stmt:sym<If>> <stmt>* <partial_stmt:sym<Else>> <stmt>* <partial_stmt:sym<EndIf>> };
  rule do_block { <partial_stmt:sym<Do>> <stmt>* <partial_stmt:sym<While>> };

  proto rule _fixed {*}
  token _fixed:cmp_op { '<' | '>' | '<>' | '=' | '>=' | '<=' };
  token _fixed:math_op { '+=' | '*=' | '/=' | '-=' };
  token _fixed:type { 'Long' | 'Int' | 'Byte' | 'ThreeByte' | 'String' };
  token _fixed:com_type { 'Zlib1' };
  token folderSpec { 'FileDir' | 'FDDE' };

  token fixed { <_fixed> }

  token identifier { <alpha> <alnum>* }
  token number { \d+ }
  token numberOrIdentifier { <number> || <identifier> }

  proto rule pragma {*}
  rule pragma:sym<ImpType> { <sym> ( 'Standard' | 'StandardTail' | 'SFileSize' | 'SFileOff' ) };


  rule for_block { <for_stmt> <stmt>* <next_stmt> };

  proto rule stmt {*}
  rule stmt:sym<CLog> { <sym> <name=.identifier> <offset=.number> <size=.number> <offsetoffset=.number> <resourcesizeoffset=.number> <uncompressedsize=.number> <uncompressedsizeoffset=.number> };
  rule stmt:sym<FindLoc> { <sym> <var=.identifier> <type=.fixed:sym<type>> <textnumber=.number> <file=.number> };
  rule stmt:sym<Get> { <sym> <var=.identifier> <type=.fixed:sym<type>> <file=.number> };
  rule stmt:sym<GetDString> { <sym> <var=.identifier> <n_chars=.number> <file=.number> };
  rule stmt:sym<GoTo> { <sym> <pos=.number> <file=.number> };
  rule stmt:sym<IDString> { <sym> <file=.number> <bytes=.number> };
  rule stmt:sym<Log> { <sym> <name=.identifier> <offset=.number> <size=.number> <offsetoffset=.number> <resourcesizeoffset=.number> };
  rule stmt:sym<Math> { <sym> <var1=.identifier> <math_op=.fixed:sym<math_op>> <var2=.identifier> };
  rule stmt:sym<Next> { <sym> <var=.identifier> };
  rule stmt:sym<Open> { <sym> <folderSpec> <fileOrExt=.number> <handleNum=.number> };
  rule stmt:sym<SavePos> { <sym> <var=.identifier> <file=.number> };
  rule stmt:sym<Set> { <sym> <var=.identifier> <numberOrIdentifier> };
  rule stmt:sym<String> { <sym> <var1=.identifier> <math_op=.fixed:sym<math_op>> <var2=.identifier> };
  rule stmt:sym<CleanExit> { <sym> };
  rule stmt:sym<GetCT> { <sym> <var=.identifier> <type=.fixed:sym<type>> <terminatorChar=.identifier> <file=.number> };
  rule stmt:sym<ComType> { <sym> <com_type=.fixed:sym<com_type>> };
}


class Actions {
   method number($/ -->Int:D)     { make +$/ }
   method identifier($/ -->Str:D) { make ~$/ }
   method fixed($/ -->Str:D)       { make ~$<_fixed> }
   method numberOrIdentifier($/)   { make ($<number> // $<identifier>).made }
   method folderSpec($/ -->Str:D) { make ~$/ }
   method statement($/ -->List:D) {
       my %caps = $<stmt>.caps;
       my $keyw = .Str
           given %caps<sym>:delete;
       my %args = %caps.pairs.map: {.key => .value.made};
       make ($keyw,%args);
   }
   method TOP($/ -->List:D) {
     make $<statement>[0].made;
   }
}

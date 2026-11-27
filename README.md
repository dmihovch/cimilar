# Cimilar
An artisanal, hand-crafted _(no AI gen!)_ compiler for a C-like language (hopefully a valid sub-set of C one day)

## What I am not currently implementing
- Variadics
- Pointers
- Structs

## Some issues:
Currently the lexer accepts and will emit `...` token, `->` token, `.` token, even though these are not valid in the language currently.

## EBNF work

<ident> ::= " main " | " x " | " func " | " var " | " foo213 "

<integer> ::= " 123 " | " 4 " | " 98761 "


<type> ::= " int " |  " void "

<param> ::= <type> <ident>

<params> ::= <param> <params_tail> | E

<params_tail> ::= "," <param> <params_tail> | E

<external> ::= <type> <ident> <external_tail>

<external_tail> ::= "=" <expression> ";" | "(" <params> ")" <function_tail> | ";"

<local_declaration> ::= <type> <ident> <local_tail>

<local_tail> ::= ";" | "=" <expression> ";"

<function_tail> ::= <block> | ";"

<expression> ::= <ident> | <integer>

<block> ::= "{"  "}"

<program> ::= <external> <program> | E
[BNF Playgound](https://bnfplayground.pauliankline.com)

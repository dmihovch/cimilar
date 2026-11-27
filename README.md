# Cimilar
An artisanal, hand-crafted _(no AI gen!)_ compiler for a C-like language (hopefully a valid sub-set of C one day)

## What I am not currently implementing
- Variadics
- Pointers
- Structs

## Some issues:
Currently the lexer accepts and will emit `...` token, `->` token, `.` token, even though these are not valid in the language currently.

## EBNF work
Probably switching to BNFGen soon, or something else
[BNF Playgound]([https://bnfplayground.pauliankline.com](https://bnfplayground.pauliankline.com/?bnf=%0A%3Cident%3E%20%3A%3A%3D%20%22%20main%20%22%20%7C%20%22%20x%20%22%20%7C%20%22%20func%20%22%20%7C%20%22%20var%20%22%20%7C%20%22%20foo213%20%22%0A%0A%3Cinteger%3E%20%3A%3A%3D%20%22%20123%20%22%20%7C%20%22%204%20%22%20%7C%20%22%2098761%20%22%0A%0A%0A%3Ctype%3E%20%3A%3A%3D%20%22%20int%20%22%20%7C%20%20%22%20void%20%22%0A%0A%3Cparam%3E%20%3A%3A%3D%20%3Ctype%3E%20%3Cident%3E%0A%0A%3Cparams%3E%20%3A%3A%3D%20%3Cparam%3E%20%3Cparams_tail%3E%20%7C%20E%0A%0A%3Cparams_tail%3E%20%3A%3A%3D%20%22,%22%20%3Cparam%3E%20%3Cparams_tail%3E%20%7C%20E%0A%0A%3Cexternal%3E%20%3A%3A%3D%20%3Ctype%3E%20%3Cident%3E%20%3Cexternal_tail%3E%0A%0A%3Cexternal_tail%3E%20%3A%3A%3D%20%22%3D%22%20%3Cexpression%3E%20%22%3B%22%20%7C%20%22%28%22%20%3Cparams%3E%20%22%29%22%20%3Cfunction_tail%3E%20%7C%20%22%3B%22%0A%0A%3Clocal_declaration%3E%20%3A%3A%3D%20%3Ctype%3E%20%3Cident%3E%20%3Clocal_tail%3E%0A%0A%3Clocal_tail%3E%20%3A%3A%3D%20%22%3B%22%20%7C%20%22%3D%22%20%3Cexpression%3E%20%22%3B%22%0A%0A%3Cfunction_tail%3E%20%3A%3A%3D%20%3Cblock%3E%20%7C%20%22%3B%22%0A%0A%3Cexpression%3E%20%3A%3A%3D%20%3Cident%3E%20%7C%20%3Cinteger%3E%0A%0A%3Cblock%3E%20%3A%3A%3D%20%22%7B%22%20%20%22%7D%22%0A%0A%3Cprogram%3E%20%3A%3A%3D%20%3Cexternal%3E%20%3Cprogram%3E%20%7C%20E%0A&name))

# Cimilar
An artisanal, hand-crafted _(no AI gen!)_ compiler for a C-like language (hopefully a valid sub-set of C one day)

## What I am not currently implementing
- Variadics
- Pointers
- Structs

## Some issues:
Currently the lexer accepts and will emit `...` token, `->` token, `.` token, even though these are not valid in the language currently.

## EBNF work

[ebnf site](https://bnfplayground.pauliankline.com/?bnf=%3Cprogram%3E%20%3A%3A%3D%20%7B%20function_def%20%7D%0A%0A%3Cfunction_def%3E%20%3A%3A%3D%20%3Ctype%3E%20%5E%5Ba-zA-Z_%5D%5Ba-zA-Z0-9_%5D*%24%20%22(%22%20%5B%20%3Cparams%3E%20%5D%20%22)%22%20%3Cblock%3E%0A%0Aparams%20%3A%3A%3D%20%3Cparam%3E%20%7B%20%22%2C%22%20%3Cparam%3E%20%7D%0A%0A%3Cgpa%3E%20%3A%3A%3D%20%224.0%22%20%7C%20%3Cleading%3E%20%22.%22%20%3Ctrailing%3E%0A%3Cleading%3E%20%3A%3A%3D%20%5B0-3%5D%0A%3Ctrailing%3E%20%3A%3A%3D%20%5B0-9%5D&name=)

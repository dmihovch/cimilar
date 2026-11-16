package lexer

import "core:fmt"

print_tokens :: proc(lex: ^Lexer){
	for tok in lex.toks {
		fmt.println(tok)
	}
}

print_lex_errors :: proc(lex: ^Lexer){
	for err in lex.errs {
		fmt.println(err)
	}
}

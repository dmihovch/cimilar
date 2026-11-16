package lexer 

import toks "../tokens"
import "core:fmt"

Lexer_Error_Kind:: enum {
	Invalid_Ident,
	Invalid_Num,
	Invalid_Punctuator,
	Invalid_Character,
	None,
	//and more
}

Lexer_Error :: struct {
	kind: Lexer_Error_Kind,
	message: string,
	value: string,
	row: int,
	col: int,
}

Lexer :: struct {
	source: string,
	pos: int,
	len: int,
	row: int,
	col: int,

	start: int,
	start_row:int,
	start_col:int,

	toks: [dynamic]toks.Token,
	errs: [dynamic]Lexer_Error,
}

init_lexer :: proc(source: string, len: int) -> Lexer {
	return Lexer{
		source = source,
		pos = 0,
		len = len,
		row = 1,
		col= 1,
	}
}

lexical_analysis :: proc(lex: ^Lexer) {
	for {
		ch, ok := peek(lex)
		if !ok {
			return
		}
		tokk:=toks.Token_Kind.Invalid; errk:=Lexer_Error_Kind.None
		switch {
		case is_digit(ch): 
			set_first_advance(lex)
			emit_token_or_error(lex, scan_number(lex))
		case is_ident_start(ch):
			set_first_advance(lex)
			emit_token_or_error(lex, scan_identifier(lex))
		case is_punctuator(ch):
			set_first_advance(lex)	
			emit_token_or_error(lex, scan_punctuator(lex, ch), .None)
		case is_whitespace(ch):
			advance(lex)
		case:
			set_first_advance(lex)
			emit_token_or_error(lex, tokk, .Invalid_Character)
		}
		//
	}
}

emit_token_or_error :: proc(lex: ^Lexer, tokk: toks.Token_Kind, errk: Lexer_Error_Kind){
	assert((tokk == .Invalid) == (errk != .None))
	if tokk != .Invalid {
		emit_token(lex, tokk)
	}
	if errk != .None {
		emit_error(lex, errk)
	}
}

//maybe an error, need to check if the append can fail
emit_token :: proc(lex: ^Lexer, tokk: toks.Token_Kind){
	append(&lex.toks,
		toks.Token{
			kind = tokk,
			value = lex.source[lex.start:lex.pos],
			row = lex.start_row,
			col = lex.start_col,
		} 
	)
}

emit_error :: proc(lex: ^Lexer, errk: Lexer_Error_Kind){
	append(&lex.errs, 
		Lexer_Error{
			kind = errk,
			message = get_err_msg(errk),
			value = lex.source[lex.start:lex.pos],
			row = lex.start_row,
			col = lex.start_col,
		}
	)
}

peek :: proc(lex: ^Lexer, n_ahead: int = 0) -> (u8, bool) {
	if lex.pos + n_ahead < lex.len{
		return lex.source[lex.pos + n_ahead], true
	}
	return 0, false
}

set_first_advance :: proc(lex: ^Lexer){
	lex.start = lex.pos
	lex.start_row = lex.row
	lex.start_col = lex.col
	advance(lex)
}

advance :: proc(lex: ^Lexer, ){
	assert(lex.pos < lex.len)
	ch := lex.source[lex.pos]
	lex.pos += 1
	if ch == '\n'{
		lex.row += 1
		lex.col = 1
	} else {
		lex.col += 1
	}
}




package main 

import "core:fmt"

Lexer_Error_Kind:: enum {
	Invalid_Ident,
	Invalid_Num,
	//and more
}

Lexer_Error :: struct {
	kind: Lexer_Error_Kind,
	message: string,
	value: string,
	invalid_char: u8,
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

	toks: [dynamic]Token,
	errs: [dynamic]Lexer_Error,
}

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

init_lexer :: proc(source: string, len: int) -> Lexer {
	return Lexer{
		source = source,
		pos = 0,
		len = len,
		row = 1,
		col= 1,
	}
}

get_err_msg :: proc(errk: Lexer_Error_Kind) -> string {
	switch errk {
	case .Invalid_Ident:
		return "Invalid Identifier:"
	case .Invalid_Num:
		return "Invalid Number:"
	}
	return "Unknown Error Type (This should not happen)"
}

get_operator_equal :: proc(tokk: Token_Kind) -> Token_Kind {
	switch {
	case tokk == .Plus:
		return .Plus_Equal 
	case tokk == .Minus:
		return .Minus_Equal 
	case tokk == .Star:
		return .Star_Equal 
	case tokk == .Divide:
		return .Divide_Equal 
	case tokk == .Modulo:
		return .Modulo_Equal 
	case tokk == .Bang:
		return .Bang_Equal
	case:
		return .Unknown_Tok
	}
}

//maybe an error, need to check if the append can fail
emit_token :: proc(lex: ^Lexer, tokk: Token_Kind){
	append(&lex.toks,
		Token{
		kind = tokk,
		value = lex.source[lex.start:lex.pos],
		row = lex.row,
		col = lex.col,
		} 
	)
}

emit_error :: proc(lex: ^Lexer, errk: Lexer_Error_Kind, ch: u8){
	append(&lex.errs, 
		Lexer_Error{
			kind = errk,
			message = get_err_msg(errk),
			value = lex.source[lex.start:lex.pos],
			invalid_char= ch if ch != 0 else 0,
			row = lex.row,
			col = lex.col,
		}
	)
}

advance_first :: proc(lex: ^Lexer){
	if lex.pos >= lex.len {
		return 
	}
	lex.start = lex.pos
	ch := lex.source[lex.pos]
	lex.pos += 1
	if ch == '\n'{
		lex.row += 1
		lex.col = 1
	} else {
		lex.col += 1
	}
}

advance :: proc(lex: ^Lexer){
	if lex.pos >= lex.len {
		return 
	}
	ch := lex.source[lex.pos]
	lex.pos += 1
	if ch == '\n'{
		lex.row += 1
		lex.col = 1
	} else {
		lex.col += 1
	}
}

//should only be called when scanning for 'operator=' patterns
scan_op_equal :: proc(lex: ^Lexer, tokk: Token_Kind) -> bool{
	if lex.pos < lex.len && peek(lex) == '='{
		advance_and_emit_token(lex, get_operator_equal(tokk))
		return true
	}
	return false
}

scan_plus :: proc(lex: ^Lexer){
	advance_first(lex)
	if lex.pos < lex.len {
		if scan_op_equal(lex, .Plus){
			return
		}
		if peek(lex) == '+' {
			advance_and_emit_token(lex, .Plus)
			return
		}
	} else {
		emit_token(lex, .Plus)
	}
	
}

advance_and_emit_token :: proc(lex: ^Lexer, tokk: Token_Kind){
	advance_first(lex)
	emit_token(lex, tokk)
}

scan_equals :: proc(lex: ^Lexer){
	advance_first(lex)
	if scan_op_equal(lex, .Equal) {
		return
	}else {
		emit_token(lex, .Equal)
	}
}

scan_punctuator:: proc(lex: ^Lexer){
	switch peek(lex){
	case '=':
		scan_equals(lex)
	case '!':
		scan_bang(lex)
	case '+':
		scan_plus(lex)
	case '-':
		scan_minus(lex)
	case '*':
		scan_star(lex)
	case '/':
		scan_divide(lex)
	case '%':
		scan_modulo(lex)
	case ';':
		advance_and_emit_token(lex, .Semicolon)
	case '{':
		advance_and_emit_token(lex, .LCurly)
	case '}':
		advance_and_emit_token(lex, .RCurly)
	case '[':
		advance_and_emit_token(lex, .LSquareBracket)
	case ']':
		advance_and_emit_token(lex, .RSquareBracket)
	case '(':
		advance_and_emit_token(lex, .LParen)
	case ')':
		advance_and_emit_token(lex, .RParen)
	}
}

scan_number :: proc(lex: ^Lexer){
	advance_first(lex)
	for lex.pos < lex.len {
		ch := peek(lex)
		switch {
		case is_digit(ch):
			advance(lex)
		case is_whitespace(ch):
			emit_token(lex, .Integer)
			return
		case is_punctuator(ch):
			emit_token(lex, .Integer)
			return
		case is_ident_start(ch):
			//TODO look for entire invalid thing
			emit_error(lex, .Invalid_Num, 0)
			return
		case:
			emit_error(lex, .Invalid_Num, ch)
			return
		}


	}
}

scan_identifier :: proc(lex: ^Lexer){
	//TODO
}

peek :: proc(lex: ^Lexer) -> u8 {
	return lex.source[lex.pos]
}

is_punctuator :: proc(c: u8) -> bool {
	switch c {
	case '=', '!', '+', '-', '*', '/', '%', ';', '{', '}', '[', ']', '(', ')', '>', '<', '|', '&', ',', '.':
		return true
	}
	return false
}

is_whitespace :: proc(c: u8) -> bool {
	return c == ' ' || c == '\n' || c == '\t'
}

is_digit :: proc(c: u8) -> bool {
	return c >= '0' && c <= '9'
}

is_alpha :: proc(c: u8) -> bool {
	return c >= 'a' && c <= 'z' || c >= 'A' && c <= 'Z'
}

is_ident_start :: proc(c: u8) -> bool{
	return is_alpha(c) || c == '_'
}

is_ident_continue :: proc(c: u8) -> bool {
	return is_ident_start(c) || is_digit(c)
}

//this is currently garbage
lexical_analysis :: proc(lex: ^Lexer) {
	for lex.pos < lex.len {
		ch := peek(lex)
		switch {
		case is_digit(ch): 
			scan_number(lex)
		case is_alpha(ch):
		case is_ident_start(ch):
		case is_punctuator(ch):
			scan_punctuator(lex)
		case is_whitespace(ch):
			advance(lex)
		}

	}

}

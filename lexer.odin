package main 

import "core:fmt"

Lexer_Error_Kind:: enum {
	Invalid_Ident,
	Invalid_Num,
	Invalid_Punctuator,
	Invalid_Character,
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
		return "Invalid Identifier: "
	case .Invalid_Num:
		return "Invalid Number: "
	case .Invalid_Punctuator:
		return "Invalid Punctuator: "
	case .Invalid_Character:
		return "Invalid Character: "
	}
	return "Unknown Error Type (This should not happen)"
}

//TODO ADD MORE
get_operator_equal :: proc(tokk: Token_Kind) -> Token_Kind {
	switch {
	case tokk == .Equal:
		return .Equal_Eq
	case tokk == .Plus:
		return .Plus_Eq
	case tokk == .Minus:
		return .Minus_Eq
	case tokk == .Star:
		return .Star_Eq
	case tokk == .Divide:
		return .Divide_Eq
	case tokk == .Modulo:
		return .Modulo_Eq
	case tokk == .Logical_Not:
		return .Logical_Not_Eq
	case:
		fmt.eprintln("In get_operator_equal, reached Unknown_Tok, something is badly wrong!")
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
		advance(lex)
		emit_token(lex, get_operator_equal(tokk))
		return true
	}
	return false
}

//need logical and, all bitwise
scan_operator :: proc(lex: ^Lexer){
	if lex.pos < lex.len {
		ch:=peek(lex)
		switch ch{
		case '=':
			advance_first(lex)
			if scan_op_equal(lex, .Equal){
				return
			}
			emit_token(lex, .Equal)
		case '+':
			advance_first(lex)
			if scan_op_equal(lex, .Plus){
				return
			}
			if lex.pos < lex.len && peek(lex) == '+'{
				advance(lex)
				emit_token(lex, .Plus_Plus)
				return
			}
			emit_token(lex, .Plus)
		case '-':
			advance_first(lex)
			if scan_op_equal(lex, .Minus){
				return
			}
			if lex.pos < lex.len {
				if peek(lex) == '-' {
					advance(lex)
					emit_token(lex, .Minus_Minus)
					return
				}
				if peek(lex) == '>' {
					advance(lex)
					emit_token(lex, .Ptr_Member_Acc)
					return
				}
			}
			emit_token(lex, .Minus)
		case '!':
			advance_first(lex)
			if scan_op_equal(lex, .Logical_Not){
				return
			}
			emit_token(lex, .Logical_Not)
		case '*':
			advance_first(lex)
			if scan_op_equal(lex, .Star){
				return
			}
			emit_token(lex, .Star)
		case '/':
			advance_first(lex)
			if scan_op_equal(lex, .Divide){
				return
			}
			emit_token(lex, .Divide)
		case '%':
			advance_first(lex)
			if scan_op_equal(lex, .Modulo){
				return
			}
			emit_token(lex, .Modulo)
		case '.':
			advance_first(lex)
			if lex.pos < lex.len {
				if peek(lex) == '.' {
					ch, ok := peek_n_ahead(lex, 1)
					if ok && ch == '.'{
						advance(lex)
						advance(lex)
						emit_token(lex, .Ellipsis)
						return
					}
				}
			}
			emit_token(lex, .Member_Acc)
		case:
			advance(lex)
			emit_error(lex, .Invalid_Punctuator, ch)
		}
	}		
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
	if scan_single_char_punctuation(lex){
		return
	}
	scan_operator(lex)
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
			scan_invalid_number(lex, .Invalid_Num, 0)
			return
		case:
			scan_invalid_number(lex, .Invalid_Num, ch)
			return
		}
	}
}

scan_invalid_number:: proc(lex: ^Lexer, errk: Lexer_Error_Kind, invalid_ch: u8){
	//TODO
	for lex.pos < lex.len && is_ident_continue(peek(lex)){
		advance(lex)
	}
	emit_error(lex, .Invalid_Num, invalid_ch)
}

scan_identifier :: proc(lex: ^Lexer){
	//TODO
}

peek_n_ahead :: proc(lex: ^Lexer, n_ahead: int) -> (u8, bool) {
	if lex.pos + n_ahead < lex.len{
		return lex.source[lex.pos + n_ahead], true
	}
	return 0, false
}
peek :: proc(lex: ^Lexer, n_ahead: int = 0) -> u8 {
	return lex.source[lex.pos]
}

is_punctuator :: proc(c: u8) -> bool {
	switch c {
	case '=', '!', '+', '-', '*', '/', '%', ';', '{', '}', '[', ']', '(', ')', '>', '<', '|', '&', ',', '.':
		return true
	}
	return false
}

//I am beginning to not like this...
scan_single_char_punctuation :: proc(lex: ^Lexer) -> bool{
	switch peek(lex){
	case ';':
		advance_first(lex)
		emit_token(lex, .Semicolon)
		return true
	case '{':
		advance_first(lex)
		emit_token(lex, .LCurly)
		return true
	case '}':
		advance_first(lex)
		emit_token(lex, .RCurly)
		return true
	case '[':
		advance_first(lex)
		emit_token(lex, .LSquare)
		return true
	case ']':
		advance_first(lex)
		emit_token(lex, .RSquare)
		return true
	case '(':
		advance_first(lex)
		emit_token(lex, .LParen)
		return true
	case ')':
		advance_first(lex)
		emit_token(lex, .RParen)
		return true
	case ',':
		advance_first(lex)
		emit_token(lex, .Comma)
		return true
	case ':':
		advance_first(lex)
		emit_token(lex, .Colon)
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
		case:
			advance_first(lex)
			emit_error(lex, .Invalid_Character, ch)
		}

	}

}

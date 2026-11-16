package lexer

import "core:fmt"
import toks "../tokens"


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

is_ident_continue :: proc(c: u8, ok: bool) -> bool {
	return ok && (is_ident_start(c) || is_digit(c))
}

get_lexeme :: proc(lex: ^Lexer) -> string {
	return lex.source[lex.start:lex.pos]
}

get_keyword :: proc(lexeme: string) -> (toks.Token_Kind, bool) {
	switch lexeme {
	case "int":
		return .Keyword_int, true
	case "return":
		return .Keyword_return, true
	}
	return .Invalid, false
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
	case .None:
		return "Not an Error"
	}
	return "Unknown Error Type (This should not happen)"
}

//TODO ADD MORE: maybe done?
get_assignment_variant :: proc(op: u8, next: u8) -> toks.Token_Kind {
	if next == '=' {
		switch op {
		case '=':
			return .Equal_Eq
		case '+':
			return .Plus_Eq
		case '-':
			return .Minus_Eq
		case '*':
			return .Star_Eq
		case '/':
			return .Divide_Eq
		case '%':
			return .Modulo_Eq
		case '!':
			return .Logical_Not_Eq
		case '<':
			return .Less
		case '>':
			return .Greater
		case '^':
			return .Bit_Xor_Eq
		case '&':
			return .Bit_And_Eq
		case '|':
			return .Bit_Or_Eq
		}
	}
	return .Invalid
}


get_single_char_punctuation :: proc(op: u8) -> toks.Token_Kind {
	switch op {
	case ';':
		return .Semicolon 
	case '{':
		return .LCurly
	case '}':
		return .RCurly
	case '[':
		return .LSquare
	case ']':
		return .RSquare
	case '(':
		return .LParen
	case ')':
		return .RParen
	case ',':
		return .Comma
	case ':':
		return .Colon
	case '~':
		return .Bit_Not
	}
	return .Invalid
}

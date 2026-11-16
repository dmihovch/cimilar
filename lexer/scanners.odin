package lexer

import toks "../tokens"
import "core:fmt"

//need logical and, all bitwise
scan_operator :: proc(lex: ^Lexer, op: u8) -> toks.Token_Kind{
	next, ok:= peek(lex)
	if ok {
		switch op {
		case '=':
			candidate_assignment_variant := get_assignment_variant(op, next)
			if candidate_assignment_variant != .Invalid {
				advance(lex)
				return  candidate_assignment_variant
			}
			return .Equal
		case '+':
			candidate_assignment_variant := get_assignment_variant(op, next)
			if candidate_assignment_variant != .Invalid {
				advance(lex)
				return  candidate_assignment_variant
			}
			if next == '+'{
				advance(lex)
				return .Plus_Plus
			}
			return .Plus
		case '-':
			candidate_assignment_variant := get_assignment_variant(op, next)
			if candidate_assignment_variant != .Invalid {
				advance(lex)
				return  candidate_assignment_variant
			}
			if next == '-' {
				advance(lex)
				return .Minus_Minus
			}
			if next == '>' {
				advance(lex)
				return .Ptr_Member_Acc
			}
			return .Minus
		case '!':
			candidate_assignment_variant := get_assignment_variant(op, next)
			if candidate_assignment_variant != .Invalid {
				advance(lex)
				return  candidate_assignment_variant
			}
			return .Logical_Not
		case '*':
			candidate_assignment_variant := get_assignment_variant(op, next)
			if candidate_assignment_variant != .Invalid {
				advance(lex)
				return  candidate_assignment_variant
			}
			return .Star
		case '/':
			candidate_assignment_variant := get_assignment_variant(op, next)
			if candidate_assignment_variant != .Invalid {
				advance(lex)
				return  candidate_assignment_variant
			}
			return .Divide
		case '%':
			candidate_assignment_variant := get_assignment_variant(op, next)
			if candidate_assignment_variant != .Invalid {
				advance(lex)
				return candidate_assignment_variant
			}
			return .Modulo
		case '.':
			if next == '.' {
				ahead, ok := peek(lex, 1)
				if ok && ahead == '.'{
					advance(lex)
					advance(lex)
					return .Ellipsis
				}
			}
			return .Member_Acc
		}		
	}
	fmt.eprintfln("got to end of scan_operator switch, this shouldn't happen. op={:c}", op)
	return .Invalid
}

scan_punctuator:: proc(lex: ^Lexer, op: u8) -> toks.Token_Kind {
	//checks first whether we just have a single character punctuator
	tokk := get_single_char_punctuation(op)
	if tokk != .Invalid {
		//advance(lex)
		return tokk 
	} 
	return scan_operator(lex, op)
}

scan_number :: proc(lex: ^Lexer) -> (toks.Token_Kind, Lexer_Error_Kind){
	for {
		ch, ok := peek(lex)
		if !ok {
			return .Integer, .None
		}	
		switch {
		case is_digit(ch):
			advance(lex)
		case is_ident_start(ch):
			scan_invalid_number(lex)
			return .Invalid, .Invalid_Num 
		case:
			return .Integer, .None	
		}
	}
}

scan_invalid_number:: proc(lex: ^Lexer){
	for is_ident_continue(peek(lex)){
		advance(lex)
	}
}

scan_identifier :: proc(lex: ^Lexer) -> (toks.Token_Kind, Lexer_Error_Kind){
	for is_ident_continue(peek(lex)){
		advance(lex)
	}
	
	if tokk, found := get_keyword(get_lexeme(lex)); found {
		return tokk, .None
	}

	return .Identifier, .None
}




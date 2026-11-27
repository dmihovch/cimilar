package tokens

//TODO need to organize the tokens for my own sanity...
Token_Kind :: enum {
	Identifier,
	Integer,
	Plus,
	Plus_Plus,
	Plus_Eq,
	Minus,
	Minus_Minus,
	Minus_Eq,
	Star,
	Star_Eq,
	Divide,
	Divide_Eq,
	Modulo,
	Modulo_Eq,
	Equal,
	Equal_Eq,
	Logical_Not,
	Logical_Not_Eq,
	Logical_And,
	Logical_Or,
	Greater,
	Greater_Eq,
	Less,
	Less_Equal,
	Bit_RShift,
	Bit_RShift_Eq,
	Bit_LShift,
	Bit_LShift_Eq,
	Bit_Not,
	Bit_And,
	Bit_And_Eq,
	Bit_Or,
	Bit_Or_Eq,
	Bit_Xor,
	Bit_Xor_Eq,
	Ternary,
	Ptr_Member_Acc,
	Comma,
	Member_Acc,
	Ellipsis,
	Colon,
	Semicolon,
	LParen,
	RParen,
	LCurly,
	RCurly,
	LSquare,
	RSquare,
	Keyword_int,
	Keyword_return,
	Keyword_if,
	Keyword_else,
	EOF,
	Invalid,
	Unknown_Tok,
}

Token :: struct {
	kind: Token_Kind,
	value: string,
	row: int,
	col: int,
}


get_tok_from_value :: proc(s: string) -> Token_Kind {
	switch s {
	case "+":
		return .Plus
	case "-":
		return .Minus
	case "=":
		return .Equal
	//TODO more
	}
	return .Unknown_Tok
}

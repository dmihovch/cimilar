package parser

import "core:fmt"
import tok "../tokens"

Parser :: struct {
	toks: [dynamic]tok.Token,
	ntoks: u32,
	ast: ^Node
}

//need to think through more
/*
Node :: union {
	Program,
	Block,
	Expr,
	Func_Tail,
	Local_Tail,
	Local_Decl,
	Extern_Tail,
	Extern,
	Params,
	Params_Tail,
	Param,
	Type,
	Ident,
	Integer,
}
*/



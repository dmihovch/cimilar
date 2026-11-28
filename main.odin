package main

import "core:fmt"
import "core:os"
import "core:strings"
import lex "lexer" 
import tok "tokens"

run :: proc() -> int {
	num_args := len(os.args)
	if num_args < 2 {
		fmt.eprintln("Usage: ./simple-compiler <file_name>.csam")
		return 1
	}

	fmt.println(os.args)
	
	if !strings.has_suffix(os.args[1], ".csam") {
		fmt.eprintln("file: ", os.args[1], " not a .csam file")
		return 2
	}

	
	file_str, err := read_file_to_string(os.args[1])
	if err != nil {
		fmt.eprintln("Error opening & reading file at path: ", os.args[1], " error msg: ", err)
		return 3
	}
	defer delete(file_str)

	fmt.println(file_str)

	toks: [dynamic]tok.Token
	defer delete(toks)
	lexer_errors: [dynamic]lex.Lexer_Error
	defer delete(lexer_errors)

	lexer := lex.init_lexer(file_str, u32(len(file_str)))
	lexer.toks = toks
	lexer.errs = lexer_errors
	lex.lexical_analysis(&lexer)

	lex.print_tokens(&lexer)
	lex.print_lex_errors(&lexer)

	//report errors and exit or hand off to parser

	return 0
}

read_file_to_string :: proc(path: string) -> (string, os.Error) {
	data, err := os.read_entire_file_from_path(path, context.allocator)
	if err != nil {
		return "", err 
	}
	return string(data), nil
}

main :: proc(){
	os.exit(run())	
}

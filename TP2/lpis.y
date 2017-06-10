%{
	void yyerror(char*);
	int yylex();
%}

%token DECLS INSTRS var num PRINT READ IF ELSE WHILE

%%

Ling: DECLS Decls INSTRS Instrs
	;

Decls: Decls ',' Decl
	 | Decl 
	 ;

Decl: var
	| var '[' num ']'
	| var '[' num ']' '[' num ']'
	;

Instrs: Instrs Instr
	  | Instr
	  ;

Instr: Atrib
	 | Print
	 | Read
	 | Cond
	 | Ciclo
	 ;

Atrib: Var '=' Valor ';'
	 | Var '=' Oper ';'
	 ;

Print: PRINT ':' Valor ';'
	 ;

Read: READ ':' Valor ';'
	;

Cond: IF '(' DefinirNomeSugestivo ')' '{' Instrs '}'
	| IF '(' DefinirNomeSugestivo ')' '{' Instrs '}' ELSE '{' Instrs '}'
	;

Ciclo: WHILE '(' DefinirNomeSugestivo ')' '{' Instrs '}'
	 ;

Oper: Valor '+' Valor
	| Valor '-' Valor
	| Valor '*' Valor
	| Valor '/' Valor
	| Valor '%' Valor
	;

DefinirNomeSugestivo: Valor '=' '=' Valor
					| Valor '!' '=' Valor
					| Valor '<' '=' Valor
					| Valor '>' '=' Valor
					| Valor '<' Valor
					| Valor '>' Valor
					;

Valor: Var
	 | num
	 ;

Var: var
   | var '[' Atom ']'
   | var '[' Atom ']' '[' Atom ']'
   ;

Atom: var
	| num
	;
%%
#include "lex.yy.c"

void yyerror(char *s){
	fprintf(stderr, "%d: %s\n\t%s\n", yylineno, yytext, s);
}

int main(int argc, char* argv[]){
	if(argc == 2){
		yyin = fopen(argv[1], "r");
	}
	yyparse();
	return 0;
}
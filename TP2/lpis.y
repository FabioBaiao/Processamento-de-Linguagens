%{
	#include <glib.h>

	void yyerror(char*);
	int yylex();
	void adicionarVariavel(char*);
	void contemVariavel(char*);

	GHashTable *vars;
%}

%token DECLS INSTRS var num PRINT READ IF ELSE WHILE

%union{int n; char *v;}

%type<v> var
%type<n> num

%%

Ling: DECLS Decls INSTRS Instrs
	;

Decls: Decls ',' Decl
	 | Decl 
	 ;

Decl: var 						  {adicionarVariavel($1);}
	| var '[' num ']'			  {adicionarVariavel($1);}
	| var '[' num ']' '[' num ']' {adicionarVariavel($1);}
	;

Instrs: Instrs Instr
	  | Instr
	  ;

Instr: Atrib
	 | Print
	 | Read
	 | CondS
	 | Ciclo
	 ;

Atrib: Var '=' Valor ';'
	 | Var '=' Oper ';'
	 ;

Print: PRINT ':' Valor ';'
	 ;

Read: READ ':' Valor ';'
	;

CondS: IF '(' Cond ')' '{' Instrs '}'
	 | IF '(' Cond ')' '{' Instrs '}' ELSE '{' Instrs '}'
	 ;

Ciclo: WHILE '(' Cond ')' '{' Instrs '}'
	 ;

Oper: Valor '+' Valor
	| Valor '-' Valor
	| Valor '*' Valor
	| Valor '/' Valor
	| Valor '%' Valor
	;

Cond: Valor '=' '=' Valor
	| Valor '!' '=' Valor
	| Valor '<' '=' Valor
	| Valor '>' '=' Valor
	| Valor '<' Valor
	| Valor '>' Valor
	;

Valor: Var
	 | num
	 ;

Var: var 						   {contemVariavel($1);}
   | var '[' Atom ']' 			   {contemVariavel($1);}
   | var '[' Atom ']' '[' Atom ']' {contemVariavel($1);}
   ;

Atom: var {contemVariavel($1);}
	| num
	;

%%
#include "lex.yy.c"

void contemVariavel(char *variavel){
	if(!g_hash_table_contains(vars, variavel)){
		yyerror(variavel);
	}
}

void adicionarVariavel(char *variavel){
	if(!g_hash_table_insert(vars, variavel, NULL)){
		yyerror(variavel);
	}
}

void yyerror(char *s){
	fprintf(stderr, "%d: %s\n\t%s\n", yylineno, yytext, s);
}

int main(int argc, char* argv[]){
	if(argc == 2){
		yyin = fopen(argv[1], "r");
	}
	vars = g_hash_table_new(g_str_hash, g_str_equal);
	yyparse();
	return 0;
}
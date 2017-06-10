%{
	#include <glib.h>
	#include <stdio.h>

	void yyerror(char*);
	int yylex();
	void adicionarVariavel(char*);
	int contemVariavel(char*);

	GHashTable *vars;
	int p;
%}

%token DECLS INSTRS var num PRINT READ IF ELSE WHILE

%union{int n; char *v;}

%type<v> var
%type<n> num Valor Var Atom

%%

Ling: DECLS Decls INSTRS Instrs {printf("stop\n");}
	;

Decls: Decl ',' Decls 
	 | Decl 			{printf("start\n");}
	 ;

Decl: var 						  {adicionarVariavel($1); printf("\tpushi 0\n");}
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

Print: PRINT ':' Valor ';' {printf("\tpushg %d\n\twritei\n", $3);}
	 ;

Read: READ ':' Valor ';' {printf("\tread\n\tatoi\n\tstoreg %d\n", $3);}
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

Valor: Var {$$ = $1;}
	 | num
	 ;

Var: var 						   {$$ = contemVariavel($1);}
   | var '[' Atom ']' 			   {$$ = contemVariavel($1);}
   | var '[' Atom ']' '[' Atom ']' {$$ = contemVariavel($1);}
   ;

Atom: var {$$ = contemVariavel($1);}
	| num
	;

%%
#include "lex.yy.c"

int contemVariavel(char *variavel){
	int *posicao = g_hash_table_lookup(vars, variavel);
	if(!posicao){
		yyerror(variavel);
		return -1;
	}
	return *posicao;
}

void adicionarVariavel(char *variavel){
	int *posicao = malloc(sizeof(int));
	*posicao = p;
	if(!g_hash_table_insert(vars, variavel, posicao)){
		yyerror(variavel);
	}
	p++;
}

void yyerror(char *s){
	fprintf(stderr, "%d: %s\n\t%s\n", yylineno, yytext, s);
}

int main(int argc, char* argv[]){
	if(argc == 2){
		yyin = fopen(argv[1], "r");
	}
	vars = g_hash_table_new(g_str_hash, g_str_equal);
	p = 0;
	yyparse();
	return 0;
}
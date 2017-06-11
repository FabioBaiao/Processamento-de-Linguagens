%{
	#include <glib.h>
	#include <stdio.h>

	void yyerror(char*);
	int yylex();
	void adicionarMatriz(char*, int, int);
	void adicionarArray(char*, int);
	void adicionarVariavel(char*);
	

	GHashTable *vars;
	int p, nIfs = 0;

	struct dadosVar{int pos, l;};

	struct dadosVar contemVariavel(char*);

	typedef struct stack{
		int v;
		struct stack *prox;
	} *Stack;

	Stack s;

	void push(Stack*, int);
	int pop(Stack*);
%}

%token DECLS INSTRS var num PRINT READ IF ELSE WHILE

%union{int n; char *v; struct dadosVar d;}

%type<v> var
%type<n> num
%type<d> Var Cabeca

%%

Ling: DECLS Decls INSTRS Instrs {printf("stop\n");}
	;

Decls: Decl ',' Decls 
	 | Decl 			{printf("start\n");}
	 ;

Decl: var 						  {adicionarVariavel($1); printf("\tpushi 0\n");}
	| var '[' num ']'			  {adicionarArray($1, $3); printf("\tpushn %d\n", $3);}
	| var '[' num ']' '[' num ']' {adicionarMatriz($1, $3, $6); printf("\tpushn %d\n", $3*$6);}
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

Atrib: Var '=' Valor ';'   {printf("\tstoreg %d\n", $1.pos);}
	 | Var '=' Oper ';'    {printf("\tstoreg %d\n", $1.pos);}
	 | Array '=' Valor ';' {printf("\tstoren\n");}
	 | Array '=' Oper ';'  {printf("\tstoren\n");}
	 ;

Print: PRINT ':' Valor ';' {printf("\twritei\n");}
	 ;

Read: READ ':' Var ';' {printf("\tread\n\tatoi\n\tstoreg %d\n", $3.pos);}
	| READ ':' Array ';' {printf("\tread\n\tatoi\n\tstoren\n");}
	;

CondS: IF { nIfs++; push(&s, nIfs); } '(' Cond ')' { printf("\tjz label%d\n", nIfs); } '{' Instrs '}' { int n = pop(&s); printf("label%d:\n", n); }
	 | IF { nIfs++; push(&s, nIfs); } '(' Cond ')' { printf("\tjz label%d\n", nIfs); } '{' Instrs '}' ELSE { nIfs++; printf("\tjz label%d\n", nIfs); } '{' Instrs '}' { int n = pop(&s); printf("label%d:\n", n); }
	 ;

Ciclo: WHILE '(' Cond ')' '{' Instrs '}'
	 ;

Oper: Valor '+' Valor {printf("\tadd\n");}
	| Valor '-' Valor {printf("\tsub\n");}
	| Valor '*' Valor {printf("\tmul\n");}
	| Valor '/' Valor {printf("\tdiv\n");}
	| Valor '%' Valor {printf("\tmod\n");}
	;

Cond: Valor '=' '=' Valor                   { printf("\tequal\n"); }
	| Valor '!' '=' Valor                   { printf("\tequal\n\tnot\n"); }
	| Valor '<' '=' Valor                   { printf("\tinfeq\n"); }
	| Valor '>' '=' Valor                   { printf("\tsupeq\n"); }
	| Valor '<' Valor                       { printf("\tinf\n"); }
	| Valor '>' Valor                       { printf("\tsup\n"); }
	;

Valor: Atom
	 | Array {printf("\tloadn\n");}
	 ;

Array: Cabeca
	 | Cabeca {printf("\tpushi %d\n\tmul\n", $1.l);} '[' Atom ']' {printf("\tadd\n");}
	 ;

Cabeca: Var {printf("\tpushgp\n\tpushi %d\n\tpadd\n", $1.pos);} '[' Atom ']' {$$ = $1;}
	  ;

Atom: Var {printf("\tpushg %d\n", $1.pos);}
	| num {printf("\tpushi %d\n", $1);}
	;

Var: var {$$ = contemVariavel($1);}
   ;

%%
#include "lex.yy.c"

void push (Stack *t, int h){
	Stack s = malloc(sizeof(struct stack));
	s->v = h;
	s->prox = *t;
}

int pop (Stack *s){
	int n = (*s)->v;
	(*s) = (*s)->prox;
	return n;
}

struct dadosVar contemVariavel(char *variavel){
	struct dadosVar *posicao = g_hash_table_lookup(vars, variavel);
	if(!posicao){
		yyerror(variavel);
		return *posicao;
	}
	return *posicao;
}

void adicionarMatriz(char *variavel, int n, int m){
	struct dadosVar *posicao = malloc(sizeof(struct dadosVar));
	posicao->pos = p;
	posicao->l = m;
	if(!g_hash_table_insert(vars, variavel, posicao)){
		yyerror(variavel);
	}
	p+=n*m;
}

void adicionarArray(char *variavel, int n){
	struct dadosVar *posicao = malloc(sizeof(struct dadosVar));
	posicao->pos = p;
	if(!g_hash_table_insert(vars, variavel, posicao)){
		yyerror(variavel);
	}
	p+=n;
}

void adicionarVariavel(char *variavel){
	struct dadosVar *posicao = malloc(sizeof(struct dadosVar));
	posicao->pos = p;
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
	s = NULL;
	yyparse();
	return 0;
}
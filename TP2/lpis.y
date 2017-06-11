%{
	#include <glib.h>
	#include <stdio.h>

	void yyerror(char*);
	int yylex();

	void adicionarMatriz(char*, int, int);
	void adicionarArray(char*, int);
	void adicionarVariavel(char*);
	
	GHashTable *vars;
	int pos, label;

	typedef struct{int pos, tamL;} DadosVar;
	DadosVar contemVariavel(char*);

	typedef struct stack{
		int v;
		struct stack *prox;
	} *Stack;
	Stack s;
	void push();
	int pop();
%}

%token DECLS INSTRS var num PRINT READ IF ELSE WHILE cad

%union{int n; char *v; DadosVar d;}

%type<v> var cad
%type<n> num
%type<d> Var ArrCabec

%%

Ling: DECLS Decls {printf("start\n");} INSTRS Instrs {printf("stop\n");}
	;

Decls: Decls ',' Decl 
	 | Decl
	 ;

Decl: var 						  {adicionarVariavel($1); }
	| var '[' num ']'			  {adicionarArray($1, $3); }
	| var '[' num ']' '[' num ']' {adicionarMatriz($1, $3, $6);}
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
	 | PRINT ':' cad ';' {printf("\tpushs %s\n\twrites\n", $3);}
	 ;

Read: READ ':' Var ';' {printf("\tread\n\tatoi\n\tstoreg %d\n", $3.pos);}
	| READ ':' Array ';' {printf("\tread\n\tatoi\n\tstoren\n");}
	;

CondS: IfCond { printf("label%d:\n", pop()); }
	 | IfCond ELSE { printf("\tjump label%d\n", label); printf("label%d:\n", pop()); push(); } '{' Instrs '}' { printf("label%d:\n", pop()); }
	 ;

IfCond: IF '(' Cond ')' { printf("\tjz label%d\n", label); push(); } '{' Instrs '}'
	  ;

Ciclo: WHILE { printf("label%d:\n", label); push(); } '(' Cond ')' { printf("\tjz label%d\n", label); push(); } '{' Instrs '}' { int lab = pop(); printf("\tjump label%d\n", pop()); printf("label%d:\n", lab);}
	 ;

Oper: Valor '+' Valor {printf("\tadd\n");}
	| Valor '-' Valor {printf("\tsub\n");}
	| Valor '*' Valor {printf("\tmul\n");}
	| Valor '/' Valor {printf("\tdiv\n");}
	| Valor '%' Valor {printf("\tmod\n");}
	;

Cond: Valor '=' '=' Valor  { printf("\tequal\n"); }
	| Valor '!' '=' Valor  { printf("\tequal\n\tnot\n"); }
	| Valor '<' '=' Valor  { printf("\tinfeq\n"); }
	| Valor '>' '=' Valor  { printf("\tsupeq\n"); }
	| Valor '<' Valor      { printf("\tinf\n"); }
	| Valor '>' Valor      { printf("\tsup\n"); }
	| Valor '&' '&' Valor     { printf("\tmul\n\tnot\n");}
	| Valor '|' '|' Valor     { }
	;

Valor: Atom
	 | Array {printf("\tloadn\n");}
	 ;

Array: ArrCabec
	 | ArrCabec {printf("\tpushi %d\n\tmul\n", $1.tamL);} '[' Atom ']' {printf("\tadd\n");}
	 ;

ArrCabec: Var {printf("\tpushgp\n\tpushi %d\n\tpadd\n", $1.pos);} '[' Atom ']' {$$ = $1;}
		;

Atom: Var {printf("\tpushg %d\n", $1.pos);}
	| num {printf("\tpushi %d\n", $1);}
	;

Var: var {$$ = contemVariavel($1);}
   ;

%%
#include "lex.yy.c"

void push (){
	Stack h = malloc(sizeof(struct stack));
	h->v = label++;
	h->prox = s;
	s = h;
}

int pop (){
	int n = s->v;
	Stack aux = s->prox;
	free(s);
	s = aux;
	return n;
}

DadosVar contemVariavel(char *variavel){
	DadosVar *posicao = g_hash_table_lookup(vars, variavel);
	if(!posicao){
		yyerror(variavel);
		return *posicao;
	}
	return *posicao;
}

void adicionarMatriz(char *variavel, int n, int m){
	DadosVar *posicao = malloc(sizeof(DadosVar));
	posicao->pos = pos;
	posicao->tamL = m;
	if(!g_hash_table_insert(vars, variavel, posicao)){
		yyerror(variavel);
	}
	pos+=n*m;
	printf("\tpushn %d\n", n*m);
}

void adicionarArray(char *variavel, int n){
	DadosVar *posicao = malloc(sizeof(DadosVar));
	posicao->pos = pos;
	if(!g_hash_table_insert(vars, variavel, posicao)){
		yyerror(variavel);
	}
	pos+=n;
	printf("\tpushn %d\n", n);
}

void adicionarVariavel(char *variavel){
	DadosVar *posicao = malloc(sizeof(DadosVar));
	posicao->pos = pos;
	if(!g_hash_table_insert(vars, variavel, posicao)){
		yyerror(variavel);
	}
	pos++;
	printf("\tpushi 0\n");
}

void yyerror(char *s){
	fprintf(stderr, "%d: %s\n\t%s\n", yylineno, yytext, s);
}

int main(int argc, char* argv[]){
	if(argc == 2){
		yyin = fopen(argv[1], "r");
	}
	if (argc == 3){
		yyin = fopen(argv[1], "r");
		yyout = fopen(argv[2], "w");
	}
	vars = g_hash_table_new(g_str_hash, g_str_equal);
	pos = 0;
	label = 0;
	s = NULL;
	yyparse();
	return 0;
}
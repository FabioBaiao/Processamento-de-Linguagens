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
	FILE *f;

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

Ling: DECLS Decls {fprintf(f, "start\n");} INSTRS Instrs {fprintf(f, "stop\n");}
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

Atrib: Var '=' Valor ';'   {fprintf(f, "\tstoreg %d\n", $1.pos);}
	 | Var '=' Oper ';'    {fprintf(f, "\tstoreg %d\n", $1.pos);}
	 | Var '=' Cond ';'    {fprintf(f, "\tstoreg %d\n", $1.pos);}
	 | Array '=' Valor ';' {fprintf(f, "\tstoren\n");}
	 | Array '=' Oper ';'  {fprintf(f, "\tstoren\n");}
	 | Array '=' Cond ';'  {fprintf(f, "\tstoren\n");}
	 | Var '=' '(' Cond {fprintf(f, "\tjz label%d\n", label++);} '?' Valor {fprintf(f, "\tstoreg %d\n\tjump label%d\nlabel%d:\n", $1.pos, label++, label-1);} ':' Valor ')' ';' {fprintf(f, "\tstoreg %d\nlabel%d:\n", $1.pos, label-1);}
	 ;

Print: PRINT ':' Valor ';' {fprintf(f, "\twritei\n");}
	 | PRINT ':' cad ';' {fprintf(f, "\tpushs %s\n\twrites\n", $3);}
	 ;

Read: READ ':' Var ';' {fprintf(f, "\tread\n\tatoi\n\tstoreg %d\n", $3.pos);}
	| READ ':' Array ';' {fprintf(f, "\tread\n\tatoi\n\tstoren\n");}
	;

CondS: IfCond { fprintf(f, "label%d:\n", pop()); }
	 | IfCond ELSE { fprintf(f, "\tjump label%d\n", label); fprintf(f, "label%d:\n", pop()); push(); } '{' Instrs '}' { fprintf(f, "label%d:\n", pop()); }
	 ;

IfCond: IF '(' Cond ')' { fprintf(f, "\tjz label%d\n", label); push(); } '{' Instrs '}'
	  ;

Ciclo: WHILE { fprintf(f, "label%d:\n", label); push(); } '(' Cond ')' { fprintf(f, "\tjz label%d\n", label); push(); } '{' Instrs '}' { int lab = pop(); fprintf(f, "\tjump label%d\n", pop()); fprintf(f, "label%d:\n", lab);}
	 ;

Oper: Valor '+' Valor {fprintf(f, "\tadd\n");}
	| Valor '-' Valor {fprintf(f, "\tsub\n");}
	| Valor '*' Valor {fprintf(f, "\tmul\n");}
	| Valor '/' Valor {fprintf(f, "\tdiv\n");}
	| Valor '%' Valor {fprintf(f, "\tmod\n");}
	;

Cond: Valor '=' '=' Valor  { fprintf(f, "\tequal\n"); }
	| Valor '!' '=' Valor  { fprintf(f, "\tequal\n\tnot\n"); }
	| Valor '<' '=' Valor  { fprintf(f, "\tinfeq\n"); }
	| Valor '>' '=' Valor  { fprintf(f, "\tsupeq\n"); }
	| Valor '<' Valor      { fprintf(f, "\tinf\n"); }
	| Valor '>' Valor      { fprintf(f, "\tsup\n"); }
	| Valor '&' '&' Valor  { fprintf(f, "\tmul\n");}
	;

Valor: Atom
	 | Array {fprintf(f, "\tloadn\n");}
	 ;

Array: ArrCabec
	 | ArrCabec {fprintf(f, "\tpushi %d\n\tmul\n", $1.tamL);} '[' Atom ']' {fprintf(f, "\tadd\n");}
	 ;

ArrCabec: Var {fprintf(f, "\tpushgp\n\tpushi %d\n\tpadd\n", $1.pos);} '[' Atom ']' {$$ = $1;}
		;

Atom: Var {fprintf(f, "\tpushg %d\n", $1.pos);}
	| num {fprintf(f, "\tpushi %d\n", $1);}
	| '-' num {fprintf(f, "\t pushi %d\n", -$2);}
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
		exit(0);
	}
	pos+=n*m;
	fprintf(f, "\tpushn %d\n", n*m);
}

void adicionarArray(char *variavel, int n){
	DadosVar *posicao = malloc(sizeof(DadosVar));
	posicao->pos = pos;
	if(!g_hash_table_insert(vars, variavel, posicao)){
		yyerror(variavel);
		exit(0);
	}
	pos+=n;
	fprintf(f, "\tpushn %d\n", n);
}

void adicionarVariavel(char *variavel){
	DadosVar *posicao = malloc(sizeof(DadosVar));
	posicao->pos = pos;
	if(!g_hash_table_insert(vars, variavel, posicao)){
		yyerror(variavel);
		exit(0);
	}
	pos++;
	fprintf(f, "\tpushi 0\n");
}

void yyerror(char *s){
	fprintf(stderr, "%d: %s\n\t%s\n", yylineno, yytext, s);
}

int main(int argc, char* argv[]){
	f = stdout;
	if(argc == 2){
		yyin = fopen(argv[1], "r");
	}
	else if (argc == 3){
		yyin = fopen(argv[1], "r");
		f = fopen(argv[2], "w");
	}
	vars = g_hash_table_new(g_str_hash, g_str_equal);
	pos = 0;
	label = 0;
	s = NULL;
	yyparse();
	return 0;
}
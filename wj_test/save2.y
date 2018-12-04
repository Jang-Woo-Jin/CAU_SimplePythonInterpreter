%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include "myGrammar.h"
#include "myGrammar.tab.h"

/* Prototypes */
nodeType *opr(int oper, int nops, ...);
nodeType *id(int i);
nodeType *intCon(int value);
nodeType *floatCon(float value);

void freeNode(nodeType *p);
int yylex(void);
void yyerror(const char *str);

int sym[26];
%}

%union {
  int i_value;          /* Integer value */
  float f_value;        /* float value */
  char* sIndex;          /* Symbol table index */
  nodeType *nPtr;       /* Node pointer */
}

%token MAINPROG VAR ARRAY OF FUNCTION PROCEDURE
%token BEG END IF THEN ELSE NOP WHILE RETURN PRINT 
%token <sIndex> ID GE LE EQ NE '<' '>' '+' '-' '*' '/'
%token INTEGER FLOAT
%token <i_value> I_VALUE
%token <f_value> F_VALUE
%token OPERATOR DELIMITER


%left GE LE EQ NE //'>' '<'
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS 
%nonassoc UPLUS


%type <nPtr> expression simple_expression term factor num
%type <nPtr> statement_list statement print_statement
%type <i_value> relop multop addop
%type <nPtr> variable 
%%
program: 
		function { exit(0); }
		;

function:
        | function statement_list { freeNode($2);}
		| function variable { printf("id = %s\n", ex($2)); }
		;

statement_list:
        	statement	{ ex($1); }
			| statement ';' statement_list { $$ = opr(';', 2, $1, $3);  }
			;

statement:
        variable '=' expression { $$ = opr('=', 2, $1, $3); /*printf("id : %s = %d\n",ex($1),ex($3));*/ }
        | print_statement		{ $$ = $1; }
        | IF expression THEN statement ELSE statement 	{ $$ = opr(IF, 3, $2, $4, $6);  }
        | WHILE '(' expression ')' statement			{ $$ = opr(WHILE, 2, $3, $5);   }
        ;

print_statement:
        PRINT	{ $$ = opr(PRINT, 0); }
        | PRINT '(' expression ')'	{ $$ = opr(PRINT, 1, $3); }
        ;

variable:
        ID	{ 
				$$ = id($1); 
				printf("\tFlex returned id : %s\n",$1);
			}
        | ID '[' expression ']'
        ;

expression:
        simple_expression { $$ = $1; }
        | 	simple_expression relop simple_expression  { 
				printf("\tFlex returned relop : %s\n",$2); 
				$$ = opr(ex($2),2,$1,$3); 
			}
        ;

simple_expression:
        term { $$ = $1; }
        | 	term addop simple_expression { 
				printf("\tFlex returned addop : %s\n",$2); 
				$$ = opr(ex($2),2,$1,$3); 
			}
        ;

term:
        factor 	{ $$ = $1; }
        | 	factor multop term { 
				printf("\tFlex returned multop : %s\n",$2); 
				$$ = opr(ex($2),2,$1,$3); 
			}
        ;

factor:
        I_VALUE	{ 
                    $$ = intCon($1);
					printf("\tFlex returned Int : %d\n",yylval); 
				}
        | F_VALUE 	{ 
						$$ = floatCon($1);
						printf("\tFlex returned Float :%f\n",$1); 
					}
        | variable	{
						$$ = $1;
					}
		| '!' factor
        | sign factor
        ;

sign:
        UPLUS
        | UMINUS
        ;

relop:
        GE 		{ $$ = $1; }
        | '>'	{ $$ = $1; }
        | LE	{ $$ = $1; }
        | '<'	{ $$ = $1; }
        | EQ	{ $$ = $1; }
        | NE	{ $$ = $1; }
        ;

addop:
        '+'		{ $$ = $1; }
        | '-'	{ $$ = $1; }
        ;

multop:
        '*'		{ $$ = $1; }
        | '/'	{ $$ = $1; }
        ;

epsilon: ;

num:
    I_VALUE	{
				$$ = intCon($1);
				printf("\tFlex returned num : %d\n",yylval);
			}
    ;

%%

#define SIZEOF_NODETYPE ((char *)&p->con - (char *)p)

nodeType *intCon(int value) {
	nodeType *p;

	/* Allocate node */
	if((p = malloc(sizeof(nodeType))) == NULL)
		yyerror("out of memory");

	/* Copy information */
	p->type = typeInt;
	p->intCon.value = value;

	return p;
}
nodeType *floatCon(float value) {
	nodeType *p;

	/* Allocate node */
	if((p = malloc(sizeof(nodeType))) == NULL)
		yyerror("out of memory");

	/* Copy information */
	p->type = typeFloat;
	p->floatCon.value = value;

	return p;
}
nodeType *id(int i) {
	nodeType *p;

	/* Allocate node */
	if((p = malloc(sizeof(nodeType))) == NULL)
		yyerror("out of memory");

	/* Copy information */
	p->type = typeId;
	p->id.i = i;

	return p;
}
nodeType *opr(int oper, int nops, ...) {
	va_list ap;
	nodeType *p;
	int i;

	/* Allocate node */
	if((p = malloc(sizeof(nodeType))) == NULL)
		yyerror("out of memory");
	if((p->opr.op = malloc(nops * sizeof(nodeType))) == NULL)
		yyerror("out of memory");

	/* Copy information */
	p->type = typeOpr;
	p->opr.oper = oper;
	p->opr.nops = nops;
	va_start(ap, nops);
	for(i = 0; i < nops; i++)
		p->opr.op[i] = va_arg(ap, nodeType*);
	va_end(ap);

	return p;
}

void freeNode(nodeType *p) {
	int i;

	if(!p) return;

	if(p->type == typeOpr) {
		for(i = 0; i < p->opr.nops; i++)
			freeNode(p->opr.op[i]);
		free(p->opr.op);
	}
	free(p);
}
void yyerror(const char *str){
	fprintf(stderr,"err : %s\n",str);
}

int yywrap(){
	return 1;
}
main(){
	yyparse();
}

/*
extern int yy_flex_debug;
int main(int argc, char *argv[])
{
  yy_flex_debug = 1;
  yyparse();
  return 0;
}*/


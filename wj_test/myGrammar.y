%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include <stdarg.h>
#include "myGrammar.tab.h"


/* Prototypes */
nodeType *opr(int oper, int nops, ...);
nodeType *id(int i);
nodeType *con(int value);
void freeNode(nodeType *p);
int yylex(void);
void yyerror(const char *str);

typedef enum {
  typeCon,
  typeId,
  typeOpr
} nodeEnum;

/* Constants */
typedef struct {
  int value;
} conNodeType;

/* Identifiers */
typedef struct {
  int i;
} idNodeType;

/* Operators */
typedef struct {
  int oper;                /* Operator */
  int nops;                /* Number of operants */
  struct nodeTypeTag **op; /* Operands */
} oprNodeType;

typedef struct nodeTypeTag {
  nodeEnum type;           /* Type of node */

  union {
    conNodeType con; /* Constants */
    idNodeType  id;  /* Identifiers */
    oprNodeType opr; /* Operators */
  };
} nodeType;


%}

%union {
  int i_value;     /* Integer value */
  char sIndex;    /* Symbol table index */
  nodeType *nPtr; /* Node pointer */
}

%token MAINPROG
%token VAR
%token ARRAY
%token OF
%token FUNCTION
%token PROCEDURE
%token BEG
%token END
%token IF
%token THEN
%token ELSE
%token NOP
%token WHILE
%token RETURN
%token PRINT
%token ID
%token INTEGER
%token FLOAT
%token I_VALUE
%token F_VALUE
%token OPERATOR
%token DELIMITER

%left '+' '-'
%left '*' '/'

%%
program: 
        program MAINPROG ID ';' declarations subprogram_declaration compound_statement
        | MAINPROG ID ';' declarations subprogram_declarations compound_statement
        ;

declarations:
        VAR identifier_list ':' type ';' declarations
        | epsilon
        ;

identifier_list:
        ID
        | ID ';' identifier_list
        ;

type:
        standard_type
        | ARRAY '[' num ']' OF standard_type
        ;

standard_type:
        INTEGER
        | FLOAT
        ;

subprogram_declarations:
        subprogram_declaration subprogram_declarations
        | epsilon
        ;

subprogram_declaration:
        subprogram_head declarations compound_statement
        ;

subprogram_head:
        FUNCTION ID argument ':' standard_type ';'
        | PROCEDURE ID argument ';'
        ;

argument:
        '(' parameter_list ')'
        | epsilon
        ;

parameter_list:
        identifier_list ':' type
        | identifier_list ':' type ';' parameter_list
        ;

compound_statement:
        BEG statement_list END
        ;

statement_list:
        statement
        | statement ';' statement_list
        ;

statement:
        variable '=' expression
        | print_statement
        | procedure_statement
        | compound_statement
        | IF expression THEN statement ELSE statement
        | WHILE '(' expression ')' statement
        | RETURN expression
        | NOP
        ;

print_statement:
        PRINT
        | PRINT '(' expression ')'
        ;

variable:
        ID
        | ID '[' expression ']'
        ;

procedure_statement:
        ID '(' actural_parameter_expression ')'
        ;

actural_parameter_expression:
        epsilon
        | expression_list
        ;

expression_list:
        expression
        | expression ';' expression_list
        ;

expression:
        simple_expression
        | simple_expression relop simple_expression
        ;

simple_expression:
        term
        | term addop simple_expression
        ;

term:
        factor
        | factor multop term
        ;

factor:
        I_VALUE {
                printf("\tFlex returned Int : %d\n",yylval);
        }
        | F_VALUE
        | variable
        | procedure_statement
        | '!' factor
        | sign factor
        ;

sign:
        '+'
        | '-'
        ;

relop:
        '>'
        | '>='
        | '<'
        | '<='
        | '=='
        | '!='
        ;

addop:
        '+'
        | '-'
        ;

multop:
        '*'
        | '/'
        ;

epsilon: '~' { printf("epsilon\n");}
        ;

num:
        I_VALUE
	{
		printf("%d",yyval*yyval);
		printf("\tFlex returned Int : %d\n",yylval);
	}
        ;

%%

#define SIZEOF_NODETYPE ((char *)&p->con - (char *)p)

nodeType *con(int value) {
	nodeType *p;

	/* Allocate node */
	if((p = malloc(sizeof(nodeType))) == NULL)
		yyerror("out of memory");

	/* Copy information */
	p->type = typeCon;
	p->con.value = value;

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


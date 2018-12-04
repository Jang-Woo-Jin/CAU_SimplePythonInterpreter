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
  char sIndex;          /* Symbol table index */
  nodeType *nPtr;       /* Node pointer */
}

%token MAINPROG VAR ARRAY OF FUNCTION PROCEDURE
%token BEG END IF THEN ELSE NOP WHILE RETURN PRINT
%token <sIndex> ID
%token INTEGER FLOAT
%token <i_value> I_VALUE
%token <f_value> F_VALUE
%token OPERATOR DELIMITER

%left '>=' '<=' '==' '!=' //'>' '<'
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS 
%nonassoc UPLUS


%type <nPtr> statement_list statement expression_list expression simple_expression term factor num
%type <nPtr> relop multop addop
%type <sIndex> identifier_list variable 
%%
program: 
        program MAINPROG ID ';' declarations subprogram_declaration compound_statement
        | ID program { /*printf("\tFlex returned Id : %s\n",$1);*/ }
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
        statement	{ ex($1); }
        | statement ';' statement_list
        ;

statement:
        variable '=' expression { $$ = opr('=', 2, id($1), $3); }
        | print_statement		{ ex($1); }
        | procedure_statement	{ ex($1); }
        | compound_statement	{ ex($1); }
        | IF expression THEN statement ELSE statement 	{ $$ = opr(IF, 3, $3, $5, $7);  }
        | WHILE '(' expression ')' statement			{ $$ = opr(WHILE, 2, $3, $5);   }
        | RETURN expression
        | NOP
        ;

print_statement:
        PRINT	{ ex($1); }
        | PRINT '(' expression ')'	{ $$ = opr(PRINT, 1, $2); }
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
        simple_expression { $$ = $1; }
        | simple_expression relop simple_expression  { $$ = opr($2,2,$1,$3); }
        ;

simple_expression:
        term { $$ = $1; }
        | term addop simple_expression { $$ = opr($2,2,$1,$3); }
        ;

term:
        factor 	{ $$ = $1; }
        | factor multop term { $$ = opr($2,2,$1,$3); }
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
						$$ = id($1);
						printf("\tFlex return ID :%s\n",$1);
					}
        | procedure_statement
        | '!' factor
        | sign factor
        ;

sign:
        UPLUS
        | UMINUS
        ;

relop:
        '>='	
        | '>'	
        | '<='	
        | '<'	
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


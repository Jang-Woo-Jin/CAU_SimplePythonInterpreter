%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include "ourFlex.tab.h"
%}

%token MAINPROG
%token VAR
%token ARRAY
%token OF
%token FUNCTION
%token PROCEDURE
%token BEGIN
%token END
%token IF
%token THEN
%token ELSE
%token NOP
%token WHILE
%token RETURN
%token PRINT
%token ID
%token INT
%token FLOAT
%token OPERATOR
%token DELIMITER

%left '+' '-'
%left '*' '/'

%%
term:
        factor
        | factor multop term
        ;

factor:
        INTEGER 
        | FLOAT
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
%%

void yyerror(const char *str){
	fprintf(stderr,"err : %s\n",str);
}

int yywrap(){
	return 1;
}
main(){
	yyparse();
}

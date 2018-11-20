%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include "myGrammar.tab.h"

void yyerror(const char *str){
	fprintf(stderr,"err : %s\n",str);
}

int yywrap(){
	return 1;
}
main(){
	yyparse();
}
%}

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
%token OPERATOR
%token DELIMITER
%token I_VALUE
%token F_VALUE

%left '+' '-'
%left '*' '/'

%%
program: 
        MAINPROG ID ';' declarations subprogram_declarations compund_statement
        |program epsilon
        | epsilon {printf("end");}
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
        subprogram_head declarations compund_statement
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

compund_statement:
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
        | compund_statement
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
        I_VALUE
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

epsilon: '~' 
        ;

num:
        I_VALUE
        ;
%%




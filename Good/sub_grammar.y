%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include "sub_grammar.tab.h"


%token INTEGER
%token FLOAT
%}


%left '+' '-'
%left '*' '/'

%%
term:
        factor
        | factor multop term 
	{
		if($2 == '*'){
			printf("*연산 실행");
				$$ = $1 * $3;
		}
		else{
			printf("/연산 실행");
			$$ = $1 / $3;
		}
	}
        ;

factor:
        INTEGER 	{$$=$1;}
        | FLOAT	{$$=$1;}
        | '!' factor	{$$=!$2;}
        | sign factor	
	{
		if($1 == '+'){
			printf("+연산 실행");	
			$$ = $2;
		}
		else{
			printf("-연산 실행");
			$$ = $2 * (-1);
		}
	}

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

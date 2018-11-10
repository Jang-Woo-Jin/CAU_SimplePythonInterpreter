%{
#include<stdio.h>
#include<string.h>
#include "ourFlex.tab.h"

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




%token ReservedWord
%token ID
%token Int
%token Float
%token Operator
%token Delimiter


%left '+' '-'
%left '*' '/'

%%

Identifies: /*empty*/
	| Identifies Identify
	;

Identify:
	ReservedWord
	{
		printf("\tFlex returned ReservedWord : %s\n",$1);
	}
	|
	ID
	{
		printf("\tFlex returned ID : %s\n",$1);
	}
	|
	Int
	{
		printf("\tFlex returned Int : %d\n",yylval);
	}
	|
	Float
	{
		printf("\tFlex returned Float : %f\n",yylval);
	}
	|
	Operator
	{
		printf("\tFlex returned Operator : %s\n",$1);
	}
	|
	Delimiter
	{
		printf("\tFlex returned Delimiter : %s\n",$1);
	}
	;
%{
#include<stdio.h>
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

%token ReservedWord ID Int Float Operator Delimiter

%%

Identifies: /*empty*/
	| Identifies Identify
	;

Identify:
	ReservedWord
	{
		printf("\tFlex returned ReservedWord\n");
	}
	|
	ID
	{
		printf("\tFlex returned ID\n");
	}
	|
	Int
	{
		printf("\tFlex returned Int\n");
	}
	|
	Float
	{
		printf("\tFlex returned Float\n");
	}
	|
	Operator
	{
		printf("\tFlex returned Operator\n");
	}
	|
	Delimiter
	{
		printf("\tFlex returned Delimiter\n");
	}
	;
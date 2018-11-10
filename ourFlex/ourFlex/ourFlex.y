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
		printf("\tFlex returned ReservedWord : %c\n",yylval);
	}
	|
	ID
	{
		printf("\tFlex returned ID : %c\n",yylval);
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
		printf("\tFlex returned Operator : %c\n",yylval);
	}
	|
	Delimiter
	{
		printf("\tFlex returned Delimiter : %c\n",yylval);
	}
	;
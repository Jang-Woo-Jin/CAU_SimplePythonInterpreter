%{
#include<stdio.h>
#include<string.h>
#include "test.tab.h"
%}


%union {
        float float_val;
        int int_val;
        char* string_val;
        char char_val;
}

%token<char*> ReservedWord
%token<char*> ID
%token<int> Int
%token<float> Float
%token<char> Operator
%token<char> Delimiter


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
		printf("\tFlex returned Int : %d\n",$1);
	}
	|
	Float
	{
		printf("\tFlex returned Float : %s\n",$1);
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



%option noyywrap

%{
#include <stdio.h>
#include <stdlib.h>
#include "test.h"
#include "test.tab.h"
%}

%%
"mainprog"			{ return MAINPROG; }
"var"				{ return VAR; }
"array"				{ return ARRAY; }
"of"				{ return OF; }
"function"			{ return FUNCTION; }
"procedure"			{ return PROCEDURE; }
"begin"				{ return BEG; }
"end"				{ return END; }
"if"				{ return IF; }
"then"				{ return THEN; }
"else"				{ return ELSE; }
"nop"				{ return NOP; }
"while"				{ return WHILE; }
"return"			{ return RETURN; }
"int"				{ return INTEGER; }
"float"				{ return FLOAT; }

"print"				{ yylval.fn = B_print; return PRINT; }

[a-zA-Z][a-zA-Z0-9]*	{
				   			yylval.s_value = lookup(yytext);
							return ID;		// ID
						}
[0-9]+				{ 
						yylval.f_value = atoi(yytext);
						return I_VALUE;		// Integer
					}	
[0-9]+"."[0-9]+		{	
						float temp;
						sscanf(yytext,"%f",&temp);
						yylval.f_value = temp;
						return F_VALUE;		// Float
					}

[-+*/!~]			{ return yytext[0]; }

[;.,=(){}:]|\[|\]		{ return yytext[0]; }
	
">" 				{ yylval.fn = 1; return CMP; }
"<" 				{ yylval.fn = 2; return CMP; }
"!=" 				{ yylval.fn = 3; return CMP; }
"==" 				{ yylval.fn = 4; return CMP; }
">=" 				{ yylval.fn = 5; return CMP; }
"<=" 				{ yylval.fn = 6; return CMP; }
				
[\n]*|\t|[ ][\t ]*			;// WhiteSpace
"/*"([^*]|\*+[^*/])*\*+"/"|"//".*|"#".*		;// WhiteSpace - Comment
%%

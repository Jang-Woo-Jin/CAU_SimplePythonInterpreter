%{
#include<stdio.h>
#include<string.h>
#include "myGrammar.tab.h"
%}

%%
"mainprog"			{return MAINPROG;}
"var"				{return VAR;}
"array"				{return ARRAY;}
"of"				{return OF;}
"function"			{return FUNCTION;}
"procedure"			{return PROCEDURE;}
"begin"				{return BEG;}
"end"				{return END;}
"if"				{return IF;}
"then"				{return THEN;}
"else"				{return ELSE;}
"nop"				{return NOP;}
"while"				{return WHILE;}
"return"			{return RETURN;}
"print"				{return PRINT;}
"int"				{return INTEGER;}
"float"				{return FLOAT;}

[a-zA-Z][a-zA-Z0-9]*		{
					yylval = (int)strdup(yytext);
					return ID;		// ID
				}
[0-9]+				{ 
					yylval = atoi(yytext);
					return INTEGER;		// Integer
				}	
[0-9]+"."[0-9]+			{	
					yylval = (int)strdup(yytext);
					return FLOAT;		// Float
				}
[-+*/<>!] 		{return *yytext;}
"<="|">="|"=="|"!="		{	
					return *yytext;
					//yylval = (int)strdup(yytext);
					//return OPERATOR;	// Operator
				}	
[;.,=():]		{return *yytext;}
"\["|"\]"		{	
					return *yytext;
					// yylval = (int)strdup(yytext);
					// return DELIMITER;	// Delimiter
				}
					
"~"			{return *yytext;}
[\n]*|\t|[ ][\t ]*				;// WhiteSpace
"/*"([^*]|\*+[^*/])*\*+"/"|"//".*|"#".*		;// WhiteSpace - Comment
%%
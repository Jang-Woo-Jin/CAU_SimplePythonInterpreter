%{
#include<stdio.h>
#include<string.h>
#include "sub_grammar.tab.h"
%}

%%

[0-9]+				{ 
					yylval = atoi(yytext);
					return Int;		// Integer
				}
[0-9]+"."[0-9]+			{	
					yylval = (int)strdup(yytext);
					return Float;		// Float
				}
[-+*/<>!]|<=|>=|==|!=		{	
					yylval = (int)strdup(yytext);
					return Operator;	// Operator
				}
[;.,=()]|\[|\]|:		{	
					yylval = (int)strdup(yytext);
					return Delimiter;	// Delimiter
				}
[\n]*|\t|[ \t]+					;// WhiteSpace
"/*"([^*]|\*+[^*/])*\*+"/"|"//".*|"#".*		;// WhiteSpace - Comment
%%
%{
#include<stdio.h>
#include<string.h>
#include "ourFlex.tab.h"
%}

%%
mainprog|var|array|of|function|procedure|begin|end|if|then|else|nop|while|return|print		{
													yylval = (int)strdup(yytext);
													return ReservedWord;	//Reserved Word
												}
[a-zA-Z][a-zA-Z0-9]*		{
					yylval = (int)strdup(yytext);
					return ID;		// ID
				}
[0-9]+				{ 
					yylval = atoi(yytext);
					return Int;		// Integer
				}
[0-9]+"."[0-9]+			{	
					yylval = (float)atof(yytext);
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
\n|\t|[ \t]+					;// WhiteSpace
"/*"([^*]|\*+[^*/])*\*+"/"|"//".*|"#".*		;// WhiteSpace - Comment
%%
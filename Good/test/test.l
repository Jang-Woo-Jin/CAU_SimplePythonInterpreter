%{
#include<stdio.h>
#include<string.h>
#include "test.tab.h"
%}

%%
mainprog|var|array|of|function|procedure|begin|end|if|then|else|nop|while|return|print		{
													yylval.string_val = strdup(yytext);
													return ReservedWord;	//Reserved Word
												}
[a-zA-Z][a-zA-Z0-9]*		{
					            yylval.string_val = strdup(yytext);
					            return ID;		// ID
				            }
[0-9]+				{ 
					    yylval.int_val = atoi(yytext);
					    return Int;		// Integer
				    }
[0-9]+"."[0-9]+			{	
					yylval.flaot_val = atof(yytext);
					return Float;		// Float
				}
[-+*/<>!]|<=|>=|==|!=		{	
					yylval.string_val = strdup(yytext);
					return Operator;	// Operator
				}
[;.,=()]|\[|\]|:		{	
					yylval.char_val = yytext;
					return Delimiter;	// Delimiter
				}
[\n]*|\t|[ \t]+					;// WhiteSpace
"/*"([^*]|\*+[^*/])*\*+"/"|"//".*|"#".*		;// WhiteSpace - Comment
%%
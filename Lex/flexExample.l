%{
#include<stdio.h>
#include "yaccExample.tab.h"
%}

%%
mainprog|var|array|of|function|procedure|begin|end|if|then|else|nop|while|return|print		{
																								yylval = *yytext;
																								return ReservedWord;	//Reserved Word
																							}
[a-zA-Z][a-zA-Z0-9]*		{
								yylval = *yytext;
								return ID;		// ID
							}
[0-9]+						{ 
								yylval = atoi(yytext);
								return int;		// Integer
							}
[0-9]+"."[0-9]+				{	
								yylval = atof(yytext);
								return float;		// Float
							}
[-+*/<>!]|<=|>=|==|!=		{	
								yylval = *yytext;
								return Operator;	// Operator
							}
[;.,=()]|\[|\]|:			{	
								yylval = *yytext;
								return Delimiter;	// Delimiter
							}
\n|\t|[ \t]+								;// WhiteSpace
"/*"([^*]|\*+[^*/])*\*+"/"|"//".*|"#".*		;// WhiteSpace - Comment
%%

%{
#include<stdio.h>
%}

%%
mainprog|var|array|of|function|procedure|begin|end|if|then|else|nop|while|return|print		printf("Reserved");	//Reserved Word
[a-zA-Z][a-zA-Z0-9]*		printf("ID");		// ID
[0-9]+				printf("Integer");	// Integer
[0-9]+.[0-9]+			printf("Float");	// Float
[-+*/<>!]|<=|>=|==|!=		printf("Operator");	// Operator	
[;.,=()]|\[|\]|:		printf("Delimiter");	// Delimiter
\n				printf("\n");		// Enter
\t				printf("\t");		// Tab
[ \t]+				printf(" ");		// Space bar
"/*"([^*]|\*+[^*/])*\*+"/"	printf("Comment like /**/");	//Comment
"//".*				printf("Comment like //");	//Comment
%%

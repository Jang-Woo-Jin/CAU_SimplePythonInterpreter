%{
#include<stdio.h>
%}

%%
mainprog|var|array|of|function|procedure|begin|end|if|then|else|nop|while|return|print		printf("Reserved\n");
[a-zA-Z][a-zA-Z0-9]*		printf("ID\n");
[0-9]+				printf("Integer\n");
[0-9]+.[0-9]+			printf("Float\n");
[-+*/<>!]|<=|>=|==|!=		printf("Operator\n");		
[;.,=()]|\[|\]|:		printf("Delimiter\n");
\n				printf("Enter\n");
\t				printf("Tab\n");
[ \t]+				printf("WhiteSpace\n");
"/*"([^*]|\*+[^*/])*\*+"/"	printf("Comment like /**/\n");
"//".*				printf("Comment like /\n");
%%

%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <stdarg.h>
  #include "test.h"

  int sym[26];
  FILE *yyin;
%}

%union {
    struct ast *a;
    float f_value;
    struct symbol *s_value; /* which symbol */
    struct symlist *s_list;
    int fn; /* which function */
}

%token MAINPROG VAR ARRAY OF FUNCTION PROCEDURE
%token BEG END IF THEN ELSE NOP WHILE RETURN 
%token <fn> PRINT
%token <s_value> ID GE LE EQ NE '<' '>' '+' '-' '*' '/' 
%token INTEGER FLOAT
%token <f_value> I_VALUE
%token <f_value> F_VALUE
%token OPERATOR DELIMITER


%type <a> compound_statement expression_list simple_expression expression statement_list statement variable term factor 

%left GE LE EQ NE //'>' '<'
%right '='
%left '+' '-'
%left '*' '/'
%nonassoc<fn> CMP
%nonassoc UMINUS 
%start program

%%

program:
       function                    { exit(0); }
        ;

function:
        function compound_statement  { eval($2); treefree($2); }
        | /* NULL */
        ;
compound_statement:
        BEG statement_list END { $$ = $2; }
        ;

statement_list:
         statement                      { $$ = $1;  }
         | statement ';' statement_list { $$ = newast('L',$1,$3); }
         ;

statement:
    expression                 	        	{ $$ = $1;              }
    | PRINT expression                 		{ $$ = newfunc($1, $2); }
    | variable '=' expression      			  { $$ = newasgn((struct symref*)$1, $3); }
    | WHILE '(' expression ')' statement              { $$ = newflow('W', $3, $5, NULL);  }
    | IF  expression THEN statement ELSE statement  { $$ = newflow('I', $2, $4, $6);      }
    ;

variable:
        ID	{ $$ = newref($1); }
        | ID '[' expression ']'
        ;

expression_list:
        expression  { $$ = $1; }
        | expression ';' expression_list    { $$ = newast('L',$1,$3);  }
        ;

expression:
        simple_expression   { $$ = $1; }
        | simple_expression CMP simple_expression   { $$ = newcmp($2, $1, $3);     }
        ;

simple_expression:
        term    { $$ = $1; }
        | term '+' simple_expression    { $$ = newast('+', $1, $3);     }
        | term '-' simple_expression    { $$ = newast('-', $1, $3);     }
        ;

term:
        factor    { $$ = $1; }
        | factor '*' term   { $$ = newast('*', $1, $3);   }
        | factor '/' term   { $$ = newast('/', $1, $3);   }
        ;

factor:
    I_VALUE                         { $$ = newnum($1); }
	  | F_VALUE							          { $$ = newnum($1); }
    | variable                      { $$ = $1; }
    | '-' expression %prec UMINUS   { $$ = newast('M', $2, NULL);  }
    | '!' factor                      { $$ = newast('!', $2, NULL);  }
    ;


%%

void yyerror(char *s) {
  fprintf(stderr, "%s\n", s);
}

//extern int yy_flex_debug;
int main(int argc, char *argv[]) {
  //yy_flex_debug = 1;
	if(argc > 1){
    	yyin = fopen(argv[1],"r");
		if(!yyin){
			perror(argv[1]);
			return 1;
		}    
	yyparse();
	fclose(yyin);
	}
  else{
    yyparse();
  }
	return 0;
}
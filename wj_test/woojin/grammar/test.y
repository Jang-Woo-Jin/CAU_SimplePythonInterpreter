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


%type <a> compound_statement procedure_statement actural_parameter_expression 
%type <a> print_statement expression_list simple_expression expression statement_list
%type <a> statement variable term factor declarations identifier_list type


%left GE LE EQ NE //'>' '<'
%right '='
%left '+' '-'
%left '*' '/'
%nonassoc<fn> CMP
%nonassoc UMINUS 
%start program

%%
program:
        pr    { exit(0); }                 
        ;

pr:
        pr declarations compound_statement  { eval($2); eval($3); treefree($2); treefree($3); }
        | /* NULL */ ;

declarations:
        VAR identifier_list ':' type ';' declarations { $$ = newidentifier((struct fixsymlist*)$2, $4, $6); }
        | epsilon       { $$ = newEpsilon(); }
        ;

identifier_list:
        ID      { $$ = newfixsymlist((struct symbol*)newref($1),NULL); }
        | ID ';' identifier_list   { $$ = newfixsymlist((struct symbol*)newref($1), $3); }
        ;

type:
        INTEGER                                 { $$ = typedivide(0,0,'I'); }
        | FLOAT                                 { $$ = typedivide(0,0,'F'); }
        | ARRAY '[' I_VALUE ']' OF INTEGER      { $$ = typedivide(1,$3,'I'); }
        | ARRAY '[' I_VALUE ']' OF FLOAT        { $$ = typedivide(1,$3,'F'); }
        ;


compound_statement:
        BEG statement_list END { $$ = $2; }
        ;

statement_list:
         statement                      { $$ = $1; }
         | statement ';' statement_list { $$ = newast('L',$1,$3); }
         ;

statement:
    expression                 	        	{ $$ = $1; }
    | print_statement    		        { $$ = $1; }
    | procedure_statement                  	{ $$ = $1; }
    | compound_statement                        { $$ = $1; }
    | variable '=' expression      	        { $$ = newasgn((struct symref*)$1, $3); printf("val->S : %d\n",((struct symref*)$1)->s) ;}
    | WHILE '(' expression ')' statement            { $$ = newflow('W', $3, $5, NULL);  }
    | IF  expression THEN statement ELSE statement  { $$ = newflow('I', $2, $4, $6);    }
    | NOP                                       { $$ = newast('X', NULL, NULL); }
    ;
print_statement:
    PRINT   { $$ = newfunc($1, NULL); }
    | PRINT expression    { $$ = newfunc($1, $2); printf("print exp->s : %d\n",((struct symref*)$2)->s);}
    ;

variable:
        ID	{ $$ = newref($1); }
        | ID '[' expression ']'
        ;
procedure_statement:
        ID '(' actural_parameter_expression ')'     { $$ = newcall($1, $3); }
        ;

actural_parameter_expression:
        epsilon
        | expression_list    { $$ = $1; }   
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
    | F_VALUE			    { $$ = newnum($1); }
    | variable                      { $$ = $1; }
    | '-' expression %prec UMINUS   { $$ = newast('M', $2, NULL);  }
    | '!' factor                    { $$ = newast('!', $2, NULL);  }
    ;
    
epsilon:
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
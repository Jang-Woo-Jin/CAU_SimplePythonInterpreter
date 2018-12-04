%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <stdarg.h>
  #include "myGrammar.h"

  /* Prototypes */
  nodeType *opr(int oper, int nops, ...);
  nodeType *id(int i);
  nodeType *intCon(int value);
  nodeType *floatCon(float value);

  void freeNode(nodeType *p);
  int ex(nodeType *p);
  int yylex(void);
  void yyerror(char *);

  int sym[26];
  FILE *yyin;
%}

%union {
  int i_value;     /* Integer value */
  float f_value;
  char c_value;    /* Symbol table index */
  char* s_value;
  nodeType *nPtr; /* Node pointer */
}


%token MAINPROG VAR ARRAY OF FUNCTION PROCEDURE
%token BEG END IF THEN ELSE NOP WHILE RETURN PRINT 
%token <c_value> ID GE LE EQ NE '<' '>' '+' '-' '*' '/'
%token INTEGER FLOAT
%token <i_value> I_VALUE
%token <f_value> F_VALUE
%token OPERATOR DELIMITER


%left GE LE EQ NE //'>' '<'
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS 
%nonassoc UPLUS


%type <nPtr> expression statement_list statement
%type <nPtr> variable
%type <c_value> relop addop multop

%%

program:
       function                    { exit(0); }
        ;

function:
        function statement_list    { ex($2); freeNode($2); }
        | /* NULL */
        ;

statement_list:
         statement                      { $$ = $1;                      }
         | statement ';' statement_list { $$ = opr(';', 2, $1, $3);     }
         ;

statement:
    expression                 	        	{ $$ = $1;                  }
    | PRINT expression                 		{ $$ = opr(PRINT, 1, $2);   }
    | variable '=' expression      			  { $$ = opr('=', 2, $1, $3); }
    | WHILE '(' expression ')' statement              { $$ = opr(WHILE, 2, $3, $5);   }
    | IF '(' expression ')' statement ELSE statement  { $$ = opr(IF, 3, $3, $5, $7);  }
    | '{' statement_list '}'                      		{ $$ = $2;                      }
    ;

variable:
        ID	{ $$ = id($1); }
        | ID '[' expression ']'
        ;

expression:
    I_VALUE                         { $$ = floatCon($1);             }
	  | F_VALUE							          { $$ = floatCon($1);           }
    | variable                 			{ $$ = $1;                     }
    | '-' expression %prec UMINUS   { $$ = opr(UMINUS, 1, $2);     }
    | expression relop expression   { $$ = opr($2, 2, $1, $3);     }
    | expression addop expression   { $$ = opr($2, 2, $1, $3);     }
    | expression multop expression  { $$ = opr($2, 2, $1, $3);     }
    | '(' expression ')'    	      { $$ = $2; }
    ;

relop:
        GE 		{ $$ = $1; }
        | '>'	{ $$ = $1; }
        | LE	{ $$ = $1; }
        | '<'	{ $$ = $1; }
        | EQ	{ $$ = $1; }
        | NE	{ $$ = $1; }
        ;

addop:
        '+'		{ $$ = $1; }
        | '-'	{ $$ = $1; }
        ;

multop:
        '*'		{ $$ = $1; }
        | '/'	{ $$ = $1; }
        ;
%%

#define SIZEOF_NODETYPE ((char *)&p->con - (char *)p)

nodeType *intCon(int value) {
  nodeType *p;

  /* Allocate node */
  if((p = malloc(sizeof(nodeType))) == NULL)
    yyerror("out of memory");

  /* Copy information */
  p->type = typeInt;
  p->intCon.value = value;

  return p;
}

nodeType *floatCon(float value) {
	nodeType *p;

	/* Allocate node */
	if((p = malloc(sizeof(nodeType))) == NULL)
		yyerror("out of memory");

	/* Copy information */
	p->type = typeFloat;
	p->floatCon.value = value;
	return p;
}

nodeType *id(int i) {
  nodeType *p;

  /* Allocate node */
  if((p = malloc(sizeof(nodeType))) == NULL)
    yyerror("out of memory");

  /* Copy information */
  p->type = typeId;
  p->id.i = i;

  return p;
}

nodeType *opr(int oper, int nops, ...) {
  va_list ap;
  nodeType *p;
  int i;

  /* Allocate node */
  if((p = malloc(sizeof(nodeType))) == NULL)
    yyerror("out of memory");
  if((p->opr.op = malloc(nops * sizeof(nodeType))) == NULL)
    yyerror("out of memory");

  /* Copy information */
  p->type = typeOpr;
  p->opr.oper = oper;
  p->opr.nops = nops;
  va_start(ap, nops);
  for(i = 0; i < nops; i++){
    p->opr.op[i] = va_arg(ap, nodeType*);
  }
  va_end(ap);

  return p;
}

void freeNode(nodeType *p) {
  int i;

  if(!p) return;

  if(p->type == typeOpr) {
    for(i = 0; i < p->opr.nops; i++)
      freeNode(p->opr.op[i]);
    free(p->opr.op);
  }
  free(p);
}

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
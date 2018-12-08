/*
 * Declarations for a calculator fb3-1
 */
/* interface to the lexer */
extern int yylineno; /* from lexer */

/* symbol table */
struct symbol { /* a variable name */
 char *name;
 float value;
 struct ast *type;
 struct ast *func; /* stmt for the function */
 struct symlist *syms; /* list of dummy args */
};

/* simple symtab of fixed size */
#define NHASH 9997
struct symbol symtab[NHASH];
struct symbol *lookup(char*);

/* list of symbols, for an argument list */
struct symlist {
 struct symbol *sym;
 struct symlist *next;
};

/* node types
 * + - * / |
 * 0-7 comparison ops, bit coded 04 equal, 02 less, 01 greater
 * M unary minus
 * L expression or statement list
 * I IF statement
 * W WHILE statement
 * N symbol ref
 * = assignment
 * S list of symbols
 * F built in function call
 * C user function call
 * X no operation
 */
enum bifs { /* built-in functions */
 B_print = 1,
};

/* nodes in the abstract syntax tree */
/* all have common initial nodetype */
struct ast {
 int nodetype;
 struct ast *l;
 struct ast *r;
 int type;
};

struct fncall { /* built-in function */
 int nodetype; /* type F */
 struct ast *l;
 enum bifs functype;
};

struct ufncall { /* user function */
 int nodetype; /* type C */
 struct ast *l; /* list of arguments */
 struct symbol *s;
};

struct flow {
 int nodetype; /* type I or W */
 struct ast *cond; /* condition */
 struct ast *tl; /* then branch or do list */
 struct ast *el; /* optional else branch */
};

struct numval {
 int nodetype; /* type K */
 float number;
};

struct symref {
 int nodetype; /* type N */
 struct symbol *s;
};

struct symasgn {
 int nodetype; /* type = */
 struct symbol *s;
 struct ast *v; /* value */
};
/////////////////////////////////////////////

struct typedivide {
    int nodetype; /* type T */
    int isarray;
    float number;
    int valuetype;
};
struct fixsymlist {
    int nodetype;
    struct symbol *sym;
    struct fixsymlist *next;
};

/* build an AST */
struct ast *newast(int nodetype, struct ast *l, struct ast *r);
struct ast *newcmp(int cmptype, struct ast *l, struct ast *r);
struct ast *newfunc(int functype, struct ast *l);
struct ast *newcall(struct symbol *s, struct ast *l);
struct ast *newref(struct symbol *s);
struct ast *newasgn(struct symref *l, struct ast *v);
struct ast *newnum(float d, int valuetype);
struct ast *newflow(int nodetype, struct ast *cond, struct ast *tl, struct ast *tr);
struct fixsymlist *newfixsymlist(struct symbol *sym, struct fixsymlist *next);
static float callbuiltin(struct fncall *);
static float calluser(struct ufncall *);
/* define a function */
void dodef(struct symbol *name, struct symlist *syms, struct ast *stmts);
/* evaluate an AST */
float eval(struct ast *);
/* delete and free an AST */
void treefree(struct ast *);
/* interface to the lexer */
extern int yylineno; /* from lexer */

////////////////////////////////////////////////////////
struct ast *typedivide(int isarray, float number, int type);
struct ast *newEpsilon();
struct ast *newidentifier(struct fixsymlist *idls, struct ast *type, struct ast *r);
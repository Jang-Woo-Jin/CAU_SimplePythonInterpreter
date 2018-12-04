typedef enum {
  typeInt,
  typeFloat,
  typeId,
  typeOpr
} nodeEnum;

/* Integer Constants */
typedef struct {
  int value;
} intNodeType;


/* Float Constants */
typedef struct {
  float value;
} floatNodeType;

/* Identifiers */
typedef struct {
  int i;
} idNodeType;

/* Operators */
typedef struct {
  int oper;                /* Operator */
  int nops;                /* Number of operants */
  struct nodeTypeTag **op; /* Operands */
} oprNodeType;

typedef struct nodeTypeTag {
  nodeEnum type;           /* Type of node */

  union {
    intNodeType intCon; /* Integer value */
    floatNodeType floatCon; /* Float value*/
    idNodeType  id;  /* Identifiers */
    oprNodeType opr; /* Operators */
  };
} nodeType;

extern int sym[26];
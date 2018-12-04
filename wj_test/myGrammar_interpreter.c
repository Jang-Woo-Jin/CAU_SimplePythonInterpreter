#include <stdio.h>
#include "myGrammar.h"
#include "myGrammar.tab.h"

int ex(nodeType *p) {
  int tmp;
  nodeType *op;

  if(!p)
    return 0;

  switch(p->type) {
    case typeInt:
      printf("typeint: %d\n",p);
      return p->intCon.value;

    case typeFloat:
      printf("typefloat: %d\n",p);
      return p->floatCon.value;

    case typeId:
      return sym[p->id.i];

    case typeOpr:
      switch(p->opr.oper) {
        case WHILE:
          while(ex(p->opr.op[0]))
            ex(p->opr.op[1]);
          return 0;

        case IF:
          if(ex(p->opr.op[0]))
            ex(p->opr.op[1]);
          else if(p->opr.nops> 2) 
            ex(p->opr.op[2]);
          return 0;

        case PRINT:
          op = ex(p->opr.op[0]);
          switch(op->type){
            case typeInt:
              printf("int : %4.4g\n", op->intCon.value);
              return 0;
            case typeFloat:
              printf("float : %4.4g\n", op->floatCon.value);
              return 0;
            default:
              printf("cannot find type\n");
              printf("%d\n", ex(op));
              return 0;
          }          
          return 0;

        case ';':
          ex(p->opr.op[0]);
          return ex(p->opr.op[1]);

        case '=':
          return sym[p->opr.op[0]->id.i] = p->opr.op[1]; //심볼테이블에 주소값을 저장

        case UMINUS:
          return -ex(p->opr.op[0]);

        case '+': return ex(p->opr.op[0]) +  ex(p->opr.op[1]);
        case '-': return ex(p->opr.op[0]) -  ex(p->opr.op[1]);
        case '*': return ex(p->opr.op[0]) *  ex(p->opr.op[1]);
        case '/': return ex(p->opr.op[0]) /  ex(p->opr.op[1]);
        case '<': return ex(p->opr.op[0]) <  ex(p->opr.op[1]);
        case '>': return ex(p->opr.op[0]) >  ex(p->opr.op[1]);
        case GE :  return ex(p->opr.op[0]) >= ex(p->opr.op[1]);
        case LE :  return ex(p->opr.op[0]) <= ex(p->opr.op[1]);
        case EQ :  return ex(p->opr.op[0]) == ex(p->opr.op[1]);
        case NE :  return ex(p->opr.op[0]) != ex(p->opr.op[1]);
      }
  }

  return 0;
}


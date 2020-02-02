grammar Mia;

/*
ignore
  : COMMENT | NEWLINE | INVALID
  ;
*/

file
  : module EOF
    //{ return $1; }
  ;

module
  : body
    //{ $$ = new yy.module($1); }
  ;

block
  : INDENT body? OUTDENT
  ;

body
  : (line TERMINATOR) +
  ;

commalist
  : expression
    //{$$ = [$1];}
  | commalist ',' expression
    //{$$ = $1; $1.push($3);}
  ;

exprlist
  : expression
    //{$$ = [$1];}
  | exprlist TERMINATOR expression
    //{$$ = $1; $1.push($3);}
  | exprlist TERMINATOR
  ;

line
  : statement | message
  ;

message
  : ('+' | '-' | '-+')? clause
  ;

statement
  : importStmt | defStmt | where | returnStmt
  ;

importStmt
  : IMPORT expression
    //{ $$ = new yy.importStmt($2); }
  ;
/*
trigger
  : parenExpr
    //{ $$ = new yy.trigger($1); }
  ;
*/
trigger
  : '(' message ')'
    //{ $$ = new yy.trigger($1); }
  ;

defStmt
  : DEF trigger block
    //{ $$ = new yy.defStmt($2, $3); }
  ;

condition
  : expression
    //{$$ = new yy.condition($1);}
  ;

where
  : WHERE lhs rhs
    //{$$ = new yy.Query($3, $4);}
  ;

lhs
  : INDENT (clause TERMINATOR)+ OUTDENT
  ;

rhs
  : action +
  ;

action
  : ('-->' | '!->' | '==>' | '!=>') block
  ;

/*
expression
  : paragraph | terminal | parenExpr | prefixExpr | postfixExpr | binaryExpr
  ;
*/
expression
  : terminal
  | prefixExpr
  ;

terminal
  : term | literal | snippet
  ;

verb
  : VERB
    //{ $$ = new yy.term($1); }
  ;

variableName
  : VARIABLE
  //{ $$ = $1.slice(1); }
;

variable
  : variableName
    //{ $$ = new yy.variable($1); }
  ;

term
  : variable | NOUN
    //{ $$ = new yy.term($1); }
  ;

subject
  : variable | NOUN
    //{ $$ = new yy.term($1); }
  ;

literal
  : STRING
    //{ $$ = new yy.literal($1); }
  ;

snippet
  : SNIPPET
    //{ $$ = new yy.snippet($1); }
  ;

paragraph
: sentence
  //{$$ = $1;}
| term INDENT exprlist OUTDENT
  //{$$ = new yy.paragraph($1, $3);}
;

sentence
  : clause
    //{$$ = $1;}
  | clause ',' commalist
    //{$$ = new yy.sentence($1, $3);}
  ;

clause
  : subject? verb expression? properties?
  ;

typeName
  : TYPE
  //{ $$ = $1.slice(0, -1); }
;

propertyName
  : PROPERTY
  //{ $$ = $1.slice(0, -1); }
;

property
  :
  propertyName
    //{ $$ = new yy.property($1); }
  | propertyName expression
    //{ $$ = new yy.property($1, $2); }
  ;

properties
  :
    property
    //{$$ = new yy.properties($1);}
  | properties property
    //{$$ = $1; $1.add($2);}
  ;

parenExpr
  : '(' expression? ')'
  ;

prefixExpr
  : typed | not
  ;

postfixExpr
  : achieve
  ;

typed
  : typeName expression
  //{ $2.type = $1 ; $$ = $2; }
  ;

not
  : NOT expression
  //{ $$ = new yy.unaryExpr($2, $1); }
  ;

propose
  : '*' expression
  //{ $$ = new yy.unaryExpr($2, $1); }
  ;

achieve
  : expression '!'
  //{ $$ = new yy.unaryExpr($2, $1); }
  ;

slash
  : '/' expression
  //{ $$ = new yy.unaryExpr($2, $1); }
  ;

binaryExpr
  : contextExpr | injectExpr | typeOfExpr | bindExpr | assignExpr | notEqualExpr
  ;

contextExpr
  : expression '<:' INDENT exprlist OUTDENT
    //{ $$ = new yy.binaryExpr($1, $4, $2); }
  ;

injectExpr
  : expression '<<:' expression
    //{ $$ = new yy.binaryExpr($1, $3, $2); }
  ;

typeOfExpr
  : expression '^' expression
    //{ $$ = new yy.binaryExpr($1, $3, $2); }
  ;

assignExpr
  : expression '=' expression
    //{ $$ = new yy.binaryExpr($1, $3, $2); }
  ;

bindExpr
  : expression '->' expression
    //{ $$ = new yy.binaryExpr($1, $3, $2); }
  ;

notEqualExpr
  : expression '!=' expression
    //{ $$ = new yy.binaryExpr($1, $3, $2); }
  ;

returnStmt
  : RETURN expression
    //{ $$ = new yy.returnStmt($2); }
  | RETURN
    //{ $$ = new yy.returnStmt(null); }
  ;

IMPORT: 'import';
DEF: 'def';
NOT: 'not';
RETURN: 'return';
//
WHERE: 'where';
LONGSKINNYARROW: '-->';
BANGARROW: '!->';
FATLONGARROW: '==>';
BANGFATARROW: '!=>';
//
ARROW: '->';
//
PLUS: '+';
MINUS: '-';
MINUSPLUS: '-+';
STAR: '*';
AT: '@';
SLASH: '/';
//
BANGEQ: '!=';
EQ: '=';
BANG: '!';
//
VARIABLE: '$' ID;
TYPE: NOUN ':' ;
PROPERTY: VERB ':' ;

//
LPAREN: '(';
RPAREN: ')';
COMMA: ',';
COLONCOLON: '::';
HAT: '^';
SEMICOLON: ';';
LEFTANGLECOLON: '<:';
LEFTANGLE2COLON: '<<:';
//
COMMENT: '#'.*? -> skip;
SNIPPET: '|'.*? ;

STRING: '"' ~ ["\r\n]* '"';

//NEWLINE: [\r?\n]+ ;
//WS: [\s \t]+ -> skip;
WS: [ \t]+ -> skip ;

DIGIT:   [0-9];
VERB:    [a-z]+[a-zA-Z0-9]*;
NOUN:    [A-Z]+[a-zA-Z0-9]*;
ID:      [a-zA-Z]+[a-zA-Z0-9]*;
TERMINATOR:      [\r?\n]+;

INDENT: TERMINATOR? '{' TERMINATOR? ;
OUTDENT: '}' TERMINATOR? ;

NUMBER: DIGIT+;

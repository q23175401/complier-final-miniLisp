%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
void yyerror(const char *);
void error(const char *) ;

int yylex();
int get_vsp(char *);
int set_fun_va(char *i,int position);
int get_fun_vsp(char *);

enum headTypes {
	plu_op, sub_op, mut_op, div_op, mod_op,
	and_op, or_op, not_op, equ_op,gre_op,sma_op, num_no, 
	var_no,nothing
};


typedef struct node{
	enum headTypes type;								//是算式還是變數還是數字的node
	char *name;											//是變數就記住他的名字
	int val;											//是數字就記住他的數字
	struct node *l;
	struct node *r;
}N;

typedef struct var{ 									//variable
	char* name;											//他的名字
	int val;											//他的值，如果是function的話就是代表他的parameter_position
	struct node *tree;
}V;

N *CreateNode(enum headTypes NodeType,int V,char *Name);//單純建造一個node，很單純
int EvalueTree(N *tree);								//把儲存的exp按照DFS算出他的值
void put_paramater(N *tree);							//把fun_exp內function所使用的變數，代換成對應的parameter
void clear_fun_position();								//用完這個function後，那個變數的parameter就不用記住了，清空

V va[300];												//儲存不同變數的值或exp
int vsp=-1;												//共有幾個變數

V fun_va[300];	  									    //儲存不同名字以及他在function的位置
int fun_vsp=0;	 									    //fun_va總共出現過幾次不同的name
int fun_position=0;									    //在fun_va存下的name對應在fun_ids的位子
int para[300]={0}; 										//儲存parameter的
int pa_position=0; 										//讓我可以按照順序儲存parameter的pointer
%}

%union{
    int num;
    char* id;
	struct node *nd;
}

%start prog
%token <num> NUMBER
%token <id> ID
%token PRINTNUM
%token PRINTBOOL
%token LAMBDA
%token IF
%token DEFINE
%token <num> BOOL

%type <nd> exp variable num_op logical_op fun_exp fun_call if_exp fun_body
%type <nd> exps_a exps_e exps_mu exps_o exps_p
%type <nd> and_op or_op not_op
%type <nd> test_exp then_exp else_exp
%type <nd> divide modulus greater smaller equal plus minus multiply
%type <num> param params fun_name

%%
prog: stmts             {;}
    ;
stmts
    :stmts stmt
    |stmt
    ;
stmt: exp                   {;}
    | def_stmt              {;}
    | print_stmt            {;}
	| error '+'				{error("'+'");}
	| error '-'				{error("'-'");}
	| error '*'				{error("'*'");}
	| error '/'				{error("'/'");}
	| error 'a'				{error("and");}
	| error 'o'				{error("or");}
	| error 'n'				{error("not");}
	| error '>'				{error("'>'");}
	| error '<'				{error("'<'");}
	| error '='				{error("'='");}
	| error ')'				{error("')'");}
	| error '('				{error("'('");}
	| error LAMBDA			{error("LAMBDA");}
	| error IF				{error("IF");}
	| error BOOL			{error("BOOL");}
	| error DEFINE			{error("DEFINE");}
	| error PRINTNUM		{error("PRINTNUM");}
	| error PRINTBOOL		{error("PRINTBOOL");}
	| error ID				{error("ID");}
    ;
    
print_stmt
    : '(' PRINTNUM exp ')' {printf("%d\n",EvalueTree($3));}
    | '(' PRINTBOOL exp ')'{
								int result=EvalueTree($3);
                                if(result==0)     printf("#f\n");
                                else if(result==1) printf("#t\n");
                            }
    ;
    
exp : BOOL                  {
								N *newNode=CreateNode(num_no,$1,"");
								$$=newNode;
							}
    | NUMBER                {
								N *newNode=CreateNode(num_no,$1,"");
								$$=newNode;
							}
    | variable              {$$=$1;}//單純把tree傳下去
    | num_op                {$$=$1;}//單純把tree傳下去
    | logical_op            {$$=$1;}//單純把tree傳下去
    | fun_exp               {$$=$1;}//單純把tree傳下去
    | fun_call              {$$=$1;}//單純把tree傳下去
    | if_exp                {$$=$1;}//單純把tree傳下去
    ;
    
num_op
    : plus                  {$$=$1;}//單純把tree傳下去
    | minus                 {$$=$1;}//單純把tree傳下去
    | multiply              {$$=$1;}//單純把tree傳下去
    | divide                {$$=$1;}//單純把tree傳下去
    | modulus               {$$=$1;}//單純把tree傳下去
    | greater               {$$=$1;}//單純把tree傳下去
    | smaller               {$$=$1;}//單純把tree傳下去
    | equal                 {$$=$1;}//單純把tree傳下去
    ;
    plus: '(' '+' exp exps_p ')'   {
										
										//建立一個NODE以 +為頭
										N *newNode=CreateNode(plu_op,0,"");
										
										//l=exp 的 node r=exps 的 node
										newNode->l=$3;
										newNode->r=$4;
										
										//把這個 node 傳下去
										$$=newNode;
									}
		|'(' '+' ')' 				{printf("Need 2 arguments, but got 0.  \n");exit(1);}
		|'(' '+' exp ')'			{printf("Need 2 arguments, but got 1.  \n");exit(1);}
        ;
        exps_p
            : exp                   {$$=$1;}
            | exps_p exp            {
										N *newNode=CreateNode(plu_op,0,"");
										newNode->l=$1;
										newNode->r=$2;
										$$=newNode;
									}
            ;
    minus
        : '(' '-' exp exp ')'       {
										N *newNode=CreateNode(sub_op,0,"");
										newNode->l=$3;
										newNode->r=$4;
										$$=newNode;
									}
		|'(' '-' ')' 				{printf("Need 2 arguments, but got 0.  \n");exit(1);}
		|'(' '-' exp ')'			{printf("Need 2 arguments, but got 1.  \n");exit(1);}
        ;
    multiply
        : '(' '*' exp exps_mu ')'   {
										N *newNode=CreateNode(mut_op,0,"");
										newNode->l=$3;
										newNode->r=$4;
										$$=newNode;
									}
		|'(' '*' ')' 				{printf("Need 2 arguments, but got 0.  \n");exit(1);}
		|'(' '*' exp ')'			{printf("Need 2 arguments, but got 1.  \n");exit(1);}
        ;
        exps_mu
            : exp                   {$$=$1;}
            | exps_mu exp           {
										N *newNode=CreateNode(mut_op,0,"");
										newNode->l=$1;
										newNode->r=$2;
										$$=newNode;
									}
            ;
    divide
        : '(' '/' exp exp ')'       {
										N *newNode=CreateNode(div_op,0,"");
										newNode->l=$3;
										newNode->r=$4;
										$$=newNode;
									}
		|'(' '/' ')' 				{printf("Need 2 arguments, but got 0.  \n");exit(1);}
		|'(' '/' exp ')'			{printf("Need 2 arguments, but got 1.  \n");exit(1);}
        ;
    modulus
        : '(' 'm' exp exp ')'       {
										N *newNode=CreateNode(mod_op,0,"");
										newNode->l=$3;
										newNode->r=$4;
										$$=newNode;
									}
		|'(' 'm' ')' 				{printf("Need 2 arguments, but got 0.  \n");exit(1);}
		|'(' 'm' exp ')'			{printf("Need 2 arguments, but got 1.  \n");exit(1);}
        ;
    greater
        : '(' '>' exp exp ')'       {
										N *newNode=CreateNode(gre_op,0,"");
										newNode->l=$3;
										newNode->r=$4;
										$$=newNode;
									}
		|'(' '>' ')'				{printf("Need 2 arguments, but got 0.  \n");exit(1);}
		|'(' '>' exp ')'			{printf("Need 2 arguments, but got 1.  \n");exit(1);}
        ;
    smaller
        : '(' '<' exp exp ')'       {
										N *newNode=CreateNode(sma_op,0,"");
										newNode->l=$3;
										newNode->r=$4;
										$$=newNode;
									}
		|'(' '<' ')' 				{printf("Need 2 arguments, but got 0.  \n");exit(1);}
		|'(' '<' exp ')'			{printf("Need 2 arguments, but got 1.  \n");exit(1);}
        ;
    equal
        : '(' '=' exp exps_e ')'    {
										N *newNode=CreateNode(equ_op,0,"");
										newNode->l=$3;
										newNode->r=$4;
										$$=newNode;
									}
		|'(' '=' ')' 				{printf("Need 2 arguments, but got 0.  \n");exit(1);}
		|'(' '=' exp ')'			{printf("Need 2 arguments, but got 1.  \n");exit(1);}
        ;
        exps_e
            : exp                   {$$=$1;}
            | exps_e exp            {
										N *newNode=CreateNode(equ_op,0,"");
										newNode->l=$1;
										newNode->r=$2;
										$$=newNode;
									}
            ;
    
logical_op
    : and_op                        {$$=$1;}//單純把tree傳下去
    | or_op                         {$$=$1;}//單純把tree傳下去
    | not_op                        {$$=$1;}//單純把tree傳下去
    ;
    and_op
        : '(' 'a' exp exps_a ')'    {
										N *newNode=CreateNode(and_op,0,"");
										newNode->l=$3;
										newNode->r=$4;
										$$=newNode;
									}
		|'(' 'a' ')' 				{printf("Need 2 arguments, but got 0.  \n");exit(1);}
		|'(' 'a' exp ')'			{printf("Need 2 arguments, but got 1.  \n");exit(1);}
        ;
        exps_a
            : exp                   {$$=$1;}
            | exps_a exp            {
										N *newNode=CreateNode(and_op,0,"");
										newNode->l=$1;
										newNode->r=$2;
										$$=newNode;
									}
            ;
        
    or_op
        : '(' 'o' exp exps_o ')'    {
										N *newNode=CreateNode(or_op,0,"");
										newNode->l=$3;
										newNode->r=$4;
										$$=newNode;
									}
		|'(' 'o' ')' 				{printf("Need 2 arguments, but got 0.  \n");exit(1);}
		|'(' 'o' exp ')'			{printf("Need 2 arguments, but got 1.  \n");exit(1);}
        ;
        exps_o
            : exp                   {$$=$1;}
            | exps_o exp            {
										N *newNode=CreateNode(or_op,0,"");
										newNode->l=$1;
										newNode->r=$2;
										$$=newNode;
									}
            ;
        
    not_op
        : '(' 'n' exp ')'           {
										N *newNode=CreateNode(not_op,0,"");
										newNode->l=$3;
										$$=newNode;
									}
		|'(' 'n' ')' 				{printf("Need 1 arguments, but got 0.  \n");exit(1);}
        ;

def_stmt
    : '(' DEFINE variable exp')'        {
											va[get_vsp($3->name)].val=EvalueTree($4); //把tree的值算出來放到這個變數內
											va[get_vsp($3->name)].tree=$4; 			  //把tree儲存下來作為之後name function使用
										}
	;
    
variable
    : ID                                {
											int sp=get_vsp($1); 
											if(sp==-1){						// 還沒有這個ID的變數，就給這個ID一個位子
												vsp++;
												va[vsp].name=$1;
												va[vsp].val=0;
											}
											N *newNode=CreateNode(var_no,0,$1);  //創建一個variable的node
											$$=newNode;
										}
    ;
    
fun_exp
    : '(' LAMBDA fun_ids fun_body ')'   {$$=$4;}//單純把tree傳下去
    ;
    
fun_ids
    :'('')'                             {;}
    |'(' ids ')'                        {;}
    ;
    ids : ID                            {
											fun_position++;
											set_fun_va($1,fun_position);//幫這些ID設一個FUN_VA的位子，並記錄他在ids的位子
											//printf("1個的%d\n",fun_position);
										} 
											
        | ids ID                        {
											fun_position++;
											set_fun_va($2,fun_position);//幫這些ID設一個FUN_VA的位子，並記錄他在ids的位子
											//printf("很多個的%d\n",fun_position);
										} 
        ;
fun_body
    : exp                               {$$=$1;}//單純把tree傳下去
    ;
fun_call
    : '(' fun_exp')'                    {$$=$2;}
    | '(' fun_exp params ')'            {//把EXP內的VARIBLE改掉成對應的parameter的數字
											put_paramater($2);
											$$=$2;
											clear_fun_position();
											pa_position=0;
											fun_position=0;
										;
										}
    | '(' fun_name')'                   {$$=va[$2].tree;}
    | '(' fun_name params ')'           {
											put_paramater(va[$2].tree);
											$$=va[$2].tree;
											clear_fun_position();
											pa_position=0;
											fun_position=0;
										}
    ;
    params
        :param                          {
											pa_position++;
											para[pa_position]=$1;
											$$=pa_position;
											//printf("1個的pa%d\n",pa_position);
										}
		|params param                   {
											pa_position++;
											para[pa_position]=$2;
											$$=pa_position;
											//printf("很多個的pa%d\n",pa_position);
										}
        ;
        param
				: exp                       {$$=EvalueTree($1);}
            ;
			
fun_name
    : variable                              {$$=get_vsp($1->name);}
    ;



if_exp
    : '(' IF test_exp then_exp else_exp ')'  {
												if(EvalueTree($3)==0){
													$$=$5;
													}
												else if(EvalueTree($3)==1){
													$$=$4;
												}
											 }
    ;

test_exp
    : exp                       {$$=$1;}//單純把tree傳下去
    ;
then_exp
    : exp                       {$$=$1;}//單純把tree傳下去
    ;
else_exp
    : exp                       {$$=$1;}//單純把tree傳下去
    ;


%%

void yyerror(const char *message) {
	//printf("syntax error, unexpected %s\n",message);
}
void error(const char *message) {
	printf("syntax error, unexpected %s\n",message);
	exit(1);
}

int get_vsp(char *n){
	for(int i=0;i<=vsp;i++){
		if(strcmp(n,va[i].name)==0){return i;}
	}
	return -1;
}

int set_fun_va(char *i,int position){
	int sp=get_fun_vsp(i);
	if(sp==0){
		fun_vsp++;
		fun_va[fun_vsp].name=i;
		fun_va[fun_vsp].val=position;
		//printf("在%d放PO%d\n",fun_vsp,fun_position);
		return fun_vsp;
	}else{
		fun_va[sp].val=position;
		return sp;
	}
}

int get_fun_vsp(char *n){
	for(int i=1;i<=fun_vsp;i++){
		if(strcmp(n,fun_va[i].name)==0){return i;}
	}
	return 0;
}

void put_paramater(N *tree){
	if(tree!=NULL){
		if(tree->type==var_no&&fun_va[get_fun_vsp(tree->name)].val!=0){ //是VARI的點又是funtion中的變數，就把它變成num_no的點，再換上他的數字
			//printf("%s position:%d\n",tree->name,fun_va[get_fun_vsp(tree->name)].val);
			tree->type=num_no;
			tree->val=para[fun_va[get_fun_vsp(tree->name)].val];
		}
		put_paramater(tree->l);
		put_paramater(tree->r);
	}
}

void clear_fun_position(){
	for(int i=1;i<=fun_vsp;i++){
		fun_va[i].val=0;
	}
}

N *CreateNode(enum headTypes NodeType,int V,char *Name){
    N *NewNode=(N *)malloc(sizeof(N));
	NewNode->type=NodeType;
	NewNode->val=V;
	NewNode->name=Name;
	NewNode->l=NULL;
	NewNode->r=NULL;
	return NewNode;
}

int EvalueTree(N *tree){
	if(tree==NULL){return 0;}
	if(tree->type<=10 && tree->type>=0 ){ //如果這是一個算式的node ，就算出來傳回去
		int left=0,right=0;
		left=EvalueTree(tree->l);
		right=EvalueTree(tree->r);

		switch(tree->type){				 //算出來
		case plu_op:	
			return left+right;
		break;
		case sub_op:    
			return left-right;
		break;
		case mut_op:    
			return left*right;
		break;
		case div_op:    
			return left/right;
		break;
		case mod_op:    
			return left % right;
		break;
		case and_op:    
			return left&&right;
		break;
		case or_op:    
			return left||right;
		break;
		case not_op:
			//printf("%d after not %d\n",left,!left);
			return !left;
		break;
		case equ_op:    
			return left==right;
		break;
		case gre_op:    
			return left>right;
		break;
		case sma_op:    
			return left<right;
		break;
		default:
			return 0;
		break;
		}
	}
	else{								//如果這是 number or variable 的 node
		int sp=-1;
		switch(tree->type){
		case num_no:					//是number，就直接傳回去
			return tree->val;
		break;
		case var_no:    				//是variable，去找他的值傳會去
			sp=get_vsp(tree->name);
			return va[sp].val;
		break;
		default:
			return 0;
		break;
		}
	}


}

int main (){
fun_va[0].val=0; //初始化fun_va[0].val作為沒有被標示的標準

yyparse();
return 0;
}


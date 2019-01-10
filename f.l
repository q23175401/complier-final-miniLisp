%{
#include "y.tab.h"
#include<stdio.h>
#include<stdlib.h>
#include<string.h>

%}

letter [a-z]
digit  [0-9]
%%
0|[1-9]{digit}*|-[1-9]{digit}*                      {yylval.num=atoi(yytext);return NUMBER;}
(\#t)                                               {yylval.num=1; return BOOL;}
(\#f)                                               {yylval.num=0; return BOOL;}
"define"                                            {return DEFINE;}
"lambda"                                            {return LAMBDA;}
"if"                                                {return IF;}
"print-num"                                         {return PRINTNUM;}
"print-bool"                                        {return PRINTBOOL;}
"mod"                                               {return yytext[0];}
"and"                                               {return yytext[0];}
"or"                                                {return yytext[0];}
"not"                                               {return yytext[0];}
{letter}({letter}|{digit}|\-)*                       {
														char *tem=(char*)malloc(strlen(yytext));
														for(int i=0;i<strlen(yytext);i++){
															tem[i]=yytext[i];
														}
														yylval.id=tem;
														return ID;
													}
[\+\-\*\/\(\)\>\<\=]                                {return yytext[0];}
[\t\n\r ]                                           {;}
.                                                   {printf("Unexpected Character! %s\n",yytext); exit(1);}
%%
int yywrap(void){
return 1;
}

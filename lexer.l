%option noyywrap

%{

    #include "parser.tab.h"
    #include<string.h>

%}

%%

print                   {return PRINT;}
[a-zA-Z][a-zA-Z0-9_]*   {
                            yylval.ime=strdup(yytext);
                            if(yylval.ime==NULL){
                                fprintf(stderr,"Neuspela alokacija");
                                exit(EXIT_FAILURE);
                            }
                            return ID;
                        }
[0-9]+(\.[0-9]*)?       {
                            yylval.v=atof(yytext);
                            return BROJ;
                        }
"=="                    {return EQ;}
"!="                    {return NEQ;}
">="                    {return GEQ;}
"<="                    {return LEQ;}
[+/*()<>;=-]             {return *yytext;}
[ \t\n]                 { } 
.                       {
                            fprintf(stderr,"Leksicka Greska: %s\n",yytext);
                            exit(EXIT_FAILURE);
                        }
%%
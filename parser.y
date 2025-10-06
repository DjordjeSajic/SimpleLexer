%{
    #include<stdio.h>
    #include<stdlib.h>
    #include<string.h>

    extern int yylex();

    void yyerror(char *s){
        fprintf(stderr,"Sintaksna greska: %s\n",s);
        exit(EXIT_FAILURE);
    }
#define INIT_CAPACITY (32)
#define STEP          (2)

typedef struct{
    char* ime;
    float v;

}prom_t;

prom_t* promenjive=NULL;
int capacity;
int n;

void alociraj(){
    capacity=INIT_CAPACITY;
    n=0;
    promenjive=malloc(capacity*sizeof(prom_t));
    if(promenjive==NULL){
        yyerror("Alokacija");
    }
}

void dealociraj(){
    int i=0;
    for(int i=0;i<n;i++){
        free(promenjive[i].ime);
    }
    free(promenjive);
}

int pronadji(char *s){
    for(int i=0;i<n;i++){
        if(strcmp(s,promenjive[i].ime)==0){
            return i;
        }
    }

    return -1;
}

%}

%union{
    int k;
    float v;
    char* ime;
}

%left '+' '-'
%left '*' '/'
%right UMINUS

%token ID PRINT GEQ NEQ EQ LEQ
%token<v> BROJ
%token<ime> ID
%type<k> logicka_naredba
%type<v> izraz


%start program

%%

program: program naredba    { }
        | naredba           { }
        ;
naredba: ID '=' izraz ';'  { 
                            int retVal=pronadji($1);
                            if (retVal!=-1){
                                promenjive[retVal].v=$3;
                            }else{
                                promenjive[n].ime=strdup($1);
                                if(promenjive[n].ime==NULL){
                                    yyerror("Alokacija nije moguca");
                                }
                                promenjive[n].v=$3;
                                n++;
                                if(n==capacity){
                                    capacity*=STEP;
                                    promenjive=realloc(promenjive,capacity*sizeof(prom_t));
                                    if(promenjive==NULL){
                                        yyerror("Alokacija nije moguca");
                                    }
                                }
                            }

                            free($1);
                           }
        | PRINT '(' izraz ')' ';' {printf("vrednosti izraza: %0.2f\n",$3);}
        | logicka_naredba ';' {printf("%s\n", $1==1? "True" : "False"); }
        ;
izraz: izraz '+' izraz   {$$=$1+$3; }
    | izraz '-' izraz   {$$=$1-$3; }
    | izraz '*' izraz   {$$=$1*$3; }
    | izraz '/' izraz    {$$=$1/$3; }
    | '-' izraz %prec UMINUS      {$$ = -$2; }
    | '(' izraz ')'     { $$ = $2; }
    | BROJ                { $$ = $1; }
    | ID                  { 
                            int retVal=pronadji($1);
                            if(retVal==-1){
                                yyerror("Promenjiva nije definisana");
                            }
                            $$=promenjive[retVal].v;

                            free($1);
                          }
    ;

logicka_naredba: izraz '<' izraz {$$ = $1<$3? 1: 0; }
        | izraz '>' izraz        {$$ = $1>$3? 1 : 0; }
        | izraz GEQ izraz        {$$ = $1>=$3? 1 : 0;}
        | izraz LEQ izraz        {$$ = $1<=$3? 1 : 0; }
        | izraz EQ izraz         {$$ = $1==$3? 1 : 0; }
        | izraz NEQ izraz        {$$ = $1!=$3? 1 : 0; }
        ;
%%

int main(){

    alociraj();
 

    if(yyparse()==0){
        printf("Sve OK\n");
    }
    else{
        printf("Sintaksna greska\n");
    }
    

    dealociraj();


    exit(EXIT_SUCCESS);
}
%{

//declarations


#define TKCOMMENT       7
#define TKINCLUDE       22
#define TKKEYWORD       20
#define TKSCANF         31
#define TKPRINTF        32
#define TKLOOP          34
#define TKCONDITION     35
#define TKFUNC          33
#define TKVAR           44
#define TKLITERAL       55
#define TKVAL           59
#define TKUNMATCHED     255

%}

INCLUDE_DIRECTIVE       (#include[ \t]*<.*>)
COMMENT                 (\/\/.*)|(\/\*([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*+\/)
KEYWORD                 (int|char|short|long|bool|void)[ \t]*\*?
PRINTF                  (printf\()
SCANF                   (scanf\()
LOOP                    (for|while)[ \t]*\(
CONDITION               (if|else\ if)[ \t]*\(|else\s*
FUNC                    ([a-zA-Z_][a-zA-Z0-9_]*[ \t]*\()
LITERAL                 (\".*\"|\'.*\')
VAR                     [a-zA-Z_][a-zA-Z0-9_]*
VAL                     [0-9]+(\.[0-9]*)?



%%

{INCLUDE_DIRECTIVE}                 { return TKINCLUDE;     }
{COMMENT}						    { return TKCOMMENT;     }
{KEYWORD}                           { return TKKEYWORD;     }
{PRINTF}                            { return TKPRINTF;      }
{SCANF}                             { return TKSCANF;       }
{LOOP}                              { return TKLOOP;        }
{CONDITION}                         { return TKCONDITION;   }
{FUNC}                              { return TKFUNC;        }
{VAR}                               { return TKVAR;         }
{VAL}                               { return TKVAL;         }
{LITERAL}                           { return TKLITERAL;     }


\n      { ++yylineno; return '\n'; }


[ \t\n\f]					{ }

.							{ 	//unmatched
								return TKUNMATCHED;
							}



%%

int yywrap(){
	return 1;
}

int main(int argc, char *argv[]) {
    FILE *file;

    if (argc < 2) {
        printf("Please provide a file to scan.\n");
        return 1;
    }

    file = fopen(argv[1], "r"); // corrected here
    if (!file) {
        printf("Cannot open file: %s\n", argv[1]); // corrected here
        return 1;
    }

    yyin = file;

    freopen("tokens.txt", "w", stdout); // corrected here

    int token = 0;
    int opcount = 0;
    int last_lineno = 0;
    while((token = yylex()) != 0){
        if (yylineno != last_lineno) {
            printf("\n");  // print newline when line number changes
            last_lineno = yylineno;
        }
        switch (token) {
            case TKINCLUDE:
                printf("%s", yytext);
                break;
            case TKCOMMENT:
                //printf("COMMENT");
                break;
            case TKKEYWORD:
                printf("%s", yytext);
                break;
            case TKPRINTF:
                printf("%s", yytext);
                break;
            case TKSCANF:
                printf("scanf(");
                break;
            case TKLOOP:
                printf("%s", yytext);
                break;
            case TKCONDITION:
                printf("%s", yytext);
                break;
            case TKFUNC:
                printf("FUNC(");
                break;
            case TKLITERAL:
                printf("LITERAL");
                break;
            case TKVAR:
                printf("VAR");
                break;
            case TKVAL:
                printf("VAL", yytext);
                break;
            case TKUNMATCHED:
                printf("%s", yytext);
                break;
            default:
                break;
        }
    }
    printf("\n");  // print final newline
    fclose(file);
    return 0;
}
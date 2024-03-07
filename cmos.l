%{

//declarations


#define TKINCLUDE       101
#define TKCOMMENT       100
#define TKPUNC          102

#define TKNUMBER        202
#define TKCHAR          211
#define TKBOOL          220
#define TKKEYWORD       200

#define TKASSIGN        300
#define TKCHGASSIGN     301
#define TKARITH         302
#define TKLOGIC         303
#define TKRELATIONAL    304

#define TKLITERAL       402
#define TKVAL           403
#define TKVARPTR        401
#define TKVAR           400

#define TKSCANF         501
#define TKPRINTF        502
#define TKMAIN          503
#define TKLOOP          504
#define TKCONDITION     505
#define TKFUNC          500


#define TKUNMATCHED     999

%}

INCLUDE_DIRECTIVE       (#include[ \t]*<.*>)
COMMENT                 (\/\/.*)|(\/\*([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*+\/)
PUNC                    ;|,|\{|\}

NUMBER                  (((short|long)[ \t]*)?(int|long|short|size_t|float|double))
CHAR                    (char)
BOOL                    (bool)
KEYWORD                 (void)

ASSIGN                  (=)
CHGASSIGN               (\+=|-=|\/=|\*=|\%=|\+\+|--)
ARITH                   (\+|-|\*|\/|%)
LOGIC                   (\|\|)|(&&)
RELATIONAL              (!=|==|<|>|<=|>=)

LITERAL                 (\"[^\"]*\"|\'[^\']*\')\)?
VAL                     [0-9]+(\.[0-9]*)?\)?
VARPTR                  (\*|&)[ \t]*[a-zA-Z_][a-zA-Z0-9_]*\)?
VAR                     [a-zA-Z_][a-zA-Z0-9_]*\)?

PRINTF                  (printf\()
SCANF                   (scanf\()
LOOP                    (for|while)[ \t]*\(|(do)\s*\{
CONDITION               (if|else\ if)[ \t]*\(|else\s*
MAIN                    (int[ \t]*main)[ \t]*\(
FUNC                    ([a-zA-Z_][a-zA-Z0-9_]*[ \t]*\()


%%

{INCLUDE_DIRECTIVE}                 { return TKINCLUDE;     }
{COMMENT}						    { return TKCOMMENT;     }
{PUNC}                              { return TKPUNC;        }

{NUMBER}                            { return TKNUMBER;      }
{CHAR}                              { return TKCHAR;        }
{BOOL}                              { return TKBOOL;        }
{KEYWORD}                           { return TKKEYWORD;     }

{ASSIGN}                            { return TKASSIGN;      }
{CHGASSIGN}                         { return TKCHGASSIGN;   }
{ARITH}                             { return TKARITH;       }      
{LOGIC}                             { return TKLOGIC;       }      
{RELATIONAL}                        { return TKRELATIONAL;  } 

{LITERAL}                           { return TKLITERAL;     }
{VAL}                               { return TKVAL;         }
{VARPTR}                            { return TKVARPTR;      }
{VAR}                               { return TKVAR;         }

{PRINTF}                            { return TKPRINTF;      }
{SCANF}                             { return TKSCANF;       }
{LOOP}                              { return TKLOOP;        }
{CONDITION}                         { return TKCONDITION;   }
{MAIN}                              { return TKMAIN;        }
{FUNC}                              { return TKFUNC;        }



[ \t\n\f\r]					{ }

.							{ 	//unmatched
								return TKUNMATCHED;
							}



%%

int yywrap(){
	return 1;
}

int main(int argc, char *argv[]) {
    FILE *file;
    int debug = 0;

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
    while((token = yylex()) != 0)
    {
        if(token > 199)
        {
            printf("%d ", token);
        }
    }
    printf("\n");  // print final newline
    fclose(file);
    return 0;
}
#include <stdio.h>
#include <strings.h>
#define MAXOPEN 8
#define MAXSTR 256 /* includes the null - max data is 255!!! */

static short nfiles = 0; /* how many filenames we know about */
static char *fnames[MAXOPEN]; /* ->saved filename strings for compares */
static FILE *files[MAXOPEN]; /* saved fileptrs for open files */

static short retcode = 100; /* return code with initial value */
/* =======================================================================
This function performs a 4gl "popquote" or argument fetch.
*/
void getquote(str,len)
	char *str; /* place to put the string */
	int len; /* length of string expected */
{
	register char *p;
	register int n;
	popquote(str,len);
	for( p = str, n = len-1 ; (n >= 0) && (p[n] <= ' '); --n );
	p[n+1] = '\0';
}
/* =======================================================================
 This function returns the last retcode, using 4GL conventions.
*/
int fglgetret(numargs)
int numargs; /* number of parameters (ignored) */
{
	retshort(retcode);
	return(1); /* number of values pushed */
}

int fglgets(numargs)
int numargs;
{
    register int ret; /* running success flag --> sqlcode */
    register int j; /* misc index */
    register char *ptr; /* misc ptr to string space */
    FILE* afile; /* selected file */
    char astring[MAXSTR]; /* scratch string space */
    astring[0] = '\0'; /* default parameter is null string */
    ret = 0; /* default result is whoopee */
    afile = stdin; /* default file is stdin */
    switch (numargs)
    {
        case 1: /* one parameter, pop as string */
        getquote(astring,MAXSTR);
        case 0: /* no parameters, ok, astring is null */
        break;
        default: /* too many parameters, clear stack */
        for( j = numargs; j; --j)
        popquote(astring,MAXSTR);
        ret = -4;
    }
    if ( (ret == 0) /* parameters ok and.. */
    && (astring[0])/* ..non-blank string passed.. */
    && (strcmp(astring,"stdin")) )/* ..but not "stdin".. */
    { /* ..look for string in our list */
        for ( j = nfiles-1; (j >= 0) && (strcmp(astring,fnames[j])); --j );
        if (j >= 0) /* it was there (strcmp returned 0) */
            afile = files[j];
        else /* it was not; try to open it */
        {
            if ((j = nfiles) < MAXOPEN)
            { /* not too many files, try fopen */
                afile = fopen(astring,"r");
                if (afile == NULL)
                    ret = -1;
            }
            else ret = -2;
            if (ret == 0)/* fopen worked, get space for name */
            {
                ptr = (char *)malloc(1+strlen(astring));
                if (ptr == NULL) ret = -3;
            }
            if (ret == 0)/* have space, copy name & save */
            {
                files[j] = afile;
                fnames[j] = ptr;
                strcpy(ptr,astring);
                ++nfiles;
            }
        }
    }
    if (ret == 0) /* we have a file to use */
    {
        ptr = fgets(astring,MAXSTR,afile);
        if (ptr != NULL)/* we did read some data */
        { /* check for newline, remove */
            ptr = astring + strlen(astring) -1;
            if ('\n' == *ptr) *ptr = '\0';
        }
        else ret = 100; /* set eof return code */
    }
    if (ret) /* not a success */
        astring[0] = '\0';/* .. ensure null string return */
    retcode = ret; /* save return for fglgetret() */
    retquote(astring);/* set string RETURN value.. */
    return(1); /* .. and tell 4gl how many pushed */
}

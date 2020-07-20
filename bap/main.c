/*
 * Bill's ABNF Parser
 * Copyright 2002-2006 William C. Fenner <fenner@research.att.com>
 *  All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the author nor the names of contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY WILLIAM C. FENNER ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL WILLIAM C. FENNER OR HIS
 * BROTHER B1FF BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
 * USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
 * DAMAGE.
 */

#include "config.h"
#include <stdio.h>
#include <stdlib.h>
#include <search.h>
#include <unistd.h>
#include <ctype.h>
#include <string.h>
#include "common.h"

static const char rcsid[] =
  "$Id: main.c,v 1.3 2008-05-30 12:33:45 jre Exp $";
static const char versionstring[] = PACKAGE_VERSION;

static void printobjasxml(object *, int);
static void printobj_r(object *, int, int);
static void printobjasxml_r(object *, int, int);
static void canonify(struct rule *);
static void canonify_r(struct object **);
static void parse_from(char *filename);
static void predefine(fn_list *ifile);
static int summary(void);

#define	MAXRULE		1000	/* XXX */

#define local_printf(format, args...)				\
  if (!olenlimit) {						\
    printf( format, ## args );					\
  } else {							\
    int prevcount = charcount;  \
    charcount += sprintf((charbuf+charcount), format, ## args);	\
    if (charcount > olenlimit) {				\
      char x[1000];  \
      sprintf(x, format, ## args ); \
      if (*x == '<') { /* prose rule? */  \
        charcut = charbuf + prevcount - 1; /* wrap all of it */ \
        charcount = olenlimit + strlen(x) + 1;  \
      } \
      else { \
        charcut = charbuf+olenlimit;				\
        while (*charcut != ' ' && charcut >= charbuf) {		\
        	charcut--;						\
        	charcount++;						\
        }								\
      } \
      if (charcut != charbuf) {					\
      	*charcut++ = 0;						\
      	printf("%s\n", charbuf);				\
      	if (*charbuf == ';') {					\
      	  memmove(charbuf+2, charcut, charcount - olenlimit);	\
      	  *(charbuf+1) = ' ';					\
      	  charcount -= (olenlimit-1);				\
      	} else {						\
      	  memmove(charbuf+1, charcut, charcount - olenlimit);	\
      	  *charbuf = ' ';					\
      	  charcount -= olenlimit;				\
      	}							\
      }								\
    }								\
    /* flush the line when EOL present */ \
    charcut = strchr(charbuf, '\n');				\
    if (charcut) {						\
      printf("%s", charbuf);					\
      charcount = 0;						\
    }								\
  }
    

char *charbuf = NULL;
char *charcut = NULL;
int charcount = 0;

struct rule *rules = NULL;
char *input_file; /* of current input file */

char *top_rule_name = "ABNF";

int cflag = 0;		/* include line number comments */
int c2flag = 0;		/* include comments for printable constants */
int tflag = 0;		/* print type info */
int permissive = 1;	/* Be permissive (e.g. accept '|') */
int rfc7405 = 0;	/* Support RFC 7405 (%s/%i) */
int qflag = 0;		/* quiet */
int canon = 1;		/* canonify */
int asxml = 0;    /* output XML */
int olenlimit = 0;   /* 0 for unlimited, might be any other value */
int listrulex = 0;   /* 0 for RFC 7320-style, 1 for 2019 experimental (recipient), 2 for 2019 experimental (sender) */

int yyparse(void);

void
usage(void)
{
  fprintf(stderr, "Bill's ABNF Parser version %s\n", versionstring);
  fprintf(stderr, " (with extensions from <https://svn.tools.ietf.org/svn/wg/httpbis/abnfparser/bap/>)\n", versionstring);
  fprintf(stderr, "usage: bap [-cknqtx][-i rules][-l num][-L rtyp][-S name][-X ext][file]\n");
  fprintf(stderr, " parse ABNF grammar from file or stdin\n");
  fprintf(stderr, " Input options:\n");
  fprintf(stderr, "  -c       include rule definition line # in comment\n");
  fprintf(stderr, "  -i file  read predefined rules from \"file\"\n");
  fprintf(stderr, "  -S name  name rule as production start\n");
  fprintf(stderr, "  -X ext   comma-separated list of allowed extensions\n");
  fprintf(stderr, "           (only value currently supported is rfc7405)\n");
  fprintf(stderr, " Output options:\n");
  fprintf(stderr, "  -k       add comments for printable characters specified as %%x\n");
  fprintf(stderr, "  -l num   limit the length of each line to \"num\" characters\n");
  fprintf(stderr, "  -L rtyp  how to expand #list production (0 == 2014, 1 == 2019)\n");
  fprintf(stderr, "  -n       don't \"canonify\" result\n");
  fprintf(stderr, "  -q       don't print parsed grammar\n");
  fprintf(stderr, "  -t       include type info in result\n");
  fprintf(stderr, "  -x       output XML\n");
  exit(1);
}

int
main(int argc, char **argv)
{
  int ch;
  int rc = 0;
  struct rule *r;
  fn_list *pre_input = NULL;
  
#ifdef YYDEBUG
  extern int yydebug;

  yydebug = 0;
#endif
  hcreate(MAXRULE);

  while ((ch = getopt(argc, argv, "cdi:kntqS:xl:L:X:")) != -1) {
    switch (ch) {
    case 'c':
      cflag++;
      break;

    case 'd':
#ifdef YYDEBUG
      yydebug = 1;
#else
      fprintf(stderr, "Rebuild with -DYYDEBUG to use -d.\n");
#endif
      break;

    case 'k':
      c2flag++;
      break;

    case 'n':
      canon = 0;
      break;

    case 'i': {
      fn_list *ifile = calloc(sizeof(fn_list), 1);
      ifile->filename = optarg;
      ifile->next = pre_input;
      pre_input = ifile;
      break;
    }
      
    case 't':
      tflag++;
      break;

    case 'p':
      permissive = 0;
      break;

    case 'q':
      qflag++;
      break;

    case 'S': 
      top_rule_name = optarg;
      break;
      
    case 'X': {
        char *x = strtok(optarg, ",");
        while (x != NULL) {
          if (0 == strcmp(x, "rfc7405")) {
            rfc7405 = 1;
          }
          else {
            fprintf(stderr, "unknown extension: %s\n", x);
            exit(2);
          }
          x = strtok(NULL, ",");
        }
      }
      break;

    case 'x':
      asxml = 1;
      break;

    case 'l':
      olenlimit = atoi(optarg);
      break;

    case 'L':
      listrulex = atoi(optarg);
      if (listrulex != 0 && listrulex != 1l && listrulex != 2) {
        fprintf(stderr, "-L: illegal argument %d\n", listrulex);
        exit(2);
      }
      break;

    default:
      usage();
    }
  }
  argc -= optind;
  argv += optind;

  if (argc > 1)
    usage();

  if (olenlimit) {
    charbuf = (char *) calloc (8192, sizeof(char));
  }
  predefine(pre_input);    
  
  /* Parse the grammar, perhaps spouting errors. */
  parse_from((argc > 0)? argv[0] : NULL);

  /* If we're not quiet, then output the grammar again. */
  if (!qflag) {
    if (canon)
      canonify(rules);
    if (!asxml) {
      for (r = rules; r; r = r->next) {
	if (r->predefined) {
	  /* do not output */
	}
	else if (r->rule) {
	  local_printf("%s = ", r->name);
	  printobj(r->rule, tflag);
	  if (cflag)
	    local_printf(" ; line %d", r->line);
	  local_printf("\n");
	} else {
	  local_printf("; %s UNDEFINED\n", r->name);
	}
	if (r->next == rules)
	  break;
      }
      for (r = rules; r; r = r->next) {
	if (r->used == 0 
	    && r->predefined == 0 
	    && r->rule 
	    && strcmp(r->name, top_rule_name))
	  local_printf("; %s defined but not used\n", r->name);
	if (r->next == rules)
	  break;
      }
    }
    else {
      local_printf("<abnf xmlns='tag:greenbytes.de,2008:abnf'>\n");
      for (r = rules; r; r = r->next) {
	if (r->predefined) {
	  /* do not output */
	}
	else if (r->rule) {
          local_printf("  <rule name='%s'", r->name);
	  if (cflag)
	    local_printf(" line='%d'", r->line);
          local_printf(">");
	  printobjasxml(r->rule, 2);
          local_printf("\n  </rule>\n");
	} else {
	  local_printf("  <undefined name='%s'/>\n", r->name);
	}
	if (r->next == rules)
	  break;
      }
      local_printf("</abnf>\n");
    }
  }
  
  rc = summary();
  hdestroy();
  exit(rc);
}

void
canonify(struct rule *rules)
{
  struct rule *r;

  for (r = rules; r; r = r->next) {
    if (r->rule)
      canonify_r(&r->rule);
    if (r->next == rules)
      break;
  }
}

/* XXX may need to modify in the future? */
void
canonify_r(struct object **op)
{
  struct object *o = *op;
  while (o) {
    switch (o->type) {
    case T_ALTERNATION:
      canonify_r(&o->u.alternation.left);
      canonify_r(&o->u.alternation.right);
      break;
    case T_RULE:
      /* nothing to do */
      break;
    case T_GROUP:
      canonify_r(&o->u.e.e.group);
      break;
    case T_TERMSTR:
      while (o->next && o->next->type == T_TERMSTR &&
	     o->u.e.repetition.lo == 1 && o->u.e.repetition.hi == 1 &&
	     o->next->u.e.repetition.lo == 1 && o->next->u.e.repetition.hi == 1 &&
	     ((o->u.e.e.termstr.flags & F_CASESENSITIVE) ==
	      (o->next->u.e.e.termstr.flags & F_CASESENSITIVE))) {
	int len = strlen(o->u.e.e.termstr.str) + strlen(o->next->u.e.e.termstr.str);
	char *p = malloc(len + 1);
	strcpy(p, o->u.e.e.termstr.str);
	strcat(p, o->next->u.e.e.termstr.str);
	free(o->u.e.e.termstr.str);
	o->u.e.e.termstr.str = p;
	/* XXX leak o->next */
	o->next = o->next->next;
      }
      if (o->u.e.e.termstr.flags & F_CASESENSITIVE) {
	int anybad = 0;
	char *p;
	for (p = o->u.e.e.termstr.str; *p; p++) {
	  if (isalpha(*p) || *p == '"' || !isprint(*p)) {
	    anybad = 1;
	    break;
	  }
	}
	if (anybad == 0)
	  o->u.e.e.termstr.flags &= ~F_CASESENSITIVE;
      }
    case T_TERMRANGE:
    case T_PROSE:
    default:
      /* nothing to do */
      break;
    }
    o = o->next;
  }
}

void
printrep(struct range *rep)
{
  if (rep->lo == 1 && rep->hi == 1)
    return;
  if (rep->lo > 0)
    local_printf("%d", rep->lo);
  if (rep->lo == rep->hi) {
    if (rep->lo == 0)
      local_printf("0");
    return;
  }
  local_printf("*");
  if (rep->hi != -1)
    local_printf("%d", rep->hi);
}

void
printobj(object *o, int tflag)
{
  /* T_GROUP means don't put grouping characters
   * around the top level. */
  printobj_r(o, T_GROUP, tflag);
}

void
printobjasxml(object *o, int indent)
{
  /* T_GROUP means don't put grouping characters
   * around the top level. */
  printobjasxml_r(o, T_GROUP, indent);
}

/*
 * No paren needed around a group that's:
 * - not concatenation (no next)
 * - not an ALTERNATION
 * - got a repeat count of 1
 */
#define	NOPAREN(o)	((o->next == NULL) && (o->type != T_ALTERNATION) && (o->u.e.repetition.lo == 1 && o->u.e.repetition.hi == 1))

/*
 * No brackets needed around a group that
 * contains a single element that has a
 * possible repetition of 0.
 */
#define NOBRACKET(o)	((o->next == NULL) && (o->u.e.repetition.lo == 0))

// code to emit #rule (RFC 7230)
static void
p_listrule_rfc7230(object *o)
{
  if (o->u.e.repetition.lo == 0) {
    local_printf("[ ( \",\" / ");
    if (o->type == T_GROUP) {
      local_printf("( ");
      printobj_r(o->u.e.e.group, o->type, tflag);
      local_printf(" )");
    } else if (o->u.e.e.rule.rule) {
      local_printf("%s", o->u.e.e.rule.rule->name);
      o->u.e.e.rule.rule->used = 1;
    } else {
      local_printf("%s", o->u.e.e.rule.name);
    }
    local_printf(" ) *( OWS \",\" [ OWS ");
    if (o->type == T_GROUP) {
      local_printf("( ");
      printobj_r(o->u.e.e.group, o->type, tflag);
      local_printf(" )");
    } else {
      local_printf("%s", (o->u.e.e.rule.rule) ?
      o->u.e.e.rule.rule->name :
      o->u.e.e.rule.name);
      }
    local_printf(" ] ) ]");
  } else if (o->u.e.repetition.lo == 1) {
    local_printf(" *( \",\" OWS ) ");
    if (o->type == T_GROUP) {
      local_printf("( ");
      printobj_r(o->u.e.e.group, o->type, tflag);
      local_printf(" )");
    } else if (o->u.e.e.rule.rule) {
      local_printf("%s", o->u.e.e.rule.rule->name);
      o->u.e.e.rule.rule->used = 1;
    } else {
      local_printf("%s", o->u.e.e.rule.name);
    }
    local_printf(" *( OWS \",\" [ OWS ");
    if (o->type == T_GROUP) {
      local_printf("( ");
      printobj_r(o->u.e.e.group, o->type, tflag);
      local_printf(" )");
    } else {
      local_printf("%s", (o->u.e.e.rule.rule) ?
      o->u.e.e.rule.rule->name :
      o->u.e.e.rule.name);
    }
    local_printf(" ] )");
  }
  else {
    local_printf("TODO: something is wrong");
  }
}

// code to emit #rule (2019, for recipients)
// #element => [ element ] *( OWS "," OWS [ element ] )
static void
p_listrule_2019_recipient(object *o)
{
  local_printf("[ ");
  if (o->type == T_GROUP) {
    local_printf("( ");
    printobj_r(o->u.e.e.group, o->type, tflag);
    local_printf(" )");
  } else if (o->u.e.e.rule.rule) {
    local_printf("%s", o->u.e.e.rule.rule->name);
    o->u.e.e.rule.rule->used = 1;
  } else {
    local_printf("%s", o->u.e.e.rule.name);
  }
  local_printf(" ] *( OWS \",\" OWS [ ");
  if (o->type == T_GROUP) {
    local_printf("( ");
    printobj_r(o->u.e.e.group, o->type, tflag);
    local_printf(" )");
  } else {
    local_printf("%s", (o->u.e.e.rule.rule) ?
    o->u.e.e.rule.rule->name :
    o->u.e.e.rule.name);
  }
  local_printf(" ] )");
}

// code to emit #rule (2019, for sender)
// 1#element => element *( OWS "," OWS element )
// #element => [ 1#element ]
static void
p_listrule_2019_sender(object *o)
{
  if (o->u.e.repetition.lo == 0) {
    local_printf("[ ");
  }
  if (o->type == T_GROUP) {
    local_printf("( ");
    printobj_r(o->u.e.e.group, o->type, tflag);
    local_printf(" )");
  } else if (o->u.e.e.rule.rule) {
    local_printf("%s", o->u.e.e.rule.rule->name);
    o->u.e.e.rule.rule->used = 1;
  } else {
    local_printf("%s", o->u.e.e.rule.name);
  }
  local_printf(" *( OWS \",\" OWS ");
  if (o->type == T_GROUP) {
    local_printf("( ");
    printobj_r(o->u.e.e.group, o->type, tflag);
    local_printf(") ");
  } else {
    local_printf("%s", (o->u.e.e.rule.rule) ?
    o->u.e.e.rule.rule->name :
    o->u.e.e.rule.name);
  }
  local_printf(" )");
  if (o->u.e.repetition.lo == 0) {
    local_printf(" ]");
  }
}

static void
printobj_r(object *o, int parenttype, int tflag)
{
  int iterating = 0;

  /* Put parenthesis around concatenations */
  if (parenttype != T_GROUP && o->next) {
    iterating = 1;
    local_printf("( ");
  }
  while (o) {
    switch (o->type) {
    case T_ALTERNATION:
      if (tflag)
	local_printf("{ALTERNATION}");
      if (o->next)
	local_printf("( ");
      printobj_r(o->u.alternation.left, o->type, tflag);
      local_printf(" / ");
      printobj_r(o->u.alternation.right, o->type, tflag);
      if (o->next)
	local_printf(" )");
      break;
    case T_RULE: /* identation to delimit the code change */
      if (tflag)
      local_printf("{RULE}");
      if (o->u.e.islist) {
        if (listrulex == 0) {
          p_listrule_rfc7230(o);
        } else if (listrulex == 1) {
          p_listrule_2019_recipient(o);
        } else {
          p_listrule_2019_sender(o);
        }
      } else {
	printrep(&o->u.e.repetition);
	if (o->u.e.e.rule.rule) {
	  local_printf("%s", o->u.e.e.rule.rule->name);
	  o->u.e.e.rule.rule->used = 1;
	}
	else {
	  local_printf("%s", o->u.e.e.rule.name);
	}
      }
      break;
    case T_GROUP:
      if (tflag)
	local_printf("{GROUP}");
      if (o->u.e.islist) {
        if (listrulex == 0) {
          p_listrule_rfc7230(o);
        } else if (listrulex == 1) {
          p_listrule_2019_recipient(o);
        } else {
          p_listrule_2019_sender(o);
        }
      } else {
	if (o->u.e.repetition.lo == 0 &&
	    o->u.e.repetition.hi == 1) {
	  if (!NOBRACKET(o->u.e.e.group))
	    local_printf("[ ");
	} else {
	  printrep(&o->u.e.repetition);
	  if (!NOPAREN(o->u.e.e.group))
	    local_printf("( ");
	}
	printobj_r(o->u.e.e.group, o->type, tflag);
	if (o->u.e.repetition.lo == 0 &&
	    o->u.e.repetition.hi == 1) {
	  if (!NOBRACKET(o->u.e.e.group))
	    local_printf(" ]");
	} else {
	  if (!NOPAREN(o->u.e.e.group))
	    local_printf(" )");
	}
      }
      break;
    case T_TERMSTR:
      if (tflag)
	local_printf("{TERMSTR}");
      printrep(&o->u.e.repetition);
      if (o->u.e.e.termstr.flags & F_CASESENSITIVE) {
	unsigned char *p = (unsigned char*)o->u.e.e.termstr.str;
	char sep;
	int allprintable = 1;
	local_printf("%%");
	sep = 'x';
	while (*p) {
	  if (!isgraph(*p)) allprintable = 0;
	  local_printf("%c%02X", sep, *p++);
	  sep = '.';
	}
	if (c2flag && allprintable)
	  local_printf(" ; %s\n", o->u.e.e.termstr.str);
      } else {
	local_printf("%c%s%c", '"', o->u.e.e.termstr.str, '"');
      }
      break;
    case T_TERMRANGE:
      if (tflag)
	local_printf("{TERMRANGE}");
      printrep(&o->u.e.repetition);
      local_printf("%%x%02X-%02X",
	     o->u.e.e.termrange.lo,
	     o->u.e.e.termrange.hi);
      /* XXX isprint does not handle non-ASCII */
      if (c2flag &&
	  isprint(o->u.e.e.termrange.lo) &&
	  isprint(o->u.e.e.termrange.hi)) {
	local_printf(" ; '%c'-'%c'\n",
	       o->u.e.e.termrange.lo,
	       o->u.e.e.termrange.hi);
      }
      break;
    case T_PROSE:
      if (tflag)
	local_printf("{PROSE}");
      printrep(&o->u.e.repetition);
      local_printf("<%s>", o->u.e.e.proseval);
      break;
    default:
      local_printf("{UNKNOWN OBJECT TYPE %d}", o->type);
      break;
    }
    if (o->next)
      local_printf(" ");
    o = o->next;
  }
  if (iterating)
    local_printf(" )");
}

static void
escaped(char *c) {
  while (*c) {
    if (*c == '&') {
      local_printf("&amp;");
    }
    else if (*c == '<') {
      local_printf("&lt;");
    }
    else {
      local_printf("%c", *c);
    }
    c += 1;
  }
}

static void
printobjasxml_r(object *o, int parenttype, int indent)
{
  while (o) {
    switch (o->type) {
    case T_ALTERNATION:
      local_printf("<alternation>\n");
      local_printf("<alternative>");
      printobjasxml_r(o->u.alternation.left, o->type, indent + 2);
      local_printf("</alternative>\n");
      local_printf("<alternative>");
      printobjasxml_r(o->u.alternation.right, o->type, indent + 2);
      local_printf("</alternative>\n");
      local_printf("</alternation>\n");
      break;
    case T_RULE:
      if (o->u.e.islist) {
        local_printf("<list min='%d' max='%d'>\n", o->u.e.repetition.lo, o->u.e.repetition.hi);
	if (o->u.e.e.rule.rule) {
	  local_printf("<rule ref='%s'/>", o->u.e.e.rule.rule->name);
	  o->u.e.e.rule.rule->used = 1;
	}
        else {
	  local_printf("<rule ref='%s'/>", o->u.e.e.rule.name);
        }
        local_printf("</list>\n");
      }
      else {
	if (o->u.e.e.rule.rule) {
	  local_printf("<rule min='%d' max='%d' ref='%s'/>", o->u.e.repetition.lo, o->u.e.repetition.hi, o->u.e.e.rule.rule->name);
	  o->u.e.e.rule.rule->used = 1;
	}
        else {
	  local_printf("<rule min='%d' max='%d' ref='%s'/>", o->u.e.repetition.lo, o->u.e.repetition.hi, o->u.e.e.rule.name);
        }
      }
      break;
    case T_GROUP:
      if (o->u.e.islist) {
        local_printf("<list min='%d' max='%d'>\n", o->u.e.repetition.lo, o->u.e.repetition.hi);
        printobjasxml_r(o->u.e.e.group, o->type, indent + 2);
        local_printf("</list>");
      }
      else {
        local_printf("<group min='%d' max='%d'>\n", o->u.e.repetition.lo, o->u.e.repetition.hi);
	printobjasxml_r(o->u.e.e.group, o->type, indent + 2);
	local_printf("</group>");
      }
      break;
    case T_TERMSTR:
      local_printf("<term min='%d' max='%d'>", o->u.e.repetition.lo, o->u.e.repetition.hi);
      if (o->u.e.e.termstr.flags & F_CASESENSITIVE) {
	unsigned char *p = (unsigned char*)o->u.e.e.termstr.str;
	char sep;
	int allprintable = 1;
	local_printf("%%");
	sep = 'x';
	while (*p) {
	  if (!isgraph(*p)) allprintable = 0;
	  local_printf("%c%02X", sep, *p++);
	  sep = '.';
	}
      } else {
        local_printf("\"");
        escaped(o->u.e.e.termstr.str);
        local_printf("\"");
      }
      local_printf("</term>");
      break;
    case T_TERMRANGE:
      local_printf("<termrange min='%d' max='%d'>", o->u.e.repetition.lo, o->u.e.repetition.hi);
      local_printf("%%x%02X-%02X",
	     o->u.e.e.termrange.lo,
	     o->u.e.e.termrange.hi);
      /* XXX isprint does not handle non-ASCII */
      if (c2flag &&
	  isprint(o->u.e.e.termrange.lo) &&
	  isprint(o->u.e.e.termrange.hi)) {
	local_printf(" ; '%c'-'%c'\n",
	       o->u.e.e.termrange.lo,
	       o->u.e.e.termrange.hi);
      }
      local_printf("</termrange>");
      break;
    case T_PROSE:
      local_printf("<prose min='%d' max='%d'>", o->u.e.repetition.lo, o->u.e.repetition.hi);
      escaped(o->u.e.e.proseval);
      local_printf("</prose>");
      break;
    default:
      local_printf("{UNKNOWN OBJECT TYPE %d}", o->type);
      break;
    }
    if (o->next)
      local_printf(" ");
    o = o->next;
  }
}

struct rule *
findrule(char *name)
{
  char *lowername;
  char *p, *q;
  ENTRY *e;
  ENTRY search;
  struct rule *r;

  lowername = malloc(strlen(name) + 1);
  for (p = name, q = lowername; *p; p++, q++)
    if (isupper(*p))
      *q = tolower(*p);
    else
      *q = *p;
  *q = '\0';
  search.key = lowername;
  search.data = NULL;
  e = hsearch(search, FIND);
  if (e == NULL) {
    r = calloc(1, sizeof(struct rule));
    r->name = name;
    r->lowername = lowername;
    search.data = r;
    e = hsearch(search, ENTER);
    if (e == NULL) {
      fprintf(stderr, "hash table full -- increase MAXRULE\n");
      exit(1);
    }
    if (rules) {
      r->next = rules;
      r->prev = rules->prev;
      rules->prev->next = r;
      rules->prev = r;
    } else {
      rules = r->next = r->prev = r;
    }
    return r;
  } else {
    free(lowername);
    return (struct rule *)e->data;
  }
}

void 
parse_from(char *filename) {
  extern FILE *yyin;
  FILE *fin = NULL;
  
  if (filename != NULL) {
    fin = fopen (filename, "rt");
    if (!fin) {
      fprintf(stderr, "input file not found: %s\n", filename);
      exit(1);
    }
    
    input_file = filename;
    yyin = fin;
  }
  else {
    yyin = stdin;
    input_file = "stdin";
  }
  
  scanreset();
  yyparse();
  
  if (fin) fclose(fin);  
}

void
predefine(fn_list *ifile) {
  struct rule *r;
  for (;ifile; ifile = ifile->next) {
    parse_from(ifile->filename);
  }
  
  for (r = rules; r; r = r->next) {
    /* struct without rule definitions are created when names are used
       they are != null when the rule was actually defined */
    if (r->rule) 
      r->predefined = 1;
    else
      r->used = 1;

    if (r->next == rules)
      break;
  }
}

int
summary(void) {
  extern int yyerrors;
  if (yyerrors > 0) {
    fflush(stdout);
    fprintf(stderr, "parsing failed: %d errors encountered\n", yyerrors);
  }
  return yyerrors;
}


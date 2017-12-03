%{
/*
 * Bill's ABNF parser.
 * Copyright 2002-2004 William C. Fenner <fenner@fenron.com>
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
#include <stdarg.h>
#include <string.h>

#include "common.h"

static const char rcsid[] =
 "$Id: parser.y,v 1.1 2008-05-28 12:01:58 jre Exp $";

extern int yylineno, yycolumn, yyerrors;

int defline;
extern struct rule *rules;
extern char *input_file;

#if defined(YYERROR_VERBOSE) && defined(YYBISON)
#define MYERROR_VERBOSE
#endif
#ifdef MYERROR_VERBOSE
/* HACK-O-ROONIE for yyerror verbosity */
int *yystatep = NULL;
int *yychar1p = NULL;
#endif

int pipewarn = 0;

object *newobj(int);
int yyerror(char *);
int yylex(void);
%}

%union {
	char *string;
	struct range range;
	object *object;
	int retval;
}

%token <string> CHARVAL CHARVALCS PROSEVAL BINVAL DECVAL HEXVAL RULENAME
%token <range> BINVALRANGE DECVALRANGE HEXVALRANGE REPEAT LIST
%token CWSP EQSLASH CRLF

%type <string> numval
%type <range> numvalrange
%type <object> element group option repetition list elements
%type <object> rulerest
%type <retval> definedas

%%

begin:	{
#ifdef MYERROR_VERBOSE
	/* HACK-O-RAMA */ yystatep = &yystate; yychar1p = &yychar1;
#endif
		} rulelist
	;

rulelist: rules
	| rulelist rules
	;

rules:	  rule
	| starcwsp CRLF
	| cwsp RULENAME	{ mywarn(MYERROR, "Indented rules are Right Out."); YYERROR; }
	;

recover:
	| error CRLF
	;

rule:	recover RULENAME { defline = yylineno; } definedas rulerest {
		struct rule *r;

		r = findrule($2);

		if ($4 == 0 || r->name == NULL || r->rule == NULL) {	/* = */
			if ($4) {
				mywarn(MYERROR, "Rule %s does not yet exist; treating /= as =", $2);
			}
			if (r->name && strcmp(r->name, $2))
				if (r->rule)
					mywarn(MYERROR, "Rule %s previously defined as %s on line %d",
						$2, r->name, r->line);
				else
					mywarn(MYWARNING, "rule %s previously referred to as %s",
						$2, r->name);
			if (r->rule)
				mywarn(MYERROR, "Rule %s was already defined on line %d of %s", $2,
               r->line, (r->file? r->file : "stdin"));
			else {
				r->name = $2;
				r->line = defline;
        r->file = input_file;
				r->rule = $5;
				if (r->next != rules) {
					/* unlink r from where it is and move to the end */
					r->prev->next = r->next;
					r->next->prev = r->prev;
					if (rules == r)
						rules = r->next;
					r->prev = rules->prev;
					rules->prev = r;
					r->prev->next = r;
					r->next = rules;
				}
			}
		} else {	/* =/ */
			object *tmp;

			tmp = newobj(T_ALTERNATION);
			tmp->u.alternation.left = r->rule;
			tmp->u.alternation.right = $5;
			r->rule = tmp;
		}
		}
	;

definedas: starcwsp EQSLASH starcwsp	{ $$ = 1; }
	| starcwsp '=' starcwsp		{ $$ = 0; }
	| starcwsp '=' starcwsp CRLF { mywarn(MYERROR, "Empty rule"); YYERROR; /* XXX this CRLF may be the one required to recover from the error, but we've already used it... */}
	| starcwsp repetition { mywarn(MYERROR, "Got definitions, expecting '=' or '=/'"); YYERROR; }
	| starcwsp CRLF { mywarn(MYERROR, "Got EOL, expecting '=' or '=/'"); YYERROR; /* XXX this CRLF may be the one required to recover from the error, but we've already used it... */}
	;

cwsp:	  CWSP
	;

starcwsp:
	| CWSP
	/* | CRLF	{ mywarn(MYERROR, "Blank lines are not permitted inside rules"); YYERROR; } */
	;

rulerest: elements starcwsp CRLF	{ $$ = $1; }
	| elements ')'	{ mywarn(MYERROR, "Extra ')'?  Missing '('?"); YYERROR; }
	| elements ']'	{ mywarn(MYERROR, "Extra ']'?  Missing '['?"); YYERROR; }
	;

elements:
	  repetition
  | list
	| elements cwsp repetition			{
		/* concatenation */
		object *o = $1;

		$$ = $1;
		if (o->type == T_ALTERNATION)
			o = o->u.alternation.right;
		while (o->next)	/* n**2, do this better */
			o = o->next;
		o->next = $3;
		}
	| elements cwsp list			{
		/* concatenation */
		object *o = $1;

		$$ = $1;
		if (o->type == T_ALTERNATION)
			o = o->u.alternation.right;
		while (o->next)	/* n**2, do this better */
			o = o->next;
		o->next = $3;
		}
	| elements starcwsp '/' starcwsp repetition	{
		$$ = newobj(T_ALTERNATION);
		$$->u.alternation.left = $1;
		$$->u.alternation.right = $5;
		}
	| elements starcwsp '|' starcwsp repetition	{
		if (!pipewarn) {
			mywarn(MYERROR, "'/' is the alternation character in ABNF");
			pipewarn = 1;
		}
		$$ = newobj(T_ALTERNATION);
		$$->u.alternation.left = $1;
		$$->u.alternation.right = $5;
		}
	| elements starcwsp '/' starcwsp list	{
		$$ = newobj(T_ALTERNATION);
		$$->u.alternation.left = $1;
		$$->u.alternation.right = $5;
		}
	| elements starcwsp '|' starcwsp list	{
		if (!pipewarn) {
			mywarn(MYERROR, "'/' is the alternation character in ABNF");
			pipewarn = 1;
		}
		$$ = newobj(T_ALTERNATION);
		$$->u.alternation.left = $1;
		$$->u.alternation.right = $5;
		}
	| elements repetition {
		object *o = $1;
		mywarn(MYERROR, "Concatenation of adjacent elements is not allowed (missing whitespace?)");
		printf("; line %d ... trying to concatenate ", yylineno);
		if (o->type == T_ALTERNATION)
			o = o->u.alternation.right;
		while (o->next)	/* n**2, do this better */
			o = o->next;
		printobj(o, 1);
		printf("\n; ... with ");
		printobj($2, 1);
		printf("\n");
		YYERROR;
		}
	| elements starcwsp '=' {
		mywarn(MYERROR, "Encountered definition while parsing rule (Indented rule?)");
		YYERROR;
		}
	| elements starcwsp EQSLASH {
		mywarn(MYERROR, "Encountered definition while parsing rule (Indented rule?)");
		YYERROR;
		}
	;

repetition:
	  element
	| REPEAT element	{
				$$ = $2;
				/* 5*10[foo] is really *10(foo), so leave
				 * the zero that [ put there. */
				if ($$->u.e.repetition.lo != 0)
					$$->u.e.repetition.lo = $1.lo;
				$$->u.e.repetition.hi = $1.hi;
				if ($1.hi < $1.lo && $1.hi != -1)
					mywarn(MYERROR, "Repeat range swapped, should be min*max");
				if ($1.hi == 0)
					mywarn(MYFYI, "absolute repeat count of zero means this element may not occur at all");
				}
	| REPEAT cwsp		{
				mywarn(MYERROR, "No whitespace allowed between repeat and element.");
				YYERROR;
				}
	;

list:
	LIST element	{
				$$ = $2;
				if ($$->u.e.repetition.lo != 0)
					$$->u.e.repetition.lo = $1.lo;
				$$->u.e.repetition.hi = $1.hi;
				if ($1.hi < $1.lo && $1.hi != -1)
					mywarn(MYERROR, "List range swapped, should be min*max");
				if ($1.hi == 0)
					mywarn(MYFYI, "absolute list count of zero means this element may not occur at all");
        if ($1.lo != 0 && $1.lo != 1 && $1.lo != -1)
					mywarn(MYERROR, "List range min must be 0 or 1");
        if ($1.hi != -1)
					mywarn(MYERROR, "List range max must be infinity");
        $$->u.e.islist = 1;
				}
	| LIST cwsp		{
				mywarn(MYERROR, "No whitespace allowed between list and element.");
				YYERROR;
				}
	;

numval:   BINVAL
	| DECVAL
	| HEXVAL
	;

numvalrange:
	  BINVALRANGE
	| DECVALRANGE
	| HEXVALRANGE
	;

element:
	  RULENAME		{
				$$ = newobj(T_RULE);
				$$->u.e.e.rule.name = $1;
				$$->u.e.e.rule.rule = findrule($1);
				if (strcmp($1, $$->u.e.e.rule.rule->name))
					mywarn(MYWARNING, "rule %s defined on line %d referred to as %s", $$->u.e.e.rule.rule->name, $$->u.e.e.rule.rule->line, $1);
				}
	| group	
	| option
	| CHARVAL		{
				char *p = $1;
				if (*$1)
					p += strlen($1) - 1;
				if (*p == '\n' || *p == '\r') {
					mywarn(MYERROR, "unterminated quoted-string");
					YYERROR;
				}
				$$ = newobj(T_TERMSTR);
				$$->u.e.e.termstr.str = $1;
				$$->u.e.e.termstr.flags = 0;
				}
	| CHARVALCS		{
				char *p = $1;
				if (*$1)
					p += strlen($1) - 1;
				if (*p == '\n' || *p == '\r') {
					mywarn(MYERROR, "unterminated quoted-string");
					YYERROR;
				}
				$$ = newobj(T_TERMSTR);
				$$->u.e.e.termstr.str = $1;
				$$->u.e.e.termstr.flags = F_CASESENSITIVE;
				}
	| numval		{
				$$ = newobj(T_TERMSTR);
				$$->u.e.e.termstr.str = $1;
				$$->u.e.e.termstr.flags = F_CASESENSITIVE;
				}
	| numvalrange		{
				$$ = newobj(T_TERMRANGE);
				$$->u.e.e.termrange.lo = $1.lo;
				$$->u.e.e.termrange.hi = $1.hi;
				}
	| PROSEVAL		{
				$$ = newobj(T_PROSE);
				$$->u.e.e.proseval = $1;
				if (strcmp($1, "\"") == 0) {
					mywarn(MYFYI, "suggest DQUOTE or %%x22 instead of <\">.");
				}
				}
	;

group:	  '(' starcwsp elements starcwsp ')'	{
						$$ = newobj(T_GROUP);
						$$->u.e.e.group = $3;
						}
	| '(' starcwsp elements starcwsp CRLF {
		mywarn(MYERROR, "Missing ')'?  Extra '('?");
		YYERROR;
		}
	;

option:	  '[' starcwsp elements starcwsp ']'	{
						$$ = newobj(T_GROUP);
						$$->u.e.e.group = $3;
						$$->u.e.repetition.lo = 0;
						}
	| '[' starcwsp elements starcwsp CRLF {
		mywarn(MYERROR, "Missing ']'?  Extra '['?");
		YYERROR;
		}
	;

%%

void
mywarn(int level, const char *fmt, ...)
{
	va_list ap;

	/* file name */
	fprintf(stderr, "%s(%d:%d): ", input_file, yylineno, yycolumn);
	switch (level) {
		case MYFYI: fprintf(stderr, "fyi: "); break;
		case MYWARNING: fprintf(stderr, "warning: "); break;
		case MYERROR: ++yyerrors; /* fall through */
		default: fprintf(stderr, "error: "); break;
	}
	va_start(ap, fmt);
	vfprintf(stderr, fmt, ap);
	fprintf(stderr, "\n");
}

int
yyerror(char *s)
{
#ifdef MYERROR_VERBOSE
	mywarn(MYERROR, "state %d, token %s: %s", 
		*yystatep,
		(yychar1p && (*yychar1p >= 0 && *yychar1p <= (sizeof(yytname)/sizeof(yytname[0])))) ? yytname[*yychar1p] : "?",
		s);
#else
	mywarn(MYERROR, "%s\n", s);
#endif
	return 0;
}

object *
newobj(int type)
{
	object *o;

	o = calloc(sizeof(object), 1);
	if (o == NULL) {
		mywarn(MYERROR, "out of memory");
		exit(1);
	}
	o->type = type;
	o->next = NULL;
	switch (type) {
		case T_RULE:
		case T_GROUP:
		case T_TERMSTR:
		case T_TERMRANGE:
		case T_PROSE:
			o->u.e.repetition.lo = 1;
			o->u.e.repetition.hi = 1;
			break;
	}
	return o;
}

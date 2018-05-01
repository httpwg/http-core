%{
/*
 * Bill's ABNF parser.
 * Copyright 2002-2007 William C. Fenner <fenner@fenron.com>
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
#include <stdlib.h>
#include <string.h>
#include "common.h"
#include "y.tab.h"

static const char rcsid[] =
 "$Id: scanner.l,v 1.1 2008-05-28 12:01:58 jre Exp $";

int yycolumn = 0;
int yyerrors = 0;
extern int permissive;
extern int rfc7405;
int indent = -1;

char badchar;

static void scanrange(char *, int, struct range *);
static char *scanstr(char *, int);
static void gotcr(void);

%}

bit		[01]
digit		[0-9]
hexdig		[0-9A-Fa-f]

rulename	[A-Za-z][-0-9A-Za-z]*
wsp		[ \t]

/* *(%x20-21 / %x23-7E) */
charval		[ !#-~]*

/* *(%x20-3D / %x3F-7E) */
proseval	[ -=?-~]*

mycrlf	(\n\r|\r\n|\r|\n)

/* %x may be a flex feature; %s works but sometimes results in
 * confusing error messages */
%x SKIP

/* line number isn't quite being updated properly.
   suspect unterminated charval and prosevals. */
%%
<SKIP>.*{mycrlf}	{ 	char q = (badchar == '\'') ? '"' : '\'';
				mywarn(MYERROR, "Illegal character %c%c%c - skipping to end of line", q, badchar, q);
				gotcr();
				BEGIN(INITIAL);
				return CRLF; }
\"{charval}["\r\n]	{
			char *p;
			yycolumn += strlen(yytext);
			yylval.string = strdup(yytext + 1);
			p = &yylval.string[strlen(yylval.string) - 1];
			if (*p != '"') {
				mywarn(MYERROR, "unterminated char-val");
				unput(*p);	/* put the cr or lf back */
			}
			*p = '\0';
			if (*yylval.string == '\0')
				mywarn(MYWARNING, "zero-length char-val");
			return CHARVAL;
			}
\%i\"{charval}["\r\n]	{
      if (!rfc7405) {
				mywarn(MYERROR, "need to enable support for RFC 7405 using -Xrfc7405");
        badchar = yytext[0];
        BEGIN(SKIP);
      }
			char *p;
			yycolumn += strlen(yytext);
			yylval.string = strdup(yytext + 3);
			p = &yylval.string[strlen(yylval.string) - 1];
			if (*p != '"') {
				mywarn(MYERROR, "unterminated char-val");
				unput(*p);	/* put the cr or lf back */
			}
			*p = '\0';
			if (*yylval.string == '\0')
				mywarn(MYWARNING, "zero-length char-val");
			return CHARVAL;
			}
\%s\"{charval}["\r\n]	{
      if (!rfc7405) {
				mywarn(MYERROR, "need to enable support for RFC 7405 using -Xrfc7405");
        badchar = yytext[0];
        BEGIN(SKIP);
      }
			char *p;
			yycolumn += strlen(yytext);
			yylval.string = strdup(yytext + 3);
			p = &yylval.string[strlen(yylval.string) - 1];
			if (*p != '"') {
				mywarn(MYERROR, "unterminated char-val");
				unput(*p);	/* put the cr or lf back */
			}
			*p = '\0';
			if (*yylval.string == '\0')
				mywarn(MYWARNING, "zero-length char-val");
			return CHARVALCS;
			}
\<{proseval}[>\r\n]	{
			char *p;
			yycolumn += strlen(yytext);
			yylval.string = strdup(yytext + 1);
			p = &yylval.string[strlen(yylval.string) - 1];
			if (*p != '>') {
				mywarn(MYERROR, "unterminated prose-val");
				unput(*p);	/* put the cr or lf back */
			}
			*p = '\0';
			return PROSEVAL;
			}
{rulename}		{
			/* record the indentation of the first rule name. */
			if (indent == -1)
				indent = yycolumn;
			yycolumn += strlen(yytext);
			yylval.string = strdup(yytext);
			return RULENAME;
			}
%[Bb]{bit}+(-|\.\.){bit}+		{
			yycolumn += strlen(yytext);
			scanrange(yytext + 2, 2, &yylval.range);
			return BINVALRANGE;
			}
%[Bb]{bit}+(\.{bit}+)*	{
			yycolumn += strlen(yytext);
			yylval.string = scanstr(yytext + 2, 2);
			return BINVAL;
			}
%[Bb].			{ mywarn(MYERROR, "bad bit value");
			  badchar = yytext[2]; BEGIN(SKIP); }
%[Dd]{digit}+(-|\.\.){digit}+	{
			yycolumn += strlen(yytext);
			scanrange(yytext + 2, 10, &yylval.range);
			return DECVALRANGE;
			}
%[Dd]{digit}+(\.{digit}+)*	{
			yycolumn += strlen(yytext);
			yylval.string = scanstr(yytext + 2, 10);
			return DECVAL;
			}
%[Dd].			{ mywarn(MYERROR, "bad decimal value");
			  badchar = yytext[2]; BEGIN(SKIP); }
%[Xx]{hexdig}+(-|\.\.){hexdig}+	{
			yycolumn += strlen(yytext);
			scanrange(yytext + 2, 16, &yylval.range);
			return HEXVALRANGE;
			}
%[Xx]{hexdig}+(\.{hexdig}+)*	{
			yycolumn += strlen(yytext);
			yylval.string = scanstr(yytext + 2, 16);
			return HEXVAL;
			}
%[Xx].			{ mywarn(MYERROR, "bad hex value");
			  badchar = yytext[2]; BEGIN(SKIP); }
{digit}*\*{digit}*	{
			char *ep;

			yycolumn += strlen(yytext);
			yylval.range.lo = strtoul(yytext, &ep, 10);
			if (*ep != '*') {
			    mywarn(MYERROR, "internal scanner error 1");
			    yylval.range.hi = -1;
			} else {
			    yylval.range.hi = strtoul(ep + 1, &ep, 10);
			    if (*ep) {
				mywarn(MYERROR, "internal scanner error 2");
				yylval.range.hi = -1;
			    } else if (yylval.range.hi == 0)
				yylval.range.hi = -1;
			}
			return REPEAT;
			}
{digit}*#{digit}*	{
			char *ep;

			yycolumn += strlen(yytext);
			yylval.range.lo = strtoul(yytext, &ep, 10);
			if (*ep != '#') {
			    mywarn(MYERROR, "internal scanner error 1");
			    yylval.range.hi = -1;
			} else {
			    yylval.range.hi = strtoul(ep + 1, &ep, 10);
			    if (*ep) {
				mywarn(MYERROR, "internal scanner error 2");
				yylval.range.hi = -1;
			    } else if (yylval.range.hi == 0)
				yylval.range.hi = -1;
			}
			return LIST;
			}
{digit}+		{
			char *ep;

			yycolumn += strlen(yytext);
			yylval.range.hi = yylval.range.lo = strtoul(yytext, &ep, 10);
			if (*ep) {
			    mywarn(MYERROR, "internal scanner error 3");
			    yylval.range.hi = yylval.range.lo = 42;
			}
			return REPEAT;
			}
=\/			{ yycolumn += 2; return EQSLASH; }
({wsp}+|(;[^\r\n]*)|{mycrlf}{wsp}+)+	{ char *p = yytext;
				while (*p) {
					/* TO DO:
					 * deal with indent if we
					 * have one set - if a blank
					 * line or a comment is indented
					 * less than enough, we warn
					 * about it. */
					if (*p == '\r') {
						gotcr();
						if (*(++p) == '\n')
							p++;
						continue;
					}
					if (*p == '\n') {
						gotcr();
						if (*(++p) == '\r')
							p++;
						continue;
					}
					p++;
					yycolumn++;
				}
				/* If we don't know the indent yet, then just
				   ignore leading whitespace. */
				if (indent == -1)
					continue;
				/* If there is more whitespace than
				   the initial indent, then tell the parser
				   about the leading whitespace. */
				if (yycolumn > indent)
					return CWSP;
				if (yycolumn < indent) {
					indent = yycolumn;
					mywarn(MYERROR, "adjusting indentation");
				}
				/* Since we didn't have more whitespace than
				   indent, tell the parser it was just
				   a CR. */
				return CRLF; }
{mycrlf}		{ gotcr(); return CRLF; }
[][()=/]		{ yycolumn++; return yytext[0]; }
\|			{ yycolumn++;
			  if (!permissive) {
				badchar = yytext[0];
				BEGIN(SKIP);
			  }
			  return yytext[0]; }
.			{ yycolumn++; badchar = yytext[0]; BEGIN(SKIP); }
%%

static void
scanrange(char *p, int base, struct range *r)
{
	char *ep;

	r->lo = strtoul(p, &ep, base);
	if (*ep != '-' && *ep != '.') {
		mywarn(MYERROR, "internal scanner error 4");
		r->hi = r->lo;
		return;
	}
	if (*ep == '.') {
		if (!permissive) {
			badchar = '.';
			BEGIN(SKIP);
		}
		mywarn(MYERROR, "Ranges use \"-\", not \"..\".");
		ep++;
	}
	r->hi = strtoul(ep + 1, &ep, base);
	if (*ep) {
		mywarn(MYERROR, "internal scanner error 5");
	}
	if (r->hi < r->lo) {
		mywarn(MYERROR, "inverted range");
	}
	return;
}

static char *
scanstr(char *p, int base)
{
	char *ep;
	char buf[512];	/*XXX*/
	char *b = buf;
	int i;

	do {
		i = strtoul(p, &ep, base);
		if (i > 255) {	/* XXX */
			mywarn(MYWARNING, "I can't handle this legal ABNF char value");
			i = 255;
		}
		if (i == 0) {
			mywarn(MYERROR, "This parser will truncate strings at %%x00");
		}
		*b++ = i;
		p = ep + 1;
	} while (*ep == '.');
	if (*ep)
		mywarn(MYERROR, "internal scanner error 6");
	*b++ = '\0';
	return strdup(buf);
}

static void
gotcr(void)
{
	yylineno++;
	yycolumn = 0;
}

void
scanreset(void) {
	yylineno = 0;
	yycolumn = 0;
	indent = -1;
}

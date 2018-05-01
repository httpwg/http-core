EDIT
====

The source files are: draft-ietf-httpbis-*-latest.xml

BUILD
=====

Prerequisites:

  a) bap (see below)

  b) saxon HE 9.7
     - https://www.saxonica.com/html/download/java.html
     - installed or symlinked as "$(HOME)/java/saxon-9-7/saxon9he.jar"

  c) xml2rfc 2.8.5
     - https://xml2rfc.tools.ietf.org/
     - https://pypi.python.org/pypi/xml2rfc

  d) rfcdiff 1.46 (only for make diffs)
     - https://tools.ietf.org/tools/rfcdiff/rfcdiff
     - also requires installing gawk and wdiff

Make:
  make clean
  make
  make diffs

ABNF
====

The build process now uses BAP, Bill Fenner's ABNF parser.

To build BAP:

cd bap
./configure
make

If linking fails, try to change 

  bap:    ${OBJS}
          ${CC} -o $@ ${DEBUG} ${OBJS} -ll
        
to

  bap:    ${OBJS}
          ${CC} -o $@ ${DEBUG} ${OBJS} -lfl
          

The actual build process does the following steps:

1) Extract ABNF

Extracts the individual ABNF fragments (labeled with type="abnf2616") into
build/*.abnf (using XSLT).

2) Parse ABNF and do 1st formatting step

Parse the ABNF using BAP, sort it, and re-parse the result using BAP,
serializing the result with folded lines for RFC production to
build/*.parsed-abnf (using XSLT).

3) Generate Collected ABNF appendix, and check whether the src is up2date

Reads both *.xml and build/*.parsed-abnf using XSLT, generating *.abnf-appendix,
ready for inclusion into the source. While doing so, checks that the current
source has an up to date appendix already.

This step will produce a WARNING message when the newly generated appendix
needs to be refreshed in the source. If it does, run refresh-inclusions.sh on
the source file, or just all:

./refresh-inclusions.sh draft-*.xml

4) Why not automate it?

That would lead to circular dependencies in the Makefile. Help appreciated :-)

5) Combined ABNF

common-abnf.sh combines the multiple parts into a single ABNF, by removing
duplicates (only when the rule is indeed the same) and by removing references
to other parts. There's also some special-casing going on that we'll need to
get rid of at some point of time.


#!/bin/sh
# combine into a single ABNF

bap=bap

[ $# -ne 0 ] || ( echo "combine-abnf.sh file..." >&2 ; exit 2 )

echo "; the ABNF below was extracted from the IETF HTTPbis WG Internet Drafts"
echo "; please see <http://tools.ietf.org/html/draft-ietf-httpbis-p1-messaging>"
echo "; for copyright information."
echo ""

for i in "$@"
do
  $bap/bap -i $bap/core.abnf -L 2 -X rfc7405 -n "$i" 
done | \
	grep -Fv ", defined in [Part" | \
	grep -Fv ", defined in [HTTP" | \
	grep -Fv ", defined in [CONDTNL" | \
	grep -Fv ", defined in [RANGERQ" | \
	grep -Fv ", defined in [CACHING" | \
	grep -Fv ", defined in [AUTHFRM" | \
	grep -Fv ", defined in [RFC723" | \
	grep -Fv ", see [RFC723" | \
	grep -Fv ", see [HTTP" | \
	grep -Fv ", see [CONDTNL" | \
	grep -Fv ", see [RANGERQ" | \
	grep -Fv ", see [CACHING" | \
	grep -Fv ", see [AUTHFRM" | \
	LC_COLLATE=C sort | uniq | \
	$bap/bap -k -i $bap/core.abnf -X rfc7405

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
  $bap/bap -i $bap/core.abnf  -X rfc7405 -n "$i" 
done | \
	fgrep -v ", defined in [Part" | \
	fgrep -v ", defined in [Messaging" | \
	fgrep -v ", defined in [Semantics" | \
	fgrep -v ", defined in [CONDTNL" | \
	fgrep -v ", defined in [RANGERQ" | \
	fgrep -v ", defined in [Caching" | \
	fgrep -v ", defined in [AUTHFRM" | \
	fgrep -v ", defined in [RFC723" | \
	fgrep -v ", see [RFC723" | \
	fgrep -v ", see [Messaging" | \
	fgrep -v ", see [Semantics" | \
	fgrep -v ", see [CONDTNL" | \
	fgrep -v ", see [RANGERQ" | \
	fgrep -v ", see [Caching" | \
	fgrep -v ", see [AUTHFRM" | \
	LC_COLLATE=C sort | uniq | \
	$bap/bap -k -i $bap/core.abnf -X rfc7405

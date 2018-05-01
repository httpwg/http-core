#!/bin/sh
# combine into a single ABNF

bap=tools/bap

[ $# -ne 0 ] || ( echo "combine-abnf.sh file..." >&2 ; exit 2 )

echo "; the ABNF below was extracted from the IETF HTTPbis WG Internet Drafts"
echo "; please see <http://tools.ietf.org/html/draft-ietf-httpbis-p1-messaging>"
echo "; for copyright information."
echo ""

for i in "$@"
do
  $bap/bap -i $bap/core.abnf -n "$i" 
done | \
	fgrep -v ", defined in [Part" | \
	fgrep -v ", defined in [MESSGNG" | \
	fgrep -v ", defined in [SEMNTCS" | \
	fgrep -v ", defined in [CONDTNL" | \
	fgrep -v ", defined in [RANGERQ" | \
	fgrep -v ", defined in [CACHING" | \
	fgrep -v ", defined in [AUTHFRM" | \
	fgrep -v ", defined in [RFC723" | \
	fgrep -v ", see [RFC723" | \
	fgrep -v ", see [MESSGNG" | \
	fgrep -v ", see [SEMNTCS" | \
	fgrep -v ", see [CONDTNL" | \
	fgrep -v ", see [RANGERQ" | \
	fgrep -v ", see [CACHING" | \
	fgrep -v ", see [AUTHFRM" | \
	LC_COLLATE=C sort | uniq | \
	$bap/bap -k -i $bap/core.abnf

#!/bin/sh
# combine into a single ABNF

bap=../../abnfparser/bap

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
	fgrep -v ", defined in [RFC723" | \
	sort | uniq | \
	$bap/bap -k -i $bap/core.abnf

mkdir submit
v=00
for i in auth cache conditional messaging range semantics
do
  cp -v draft-ietf-httpbis-$i-latest.txt submit/draft-ietf-httpbis-$i-$v.txt
  cp -v build/draft-ietf-httpbis-$i-latest.redxml submit/draft-ietf-httpbis-$i-$v.xml
done
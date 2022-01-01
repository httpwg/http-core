all:	rfc9110-to-be.diff rfc9111-to-be.diff rfc9112-to-be.diff rfc9110-to-be.txt.diff rfc9111-to-be.txt.diff rfc9112-to-be.txt.diff

refresh:	rfc9110-to-be.xml rfc9111-to-be.xml rfc9112-to-be.xml

rfc9110-to-be.xml:
	curl https://www.rfc-editor.org/authors/rfc9110.xml -o $@

rfc9111-to-be.xml:
	curl https://www.rfc-editor.org/authors/rfc9111.xml -o $@

rfc9112-to-be.xml:
	curl https://www.rfc-editor.org/authors/rfc9112.xml -o $@

%.txt:	%.xml
	xml2rfc --text -P $< -o $@

draft-ietf-httpbis-semantics-latest.txt:	../build/draft-ietf-httpbis-semantics-latest.redxml
	xml2rfc --text -P $< -o $@

draft-ietf-httpbis-cache-latest.txt:	../build/draft-ietf-httpbis-cache-latest.redxml
	xml2rfc --text -P $< -o $@

draft-ietf-httpbis-messaging-latest.txt:	../build/draft-ietf-httpbis-messaging-latest.redxml
	xml2rfc --text -P $< -o $@

rfc9110-to-be.txt.diff:	rfc9110-to-be.txt draft-ietf-httpbis-semantics-latest.txt
	diff -u draft-ietf-httpbis-semantics-latest.txt rfc9110-to-be.txt > $@ || true

rfc9111-to-be.txt.diff:	rfc9111-to-be.txt draft-ietf-httpbis-cache-latest.txt
	diff -u draft-ietf-httpbis-cache-latest.txt rfc9111-to-be.txt > $@ || true

rfc9112-to-be.txt.diff:	rfc9112-to-be.txt draft-ietf-httpbis-messaging-latest.txt
	diff -u draft-ietf-httpbis-messaging-latest.txt rfc9112-to-be.txt > $@ || true

rfc9110-to-be.diff:	../build/draft-ietf-httpbis-semantics-latest.redxml
	diff -u ../build/draft-ietf-httpbis-semantics-latest.redxml rfc9110-to-be.xml > $@ || true

rfc9111-to-be.diff:	../build/draft-ietf-httpbis-cache-latest.redxml
	diff -u ../build/draft-ietf-httpbis-cache-latest.redxml rfc9111-to-be.xml > $@ || true

rfc9112-to-be.diff:	../build/draft-ietf-httpbis-messaging-latest.redxml
	diff -u ../build/draft-ietf-httpbis-messaging-latest.redxml rfc9112-to-be.xml > $@ || true

 